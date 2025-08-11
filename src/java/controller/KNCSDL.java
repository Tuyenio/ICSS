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

    public ResultSet laydl(String email) throws SQLException {
        if (email == null || email.trim().isEmpty()) {
            return null;  // Không hợp lệ
        }

        // Truy vấn vai trò và phòng ban từ email
        String getInfoSql = "SELECT vai_tro, phong_ban_id FROM nhanvien WHERE email = ?";
        String vaiTro = null;
        int phongBanId = -1;

        try (PreparedStatement infoStmt = this.cn.prepareStatement(getInfoSql)) {
            infoStmt.setString(1, email);
            try (ResultSet rs = infoStmt.executeQuery()) {
                if (rs.next()) {
                    vaiTro = rs.getString("vai_tro");
                    phongBanId = rs.getInt("phong_ban_id");
                } else {
                    return null;  // Không tìm thấy người dùng
                }
            }
        }

        boolean isAdmin = "Admin".equalsIgnoreCase(vaiTro);

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT nv.id, nv.ho_ten, nv.email, nv.mat_khau, nv.so_dien_thoai, ")
                .append("nv.gioi_tinh, nv.ngay_sinh, nv.phong_ban_id, pb.ten_phong AS ten_phong_ban, ")
                .append("nv.chuc_vu, nv.ngay_vao_lam, nv.trang_thai_lam_viec, nv.vai_tro ")
                .append("FROM nhanvien nv ")
                .append("LEFT JOIN phong_ban pb ON nv.phong_ban_id = pb.id ");

        if (!isAdmin) {
            sql.append("WHERE nv.phong_ban_id = ?");
        }

        PreparedStatement stmt = this.cn.prepareStatement(sql.toString());

        if (!isAdmin) {
            stmt.setInt(1, phongBanId);
        }

        return stmt.executeQuery();  // Gọi servlet phải đóng ResultSet và Connection
    }

    public ResultSet layThongTinNhanVienTheoEmail(String email) throws SQLException {
        if (email == null || email.trim().isEmpty()) {
            return null; // Email không hợp lệ
        }

        String sql = "SELECT nv.id, nv.ho_ten, nv.email, nv.mat_khau, nv.so_dien_thoai, "
                + "nv.gioi_tinh, nv.ngay_sinh, nv.phong_ban_id, pb.ten_phong AS ten_phong_ban, "
                + "nv.chuc_vu, nv.ngay_vao_lam, nv.trang_thai_lam_viec, nv.vai_tro, nv.ngay_tao "
                + "FROM nhanvien nv "
                + "LEFT JOIN phong_ban pb ON nv.phong_ban_id = pb.id "
                + "WHERE nv.email = ?";

        PreparedStatement stmt = this.cn.prepareStatement(sql);
        stmt.setString(1, email);

        return stmt.executeQuery();
    }

    public boolean capNhatNhanVien(int id, String hoTen, String email, String matKhau, String sdt, String gioiTinh,
            String ngaySinh, String ngayVaoLam, String tenPhongBan, String chucVu,
            String trangThai, String vaiTro, String avatar) throws SQLException {

        // Cập nhật thông tin nhân viên
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
        ps.setString(12, tenPhongBan);
        ps.setInt(13, id);

        boolean updated = ps.executeUpdate() > 0;

        if (updated) {
            // 1. Kiểm tra nếu nhân viên đang là trưởng phòng ở bảng phong_ban
            String checkTruongPhongSQL = "SELECT id FROM phong_ban WHERE truong_phong_id = ?";
            try (PreparedStatement checkStmt = cn.prepareStatement(checkTruongPhongSQL)) {
                checkStmt.setInt(1, id);
                ResultSet rs = checkStmt.executeQuery();

                while (rs.next()) {
                    int phongBanId = rs.getInt("id");

                    // 2. Lấy id phòng ban mới theo tên
                    int newPhongBanId = -1;
                    String getPBIdSQL = "SELECT id FROM phong_ban WHERE ten_phong = ?";
                    try (PreparedStatement pbStmt = cn.prepareStatement(getPBIdSQL)) {
                        pbStmt.setString(1, tenPhongBan);
                        ResultSet pbRs = pbStmt.executeQuery();
                        if (pbRs.next()) {
                            newPhongBanId = pbRs.getInt("id");
                        }
                    }

                    // 3. Nếu chuyển sang phòng ban khác hoặc không còn là trưởng phòng
                    if (newPhongBanId != phongBanId || !"Trưởng phòng".equalsIgnoreCase(chucVu)) {
                        // → Gỡ chức trưởng phòng cũ
                        String resetSQL = "UPDATE phong_ban SET truong_phong_id = NULL WHERE id = ?";
                        try (PreparedStatement resetStmt = cn.prepareStatement(resetSQL)) {
                            resetStmt.setInt(1, phongBanId);
                            resetStmt.executeUpdate();
                        }
                    }
                }
            }

            // 4. Nếu chức vụ là "Trưởng phòng" → cập nhật lại bảng phong_ban
            if ("Trưởng phòng".equalsIgnoreCase(chucVu)) {
                String updateTruongPhongSQL = "UPDATE phong_ban SET truong_phong_id = ? WHERE ten_phong = ?";
                try (PreparedStatement updateTruongStmt = cn.prepareStatement(updateTruongPhongSQL)) {
                    updateTruongStmt.setInt(1, id);
                    updateTruongStmt.setString(2, tenPhongBan);
                    updateTruongStmt.executeUpdate();
                }
            }
        }

        return updated;
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

        try (PreparedStatement ps = cn.prepareStatement(sql)) {
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

    // Lọc nhân viên dành cho TRƯỞNG PHÒNG: chỉ thấy người trong PHÒNG BAN của mình
    public List<Map<String, Object>> locNhanVienQL(String keyword, String trangThai, String emailQL, String vaiTro) throws SQLException {
        List<Map<String, Object>> danhSach = new ArrayList<>();

        // Lấy thông tin trưởng phòng theo email
        final String infoSql = "SELECT id, phong_ban_id FROM nhanvien WHERE email = ?";
        Integer phongBanIdQL = null;
        try (PreparedStatement st = cn.prepareStatement(infoSql)) {
            st.setString(1, emailQL);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    phongBanIdQL = rs.getInt("phong_ban_id");
                } else {
                    return danhSach; // không có user hợp lệ
                }
            }
        }

        // Chỉ lọc trong phòng ban của trưởng phòng
        StringBuilder sql = new StringBuilder(
                "SELECT nv.*, pb.ten_phong AS ten_phong_ban "
                + "FROM nhanvien nv "
                + "LEFT JOIN phong_ban pb ON nv.phong_ban_id = pb.id "
                + "WHERE nv.phong_ban_id = ?"
        );
        List<Object> params = new ArrayList<>();
        params.add(phongBanIdQL);

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (nv.ho_ten LIKE ? OR nv.email LIKE ? OR nv.so_dien_thoai LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }
        if (trangThai != null && !trangThai.trim().isEmpty()) {
            sql.append(" AND nv.trang_thai_lam_viec = ?");
            params.add(trangThai.trim());
        }
        if (vaiTro != null && !vaiTro.isEmpty()) {
            sql.append(" AND nv.vai_tro = ?");
            params.add(vaiTro);
        }

        try (PreparedStatement ps = cn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
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
            }
        }
        return danhSach;
    }

    public List<Map<String, Object>> getAllTasks(String email) throws SQLException {
        List<Map<String, Object>> tasks = new ArrayList<>();

        if (email == null || email.trim().isEmpty()) {
            // Không có email → không truy cập
            return tasks;
        }

        // Truy vấn vai trò và phòng ban từ email
        String getInfoSql = "SELECT vai_tro, phong_ban_id, id FROM nhanvien WHERE email = ?";
        String vaiTro = null;
        int phongBanId = -1;
        int userId = -1;

        try (PreparedStatement infoStmt = cn.prepareStatement(getInfoSql)) {
            infoStmt.setString(1, email);
            try (ResultSet rs = infoStmt.executeQuery()) {
                if (rs.next()) {
                    vaiTro = rs.getString("vai_tro");
                    phongBanId = rs.getInt("phong_ban_id");
                    userId = rs.getInt("id");
                } else {
                    // Không tìm thấy người dùng → không trả kết quả
                    return tasks;
                }
            }
        }

        // Viết truy vấn chính
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT cv.*, ")
                .append("ng1.ho_ten AS nguoi_giao_ten, ")
                .append("ng2.ho_ten AS nguoi_nhan_ten, ")
                .append("td.phan_tram, ")
                .append("pb.ten_phong AS ten_phong ")
                .append("FROM cong_viec cv ")
                .append("LEFT JOIN nhanvien ng1 ON cv.nguoi_giao_id = ng1.id ")
                .append("LEFT JOIN nhanvien ng2 ON cv.nguoi_nhan_id = ng2.id ")
                .append("LEFT JOIN cong_viec_tien_do td ON cv.id = td.cong_viec_id ")
                .append("LEFT JOIN phong_ban pb ON cv.phong_ban_id = pb.id ");

        boolean isAdmin = "Admin".equalsIgnoreCase(vaiTro);

        if (!isAdmin) {
            // Nếu không phải admin, cần lọc theo phòng ban hoặc chính người đó
            sql.append("WHERE cv.phong_ban_id = ? OR cv.nguoi_nhan_id = ?");
        }

        try (PreparedStatement stmt = cn.prepareStatement(sql.toString())) {
            if (!isAdmin) {
                stmt.setInt(1, phongBanId);
                stmt.setInt(2, userId);
            }

            try (ResultSet rs = stmt.executeQuery()) {
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
        }
        return tasks;
    }

    public List<Map<String, Object>> getAllTasksNV(String email) throws SQLException {
        List<Map<String, Object>> tasks = new ArrayList<>();
        String sql = "SELECT cv.*, "
                + "ng1.ho_ten AS nguoi_giao_ten, "
                + "ng2.ho_ten AS nguoi_nhan_ten, "
                + "ng2.vai_tro, "
                + "td.phan_tram, "
                + "pb.ten_phong AS ten_phong "
                + "FROM cong_viec cv "
                + "LEFT JOIN nhanvien ng1 ON cv.nguoi_giao_id = ng1.id "
                + "LEFT JOIN nhanvien ng2 ON cv.nguoi_nhan_id = ng2.id "
                + "LEFT JOIN cong_viec_tien_do td ON cv.id = td.cong_viec_id "
                + "LEFT JOIN phong_ban pb ON cv.phong_ban_id = pb.id "
                + "WHERE ng2.email = ?";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setString(1, email); // Truyền email vào WHERE ng2.email = ?
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> task = new HashMap<>();
                    task.put("id", rs.getInt("id"));
                    task.put("ten_cong_viec", rs.getString("ten_cong_viec"));
                    task.put("mo_ta", rs.getString("mo_ta"));
                    task.put("nguoi_giao_id", rs.getString("nguoi_giao_ten"));
                    task.put("nguoi_nhan_id", rs.getString("nguoi_nhan_ten"));
                    task.put("vai_tro", rs.getString("vai_tro"));
                    task.put("phan_tram", rs.getString("phan_tram"));
                    task.put("phong_ban_id", rs.getString("ten_phong"));
                    task.put("muc_do_uu_tien", rs.getString("muc_do_uu_tien"));
                    task.put("trang_thai", rs.getString("trang_thai"));
                    task.put("han_hoan_thanh", rs.getDate("han_hoan_thanh"));
                    tasks.add(task);
                }
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
        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
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
        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
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
        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
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

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
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

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
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

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, congViecId);
            try (ResultSet rs = stmt.executeQuery()) {
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
        String sqlCheckQuyTrinhDangTH
                = "SELECT COUNT(*) AS cnt "
                + "FROM cong_viec_quy_trinh "
                + "WHERE cong_viec_id = ? AND trang_thai = 'Đang thực hiện'";
        String sqlInfoCv = "SELECT han_hoan_thanh, trang_thai FROM cong_viec WHERE id = ?";
        String sqlCapNhatTrangThai = "UPDATE cong_viec SET trang_thai = ? WHERE id = ?";

        try (PreparedStatement psInfo = cn.prepareStatement(sqlInfoCv); PreparedStatement ps1 = cn.prepareStatement(sqlTienDo); PreparedStatement psCheck = cn.prepareStatement(sqlCheckQuyTrinhDangTH); PreparedStatement ps2 = cn.prepareStatement(sqlCapNhatTrangThai)) {

            // 0) Lấy hạn + trạng thái hiện tại
            psInfo.setInt(1, congViecId);
            java.sql.Date han = null;
            String trangThaiHienTai = null;
            try (ResultSet rs = psInfo.executeQuery()) {
                if (!rs.next()) {
                    return;
                }
                han = rs.getDate("han_hoan_thanh");
                trangThaiHienTai = rs.getString("trang_thai");
            }

            // >>> NEW: Nếu đã hoàn thành (đúng hạn hoặc trước hạn) thì không đổi sang Trễ hạn
            if ("Đã hoàn thành".equalsIgnoreCase(trangThaiHienTai)) {
                return;
            }

            // 1) Kiểm tra quá hạn
            boolean quaHan = false;
            if (han != null) {
                java.time.LocalDate today = java.time.LocalDate.now();
                quaHan = han.toLocalDate().isBefore(today);
            }

            // 2) Nếu quá hạn -> ÉP "Trễ hạn" và dừng (KHÔNG xét % hay quy trình)
            if (quaHan) {
                if (!"Trễ hạn".equalsIgnoreCase(trangThaiHienTai)) {
                    ps2.setString(1, "Trễ hạn");
                    ps2.setInt(2, congViecId);
                    ps2.executeUpdate();
                }
                return; // sẽ chạy lại logic thường khi hạn được gia hạn
            }

            // 3) Không quá hạn -> chạy logic gốc (percent + có quy trình đang TH)
            ps1.setInt(1, congViecId);
            Integer percent = null;
            try (ResultSet rs = ps1.executeQuery()) {
                if (!rs.next()) {
                    return; // Không có bản ghi tiến độ -> thôi khỏi cập nhật
                }
                percent = rs.getInt("phan_tram");
            }

            String trangThai;
            if (percent == 0) {
                // nếu %==0 mà có bất kỳ quy trình Đang thực hiện -> Đang thực hiện
                psCheck.setInt(1, congViecId);
                int coQuyTrinhDangTH = 0;
                try (ResultSet rs2 = psCheck.executeQuery()) {
                    if (rs2.next()) {
                        coQuyTrinhDangTH = rs2.getInt("cnt");
                    }
                }
                trangThai = (coQuyTrinhDangTH > 0) ? "Đang thực hiện" : "Chưa bắt đầu";
            } else if (percent >= 100) {
                trangThai = "Đã hoàn thành";
            } else {
                trangThai = "Đang thực hiện";
            }

            // 4) Cập nhật
            if (!trangThai.equalsIgnoreCase(trangThaiHienTai)) {
                ps2.setString(1, trangThai);
                ps2.setInt(2, congViecId);
                ps2.executeUpdate();
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

    public List<Map<String, Object>> locCongViecNV(String keyword, String trangThai, String emailNhanVien) throws SQLException {
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

        if (trangThai != null && !trangThai.isEmpty()) {
            sql += " AND cv.trang_thai = ?";
            params.add(trangThai);
        }

        if (emailNhanVien != null && !emailNhanVien.trim().isEmpty()) {
            sql += " AND ng2.email = ?";
            params.add(emailNhanVien.trim());
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

    public List<Map<String, Object>> locCongViecQL(String keyword, String trangThai, String emailQL) throws SQLException {
        List<Map<String, Object>> danhSach = new ArrayList<>();

        // Lấy thông tin trưởng phòng
        String infoSql = "SELECT id, phong_ban_id FROM nhanvien WHERE email = ?";
        int idQL = -1;
        int phongBanId = -1;

        try (PreparedStatement stmt = cn.prepareStatement(infoSql)) {
            stmt.setString(1, emailQL);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    idQL = rs.getInt("id");
                    phongBanId = rs.getInt("phong_ban_id");
                } else {
                    return danhSach; // Không có trưởng phòng hợp lệ
                }
            }
        }

        // Query công việc của phòng và của chính trưởng phòng
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
                + "WHERE (cv.phong_ban_id = ? OR cv.nguoi_nhan_id = ?)";

        List<Object> params = new ArrayList<>();
        params.add(phongBanId);
        params.add(idQL);

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += " AND cv.ten_cong_viec LIKE ?";
            params.add("%" + keyword.trim() + "%");
        }

        if (trangThai != null && !trangThai.trim().isEmpty()) {
            sql += " AND cv.trang_thai = ?";
            params.add(trangThai.trim());
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
        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            stmt.executeUpdate();
        }
    }

    public Map<String, String> login(String email, String password) throws SQLException {
        String sql = "SELECT * FROM nhanvien WHERE email = ? AND mat_khau = ?";
        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setString(1, email);
            stmt.setString(2, password);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Map<String, String> userInfo = new HashMap<>();
                    userInfo.put("ho_ten", rs.getString("ho_ten"));
                    userInfo.put("email", email);
                    userInfo.put("vai_tro", rs.getString("vai_tro"));
                    // Thêm thông tin khác nếu cần
                    return userInfo;
                }
            }
        }
        return null; // Đăng nhập thất bại
    }

    public String getVaiTroByEmail(String email) throws SQLException {
        String sql = "SELECT vai_tro FROM nhanvien WHERE email = ?";
        PreparedStatement ps = cn.prepareStatement(sql);
        ps.setString(1, email);

        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            return rs.getString("vai_tro");
        }
        return null;
    }

    // Lấy danh sách tất cả phòng ban
    public List<Map<String, Object>> getAllPhongBan() throws SQLException {
        List<Map<String, Object>> danhSach = new ArrayList<>();
        String sql = "SELECT pb.id, pb.ten_phong, pb.truong_phong_id, "
                + "tp.ho_ten AS truong_phong_ten, pb.ngay_tao, "
                + "COUNT(nv.id) AS so_nhan_vien "
                + "FROM phong_ban pb "
                + "LEFT JOIN nhanvien tp ON pb.truong_phong_id = tp.id "
                + "LEFT JOIN nhanvien nv ON pb.id = nv.phong_ban_id "
                + "GROUP BY pb.id, pb.ten_phong, pb.truong_phong_id, tp.ho_ten, pb.ngay_tao "
                + "ORDER BY pb.id";

        try (PreparedStatement stmt = cn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

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
        String sql = "SELECT pb.*, tp.ho_ten AS truong_phong_ten "
                + "FROM phong_ban pb "
                + "LEFT JOIN nhanvien tp ON pb.truong_phong_id = tp.id "
                + "WHERE pb.id = ?";

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

    public boolean themPhongBan(String tenPhong, Integer truongPhongId) throws SQLException {
        String insertSQL = "INSERT INTO phong_ban (ten_phong, truong_phong_id, ngay_tao) VALUES (?, ?, NOW())";
        String updateNhanVienSQL = "UPDATE nhanvien SET chuc_vu = 'Trưởng phòng', phong_ban_id = ?, vai_tro = 'Quản lý' WHERE id = ?";
        String removeOldTruongPhongSQL = "UPDATE phong_ban SET truong_phong_id = NULL WHERE truong_phong_id = ?";

        try (
                // Khởi tạo PreparedStatement để chèn phòng ban mới
                PreparedStatement insertStmt = cn.prepareStatement(insertSQL, Statement.RETURN_GENERATED_KEYS)) {
            insertStmt.setString(1, tenPhong);

            if (truongPhongId != null && truongPhongId > 0) {
                // 1. Trước khi thêm, kiểm tra nếu người này đang là trưởng phòng ở nơi khác → reset
                try (PreparedStatement resetStmt = cn.prepareStatement(removeOldTruongPhongSQL)) {
                    resetStmt.setInt(1, truongPhongId);
                    resetStmt.executeUpdate();
                }

                insertStmt.setInt(2, truongPhongId);
            } else {
                insertStmt.setNull(2, Types.INTEGER);
            }

            int rows = insertStmt.executeUpdate();

            if (rows > 0) {
                try (ResultSet generatedKeys = insertStmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        int newPhongBanId = generatedKeys.getInt(1);

                        // 2. Cập nhật lại thông tin nhân viên trưởng phòng
                        if (truongPhongId != null && truongPhongId > 0) {
                            try (PreparedStatement updateStmt = cn.prepareStatement(updateNhanVienSQL)) {
                                updateStmt.setInt(1, newPhongBanId);
                                updateStmt.setInt(2, truongPhongId);
                                updateStmt.executeUpdate();
                            }
                        }

                        return true;
                    }
                }
            }

            return false;
        }
    }

    // Cập nhật thông tin phòng ban
    public boolean capNhatPhongBan(int id, String tenPhong, Integer truongPhongId) throws SQLException {
        // 1. Nếu có trưởng phòng mới được chỉ định
        if (truongPhongId != null && truongPhongId > 0) {
            // 1.1 Kiểm tra người đó đã là trưởng phòng nơi khác chưa (ngoài phòng hiện tại)
            String checkSQL = "SELECT id FROM phong_ban WHERE truong_phong_id = ? AND id <> ?";
            try (PreparedStatement checkStmt = cn.prepareStatement(checkSQL)) {
                checkStmt.setInt(1, truongPhongId);
                checkStmt.setInt(2, id); // Loại trừ phòng ban hiện tại
                ResultSet rs = checkStmt.executeQuery();
                while (rs.next()) {
                    int phongBanCuId = rs.getInt("id");

                    // 1.2 Gỡ vai trò trưởng phòng cũ
                    String resetSQL = "UPDATE phong_ban SET truong_phong_id = NULL WHERE id = ?";
                    try (PreparedStatement resetStmt = cn.prepareStatement(resetSQL)) {
                        resetStmt.setInt(1, phongBanCuId);
                        resetStmt.executeUpdate();
                    }
                }
            }
        }

        // 2. Cập nhật tên phòng ban + trưởng phòng mới
        String updatePhongBanSQL = "UPDATE phong_ban SET ten_phong = ?, truong_phong_id = ? WHERE id = ?";
        try (PreparedStatement stmt = cn.prepareStatement(updatePhongBanSQL)) {
            stmt.setString(1, tenPhong);
            if (truongPhongId != null && truongPhongId > 0) {
                stmt.setInt(2, truongPhongId);
            } else {
                stmt.setNull(2, Types.INTEGER);
            }
            stmt.setInt(3, id);
            stmt.executeUpdate();
        }

        // 3. Nếu có trưởng phòng → cập nhật bảng nhân viên
        if (truongPhongId != null && truongPhongId > 0) {
            String updateNhanVienSQL = "UPDATE nhanvien SET phong_ban_id = ?, chuc_vu = 'Trưởng phòng', vai_tro = 'Quản lý' WHERE id = ?";
            try (PreparedStatement updateStmt = cn.prepareStatement(updateNhanVienSQL)) {
                updateStmt.setInt(1, id); // phòng ban vừa cập nhật
                updateStmt.setInt(2, truongPhongId);
                updateStmt.executeUpdate();
            }
        }

        return true;
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
        String sql = "SELECT lsh.*, nv.ho_ten AS nguoi_thay_doi "
                + "FROM nhan_su_lich_su lsh "
                + "LEFT JOIN nhanvien nv ON lsh.nguoi_thay_doi_id = nv.id "
                + "WHERE lsh.nhan_vien_id IN (SELECT id FROM nhanvien WHERE phong_ban_id = ?) "
                + "OR lsh.loai_thay_doi LIKE '%phòng ban%' "
                + "ORDER BY lsh.thoi_gian DESC";

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
        String sql = "INSERT INTO nhan_su_lich_su (nhan_vien_id, loai_thay_doi, gia_tri_cu, gia_tri_moi, "
                + "nguoi_thay_doi_id, ghi_chu, thoi_gian) VALUES (?, ?, ?, ?, ?, ?, NOW())";

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

    // ============ PHƯƠNG THỨC CHO BÁO CÁO TỔNG HỢP ============
    // Lấy thống kê tổng quan công việc theo trạng thái
    public Map<String, Integer> getThongKeCongViecTheoTrangThai() throws SQLException {
        Map<String, Integer> thongKe = new HashMap<>();
        String sql = "SELECT trang_thai, COUNT(*) as so_luong FROM cong_viec GROUP BY trang_thai";

        try (PreparedStatement stmt = cn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                thongKe.put(rs.getString("trang_thai"), rs.getInt("so_luong"));
            }
        }
        return thongKe;
    }

    // Lấy thống kê tiến độ công việc theo phòng ban
    public List<Map<String, Object>> getThongKeTienDoTheoPhongBan() throws SQLException {
        List<Map<String, Object>> thongKe = new ArrayList<>();
        String sql = "SELECT pb.ten_phong, "
                + "COUNT(cv.id) as tong_cong_viec, "
                + "AVG(td.phan_tram) as tien_do_trung_binh, "
                + "SUM(CASE WHEN cv.trang_thai = 'Đã hoàn thành' THEN 1 ELSE 0 END) as da_hoan_thanh, "
                + "SUM(CASE WHEN cv.trang_thai = 'Đang thực hiện' THEN 1 ELSE 0 END) as dang_thuc_hien, "
                + "SUM(CASE WHEN cv.trang_thai = 'Trễ hạn' THEN 1 ELSE 0 END) as tre_han "
                + "FROM phong_ban pb "
                + "LEFT JOIN cong_viec cv ON pb.id = cv.phong_ban_id "
                + "LEFT JOIN cong_viec_tien_do td ON cv.id = td.cong_viec_id "
                + "GROUP BY pb.id, pb.ten_phong "
                + "ORDER BY pb.ten_phong";

        try (PreparedStatement stmt = cn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> phongBan = new HashMap<>();
                phongBan.put("ten_phong", rs.getString("ten_phong"));
                phongBan.put("tong_cong_viec", rs.getInt("tong_cong_viec"));
                phongBan.put("tien_do_trung_binh", rs.getDouble("tien_do_trung_binh"));
                phongBan.put("da_hoan_thanh", rs.getInt("da_hoan_thanh"));
                phongBan.put("dang_thuc_hien", rs.getInt("dang_thuc_hien"));
                phongBan.put("tre_han", rs.getInt("tre_han"));
                thongKe.add(phongBan);
            }
        }
        return thongKe;
    }

    // Lấy báo cáo tổng hợp nhân viên với KPI
    public List<Map<String, Object>> getBaoCaoTongHopNhanVien(String thang, String nam, String phongBan) throws SQLException {
        List<Map<String, Object>> baoCao = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT nv.id, nv.ho_ten, pb.ten_phong, ");
        sql.append("COUNT(cv.id) as so_task, ");
        sql.append("SUM(CASE WHEN cv.trang_thai = 'Đã hoàn thành' THEN 1 ELSE 0 END) as da_hoan_thanh, ");
        sql.append("SUM(CASE WHEN cv.trang_thai = 'Đang thực hiện' THEN 1 ELSE 0 END) as dang_thuc_hien, ");
        sql.append("SUM(CASE WHEN cv.trang_thai = 'Trễ hạn' THEN 1 ELSE 0 END) as tre_han, ");
        sql.append("AVG(kpi.diem_kpi) as diem_kpi_trung_binh ");
        sql.append("FROM nhanvien nv ");
        sql.append("LEFT JOIN phong_ban pb ON nv.phong_ban_id = pb.id ");
        sql.append("LEFT JOIN cong_viec cv ON nv.id = cv.nguoi_nhan_id ");
        sql.append("LEFT JOIN luu_kpi kpi ON nv.id = kpi.nhan_vien_id ");

        List<Object> params = new ArrayList<>();
        boolean hasWhere = false;

        if (thang != null && !thang.isEmpty() && nam != null && !nam.isEmpty()) {
            sql.append(" WHERE (kpi.thang = ? AND kpi.nam = ?) OR kpi.thang IS NULL ");
            params.add(Integer.parseInt(thang));
            params.add(Integer.parseInt(nam));
            hasWhere = true;
        }

        if (phongBan != null && !phongBan.isEmpty()) {
            if (hasWhere) {
                sql.append(" AND pb.ten_phong = ? ");
            } else {
                sql.append(" WHERE pb.ten_phong = ? ");
            }
            params.add(phongBan);
        }

        sql.append("GROUP BY nv.id, nv.ho_ten, pb.ten_phong ");
        sql.append("ORDER BY nv.ho_ten");

        try (PreparedStatement stmt = cn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> nhanVien = new HashMap<>();
                    nhanVien.put("id", rs.getInt("id"));
                    nhanVien.put("ho_ten", rs.getString("ho_ten"));
                    nhanVien.put("ten_phong", rs.getString("ten_phong"));
                    nhanVien.put("so_task", rs.getInt("so_task"));
                    nhanVien.put("da_hoan_thanh", rs.getInt("da_hoan_thanh"));
                    nhanVien.put("dang_thuc_hien", rs.getInt("dang_thuc_hien"));
                    nhanVien.put("tre_han", rs.getInt("tre_han"));
                    nhanVien.put("diem_kpi", rs.getDouble("diem_kpi_trung_binh"));
                    baoCao.add(nhanVien);
                }
            }
        }
        return baoCao;
    }

    // Lấy dữ liệu cho chart pie về trạng thái công việc
    public Map<String, Object> getDataForPieChart() throws SQLException {
        Map<String, Object> data = new HashMap<>();
        List<String> labels = new ArrayList<>();
        List<Integer> values = new ArrayList<>();

        String sql = "SELECT trang_thai, COUNT(*) as so_luong FROM cong_viec GROUP BY trang_thai";

        try (PreparedStatement stmt = cn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                labels.add(rs.getString("trang_thai"));
                values.add(rs.getInt("so_luong"));
            }
        }

        data.put("labels", labels);
        data.put("data", values);
        return data;
    }

    // Lấy dữ liệu cho chart bar về tiến độ phòng ban
    public Map<String, Object> getDataForBarChart() throws SQLException {
        Map<String, Object> data = new HashMap<>();
        List<String> labels = new ArrayList<>();
        List<Double> values = new ArrayList<>();

        String sql = "SELECT pb.ten_phong, AVG(COALESCE(td.phan_tram, 0)) as tien_do_trung_binh "
                + "FROM phong_ban pb "
                + "LEFT JOIN cong_viec cv ON pb.id = cv.phong_ban_id "
                + "LEFT JOIN cong_viec_tien_do td ON cv.id = td.cong_viec_id "
                + "GROUP BY pb.id, pb.ten_phong "
                + "ORDER BY pb.ten_phong";

        try (PreparedStatement stmt = cn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                labels.add(rs.getString("ten_phong"));
                values.add(Math.round(rs.getDouble("tien_do_trung_binh") * 100) / 100.0);
            }
        }

        data.put("labels", labels);
        data.put("data", values);
        return data;
    }

    // Lấy báo cáo KPI nhân viên theo tháng
    public List<Map<String, Object>> getBaoCaoKPINhanVien(int nhanVienId, int thang, int nam) throws SQLException {
        List<Map<String, Object>> baoCao = new ArrayList<>();
        String sql = "SELECT * FROM luu_kpi WHERE nhan_vien_id = ? AND thang = ? AND nam = ? ORDER BY ngay_tao DESC";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nhanVienId);
            stmt.setInt(2, thang);
            stmt.setInt(3, nam);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> kpi = new HashMap<>();
                    kpi.put("id", rs.getInt("id"));
                    kpi.put("chi_tieu", rs.getString("chi_tieu"));
                    kpi.put("ket_qua", rs.getString("ket_qua"));
                    kpi.put("diem_kpi", rs.getDouble("diem_kpi"));
                    kpi.put("ghi_chu", rs.getString("ghi_chu"));
                    kpi.put("ngay_tao", rs.getTimestamp("ngay_tao"));
                    baoCao.add(kpi);
                }
            }
        }
        return baoCao;
    }

    // Lấy thống kê chấm công theo tháng
    public Map<String, Object> getThongKeChamCong(int thang, int nam) throws SQLException {
        Map<String, Object> thongKe = new HashMap<>();

        // Tổng số ngày làm việc trong tháng
        String sqlTongNgay = "SELECT COUNT(DISTINCT ngay) as tong_ngay_lam_viec "
                + "FROM cham_cong WHERE MONTH(ngay) = ? AND YEAR(ngay) = ?";

        // Trung bình giờ làm việc
        String sqlTrungBinhGio = "SELECT AVG(TIME_TO_SEC(TIMEDIFF(check_out, check_in))/3600) as gio_lam_trung_binh "
                + "FROM cham_cong WHERE MONTH(ngay) = ? AND YEAR(ngay) = ? "
                + "AND check_in IS NOT NULL AND check_out IS NOT NULL";

        // Số lần đi muộn (sau 8:30)
        String sqlDiMuon = "SELECT COUNT(*) as so_lan_di_muon "
                + "FROM cham_cong WHERE MONTH(ngay) = ? AND YEAR(ngay) = ? "
                + "AND check_in > '08:30:00'";

        try (PreparedStatement stmt1 = cn.prepareStatement(sqlTongNgay); PreparedStatement stmt2 = cn.prepareStatement(sqlTrungBinhGio); PreparedStatement stmt3 = cn.prepareStatement(sqlDiMuon)) {

            stmt1.setInt(1, thang);
            stmt1.setInt(2, nam);
            stmt2.setInt(1, thang);
            stmt2.setInt(2, nam);
            stmt3.setInt(1, thang);
            stmt3.setInt(2, nam);

            try (ResultSet rs1 = stmt1.executeQuery()) {
                if (rs1.next()) {
                    thongKe.put("tong_ngay_lam_viec", rs1.getInt("tong_ngay_lam_viec"));
                }
            }

            try (ResultSet rs2 = stmt2.executeQuery()) {
                if (rs2.next()) {
                    thongKe.put("gio_lam_trung_binh", rs2.getDouble("gio_lam_trung_binh"));
                }
            }

            try (ResultSet rs3 = stmt3.executeQuery()) {
                if (rs3.next()) {
                    thongKe.put("so_lan_di_muon", rs3.getInt("so_lan_di_muon"));
                }
            }
        }

        return thongKe;
    }

    // ============ PHƯƠNG THỨC CHO CHẤM CÔNG & LƯƠNG ============
    // Lấy danh sách chấm công với thông tin chi tiết
    public List<Map<String, Object>> getDanhSachChamCong(String thang, String nam, String phongBan, String keyword) throws SQLException {
        List<Map<String, Object>> danhSach = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT cc.id, cc.nhan_vien_id, cc.ngay, cc.check_in, cc.check_out, ");
        sql.append("nv.ho_ten, nv.avatar_url, nv.ngay_vao_lam, nv.luong_co_ban, ");
        sql.append("pb.ten_phong, ");
        sql.append("CASE ");
        sql.append("  WHEN cc.check_in IS NULL THEN 0 ");
        sql.append("  WHEN cc.check_out IS NULL THEN 0 ");
        sql.append("  ELSE TIMESTAMPDIFF(HOUR, cc.check_in, cc.check_out) ");
        sql.append("END as so_gio_lam, ");
        sql.append("CASE ");
        sql.append("  WHEN cc.check_in IS NULL THEN 'Vắng' ");
        sql.append("  WHEN cc.check_in > '08:30:00' THEN 'Đi trễ' ");
        sql.append("  WHEN TIMESTAMPDIFF(HOUR, cc.check_in, cc.check_out) >= 8 THEN 'Đủ công' ");
        sql.append("  ELSE 'Thiếu giờ' ");
        sql.append("END as trang_thai ");
        sql.append("FROM cham_cong cc ");
        sql.append("LEFT JOIN nhanvien nv ON cc.nhan_vien_id = nv.id ");
        sql.append("LEFT JOIN phong_ban pb ON nv.phong_ban_id = pb.id ");
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (thang != null && !thang.isEmpty() && nam != null && !nam.isEmpty()) {
            sql.append("AND MONTH(cc.ngay) = ? AND YEAR(cc.ngay) = ? ");
            params.add(Integer.parseInt(thang));
            params.add(Integer.parseInt(nam));
        }

        if (phongBan != null && !phongBan.isEmpty()) {
            sql.append("AND pb.ten_phong = ? ");
            params.add(phongBan);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (nv.ho_ten LIKE ? OR nv.email LIKE ?) ");
            params.add("%" + keyword + "%");
            params.add("%" + keyword + "%");
        }

        sql.append("ORDER BY cc.ngay DESC, nv.ho_ten ASC");

        try (PreparedStatement stmt = cn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> record = new HashMap<>();
                    record.put("id", rs.getInt("id"));
                    record.put("nhan_vien_id", rs.getInt("nhan_vien_id"));
                    record.put("ho_ten", rs.getString("ho_ten"));
                    record.put("avatar_url", rs.getString("avatar_url"));
                    record.put("ten_phong", rs.getString("ten_phong"));
                    record.put("ngay_vao_lam", rs.getDate("ngay_vao_lam"));
                    record.put("ngay", rs.getDate("ngay"));
                    record.put("check_in", rs.getTime("check_in"));
                    record.put("check_out", rs.getTime("check_out"));
                    record.put("so_gio_lam", rs.getDouble("so_gio_lam"));
                    record.put("trang_thai", rs.getString("trang_thai"));
                    record.put("luong_co_ban", rs.getDouble("luong_co_ban"));

                    // Tính lương ngày
                    double luongCoBan = rs.getDouble("luong_co_ban");
                    double soGioLam = rs.getDouble("so_gio_lam");
                    double luongNgay = (luongCoBan / 22) * (soGioLam / 8); // 22 ngày làm việc/tháng, 8 giờ/ngày
                    record.put("luong_ngay", luongNgay);

                    danhSach.add(record);
                }
            }
        }
        return danhSach;
    }

    // Lấy lịch sử chấm công của nhân viên
    public List<Map<String, Object>> getLichSuChamCong(int nhanVienId, int thang, int nam) throws SQLException {
        List<Map<String, Object>> lichSu = new ArrayList<>();
        String sql = "SELECT ngay, check_in, check_out, "
                + "CASE "
                + "  WHEN check_in IS NULL THEN 'Vắng' "
                + "  WHEN check_in > '08:30:00' THEN 'Đi trễ' "
                + "  WHEN TIMESTAMPDIFF(HOUR, check_in, check_out) >= 8 THEN 'Đủ công' "
                + "  ELSE 'Thiếu giờ' "
                + "END as trang_thai "
                + "FROM cham_cong "
                + "WHERE nhan_vien_id = ? AND MONTH(ngay) = ? AND YEAR(ngay) = ? "
                + "ORDER BY ngay DESC";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nhanVienId);
            stmt.setInt(2, thang);
            stmt.setInt(3, nam);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> record = new HashMap<>();
                    record.put("ngay", rs.getDate("ngay"));
                    record.put("check_in", rs.getTime("check_in"));
                    record.put("check_out", rs.getTime("check_out"));
                    record.put("trang_thai", rs.getString("trang_thai"));
                    lichSu.add(record);
                }
            }
        }
        return lichSu;
    }

    // Lấy thông tin lương của nhân viên theo tháng
    public Map<String, Object> getThongTinLuong(int nhanVienId, int thang, int nam) throws SQLException {
        Map<String, Object> luongInfo = new HashMap<>();
        String sql = "SELECT l.*, nv.ho_ten, nv.luong_co_ban "
                + "FROM luong l "
                + "LEFT JOIN nhanvien nv ON l.nhan_vien_id = nv.id "
                + "WHERE l.nhan_vien_id = ? AND l.thang = ? AND l.nam = ?";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nhanVienId);
            stmt.setInt(2, thang);
            stmt.setInt(3, nam);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    luongInfo.put("id", rs.getInt("id"));
                    luongInfo.put("ho_ten", rs.getString("ho_ten"));
                    luongInfo.put("luong_co_ban", rs.getDouble("luong_co_ban"));
                    luongInfo.put("phu_cap", rs.getDouble("phu_cap"));
                    luongInfo.put("thuong", rs.getDouble("thuong"));
                    luongInfo.put("phat", rs.getDouble("phat"));
                    luongInfo.put("bao_hiem", rs.getDouble("bao_hiem"));
                    luongInfo.put("thue", rs.getDouble("thue"));
                    luongInfo.put("luong_thuc_te", rs.getDouble("luong_thuc_te"));
                    luongInfo.put("trang_thai", rs.getString("trang_thai"));
                    luongInfo.put("ngay_tra_luong", rs.getDate("ngay_tra_luong"));
                    luongInfo.put("ghi_chu", rs.getString("ghi_chu"));
                }
            }
        }
        return luongInfo;
    }

    // Thêm/cập nhật chấm công
    public boolean capNhatChamCong(int nhanVienId, String ngay, String checkIn, String checkOut) throws SQLException {
        String checkSql = "SELECT COUNT(*) FROM cham_cong WHERE nhan_vien_id = ? AND ngay = ?";
        boolean exists = false;

        try (PreparedStatement checkStmt = cn.prepareStatement(checkSql)) {
            checkStmt.setInt(1, nhanVienId);
            checkStmt.setDate(2, java.sql.Date.valueOf(ngay));

            try (ResultSet rs = checkStmt.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    exists = true;
                }
            }
        }

        String sql;
        if (exists) {
            sql = "UPDATE cham_cong SET check_in = ?, check_out = ? WHERE nhan_vien_id = ? AND ngay = ?";
        } else {
            sql = "INSERT INTO cham_cong (check_in, check_out, nhan_vien_id, ngay) VALUES (?, ?, ?, ?)";
        }

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            if (checkIn != null && !checkIn.isEmpty()) {
                stmt.setTime(1, java.sql.Time.valueOf(checkIn + ":00"));
            } else {
                stmt.setNull(1, Types.TIME);
            }

            if (checkOut != null && !checkOut.isEmpty()) {
                stmt.setTime(2, java.sql.Time.valueOf(checkOut + ":00"));
            } else {
                stmt.setNull(2, Types.TIME);
            }

            stmt.setInt(3, nhanVienId);
            stmt.setDate(4, java.sql.Date.valueOf(ngay));

            return stmt.executeUpdate() > 0;
        }
    }

    // Tính toán và cập nhật lương tháng
    public boolean tinhToanLuongThang(int nhanVienId, int thang, int nam) throws SQLException {
        // Lấy thông tin nhân viên
        String empSql = "SELECT luong_co_ban FROM nhanvien WHERE id = ?";
        double luongCoBan = 0;

        try (PreparedStatement empStmt = cn.prepareStatement(empSql)) {
            empStmt.setInt(1, nhanVienId);
            try (ResultSet empRs = empStmt.executeQuery()) {
                if (empRs.next()) {
                    luongCoBan = empRs.getDouble("luong_co_ban");
                }
            }
        }

        // Tính số ngày làm việc thực tế
        String attSql = "SELECT COUNT(*) as ngay_lam, "
                + "SUM(CASE WHEN check_in > '08:30:00' THEN 1 ELSE 0 END) as ngay_di_tre "
                + "FROM cham_cong "
                + "WHERE nhan_vien_id = ? AND MONTH(ngay) = ? AND YEAR(ngay) = ? "
                + "AND check_in IS NOT NULL";

        int ngayLam = 0;
        int ngayDiTre = 0;

        try (PreparedStatement attStmt = cn.prepareStatement(attSql)) {
            attStmt.setInt(1, nhanVienId);
            attStmt.setInt(2, thang);
            attStmt.setInt(3, nam);

            try (ResultSet attRs = attStmt.executeQuery()) {
                if (attRs.next()) {
                    ngayLam = attRs.getInt("ngay_lam");
                    ngayDiTre = attRs.getInt("ngay_di_tre");
                }
            }
        }

        // Tính toán lương
        double phuCap = luongCoBan * 0.1; // 10% lương cơ bản
        double phat = ngayDiTre * 50000; // 50k mỗi lần đi trễ
        double thuong = 0; // Có thể tính từ KPI
        double baoHiem = luongCoBan * 0.105; // 10.5% bảo hiểm
        double thue = luongCoBan * 0.05; // 5% thuế

        double luongThucTe = luongCoBan + phuCap + thuong - phat - baoHiem - thue;

        // Kiểm tra xem đã có bản ghi lương chưa
        String checkLuongSql = "SELECT COUNT(*) FROM luong WHERE nhan_vien_id = ? AND thang = ? AND nam = ?";
        boolean luongExists = false;

        try (PreparedStatement checkStmt = cn.prepareStatement(checkLuongSql)) {
            checkStmt.setInt(1, nhanVienId);
            checkStmt.setInt(2, thang);
            checkStmt.setInt(3, nam);

            try (ResultSet rs = checkStmt.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    luongExists = true;
                }
            }
        }

        String luongSql;
        if (luongExists) {
            luongSql = "UPDATE luong SET luong_co_ban = ?, phu_cap = ?, thuong = ?, phat = ?, "
                    + "bao_hiem = ?, thue = ?, luong_thuc_te = ?, "
                    + "ghi_chu = ? WHERE nhan_vien_id = ? AND thang = ? AND nam = ?";
        } else {
            luongSql = "INSERT INTO luong (nhan_vien_id, thang, nam, luong_co_ban, phu_cap, thuong, phat, "
                    + "bao_hiem, thue, luong_thuc_te, ghi_chu, trang_thai) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'Chưa trả')";
        }

        try (PreparedStatement luongStmt = cn.prepareStatement(luongSql)) {
            if (luongExists) {
                luongStmt.setDouble(1, luongCoBan);
                luongStmt.setDouble(2, phuCap);
                luongStmt.setDouble(3, thuong);
                luongStmt.setDouble(4, phat);
                luongStmt.setDouble(5, baoHiem);
                luongStmt.setDouble(6, thue);
                luongStmt.setDouble(7, luongThucTe);
                luongStmt.setString(8, "Làm " + ngayLam + " ngày, đi trễ " + ngayDiTre + " lần");
                luongStmt.setInt(9, nhanVienId);
                luongStmt.setInt(10, thang);
                luongStmt.setInt(11, nam);
            } else {
                luongStmt.setInt(1, nhanVienId);
                luongStmt.setInt(2, thang);
                luongStmt.setInt(3, nam);
                luongStmt.setDouble(4, luongCoBan);
                luongStmt.setDouble(5, phuCap);
                luongStmt.setDouble(6, thuong);
                luongStmt.setDouble(7, phat);
                luongStmt.setDouble(8, baoHiem);
                luongStmt.setDouble(9, thue);
                luongStmt.setDouble(10, luongThucTe);
                luongStmt.setString(11, "Làm " + ngayLam + " ngày, đi trễ " + ngayDiTre + " lần");
                luongStmt.setString(12, "Chưa trả");
            }

            return luongStmt.executeUpdate() > 0;
        }
    }

    // Lấy thống kê chấm công tổng quan
    public Map<String, Object> getThongKeChamCongTongQuan(int thang, int nam) throws SQLException {
        Map<String, Object> thongKe = new HashMap<>();

        // Tổng số ngày làm việc
        String sql1 = "SELECT COUNT(DISTINCT ngay) as tong_ngay FROM cham_cong "
                + "WHERE MONTH(ngay) = ? AND YEAR(ngay) = ?";

        // Số lượt đi trễ
        String sql2 = "SELECT COUNT(*) as di_tre FROM cham_cong "
                + "WHERE MONTH(ngay) = ? AND YEAR(ngay) = ? AND check_in > '08:30:00'";

        // Số lượt vắng mặt
        String sql3 = "SELECT COUNT(*) as vang_mat FROM cham_cong "
                + "WHERE MONTH(ngay) = ? AND YEAR(ngay) = ? AND check_in IS NULL";

        // Trung bình giờ làm việc
        String sql4 = "SELECT AVG(TIMESTAMPDIFF(HOUR, check_in, check_out)) as gio_tb FROM cham_cong "
                + "WHERE MONTH(ngay) = ? AND YEAR(ngay) = ? AND check_in IS NOT NULL AND check_out IS NOT NULL";

        try (PreparedStatement stmt1 = cn.prepareStatement(sql1); PreparedStatement stmt2 = cn.prepareStatement(sql2); PreparedStatement stmt3 = cn.prepareStatement(sql3); PreparedStatement stmt4 = cn.prepareStatement(sql4)) {

            stmt1.setInt(1, thang);
            stmt1.setInt(2, nam);
            stmt2.setInt(1, thang);
            stmt2.setInt(2, nam);
            stmt3.setInt(1, thang);
            stmt3.setInt(2, nam);
            stmt4.setInt(1, thang);
            stmt4.setInt(2, nam);

            try (ResultSet rs1 = stmt1.executeQuery()) {
                if (rs1.next()) {
                    thongKe.put("tong_ngay", rs1.getInt("tong_ngay"));
                }
            }

            try (ResultSet rs2 = stmt2.executeQuery()) {
                if (rs2.next()) {
                    thongKe.put("di_tre", rs2.getInt("di_tre"));
                }
            }

            try (ResultSet rs3 = stmt3.executeQuery()) {
                if (rs3.next()) {
                    thongKe.put("vang_mat", rs3.getInt("vang_mat"));
                }
            }

            try (ResultSet rs4 = stmt4.executeQuery()) {
                if (rs4.next()) {
                    thongKe.put("gio_trung_binh", rs4.getDouble("gio_tb"));
                }
            }
        }

        return thongKe;
    }

    // Phương thức lấy danh sách lương theo filter
    public List<Map<String, Object>> getDanhSachLuong(String thang, String nam, String phongBan, String keyword) throws SQLException {
        List<Map<String, Object>> danhSach = new ArrayList<>();

        Connection con = cn;

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT l.id, l.nhan_vien_id, nv.ho_ten, nv.email, pb.ten_phong, ");
        sql.append("l.luong_co_ban, l.phu_cap, l.thuong, l.tru_khoan, l.luong_thuc_te, ");
        sql.append("l.thang, l.nam, l.ngay_tra, l.trang_thai, l.ghi_chu ");
        sql.append("FROM luong l ");
        sql.append("JOIN nhanvien nv ON l.nhan_vien_id = nv.id ");
        sql.append("JOIN phong_ban pb ON nv.phong_ban_id = pb.id ");
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (thang != null && !thang.isEmpty()) {
            sql.append("AND l.thang = ? ");
            params.add(Integer.parseInt(thang));
        }

        if (nam != null && !nam.isEmpty()) {
            sql.append("AND l.nam = ? ");
            params.add(Integer.parseInt(nam));
        }

        if (phongBan != null && !phongBan.isEmpty()) {
            sql.append("AND pb.id = ? ");
            params.add(Integer.parseInt(phongBan));
        }

        if (keyword != null && !keyword.isEmpty()) {
            sql.append("AND (nv.ho_ten LIKE ? OR nv.email LIKE ?) ");
            params.add("%" + keyword + "%");
            params.add("%" + keyword + "%");
        }

        sql.append("ORDER BY l.nam DESC, l.thang DESC, nv.ho_ten ASC");

        try (PreparedStatement stmt = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("id", rs.getInt("id"));
                    item.put("nhan_vien_id", rs.getInt("nhan_vien_id"));
                    item.put("ho_ten", rs.getString("ho_ten"));
                    item.put("email", rs.getString("email"));
                    item.put("ten_phong", rs.getString("ten_phong"));
                    item.put("luong_co_ban", rs.getDouble("luong_co_ban"));
                    item.put("phu_cap", rs.getDouble("phu_cap"));
                    item.put("thuong", rs.getDouble("thuong"));
                    item.put("tru_khoan", rs.getDouble("tru_khoan"));
                    item.put("luong_thuc_te", rs.getDouble("luong_thuc_te"));
                    item.put("thang", rs.getInt("thang"));
                    item.put("nam", rs.getInt("nam"));
                    item.put("ngay_tra", rs.getDate("ngay_tra"));
                    item.put("trang_thai", rs.getString("trang_thai"));
                    item.put("ghi_chu", rs.getString("ghi_chu"));
                    danhSach.add(item);
                }
            }
        }

        return danhSach;
    }

    // ============ PHƯƠNG THỨC CHO USER ATTENDANCE ============
    // Lấy thông tin nhân viên theo email
    public Map<String, Object> getNhanVienByEmail(String email) throws SQLException {
        Map<String, Object> nhanVien = new HashMap<>();
        String sql = "SELECT nv.*, pb.ten_phong "
                + "FROM nhanvien nv "
                + "LEFT JOIN phong_ban pb ON nv.phong_ban_id = pb.id "
                + "WHERE nv.email = ?";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setString(1, email);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    nhanVien.put("id", rs.getInt("id"));
                    nhanVien.put("ho_ten", rs.getString("ho_ten"));
                    nhanVien.put("email", rs.getString("email"));
                    nhanVien.put("chuc_vu", rs.getString("chuc_vu"));
                    nhanVien.put("phong_ban_id", rs.getInt("phong_ban_id"));
                    nhanVien.put("ten_phong", rs.getString("ten_phong"));
                    nhanVien.put("luong_co_ban", rs.getDouble("luong_co_ban"));
                    nhanVien.put("avatar_url", rs.getString("avatar_url"));
                    nhanVien.put("vai_tro", rs.getString("vai_tro"));
                    nhanVien.put("ngay_vao_lam", rs.getDate("ngay_vao_lam"));
                }
            }
        }
        return nhanVien;
    }

    // Lấy lịch sử chấm công của user
    public List<Map<String, Object>> getLichSuChamCongUser(int nhanVienId, int thang, int nam) throws SQLException {
        List<Map<String, Object>> lichSu = new ArrayList<>();
        String sql = "SELECT ngay, check_in, check_out, "
                + "CASE "
                + "  WHEN check_in IS NULL THEN 0 "
                + "  WHEN check_out IS NULL THEN 0 "
                + "  ELSE TIMESTAMPDIFF(HOUR, check_in, check_out) "
                + "END as so_gio_lam, "
                + "CASE "
                + "  WHEN check_in IS NULL THEN 'Vắng mặt' "
                + "  WHEN check_in > '08:30:00' THEN 'Đi trễ' "
                + "  WHEN TIMESTAMPDIFF(HOUR, check_in, check_out) >= 8 THEN 'Đủ công' "
                + "  ELSE 'Thiếu giờ' "
                + "END as trang_thai "
                + "FROM cham_cong "
                + "WHERE nhan_vien_id = ? AND MONTH(ngay) = ? AND YEAR(ngay) = ? "
                + "ORDER BY ngay DESC";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nhanVienId);
            stmt.setInt(2, thang);
            stmt.setInt(3, nam);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> record = new HashMap<>();
                    record.put("ngay", rs.getDate("ngay"));
                    record.put("check_in", rs.getTime("check_in"));
                    record.put("check_out", rs.getTime("check_out"));
                    record.put("so_gio_lam", rs.getDouble("so_gio_lam"));
                    record.put("trang_thai", rs.getString("trang_thai"));
                    lichSu.add(record);
                }
            }
        }
        return lichSu;
    }

    // Lấy thống kê chấm công cá nhân
    public Map<String, Object> getThongKeChamCongCaNhan(int nhanVienId, int thang, int nam) throws SQLException {
        Map<String, Object> thongKe = new HashMap<>();

        // Tổng số ngày đã chấm công
        String sql1 = "SELECT COUNT(*) as tong_ngay_cham FROM cham_cong "
                + "WHERE nhan_vien_id = ? AND MONTH(ngay) = ? AND YEAR(ngay) = ? "
                + "AND check_in IS NOT NULL";

        // Số ngày đi trễ
        String sql2 = "SELECT COUNT(*) as ngay_di_tre FROM cham_cong "
                + "WHERE nhan_vien_id = ? AND MONTH(ngay) = ? AND YEAR(ngay) = ? "
                + "AND check_in > '08:30:00'";

        // Tổng giờ làm việc
        String sql3 = "SELECT SUM(TIMESTAMPDIFF(HOUR, check_in, check_out)) as tong_gio_lam FROM cham_cong "
                + "WHERE nhan_vien_id = ? AND MONTH(ngay) = ? AND YEAR(ngay) = ? "
                + "AND check_in IS NOT NULL AND check_out IS NOT NULL";

        // Số ngày đủ công (>= 8 giờ)
        String sql4 = "SELECT COUNT(*) as ngay_du_cong FROM cham_cong "
                + "WHERE nhan_vien_id = ? AND MONTH(ngay) = ? AND YEAR(ngay) = ? "
                + "AND TIMESTAMPDIFF(HOUR, check_in, check_out) >= 8";

        try (PreparedStatement stmt1 = cn.prepareStatement(sql1); PreparedStatement stmt2 = cn.prepareStatement(sql2); PreparedStatement stmt3 = cn.prepareStatement(sql3); PreparedStatement stmt4 = cn.prepareStatement(sql4)) {

            // Thực hiện các truy vấn
            stmt1.setInt(1, nhanVienId);
            stmt1.setInt(2, thang);
            stmt1.setInt(3, nam);
            stmt2.setInt(1, nhanVienId);
            stmt2.setInt(2, thang);
            stmt2.setInt(3, nam);
            stmt3.setInt(1, nhanVienId);
            stmt3.setInt(2, thang);
            stmt3.setInt(3, nam);
            stmt4.setInt(1, nhanVienId);
            stmt4.setInt(2, thang);
            stmt4.setInt(3, nam);

            try (ResultSet rs1 = stmt1.executeQuery()) {
                if (rs1.next()) {
                    thongKe.put("tong_ngay_cham", rs1.getInt("tong_ngay_cham"));
                }
            }

            try (ResultSet rs2 = stmt2.executeQuery()) {
                if (rs2.next()) {
                    thongKe.put("ngay_di_tre", rs2.getInt("ngay_di_tre"));
                }
            }

            try (ResultSet rs3 = stmt3.executeQuery()) {
                if (rs3.next()) {
                    thongKe.put("tong_gio_lam", rs3.getDouble("tong_gio_lam"));
                }
            }

            try (ResultSet rs4 = stmt4.executeQuery()) {
                if (rs4.next()) {
                    thongKe.put("ngay_du_cong", rs4.getInt("ngay_du_cong"));
                }
            }
        }

        return thongKe;
    }

    // Lấy trạng thái chấm công hôm nay
    public Map<String, Object> getChamCongHomNay(int nhanVienId) throws SQLException {
        Map<String, Object> chamCong = new HashMap<>();
        String sql = "SELECT check_in, check_out FROM cham_cong "
                + "WHERE nhan_vien_id = ? AND ngay = CURDATE()";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nhanVienId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    chamCong.put("check_in", rs.getTime("check_in"));
                    chamCong.put("check_out", rs.getTime("check_out"));
                    chamCong.put("da_check_in", rs.getTime("check_in") != null);
                    chamCong.put("da_check_out", rs.getTime("check_out") != null);
                } else {
                    chamCong.put("check_in", null);
                    chamCong.put("check_out", null);
                    chamCong.put("da_check_in", false);
                    chamCong.put("da_check_out", false);
                }
            }
        }
        return chamCong;
    }

    // Check-in
    public boolean checkIn(int nhanVienId) throws SQLException {
        // Kiểm tra đã check-in hôm nay chưa
        String checkSql = "SELECT COUNT(*) FROM cham_cong WHERE nhan_vien_id = ? AND ngay = CURDATE()";
        boolean exists = false;

        try (PreparedStatement checkStmt = cn.prepareStatement(checkSql)) {
            checkStmt.setInt(1, nhanVienId);
            try (ResultSet rs = checkStmt.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    exists = true;
                }
            }
        }

        String sql;
        if (exists) {
            // Cập nhật check-in nếu đã có record
            sql = "UPDATE cham_cong SET check_in = CURRENT_TIME WHERE nhan_vien_id = ? AND ngay = CURDATE()";
        } else {
            // Tạo record mới
            sql = "INSERT INTO cham_cong (nhan_vien_id, ngay, check_in) VALUES (?, CURDATE(), CURRENT_TIME)";
        }

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nhanVienId);
            return stmt.executeUpdate() > 0;
        }
    }

    // Check-out
    public boolean checkOut(int nhanVienId) throws SQLException {
        String sql = "UPDATE cham_cong SET check_out = CURRENT_TIME "
                + "WHERE nhan_vien_id = ? AND ngay = CURDATE() AND check_in IS NOT NULL";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nhanVienId);
            return stmt.executeUpdate() > 0;
        }
    }

    // ============ PHƯƠNG THỨC CHO USER SALARY & KPI ============
    // Lấy thông tin lương của user theo tháng
    public Map<String, Object> getThongTinLuongUser(int nhanVienId, int thang, int nam) throws SQLException {
        Map<String, Object> luongInfo = new HashMap<>();
        String sql = "SELECT * FROM luong WHERE nhan_vien_id = ? AND thang = ? AND nam = ?";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nhanVienId);
            stmt.setInt(2, thang);
            stmt.setInt(3, nam);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    luongInfo.put("id", rs.getInt("id"));
                    luongInfo.put("luong_co_ban", rs.getDouble("luong_co_ban"));
                    luongInfo.put("phu_cap", rs.getDouble("phu_cap"));
                    luongInfo.put("thuong", rs.getDouble("thuong"));
                    luongInfo.put("phat", rs.getDouble("phat"));
                    luongInfo.put("bao_hiem", rs.getDouble("bao_hiem"));
                    luongInfo.put("thue", rs.getDouble("thue"));
                    luongInfo.put("luong_thuc_te", rs.getDouble("luong_thuc_te"));
                    luongInfo.put("trang_thai", rs.getString("trang_thai"));
                    luongInfo.put("ngay_tra_luong", rs.getDate("ngay_tra_luong"));
                    luongInfo.put("ghi_chu", rs.getString("ghi_chu"));
                    luongInfo.put("thang", rs.getInt("thang"));
                    luongInfo.put("nam", rs.getInt("nam"));
                }
            }
        }
        return luongInfo;
    }

    // Lấy lịch sử lương của user
    public List<Map<String, Object>> getLichSuLuongUser(int nhanVienId) throws SQLException {
        List<Map<String, Object>> lichSu = new ArrayList<>();
        String sql = "SELECT * FROM luong WHERE nhan_vien_id = ? ORDER BY nam DESC, thang DESC LIMIT 12";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nhanVienId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> record = new HashMap<>();
                    record.put("id", rs.getInt("id"));
                    record.put("thang", rs.getInt("thang"));
                    record.put("nam", rs.getInt("nam"));
                    record.put("luong_co_ban", rs.getDouble("luong_co_ban"));
                    record.put("phu_cap", rs.getDouble("phu_cap"));
                    record.put("thuong", rs.getDouble("thuong"));
                    record.put("phat", rs.getDouble("phat"));
                    record.put("bao_hiem", rs.getDouble("bao_hiem"));
                    record.put("thue", rs.getDouble("thue"));
                    record.put("luong_thuc_te", rs.getDouble("luong_thuc_te"));
                    record.put("trang_thai", rs.getString("trang_thai"));
                    record.put("ngay_tra_luong", rs.getDate("ngay_tra_luong"));
                    record.put("ghi_chu", rs.getString("ghi_chu"));
                    lichSu.add(record);
                }
            }
        }
        return lichSu;
    }

    // Lấy thông tin KPI của user theo tháng
    public List<Map<String, Object>> getKPIUser(int nhanVienId, int thang, int nam) throws SQLException {
        List<Map<String, Object>> kpiList = new ArrayList<>();
        String sql = "SELECT * FROM luu_kpi WHERE nhan_vien_id = ? AND thang = ? AND nam = ? ORDER BY ngay_tao DESC";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nhanVienId);
            stmt.setInt(2, thang);
            stmt.setInt(3, nam);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> kpi = new HashMap<>();
                    kpi.put("id", rs.getInt("id"));
                    kpi.put("chi_tieu", rs.getString("chi_tieu"));
                    kpi.put("ket_qua", rs.getString("ket_qua"));
                    kpi.put("diem_kpi", rs.getDouble("diem_kpi"));
                    kpi.put("ghi_chu", rs.getString("ghi_chu"));
                    kpi.put("ngay_tao", rs.getTimestamp("ngay_tao"));
                    kpiList.add(kpi);
                }
            }
        }
        return kpiList;
    }

    // Lấy tổng hợp KPI của user
    public Map<String, Object> getTongHopKPIUser(int nhanVienId, int thang, int nam) throws SQLException {
        Map<String, Object> tongHop = new HashMap<>();

        // Điểm KPI trung bình
        String sql1 = "SELECT AVG(diem_kpi) as diem_tb, COUNT(*) as so_chi_tieu FROM luu_kpi "
                + "WHERE nhan_vien_id = ? AND thang = ? AND nam = ?";

        // Số công việc hoàn thành trong tháng
        String sql2 = "SELECT COUNT(*) as cong_viec_hoan_thanh FROM cong_viec "
                + "WHERE nguoi_nhan_id = ? AND trang_thai = 'Đã hoàn thành' "
                + "AND MONTH(ngay_tao) = ? AND YEAR(ngay_tao) = ?";

        try (PreparedStatement stmt1 = cn.prepareStatement(sql1); PreparedStatement stmt2 = cn.prepareStatement(sql2)) {

            stmt1.setInt(1, nhanVienId);
            stmt1.setInt(2, thang);
            stmt1.setInt(3, nam);
            stmt2.setInt(1, nhanVienId);
            stmt2.setInt(2, thang);
            stmt2.setInt(3, nam);

            try (ResultSet rs1 = stmt1.executeQuery()) {
                if (rs1.next()) {
                    tongHop.put("diem_kpi_trung_binh", rs1.getDouble("diem_tb"));
                    tongHop.put("so_chi_tieu", rs1.getInt("so_chi_tieu"));
                }
            }

            try (ResultSet rs2 = stmt2.executeQuery()) {
                if (rs2.next()) {
                    tongHop.put("cong_viec_hoan_thanh", rs2.getInt("cong_viec_hoan_thanh"));
                }
            }
        }

        return tongHop;
    }

    // Lấy danh sách lương & KPI kết hợp cho user
    public List<Map<String, Object>> getLuongKPIUser(int nhanVienId) throws SQLException {
        List<Map<String, Object>> danhSach = new ArrayList<>();
        String sql = "SELECT l.thang, l.nam, l.luong_co_ban, l.phu_cap, l.thuong, l.phat, "
                + "l.bao_hiem, l.thue, l.luong_thuc_te, l.trang_thai, "
                + "AVG(kpi.diem_kpi) as diem_kpi_tb, "
                + "SUM(CASE WHEN cc.check_in IS NOT NULL AND cc.check_out IS NOT NULL "
                + "    THEN TIMESTAMPDIFF(HOUR, cc.check_in, cc.check_out) ELSE 0 END) as tong_gio_lam "
                + "FROM luong l "
                + "LEFT JOIN luu_kpi kpi ON l.nhan_vien_id = kpi.nhan_vien_id AND l.thang = kpi.thang AND l.nam = kpi.nam "
                + "LEFT JOIN cham_cong cc ON l.nhan_vien_id = cc.nhan_vien_id AND MONTH(cc.ngay) = l.thang AND YEAR(cc.ngay) = l.nam "
                + "WHERE l.nhan_vien_id = ? "
                + "GROUP BY l.thang, l.nam, l.luong_co_ban, l.phu_cap, l.thuong, l.phat, l.bao_hiem, l.thue, l.luong_thuc_te, l.trang_thai "
                + "ORDER BY l.nam DESC, l.thang DESC LIMIT 12";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nhanVienId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> record = new HashMap<>();
                    record.put("thang", rs.getInt("thang"));
                    record.put("nam", rs.getInt("nam"));
                    record.put("luong_co_ban", rs.getDouble("luong_co_ban"));
                    record.put("phu_cap", rs.getDouble("phu_cap"));
                    record.put("thuong", rs.getDouble("thuong"));
                    record.put("phat", rs.getDouble("phat"));
                    record.put("bao_hiem", rs.getDouble("bao_hiem"));
                    record.put("thue", rs.getDouble("thue"));
                    record.put("luong_thuc_te", rs.getDouble("luong_thuc_te"));
                    record.put("trang_thai", rs.getString("trang_thai"));
                    record.put("diem_kpi", rs.getDouble("diem_kpi_tb"));
                    record.put("tong_gio_lam", rs.getDouble("tong_gio_lam"));
                    danhSach.add(record);
                }
            }
        }
        return danhSach;
    }
    
    public boolean kiemTraMatKhau(String email, String oldPass) throws SQLException {
        if (email == null || email.trim().isEmpty()) return false;

        String sql = "SELECT mat_khau FROM nhanvien WHERE email = ?";
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return false;
                String mkDb = rs.getString("mat_khau");
                // BCrypt: return BCrypt.checkpw(oldPass, mkDb);
                return mkDb != null && mkDb.equals(oldPass);
            }
        }
    }

    public int capNhatMatKhau(String email, String newPass) throws SQLException {
        if (email == null || email.trim().isEmpty()) return 0;

        // BCrypt: String hashed = BCrypt.hashpw(newPass, BCrypt.gensalt());
        String hashed = newPass;

        String sql = "UPDATE nhanvien SET mat_khau = ? WHERE email = ?";
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, hashed);
            ps.setString(2, email);
            return ps.executeUpdate();
        }
    }

    public boolean doiMatKhau(String email, String oldPass, String newPass) throws SQLException {
        if (email == null || email.trim().isEmpty()) return false;

        boolean oldAutoCommit = cn.getAutoCommit();
        try {
            cn.setAutoCommit(false);

            if (!kiemTraMatKhau(email, oldPass)) {
                cn.rollback();
                return false;
            }

            int rows = capNhatMatKhau(email, newPass);
            if (rows <= 0) {
                cn.rollback();
                return false;
            }

            cn.commit();
            return true;
        } catch (SQLException ex) {
            try { cn.rollback(); } catch (SQLException ignore) {}
            throw ex;
        } finally {
            try { cn.setAutoCommit(oldAutoCommit); } catch (SQLException ignore) {}
        }
    }

    public void close() throws SQLException {
        if (cn != null && !cn.isClosed()) {
            cn.close();
        }
    }

}
