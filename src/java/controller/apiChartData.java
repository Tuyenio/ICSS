package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class apiChartData extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String chartType = request.getParameter("type");
        HttpSession session = request.getSession();

        // ✅ Lấy thêm tham số lọc
        String tuNgay = request.getParameter("tu_ngay");
        String denNgay = request.getParameter("den_ngay");
        String phongBan = request.getParameter("phong_ban");

        try {
            KNCSDL kn = new KNCSDL();

            if ("pie".equals(chartType)) {
                // Lọc dữ liệu cho biểu đồ tròn
                Map<String, Object> data = kn.getDataForPieChart(tuNgay, denNgay, phongBan);
                out.print(convertToJson(data));

            } else if ("bar".equals(chartType)) {
                // Lọc dữ liệu cho biểu đồ cột
                Map<String, Object> data = kn.getDataForBarChart(session, tuNgay, denNgay, phongBan);
                out.print(convertToJson(data));

            } else if ("table".equals(chartType)) {
                // Lọc dữ liệu cho bảng chi tiết
                String thang = request.getParameter("thang");
                String nam = request.getParameter("nam");
                List<Map<String, Object>> baoCao;

                if (tuNgay != null && denNgay != null && !tuNgay.isEmpty() && !denNgay.isEmpty()) {
                    baoCao = kn.getBaoCaoTongHopNhanVienByDateRange(tuNgay, denNgay, phongBan);
                } else {
                    baoCao = kn.getBaoCaoTongHopNhanVien(thang, nam, phongBan);
                }

                out.print(convertListToJson(baoCao));

            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\": \"Loại chart không hợp lệ\"}");
            }

        } catch (ClassNotFoundException | SQLException ex) {
            Logger.getLogger(apiChartData.class.getName()).log(Level.SEVERE, null, ex);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"Lỗi khi lấy dữ liệu: " + ex.getMessage() + "\"}");
        }
    }

    // ========== CÁC HÀM PHỤ ==========
    private String convertToJson(Map<String, Object> data) {
        StringBuilder json = new StringBuilder();
        json.append("{");

        @SuppressWarnings("unchecked")
        List<String> labels = (List<String>) data.get("labels");
        @SuppressWarnings("unchecked")
        List<? extends Number> values = (List<? extends Number>) data.get("data");

        json.append("\"labels\":[");
        for (int i = 0; i < labels.size(); i++) {
            if (i > 0) json.append(",");
            json.append("\"").append(escapeJson(labels.get(i))).append("\"");
        }
        json.append("],");

        json.append("\"data\":[");
        for (int i = 0; i < values.size(); i++) {
            if (i > 0) json.append(",");
            json.append(values.get(i));
        }
        json.append("]}");
        return json.toString();
    }

    private String convertListToJson(List<Map<String, Object>> list) {
        StringBuilder json = new StringBuilder();
        json.append("[");

        for (int i = 0; i < list.size(); i++) {
            if (i > 0) json.append(",");
            Map<String, Object> item = list.get(i);
            json.append("{");

            boolean first = true;
            for (Map.Entry<String, Object> entry : item.entrySet()) {
                if (!first) json.append(",");
                json.append("\"").append(entry.getKey()).append("\":");

                Object value = entry.getValue();
                if (value == null) {
                    json.append("null");
                } else if (value instanceof String) {
                    json.append("\"").append(escapeJson(value.toString())).append("\"");
                } else {
                    json.append(value.toString());
                }
                first = false;
            }
            json.append("}");
        }
        json.append("]");
        return json.toString();
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\n", "\\n")
                    .replace("\r", "\\r");
    }

    @Override
    public String getServletInfo() {
        return "API lấy dữ liệu cho biểu đồ và bảng, có lọc theo ngày & phòng ban";
    }
}
