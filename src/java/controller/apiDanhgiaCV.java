package controller;

import controller.KNCSDL;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.*;
import java.util.*;

public class apiDanhgiaCV extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json; charset=UTF-8");
        req.setCharacterEncoding("UTF-8");

        String taskIdStr = req.getParameter("taskId");

        if (taskIdStr == null || taskIdStr.isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\": \"Thiếu tham số taskId\"}");
            return;
        }

        try {
            int taskId = Integer.parseInt(taskIdStr);
            KNCSDL kn = new KNCSDL();
            List<Map<String, String>> danhGiaList = kn.layDanhGiaTheoCongViec(taskId);

            StringBuilder json = new StringBuilder();
            json.append("[");

            for (int i = 0; i < danhGiaList.size(); i++) {
                Map<String, String> item = danhGiaList.get(i);

                json.append("{");
                json.append("\"nhan_xet\":\"").append(escapeJson(item.get("nhan_xet"))).append("\",");
                json.append("\"thoi_gian\":\"").append(escapeJson(item.get("thoi_gian"))).append("\",");
                json.append("\"ten_nguoi_danh_gia\":\"").append(escapeJson(item.get("ten_nguoi_danh_gia"))).append("\",");
                json.append("\"is_from_worker\":").append(item.get("is_from_worker"));
                json.append("}");

                if (i < danhGiaList.size() - 1) {
                    json.append(",");
                }
            }

            json.append("]");
            resp.getWriter().write(json.toString());

        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\": \"taskId không hợp lệ\"}");
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"error\": \"Lỗi khi truy vấn dữ liệu\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json");
        PrintWriter out = resp.getWriter();

        try {
            int congViecId = Integer.parseInt(req.getParameter("cong_viec_id"));
            int nguoiDanhGiaId = Integer.parseInt(req.getParameter("nguoi_danh_gia_id"));
            String nhanXet = req.getParameter("nhan_xet");

            KNCSDL db = new KNCSDL();
            List<Integer> workerIds = db.getDanhSachNguoiNhanId(congViecId);
            int isFromWorker = workerIds.contains(nguoiDanhGiaId) ? 1 : 0;
            boolean result = db.insertDanhGia(congViecId, nguoiDanhGiaId, nhanXet, isFromWorker);

            if (result) {
                db = new KNCSDL();
                String tieuDeTB = "Đánh giá công việc mới";
                String noiDungTB = "Bạn vừa có thêm đánh giá cho công việc.";

                // Gửi cho tất cả người nhận của công việc
                List<Integer> danhSachNguoiNhan = db.getDanhSachNguoiNhanId(congViecId);
                for (int nhanId : danhSachNguoiNhan) {
                    String role = db.getVaiTroById(nhanId);
                    String link = "";

                    // 🔥 Nếu là Admin hoặc Quản lý → vào giao diện Admin
                    if (role != null && (role.equalsIgnoreCase("Admin") || role.equalsIgnoreCase("Quản lý"))) {
                        link = "dsCongviec?taskId=" + congViecId;
                    } else {
                        // 🔥 Ngược lại nhân viên dùng giao diện của NV
                        link = "dsCongviecNV?taskId=" + congViecId;
                    }
                    db.insertThongBao(nhanId, tieuDeTB, noiDungTB, "Đánh giá", link);
                }

                // Ghi log lịch sử
                HttpSession session = req.getSession(false);
                int userId = 0;
                if (session != null && session.getAttribute("userId") != null) {
                    try {
                        userId = Integer.parseInt(session.getAttribute("userId").toString());
                    } catch (Exception e) {
                    }
                }
                if (userId > 0) {
                    // Rút gọn nhận xét nếu quá dài
                    String nhanXetShort = nhanXet.length() > 50 ? nhanXet.substring(0, 50) + "..." : nhanXet;
                    String logMsg = "⭐ Thêm đánh giá: \"" + nhanXetShort + "\"";
                    db.themLichSuCongViec(congViecId, userId, logMsg);
                }

                out.print("{\"success\":true}");
            } else {
                out.print("{\"success\":false,\"message\":\"Không thể thêm đánh giá.\"}");
            }
        } catch (Exception e) {
            out.print("{\"success\":false,\"message\":\"" + e.getMessage().replace("\"", "") + "\"}");
        }
    }

    // Hàm escape ký tự JSON cơ bản
    private String escapeJson(String input) {
        if (input == null) {
            return "";
        }
        return input.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}
