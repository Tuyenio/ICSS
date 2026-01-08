package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.sql.Date;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

/**
 * API xử lý các thao tác với đơn nghỉ phép (AJAX)
 * @author ICSS
 */
@WebServlet(name = "apiNghiPhep", urlPatterns = {"/apiNghiPhep"})
public class apiNghiPhep extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            HttpSession session = request.getSession();
            String email = (String) session.getAttribute("userEmail");
            
            if (email == null) {
                out.print("{\"success\":false,\"message\":\"Chưa đăng nhập\"}");
                return;
            }
            
            String action = request.getParameter("action");
            KNCSDL kn = new KNCSDL();
            
            switch (action) {
                case "getDonById":
                    getDonById(request, response, out, kn);
                    break;
                    
                case "getNgayPhep":
                    getNgayPhep(request, response, out, kn);
                    break;
                    
                case "getThongKe":
                    getThongKe(request, response, out, kn);
                    break;
                    
                default:
                    out.print("{\"success\":false,\"message\":\"Action không hợp lệ\"}");
            }
            
        } catch (Exception ex) {
            Logger.getLogger(apiNghiPhep.class.getName()).log(Level.SEVERE, null, ex);
            out.print("{\"success\":false,\"message\":\"Lỗi: " + escapeJson(ex.getMessage()) + "\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            HttpSession session = request.getSession();
            String email = (String) session.getAttribute("userEmail");
            String role = (String) session.getAttribute("vaiTro");
            
            if (email == null) {
                out.print("{\"success\":false,\"message\":\"Chưa đăng nhập\"}");
                return;
            }
            
            String action = request.getParameter("action");
            KNCSDL kn = new KNCSDL();
            
            switch (action) {
                case "taoDon":
                    taoDon(request, response, out, kn, email);
                    break;
                    
                case "duyetDon":
                    if ("Quản lý nhân sự".equals(role) || "Admin".equals(role)) {
                        duyetDon(request, response, out, kn, email);
                    } else {
                        out.print("{\"success\":false,\"message\":\"Không có quyền duyệt\"}");
                    }
                    break;
                    
                case "tuChoiDon":
                    if ("Quản lý nhân sự".equals(role) || "Admin".equals(role)) {
                        tuChoiDon(request, response, out, kn, email);
                    } else {
                        out.print("{\"success\":false,\"message\":\"Không có quyền từ chối\"}");
                    }
                    break;
                    
                case "xoaDon":
                    xoaDon(request, response, out, kn);
                    break;
                    
                default:
                    out.print("{\"success\":false,\"message\":\"Action không hợp lệ\"}");
            }
            
        } catch (Exception ex) {
            Logger.getLogger(apiNghiPhep.class.getName()).log(Level.SEVERE, null, ex);
            out.print("{\"success\":false,\"message\":\"Lỗi: " + escapeJson(ex.getMessage()) + "\"}");
        }
    }

    private void getDonById(HttpServletRequest request, HttpServletResponse response, PrintWriter out, KNCSDL kn) throws SQLException {
        try {
            int donId = Integer.parseInt(request.getParameter("id"));
            Map<String, Object> don = kn.getDonNghiPhepById(donId);
            if (don != null) {
                String json = mapToJson(don);
                out.print("{\"success\":true,\"data\":" + json + "}");
            } else {
                out.print("{\"success\":false,\"message\":\"Không tìm thấy đơn\"}");
            }
        } catch (Exception ex) {
            out.print("{\"success\":false,\"message\":\"" + escapeJson(ex.getMessage()) + "\"}");
        }
    }

    private void getNgayPhep(HttpServletRequest request, HttpServletResponse response, PrintWriter out, KNCSDL kn) throws SQLException {
        try {
            int nhanVienId = Integer.parseInt(request.getParameter("nhanVienId"));
            int nam = Integer.parseInt(request.getParameter("nam"));
            Map<String, Object> ngayPhep = kn.getNgayPhepNam(nhanVienId, nam);
            
            if (ngayPhep != null) {
                String json = mapToJson(ngayPhep);
                out.print("{\"success\":true,\"data\":" + json + "}");
            } else {
                out.print("{\"success\":true,\"data\":{\"tong_ngay_phep\":12,\"ngay_phep_da_dung\":0,\"ngay_phep_con_lai\":12}}");
            }
        } catch (Exception ex) {
            out.print("{\"success\":false,\"message\":\"" + escapeJson(ex.getMessage()) + "\"}");
        }
    }

    private void getThongKe(HttpServletRequest request, HttpServletResponse response, PrintWriter out, KNCSDL kn) throws SQLException {
        try {
            Map<String, Integer> thongKe = kn.thongKeDonNghiPhep();
            out.print("{\"success\":true,\"data\":{}}" );
        } catch (Exception ex) {
            out.print("{\"success\":false,\"message\":\"" + escapeJson(ex.getMessage()) + "\"}");
        }
    }

    private void taoDon(HttpServletRequest request, HttpServletResponse response, PrintWriter out, KNCSDL kn, String email) throws SQLException {
        try {
            int nhanVienId = Integer.parseInt(request.getParameter("nhanVienId"));
            String loaiPhep = request.getParameter("loaiPhep");
            String ngayBatDauStr = request.getParameter("ngayBatDau");
            String ngayKetThucStr = request.getParameter("ngayKetThuc");
            double soNgay = Double.parseDouble(request.getParameter("soNgay"));
            String lyDo = request.getParameter("lyDo");
            
            // Kiểm tra số ngày phép còn lại
            Calendar cal = Calendar.getInstance();
            int nam = cal.get(Calendar.YEAR);
            
            Map<String, Object> ngayPhep = kn.getNgayPhepNam(nhanVienId, nam);
            double conLai = 12.0;
            if (ngayPhep != null && ngayPhep.get("ngay_phep_con_lai") != null) {
                Object conLaiObj = ngayPhep.get("ngay_phep_con_lai");
                if (conLaiObj instanceof Number) {
                    conLai = ((Number) conLaiObj).doubleValue();
                } else {
                    conLai = Double.parseDouble(conLaiObj.toString());
                }
            }
            
            // Kiểm tra phép năm
            if ("Phép năm".equals(loaiPhep)) {
                if (soNgay > conLai) {
                    out.print("{\"success\":false,\"message\":\"Không đủ phép năm. Còn lại: " + conLai + " ngày. Vui lòng chọn loại phép khác.\"}");
                    return;
                }
                if (conLai <= 0) {
                    out.print("{\"success\":false,\"message\":\"Bạn đã hết phép năm. Vui lòng chọn loại phép khác.\"}");
                    return;
                }
            }
            
            Map<String, Object> nhanVien = kn.getNhanVienByEmail(email);
            Integer nguoiTaoId = ((Number) nhanVien.get("id")).intValue();
            java.sql.Date ngayBatDau = java.sql.Date.valueOf(ngayBatDauStr);
            java.sql.Date ngayKetThuc = java.sql.Date.valueOf(ngayKetThucStr);
            int donId = kn.taoDonNghiPhep(nhanVienId, loaiPhep, ngayBatDau, ngayKetThuc, soNgay, lyDo, nguoiTaoId, null);
            out.print("{\"success\":true,\"message\":\"Tạo đơn thành công\",\"donId\":" + donId + "}");
        } catch (Exception ex) {
            out.print("{\"success\":false,\"message\":\"" + escapeJson(ex.getMessage()) + "\"}");
        }
    }

    private void duyetDon(HttpServletRequest request, HttpServletResponse response, PrintWriter out, KNCSDL kn, String email) throws SQLException {
        try {
            int donId = Integer.parseInt(request.getParameter("donId"));
            
            // Lấy thông tin đơn
            Map<String, Object> don = kn.getDonNghiPhepById(donId);
            if (don == null) {
                out.print("{\"success\":false,\"message\":\"Không tìm thấy đơn\"}");
                return;
            }
            
            String loaiPhep = (String) don.get("loai_phep");
            double soNgay = Double.parseDouble(don.get("so_ngay").toString());
            int nhanVienId = ((Number) don.get("nhan_vien_id")).intValue();
            
            // Nếu là phép năm, trừ phép
            if ("Phép năm".equals(loaiPhep)) {
                Calendar cal = Calendar.getInstance();
                int nam = cal.get(Calendar.YEAR);
                
                // Cập nhật ngày phép đã dùng
                kn.capNhatNgayPhepDaDung(nhanVienId, nam, soNgay);
            }
            
            Map<String, Object> nhanVien = kn.getNhanVienByEmail(email);
            int nguoiDuyetId = ((Number) nhanVien.get("id")).intValue();
            
            kn.duyetDonNghiPhep(donId, nguoiDuyetId);
            out.print("{\"success\":true,\"message\":\"Duyệt đơn thành công\"}");
        } catch (Exception ex) {
            out.print("{\"success\":false,\"message\":\"" + escapeJson(ex.getMessage()) + "\"}");
        }
    }

    private void tuChoiDon(HttpServletRequest request, HttpServletResponse response, PrintWriter out, KNCSDL kn, String email) throws SQLException {
        try {
            int donId = Integer.parseInt(request.getParameter("donId"));
            String lyDo = request.getParameter("lyDo");
            
            Map<String, Object> nhanVien = kn.getNhanVienByEmail(email);
            int nguoiDuyetId = ((Number) nhanVien.get("id")).intValue();
            
            kn.tuChoiDonNghiPhep(donId, nguoiDuyetId, lyDo);
            out.print("{\"success\":true,\"message\":\"Từ chối đơn thành công\"}");
        } catch (Exception ex) {
            out.print("{\"success\":false,\"message\":\"" + escapeJson(ex.getMessage()) + "\"}");
        }
    }

    private void xoaDon(HttpServletRequest request, HttpServletResponse response, PrintWriter out, KNCSDL kn) throws SQLException {
        try {
            int donId = Integer.parseInt(request.getParameter("donId"));
            int nhanVienId = Integer.parseInt(request.getParameter("nhanVienId"));
            kn.xoaDonNghiPhep(donId, nhanVienId);
            out.print("{\"success\":true,\"message\":\"Xóa đơn thành công\"}");
        } catch (Exception ex) {
            out.print("{\"success\":false,\"message\":\"" + escapeJson(ex.getMessage()) + "\"}");
        }
    }

    private String mapToJson(Map<String, Object> map) {
        StringBuilder json = new StringBuilder("{");
        boolean first = true;
        
        for (Map.Entry<String, Object> entry : map.entrySet()) {
            if (!first) json.append(",");
            json.append("\"").append(entry.getKey()).append("\":");
            
            Object value = entry.getValue();
            if (value == null) {
                json.append("null");
            } else if (value instanceof String) {
                json.append("\"").append(escapeJson((String) value)).append("\"");
            } else if (value instanceof Number) {
                json.append(value);
            } else if (value instanceof Boolean) {
                json.append(value);
            } else {
                json.append("\"").append(escapeJson(value.toString())).append("\"");
            }
            first = false;
        }
        
        json.append("}");
        return json.toString();
    }

    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}
