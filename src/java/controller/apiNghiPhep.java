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
                    if ("Quản lý".equals(role) || "Admin".equals(role) || 
                        "Trưởng phòng".equals(role) || "Giám đốc".equals(role)) {
                        duyetDon(request, response, out, kn, email);
                    } else {
                        out.print("{\"success\":false,\"message\":\"Không có quyền duyệt\"}");
                    }
                    break;
                    
                case "tuChoiDon":
                    if ("Quản lý".equals(role) || "Admin".equals(role) || 
                        "Trưởng phòng".equals(role) || "Giám đốc".equals(role)) {
                        tuChoiDon(request, response, out, kn, email);
                    } else {
                        out.print("{\"success\":false,\"message\":\"Không có quyền từ chối\"}");
                    }
                    break;
                    
                case "xoaDon":
                    xoaDon(request, response, out, kn);
                    break;
                    
                case "themNghiPhepMoi":
                    if ("Admin".equals(role) || "Quản lý".equals(role)) {
                        themNghiPhepMoi(request, response, out, kn, email);
                    } else {
                        out.print("{\"success\":false,\"message\":\"Không có quyền thêm mới đơn\"}");
                    }
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
            
            java.sql.Date ngayBatDau = java.sql.Date.valueOf(ngayBatDauStr);
            java.sql.Date ngayKetThuc = java.sql.Date.valueOf(ngayKetThucStr);
            
            // Validation 1: Kiểm tra ngày bắt đầu có phải cuối tuần không
            if (kn.isCuoiTuan(ngayBatDau)) {
                out.print("{\"success\":false,\"message\":\"Ngày bắt đầu không thể là thứ 7 hoặc chủ nhật. Vui lòng chọn ngày làm việc.\",\"resetDate\":true}");
                return;
            }
            
            // Validation 2: Kiểm tra ngày bắt đầu có phải ngày lễ không
            if (kn.isNgayNghiLe(ngayBatDau)) {
                out.print("{\"success\":false,\"message\":\"Ngày bắt đầu trùng với ngày nghỉ lễ. Vui lòng chọn ngày khác.\",\"resetDate\":true}");
                return;
            }
            
            // Validation 3: Kiểm tra ngày kết thúc có phải cuối tuần không
            if (kn.isCuoiTuan(ngayKetThuc)) {
                out.print("{\"success\":false,\"message\":\"Ngày kết thúc không thể là thứ 7 hoặc chủ nhật. Vui lòng chọn ngày làm việc.\",\"resetDate\":true}");
                return;
            }
            
            // Validation 4: Kiểm tra ngày kết thúc có phải ngày lễ không
            if (kn.isNgayNghiLe(ngayKetThuc)) {
                out.print("{\"success\":false,\"message\":\"Ngày kết thúc trùng với ngày nghỉ lễ. Vui lòng chọn ngày khác.\",\"resetDate\":true}");
                return;
            }
            
            // Kiểm tra số ngày phép còn lại
            Calendar cal = Calendar.getInstance();
            int nam = cal.get(Calendar.YEAR);
            
            Map<String, Object> ngayPhep = kn.getNgayPhepNam(nhanVienId, nam);
            double conLai = 0.0;
            double phepNamTruoc = 0.0;
            
            if (ngayPhep != null) {
                if (ngayPhep.get("ngay_phep_con_lai") != null) {
                    Object conLaiObj = ngayPhep.get("ngay_phep_con_lai");
                    if (conLaiObj instanceof Number) {
                        conLai = ((Number) conLaiObj).doubleValue();
                    } else {
                        conLai = Double.parseDouble(conLaiObj.toString());
                    }
                }
                
                if (ngayPhep.get("ngay_phep_nam_truoc") != null) {
                    Object phepNamTruocObj = ngayPhep.get("ngay_phep_nam_truoc");
                    if (phepNamTruocObj instanceof Number) {
                        phepNamTruoc = ((Number) phepNamTruocObj).doubleValue();
                    } else {
                        phepNamTruoc = Double.parseDouble(phepNamTruocObj.toString());
                    }
                }
            }
            
            double tongPhepConLai = conLai + phepNamTruoc;
            
            // Kiểm tra phép năm
            if ("Phép năm".equals(loaiPhep)) {
                if (soNgay > tongPhepConLai) {
                    String msg = "Không đủ phép năm. Còn lại: " + conLai + " ngày (năm nay)";
                    if (phepNamTruoc > 0) {
                        msg += " + " + phepNamTruoc + " ngày (năm trước)";
                    }
                    msg += ". Vui lòng chọn loại phép khác.";
                    out.print("{\"success\":false,\"message\":\"" + escapeJson(msg) + "\"}");
                    return;
                }
                if (tongPhepConLai <= 0) {
                    out.print("{\"success\":false,\"message\":\"Bạn đã hết phép năm. Vui lòng chọn loại phép khác.\"}");
                    return;
                }
            }
            
            Map<String, Object> nhanVien = kn.getNhanVienByEmail(email);
            Integer nguoiTaoId = ((Number) nhanVien.get("id")).intValue();
            
            int donId = kn.taoDonNghiPhep(nhanVienId, loaiPhep, ngayBatDau, ngayKetThuc, soNgay, lyDo, nguoiTaoId, null);
            
            // Gửi thông báo cho trưởng phòng nhân sự (ID = 12)
            if (donId > 0) {
                try {
                    String tenNhanVien = (String) nhanVien.get("ho_ten");
                    String tieuDe = "Có đơn xin nghỉ phép cần duyệt";
                    String noiDung = "Nhân viên " + tenNhanVien + " đã gửi đơn xin " + loaiPhep.toLowerCase() 
                        + " từ ngày " + ngayBatDauStr + " đến " + ngayKetThucStr + " (" + soNgay + " ngày). "
                        + "Lý do: " + lyDo;
                    String loaiThongBao = "Đơn xin nghỉ phép";
                    String duongDan = "dsNghiPhep";
                    
                    kn.insertThongBao(12, tieuDe, noiDung, loaiThongBao, duongDan);
                } catch (Exception ex) {
                    // Không dừng quá trình nếu gửi thông báo thất bại
                    ex.printStackTrace();
                }
            }
            
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
            String tenNguoiDuyet = (String) nhanVien.get("ho_ten");
            
            boolean result = kn.duyetDonNghiPhep(donId, nguoiDuyetId);
            
            // Gửi thông báo cho người gửi đơn
            if (result) {
                try {
                    String tenNhanVien = (String) don.get("ten_nhan_vien");
                    String ngayBatDau = don.get("ngay_bat_dau").toString();
                    String ngayKetThuc = don.get("ngay_ket_thuc").toString();
                    
                    String tieuDe = "Đơn xin " + loaiPhep.toLowerCase() + " đã được duyệt";
                    String noiDung = "Đơn xin " + loaiPhep.toLowerCase() + " của bạn từ ngày " + ngayBatDau 
                        + " đến " + ngayKetThuc + " (" + soNgay + " ngày) đã được " + tenNguoiDuyet + " duyệt.";
                    String loaiThongBao = "Đơn xin nghỉ phép";
                    String duongDan = "userNghiPhep";
                    
                    kn.insertThongBao(nhanVienId, tieuDe, noiDung, loaiThongBao, duongDan);
                } catch (Exception ex) {
                    // Không dừng quá trình nếu gửi thông báo thất bại
                    ex.printStackTrace();
                }
            }
            
            out.print("{\"success\":true,\"message\":\"Duyệt đơn thành công\"}");
        } catch (Exception ex) {
            out.print("{\"success\":false,\"message\":\"" + escapeJson(ex.getMessage()) + "\"}");
        }
    }

    private void tuChoiDon(HttpServletRequest request, HttpServletResponse response, PrintWriter out, KNCSDL kn, String email) throws SQLException {
        try {
            int donId = Integer.parseInt(request.getParameter("donId"));
            String lyDo = request.getParameter("lyDo");
            
            // Lấy thông tin đơn trước khi từ chối
            Map<String, Object> don = kn.getDonNghiPhepById(donId);
            if (don == null) {
                out.print("{\"success\":false,\"message\":\"Không tìm thấy đơn\"}");
                return;
            }
            
            Map<String, Object> nhanVien = kn.getNhanVienByEmail(email);
            int nguoiDuyetId = ((Number) nhanVien.get("id")).intValue();
            String tenNguoiDuyet = (String) nhanVien.get("ho_ten");
            
            boolean result = kn.tuChoiDonNghiPhep(donId, nguoiDuyetId, lyDo);
            
            // Gửi thông báo cho người gửi đơn
            if (result) {
                try {
                    String loaiPhep = (String) don.get("loai_phep");
                    String ngayBatDau = don.get("ngay_bat_dau").toString();
                    String ngayKetThuc = don.get("ngay_ket_thuc").toString();
                    double soNgay = Double.parseDouble(don.get("so_ngay").toString());
                    int nhanVienId = ((Number) don.get("nhan_vien_id")).intValue();
                    
                    String tieuDe = "Đơn xin " + loaiPhep.toLowerCase() + " đã bị từ chối";
                    String noiDung = "Đơn xin " + loaiPhep.toLowerCase() + " của bạn từ ngày " + ngayBatDau 
                        + " đến " + ngayKetThuc + " (" + soNgay + " ngày) đã bị từ chối bởi " + tenNguoiDuyet + ". "
                        + "Lý do: " + (lyDo != null && !lyDo.isEmpty() ? lyDo : "Không có lý do cụ thể");
                    String loaiThongBao = "Đơn xin nghỉ phép";
                    String duongDan = "userNghiPhep";
                    
                    kn.insertThongBao(nhanVienId, tieuDe, noiDung, loaiThongBao, duongDan);
                } catch (Exception ex) {
                    // Không dừng quá trình nếu gửi thông báo thất bại
                    ex.printStackTrace();
                }
            }
            
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

    /**
     * Thêm mới đơn nghỉ phép cho nhân viên (chỉ Admin/Quản lý)
     * Được sử dụng để tạo lệnh nghỉ cho nhân viên từ phía quản trị
     */
    private void themNghiPhepMoi(HttpServletRequest request, HttpServletResponse response, PrintWriter out, KNCSDL kn, String email) throws SQLException {
        try {
            int nhanVienId = Integer.parseInt(request.getParameter("nhanVienId"));
            String loaiPhep = request.getParameter("loaiPhep");
            String ngayBatDauStr = request.getParameter("ngayBatDau");
            String ngayKetThucStr = request.getParameter("ngayKetThuc");
            double soNgay = Double.parseDouble(request.getParameter("soNgay"));
            String lyDo = request.getParameter("lyDo");
            
            java.sql.Date ngayBatDau = java.sql.Date.valueOf(ngayBatDauStr);
            java.sql.Date ngayKetThuc = java.sql.Date.valueOf(ngayKetThucStr);
            
            // Validation 1: Kiểm tra ngày bắt đầu có phải cuối tuần không
            if (kn.isCuoiTuan(ngayBatDau)) {
                out.print("{\"success\":false,\"message\":\"Ngày bắt đầu không thể là thứ 7 hoặc chủ nhật. Vui lòng chọn ngày làm việc.\",\"resetDate\":true}");
                return;
            }
            
            // Validation 2: Kiểm tra ngày bắt đầu có phải ngày lễ không
            if (kn.isNgayNghiLe(ngayBatDau)) {
                out.print("{\"success\":false,\"message\":\"Ngày bắt đầu trùng với ngày nghỉ lễ. Vui lòng chọn ngày khác.\",\"resetDate\":true}");
                return;
            }
            
            // Validation 3: Kiểm tra ngày kết thúc có phải cuối tuần không
            if (kn.isCuoiTuan(ngayKetThuc)) {
                out.print("{\"success\":false,\"message\":\"Ngày kết thúc không thể là thứ 7 hoặc chủ nhật. Vui lòng chọn ngày làm việc.\",\"resetDate\":true}");
                return;
            }
            
            // Validation 4: Kiểm tra ngày kết thúc có phải ngày lễ không
            if (kn.isNgayNghiLe(ngayKetThuc)) {
                out.print("{\"success\":false,\"message\":\"Ngày kết thúc trùng với ngày nghỉ lễ. Vui lòng chọn ngày khác.\",\"resetDate\":true}");
                return;
            }
            
            // Kiểm tra số ngày phép còn lại (nếu là phép năm)
            if ("Phép năm".equals(loaiPhep)) {
                Calendar cal = Calendar.getInstance();
                int nam = cal.get(Calendar.YEAR);
                
                Map<String, Object> ngayPhep = kn.getNgayPhepNam(nhanVienId, nam);
                double conLai = 0.0;
                double phepNamTruoc = 0.0;
                
                if (ngayPhep != null) {
                    if (ngayPhep.get("ngay_phep_con_lai") != null) {
                        Object conLaiObj = ngayPhep.get("ngay_phep_con_lai");
                        if (conLaiObj instanceof Number) {
                            conLai = ((Number) conLaiObj).doubleValue();
                        } else {
                            conLai = Double.parseDouble(conLaiObj.toString());
                        }
                    }
                    
                    if (ngayPhep.get("ngay_phep_nam_truoc") != null) {
                        Object phepNamTruocObj = ngayPhep.get("ngay_phep_nam_truoc");
                        if (phepNamTruocObj instanceof Number) {
                            phepNamTruoc = ((Number) phepNamTruocObj).doubleValue();
                        } else {
                            phepNamTruoc = Double.parseDouble(phepNamTruocObj.toString());
                        }
                    }
                }
                
                double tongPhepConLai = conLai + phepNamTruoc;
                
                if (soNgay > tongPhepConLai) {
                    String msg = "Không đủ phép năm. Còn lại: " + conLai + " ngày (năm nay)";
                    if (phepNamTruoc > 0) {
                        msg += " + " + phepNamTruoc + " ngày (năm trước)";
                    }
                    msg += ". Vui lòng chọn số ngày khác.";
                    out.print("{\"success\":false,\"message\":\"" + escapeJson(msg) + "\"}");
                    return;
                }
                if (tongPhepConLai <= 0) {
                    out.print("{\"success\":false,\"message\":\"Nhân viên này đã hết phép năm.\"}");
                    return;
                }
            }
            
            Map<String, Object> nhanVien = kn.getNhanVienByEmail(email);
            Integer nguoiTaoId = ((Number) nhanVien.get("id")).intValue();
            String tenNguoiTao = (String) nhanVien.get("ho_ten");
            
            // Tạo đơn với trạng thái đã duyệt (vì admin tạo trực tiếp)
            int donId = kn.taoDonNghiPhepQuanLy(nhanVienId, loaiPhep, ngayBatDau, ngayKetThuc, 
                                               soNgay, lyDo, nguoiTaoId, "Được tạo bởi " + tenNguoiTao);
            
            // Nếu là phép năm, trừ phép ngay lập tức với ưu tiên phép năm trước trước
            if (donId > 0 && "Phép năm".equals(loaiPhep)) {
                Calendar cal = Calendar.getInstance();
                int nam = cal.get(Calendar.YEAR);
                kn.capNhatNgayPhepDaDungUuTien(nhanVienId, nam, soNgay);
            }
            
            // Gửi thông báo cho nhân viên
            if (donId > 0) {
                try {
                    Map<String, Object> nv = kn.getNhanVienById(nhanVienId);
                    String tenNhanVien = (String) nv.get("ho_ten");
                    String tieuDe = "Nhân viên được cấp phép";
                    String noiDung = "Bạn được cấp " + loaiPhep.toLowerCase() + " từ ngày " + ngayBatDauStr 
                        + " đến " + ngayKetThucStr + " (" + soNgay + " ngày) bởi " + tenNguoiTao + ". "
                        + "Lý do: " + lyDo;
                    String loaiThongBao = "Đơn xin nghỉ phép";
                    String duongDan = "userNghiPhep";
                    
                    kn.insertThongBao(nhanVienId, tieuDe, noiDung, loaiThongBao, duongDan);
                } catch (Exception ex) {
                    // Không dừng quá trình nếu gửi thông báo thất bại
                    ex.printStackTrace();
                }
            }
            
            out.print("{\"success\":true,\"message\":\"Thêm mới đơn thành công\",\"donId\":" + donId + "}");
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
