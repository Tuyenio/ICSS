/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

import java.sql.*;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author Admin
 */
public class KNCSDL {

    Connection cn;
    String path = "jdbc:mysql://localhost:3306/qlns";

    public KNCSDL() throws ClassNotFoundException, SQLException {
        Class.forName("com.mysql.cj.jdbc.Driver");
        this.cn = DriverManager.getConnection(path, "root", "");
    }

    public ResultSet laydl() throws SQLException {
        Statement st = this.cn.createStatement();
        String sql = "SELECT "
                + "nv.id, "
                + "nv.ho_ten, "
                + "nv.email, "
                + "nv.mat_khau, "
                + "nv.so_dien_thoai, "
                + "nv.gioi_tinh, "
                + "nv.ngay_sinh, "
                + "nv.phong_ban_id, "
                + "pb.ten_phong AS ten_phong_ban, "
                + "nv.chuc_vu, "
                + "nv.trang_thai_lam_viec, "
                + "nv.vai_tro, "
                + "nv.ngay_vao_lam, "
                + "nv.avatar_url, "
                + "nv.ngay_tao "
                + "FROM nhanvien nv "
                + "LEFT JOIN phong_ban pb ON nv.phong_ban_id = pb.id";

        ResultSet rs = st.executeQuery(sql);
        return rs;
    }

    public boolean capNhatNhanVien(int id, String hoTen, String email, String matKhau, String sdt, String gioiTinh,
            String ngaySinh, String ngayVaoLam, String tenPhongBan, String chucVu,
            String trangThai, String vaiTro, String avatar) throws SQLException {

        String sql = "UPDATE nhanvien SET ho_ten=?, email=?, mat_khau=?, so_dien_thoai=?, gioi_tinh=?, ngay_sinh=?, "
                + "ngay_vao_lam=?, chuc_vu=?, trang_thai_lam_viec=?, vai_tro=?, avatar_url=?, "
                + "phong_ban_id=(SELECT id FROM phong_ban WHERE ten_phong=?) "
                + "WHERE id=?";
        PreparedStatement ps = cn.prepareStatement(sql);
        ps.setString(1, hoTen);
        ps.setString(2, email);
        ps.setString(3, matKhau);
        ps.setString(4, sdt);
        ps.setString(5, gioiTinh);
        ps.setString(6, ngaySinh);
        ps.setString(7, ngayVaoLam);
        ps.setString(8, chucVu);
        ps.setString(9, trangThai);
        ps.setString(10, vaiTro);
        ps.setString(11, avatar);
        ps.setString(12, tenPhongBan); // Dùng để tìm id trong phong_ban
        ps.setInt(13, id);

        return ps.executeUpdate() > 0;
    }

    public boolean xoaNhanVien(int id) {
        String sql = "DELETE FROM nhanvien WHERE id = ?";
        try (
                 PreparedStatement stmt = cn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            e.printStackTrace(); // In lỗi chi tiết để debug
            return false;
        }
    }

    public boolean themNhanVien(String hoTen, String email, String matKhau, String sdt, String gioiTinh,
            String ngaySinh, String ngayVaoLam, String tenPhongBan, String chucVu,
            String trangThai, String vaiTro, String avatar) throws SQLException {

        String sql = "INSERT INTO nhanvien (ho_ten, email, mat_khau, so_dien_thoai, gioi_tinh, ngay_sinh, "
                + "ngay_vao_lam, chuc_vu, trang_thai_lam_viec, vai_tro, avatar_url, phong_ban_id, ngay_tao) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, "
                + "(SELECT id FROM phong_ban WHERE ten_phong = ?), NOW())";

        try ( PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, hoTen);
            ps.setString(2, email);
            ps.setString(3, matKhau);
            ps.setString(4, sdt);
            ps.setString(5, gioiTinh);
            ps.setString(6, ngaySinh);
            ps.setString(7, ngayVaoLam);
            ps.setString(8, chucVu);
            ps.setString(9, trangThai);
            ps.setString(10, vaiTro);
            ps.setString(11, avatar);
            ps.setString(12, tenPhongBan); // để tìm phong_ban_id

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Map<String, Object>> locNhanVien(String keyword, String phongBan, String trangThai, String vaiTro) throws SQLException {
        List<Map<String, Object>> danhSach = new ArrayList<>();

        String sql = "SELECT nv.*, pb.ten_phong AS ten_phong_ban "
                + "FROM nhanvien nv LEFT JOIN phong_ban pb ON nv.phong_ban_id = pb.id WHERE 1=1";

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += " AND (nv.ho_ten LIKE ? OR nv.email LIKE ?)";
            params.add("%" + keyword + "%");
            params.add("%" + keyword + "%");
        }
        if (phongBan != null && !phongBan.isEmpty()) {
            sql += " AND pb.ten_phong = ?";
            params.add(phongBan);
        }
        if (trangThai != null && !trangThai.isEmpty()) {
            sql += " AND nv.trang_thai_lam_viec = ?";
            params.add(trangThai);
        }
        if (vaiTro != null && !vaiTro.isEmpty()) {
            sql += " AND nv.vai_tro = ?";
            params.add(vaiTro);
        }

        PreparedStatement ps = cn.prepareStatement(sql);
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }

        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            Map<String, Object> nv = new HashMap<>();
            nv.put("id", rs.getInt("id"));
            nv.put("ho_ten", rs.getString("ho_ten"));
            nv.put("email", rs.getString("email"));
            nv.put("mat_khau", rs.getString("mat_khau"));
            nv.put("so_dien_thoai", rs.getString("so_dien_thoai"));
            nv.put("gioi_tinh", rs.getString("gioi_tinh"));
            nv.put("ngay_sinh", rs.getString("ngay_sinh"));
            nv.put("ngay_vao_lam", rs.getString("ngay_vao_lam"));
            nv.put("ten_phong_ban", rs.getString("ten_phong_ban"));
            nv.put("chuc_vu", rs.getString("chuc_vu"));
            nv.put("trang_thai_lam_viec", rs.getString("trang_thai_lam_viec"));
            nv.put("vai_tro", rs.getString("vai_tro"));
            nv.put("avatar_url", rs.getString("avatar_url"));
            nv.put("ngay_tao", rs.getString("ngay_tao"));
            danhSach.add(nv);
        }
        return danhSach;
    }

    public List<Map<String, Object>> getAllTasks() throws SQLException {
        List<Map<String, Object>> tasks = new ArrayList<>();
        String sql = "SELECT cv.*, "
                + "ng1.ho_ten AS nguoi_giao_ten, "
                + "ng2.ho_ten AS nguoi_nhan_ten, "
                + "td.phan_tram, "
                + "pb.ten_phong AS ten_phong "
                + "FROM cong_viec cv "
                + "LEFT JOIN nhanvien ng1 ON cv.nguoi_giao_id = ng1.id "
                + "LEFT JOIN nhanvien ng2 ON cv.nguoi_nhan_id = ng2.id "
                + "LEFT JOIN cong_viec_tien_do td ON cv.id = td.cong_viec_id "
                + "LEFT JOIN phong_ban pb ON cv.phong_ban_id = pb.id";

        try ( PreparedStatement stmt = cn.prepareStatement(sql);  ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> task = new HashMap<>();
                task.put("id", rs.getInt("id"));
                task.put("ten_cong_viec", rs.getString("ten_cong_viec"));
                task.put("mo_ta", rs.getString("mo_ta"));
                task.put("nguoi_giao_id", rs.getString("nguoi_giao_ten"));
                task.put("nguoi_nhan_id", rs.getString("nguoi_nhan_ten"));
                task.put("phan_tram", rs.getString("phan_tram"));
                task.put("phong_ban_id", rs.getString("ten_phong"));
                task.put("muc_do_uu_tien", rs.getString("muc_do_uu_tien"));
                task.put("trang_thai", rs.getString("trang_thai"));
                task.put("han_hoan_thanh", rs.getDate("han_hoan_thanh"));
                tasks.add(task);
            }
        }
        return tasks;
    }

    public ResultSet layNhanVien() throws SQLException {
        return cn.createStatement().executeQuery("SELECT id, ho_ten FROM nhanvien");
    }

    public ResultSet layphongban() throws SQLException {
        return cn.createStatement().executeQuery("SELECT id, ten_phong FROM phong_ban");
    }

    public int getNhanVienIdByName(String ten) throws SQLException {
        String sql = "SELECT id FROM nhanvien WHERE ho_ten = ?";
        try ( PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setString(1, ten);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("id");
            }
        }
        return -1; // Không tìm thấy
    }

    public int getPhongIdByName(String ten) throws SQLException {
        String sql = "SELECT id FROM phong_ban WHERE ten_phong = ?";
        try ( PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setString(1, ten);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("id");
            }
        }
        return -1; // Không tìm thấy
    }

    public String getPhongNameById(int id) throws SQLException {
        String sql = "SELECT ten_phong FROM phong_ban WHERE id = ?";
        try ( PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getString("ten_phong");
            }
        }
        return null; // Không tìm thấy
    }

    public void insertTask(String ten, String moTa, String han, String uuTien,
            int tenNguoiGiao, int tenNguoiNhan, int tenPhong, String trangThai) throws SQLException {

        String sql = "INSERT INTO cong_viec (ten_cong_viec, mo_ta, han_hoan_thanh, muc_do_uu_tien, nguoi_giao_id, nguoi_nhan_id, phong_ban_id, trang_thai) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try ( PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setString(1, ten);
            stmt.setString(2, moTa);
            stmt.setDate(3, java.sql.Date.valueOf(han));
            stmt.setString(4, uuTien);
            stmt.setInt(5, tenNguoiGiao);
            stmt.setInt(6, tenNguoiNhan);
            stmt.setInt(7, tenPhong);
            stmt.setString(8, trangThai);
            stmt.executeUpdate();
        }
    }

    public void updateTask(int id, String ten, String moTa, String han, String uuTien,
            int tenNguoiGiao, int tenNguoiNhan, int tenPhong, String trangThai) throws SQLException {

        String sql = "UPDATE cong_viec SET ten_cong_viec=?, mo_ta=?, han_hoan_thanh=?, muc_do_uu_tien=?, "
                + "nguoi_giao_id=?, nguoi_nhan_id=?, phong_ban_id=?, trang_thai=? WHERE id=?";

        try ( PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setString(1, ten);
            stmt.setString(2, moTa);
            stmt.setDate(3, java.sql.Date.valueOf(han));
            stmt.setString(4, uuTien);
            stmt.setInt(5, tenNguoiGiao);
            stmt.setInt(6, tenNguoiNhan);
            stmt.setInt(7, tenPhong);
            stmt.setString(8, trangThai);
            stmt.setInt(9, id);
            stmt.executeUpdate();
        }
    }

    public ResultSet getStepsRawByTaskId(String taskId) throws SQLException {
        String sql = "SELECT id, ten_buoc, mo_ta, trang_thai, ngay_bat_dau, ngay_ket_thuc "
                + "FROM cong_viec_quy_trinh WHERE cong_viec_id = ? ORDER BY ngay_bat_dau ASC";
        PreparedStatement ps = cn.prepareStatement(sql);
        ps.setString(1, taskId);
        return ps.executeQuery();
    }

    public boolean updateStepById(int stepId, String name, String desc,
            String status, String start, String end) throws SQLException {
        String sql = "UPDATE cong_viec_quy_trinh SET ten_buoc = ?, mo_ta = ?, trang_thai = ?, ngay_bat_dau = ?, ngay_ket_thuc = ? WHERE id = ?";
        PreparedStatement stmt = cn.prepareStatement(sql);
        stmt.setString(1, name);
        stmt.setString(2, desc);
        stmt.setString(3, status);
        stmt.setString(4, start);
        stmt.setString(5, end);
        stmt.setInt(6, stepId);

        int affected = stmt.executeUpdate();
        stmt.close();
        cn.close();
        return affected > 0;
    }

    public boolean deleteStepById(int stepId) throws SQLException {
        String sql = "DELETE FROM cong_viec_quy_trinh WHERE id = ?";
        PreparedStatement stmt = cn.prepareStatement(sql);
        stmt.setInt(1, stepId);

        int affected = stmt.executeUpdate();
        stmt.close();
        cn.close();
        return affected > 0;
    }

    public int insertStep(int congViecId, String tenBuoc, String moTa, String trangThai, String ngayBatDau, String ngayKetThuc) throws SQLException {
        String sql = "INSERT INTO cong_viec_quy_trinh (cong_viec_id, ten_buoc, mo_ta, trang_thai, ngay_bat_dau, ngay_ket_thuc) VALUES (?, ?, ?, ?, ?, ?)";
        PreparedStatement stmt = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
        stmt.setInt(1, congViecId);
        stmt.setString(2, tenBuoc);
        stmt.setString(3, moTa);
        stmt.setString(4, trangThai);
        stmt.setString(5, ngayBatDau);
        stmt.setString(6, ngayKetThuc);

        int affected = stmt.executeUpdate();
        int newId = -1;

        if (affected > 0) {
            ResultSet rs = stmt.getGeneratedKeys();
            if (rs.next()) {
                newId = rs.getInt(1);
            }
            rs.close();
        }

        stmt.close();
        cn.close();
        return newId;
    }

    public List<Map<String, String>> layDanhGiaTheoCongViec(int congViecId) {
        List<Map<String, String>> danhSachDanhGia = new ArrayList<>();
        String sql = """
        SELECT d.nhan_xet, d.thoi_gian, n.ho_ten AS ten_nguoi_danh_gia
        FROM cong_viec_danh_gia d
        JOIN nhanvien n ON d.nguoi_danh_gia_id = n.id
        WHERE d.cong_viec_id = ?
        ORDER BY d.thoi_gian DESC
    """;

        try ( PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, congViecId);
            try ( ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> dg = new HashMap<>();
                    dg.put("nhan_xet", rs.getString("nhan_xet"));
                    dg.put("thoi_gian", rs.getString("thoi_gian"));
                    dg.put("ten_nguoi_danh_gia", rs.getString("ten_nguoi_danh_gia"));
                    danhSachDanhGia.add(dg);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(KNCSDL.class.getName()).log(Level.SEVERE, null, ex);
        }

        return danhSachDanhGia;
    }

    // Thêm đánh giá mới
    public boolean insertDanhGia(int congViecId, int nguoiDanhGiaId, String nhanXet) throws SQLException {
        String sql = "INSERT INTO cong_viec_danh_gia (cong_viec_id, nguoi_danh_gia_id, nhan_xet) VALUES (?, ?, ?)";
        PreparedStatement ps = cn.prepareStatement(sql);
        ps.setInt(1, congViecId);
        ps.setInt(2, nguoiDanhGiaId);
        ps.setString(3, nhanXet);
        int result = ps.executeUpdate();
        ps.close();
        cn.close();
        return result > 0;
    }

    public void capNhatTrangThaiTuTienDo(int congViecId) throws SQLException {
        String sqlTienDo = "SELECT phan_tram FROM cong_viec_tien_do WHERE cong_viec_id = ?";
        String sqlCapNhatTrangThai = "UPDATE cong_viec SET trang_thai = ? WHERE id = ?";

        try ( PreparedStatement ps1 = cn.prepareStatement(sqlTienDo);  PreparedStatement ps2 = cn.prepareStatement(sqlCapNhatTrangThai)) {

            ps1.setInt(1, congViecId);
            try ( ResultSet rs = ps1.executeQuery()) {
                if (rs.next()) {
                    int percent = rs.getInt("phan_tram");
                    String trangThai;

                    if (percent == 0) {
                        trangThai = "Chưa bắt đầu";
                    } else if (percent >= 100) {
                        trangThai = "Đã hoàn thành";
                    } else {
                        trangThai = "Đang thực hiện";
                    }

                    ps2.setString(1, trangThai);
                    ps2.setInt(2, congViecId);
                    ps2.executeUpdate();
                }
            }
        }
    }

    public boolean capNhatTienDo(int congViecId, int phanTram) {
        try {
            // Kiểm tra xem đã có dòng tiến độ cho công việc này chưa
            String sqlCheck = "SELECT 1 FROM cong_viec_tien_do WHERE cong_viec_id = ?";
            PreparedStatement psCheck = cn.prepareStatement(sqlCheck);
            psCheck.setInt(1, congViecId);
            ResultSet rs = psCheck.executeQuery();

            boolean result = false;

            if (rs.next()) {
                // Nếu đã có thì cập nhật
                String sqlUpdate = "UPDATE cong_viec_tien_do SET phan_tram = ?, thoi_gian_cap_nhat = CURRENT_TIMESTAMP WHERE cong_viec_id = ?";
                PreparedStatement psUpdate = cn.prepareStatement(sqlUpdate);
                psUpdate.setInt(1, phanTram);
                psUpdate.setInt(2, congViecId);
                result = psUpdate.executeUpdate() > 0;
            } else {
                // Nếu chưa có thì thêm mới
                String sqlInsert = "INSERT INTO cong_viec_tien_do (cong_viec_id, phan_tram) VALUES (?, ?)";
                PreparedStatement psInsert = cn.prepareStatement(sqlInsert);
                psInsert.setInt(1, congViecId);
                psInsert.setInt(2, phanTram);
                result = psInsert.executeUpdate() > 0;
            }

            // Gọi cập nhật trạng thái sau khi cập nhật tiến độ
            capNhatTrangThaiTuTienDo(congViecId);
            return result;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Map<String, Object>> locCongViec(String keyword, String phongBan, String trangThai) throws SQLException {
        List<Map<String, Object>> danhSach = new ArrayList<>();

        String sql = "SELECT cv.*, "
                + "ng1.ho_ten AS nguoi_giao_ten, "
                + "ng2.ho_ten AS nguoi_nhan_ten, "
                + "td.phan_tram, "
                + "pb.ten_phong AS ten_phong "
                + "FROM cong_viec cv "
                + "LEFT JOIN nhanvien ng1 ON cv.nguoi_giao_id = ng1.id "
                + "LEFT JOIN nhanvien ng2 ON cv.nguoi_nhan_id = ng2.id "
                + "LEFT JOIN cong_viec_tien_do td ON cv.id = td.cong_viec_id "
                + "LEFT JOIN phong_ban pb ON cv.phong_ban_id = pb.id "
                + "WHERE 1=1 ";

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += " AND cv.ten_cong_viec LIKE ?";
            params.add("%" + keyword.trim() + "%");
        }

        if (phongBan != null && !phongBan.isEmpty()) {
            sql += " AND pb.ten_phong = ?";
            params.add(phongBan);
        }

        if (trangThai != null && !trangThai.isEmpty()) {
            sql += " AND cv.trang_thai = ?";
            params.add(trangThai);
        }

        PreparedStatement ps = cn.prepareStatement(sql);
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }

        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, Object> task = new HashMap<>();
            task.put("id", rs.getInt("id"));
            task.put("ten_cong_viec", rs.getString("ten_cong_viec"));
            task.put("mo_ta", rs.getString("mo_ta"));
            task.put("nguoi_giao_id", rs.getString("nguoi_giao_ten"));
            task.put("nguoi_nhan_id", rs.getString("nguoi_nhan_ten"));
            task.put("phan_tram", rs.getString("phan_tram"));
            task.put("phong_ban_id", rs.getString("ten_phong"));
            task.put("muc_do_uu_tien", rs.getString("muc_do_uu_tien"));
            task.put("trang_thai", rs.getString("trang_thai"));
            task.put("han_hoan_thanh", rs.getDate("han_hoan_thanh"));
            danhSach.add(task);
        }

        return danhSach;
    }

    public void xoaCongViec(int id) throws SQLException {
        String sql = "DELETE FROM cong_viec WHERE id = ?";
        try ( PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            stmt.executeUpdate();
        }
    }

    // ============ QUẢN LÝ PHÒNG BAN ============
    
    // Lấy danh sách tất cả phòng ban
    public List<Map<String, Object>> getAllPhongBan() throws SQLException {
        List<Map<String, Object>> danhSach = new ArrayList<>();
        String sql = "SELECT pb.id, pb.ten_phong, pb.truong_phong_id, " +
                    "tp.ho_ten AS truong_phong_ten, pb.ngay_tao, " +
                    "COUNT(nv.id) AS so_nhan_vien " +
                    "FROM phong_ban pb " +
                    "LEFT JOIN nhanvien tp ON pb.truong_phong_id = tp.id " +
                    "LEFT JOIN nhanvien nv ON pb.id = nv.phong_ban_id " +
                    "GROUP BY pb.id, pb.ten_phong, pb.truong_phong_id, tp.ho_ten, pb.ngay_tao " +
                    "ORDER BY pb.id";
        
        try (PreparedStatement stmt = cn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> phongBan = new HashMap<>();
                phongBan.put("id", rs.getInt("id"));
                phongBan.put("ten_phong", rs.getString("ten_phong"));
                phongBan.put("truong_phong_id", rs.getInt("truong_phong_id"));
                phongBan.put("truong_phong_ten", rs.getString("truong_phong_ten"));
                phongBan.put("ngay_tao", rs.getTimestamp("ngay_tao"));
                phongBan.put("so_nhan_vien", rs.getInt("so_nhan_vien"));
                danhSach.add(phongBan);
            }
        }
        return danhSach;
    }
    
    // Lấy chi tiết phòng ban theo ID
    public Map<String, Object> getPhongBanById(int id) throws SQLException {
        Map<String, Object> phongBan = new HashMap<>();
        String sql = "SELECT pb.*, tp.ho_ten AS truong_phong_ten " +
                    "FROM phong_ban pb " +
                    "LEFT JOIN nhanvien tp ON pb.truong_phong_id = tp.id " +
                    "WHERE pb.id = ?";
        
        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    phongBan.put("id", rs.getInt("id"));
                    phongBan.put("ten_phong", rs.getString("ten_phong"));
                    phongBan.put("truong_phong_id", rs.getInt("truong_phong_id"));
                    phongBan.put("truong_phong_ten", rs.getString("truong_phong_ten"));
                    phongBan.put("ngay_tao", rs.getTimestamp("ngay_tao"));
                }
            }
        }
        return phongBan;
    }
    
    // Lấy danh sách nhân viên trong phòng ban
    public List<Map<String, Object>> getNhanVienByPhongBan(int phongBanId) throws SQLException {
        List<Map<String, Object>> danhSach = new ArrayList<>();
        String sql = "SELECT id, ho_ten, email, chuc_vu, vai_tro FROM nhanvien WHERE phong_ban_id = ?";
        
        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, phongBanId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> nhanVien = new HashMap<>();
                    nhanVien.put("id", rs.getInt("id"));
                    nhanVien.put("ho_ten", rs.getString("ho_ten"));
                    nhanVien.put("email", rs.getString("email"));
                    nhanVien.put("chuc_vu", rs.getString("chuc_vu"));
                    nhanVien.put("vai_tro", rs.getString("vai_tro"));
                    danhSach.add(nhanVien);
                }
            }
        }
        return danhSach;
    }
    
    // Thêm phòng ban mới
    public boolean themPhongBan(String tenPhong, Integer truongPhongId) throws SQLException {
        String sql = "INSERT INTO phong_ban (ten_phong, truong_phong_id, ngay_tao) VALUES (?, ?, NOW())";
        
        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setString(1, tenPhong);
            if (truongPhongId != null && truongPhongId > 0) {
                stmt.setInt(2, truongPhongId);
            } else {
                stmt.setNull(2, Types.INTEGER);
            }
            return stmt.executeUpdate() > 0;
        }
    }
    
    // Cập nhật thông tin phòng ban
    public boolean capNhatPhongBan(int id, String tenPhong, Integer truongPhongId) throws SQLException {
        String sql = "UPDATE phong_ban SET ten_phong = ?, truong_phong_id = ? WHERE id = ?";
        
        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setString(1, tenPhong);
            if (truongPhongId != null && truongPhongId > 0) {
                stmt.setInt(2, truongPhongId);
            } else {
                stmt.setNull(2, Types.INTEGER);
            }
            stmt.setInt(3, id);
            return stmt.executeUpdate() > 0;
        }
    }
    
    // Xóa phòng ban
    public boolean xoaPhongBan(int id) throws SQLException {
        // Kiểm tra có nhân viên không trước khi xóa
        String checkSql = "SELECT COUNT(*) FROM nhanvien WHERE phong_ban_id = ?";
        try (PreparedStatement checkStmt = cn.prepareStatement(checkSql)) {
            checkStmt.setInt(1, id);
            try (ResultSet rs = checkStmt.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    return false; // Không được xóa vì còn nhân viên
                }
            }
        }
        
        String sql = "DELETE FROM phong_ban WHERE id = ?";
        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        }
    }
    
    // Lấy lịch sử thay đổi phòng ban
    public List<Map<String, Object>> getLichSuPhongBan(int phongBanId) throws SQLException {
        List<Map<String, Object>> danhSach = new ArrayList<>();
        String sql = "SELECT lsh.*, nv.ho_ten AS nguoi_thay_doi " +
                    "FROM nhan_su_lich_su lsh " +
                    "LEFT JOIN nhanvien nv ON lsh.nguoi_thay_doi_id = nv.id " +
                    "WHERE lsh.nhan_vien_id IN (SELECT id FROM nhanvien WHERE phong_ban_id = ?) " +
                    "OR lsh.loai_thay_doi LIKE '%phòng ban%' " +
                    "ORDER BY lsh.thoi_gian DESC";
        
        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, phongBanId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> lichSu = new HashMap<>();
                    lichSu.put("id", rs.getInt("id"));
                    lichSu.put("loai_thay_doi", rs.getString("loai_thay_doi"));
                    lichSu.put("gia_tri_cu", rs.getString("gia_tri_cu"));
                    lichSu.put("gia_tri_moi", rs.getString("gia_tri_moi"));
                    lichSu.put("nguoi_thay_doi", rs.getString("nguoi_thay_doi"));
                    lichSu.put("ghi_chu", rs.getString("ghi_chu"));
                    lichSu.put("thoi_gian", rs.getTimestamp("thoi_gian"));
                    danhSach.add(lichSu);
                }
            }
        }
        return danhSach;
    }
    
    // Ghi lại lịch sử thay đổi
    public void ghiLichSuThayDoi(int nhanVienId, String loaiThayDoi, String giaTriCu, String giaTriMoi, 
                                int nguoiThayDoiId, String ghiChu) throws SQLException {
        String sql = "INSERT INTO nhan_su_lich_su (nhan_vien_id, loai_thay_doi, gia_tri_cu, gia_tri_moi, " +
                    "nguoi_thay_doi_id, ghi_chu, thoi_gian) VALUES (?, ?, ?, ?, ?, ?, NOW())";
        
        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nhanVienId);
            stmt.setString(2, loaiThayDoi);
            stmt.setString(3, giaTriCu);
            stmt.setString(4, giaTriMoi);
            stmt.setInt(5, nguoiThayDoiId);
            stmt.setString(6, ghiChu);
            stmt.executeUpdate();
        }
    }

}
