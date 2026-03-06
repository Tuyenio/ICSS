package controller;

import jakarta.servlet.http.HttpSession;
import java.sql.*;
import java.sql.Date;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellType;
import static org.apache.poi.ss.usermodel.CellType.BLANK;
import static org.apache.poi.ss.usermodel.CellType.BOOLEAN;
import static org.apache.poi.ss.usermodel.CellType.NUMERIC;
import static org.apache.poi.ss.usermodel.CellType.STRING;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Row;

public class KNCSDL {

    Connection cn;
    String path = "jdbc:mysql://localhost:3306/qlns";

    public KNCSDL() throws ClassNotFoundException, SQLException {
        Class.forName("com.mysql.cj.jdbc.Driver");
        //this.cn = DriverManager.getConnection(path, "root", "");
        this.cn = DriverManager.getConnection(path, "icssapp", "StrongPass!2025");
    }

    public ResultSet laydl(String email) throws SQLException {
        if (email == null || email.trim().isEmpty()) {
            return null;  // Không hợp lệ
        }

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT nv.id, nv.ho_ten, nv.email, nv.mat_khau, nv.so_dien_thoai, ")
                .append("nv.gioi_tinh, nv.ngay_sinh, nv.phong_ban_id, pb.ten_phong AS ten_phong_ban, ")
                .append("nv.chuc_vu, nv.ngay_vao_lam, nv.trang_thai_lam_viec, nv.vai_tro, nv.avatar_url ")
                .append("FROM nhanvien nv ")
                .append("LEFT JOIN phong_ban pb ON nv.phong_ban_id = pb.id ");

        // 🔹 Sắp xếp theo chức vụ
        sql.append("ORDER BY CASE ")
                .append("WHEN nv.chuc_vu = 'Giám đốc' THEN 1 ")
                .append("WHEN nv.chuc_vu = 'Trưởng phòng' THEN 2 ")
                .append("WHEN nv.chuc_vu = 'Nhân viên' THEN 3 ")
                .append("WHEN nv.chuc_vu = 'Thực tập sinh' THEN 4 ")
                .append("ELSE 4 END, nv.ho_ten ASC");

        PreparedStatement stmt = this.cn.prepareStatement(sql.toString());
        return stmt.executeQuery();
    }

    public ResultSet laydlAZ(String email) throws SQLException {
        if (email == null || email.trim().isEmpty()) {
            return null;
        }

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT nv.id, nv.ho_ten, nv.email, nv.mat_khau, nv.so_dien_thoai, ")
                .append("nv.gioi_tinh, nv.ngay_sinh, nv.phong_ban_id, pb.ten_phong AS ten_phong_ban, ")
                .append("nv.chuc_vu, nv.ngay_vao_lam, nv.trang_thai_lam_viec, nv.vai_tro, nv.avatar_url ")
                .append("FROM nhanvien nv ")
                .append("LEFT JOIN phong_ban pb ON nv.phong_ban_id = pb.id ")
                .append("WHERE nv.trang_thai_lam_viec = 'Đang làm' ");  // ✅ Chỉ lấy nhân viên đang làm

        // 🔹 Sắp xếp theo tên A → Z
        sql.append("ORDER BY nv.ho_ten ASC");

        PreparedStatement stmt = this.cn.prepareStatement(sql.toString());
        return stmt.executeQuery();
    }

    public List<Map<String, Object>> getAllNhanVien() throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();

        String sql = "SELECT nv.id, nv.ho_ten, nv.email, nv.avatar_url, "
                + "nv.phong_ban_id, pb.ten_phong AS ten_phong_ban "
                + "FROM nhanvien nv "
                + "LEFT JOIN phong_ban pb ON nv.phong_ban_id = pb.id "
                + "ORDER BY nv.ho_ten ASC";

        try (PreparedStatement stmt = cn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> nv = new HashMap<>();
                nv.put("id", rs.getInt("id"));
                nv.put("ho_ten", rs.getString("ho_ten"));
                nv.put("email", rs.getString("email"));
                nv.put("avatar_url", rs.getString("avatar_url"));
                nv.put("phong_ban_id", rs.getInt("phong_ban_id"));
                nv.put("ten_phong_ban", rs.getString("ten_phong_ban"));

                list.add(nv);
            }
        }

        return list;
    }

    public ResultSet layThongTinNhanVienTheoEmail(String email) throws SQLException {
        if (email == null || email.trim().isEmpty()) {
            return null; // Email không hợp lệ
        }

        String sql = "SELECT nv.id, nv.ho_ten, nv.email, nv.mat_khau, nv.so_dien_thoai, "
                + "nv.gioi_tinh, nv.ngay_sinh, nv.phong_ban_id, pb.ten_phong AS ten_phong_ban, "
                + "nv.chuc_vu, nv.ngay_vao_lam, nv.trang_thai_lam_viec, nv.vai_tro, nv.ngay_tao, nv.avatar_url "
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

    public List<Map<String, Object>> getAllTasksNV(String email, int projectId) throws SQLException {
        List<Map<String, Object>> tasks = new ArrayList<>();

        if (email == null || email.trim().isEmpty()) {
            return tasks;
        }

        // 🔹 Lấy ID nhân viên + phòng ban
        String getInfoSql = """
        SELECT nv.id, nv.phong_ban_id
        FROM nhanvien nv
        WHERE nv.email = ?
    """;

        int userId = -1;
        int phongBanId = -1;

        try (PreparedStatement infoStmt = cn.prepareStatement(getInfoSql)) {
            infoStmt.setString(1, email);

            try (ResultSet rs = infoStmt.executeQuery()) {
                if (rs.next()) {
                    userId = rs.getInt("id");
                    phongBanId = rs.getInt("phong_ban_id");
                } else {
                    return tasks;
                }
            }
        }

        String sql;

        // ===========================================================
        // 🔥 1) Nếu projectId = 0 → Lấy tất cả task của nhân viên
        // ===========================================================
        if (projectId == 0) {
            sql = """
            SELECT cv.id, cv.du_an_id, da.ten_du_an,
                   cv.ten_cong_viec, cv.mo_ta,
                   cv.muc_do_uu_tien, cv.trang_thai, cv.tai_lieu_cv, cv.file_tai_lieu,
                   cv.han_hoan_thanh, cv.ngay_bat_dau, cv.ngay_gia_han,
                   cv.trang_thai_duyet, cv.ly_do_duyet, cv.nhac_viec,
                   ng1.ho_ten AS nguoi_giao_ten,
                   GROUP_CONCAT(DISTINCT ng2.ho_ten ORDER BY ng2.ho_ten SEPARATOR ', ') AS nguoi_nhan_ten,
                   GROUP_CONCAT(DISTINCT ng3.ho_ten ORDER BY ng3.ho_ten SEPARATOR ', ') AS nguoi_theo_doi_ten,
                   MAX(td.phan_tram) AS phan_tram,
                   pb.ten_phong AS ten_phong
            FROM cong_viec cv
            LEFT JOIN du_an da ON cv.du_an_id = da.id
            LEFT JOIN nhanvien ng1 ON cv.nguoi_giao_id = ng1.id
            LEFT JOIN cong_viec_nguoi_nhan cvnn ON cv.id = cvnn.cong_viec_id
            LEFT JOIN nhanvien ng2 ON cvnn.nhan_vien_id = ng2.id
            LEFT JOIN cong_viec_nguoi_theo_doi cvntd ON cv.id = cvntd.cong_viec_id
            LEFT JOIN nhanvien ng3 ON cvntd.nhan_vien_id = ng3.id
            LEFT JOIN cong_viec_tien_do td ON cv.id = td.cong_viec_id
            LEFT JOIN phong_ban pb ON cv.phong_ban_id = pb.id
            WHERE cv.tinh_trang IS NULL
              AND (cv.nguoi_giao_id = ?
                OR cv.id IN (SELECT cong_viec_id FROM cong_viec_nguoi_nhan WHERE nhan_vien_id = ?)
                OR cv.id IN (SELECT cong_viec_id FROM cong_viec_nguoi_theo_doi WHERE nhan_vien_id = ?))
            GROUP BY cv.id
        """;

            try (PreparedStatement stmt = cn.prepareStatement(sql)) {
                stmt.setInt(1, userId);
                stmt.setInt(2, userId);
                stmt.setInt(3, userId);
                return executeTaskQuery(stmt);
            }
        }

        // ===========================================================
        // 🔥 2) Nếu projectId > 0 → Giữ nguyên logic cũ nhưng thêm tên dự án
        // ===========================================================
        // Lấy lead của dự án
        String getLeadSql = "SELECT lead_id FROM du_an WHERE id = ?";
        int leadOfProject = -1;

        try (PreparedStatement leadStmt = cn.prepareStatement(getLeadSql)) {
            leadStmt.setInt(1, projectId);
            try (ResultSet rs = leadStmt.executeQuery()) {
                if (rs.next()) {
                    leadOfProject = rs.getInt("lead_id");
                }
            }
        }

        boolean isLead = (userId == leadOfProject);

        if (isLead) {
            // 🔹 LEAD xem toàn bộ task dự án
            sql = """
            SELECT cv.id, cv.du_an_id, da.ten_du_an,
                   cv.ten_cong_viec, cv.mo_ta,
                   cv.muc_do_uu_tien, cv.trang_thai, cv.tai_lieu_cv, cv.file_tai_lieu,
                   cv.han_hoan_thanh, cv.ngay_bat_dau, cv.ngay_gia_han,
                   cv.trang_thai_duyet, cv.ly_do_duyet, cv.nhac_viec,
                   ng1.ho_ten AS nguoi_giao_ten,
                   GROUP_CONCAT(DISTINCT ng2.ho_ten ORDER BY ng2.ho_ten SEPARATOR ', ') AS nguoi_nhan_ten,
                   GROUP_CONCAT(DISTINCT ng3.ho_ten ORDER BY ng3.ho_ten SEPARATOR ', ') AS nguoi_theo_doi_ten,
                   MAX(td.phan_tram) AS phan_tram,
                   pb.ten_phong AS ten_phong
            FROM cong_viec cv
            LEFT JOIN du_an da ON cv.du_an_id = da.id
            LEFT JOIN nhanvien ng1 ON cv.nguoi_giao_id = ng1.id
            LEFT JOIN cong_viec_nguoi_nhan cvnn ON cv.id = cvnn.cong_viec_id
            LEFT JOIN nhanvien ng2 ON cvnn.nhan_vien_id = ng2.id
            LEFT JOIN cong_viec_nguoi_theo_doi cvntd ON cv.id = cvntd.cong_viec_id
            LEFT JOIN nhanvien ng3 ON cvntd.nhan_vien_id = ng3.id
            LEFT JOIN cong_viec_tien_do td ON cv.id = td.cong_viec_id
            LEFT JOIN phong_ban pb ON cv.phong_ban_id = pb.id
            WHERE cv.tinh_trang IS NULL
              AND cv.du_an_id = ?
            GROUP BY cv.id
        """;
        } else {
            // 🔹 Nhân viên thường → xem task được giao của dự án
            sql = """
            SELECT cv.id, cv.du_an_id, da.ten_du_an,
                   cv.ten_cong_viec, cv.mo_ta,
                   cv.muc_do_uu_tien, cv.trang_thai, cv.tai_lieu_cv, cv.file_tai_lieu,
                   cv.han_hoan_thanh, cv.ngay_bat_dau, cv.ngay_gia_han,
                   cv.trang_thai_duyet, cv.ly_do_duyet, cv.nhac_viec,
                   ng1.ho_ten AS nguoi_giao_ten,
                   GROUP_CONCAT(DISTINCT ng2.ho_ten ORDER BY ng2.ho_ten SEPARATOR ', ') AS nguoi_nhan_ten,
                   GROUP_CONCAT(DISTINCT ng3.ho_ten ORDER BY ng3.ho_ten SEPARATOR ', ') AS nguoi_theo_doi_ten,
                   MAX(td.phan_tram) AS phan_tram,
                   pb.ten_phong AS ten_phong
            FROM cong_viec cv
            LEFT JOIN du_an da ON cv.du_an_id = da.id
            LEFT JOIN nhanvien ng1 ON cv.nguoi_giao_id = ng1.id
            LEFT JOIN cong_viec_nguoi_nhan cvnn ON cv.id = cvnn.cong_viec_id
            LEFT JOIN nhanvien ng2 ON cvnn.nhan_vien_id = ng2.id
            LEFT JOIN cong_viec_nguoi_theo_doi cvntd ON cv.id = cvntd.cong_viec_id
            LEFT JOIN nhanvien ng3 ON cvntd.nhan_vien_id = ng3.id
            LEFT JOIN cong_viec_tien_do td ON cv.id = td.cong_viec_id
            LEFT JOIN phong_ban pb ON cv.phong_ban_id = pb.id
            WHERE cv.tinh_trang IS NULL
              AND cv.du_an_id = ?
              AND (cv.nguoi_giao_id = ?
                OR cv.id IN (SELECT cong_viec_id FROM cong_viec_nguoi_nhan WHERE nhan_vien_id = ?)
                OR cv.id IN (SELECT cong_viec_id FROM cong_viec_nguoi_theo_doi WHERE nhan_vien_id = ?))
            GROUP BY cv.id
        """;
        }

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, projectId);
            if (!isLead) {
                stmt.setInt(2, userId);
                stmt.setInt(3, userId);
                stmt.setInt(4, userId);
            }
            return executeTaskQuery(stmt);
        }
    }

    private List<Map<String, Object>> executeTaskQuery(PreparedStatement stmt) throws SQLException {
        List<Map<String, Object>> tasks = new ArrayList<>();

        try (ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> task = new HashMap<>();

                task.put("id", rs.getInt("id"));
                task.put("du_an_id", rs.getInt("du_an_id"));
                task.put("ten_du_an", rs.getString("ten_du_an"));
                task.put("ten_cong_viec", rs.getString("ten_cong_viec"));
                task.put("mo_ta", rs.getString("mo_ta"));
                task.put("nguoi_giao_id", rs.getString("nguoi_giao_ten"));
                task.put("nguoi_nhan_ten", rs.getString("nguoi_nhan_ten"));
                task.put("nguoi_theo_doi_ten", rs.getString("nguoi_theo_doi_ten"));
                task.put("phan_tram", rs.getString("phan_tram"));
                task.put("muc_do_uu_tien", rs.getString("muc_do_uu_tien"));
                task.put("trang_thai", rs.getString("trang_thai"));
                task.put("tai_lieu_cv", rs.getString("tai_lieu_cv"));
                task.put("file_tai_lieu", rs.getString("file_tai_lieu"));
                task.put("han_hoan_thanh", rs.getDate("han_hoan_thanh"));
                task.put("ngay_bat_dau", rs.getDate("ngay_bat_dau"));
                task.put("ngay_gia_han", rs.getDate("ngay_gia_han"));
                task.put("trang_thai_duyet", rs.getString("trang_thai_duyet"));
                task.put("ly_do_duyet", rs.getString("ly_do_duyet"));
                task.put("nhac_viec", rs.getString("nhac_viec"));
                task.put("phong_ban_id", rs.getString("ten_phong"));

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

    // Xoá hết người nhận của 1 công việc
    public void clearNguoiNhan(int taskId) throws SQLException {
        String sql = "DELETE FROM cong_viec_nguoi_nhan WHERE cong_viec_id=?";
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            ps.executeUpdate();
        }
    }

// Thêm người nhận cho công việc
    public void addNguoiNhan(int taskId, int nhanVienId) throws SQLException {
        String sql = "INSERT INTO cong_viec_nguoi_nhan (cong_viec_id, nhan_vien_id) VALUES (?, ?)";
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            ps.setInt(2, nhanVienId);
            ps.executeUpdate();
        }
    }

    // ===== NGƯỜI THEO DÕI =====
    public void clearNguoiTheoDoi(int taskId) throws SQLException {
        String sql = "DELETE FROM cong_viec_nguoi_theo_doi WHERE cong_viec_id=?";
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            ps.executeUpdate();
        }
    }

    public void addNguoiTheoDoi(int taskId, int nhanVienId) throws SQLException {
        String sql = "INSERT IGNORE INTO cong_viec_nguoi_theo_doi (cong_viec_id, nhan_vien_id) VALUES (?, ?)";
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            ps.setInt(2, nhanVienId);
            ps.executeUpdate();
        }
    }

    public void capNhatDanhSachNguoiTheoDoi(int congViecId, List<Integer> danhSachIdMoi) throws SQLException {
        try (PreparedStatement deleteStmt = cn.prepareStatement("DELETE FROM cong_viec_nguoi_theo_doi WHERE cong_viec_id = ?")) {
            deleteStmt.setInt(1, congViecId);
            deleteStmt.executeUpdate();
        }
        String insertSql = "INSERT IGNORE INTO cong_viec_nguoi_theo_doi(cong_viec_id, nhan_vien_id) VALUES (?, ?)";
        try (PreparedStatement insertStmt = cn.prepareStatement(insertSql)) {
            for (Integer nhanId : danhSachIdMoi) {
                insertStmt.setInt(1, congViecId);
                insertStmt.setInt(2, nhanId);
                insertStmt.addBatch();
            }
            insertStmt.executeBatch();
        }
    }

    public String getDanhSachNguoiTheoDoi(int taskId) throws SQLException {
        String sql = "SELECT GROUP_CONCAT(nv.ho_ten ORDER BY nv.ho_ten SEPARATOR ', ') AS ten_list "
                + "FROM cong_viec_nguoi_theo_doi td JOIN nhanvien nv ON td.nhan_vien_id = nv.id "
                + "WHERE td.cong_viec_id = ?";
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("ten_list");
                }
            }
        }
        return null;
    }

    // Sửa insertTask trả về id mới
    public int insertTask(int duanid, String ten, String moTa, String ngaybd, String han, String uuTien,
            int giaoId, int phongId, String trangThai, String taiLieu, String file) throws SQLException {
        String sql = "INSERT INTO cong_viec (du_an_id, ten_cong_viec, mo_ta, ngay_bat_dau, han_hoan_thanh, muc_do_uu_tien, nguoi_giao_id, phong_ban_id, trang_thai, tai_lieu_cv, file_tai_lieu) VALUES (?,?,?,?,?,?,?,?,?,?,?)";
        try (PreparedStatement ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, duanid);
            ps.setString(2, ten);
            ps.setString(3, moTa);
            ps.setString(4, ngaybd);
            ps.setString(5, han);
            ps.setString(6, uuTien);
            ps.setInt(7, giaoId);
            ps.setInt(8, phongId);
            ps.setString(9, trangThai);
            ps.setString(10, taiLieu);
            ps.setString(11, file);
            ps.executeUpdate();
            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return -1;
    }

    public void updateTask(int id, String ten, String moTa, String ngaybd, String han, String uuTien,
            int giaoId, int phongBanId, String trangThai, String tailieu, String file) throws SQLException {
        String sql = "UPDATE cong_viec SET ten_cong_viec=?, mo_ta=?, ngay_bat_dau=?, han_hoan_thanh=?, muc_do_uu_tien=?, "
                + "nguoi_giao_id=?, phong_ban_id=?, trang_thai=?, tai_lieu_cv=?, file_tai_lieu=? WHERE id=?";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setString(1, ten);
            stmt.setString(2, moTa);
            stmt.setDate(3, java.sql.Date.valueOf(ngaybd));
            stmt.setDate(4, java.sql.Date.valueOf(han));
            stmt.setString(5, uuTien);
            stmt.setInt(6, giaoId);
            stmt.setInt(7, phongBanId);
            stmt.setString(8, trangThai);
            stmt.setString(9, tailieu);
            stmt.setString(10, file);
            stmt.setInt(11, id);
            stmt.executeUpdate();
        }
    }

    public List<Integer> layIdTuDanhSachTen(String chuoiTen) throws SQLException {
        List<Integer> ids = new ArrayList<>();
        if (chuoiTen == null || chuoiTen.trim().isEmpty()) {
            return ids;
        }

        String[] tenArray = chuoiTen.split(",");
        String sql = "SELECT id FROM nhanvien WHERE TRIM(ho_ten) = ?";
        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            for (String ten : tenArray) {
                stmt.setString(1, ten.trim());
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        ids.add(rs.getInt("id"));
                    }
                }
            }
        }
        return ids;
    }

    public void capNhatDanhSachNguoiNhan(int congViecId, List<Integer> danhSachIdMoi) throws SQLException {
        // Xóa cũ
        try (PreparedStatement deleteStmt = cn.prepareStatement("DELETE FROM cong_viec_nguoi_nhan WHERE cong_viec_id = ?")) {
            deleteStmt.setInt(1, congViecId);
            deleteStmt.executeUpdate();
        }

        // Thêm mới
        String insertSql = "INSERT INTO cong_viec_nguoi_nhan(cong_viec_id, nhan_vien_id) VALUES (?, ?)";
        try (PreparedStatement insertStmt = cn.prepareStatement(insertSql)) {
            for (Integer nhanId : danhSachIdMoi) {
                insertStmt.setInt(1, congViecId);
                insertStmt.setInt(2, nhanId);
                insertStmt.addBatch();
            }
            insertStmt.executeBatch();
        }
    }

    public ResultSet getStepsRawByTaskId(String taskId) throws SQLException {
        String sql = "SELECT id, ten_buoc, mo_ta, trang_thai, ngay_bat_dau, ngay_ket_thuc, tai_lieu_link, tai_lieu_file "
                + "FROM cong_viec_quy_trinh WHERE cong_viec_id = ? ORDER BY ngay_bat_dau ASC";
        PreparedStatement ps = cn.prepareStatement(sql);
        ps.setString(1, taskId);
        return ps.executeQuery();
    }

    /**
     * Lấy thông tin chi tiết tiến độ theo ID
     *
     * @param stepId ID của tiến độ
     * @return Map chứa thông tin tiến độ
     */
    public Map<String, Object> getStepById(int stepId) throws SQLException {
        String sql = "SELECT id, cong_viec_id, ten_buoc, mo_ta, trang_thai, ngay_bat_dau, ngay_ket_thuc, tai_lieu_link, tai_lieu_file "
                + "FROM cong_viec_quy_trinh WHERE id = ?";

        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, stepId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> step = new LinkedHashMap<>();
                    step.put("id", rs.getInt("id"));
                    step.put("cong_viec_id", rs.getInt("cong_viec_id"));
                    step.put("ten_buoc", rs.getString("ten_buoc"));
                    step.put("mo_ta", rs.getString("mo_ta"));
                    step.put("trang_thai", rs.getString("trang_thai"));
                    step.put("ngay_bat_dau", rs.getString("ngay_bat_dau"));
                    step.put("ngay_ket_thuc", rs.getString("ngay_ket_thuc"));
                    step.put("tai_lieu_link", rs.getString("tai_lieu_link"));
                    step.put("tai_lieu_file", rs.getString("tai_lieu_file"));
                    return step;
                }
            }
        }
        return null;
    }

    public List<Map<String, Object>> getNguoiNhanByStepId(int stepId) throws SQLException {
        String sql = "SELECT n.id, n.ho_ten FROM quy_trinh_nguoi_nhan q "
                + "JOIN nhanvien n ON q.nhan_id = n.id "
                + "WHERE q.step_id = ?";
        PreparedStatement ps = cn.prepareStatement(sql);
        ps.setInt(1, stepId);
        ResultSet rs = ps.executeQuery();

        List<Map<String, Object>> list = new ArrayList<>();
        while (rs.next()) {
            Map<String, Object> nguoi = new LinkedHashMap<>();
            nguoi.put("id", rs.getInt("id"));
            nguoi.put("ten", rs.getString("ho_ten"));  // 👈 đổi đúng theo cột trong DB
            list.add(nguoi);
        }
        return list;
    }

    public boolean updateStepById(int stepId, String name, String desc,
            String status, String start, String end) throws SQLException {
        String sql = "UPDATE cong_viec_quy_trinh SET ten_buoc = ?, mo_ta = ?, trang_thai = ?, ngay_bat_dau = ?, ngay_ket_thuc = ? WHERE id = ?";
        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setString(1, name);
            stmt.setString(2, desc);
            stmt.setString(3, status);
            stmt.setString(4, start);
            stmt.setString(5, end);
            stmt.setInt(6, stepId);
            int affected = stmt.executeUpdate();
            return affected > 0;
        }
    }

    public boolean updateStepByIdWithDocuments(int stepId, String name, String desc,
            String status, String start, String end, String linkTaiLieu, String fileTaiLieu) throws SQLException {
        String sql = "UPDATE cong_viec_quy_trinh SET ten_buoc = ?, mo_ta = ?, trang_thai = ?, ngay_bat_dau = ?, ngay_ket_thuc = ?, tai_lieu_link = ?, tai_lieu_file = ? WHERE id = ?";
        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setString(1, name);
            stmt.setString(2, desc);
            stmt.setString(3, status);
            stmt.setString(4, start);
            stmt.setString(5, end);
            stmt.setString(6, linkTaiLieu);
            stmt.setString(7, fileTaiLieu);
            stmt.setInt(8, stepId);
            int affected = stmt.executeUpdate();
            return affected > 0;
        }
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
        // ❌ KHÔNG đóng cn ở đây
        return newId;
    }

    public String getTenCongViecById(int congViecId) throws SQLException {
        String sql = "SELECT ten_cong_viec FROM cong_viec WHERE id = ? LIMIT 1";
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, congViecId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("ten_cong_viec");
                }
            }
        }
        return null;
    }

    public List<Map<String, String>> layDanhGiaTheoCongViec(int congViecId) {
        List<Map<String, String>> danhSachDanhGia = new ArrayList<>();
        String sql = """
        SELECT d.nhan_xet, d.thoi_gian, d.is_from_worker,
               n.ho_ten AS ten_nguoi_danh_gia
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
                    dg.put("is_from_worker", rs.getString("is_from_worker"));
                    danhSachDanhGia.add(dg);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(KNCSDL.class.getName()).log(Level.SEVERE, null, ex);
        }

        return danhSachDanhGia;
    }

    // Thêm đánh giá mới
    public boolean insertDanhGia(int congViecId, int nguoiDanhGiaId, String nhanXet, int isFromWorker) throws SQLException {
        String sql = "INSERT INTO cong_viec_danh_gia (cong_viec_id, nguoi_danh_gia_id, nhan_xet, is_from_worker) VALUES (?, ?, ?, ?)";
        PreparedStatement ps = cn.prepareStatement(sql);

        ps.setInt(1, congViecId);
        ps.setInt(2, nguoiDanhGiaId);
        ps.setString(3, nhanXet);
        ps.setInt(4, isFromWorker);

        int result = ps.executeUpdate();
        ps.close();
        cn.close();
        return result > 0;
    }

    public void capNhatTrangThaiTuTienDo(int congViecId) throws SQLException {
        String sqlTienDo = "SELECT phan_tram FROM cong_viec_tien_do WHERE cong_viec_id = ?";
        String sqlCheckQuyTrinhDangTH
                = "SELECT COUNT(*) AS cnt FROM cong_viec_quy_trinh WHERE cong_viec_id = ? AND trang_thai = 'Đang thực hiện'";
        String sqlInfoCv = "SELECT han_hoan_thanh, trang_thai FROM cong_viec WHERE id = ?";
        String sqlCapNhatTrangThai = "UPDATE cong_viec SET trang_thai = ? WHERE id = ?";

        try (
                PreparedStatement psInfo = cn.prepareStatement(sqlInfoCv); PreparedStatement psTienDo = cn.prepareStatement(sqlTienDo); PreparedStatement psCheckQT = cn.prepareStatement(sqlCheckQuyTrinhDangTH); PreparedStatement psUpdate = cn.prepareStatement(sqlCapNhatTrangThai)) {

            // === 1) Lấy thông tin công việc ===
            psInfo.setInt(1, congViecId);
            Date han = null;
            String trangThaiCu = null;

            try (ResultSet rs = psInfo.executeQuery()) {
                if (!rs.next()) {
                    return;
                }

                han = rs.getDate("han_hoan_thanh");
                trangThaiCu = rs.getString("trang_thai");
            }

            // === 2) Lấy tiến độ ===
            psTienDo.setInt(1, congViecId);
            Integer percent = null;

            try (ResultSet rs = psTienDo.executeQuery()) {
                if (rs.next()) {
                    percent = rs.getInt("phan_tram");
                }
            }

            if (percent == null) {
                return;
            }

            String trangThaiMoi;

            // === (A) ƯU TIÊN CAO NHẤT: HOÀN THÀNH ===
            if (percent >= 100) {
                trangThaiMoi = "Đã hoàn thành";
            } else {
                // === (B) KIỂM TRA QUÁ HẠN ===
                boolean quaHan = false;
                if (han != null) {
                    LocalDate today = LocalDate.now();
                    quaHan = han.toLocalDate().isBefore(today);
                }

                if (quaHan) {
                    trangThaiMoi = "Trễ hạn";
                } else {
                    // === (C) CHƯA QUÁ HẠN → XÉT TIẾN ĐỘ ===
                    if (percent == 0) {
                        psCheckQT.setInt(1, congViecId);

                        int dangTH = 0;
                        try (ResultSet rs = psCheckQT.executeQuery()) {
                            if (rs.next()) {
                                dangTH = rs.getInt("cnt");
                            }
                        }

                        trangThaiMoi = (dangTH > 0) ? "Đang thực hiện" : "Chưa bắt đầu";
                    } else {
                        trangThaiMoi = "Đang thực hiện";
                    }
                }
            }

            // === 3) NẾU KHÔNG THAY ĐỔI TRẠNG THÁI → THOÁT ===
            if (trangThaiMoi.equalsIgnoreCase(trangThaiCu)) {
                return;
            }

            // === 4) CẬP NHẬT TRẠNG THÁI ===
            psUpdate.setString(1, trangThaiMoi);
            psUpdate.setInt(2, congViecId);
            psUpdate.executeUpdate();

            // === 5) CẬP NHẬT NGÀY BẮT ĐẦU (nếu mới chuyển sang Đang thực hiện) ===
            if ("Đang thực hiện".equalsIgnoreCase(trangThaiMoi)
                    && "Chưa bắt đầu".equalsIgnoreCase(trangThaiCu)) {

                try (PreparedStatement ps = cn.prepareStatement(
                        "UPDATE cong_viec SET ngay_bat_dau = CURRENT_DATE WHERE id = ? AND ngay_bat_dau IS NULL"
                )) {
                    ps.setInt(1, congViecId);
                    ps.executeUpdate();
                }
            }

            // === 6) CẬP NHẬT NGÀY HOÀN THÀNH (nếu mới chuyển sang Đã hoàn thành) ===
            if ("Đã hoàn thành".equalsIgnoreCase(trangThaiMoi)) {
                try (PreparedStatement ps = cn.prepareStatement(
                        "UPDATE cong_viec SET ngay_hoan_thanh = CURRENT_DATE WHERE id = ? AND ngay_hoan_thanh IS NULL"
                )) {
                    ps.setInt(1, congViecId);
                    ps.executeUpdate();
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

    public List<Map<String, Object>> locCongViec(String keyword, String tinhtrang, String phongBan, String trangThai, Integer projectId) throws SQLException {
        List<Map<String, Object>> danhSach = new ArrayList<>();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT cv.id, cv.du_an_id, cv.ten_cong_viec, cv.mo_ta, cv.muc_do_uu_tien, cv.trang_thai, ")
                .append("cv.tai_lieu_cv, cv.file_tai_lieu, cv.han_hoan_thanh, cv.ngay_bat_dau, cv.ngay_gia_han, ")
                .append("cv.trang_thai_duyet, cv.ly_do_duyet, cv.nhac_viec, cv.tinh_trang, ")
                .append("ng1.ho_ten AS nguoi_giao_ten, ")
                .append("GROUP_CONCAT(DISTINCT ng2.ho_ten ORDER BY ng2.ho_ten SEPARATOR ', ') AS nguoi_nhan_ten, ")
                .append("GROUP_CONCAT(DISTINCT ng3.ho_ten ORDER BY ng3.ho_ten SEPARATOR ', ') AS nguoi_theo_doi_ten, ")
                .append("MAX(td.phan_tram) AS phan_tram, ")
                .append("pb.ten_phong AS ten_phong ")
                .append("FROM cong_viec cv ")
                .append("LEFT JOIN nhanvien ng1 ON cv.nguoi_giao_id = ng1.id ")
                .append("LEFT JOIN cong_viec_nguoi_nhan cvnn ON cv.id = cvnn.cong_viec_id ")
                .append("LEFT JOIN nhanvien ng2 ON cvnn.nhan_vien_id = ng2.id ")
                .append("LEFT JOIN cong_viec_nguoi_theo_doi cvntd ON cv.id = cvntd.cong_viec_id ")
                .append("LEFT JOIN nhanvien ng3 ON cvntd.nhan_vien_id = ng3.id ")
                .append("LEFT JOIN cong_viec_tien_do td ON cv.id = td.cong_viec_id ")
                .append("LEFT JOIN phong_ban pb ON cv.phong_ban_id = pb.id ")
                .append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (projectId != null && projectId != 0) {
            sql.append(" AND cv.du_an_id = ? ");
            params.add(projectId);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND cv.ten_cong_viec LIKE ? ");
            params.add("%" + keyword.trim() + "%");
        }
        if (phongBan != null && !phongBan.isEmpty()) {
            sql.append(" AND pb.ten_phong = ? ");
            params.add(phongBan);
        }
        if (trangThai != null && !trangThai.isEmpty()) {
            sql.append(" AND cv.trang_thai = ? ");
            params.add(trangThai);
        }
        if (tinhtrang != null && !tinhtrang.isEmpty()) {
            sql.append(" AND cv.tinh_trang = ? ");
            params.add(tinhtrang);
        } else {
            sql.append(" AND (cv.tinh_trang IS NULL OR cv.tinh_trang = '') ");
        }

        sql.append(" GROUP BY cv.id ");

        try (PreparedStatement ps = cn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> task = new HashMap<>();
                    task.put("id", rs.getInt("id"));
                    task.put("du_an_id", rs.getInt("du_an_id"));
                    task.put("ten_cong_viec", rs.getString("ten_cong_viec"));
                    task.put("mo_ta", rs.getString("mo_ta"));
                    task.put("nguoi_giao_id", rs.getString("nguoi_giao_ten"));
                    task.put("nguoi_nhan_ten", rs.getString("nguoi_nhan_ten"));
                    task.put("nguoi_theo_doi_ten", rs.getString("nguoi_theo_doi_ten"));
                    task.put("phan_tram", rs.getString("phan_tram"));
                    task.put("phong_ban_id", rs.getString("ten_phong"));
                    task.put("muc_do_uu_tien", rs.getString("muc_do_uu_tien"));
                    task.put("trang_thai", rs.getString("trang_thai"));
                    task.put("tai_lieu_cv", rs.getString("tai_lieu_cv"));
                    task.put("file_tai_lieu", rs.getString("file_tai_lieu"));
                    task.put("tinh_trang", rs.getString("tinh_trang"));
                    task.put("han_hoan_thanh", rs.getDate("han_hoan_thanh"));
                    task.put("ngay_bat_dau", rs.getDate("ngay_bat_dau"));
                    task.put("ngay_gia_han", rs.getDate("ngay_gia_han"));
                    task.put("trang_thai_duyet", rs.getString("trang_thai_duyet"));
                    task.put("ly_do_duyet", rs.getString("ly_do_duyet"));
                    task.put("nhac_viec", rs.getString("nhac_viec"));
                    danhSach.add(task);
                }
            }
        }

        return danhSach;
    }

    public List<Map<String, Object>> locCongViecNV(String keyword, String tinhtrang, String trangThai,
            String emailNhanVien, Integer projectId) throws SQLException {

        List<Map<String, Object>> danhSach = new ArrayList<>();

        // 🔹 Lấy ID nhân viên từ email
        int userId = -1;
        try (PreparedStatement st = cn.prepareStatement("SELECT id FROM nhanvien WHERE email = ?")) {
            st.setString(1, emailNhanVien);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    userId = rs.getInt("id");
                } else {
                    return danhSach;
                }
            }
        }

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT cv.id, cv.du_an_id, cv.ten_cong_viec, cv.mo_ta, cv.muc_do_uu_tien, cv.trang_thai, ")
                .append("cv.tai_lieu_cv, cv.file_tai_lieu, cv.han_hoan_thanh, cv.ngay_bat_dau, cv.ngay_gia_han, ")
                .append("cv.trang_thai_duyet, cv.ly_do_duyet, cv.nhac_viec, cv.tinh_trang, ")
                .append("ng1.ho_ten AS nguoi_giao_ten, ")
                .append("GROUP_CONCAT(DISTINCT ng2.ho_ten ORDER BY ng2.ho_ten SEPARATOR ', ') AS nguoi_nhan_ten, ")
                .append("GROUP_CONCAT(DISTINCT ng3.ho_ten ORDER BY ng3.ho_ten SEPARATOR ', ') AS nguoi_theo_doi_ten, ")
                .append("MAX(td.phan_tram) AS phan_tram, ")
                .append("pb.ten_phong AS ten_phong ")
                .append("FROM cong_viec cv ")
                .append("LEFT JOIN nhanvien ng1 ON cv.nguoi_giao_id = ng1.id ")
                .append("LEFT JOIN cong_viec_nguoi_nhan cvnn ON cv.id = cvnn.cong_viec_id ")
                .append("LEFT JOIN nhanvien ng2 ON cvnn.nhan_vien_id = ng2.id ")
                .append("LEFT JOIN cong_viec_nguoi_theo_doi cvntd ON cv.id = cvntd.cong_viec_id ")
                .append("LEFT JOIN nhanvien ng3 ON cvntd.nhan_vien_id = ng3.id ")
                .append("LEFT JOIN cong_viec_tien_do td ON cv.id = td.cong_viec_id ")
                .append("LEFT JOIN phong_ban pb ON cv.phong_ban_id = pb.id ")
                .append("WHERE (cv.nguoi_giao_id = ? OR cv.id IN (SELECT cong_viec_id FROM cong_viec_nguoi_nhan WHERE nhan_vien_id = ?) OR cv.id IN (SELECT cong_viec_id FROM cong_viec_nguoi_theo_doi WHERE nhan_vien_id = ?)) ");

        List<Object> params = new ArrayList<>();
        params.add(userId);
        params.add(userId);
        params.add(userId);

        if (projectId != null && projectId != 0) {
            sql.append(" AND cv.du_an_id = ? ");
            params.add(projectId);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND cv.ten_cong_viec LIKE ? ");
            params.add("%" + keyword.trim() + "%");
        }

        if (trangThai != null && !trangThai.trim().isEmpty()) {
            sql.append(" AND cv.trang_thai = ? ");
            params.add(trangThai.trim());
        }

        if (tinhtrang != null && !tinhtrang.trim().isEmpty()) {
            sql.append(" AND cv.tinh_trang = ? ");
            params.add(tinhtrang.trim());
        } else {
            sql.append(" AND (cv.tinh_trang IS NULL OR cv.tinh_trang = '') ");
        }

        sql.append(" GROUP BY cv.id ");

        try (PreparedStatement ps = cn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> task = new HashMap<>();

                    task.put("id", rs.getInt("id"));
                    task.put("du_an_id", rs.getInt("du_an_id"));
                    task.put("ten_cong_viec", rs.getString("ten_cong_viec"));
                    task.put("mo_ta", rs.getString("mo_ta"));
                    task.put("nguoi_giao_id", rs.getString("nguoi_giao_ten"));
                    task.put("nguoi_nhan_ten", rs.getString("nguoi_nhan_ten"));  // 🔥 ĐÃ ĐẦY ĐỦ TOÀN BỘ
                    task.put("nguoi_theo_doi_ten", rs.getString("nguoi_theo_doi_ten"));
                    task.put("phan_tram", rs.getString("phan_tram"));
                    task.put("phong_ban_id", rs.getString("ten_phong"));
                    task.put("muc_do_uu_tien", rs.getString("muc_do_uu_tien"));
                    task.put("trang_thai", rs.getString("trang_thai"));
                    task.put("tai_lieu_cv", rs.getString("tai_lieu_cv"));
                    task.put("file_tai_lieu", rs.getString("file_tai_lieu"));
                    task.put("tinh_trang", rs.getString("tinh_trang"));
                    task.put("han_hoan_thanh", rs.getDate("han_hoan_thanh"));
                    task.put("ngay_bat_dau", rs.getDate("ngay_bat_dau"));
                    task.put("ngay_gia_han", rs.getDate("ngay_gia_han"));
                    task.put("trang_thai_duyet", rs.getString("trang_thai_duyet"));
                    task.put("ly_do_duyet", rs.getString("ly_do_duyet"));
                    task.put("nhac_viec", rs.getString("nhac_viec"));

                    danhSach.add(task);
                }
            }
        }

        return danhSach;
    }

    public List<Map<String, Object>> locCongViecQL(String keyword, String tinhtrang, String trangThai, String emailQL, Integer projectId) throws SQLException {
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
                    return danhSach;
                }
            }
        }

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT cv.id, cv.du_an_id, cv.ten_cong_viec, cv.mo_ta, cv.muc_do_uu_tien, cv.trang_thai, ")
                .append("cv.tai_lieu_cv, cv.file_tai_lieu, cv.han_hoan_thanh, cv.ngay_bat_dau, cv.ngay_gia_han, ")
                .append("cv.trang_thai_duyet, cv.ly_do_duyet, cv.nhac_viec, cv.tinh_trang, ")
                .append("ng1.ho_ten AS nguoi_giao_ten, ")
                .append("GROUP_CONCAT(DISTINCT ng2.ho_ten ORDER BY ng2.ho_ten SEPARATOR ', ') AS nguoi_nhan_ten, ")
                .append("GROUP_CONCAT(DISTINCT ng3.ho_ten ORDER BY ng3.ho_ten SEPARATOR ', ') AS nguoi_theo_doi_ten, ")
                .append("MAX(td.phan_tram) AS phan_tram, ")
                .append("pb.ten_phong AS ten_phong ")
                .append("FROM cong_viec cv ")
                .append("LEFT JOIN nhanvien ng1 ON cv.nguoi_giao_id = ng1.id ")
                .append("LEFT JOIN cong_viec_nguoi_nhan cvnn ON cv.id = cvnn.cong_viec_id ")
                .append("LEFT JOIN nhanvien ng2 ON cvnn.nhan_vien_id = ng2.id ")
                .append("LEFT JOIN cong_viec_nguoi_theo_doi cvntd ON cv.id = cvntd.cong_viec_id ")
                .append("LEFT JOIN nhanvien ng3 ON cvntd.nhan_vien_id = ng3.id ")
                .append("LEFT JOIN cong_viec_tien_do td ON cv.id = td.cong_viec_id ")
                .append("LEFT JOIN phong_ban pb ON cv.phong_ban_id = pb.id ")
                .append("WHERE (cv.phong_ban_id = ? OR cvnn.nhan_vien_id = ?) ");

        List<Object> params = new ArrayList<>();
        params.add(phongBanId);
        params.add(idQL);

        if (projectId != null && projectId != 0) {
            sql.append(" AND cv.du_an_id = ? ");
            params.add(projectId);
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND cv.ten_cong_viec LIKE ? ");
            params.add("%" + keyword.trim() + "%");
        }
        if (trangThai != null && !trangThai.trim().isEmpty()) {
            sql.append(" AND cv.trang_thai = ? ");
            params.add(trangThai.trim());
        }
        if (tinhtrang != null && !tinhtrang.isEmpty()) {
            sql.append(" AND cv.tinh_trang = ? ");
            params.add(tinhtrang);
        } else {
            sql.append(" AND (cv.tinh_trang IS NULL OR cv.tinh_trang = '') ");
        }

        sql.append(" GROUP BY cv.id ");

        try (PreparedStatement ps = cn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> task = new HashMap<>();
                    task.put("id", rs.getInt("id"));
                    task.put("du_an_id", rs.getInt("du_an_id"));
                    task.put("ten_cong_viec", rs.getString("ten_cong_viec"));
                    task.put("mo_ta", rs.getString("mo_ta"));
                    task.put("nguoi_giao_id", rs.getString("nguoi_giao_ten"));
                    task.put("nguoi_nhan_ten", rs.getString("nguoi_nhan_ten"));
                    task.put("nguoi_theo_doi_ten", rs.getString("nguoi_theo_doi_ten"));
                    task.put("phan_tram", rs.getString("phan_tram"));
                    task.put("phong_ban_id", rs.getString("ten_phong"));
                    task.put("muc_do_uu_tien", rs.getString("muc_do_uu_tien"));
                    task.put("trang_thai", rs.getString("trang_thai"));
                    task.put("tai_lieu_cv", rs.getString("tai_lieu_cv"));
                    task.put("file_tai_lieu", rs.getString("file_tai_lieu"));
                    task.put("tinh_trang", rs.getString("tinh_trang"));
                    task.put("han_hoan_thanh", rs.getDate("han_hoan_thanh"));
                    task.put("ngay_bat_dau", rs.getDate("ngay_bat_dau"));
                    task.put("ngay_gia_han", rs.getDate("ngay_gia_han"));
                    task.put("trang_thai_duyet", rs.getString("trang_thai_duyet"));
                    task.put("ly_do_duyet", rs.getString("ly_do_duyet"));
                    task.put("nhac_viec", rs.getString("nhac_viec"));
                    danhSach.add(task);
                }
            }
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
                    userInfo.put("id", rs.getString("id"));
                    userInfo.put("ho_ten", rs.getString("ho_ten"));
                    userInfo.put("email", email);
                    userInfo.put("chuc_vu", rs.getString("chuc_vu"));
                    userInfo.put("vai_tro", rs.getString("vai_tro"));
                    userInfo.put("avatar_url", rs.getString("avatar_url"));
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

    public String getVaiTroById(int userId) throws SQLException {
        String sql = "SELECT vai_tro FROM nhanvien WHERE id = ?";
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getString("vai_tro");
            }
        }
        return null;
    }

    // Lấy danh sách tất cả phòng ban
    public List<Map<String, Object>> getAllPhongBan() throws SQLException {
        List<Map<String, Object>> danhSach = new ArrayList<>();
        String sql = "SELECT pb.id, pb.ten_phong, pb.truong_phong_id, "
                + "tp.ho_ten AS truong_phong_ten, tp.avatar_url AS truong_phong_avatar, "
                + "pb.ngay_tao, COUNT(nv.id) AS so_nhan_vien "
                + "FROM phong_ban pb "
                + "LEFT JOIN nhanvien tp ON pb.truong_phong_id = tp.id "
                + "LEFT JOIN nhanvien nv ON pb.id = nv.phong_ban_id "
                + "GROUP BY pb.id, pb.ten_phong, pb.truong_phong_id, "
                + "tp.ho_ten, tp.avatar_url, pb.ngay_tao "
                + "ORDER BY pb.id";

        try (PreparedStatement stmt = cn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> phongBan = new HashMap<>();
                phongBan.put("id", rs.getInt("id"));
                phongBan.put("ten_phong", rs.getString("ten_phong"));
                phongBan.put("truong_phong_id", rs.getInt("truong_phong_id"));
                phongBan.put("truong_phong_ten", rs.getString("truong_phong_ten"));
                phongBan.put("truong_phong_avatar", rs.getString("truong_phong_avatar"));
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
    public Map<String, Integer> getThongKeCongViecTheoTrangThai(HttpSession session) throws SQLException {
        Map<String, Integer> thongKe = new HashMap<>();

        String vaiTro = (String) session.getAttribute("vaiTro");
        int truongPhongId = -1;
        Integer phongBanId = null;

        if ("Quản lý".equalsIgnoreCase(vaiTro)) {
            // Lấy ID người dùng từ session
            Object uidObj = session.getAttribute("userId");
            if (uidObj instanceof Integer) {
                truongPhongId = (Integer) uidObj;
            } else if (uidObj instanceof String) {
                truongPhongId = Integer.parseInt((String) uidObj);
            }

            // Truy vấn phòng ban mà người này là trưởng phòng
            String sqlPhong = "SELECT id FROM phong_ban WHERE truong_phong_id = ?";
            try (PreparedStatement stmt = cn.prepareStatement(sqlPhong)) {
                stmt.setInt(1, truongPhongId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        phongBanId = rs.getInt("id");
                    }
                }
            }
        }

        // Câu SQL chính
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT trang_thai, COUNT(*) as so_luong FROM cong_viec");

        if (phongBanId != null) {
            sql.append(" WHERE phong_ban_id = ?");
        }

        sql.append(" GROUP BY trang_thai");

        try (PreparedStatement stmt = cn.prepareStatement(sql.toString())) {
            if (phongBanId != null) {
                stmt.setInt(1, phongBanId);
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    thongKe.put(rs.getString("trang_thai"), rs.getInt("so_luong"));
                }
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

    // Phương thức lấy báo cáo theo tháng/năm (giữ nguyên để tương thích)
    public List<Map<String, Object>> getBaoCaoTongHopNhanVien(String thang, String nam, String phongBan) throws SQLException {
        // Xác định ngày đầu và cuối tháng
        int thangInt = Integer.parseInt(thang);
        int namInt = Integer.parseInt(nam);
        YearMonth ym = YearMonth.of(namInt, thangInt);
        LocalDate ngayDauThang = ym.atDay(1);
        LocalDate ngayCuoiThang = ym.atEndOfMonth();

        // Gọi phương thức mới với khoảng thời gian
        return getBaoCaoTongHopNhanVienByDateRange(
                java.sql.Date.valueOf(ngayDauThang).toString(),
                java.sql.Date.valueOf(ngayCuoiThang).toString(),
                phongBan
        );
    }

    // Phương thức mới: lấy báo cáo theo khoảng thời gian
    public List<Map<String, Object>> getBaoCaoTongHopNhanVienByDateRange(String tuNgay, String denNgay, String phongBan) throws SQLException {
        List<Map<String, Object>> baoCao = new ArrayList<>();

        StringBuilder sql = new StringBuilder();
        sql.append("""
        SELECT 
            nv.id,
            nv.avatar_url,
            nv.ho_ten,
            pb.ten_phong,

            COUNT(cv.id) AS so_task,

            -- Đã hoàn thành trong khoảng thời gian
            SUM(CASE 
                    WHEN cv.ngay_hoan_thanh BETWEEN ? AND ?
                    THEN 1 ELSE 0 END
            ) AS da_hoan_thanh,

            -- Đang thực hiện: đã tới ngày bắt đầu, chưa hoàn thành, chưa trễ hạn
            SUM(CASE 
                    WHEN cv.ngay_hoan_thanh IS NULL
                         AND cv.ngay_bat_dau <= ?
                         AND (cv.han_hoan_thanh IS NULL OR cv.han_hoan_thanh >= ?)
                    THEN 1 ELSE 0 END
            ) AS dang_thuc_hien,

            -- Trễ hạn: chưa hoàn thành & hạn < ngày kết thúc
            SUM(CASE 
                    WHEN cv.ngay_hoan_thanh IS NULL
                         AND cv.han_hoan_thanh IS NOT NULL
                         AND cv.han_hoan_thanh < ?
                    THEN 1 ELSE 0 END
            ) AS tre_han,

            -- Chưa bắt đầu: ngày bắt đầu > ngày kết thúc khoảng thời gian
            SUM(CASE
                    WHEN cv.ngay_bat_dau > ?
                    THEN 1 ELSE 0 END
            ) AS chua_bat_dau

        FROM nhanvien nv
        LEFT JOIN phong_ban pb ON nv.phong_ban_id = pb.id
        LEFT JOIN cong_viec_nguoi_nhan cvr ON nv.id = cvr.nhan_vien_id
        LEFT JOIN cong_viec cv ON cvr.cong_viec_id = cv.id
        WHERE nv.trang_thai_lam_viec = 'Đang làm'
          AND (nv.chuc_vu IS NULL OR nv.chuc_vu <> 'Giám đốc')
    """);

        // Danh sách tham số
        List<Object> params = new ArrayList<>();

        java.sql.Date sqlTuNgay = java.sql.Date.valueOf(tuNgay);
        java.sql.Date sqlDenNgay = java.sql.Date.valueOf(denNgay);

        // Gán đúng thứ tự các tham số ? trong SQL
        params.add(sqlTuNgay);   // 1 - đã hoàn thành: bắt đầu
        params.add(sqlDenNgay);  // 2 - đã hoàn thành: kết thúc
        params.add(sqlDenNgay);  // 3 - đang thực hiện: ngày bắt đầu <= denNgay
        params.add(sqlDenNgay);  // 4 - đang thực hiện: hạn >= denNgay
        params.add(sqlDenNgay);  // 5 - trễ hạn: hạn < denNgay
        params.add(sqlDenNgay);  // 6 - chưa bắt đầu: ngày bắt đầu > denNgay

        // Lọc phòng ban
        if (phongBan != null && !phongBan.trim().isEmpty()) {
            sql.append(" AND pb.id = ? ");
            params.add(Integer.parseInt(phongBan.trim()));
        }

        sql.append(" GROUP BY nv.id, nv.ho_ten, pb.ten_phong ");
        sql.append(" ORDER BY nv.ho_ten ");

        // Thực thi
        try (PreparedStatement stmt = cn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getInt("id"));
                    row.put("avatar_url", rs.getString("avatar_url"));
                    row.put("ho_ten", rs.getString("ho_ten"));
                    row.put("ten_phong", rs.getString("ten_phong"));
                    row.put("so_task", rs.getInt("so_task"));
                    row.put("da_hoan_thanh", rs.getInt("da_hoan_thanh"));
                    row.put("dang_thuc_hien", rs.getInt("dang_thuc_hien"));
                    row.put("tre_han", rs.getInt("tre_han"));
                    row.put("chua_bat_dau", rs.getInt("chua_bat_dau"));
                    baoCao.add(row);
                }
            }
        }

        return baoCao;
    }

    // Lấy dữ liệu cho chart pie về trạng thái công việc
    public Map<String, Object> getDataForPieChart2() throws SQLException {
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

    public Map<String, Object> getDataForPieChart(String tuNgay, String denNgay, String phongBan) throws SQLException {
        Map<String, Object> data = new HashMap<>();
        List<String> labels = new ArrayList<>();
        List<Integer> values = new ArrayList<>();

        StringBuilder sql = new StringBuilder("""
        SELECT
            SUM(CASE 
                    WHEN cv.ngay_hoan_thanh BETWEEN ? AND ? 
                    THEN 1 ELSE 0 END
            ) AS da_hoan_thanh,

            SUM(CASE
                    WHEN cv.ngay_hoan_thanh IS NULL
                         AND cv.ngay_bat_dau <= ?
                         AND (cv.han_hoan_thanh IS NULL OR cv.han_hoan_thanh >= ?)
                    THEN 1 ELSE 0 END
            ) AS dang_thuc_hien,

            SUM(CASE
                    WHEN cv.ngay_hoan_thanh IS NULL
                         AND cv.han_hoan_thanh IS NOT NULL
                         AND cv.han_hoan_thanh < ?
                    THEN 1 ELSE 0 END
            ) AS tre_han,

            SUM(CASE
                    WHEN cv.ngay_bat_dau > ?
                    THEN 1 ELSE 0 END
            ) AS chua_bat_dau
        FROM cong_viec cv
        WHERE 1 = 1
    """);

        List<Object> params = new ArrayList<>();
        java.sql.Date sqlTu = java.sql.Date.valueOf(tuNgay);
        java.sql.Date sqlDen = java.sql.Date.valueOf(denNgay);

        // Tham số cho 7 biến ? trong câu SQL trên
        params.add(sqlTu);   // 1
        params.add(sqlDen);  // 2
        params.add(sqlDen);  // 3
        params.add(sqlDen);  // 4
        params.add(sqlDen);  // 5
        params.add(sqlDen);  // 6

        // Lọc phòng ban
        if (phongBan != null && !phongBan.isEmpty()) {
            sql.append(" AND cv.phong_ban_id = ? ");
            params.add(Integer.parseInt(phongBan));
        }

        try (PreparedStatement stmt = cn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {

                    labels.add("Đã hoàn thành");
                    values.add(rs.getInt("da_hoan_thanh"));

                    labels.add("Đang thực hiện");
                    values.add(rs.getInt("dang_thuc_hien"));

                    labels.add("Trễ hạn");
                    values.add(rs.getInt("tre_han"));

                    labels.add("Chưa bắt đầu");
                    values.add(rs.getInt("chua_bat_dau"));
                }
            }
        }

        data.put("labels", labels);
        data.put("data", values);
        return data;
    }

    public Map<String, Object> getDataForBarChart(HttpSession session, String tuNgay, String denNgay, String phongBan) throws SQLException {

        Map<String, Object> data = new HashMap<>();
        List<String> labels = new ArrayList<>();
        List<Double> values = new ArrayList<>();

        String vaiTro = (String) session.getAttribute("vaiTro");
        Integer userId = null;
        try {
            userId = Integer.parseInt(session.getAttribute("userId").toString());
        } catch (Exception e) {
        }

        java.sql.Date sqlTu = java.sql.Date.valueOf(tuNgay);
        java.sql.Date sqlDen = java.sql.Date.valueOf(denNgay);

        StringBuilder sql = new StringBuilder();
        List<Object> params = new ArrayList<>();

        // =================================================================
        // 📌 TRƯỞNG PHÒNG – BAR CHART THEO NHÂN VIÊN
        // =================================================================
        if ("Quản lý".equalsIgnoreCase(vaiTro) && userId != null) {
            sql.append("""
            SELECT nv.ho_ten AS label,
                   ROUND(
                       100.0 * 
                       SUM(
                            CASE 
                                WHEN cv.ngay_hoan_thanh BETWEEN ? AND ? 
                                THEN 1 ELSE 0 
                            END
                       ) 
                       /
                       NULLIF(COUNT(cv.id), 0)
                   , 2) AS tien_do
            FROM cong_viec cv
            JOIN cong_viec_nguoi_nhan cvr ON cv.id = cvr.cong_viec_id
            JOIN nhanvien nv ON nv.id = cvr.nhan_vien_id
            JOIN phong_ban pb ON pb.id = nv.phong_ban_id
            WHERE pb.truong_phong_id = ?
              AND (
                    cv.ngay_bat_dau <= ? 
                 OR cv.ngay_hoan_thanh BETWEEN ? AND ?
              )
        """);

            // params
            params.add(sqlTu);
            params.add(sqlDen);
            params.add(userId);
            params.add(sqlDen);
            params.add(sqlTu);
            params.add(sqlDen);

            // lọc phòng ban (nếu truyền vào)
            if (phongBan != null && !phongBan.isEmpty()) {
                sql.append(" AND pb.id = ? ");
                params.add(Integer.parseInt(phongBan));
            }

            sql.append(" GROUP BY nv.id, nv.ho_ten ORDER BY nv.ho_ten ");

        } else {

            // =================================================================
            // 📌 ADMIN – BAR CHART THEO PHÒNG BAN
            // =================================================================
            sql.append("""
            SELECT pb.ten_phong AS label,
                   ROUND(
                       100.0 * 
                       SUM(
                            CASE 
                                WHEN cv.ngay_hoan_thanh BETWEEN ? AND ?
                                THEN 1 ELSE 0 
                            END
                       ) 
                       /
                       NULLIF(COUNT(cv.id), 0)
                   , 2) AS tien_do
            FROM cong_viec cv
            JOIN phong_ban pb ON pb.id = cv.phong_ban_id
            WHERE 
                cv.ngay_bat_dau <= ?
                OR cv.ngay_hoan_thanh BETWEEN ? AND ?
        """);

            params.add(sqlTu);
            params.add(sqlDen);
            params.add(sqlDen);
            params.add(sqlTu);
            params.add(sqlDen);

            if (phongBan != null && !phongBan.isEmpty()) {
                sql.append(" AND pb.id = ? ");
                params.add(Integer.parseInt(phongBan));
            }

            sql.append(" GROUP BY pb.id, pb.ten_phong ORDER BY pb.ten_phong ");
        }

        // =================================================================
        // 🌟 THỰC THI QUERY
        // =================================================================
        try (PreparedStatement stmt = cn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    labels.add(rs.getString("label"));
                    values.add(rs.getDouble("tien_do"));
                }
            }
        }

        data.put("labels", labels);
        data.put("data", values);
        return data;
    }

    // Lấy dữ liệu cho chart bar về tiến độ phòng ban
    public Map<String, Object> getDataForBarChart2(HttpSession session) throws SQLException {
        Map<String, Object> data = new HashMap<>();
        List<String> labels = new ArrayList<>();
        List<Double> values = new ArrayList<>();

        String vaiTro = (String) session.getAttribute("vaiTro");
        Integer userId = null;
        try {
            userId = Integer.parseInt(session.getAttribute("userId").toString());
        } catch (Exception e) {
            userId = null;
        }

        StringBuilder sql = new StringBuilder();
        List<Object> params = new ArrayList<>();

        if ("Quản lý".equalsIgnoreCase(vaiTro) && userId != null) {
            // Trưởng phòng: tiến độ trung bình theo nhân viên trong phòng
            sql.append("""
                SELECT 
                    nv.ho_ten AS ten_nhan_vien,
                    ROUND(AVG(COALESCE(cv_tiendo.max_tiendo, 0)), 2) AS tien_do
                FROM phong_ban pb
                JOIN nhanvien nv ON pb.id = nv.phong_ban_id
                LEFT JOIN cong_viec_nguoi_nhan cvr ON nv.id = cvr.nhan_vien_id
                LEFT JOIN (
                    SELECT cong_viec_id, MAX(phan_tram) AS max_tiendo
                    FROM cong_viec_tien_do
                    GROUP BY cong_viec_id
                ) cv_tiendo ON cvr.cong_viec_id = cv_tiendo.cong_viec_id
                WHERE pb.truong_phong_id = ?
                GROUP BY nv.id, nv.ho_ten
                ORDER BY nv.ho_ten
            """);
            params.add(userId);

        } else {
            // Admin hoặc vai trò khác: tiến độ trung bình theo phòng ban
            sql.append("""
                SELECT 
                    pb.ten_phong,
                    ROUND(AVG(cv_avg.max_tiendo), 2) AS tien_do
                FROM phong_ban pb
                LEFT JOIN (
                    SELECT 
                        cv.phong_ban_id,
                        MAX(ctd.phan_tram) AS max_tiendo
                    FROM cong_viec cv
                    LEFT JOIN cong_viec_tien_do ctd ON cv.id = ctd.cong_viec_id
                    GROUP BY cv.id, cv.phong_ban_id
                ) cv_avg ON pb.id = cv_avg.phong_ban_id
                GROUP BY pb.id, pb.ten_phong
                ORDER BY pb.ten_phong
            """);
        }

        try (PreparedStatement stmt = cn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    if ("Quản lý".equalsIgnoreCase(vaiTro)) {
                        labels.add(rs.getString("ten_nhan_vien"));
                    } else {
                        labels.add(rs.getString("ten_phong"));
                    }
                    values.add(rs.getDouble("tien_do"));
                }
            }
        }

        data.put("labels", labels);
        data.put("data", values);
        return data;
    }

    // Lấy cơ cấu nhân sự (số nhân viên theo phòng ban)
    public Map<String, Object> getNhanSuCoCau() throws SQLException {
        Map<String, Object> data = new HashMap<>();
        List<String> labels = new ArrayList<>();
        List<Integer> values = new ArrayList<>();

        String sql = "SELECT pb.ten_phong, COUNT(nv.id) AS so_nv "
                + "FROM phong_ban pb "
                + "LEFT JOIN nhanvien nv ON pb.id = nv.phong_ban_id "
                + "GROUP BY pb.id, pb.ten_phong "
                + "ORDER BY pb.ten_phong";

        try (PreparedStatement stmt = cn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                labels.add(rs.getString("ten_phong"));
                values.add(rs.getInt("so_nv"));
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
    public List<Map<String, Object>> getDanhSachChamCong(String thang, String nam, String phongBan, String keyword, String employeeId) throws SQLException {
        List<Map<String, Object>> danhSach = new ArrayList<>();
        StringBuilder sql = new StringBuilder();

        sql.append("SELECT cc.id, cc.nhan_vien_id, cc.ngay, cc.bao_cao, cc.check_in, cc.check_out, ");
        sql.append("nv.ho_ten, nv.avatar_url, nv.ngay_vao_lam, nv.luong_co_ban, ");
        sql.append("pb.ten_phong, ");

        // 🧮 Tính số giờ làm chính xác theo phút (giờ.lẻ)
        sql.append("CASE ");
        sql.append("  WHEN cc.check_in IS NULL OR cc.check_out IS NULL THEN 0 ");
        sql.append("  ELSE ROUND(TIMESTAMPDIFF(MINUTE, cc.check_in, cc.check_out) / 60, 2) ");
        sql.append("END AS so_gio_lam, ");

        // 🧠 Phân loại trạng thái chi tiết hơn
        sql.append("CASE ");
        // ✅ Ưu tiên WFH
        sql.append("  WHEN cc.loai_cham_cong = 'WFH' THEN 'WFH' ");
        // ✅ Nghỉ phép chỉ áp dụng khi không có check_in/check_out
        sql.append("  WHEN cc.check_in IS NULL AND cc.check_out IS NULL AND EXISTS ( ");
        sql.append("    SELECT 1 FROM don_nghi_phep dnp ");
        sql.append("    WHERE dnp.nhan_vien_id = cc.nhan_vien_id ");
        sql.append("    AND dnp.trang_thai = 'da_duyet' ");
        sql.append("    AND cc.ngay BETWEEN dnp.ngay_bat_dau AND dnp.ngay_ket_thuc ");
        sql.append("  ) THEN 'Nghỉ phép' ");
        // ✅ Nếu chưa có check_in
        sql.append("  WHEN cc.check_in IS NULL THEN 'Vắng mặt' ");
        // ✅ Nếu có check_in trước hoặc bằng 8h05 mà chưa check_out → Đúng giờ
        sql.append("  WHEN TIME(cc.check_in) <= '08:05:59' AND cc.check_out IS NULL THEN 'Đúng giờ' ");
        // ✅ Nếu check_in sau 8h05 mà chưa check_out → Đi trễ
        sql.append("  WHEN TIME(cc.check_in) > '08:05:59' AND cc.check_out IS NULL THEN 'Đi trễ' ");
        // ✅ Các trường hợp có đủ check_in và check_out
        sql.append("  WHEN TIME(cc.check_in) <= '08:05:59' AND TIME(cc.check_out) >= '17:00:00' THEN 'Đủ công' ");
        sql.append("  WHEN TIME(cc.check_in) <= '08:05:59' AND TIME(cc.check_out) < '17:00:00' THEN 'Thiếu giờ' ");
        sql.append("  WHEN TIME(cc.check_in) > '08:05:59' AND TIME(cc.check_out) >= '17:00:00' THEN 'Đi trễ' ");
        sql.append("  WHEN TIME(cc.check_in) > '08:05:59' AND TIME(cc.check_out) < '17:00:00' THEN 'Thiếu giờ' ");
        sql.append("  ELSE 'Thiếu dữ liệu' ");
        sql.append("END AS trang_thai ");

        sql.append("FROM cham_cong cc ");
        sql.append("LEFT JOIN nhanvien nv ON cc.nhan_vien_id = nv.id ");
        sql.append("LEFT JOIN phong_ban pb ON nv.phong_ban_id = pb.id ");
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        // 🗓️ Lọc theo tháng - năm
        if (thang != null && !thang.isEmpty() && nam != null && !nam.isEmpty()) {
            sql.append("AND MONTH(cc.ngay) = ? AND YEAR(cc.ngay) = ? ");
            params.add(Integer.parseInt(thang));
            params.add(Integer.parseInt(nam));
        }

        // 🏢 Lọc theo phòng ban
        if (phongBan != null && !phongBan.isEmpty()) {
            sql.append("AND pb.ten_phong = ? ");
            params.add(phongBan);
        }

        // 🔍 Lọc theo keyword (tìm tên hoặc email)
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (nv.ho_ten LIKE ? OR nv.email LIKE ?) ");
            params.add("%" + keyword + "%");
            params.add("%" + keyword + "%");
        }

        // 👤 Lọc theo ID nhân viên (nếu xuất file)
        if (employeeId != null && !employeeId.equals("all")) {
            sql.append("AND nv.id = ? ");
            params.add(Integer.parseInt(employeeId));
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
                    record.put("bao_cao", rs.getString("bao_cao"));
                    // 💰 Tính lương theo số giờ làm
                    double luongCoBan = rs.getDouble("luong_co_ban");
                    double soGioLam = rs.getDouble("so_gio_lam");
                    double luongNgay = (luongCoBan / 22) * (soGioLam / 8);
                    record.put("luong_ngay", Math.round(luongNgay * 100.0) / 100.0);

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
            // ✅ Ưu tiên WFH
            + "  WHEN loai_cham_cong = 'WFH' THEN 'WFH' "
            // ✅ Nghỉ phép chỉ khi không có check_in/check_out
            + "  WHEN check_in IS NULL AND check_out IS NULL AND EXISTS ( "
            + "    SELECT 1 FROM don_nghi_phep dnp "
            + "    WHERE dnp.nhan_vien_id = cham_cong.nhan_vien_id "
            + "    AND dnp.trang_thai = 'da_duyet' "
            + "    AND cham_cong.ngay BETWEEN dnp.ngay_bat_dau AND dnp.ngay_ket_thuc "
            + "  ) THEN 'Nghỉ phép' "
            + "  WHEN check_in IS NULL THEN 'Vắng mặt' "
            + "  WHEN TIME(check_in) <= '08:05:59' AND check_out IS NULL THEN 'Đúng giờ' "
            + "  WHEN TIME(check_in) > '08:05:59' AND check_out IS NULL THEN 'Đi trễ' "
            + "  WHEN TIME(check_in) <= '08:05:59' AND TIME(check_out) >= '17:00:00' THEN 'Đủ công' "
            + "  WHEN TIME(check_in) <= '08:05:59' AND TIME(check_out) < '17:00:00' THEN 'Thiếu giờ' "
            + "  WHEN TIME(check_in) > '08:05:59' AND TIME(check_out) >= '17:00:00' THEN 'Đi trễ' "
            + "  WHEN TIME(check_in) > '08:05:59' AND TIME(check_out) < '17:00:00' THEN 'Thiếu giờ' "
            + "  ELSE 'Thiếu dữ liệu' "
            + "END AS trang_thai "
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

        String sql = "SELECT id, ngay, check_in, check_out, bao_cao, "
            + "CASE "
            + "  WHEN check_in IS NULL OR check_out IS NULL THEN 0 "
            + "  ELSE ROUND(TIMESTAMPDIFF(MINUTE, check_in, check_out) / 60, 2) "
            + "END AS so_gio_lam, "
            + "CASE "
            + "  WHEN loai_cham_cong = 'WFH' THEN 'WFH' "
            + "  WHEN check_in IS NULL AND check_out IS NULL AND EXISTS ( "
            + "    SELECT 1 FROM don_nghi_phep dnp "
            + "    WHERE dnp.nhan_vien_id = cham_cong.nhan_vien_id "
            + "    AND dnp.trang_thai = 'da_duyet' "
            + "    AND cham_cong.ngay BETWEEN dnp.ngay_bat_dau AND dnp.ngay_ket_thuc "
            + "  ) THEN 'Nghỉ phép' "
            + "  WHEN check_in IS NULL THEN 'Vắng mặt' "
            + "  WHEN TIME(check_in) <= '08:05:59' AND check_out IS NULL THEN 'Đúng giờ' "
            + "  WHEN TIME(check_in) > '08:05:59' AND check_out IS NULL THEN 'Đi trễ' "
            + "  WHEN TIME(check_in) <= '08:05:59' AND TIME(check_out) >= '17:00:00' THEN 'Đủ công' "
            + "  WHEN TIME(check_in) <= '08:05:59' AND TIME(check_out) < '17:00:00' THEN 'Thiếu giờ' "
            + "  WHEN TIME(check_in) > '08:05:59' AND TIME(check_out) >= '17:00:00' THEN 'Đi trễ' "
            + "  WHEN TIME(check_in) > '08:05:59' AND TIME(check_out) < '17:00:00' THEN 'Thiếu giờ' "
            + "  ELSE 'Thiếu dữ liệu' "
            + "END AS trang_thai "
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
                    record.put("id", rs.getInt("id"));
                    record.put("ngay", rs.getDate("ngay"));
                    record.put("check_in", rs.getTime("check_in"));
                    record.put("check_out", rs.getTime("check_out"));
                    record.put("so_gio_lam", rs.getDouble("so_gio_lam"));
                    record.put("trang_thai", rs.getString("trang_thai"));
                    record.put("bao_cao", rs.getString("bao_cao"));
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
        // Kiểm tra đã check-in hôm nay chưa và có phải WFH không
        String checkSql = "SELECT loai_cham_cong FROM cham_cong WHERE nhan_vien_id = ? AND ngay = CURDATE() LIMIT 1";
        boolean exists = false;
        boolean isWFH = false;

        try (PreparedStatement checkStmt = cn.prepareStatement(checkSql)) {
            checkStmt.setInt(1, nhanVienId);
            try (ResultSet rs = checkStmt.executeQuery()) {
                if (rs.next()) {
                    exists = true;
                    String loaiChamCong = rs.getString("loai_cham_cong");
                    isWFH = "WFH".equalsIgnoreCase(loaiChamCong);
                }
            }
        }

        // Nếu đã check-in WFH thì không cho check-in thường
        if (isWFH) {
            return false;
        }

        String sql;
        if (exists) {
            // Cập nhật check-in, đánh dấu loai_cham_cong = 'office'
            sql = "UPDATE cham_cong SET check_in = CURRENT_TIME, loai_cham_cong = 'office' "
                    + "WHERE nhan_vien_id = ? AND ngay = CURDATE()";
        } else {
            // Tạo record mới với loai_cham_cong = 'office'
            sql = "INSERT INTO cham_cong (nhan_vien_id, ngay, check_in, loai_cham_cong) VALUES (?, CURDATE(), CURRENT_TIME, 'office')";
        }

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nhanVienId);
            return stmt.executeUpdate() > 0;
        }
    }

    // Check-in WFH
    public boolean checkInWFH(int nhanVienId) throws SQLException {
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
            // Cập nhật check-in WFH, reset check_out, đánh dấu loai_cham_cong = 'WFH'
            sql = "UPDATE cham_cong SET check_in = CURRENT_TIME, check_out = NULL, loai_cham_cong = 'WFH' "
                    + "WHERE nhan_vien_id = ? AND ngay = CURDATE()";
        } else {
            // Tạo record mới với loai_cham_cong = 'WFH'
            sql = "INSERT INTO cham_cong (nhan_vien_id, ngay, check_in, loai_cham_cong) VALUES (?, CURDATE(), CURRENT_TIME, 'WFH')";
        }

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nhanVienId);
            return stmt.executeUpdate() > 0;
        }
    }

    // Check-out
    public boolean checkOut(int nhanVienId) throws SQLException {
        String sql = "UPDATE cham_cong SET check_out = CURRENT_TIME "
                + "WHERE nhan_vien_id = ? AND ngay = CURDATE() AND check_in IS NOT NULL "
                + "AND (loai_cham_cong IS NULL OR loai_cham_cong <> 'WFH')";

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

        // 1. Điểm KPI trung bình
        String sql1 = """
        SELECT AVG(diem_kpi) AS diem_tb, COUNT(*) AS so_chi_tieu
        FROM luu_kpi
        WHERE nhan_vien_id = ? AND thang = ? AND nam = ?
    """;

        // 2. Số công việc hoàn thành trong tháng
        String sql2 = """
        SELECT COUNT(cv.id) AS cong_viec_hoan_thanh
        FROM cong_viec cv
        JOIN cong_viec_nguoi_nhan cvr ON cv.id = cvr.cong_viec_id
        WHERE cvr.nhan_vien_id = ?
          AND cv.trang_thai = 'Đã hoàn thành'
          AND MONTH(cv.ngay_tao) = ?
          AND YEAR(cv.ngay_tao) = ?
    """;

        try (
                PreparedStatement stmt1 = cn.prepareStatement(sql1); PreparedStatement stmt2 = cn.prepareStatement(sql2)) {
            // KPI
            stmt1.setInt(1, nhanVienId);
            stmt1.setInt(2, thang);
            stmt1.setInt(3, nam);
            try (ResultSet rs1 = stmt1.executeQuery()) {
                if (rs1.next()) {
                    tongHop.put("diem_kpi_trung_binh", rs1.getDouble("diem_tb"));
                    tongHop.put("so_chi_tieu", rs1.getInt("so_chi_tieu"));
                }
            }

            // Công việc
            stmt2.setInt(1, nhanVienId);
            stmt2.setInt(2, thang);
            stmt2.setInt(3, nam);
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
        if (email == null || email.trim().isEmpty()) {
            return false;
        }

        String sql = "SELECT mat_khau FROM nhanvien WHERE email = ?";
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return false;
                }
                String mkDb = rs.getString("mat_khau");
                // BCrypt: return BCrypt.checkpw(oldPass, mkDb);
                return mkDb != null && mkDb.equals(oldPass);
            }
        }
    }

    public int capNhatMatKhau(String email, String newPass) throws SQLException {
        if (email == null || email.trim().isEmpty()) {
            return 0;
        }

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
        if (email == null || email.trim().isEmpty()) {
            return false;
        }

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
            try {
                cn.rollback();
            } catch (SQLException ignore) {
            }
            throw ex;
        } finally {
            try {
                cn.setAutoCommit(oldAutoCommit);
            } catch (SQLException ignore) {
            }
        }
    }

    // ============ PHƯƠNG THỨC BỔ SUNG CHO DASHBOARD ============
    // Lấy thống kê tổng quan hệ thống
    public Map<String, Object> getThongKeTongQuan(HttpSession session) throws SQLException {
        Map<String, Object> thongKe = new HashMap<>();

        String vaiTro = (String) session.getAttribute("vaiTro");
        String idStr = (String) session.getAttribute("userId");
        Integer userId = Integer.parseInt(idStr);

        Integer phongBanId = null;

        // Nếu là quản lý thì tìm phòng ban mà họ làm trưởng phòng
        if ("Quản lý".equalsIgnoreCase(vaiTro) && userId != null) {
            String sqlPhongBan = "SELECT id FROM phong_ban WHERE truong_phong_id = ?";
            try (PreparedStatement stmt = cn.prepareStatement(sqlPhongBan)) {
                stmt.setInt(1, userId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        phongBanId = rs.getInt("id");
                    }
                }
            }
        }

        // 1. Thống kê trạng thái nhân viên
        StringBuilder sql1 = new StringBuilder("SELECT trang_thai_lam_viec, COUNT(*) as so_luong FROM nhanvien");
        if (phongBanId != null) {
            sql1.append(" WHERE phong_ban_id = ").append(phongBanId);
        }
        sql1.append(" GROUP BY trang_thai_lam_viec");

        int totalNV = 0, dangLam = 0, tamNghi = 0, nghiViec = 0;
        try (PreparedStatement stmt = cn.prepareStatement(sql1.toString()); ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                String st = rs.getString("trang_thai_lam_viec");
                int count = rs.getInt("so_luong");
                totalNV += count;
                if ("Đang làm".equalsIgnoreCase(st)) {
                    dangLam = count;
                } else if ("Tạm nghỉ".equalsIgnoreCase(st)) {
                    tamNghi = count;
                } else if ("Nghỉ việc".equalsIgnoreCase(st) || "Đã nghỉ".equalsIgnoreCase(st)) {
                    nghiViec = count;
                }
            }
        }
        thongKe.put("tong_nhan_vien", totalNV);
        thongKe.put("nv_dang_lam", dangLam);
        thongKe.put("nv_tam_nghi", tamNghi);
        thongKe.put("nv_nghi_viec", nghiViec);

        // 2. Tổng số phòng ban (chỉ Admin mới lấy toàn bộ)
        if ("Admin".equalsIgnoreCase(vaiTro)) {
            String sql2 = "SELECT COUNT(*) as tong FROM phong_ban";
            try (PreparedStatement stmt = cn.prepareStatement(sql2); ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    thongKe.put("tong_phong_ban", rs.getInt("tong"));
                }
            }
        } else {
            thongKe.put("tong_phong_ban", 1);  // Chỉ 1 phòng ban quản lý phụ trách
        }

        // 3. Tổng số công việc
        String sql3 = """
        SELECT COUNT(DISTINCT cv.id) as tong
        FROM cong_viec cv
        JOIN cong_viec_nguoi_nhan cvr ON cv.id = cvr.cong_viec_id
        JOIN nhanvien nv ON cvr.nhan_vien_id = nv.id
    """;
        if (phongBanId != null) {
            sql3 += " WHERE nv.phong_ban_id = ?";
        }
        try (PreparedStatement stmt = cn.prepareStatement(sql3)) {
            if (phongBanId != null) {
                stmt.setInt(1, phongBanId);
            }
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    thongKe.put("tong_cong_viec", rs.getInt("tong"));
                }
            }
        }

        // 4. Tỷ lệ công việc hoàn thành
        String sql4 = """
    SELECT COUNT(*) as tong_cv,
           SUM(CASE WHEN trang_thai = 'Đã hoàn thành' THEN 1 ELSE 0 END) as hoan_thanh
    FROM (
        SELECT cv.id, cv.trang_thai
        FROM cong_viec cv
        JOIN cong_viec_nguoi_nhan cvr ON cv.id = cvr.cong_viec_id
        JOIN nhanvien nv ON cvr.nhan_vien_id = nv.id
        /**WHERE_COND**/
        GROUP BY cv.id, cv.trang_thai
    ) t
""";

        if (phongBanId != null) {
            sql4 = sql4.replace("/**WHERE_COND**/", "WHERE nv.phong_ban_id = ?");
        } else {
            sql4 = sql4.replace("/**WHERE_COND**/", "");
        }

        try (PreparedStatement stmt = cn.prepareStatement(sql4)) {
            if (phongBanId != null) {
                stmt.setInt(1, phongBanId);
            }
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    int tong = rs.getInt("tong_cv");
                    int hoanThanh = rs.getInt("hoan_thanh");
                    double tyLe = tong > 0 ? (hoanThanh * 100.0 / tong) : 0;
                    thongKe.put("ty_le_hoan_thanh", Math.round(tyLe * 10) / 10.0);
                }
            }
        }

        return thongKe;
    }

    // Thống kê chấm công toàn bộ (loại trừ Admin / Quản lý / Trưởng phòng)
    public Map<String, Object> getThongKeChamCongNhanVienThuong(int thang, int nam) throws SQLException {
        Map<String, Object> tk = new HashMap<>();
        String base = " FROM cham_cong cc INNER JOIN nhanvien nv ON cc.nhan_vien_id = nv.id "
                + "WHERE MONTH(cc.ngay) = ? AND YEAR(cc.ngay) = ? "
                + "AND (nv.vai_tro IS NULL OR nv.vai_tro NOT IN ('Admin','Quản lý')) "
                + "AND (nv.chuc_vu IS NULL OR nv.chuc_vu <> 'Trưởng phòng')";

        String sqlTotal = "SELECT COUNT(*) AS tong_luot" + base;
        String sqlLate = "SELECT COUNT(*) AS di_muon" + base + " AND cc.check_in > '08:30:00'";
        String sqlDistinctNV = "SELECT COUNT(DISTINCT nv.id) AS so_nv" + base;

        int tongLuot = 0, diMuon = 0, soNV = 0;
        try (PreparedStatement stmt = cn.prepareStatement(sqlTotal)) {
            stmt.setInt(1, thang);
            stmt.setInt(2, nam);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    tongLuot = rs.getInt("tong_luot");
                }
            }
        }
        try (PreparedStatement stmt = cn.prepareStatement(sqlLate)) {
            stmt.setInt(1, thang);
            stmt.setInt(2, nam);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    diMuon = rs.getInt("di_muon");
                }
            }
        }
        try (PreparedStatement stmt = cn.prepareStatement(sqlDistinctNV)) {
            stmt.setInt(1, thang);
            stmt.setInt(2, nam);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    soNV = rs.getInt("so_nv");
                }
            }
        }
        int dungGio = tongLuot - diMuon;
        double tyLeMuon = tongLuot > 0 ? (diMuon * 100.0 / tongLuot) : 0;
        tk.put("tong_luot", tongLuot);
        tk.put("di_muon", diMuon);
        tk.put("dung_gio", dungGio);
        tk.put("so_nv", soNV);
        tk.put("ty_le_di_muon", Math.round(tyLeMuon * 10) / 10.0);
        return tk;
    }

    // Thống kê chấm công theo từng ngày trong tháng (nhân viên thường)
    public Map<String, Object> getChamCongTheoNgayNhanVienThuong(int thang, int nam) throws SQLException {
        Map<String, Object> data = new HashMap<>();
        List<Integer> days = new ArrayList<>();
        List<Integer> duCong = new ArrayList<>();
        List<Integer> diMuon = new ArrayList<>();
        List<Integer> thieuGio = new ArrayList<>();
        List<Integer> vang = new ArrayList<>();
        List<Integer> lamThem = new ArrayList<>(); // tạm thời 0 nếu chưa xác định OT/WFH

        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.YEAR, nam);
        cal.set(Calendar.MONTH, thang - 1);
        int maxDay = cal.getActualMaximum(Calendar.DAY_OF_MONTH);
        for (int d = 1; d <= maxDay; d++) {
            days.add(d);
            duCong.add(0);
            diMuon.add(0);
            thieuGio.add(0);
            vang.add(0);
            lamThem.add(0);
        }

        String sql = "SELECT DAY(cc.ngay) AS d, "
                + "SUM(CASE WHEN cc.check_in IS NOT NULL AND cc.check_out IS NOT NULL "
                + "AND cc.check_in <= '08:30:00' AND TIMESTAMPDIFF(HOUR, cc.check_in, cc.check_out) >= 8 THEN 1 ELSE 0 END) AS du_cong, "
                + "SUM(CASE WHEN cc.check_in > '08:30:00' THEN 1 ELSE 0 END) AS di_muon, "
                + "SUM(CASE WHEN cc.check_in IS NOT NULL AND cc.check_out IS NOT NULL "
                + "AND TIMESTAMPDIFF(HOUR, cc.check_in, cc.check_out) < 8 AND cc.check_in <= '08:30:00' THEN 1 ELSE 0 END) AS thieu_gio, "
                + "SUM(CASE WHEN cc.check_in IS NULL THEN 1 ELSE 0 END) AS vang "
                + "FROM cham_cong cc INNER JOIN nhanvien nv ON cc.nhan_vien_id = nv.id "
                + "WHERE MONTH(cc.ngay) = ? AND YEAR(cc.ngay) = ? "
                + "AND (nv.vai_tro IS NULL OR nv.vai_tro NOT IN ('Admin','Quản lý')) "
                + "AND (nv.chuc_vu IS NULL OR nv.chuc_vu <> 'Trưởng phòng') "
                + "GROUP BY d ORDER BY d";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, thang);
            stmt.setInt(2, nam);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    int d = rs.getInt("d");
                    int idx = d - 1;
                    if (idx >= 0 && idx < maxDay) {
                        duCong.set(idx, rs.getInt("du_cong"));
                        diMuon.set(idx, rs.getInt("di_muon"));
                        thieuGio.set(idx, rs.getInt("thieu_gio"));
                        vang.set(idx, rs.getInt("vang"));
                    }
                }
            }
        }

        data.put("days", days);
        data.put("du_cong", duCong);
        data.put("di_muon", diMuon);
        data.put("thieu_gio", thieuGio);
        data.put("vang", vang);
        data.put("lam_them", lamThem); // placeholder
        return data;
    }

    // Lấy thống kê công việc theo nhân viên
    public Map<String, Integer> getThongKeCongViecTheoNhanVien(int nhanVienId) throws SQLException {
        Map<String, Integer> thongKe = new HashMap<>();

        // Khởi tạo giá trị mặc định
        thongKe.put("Chưa bắt đầu", 0);
        thongKe.put("Đang thực hiện", 0);
        thongKe.put("Đã hoàn thành", 0);
        thongKe.put("Trễ hạn", 0);

        String sql = "SELECT cv.trang_thai, COUNT(*) as so_luong "
                + "FROM cong_viec_nguoi_nhan cn "
                + "JOIN cong_viec cv ON cn.cong_viec_id = cv.id "
                + "WHERE cn.nhan_vien_id = ? "
                + "GROUP BY cv.trang_thai";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nhanVienId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    thongKe.put(rs.getString("trang_thai"), rs.getInt("so_luong"));
                }
            }
        }

        return thongKe;
    }

    // Lấy danh sách công việc sắp đến hạn
    public List<Map<String, Object>> getCongViecSapDenHan(int nhanVienId, int soNgay) throws SQLException {
        List<Map<String, Object>> danhSach = new ArrayList<>();

        String sql = "SELECT cv.id, cv.ten_cong_viec, cv.han_hoan_thanh, cv.muc_do_uu_tien, "
                + "nv.ho_ten AS nguoi_giao_ten "
                + "FROM cong_viec_nguoi_nhan cn "
                + "JOIN cong_viec cv ON cn.cong_viec_id = cv.id "
                + "LEFT JOIN nhanvien nv ON cv.nguoi_giao_id = nv.id "
                + "WHERE cn.nhan_vien_id = ? "
                + "AND cv.trang_thai NOT IN ('Đã hoàn thành', 'Trễ hạn') "
                + "AND cv.han_hoan_thanh BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL ? DAY) "
                + "ORDER BY cv.han_hoan_thanh ASC";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nhanVienId);
            stmt.setInt(2, soNgay);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> congViec = new HashMap<>();
                    congViec.put("id", rs.getInt("id"));
                    congViec.put("ten_cong_viec", rs.getString("ten_cong_viec"));
                    congViec.put("han_hoan_thanh", rs.getDate("han_hoan_thanh"));
                    congViec.put("muc_do_uu_tien", rs.getString("muc_do_uu_tien"));
                    congViec.put("nguoi_giao_ten", rs.getString("nguoi_giao_ten"));
                    danhSach.add(congViec);
                }
            }
        }

        return danhSach;
    }

    // Lấy số thông báo chưa đọc
    public int getSoThongBaoChuaDoc(int nhanVienId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM thong_bao WHERE nguoi_nhan_id = ? AND da_doc = FALSE";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nhanVienId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return 0;
    }

    // Lấy thống kê phòng ban theo ID
    public Map<String, Object> getThongKePhongBanById(int phongBanId) throws SQLException {
        Map<String, Object> thongKe = new HashMap<>();

        if (phongBanId <= 0) {
            return thongKe;
        }

        // Thông tin cơ bản phòng ban
        String sql1 = "SELECT pb.ten_phong, nv.ho_ten as truong_phong_ten "
                + "FROM phong_ban pb "
                + "LEFT JOIN nhanvien nv ON pb.truong_phong_id = nv.id "
                + "WHERE pb.id = ?";

        try (PreparedStatement stmt = cn.prepareStatement(sql1)) {
            stmt.setInt(1, phongBanId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    thongKe.put("ten_phong", rs.getString("ten_phong"));
                    thongKe.put("truong_phong_ten", rs.getString("truong_phong_ten"));
                }
            }
        }

        // Số nhân viên trong phòng ban
        String sql2 = "SELECT COUNT(*) as so_nv FROM nhanvien "
                + "WHERE phong_ban_id = ? AND trang_thai_lam_viec = 'Đang làm'";

        try (PreparedStatement stmt = cn.prepareStatement(sql2)) {
            stmt.setInt(1, phongBanId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    thongKe.put("so_nhan_vien", rs.getInt("so_nv"));
                }
            }
        }

        // Số công việc của phòng ban
        String sql3 = "SELECT COUNT(*) as so_cv FROM cong_viec WHERE phong_ban_id = ?";

        try (PreparedStatement stmt = cn.prepareStatement(sql3)) {
            stmt.setInt(1, phongBanId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    thongKe.put("so_cong_viec", rs.getInt("so_cv"));
                }
            }
        }

        return thongKe;
    }

    public List<Map<String, Object>> getDanhSachThongBao(Integer nguoiNhanId, Integer limit, Integer offset) throws SQLException {
        List<Map<String, Object>> ds = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT id, tieu_de, noi_dung, nguoi_nhan_id, duong_dan, loai_thong_bao, da_doc, ngay_tao "
                + "FROM thong_bao "
        );
        List<Object> params = new ArrayList<>();

        if (nguoiNhanId != null && nguoiNhanId > 0) {
            sql.append("WHERE nguoi_nhan_id = ? ");
            params.add(nguoiNhanId);
        }

        sql.append("ORDER BY ngay_tao DESC ");

        if (limit != null && limit > 0) {
            sql.append("LIMIT ? ");
            params.add(limit);
        }
        if (offset != null && offset >= 0) {
            sql.append("OFFSET ? ");
            params.add(offset);
        }

        try (PreparedStatement ps = cn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getInt("id"));
                    row.put("tieu_de", rs.getString("tieu_de"));
                    row.put("noi_dung", rs.getString("noi_dung"));
                    row.put("nguoi_nhan_id", rs.getInt("nguoi_nhan_id"));
                    row.put("loai_thong_bao", rs.getString("loai_thong_bao"));
                    row.put("duong_dan", rs.getString("duong_dan"));
                    row.put("da_doc", rs.getBoolean("da_doc"));
                    row.put("ngay_tao", rs.getTimestamp("ngay_tao"));
                    ds.add(row);
                }
            }
        }
        return ds;
    }

    // Đánh dấu đã đọc 1 thông báo
    public int markThongBaoDaDoc(int tbId, Integer userId) throws SQLException {
        String sql = "UPDATE thong_bao SET da_doc = 1, ngay_doc = NOW() WHERE id = ?"
                + (userId != null ? " AND nguoi_nhan_id = ?" : "");
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, tbId);
            if (userId != null) {
                ps.setInt(2, userId);
            }
            return ps.executeUpdate();
        }
    }

// Đếm số thông báo chưa đọc cho 1 người
    public int getSoThongBaoChuaDoc(Integer userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM thong_bao WHERE da_doc = 0"
                + (userId != null ? " AND nguoi_nhan_id = ?" : "");
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            if (userId != null) {
                ps.setInt(1, userId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    public int insertThongBao(int nguoiNhanId, String tieuDe, String noiDung, String loai, String duongDan) throws SQLException {
        String sql = "INSERT INTO thong_bao (tieu_de, noi_dung, nguoi_nhan_id, loai_thong_bao, duong_dan, da_doc, ngay_doc, ngay_tao) "
                + "VALUES (?, ?, ?, ?, ?, 0, NOW(), NOW())";

        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, tieuDe);
            ps.setString(2, noiDung);
            ps.setInt(3, nguoiNhanId);
            ps.setString(4, loai);
            ps.setString(5, duongDan);
            return ps.executeUpdate();
        }
    }

    /**
     * Lấy danh sách ID nhân viên theo chức vụ
     *
     * @param chucVu Chức vụ cần lọc (VD: "Giám đốc", "Trưởng phòng")
     * @return Danh sách ID nhân viên
     */
    public List<Integer> getNhanVienIdsByChucVu(String chucVu) throws SQLException {
        List<Integer> ids = new ArrayList<>();
        String sql = "SELECT id FROM nhanvien WHERE chuc_vu = ? AND trang_thai_lam_viec = 'Đang làm'";

        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, chucVu);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ids.add(rs.getInt("id"));
                }
            }
        }
        return ids;
    }

    /**
     * Lấy danh sách ID nhân viên có chức vụ Giám đốc hoặc Trưởng phòng
     *
     * @return Danh sách ID nhân viên
     */
    public List<Integer> getNhanVienGiamDocVaTruongPhong() throws SQLException {
        List<Integer> ids = new ArrayList<>();
        String sql = "SELECT id FROM nhanvien WHERE chuc_vu IN ('Giám đốc', 'Trưởng phòng') AND trang_thai_lam_viec = 'Đang làm'";

        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ids.add(rs.getInt("id"));
                }
            }
        }
        return ids;
    }

    public List<Integer> getDanhSachNguoiNhanId(int congViecId) throws SQLException {
        List<Integer> ids = new ArrayList<>();
        String sql = "SELECT nhan_vien_id FROM cong_viec_nguoi_nhan WHERE cong_viec_id = ?";
        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, congViecId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    ids.add(rs.getInt("nhan_vien_id"));
                }
            }
        }
        return ids;
    }

    // Lấy ID trưởng phòng theo TÊN phòng ban (trả về null nếu không có/không đặt trưởng phòng)
    public Integer getTruongPhongIdByTenPhong(String tenPhong) throws SQLException {
        if (tenPhong == null) {
            return null;
        }
        String sql = "SELECT truong_phong_id FROM phong_ban WHERE ten_phong = ? LIMIT 1";
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, tenPhong.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    // getObject để nhận được null nếu chưa có trưởng phòng
                    return (Integer) rs.getObject(1);
                }
            }
        }
        return null;
    }

//    public Integer getNguoiNhanIdByCongVI(int congViecId) throws SQLException {
//        String sql = "SELECT nguoi_nhan_id FROM cong_viec WHERE id = ? LIMIT 1";
//        try (PreparedStatement ps = cn.prepareStatement(sql)) {
//            ps.setInt(1, congViecId);
//            try (ResultSet rs = ps.executeQuery()) {
//                if (rs.next()) {
//                    return (Integer) rs.getObject(1);
//                }
//            }
//        }
//        return null;
//    }
    public Integer getCongViecIdByBuocId(int buocId) throws SQLException {
        String sql = "SELECT cong_viec_id FROM cong_viec_quy_trinh WHERE id = ? LIMIT 1";
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, buocId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return (Integer) rs.getObject(1);
                }
            }
        }
        return null;
    }

    public int getGiamDocId() throws SQLException {
        String sql = "SELECT id FROM nhanvien WHERE chuc_vu = 'Giám đốc' LIMIT 1";
        try (PreparedStatement ps = cn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("id");
            }
        }
        return -1;
    }

    public boolean xoaChamCongTheoId(int id) throws SQLException {
        String sql = "DELETE FROM cham_cong WHERE id = ?";
        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean capNhatChamCong(int id, String checkIn, String checkOut) throws SQLException {
        String sql = "UPDATE cham_cong SET check_in = ?, check_out = ? WHERE id = ?";
        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setString(1, checkIn);
            stmt.setString(2, checkOut);
            stmt.setInt(3, id);  // Chỉ có 3 tham số, index cuối là 3
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean themChamCong(int nhanVienId, String ngay, String checkIn, String checkOut) throws SQLException {
        // Kiểm tra xem đã tồn tại bản ghi
        String checkSql = "SELECT COUNT(*) FROM cham_cong WHERE nhan_vien_id = ? AND ngay = ?";
        try (PreparedStatement checkStmt = cn.prepareStatement(checkSql)) {
            checkStmt.setInt(1, nhanVienId);
            checkStmt.setString(2, ngay);
            ResultSet rs = checkStmt.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                return false; // đã tồn tại
            }
        }

        // Chỉ thêm 5 cột: nhan_vien_id, ngay, check_in, check_out
        String sql = "INSERT INTO cham_cong (nhan_vien_id, ngay, check_in, check_out) VALUES (?, ?, ?, ?)";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nhanVienId);
            stmt.setString(2, ngay);
            stmt.setString(3, checkIn);
            stmt.setString(4, checkOut);
            return stmt.executeUpdate() > 0;
        }
    }

    // Overload themChamCong với tham số trạng thái
    public boolean themChamCong(int nhanVienId, String ngay, String checkIn, String checkOut, String trangThai) throws SQLException {
        // Kiểm tra xem đã tồn tại bản ghi
        String checkSql = "SELECT COUNT(*) FROM cham_cong WHERE nhan_vien_id = ? AND ngay = ?";
        try (PreparedStatement checkStmt = cn.prepareStatement(checkSql)) {
            checkStmt.setInt(1, nhanVienId);
            checkStmt.setString(2, ngay);
            ResultSet rs = checkStmt.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                return false; // đã tồn tại
            }
        }

        String sql;
        if ("WFH".equals(trangThai)) {
            // Nếu là WFH, lưu check_in và loai_cham_cong = 'WFH', không cần check_out
            sql = "INSERT INTO cham_cong (nhan_vien_id, ngay, check_in, loai_cham_cong) VALUES (?, ?, CURRENT_TIME, 'WFH')";
        } else {
            // Bình thường: thêm check_in, check_out, và loai_cham_cong = 'office'
            sql = "INSERT INTO cham_cong (nhan_vien_id, ngay, check_in, check_out, loai_cham_cong) VALUES (?, ?, ?, ?, 'office')";
        }

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nhanVienId);
            stmt.setString(2, ngay);
            
            if (!("WFH".equals(trangThai))) {
                stmt.setString(3, checkIn);
                stmt.setString(4, checkOut);
            }
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    /**
     * Thêm bản ghi chấm công cho ngày nghỉ phép (check_in và check_out là NULL để đánh dấu nghỉ phép)
     */
    public boolean themChamCongNghiPhep(int nhanVienId, Date ngayNghi) throws SQLException {
        // Kiểm tra xem đã tồn tại bản ghi chấm công trong ngày chưa
        String checkSql = "SELECT COUNT(*) FROM cham_cong WHERE nhan_vien_id = ? AND ngay = ?";
        try (PreparedStatement checkStmt = cn.prepareStatement(checkSql)) {
            checkStmt.setInt(1, nhanVienId);
            checkStmt.setDate(2, ngayNghi);
            ResultSet rs = checkStmt.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                return true; // Đã có bản ghi, không cần thêm nữa
            }
        }
        
        // Thêm bản ghi chấm công với check_in và check_out = NULL để đánh dấu nghỉ phép
        String sql = "INSERT INTO cham_cong (nhan_vien_id, ngay, check_in, check_out) VALUES (?, ?, NULL, NULL)";
        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nhanVienId);
            stmt.setDate(2, ngayNghi);
            return stmt.executeUpdate() > 0;
        }
    }
    
    /**
     * Tự động tạo các bản ghi chấm công cho tất cả ngày trong khoảng nghỉ phép
     * (không bao gồm cuối tuần và ngày lễ)
     */
    public void taoChamCongChoNgayNghiPhep(int nhanVienId, Date ngayBatDau, Date ngayKetThuc) throws SQLException {
        Calendar cal = Calendar.getInstance();
        cal.setTime(new java.util.Date(ngayBatDau.getTime()));
        
        Date ngayKT = ngayKetThuc;
        
        while (!cal.getTime().after(new java.util.Date(ngayKT.getTime()))) {
            Date ngayHienTai = new Date(cal.getTimeInMillis());
            
            // Bỏ qua cuối tuần (thứ 7, chủ nhật)
            int dayOfWeek = cal.get(Calendar.DAY_OF_WEEK);
            if (dayOfWeek != Calendar.SATURDAY && dayOfWeek != Calendar.SUNDAY) {
                // Bỏ qua ngày lễ
                if (!isNgayNghiLe(ngayHienTai)) {
                    themChamCongNghiPhep(nhanVienId, ngayHienTai);
                }
            }
            
            // Chuyển sang ngày tiếp theo
            cal.add(Calendar.DAY_OF_MONTH, 1);
        }
    }

    public List<String> getDanhSachTaiLieuByTaskId(int taskId) throws SQLException {
        List<String> list = new ArrayList<>();
        String sql = "SELECT file_tai_lieu FROM cong_viec WHERE id = ?";
        PreparedStatement ps = cn.prepareStatement(sql);
        ps.setInt(1, taskId);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            String raw = rs.getString("file_tai_lieu");
            if (raw != null && !raw.trim().isEmpty()) {
                String[] files = raw.split(";");
                for (String f : files) {
                    if (!f.trim().isEmpty()) {
                        list.add(f.trim());
                    }
                }
            }
        }

        rs.close();
        ps.close();
        return list;
    }

    public void capNhatTaiLieuCongViec(int taskId, List<String> dsFileConLai) throws SQLException {
        String newValue = String.join(";", dsFileConLai);
        String sql = "UPDATE cong_viec SET file_tai_lieu = ? WHERE id = ?";
        PreparedStatement ps = cn.prepareStatement(sql);
        ps.setString(1, newValue);
        ps.setInt(2, taskId);
        ps.executeUpdate();
        ps.close();
    }

    public String getFileCongViec(int taskId) throws SQLException {
        String files = null;
        String sql = "SELECT file_tai_lieu FROM cong_viec WHERE id = ?";

        try (PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, taskId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    files = rs.getString("file_tai_lieu");
                }
            }
        }
        return files;
    }

    public void updateFileCongViec(int taskId, String fileFinal) throws SQLException {
        String sql = "UPDATE cong_viec SET file_tai_lieu = ? WHERE id = ?";
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, fileFinal);
            ps.setInt(2, taskId);
            ps.executeUpdate();
        }
    }

    public List<Map<String, Object>> getAllProjects(String keyword, String uuTien, Integer leadId, String nhomda, String phongBan) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT da.id, da.ten_du_an, da.mo_ta, da.lead_id, da.muc_do_uu_tien, da.nhom_du_an, da.phong_ban, "
                + "da.ngay_bat_dau, da.trang_thai_duan, da.ngay_ket_thuc, "
                + "COALESCE(AVG(cvtd.phan_tram), 0) AS tien_do, "
                + "nv.ho_ten AS lead_ten, nv.avatar_url AS lead_avatar "
                + "FROM du_an da "
                + "LEFT JOIN nhanvien nv ON nv.id = da.lead_id "
                + "LEFT JOIN cong_viec cv ON cv.du_an_id = da.id "
                + "LEFT JOIN cong_viec_tien_do cvtd ON cvtd.cong_viec_id = cv.id "
                + "WHERE da.id <> 1 "
        );

        // ====== XÂY DỰNG ĐIỀU KIỆN LỌC ======
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND da.ten_du_an LIKE ? ");
        }

        if (uuTien != null && !uuTien.trim().isEmpty()) {
            sql.append(" AND da.muc_do_uu_tien = ? ");
        }

        if (nhomda != null && !nhomda.trim().isEmpty()) {
            sql.append(" AND da.nhom_du_an = ? ");
        }

        if (phongBan != null && !phongBan.trim().isEmpty()) {
            sql.append(" AND da.phong_ban = ? ");
        }

        if (leadId != null) {
            sql.append(" AND da.lead_id = ? ");
        }

        sql.append(" GROUP BY da.id ");

        PreparedStatement ps = cn.prepareStatement(sql.toString());

        // ==== GÁN GIÁ TRỊ CHO PARAM =====
        int index = 1;

        if (keyword != null && !keyword.trim().isEmpty()) {
            ps.setString(index++, "%" + keyword + "%");
        }

        if (uuTien != null && !uuTien.trim().isEmpty()) {
            ps.setString(index++, uuTien);
        }

        if (nhomda != null && !nhomda.trim().isEmpty()) {
            ps.setString(index++, nhomda);   // ✅ THÊM DÒNG BỊ THIẾU
        }

        if (phongBan != null && !phongBan.trim().isEmpty()) {
            ps.setString(index++, phongBan);
        }

        if (leadId != null) {
            ps.setInt(index++, leadId);
        }

        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            Map<String, Object> row = new HashMap<>();
            row.put("id", rs.getInt("id"));
            row.put("ten_du_an", rs.getString("ten_du_an"));
            row.put("mo_ta", rs.getString("mo_ta"));
            row.put("lead_id", rs.getInt("lead_id"));
            row.put("muc_do_uu_tien", rs.getString("muc_do_uu_tien"));
            row.put("ngay_bat_dau", rs.getDate("ngay_bat_dau"));
            row.put("ngay_ket_thuc", rs.getDate("ngay_ket_thuc"));
            row.put("tien_do", rs.getInt("tien_do"));
            row.put("nhom_du_an", rs.getString("nhom_du_an"));
            row.put("phong_ban", rs.getString("phong_ban"));
            row.put("lead_ten", rs.getString("lead_ten"));
            row.put("lead_avatar", rs.getString("lead_avatar"));
            row.put("trang_thai_duan", rs.getString("trang_thai_duan"));
            list.add(row);
        }
        return list;
    }

    public List<Map<String, Object>> getAllProjects(String keyword, String uuTien, Integer leadId, String nhomda) throws SQLException {
        return getAllProjects(keyword, uuTien, leadId, nhomda, null);
    }

    public List<Map<String, Object>> getProjectsByNhanVienFilter(
            String email, String keyword, String uuTien, Integer leadId, String nhomda) throws SQLException {

        List<Map<String, Object>> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder("""
        SELECT da.id, da.ten_du_an, da.mo_ta, da.nhom_du_an, da.muc_do_uu_tien,
               da.ngay_bat_dau, da.ngay_ket_thuc,
               da.lead_id, nv_lead.ho_ten AS lead_ten, nv_lead.avatar_url AS lead_avatar,
               COALESCE(AVG(cvtd.phan_tram), 0) AS tien_do
        FROM du_an da
        LEFT JOIN cong_viec cv ON cv.du_an_id = da.id
        LEFT JOIN cong_viec_nguoi_nhan cvnn ON cvnn.cong_viec_id = cv.id
        LEFT JOIN nhanvien nv ON nv.id = cvnn.nhan_vien_id
        LEFT JOIN nhanvien nv_lead ON nv_lead.id = da.lead_id
        LEFT JOIN cong_viec_tien_do cvtd ON cvtd.cong_viec_id = cv.id
        WHERE da.id <> 1
          AND (
                nv.email = ?
                OR da.lead_id = (SELECT id FROM nhanvien WHERE email = ?)
              )
    """);

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND da.ten_du_an LIKE ? ");
        }
        if (uuTien != null && !uuTien.trim().isEmpty()) {
            sql.append(" AND da.muc_do_uu_tien = ? ");
        }
        if (nhomda != null && !nhomda.trim().isEmpty()) {
            sql.append(" AND da.nhom_du_an = ? ");
        }
        if (leadId != null) {
            sql.append(" AND da.lead_id = ? ");
        }

        sql.append(" GROUP BY da.id ");

        PreparedStatement ps = cn.prepareStatement(sql.toString());
        int index = 1;

        // 🔥 2 lần email: 1 cho "nv.email", 1 cho "lead_id"
        ps.setString(index++, email);
        ps.setString(index++, email);

        if (keyword != null && !keyword.trim().isEmpty()) {
            ps.setString(index++, "%" + keyword + "%");
        }
        if (uuTien != null && !uuTien.trim().isEmpty()) {
            ps.setString(index++, uuTien);
        }
        if (nhomda != null && !nhomda.trim().isEmpty()) {
            ps.setString(index++, nhomda);
        }
        if (leadId != null) {
            ps.setInt(index++, leadId);
        }

        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            Map<String, Object> row = new HashMap<>();
            row.put("id", rs.getInt("id"));
            row.put("ten_du_an", rs.getString("ten_du_an"));
            row.put("mo_ta", rs.getString("mo_ta"));
            row.put("nhom_du_an", rs.getString("nhom_du_an"));
            row.put("muc_do_uu_tien", rs.getString("muc_do_uu_tien"));
            row.put("ngay_bat_dau", rs.getDate("ngay_bat_dau"));
            row.put("ngay_ket_thuc", rs.getDate("ngay_ket_thuc"));
            row.put("tien_do", rs.getInt("tien_do"));
            row.put("lead_id", rs.getInt("lead_id"));
            row.put("lead_ten", rs.getString("lead_ten"));
            row.put("lead_avatar", rs.getString("lead_avatar"));
            list.add(row);
        }

        return list;
    }

    public List<Map<String, Object>> getTaskByIdLikeList(int taskId) throws SQLException {
        List<Map<String, Object>> tasks = new ArrayList<>();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT cv.id, cv.du_an_id, cv.ten_cong_viec, cv.mo_ta, cv.muc_do_uu_tien, cv.trang_thai, ")
                .append("cv.tai_lieu_cv, cv.file_tai_lieu, cv.ngay_bat_dau, cv.trang_thai_duyet, cv.ly_do_duyet, cv.ngay_gia_han, cv.han_hoan_thanh, cv.nhac_viec, ")
                .append("ng1.ho_ten AS nguoi_giao_ten, ")
                .append("GROUP_CONCAT(DISTINCT ng2.ho_ten ORDER BY ng2.ho_ten SEPARATOR ', ') AS nguoi_nhan_ten, ")
                .append("GROUP_CONCAT(DISTINCT ng3.ho_ten ORDER BY ng3.ho_ten SEPARATOR ', ') AS nguoi_theo_doi_ten, ")
                .append("MAX(td.phan_tram) AS phan_tram, ")
                .append("da.ten_du_an AS ten_du_an, ")
                .append("pb.ten_phong AS ten_phong ")
                .append("FROM cong_viec cv ")
                .append("LEFT JOIN nhanvien ng1 ON cv.nguoi_giao_id = ng1.id ")
                .append("LEFT JOIN cong_viec_nguoi_nhan cvnn ON cv.id = cvnn.cong_viec_id ")
                .append("LEFT JOIN nhanvien ng2 ON cvnn.nhan_vien_id = ng2.id ")
                .append("LEFT JOIN cong_viec_nguoi_theo_doi cvntd ON cv.id = cvntd.cong_viec_id ")
                .append("LEFT JOIN nhanvien ng3 ON cvntd.nhan_vien_id = ng3.id ")
                .append("LEFT JOIN cong_viec_tien_do td ON cv.id = td.cong_viec_id ")
                .append("LEFT JOIN phong_ban pb ON cv.phong_ban_id = pb.id ")
                .append("LEFT JOIN du_an da ON cv.du_an_id = da.id ")
                .append("WHERE cv.id = ? AND cv.tinh_trang IS NULL ")
                .append("GROUP BY cv.id");

        try (PreparedStatement stmt = cn.prepareStatement(sql.toString())) {
            stmt.setInt(1, taskId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {

                    Map<String, Object> task = new HashMap<>();

                    task.put("id", rs.getInt("id"));
                    task.put("du_an_id", rs.getInt("du_an_id"));
                    task.put("ten_du_an", rs.getString("ten_du_an"));

                    task.put("ten_cong_viec", rs.getString("ten_cong_viec"));
                    task.put("mo_ta", rs.getString("mo_ta"));

                    task.put("nguoi_giao_id", rs.getString("nguoi_giao_ten"));
                    task.put("nguoi_nhan_ten", rs.getString("nguoi_nhan_ten"));
                    task.put("nguoi_theo_doi_ten", rs.getString("nguoi_theo_doi_ten"));

                    task.put("phan_tram", rs.getString("phan_tram"));
                    task.put("phong_ban_id", rs.getString("ten_phong"));

                    task.put("muc_do_uu_tien", rs.getString("muc_do_uu_tien"));
                    task.put("trang_thai", rs.getString("trang_thai"));

                    task.put("tai_lieu_cv", rs.getString("tai_lieu_cv"));
                    task.put("file_tai_lieu", rs.getString("file_tai_lieu"));

                    task.put("han_hoan_thanh", rs.getDate("han_hoan_thanh"));
                    task.put("ngay_bat_dau", rs.getDate("ngay_bat_dau"));
                    task.put("ngay_gia_han", rs.getDate("ngay_gia_han"));
                    task.put("nhac_viec", rs.getString("nhac_viec"));

                    task.put("trang_thai_duyet", rs.getString("trang_thai_duyet"));
                    task.put("ly_do_duyet", rs.getString("ly_do_duyet"));

                    tasks.add(task);
                }
            }
        }

        return tasks;
    }

    public List<Map<String, Object>> getAllTasksByProject(String email, int projectId) throws SQLException {
        List<Map<String, Object>> tasks = new ArrayList<>();

        if (email == null || email.trim().isEmpty()) {
            return tasks;
        }

        // Lấy thông tin user
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
                    return tasks;
                }
            }
        }

        boolean isAdmin = "Admin".equalsIgnoreCase(vaiTro);

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT cv.id, cv.du_an_id, da.ten_du_an, cv.ten_cong_viec, cv.mo_ta, cv.muc_do_uu_tien, cv.trang_thai, ")
                .append("cv.tai_lieu_cv, cv.file_tai_lieu, cv.han_hoan_thanh, cv.trang_thai_duyet, cv.ly_do_duyet, cv.ngay_gia_han, cv.ngay_bat_dau, cv.nhac_viec, ")
                .append("ng1.ho_ten AS nguoi_giao_ten, ")
                .append("GROUP_CONCAT(DISTINCT ng2.ho_ten ORDER BY ng2.ho_ten SEPARATOR ', ') AS nguoi_nhan_ten, ")
                .append("GROUP_CONCAT(DISTINCT ng3.ho_ten ORDER BY ng3.ho_ten SEPARATOR ', ') AS nguoi_theo_doi_ten, ")
                .append("MAX(td.phan_tram) AS phan_tram, ")
                .append("pb.ten_phong AS ten_phong ")
                .append("FROM cong_viec cv ")
                .append("LEFT JOIN nhanvien ng1 ON cv.nguoi_giao_id = ng1.id ")
                .append("LEFT JOIN cong_viec_nguoi_nhan cvnn ON cv.id = cvnn.cong_viec_id ")
                .append("LEFT JOIN nhanvien ng2 ON cvnn.nhan_vien_id = ng2.id ")
                .append("LEFT JOIN cong_viec_nguoi_theo_doi cvntd ON cv.id = cvntd.cong_viec_id ")
                .append("LEFT JOIN nhanvien ng3 ON cvntd.nhan_vien_id = ng3.id ")
                .append("LEFT JOIN cong_viec_tien_do td ON cv.id = td.cong_viec_id ")
                .append("LEFT JOIN phong_ban pb ON cv.phong_ban_id = pb.id ")
                .append("LEFT JOIN du_an da ON cv.du_an_id = da.id ");   // 🔥 THÊM JOIN

        if (isAdmin) {
            sql.append("WHERE ( ? = 0 OR cv.du_an_id = ? ) AND cv.tinh_trang IS NULL ");
        } else {
            sql.append("WHERE ( ? = 0 OR cv.du_an_id = ? ) AND cv.tinh_trang IS NULL ")
                    .append("AND (cv.phong_ban_id = ? OR cvnn.nhan_vien_id = ?) ");
        }

        sql.append("GROUP BY cv.id");

        try (PreparedStatement stmt = cn.prepareStatement(sql.toString())) {
            if (isAdmin) {
                stmt.setInt(1, projectId);
                stmt.setInt(2, projectId);
            } else {
                stmt.setInt(1, projectId);
                stmt.setInt(2, projectId);
                stmt.setInt(3, phongBanId);
                stmt.setInt(4, userId);
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> task = new HashMap<>();
                    task.put("id", rs.getInt("id"));
                    task.put("du_an_id", rs.getInt("du_an_id"));
                    task.put("ten_du_an", rs.getString("ten_du_an"));   // 🔥 TRẢ VỀ TÊN DỰ ÁN
                    task.put("ten_cong_viec", rs.getString("ten_cong_viec"));
                    task.put("mo_ta", rs.getString("mo_ta"));
                    task.put("nguoi_giao_id", rs.getString("nguoi_giao_ten"));
                    task.put("nguoi_nhan_ten", rs.getString("nguoi_nhan_ten"));
                    task.put("nguoi_theo_doi_ten", rs.getString("nguoi_theo_doi_ten"));
                    task.put("phan_tram", rs.getString("phan_tram"));
                    task.put("phong_ban_id", rs.getString("ten_phong"));
                    task.put("muc_do_uu_tien", rs.getString("muc_do_uu_tien"));
                    task.put("trang_thai", rs.getString("trang_thai"));
                    task.put("tai_lieu_cv", rs.getString("tai_lieu_cv"));
                    task.put("file_tai_lieu", rs.getString("file_tai_lieu"));
                    task.put("han_hoan_thanh", rs.getDate("han_hoan_thanh"));
                    task.put("ngay_bat_dau", rs.getDate("ngay_bat_dau"));
                    task.put("nhac_viec", rs.getString("nhac_viec"));
                    task.put("trang_thai_duyet", rs.getString("trang_thai_duyet"));
                    task.put("ly_do_duyet", rs.getString("ly_do_duyet"));
                    task.put("ngay_gia_han", rs.getDate("ngay_gia_han"));
                    tasks.add(task);
                }
            }
        }

        return tasks;
    }

    public String getTenDuanById(int projectId) throws SQLException {
        String sql = "SELECT ten_du_an FROM du_an WHERE id = ?";
        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, projectId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("ten_du_an");
                }
            }
        }
        return null;
    }

    // Lấy chi tiết dự án
    public Map<String, Object> getProjectById(int id) throws SQLException {
        String sql = "SELECT da.*, nv.ho_ten AS lead_ten, COALESCE(AVG(cvtd.phan_tram), 0) AS tien_do "
                   + "FROM du_an da "
                   + "LEFT JOIN nhanvien nv ON nv.id = da.lead_id "
                   + "LEFT JOIN cong_viec cv ON cv.du_an_id = da.id "
                   + "LEFT JOIN cong_viec_tien_do cvtd ON cvtd.cong_viec_id = cv.id "
                   + "WHERE da.id = ? "
                   + "GROUP BY da.id";
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> project = new HashMap<>();
                    project.put("id", rs.getInt("id"));
                    project.put("ten_du_an", rs.getString("ten_du_an"));
                    project.put("mo_ta", rs.getString("mo_ta"));
                    project.put("muc_do_uu_tien", rs.getString("muc_do_uu_tien"));
                    project.put("lead_id", rs.getInt("lead_id"));
                    project.put("lead_ten", rs.getString("lead_ten"));
                    project.put("tien_do", rs.getInt("tien_do"));
                    project.put("nhom_du_an", rs.getString("nhom_du_an"));
                    project.put("trang_thai_duan", rs.getString("trang_thai_duan"));
                    project.put("phong_ban", rs.getString("phong_ban"));

                    // Format ngày
                    java.sql.Date ngayBatDau = rs.getDate("ngay_bat_dau");
                    java.sql.Date ngayKetThuc = rs.getDate("ngay_ket_thuc");
                    java.sql.Timestamp ngayTao = rs.getTimestamp("ngay_tao");

                    java.text.SimpleDateFormat df = new java.text.SimpleDateFormat("yyyy-MM-dd");
                    java.text.SimpleDateFormat dtf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

                    project.put("ngay_bat_dau", ngayBatDau != null ? df.format(ngayBatDau) : "");
                    project.put("ngay_ket_thuc", ngayKetThuc != null ? df.format(ngayKetThuc) : "");
                    project.put("ngay_tao", ngayTao != null ? dtf.format(ngayTao) : "");

                    // ====== Lấy tổng công việc ======
                    String sqlCv = "SELECT COUNT(*) FROM cong_viec WHERE du_an_id = ?";
                    try (PreparedStatement psCv = cn.prepareStatement(sqlCv)) {
                        psCv.setInt(1, id);
                        try (ResultSet rsCv = psCv.executeQuery()) {
                            if (rsCv.next()) {
                                project.put("tong_cong_viec", rsCv.getInt(1));
                            } else {
                                project.put("tong_cong_viec", 0);
                            }
                        }
                    }

                    // ====== Lấy tổng số người duy nhất trong dự án ======
                    String sqlNguoi = "SELECT COUNT(DISTINCT cvr.nhan_vien_id) "
                            + "FROM cong_viec cv "
                            + "JOIN cong_viec_nguoi_nhan cvr ON cv.id = cvr.cong_viec_id "
                            + "WHERE cv.du_an_id = ?";
                    try (PreparedStatement psNguoi = cn.prepareStatement(sqlNguoi)) {
                        psNguoi.setInt(1, id);
                        try (ResultSet rsNguoi = psNguoi.executeQuery()) {
                            if (rsNguoi.next()) {
                                project.put("tong_nguoi", rsNguoi.getInt(1));
                            } else {
                                project.put("tong_nguoi", 0);
                            }
                        }
                    }

                    return project;
                }
            }
        }
        return null;
    }

    // Xóa dự án
    public boolean deleteProject(int id) throws SQLException {
        String sql = "DELETE FROM du_an WHERE id = ?";
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean insertDuAn(String tenDuAn, String moTa, String uuTien, int leadId,
            String nhomDuAn, String phongBan,
            Date ngayBatDau, Date ngayKetThuc) throws SQLException {

        String sql = "INSERT INTO du_an (ten_du_an, mo_ta, muc_do_uu_tien, lead_id, nhom_du_an, phong_ban, ngay_bat_dau, ngay_ket_thuc, trang_thai_duan) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'Đang thực hiện')";

        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, tenDuAn);
            ps.setString(2, moTa);
            ps.setString(3, uuTien);
            ps.setInt(4, leadId);
            ps.setString(5, nhomDuAn);
            ps.setString(6, phongBan);
            ps.setDate(7, ngayBatDau);
            ps.setDate(8, ngayKetThuc);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateProject(int id, String tenDuAn, String moTa,
            String uuTien, int leadId,
            String nhomDuAn, String phongBan,
            Date ngayBatDau, Date ngayKetThuc,
            String trangThaiDuAn) throws SQLException {

        String sql = "UPDATE du_an SET ten_du_an=?, mo_ta=?, muc_do_uu_tien=?, lead_id=?, nhom_du_an=?, phong_ban=?, "
                + "ngay_bat_dau=?, ngay_ket_thuc=?, trang_thai_duan=? WHERE id=?";

        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, tenDuAn);
            ps.setString(2, moTa);
            ps.setString(3, uuTien);
            ps.setInt(4, leadId);
            ps.setString(5, nhomDuAn);
            ps.setString(6, phongBan);
            ps.setDate(7, ngayBatDau);
            ps.setDate(8, ngayKetThuc);
            ps.setString(9, trangThaiDuAn);
            ps.setInt(10, id);

            return ps.executeUpdate() > 0;
        }
    }

    public List<Map<String, Object>> layTatCaLichTrinh() throws SQLException {
        List<Map<String, Object>> dsLichTrinh = new ArrayList<>();
        String sql = "SELECT * FROM lich_trinh";
        try (PreparedStatement ps = cn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> lich = new HashMap<>();
                lich.put("id", rs.getInt("id"));
                lich.put("tieu_de", rs.getString("tieu_de"));
                lich.put("ngay_bat_dau", rs.getDate("ngay_bat_dau"));
                lich.put("ngay_ket_thuc", rs.getDate("ngay_ket_thuc"));
                lich.put("mo_ta", rs.getString("mo_ta"));
                dsLichTrinh.add(lich);
            }
        }
        return dsLichTrinh;
    }

    // Thêm mới lịch trình
    public boolean themLichTrinh(String tieuDe, Date ngayBatDau, Date ngayKetThuc, String moTa) throws SQLException {
        String sql = "INSERT INTO lich_trinh (tieu_de, ngay_bat_dau, ngay_ket_thuc, mo_ta) VALUES (?,?,?,?)";
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, tieuDe);
            ps.setDate(2, ngayBatDau);
            ps.setDate(3, ngayKetThuc);
            ps.setString(4, moTa);
            return ps.executeUpdate() > 0;
        }
    }

// Cập nhật lịch trình
    public boolean capNhatLichTrinh(int id, String tieuDe, Date ngayBatDau, Date ngayKetThuc, String moTa) throws SQLException {
        String sql = "UPDATE lich_trinh SET tieu_de=?, ngay_bat_dau=?, ngay_ket_thuc=?, mo_ta=? WHERE id=?";
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, tieuDe);
            ps.setDate(2, ngayBatDau);
            ps.setDate(3, ngayKetThuc);
            ps.setString(4, moTa);
            ps.setInt(5, id);
            return ps.executeUpdate() > 0;
        }
    }

// Xóa lịch trình
    public boolean xoaLichTrinh(int id) throws SQLException {
        String sql = "DELETE FROM lich_trinh WHERE id=?";
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    private java.sql.Date getSqlDate(Cell cell) {
        if (cell == null) {
            return null;
        }

        switch (cell.getCellType()) {
            case STRING:
                try {
                    String value = cell.getStringCellValue().trim();
                    if (value.isEmpty()) {
                        return null;
                    }

                    // Parse chuỗi dd/MM/yyyy
                    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
                    java.util.Date utilDate = sdf.parse(value);
                    return new java.sql.Date(utilDate.getTime());
                } catch (Exception e) {
                    e.printStackTrace();
                    return null;
                }
            case NUMERIC:
                if (org.apache.poi.ss.usermodel.DateUtil.isCellDateFormatted(cell)) {
                    return new java.sql.Date(cell.getDateCellValue().getTime());
                } else {
                    // nếu là số (Excel lưu date dạng số) thì convert
                    return new java.sql.Date(org.apache.poi.ss.usermodel.DateUtil.getJavaDate(cell.getNumericCellValue()).getTime());
                }
            default:
                return null;
        }
    }

    private int getDuAnIdByName(String tenDuAn) throws SQLException {
        String sql = "SELECT id FROM du_an WHERE ten_du_an = ?";
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, tenDuAn);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("id");
            }
        }
        return 0; // hoặc throw new SQLException("Không tìm thấy dự án: " + tenDuAn);
    }

    private String getNullableString(Cell cell) {
        if (cell == null) {
            return null;
        }

        switch (cell.getCellType()) {
            case STRING:
                String s = cell.getStringCellValue().trim();
                return s.isEmpty() ? null : s;

            case NUMERIC:
                // Nếu là số -> chuyển về chuỗi (vd: "123")
                return String.valueOf((long) cell.getNumericCellValue());

            case BOOLEAN:
                return String.valueOf(cell.getBooleanCellValue());

            case BLANK:
                return null;

            default:
                return null;
        }
    }

    public int importTasksFromExcel(Sheet sheet) throws SQLException {
        String sql = "INSERT INTO cong_viec (du_an_id, ten_cong_viec, mo_ta, ngay_bat_dau, han_hoan_thanh, muc_do_uu_tien, "
                + "nguoi_giao_id, phong_ban_id, trang_thai, tai_lieu_cv, file_tai_lieu) "
                + "VALUES (?,?,?,?,?,?,?,?,?,?,?)";

        int count = 0;

        try (PreparedStatement ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            for (Row row : sheet) {
                if (row.getRowNum() == 0) {
                    continue; // bỏ dòng tiêu đề
                }
                // 1. du_an_id
                String tenDuAn = getNullableString(row.getCell(0));
                int duAnId = getDuAnIdByName(tenDuAn);
                ps.setInt(1, duAnId);

                // 2. ten_cong_viec
                String tenCongViec = getNullableString(row.getCell(1));
                ps.setString(2, tenCongViec);

                // 3. mo_ta
                String moTa = getNullableString(row.getCell(2));
                ps.setString(3, moTa);

                // 4. ngay_bat_dau
                java.sql.Date ngayBatDau = getSqlDate(row.getCell(3));
                ps.setDate(4, ngayBatDau);

                // 5. han_hoan_thanh
                java.sql.Date ngayKetThuc = getSqlDate(row.getCell(4));
                ps.setDate(5, ngayKetThuc);

                // 6. muc_do_uu_tien
                String mucDo = getNullableString(row.getCell(5));
                ps.setString(6, mucDo);

                // 7. nguoi_giao_id
                String tenNguoiGiao = getNullableString(row.getCell(6));
                int giaoId = getNhanVienIdByName(tenNguoiGiao);
                ps.setInt(7, giaoId);

                // 8. Người nhận (PIC)
                String dsNguoiNhan = getNullableString(row.getCell(7));

                // 9. phong_ban_id
                String tenPhongBan = getNullableString(row.getCell(8));
                int phongBanId = getPhongIdByName(tenPhongBan);
                ps.setInt(8, phongBanId);

                // 10. trang_thai
                String trangThai = getNullableString(row.getCell(9));
                ps.setString(9, trangThai);

                // 11. tai_lieu_cv
                String taiLieu = getNullableString(row.getCell(10));
                if (taiLieu != null) {
                    ps.setString(10, taiLieu);
                } else {
                    ps.setNull(10, java.sql.Types.VARCHAR);
                }

                // 12. file_tai_lieu
                String fileTaiLieu = getNullableString(row.getCell(11));
                if (fileTaiLieu != null) {
                    ps.setString(11, fileTaiLieu);
                } else {
                    ps.setNull(11, java.sql.Types.VARCHAR);
                }

                // Thực hiện insert công việc
                ps.executeUpdate();
                count++;

                // Lấy id công việc
                int taskId = -1;
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        taskId = rs.getInt(1);
                    }
                }

                // Insert người nhận
                if (taskId > 0 && dsNguoiNhan != null && !dsNguoiNhan.trim().isEmpty()) {
                    for (String tenNhan : dsNguoiNhan.split(",")) {
                        tenNhan = tenNhan.trim();
                        if (tenNhan.isEmpty()) {
                            continue;
                        }
                        int nhanId = getNhanVienIdByName(tenNhan);
                        if (nhanId > 0) {
                            addNguoiNhan(taskId, nhanId);
                        }
                    }
                }
            }
        }
        return count;
    }

    // Phương thức cập nhật hồ sơ cá nhân
    public boolean capNhatHoSoCaNhan(String email, String hoTen, String soDienThoai, String gioiTinh, String ngaySinh, String avatarUrl) throws SQLException {
        StringBuilder sql = new StringBuilder("UPDATE nhanvien SET ");
        List<Object> params = new ArrayList<>();
        boolean hasUpdate = false;

        // Chỉ cập nhật các trường có giá trị
        if (hoTen != null && !hoTen.trim().isEmpty()) {
            sql.append("ho_ten = ?");
            params.add(hoTen.trim());
            hasUpdate = true;
        }

        if (soDienThoai != null && !soDienThoai.trim().isEmpty()) {
            if (hasUpdate) {
                sql.append(", ");
            }
            sql.append("so_dien_thoai = ?");
            params.add(soDienThoai.trim());
            hasUpdate = true;
        }

        if (gioiTinh != null && !gioiTinh.trim().isEmpty()) {
            if (hasUpdate) {
                sql.append(", ");
            }
            sql.append("gioi_tinh = ?");
            params.add(gioiTinh.trim());
            hasUpdate = true;
        }

        if (ngaySinh != null && !ngaySinh.trim().isEmpty()) {
            if (hasUpdate) {
                sql.append(", ");
            }
            sql.append("ngay_sinh = STR_TO_DATE(?, '%d/%m/%Y')");
            params.add(ngaySinh.trim());
            hasUpdate = true;
        }

        if (avatarUrl != null && !avatarUrl.trim().isEmpty()) {
            if (hasUpdate) {
                sql.append(", ");
            }
            sql.append("avatar_url = ?");
            params.add(avatarUrl.trim());
            hasUpdate = true;
        }

        if (!hasUpdate) {
            return false; // Không có gì để cập nhật
        }

        sql.append(" WHERE email = ?");
        params.add(email);

        try (PreparedStatement ps = cn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        }
    }

    public List<Map<String, Object>> getTasksByDepartment(String email, int phongBanFilter) throws SQLException {
        List<Map<String, Object>> tasks = new ArrayList<>();

        if (email == null || email.trim().isEmpty()) {
            return tasks;
        }

        // 🔹 Lấy thông tin vai trò và phòng ban của user
        String getInfoSql = "SELECT vai_tro, phong_ban_id, id FROM nhanvien WHERE email = ?";
        String vaiTro = null;
        int phongBanUser = -1;
        int userId = -1;

        try (PreparedStatement infoStmt = cn.prepareStatement(getInfoSql)) {
            infoStmt.setString(1, email);
            try (ResultSet rs = infoStmt.executeQuery()) {
                if (rs.next()) {
                    vaiTro = rs.getString("vai_tro");
                    phongBanUser = rs.getInt("phong_ban_id");
                    userId = rs.getInt("id");
                } else {
                    return tasks;
                }
            }
        }

        boolean isAdmin = "Admin".equalsIgnoreCase(vaiTro);

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT cv.id, cv.du_an_id, cv.ten_cong_viec, cv.mo_ta, cv.muc_do_uu_tien, cv.trang_thai, ")
                .append("cv.tai_lieu_cv, cv.file_tai_lieu, cv.ngay_bat_dau, cv.trang_thai_duyet, cv.ly_do_duyet, cv.ngay_gia_han, cv.han_hoan_thanh, ")
                .append("ng1.ho_ten AS nguoi_giao_ten, ")
                .append("GROUP_CONCAT(DISTINCT ng2.ho_ten ORDER BY ng2.ho_ten SEPARATOR ', ') AS nguoi_nhan_ten, ")
                .append("GROUP_CONCAT(DISTINCT ng3.ho_ten ORDER BY ng3.ho_ten SEPARATOR ', ') AS nguoi_theo_doi_ten, ")
                .append("MAX(td.phan_tram) AS phan_tram, ")
                .append("da.ten_du_an AS ten_du_an, ")
                .append("pb.ten_phong AS ten_phong ")
                .append("FROM cong_viec cv ")
                .append("LEFT JOIN nhanvien ng1 ON cv.nguoi_giao_id = ng1.id ")
                .append("LEFT JOIN cong_viec_nguoi_nhan cvnn ON cv.id = cvnn.cong_viec_id ")
                .append("LEFT JOIN nhanvien ng2 ON cvnn.nhan_vien_id = ng2.id ")
                .append("LEFT JOIN cong_viec_nguoi_theo_doi cvntd ON cv.id = cvntd.cong_viec_id ")
                .append("LEFT JOIN nhanvien ng3 ON cvntd.nhan_vien_id = ng3.id ")
                .append("LEFT JOIN cong_viec_tien_do td ON cv.id = td.cong_viec_id ")
                .append("LEFT JOIN phong_ban pb ON cv.phong_ban_id = pb.id ")
                .append("LEFT JOIN du_an da ON cv.du_an_id = da.id ");

        if (isAdmin) {
            sql.append("WHERE cv.phong_ban_id = ? AND cv.tinh_trang IS NULL ");
        } else {
            sql.append("WHERE cv.phong_ban_id = ? AND cv.tinh_trang IS NULL ")
                    .append("AND (cv.phong_ban_id = ? OR cvnn.nhan_vien_id = ?) ");
        }

        sql.append("GROUP BY cv.id");

        try (PreparedStatement stmt = cn.prepareStatement(sql.toString())) {
            if (isAdmin) {
                stmt.setInt(1, phongBanFilter);
            } else {
                stmt.setInt(1, phongBanFilter);
                stmt.setInt(2, phongBanUser);
                stmt.setInt(3, userId);
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> task = new HashMap<>();
                    task.put("id", rs.getInt("id"));
                    task.put("du_an_id", rs.getInt("du_an_id"));
                    task.put("ten_du_an", rs.getString("ten_du_an"));
                    task.put("ten_cong_viec", rs.getString("ten_cong_viec"));
                    task.put("mo_ta", rs.getString("mo_ta"));
                    task.put("nguoi_giao_id", rs.getString("nguoi_giao_ten"));
                    task.put("nguoi_nhan_ten", rs.getString("nguoi_nhan_ten"));
                    task.put("nguoi_theo_doi_ten", rs.getString("nguoi_theo_doi_ten"));
                    task.put("phan_tram", rs.getString("phan_tram"));
                    task.put("phong_ban_id", rs.getString("ten_phong"));
                    task.put("muc_do_uu_tien", rs.getString("muc_do_uu_tien"));
                    task.put("trang_thai", rs.getString("trang_thai"));
                    task.put("tai_lieu_cv", rs.getString("tai_lieu_cv"));
                    task.put("file_tai_lieu", rs.getString("file_tai_lieu"));
                    task.put("han_hoan_thanh", rs.getDate("han_hoan_thanh"));
                    task.put("ngay_bat_dau", rs.getDate("ngay_bat_dau"));
                    task.put("trang_thai_duyet", rs.getString("trang_thai_duyet"));
                    task.put("ly_do_duyet", rs.getString("ly_do_duyet"));
                    task.put("ngay_gia_han", rs.getDate("ngay_gia_han"));

                    tasks.add(task);
                }
            }
        }

        return tasks;
    }

    public List<Map<String, Object>> getTasksByStatus(String email, int projectId, String trangThai) throws SQLException {
        List<Map<String, Object>> tasks = new ArrayList<>();

        if (email == null || email.trim().isEmpty()) {
            return tasks;
        }

        // Lấy thông tin vai trò và phòng ban của user
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
                    return tasks;
                }
            }
        }

        boolean isAdmin = "Admin".equalsIgnoreCase(vaiTro);

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT cv.id, cv.du_an_id, da.ten_du_an, cv.ten_cong_viec, cv.mo_ta, cv.muc_do_uu_tien, cv.trang_thai, ")
                .append("cv.tai_lieu_cv, cv.file_tai_lieu, cv.ngay_bat_dau, cv.trang_thai_duyet, cv.ly_do_duyet, cv.ngay_gia_han, cv.han_hoan_thanh, ")
                .append("ng1.ho_ten AS nguoi_giao_ten, ")
                .append("GROUP_CONCAT(DISTINCT ng2.ho_ten ORDER BY ng2.ho_ten SEPARATOR ', ') AS nguoi_nhan_ten, ")
                .append("GROUP_CONCAT(DISTINCT ng3.ho_ten ORDER BY ng3.ho_ten SEPARATOR ', ') AS nguoi_theo_doi_ten, ")
                .append("MAX(td.phan_tram) AS phan_tram, ")
                .append("pb.ten_phong AS ten_phong ")
                .append("FROM cong_viec cv ")
                .append("LEFT JOIN nhanvien ng1 ON cv.nguoi_giao_id = ng1.id ")
                .append("LEFT JOIN cong_viec_nguoi_nhan cvnn ON cv.id = cvnn.cong_viec_id ")
                .append("LEFT JOIN nhanvien ng2 ON cvnn.nhan_vien_id = ng2.id ")
                .append("LEFT JOIN cong_viec_nguoi_theo_doi cvntd ON cv.id = cvntd.cong_viec_id ")
                .append("LEFT JOIN nhanvien ng3 ON cvntd.nhan_vien_id = ng3.id ")
                .append("LEFT JOIN cong_viec_tien_do td ON cv.id = td.cong_viec_id ")
                .append("LEFT JOIN phong_ban pb ON cv.phong_ban_id = pb.id ")
                .append("LEFT JOIN du_an da ON cv.du_an_id = da.id ");   // 🔥 Thêm JOIN

        if (isAdmin) {
            sql.append("WHERE ( ? = 0 OR cv.du_an_id = ? ) AND cv.trang_thai = ? AND cv.tinh_trang IS NULL ");
        } else {
            sql.append("WHERE ( ? = 0 OR cv.du_an_id = ? ) AND cv.trang_thai = ? AND cv.tinh_trang IS NULL ")
                    .append("AND (cv.phong_ban_id = ? OR cvnn.nhan_vien_id = ?) ");
        }

        sql.append("GROUP BY cv.id");

        try (PreparedStatement stmt = cn.prepareStatement(sql.toString())) {

            if (isAdmin) {
                stmt.setInt(1, projectId);
                stmt.setInt(2, projectId);
                stmt.setString(3, trangThai);
            } else {
                stmt.setInt(1, projectId);
                stmt.setInt(2, projectId);
                stmt.setString(3, trangThai);
                stmt.setInt(4, phongBanId);
                stmt.setInt(5, userId);
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> task = new HashMap<>();
                    task.put("id", rs.getInt("id"));
                    task.put("du_an_id", rs.getInt("du_an_id"));
                    task.put("ten_du_an", rs.getString("ten_du_an"));   // 🔥 Trả về tên dự án
                    task.put("ten_cong_viec", rs.getString("ten_cong_viec"));
                    task.put("mo_ta", rs.getString("mo_ta"));
                    task.put("nguoi_giao_id", rs.getString("nguoi_giao_ten"));
                    task.put("nguoi_nhan_ten", rs.getString("nguoi_nhan_ten"));
                    task.put("nguoi_theo_doi_ten", rs.getString("nguoi_theo_doi_ten"));
                    task.put("phan_tram", rs.getString("phan_tram"));
                    task.put("phong_ban_id", rs.getString("ten_phong"));
                    task.put("muc_do_uu_tien", rs.getString("muc_do_uu_tien"));
                    task.put("trang_thai", rs.getString("trang_thai"));
                    task.put("tai_lieu_cv", rs.getString("tai_lieu_cv"));
                    task.put("file_tai_lieu", rs.getString("file_tai_lieu"));
                    task.put("han_hoan_thanh", rs.getDate("han_hoan_thanh"));
                    task.put("ngay_bat_dau", rs.getDate("ngay_bat_dau"));
                    task.put("trang_thai_duyet", rs.getString("trang_thai_duyet"));
                    task.put("ly_do_duyet", rs.getString("ly_do_duyet"));
                    task.put("ngay_gia_han", rs.getDate("ngay_gia_han"));

                    tasks.add(task);
                }
            }
        }

        return tasks;
    }

    public List<Map<String, Object>> getTasksByTinhTrang(String email, int projectId, String tinhTrang) throws SQLException {
        List<Map<String, Object>> tasks = new ArrayList<>();

        if (email == null || email.trim().isEmpty()) {
            return tasks;
        }

        // 🔹 Lấy thông tin người dùng + kiểm tra lead
        String getInfoSql = """
    SELECT nv.id, nv.vai_tro, nv.phong_ban_id,
           (SELECT lead_id FROM du_an WHERE id = ?) AS lead_of_project
    FROM nhanvien nv
    WHERE nv.email = ?
    """;

        int userId = -1;
        int phongBanId = -1;
        String vaiTro = "";
        int leadOfProject = -1;

        try (PreparedStatement stmt = cn.prepareStatement(getInfoSql)) {
            stmt.setInt(1, projectId);
            stmt.setString(2, email);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    userId = rs.getInt("id");
                    phongBanId = rs.getInt("phong_ban_id");
                    vaiTro = rs.getString("vai_tro");
                    leadOfProject = rs.getInt("lead_of_project");
                } else {
                    return tasks;
                }
            }
        }

        boolean isAdmin = "Admin".equalsIgnoreCase(vaiTro);
        boolean isLead = (userId == leadOfProject);

        // 🔹 Query chính
        StringBuilder sql = new StringBuilder();
        sql.append("""
    SELECT cv.id, cv.du_an_id, da.ten_du_an,
           cv.ten_cong_viec, cv.mo_ta, cv.muc_do_uu_tien,
           cv.trang_thai, cv.tinh_trang, cv.tai_lieu_cv, cv.file_tai_lieu,
           cv.ngay_bat_dau, cv.han_hoan_thanh,
           ng1.ho_ten AS nguoi_giao_ten,
           GROUP_CONCAT(DISTINCT ng2.ho_ten ORDER BY ng2.ho_ten SEPARATOR ', ') AS nguoi_nhan_ten,
           GROUP_CONCAT(DISTINCT ng3.ho_ten ORDER BY ng3.ho_ten SEPARATOR ', ') AS nguoi_theo_doi_ten,
           MAX(td.phan_tram) AS phan_tram,
           pb.ten_phong AS ten_phong
    FROM cong_viec cv
    LEFT JOIN nhanvien ng1 ON cv.nguoi_giao_id = ng1.id
    LEFT JOIN cong_viec_nguoi_nhan cvnn ON cv.id = cvnn.cong_viec_id
    LEFT JOIN nhanvien ng2 ON cvnn.nhan_vien_id = ng2.id
    LEFT JOIN cong_viec_nguoi_theo_doi cvntd ON cv.id = cvntd.cong_viec_id
    LEFT JOIN nhanvien ng3 ON cvntd.nhan_vien_id = ng3.id
    LEFT JOIN cong_viec_tien_do td ON cv.id = td.cong_viec_id
    LEFT JOIN phong_ban pb ON cv.phong_ban_id = pb.id
    LEFT JOIN du_an da ON cv.du_an_id = da.id
    WHERE ( ? = 0 OR cv.du_an_id = ? ) AND cv.tinh_trang = ?
    """);

        // Nếu không phải ADMIN và không phải LEAD thì chỉ xem công việc liên quan
        if (!isAdmin && !isLead) {
            sql.append(" AND (cv.nguoi_giao_id = ? OR cvnn.nhan_vien_id = ? OR cv.id IN (SELECT cong_viec_id FROM cong_viec_nguoi_theo_doi WHERE nhan_vien_id = ?)) ");
        }

        sql.append(" GROUP BY cv.id ");

        try (PreparedStatement stmt = cn.prepareStatement(sql.toString())) {

            stmt.setInt(1, projectId);
            stmt.setInt(2, projectId);
            stmt.setString(3, tinhTrang);

            if (!isAdmin && !isLead) {
                stmt.setInt(4, userId);
                stmt.setInt(5, userId);
                stmt.setInt(6, userId);
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> task = new HashMap<>();

                    task.put("id", rs.getInt("id"));
                    task.put("du_an_id", rs.getInt("du_an_id"));
                    task.put("ten_du_an", rs.getString("ten_du_an")); // 🔥 Trả tên dự án
                    task.put("ten_cong_viec", rs.getString("ten_cong_viec"));
                    task.put("mo_ta", rs.getString("mo_ta"));
                    task.put("nguoi_giao_id", rs.getString("nguoi_giao_ten"));
                    task.put("nguoi_nhan_ten", rs.getString("nguoi_nhan_ten"));
                    task.put("nguoi_theo_doi_ten", rs.getString("nguoi_theo_doi_ten"));
                    task.put("phan_tram", rs.getString("phan_tram"));
                    task.put("phong_ban_id", rs.getString("ten_phong"));
                    task.put("muc_do_uu_tien", rs.getString("muc_do_uu_tien"));
                    task.put("trang_thai", rs.getString("trang_thai"));
                    task.put("tinh_trang", rs.getString("tinh_trang"));
                    task.put("tai_lieu_cv", rs.getString("tai_lieu_cv"));
                    task.put("file_tai_lieu", rs.getString("file_tai_lieu"));
                    task.put("han_hoan_thanh", rs.getDate("han_hoan_thanh"));
                    task.put("ngay_bat_dau", rs.getDate("ngay_bat_dau"));

                    tasks.add(task);
                }
            }
        }

        return tasks;
    }

    public boolean updateTinhTrang(int taskId, String tinhTrang) throws SQLException {
        final String sql = "UPDATE cong_viec SET tinh_trang = ? WHERE id = ?";
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            if (tinhTrang == null || "NULL".equalsIgnoreCase(tinhTrang)) {
                ps.setNull(1, Types.VARCHAR);
            } else {
                ps.setString(1, tinhTrang);
            }
            ps.setInt(2, taskId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateNhacViec(int taskId, int nhacViec) throws SQLException {
        final String sql = "UPDATE cong_viec SET nhac_viec = ? WHERE id = ?";
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, nhacViec); // 1 = đã bật nhắc việc, 0 = tắt
            ps.setInt(2, taskId);
            return ps.executeUpdate() > 0;
        }
    }

// Cập nhật deadline
    public boolean updateDeadline(int taskId, String newDeadline) throws SQLException {
        final String sql = "UPDATE cong_viec SET han_hoan_thanh = ? WHERE id = ?";
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, newDeadline);
            ps.setInt(2, taskId);
            return ps.executeUpdate() > 0;
        }
    }

// tuỳ chọn: khi khôi phục muốn reset trạng_thái nghiệp vụ
    public boolean updateTrangThai(int taskId, String trangThai) throws SQLException {
        final String sql = "UPDATE cong_viec SET trang_thai = ? WHERE id = ?";
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, trangThai);
            ps.setInt(2, taskId);
            return ps.executeUpdate() > 0;
        }
    }

// gói gọn theo action (tiện cho servlet gọi)
    public boolean archiveTask(int taskId) throws SQLException {
        return updateTinhTrang(taskId, "Lưu trữ");
    }

    public boolean softDeleteTask(int taskId) throws SQLException {
        return updateTinhTrang(taskId, "Đã xóa");
    }

    public boolean restoreTask(int taskId, String defaultTrangThai) throws SQLException {
        boolean ok = updateTinhTrang(taskId, null); // set NULL
        // nếu cần, set lại trạng_thái nghiệp vụ (VD: "Chưa bắt đầu")
        if (ok && defaultTrangThai != null && !defaultTrangThai.isEmpty()) {
            ok = updateTrangThai(taskId, defaultTrangThai);
        }
        return ok;
    }

    /**
     * Lấy thông tin chi tiết công việc theo ID
     *
     * @param taskId ID của công việc
     * @return Map chứa thông tin công việc
     */
    public Map<String, Object> getCongViecById(int taskId) throws SQLException {
        String sql = "SELECT cv.*, "
                + "ng.ho_ten as ten_nguoi_giao, "
                + "pb.ten_phong "
                + "FROM cong_viec cv "
                + "LEFT JOIN nhanvien ng ON cv.nguoi_giao_id = ng.id "
                + "LEFT JOIN phong_ban pb ON cv.phong_ban_id = pb.id "
                + "WHERE cv.id = ?";

        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> task = new LinkedHashMap<>();
                    task.put("id", rs.getInt("id"));
                    task.put("ten_cong_viec", rs.getString("ten_cong_viec"));
                    task.put("mo_ta", rs.getString("mo_ta"));
                    task.put("ngay_bat_dau", rs.getString("ngay_bat_dau"));
                    task.put("han_hoan_thanh", rs.getString("han_hoan_thanh"));
                    task.put("muc_do_uu_tien", rs.getString("muc_do_uu_tien"));
                    task.put("nguoi_giao_id", rs.getInt("nguoi_giao_id"));
                    task.put("ten_nguoi_giao", rs.getString("ten_nguoi_giao"));
                    task.put("phong_ban_id", rs.getInt("phong_ban_id"));
                    task.put("ten_phong_ban", rs.getString("ten_phong"));
                    task.put("trang_thai", rs.getString("trang_thai"));
                    task.put("tai_lieu_cv", rs.getString("tai_lieu_cv"));
                    task.put("file_tai_lieu", rs.getString("file_tai_lieu"));
                    task.put("tinh_trang", rs.getString("tinh_trang"));
                    task.put("nhac_viec", rs.getInt("nhac_viec"));
                    return task;
                }
            }
        }
        return null;
    }

    /**
     * Lấy danh sách người nhận của công việc
     *
     * @param taskId ID của công việc
     * @return Danh sách tên người nhận, ngăn cách bởi dấu phẩy
     */
    public String getDanhSachNguoiNhan(int taskId) throws SQLException {
        String sql = "SELECT GROUP_CONCAT(nv.ho_ten SEPARATOR ', ') AS danh_sach "
                + "FROM cong_viec_nguoi_nhan cn "
                + "JOIN nhanvien nv ON cn.nhan_vien_id = nv.id "
                + "WHERE cn.cong_viec_id = ?";

        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("danh_sach");
                }
            }
        }
        return "";
    }

    /**
     * Lấy danh sách lịch sử thay đổi của công việc
     *
     * @param congViecId ID của công việc
     * @return List các Map chứa thông tin lịch sử
     */
    public List<Map<String, Object>> getLichSuCongViec(int congViecId) throws SQLException {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "SELECT ls.id, ls.cong_viec_id, ls.nguoi_thay_doi_id, "
                + "ls.mo_ta_thay_doi, ls.thoi_gian, "
                + "nv.ho_ten, nv.avatar_url "
                + "FROM cong_viec_lich_su ls "
                + "LEFT JOIN nhanvien nv ON ls.nguoi_thay_doi_id = nv.id "
                + "WHERE ls.cong_viec_id = ? "
                + "ORDER BY ls.thoi_gian DESC";

        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, congViecId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("id", rs.getInt("id"));
                    row.put("cong_viec_id", rs.getInt("cong_viec_id"));
                    row.put("nguoi_thay_doi_id", rs.getInt("nguoi_thay_doi_id"));
                    row.put("mo_ta_thay_doi", rs.getString("mo_ta_thay_doi"));
                    row.put("thoi_gian", rs.getTimestamp("thoi_gian"));
                    row.put("ten_nhan_vien", rs.getString("ho_ten"));
                    row.put("anh_dai_dien", rs.getString("avatar_url"));
                    result.add(row);
                }
            }
        }
        return result;
    }

    /**
     * Thêm một bản ghi lịch sử công việc
     *
     * @param congViecId ID của công việc
     * @param nguoiThayDoiId ID của người thực hiện thay đổi
     * @param moTaThayDoi Mô tả chi tiết thay đổi
     * @return true nếu thêm thành công
     */
    public boolean themLichSuCongViec(int congViecId, int nguoiThayDoiId, String moTaThayDoi) throws SQLException {
        String sql = "INSERT INTO cong_viec_lich_su (cong_viec_id, nguoi_thay_doi_id, mo_ta_thay_doi, thoi_gian) "
                + "VALUES (?, ?, ?, NOW())";

        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, congViecId);
            ps.setInt(2, nguoiThayDoiId);
            ps.setString(3, moTaThayDoi);
            return ps.executeUpdate() > 0;
        }
    }

    public Map<String, Object> giaHanCongViec(int taskId, String ngayGiaHan, Integer userId) {
        Map<String, Object> result = new HashMap<>();
        String updateSql = "UPDATE cong_viec SET ngay_gia_han = ?, han_hoan_thanh = ? WHERE id = ?";

        try (PreparedStatement ps = cn.prepareStatement(updateSql)) {

            Date newDate = Date.valueOf(ngayGiaHan);

            // Cập nhật ngày gia hạn
            ps.setDate(1, newDate);
            ps.setDate(2, newDate);
            ps.setInt(3, taskId);
            int updated = ps.executeUpdate();

            if (updated > 0) {
                // Ghi lịch sử (tái sử dụng hàm có sẵn)
//                String note = "Gia hạn công việc đến " + ngayGiaHan;
//                themLichSuCongViec(taskId, userId != null ? userId : 0, note);
//
//                result.put("success", true);
//                result.put("message", "Gia hạn thành công");
//                result.put("ngayGiaHan", ngayGiaHan);
            } else {
                result.put("success", false);
                result.put("message", "Không tìm thấy công việc hoặc không thể cập nhật");
            }

        } catch (Exception ex) {
            Logger.getLogger(KNCSDL.class.getName()).log(Level.SEVERE, null, ex);
            result.put("success", false);
            result.put("message", "Lỗi máy chủ: " + escapeJson(ex.getMessage()));
        }

        return result;
    }

    /**
     * Xét duyệt công việc
     */
    public Map<String, Object> xetDuyetCongViec(int taskId, String quyetDinh, String lyDo, Integer userId) {
        Map<String, Object> result = new HashMap<>();
        String updateSql = "UPDATE cong_viec SET trang_thai_duyet = ?, ly_do_duyet = ? WHERE id = ?";

        try (PreparedStatement ps = cn.prepareStatement(updateSql)) {

            ps.setString(1, quyetDinh);
            ps.setString(2, lyDo);
            ps.setInt(3, taskId);
            int updated = ps.executeUpdate();

            if (updated > 0) {
                // Ghi lịch sử (tái sử dụng hàm có sẵn)
                String note = "Xét duyệt: " + quyetDinh
                        + (lyDo != null && !lyDo.isEmpty() ? " - Lý do: " + lyDo : "");
                themLichSuCongViec(taskId, userId != null ? userId : 0, note);

                result.put("success", true);
                result.put("message", "Xét duyệt thành công");
            } else {
                result.put("success", false);
                result.put("message", "Không tìm thấy công việc hoặc không thể cập nhật");
            }

        } catch (Exception ex) {
            Logger.getLogger(KNCSDL.class.getName()).log(Level.SEVERE, null, ex);
            result.put("success", false);
            result.put("message", "Lỗi máy chủ: " + escapeJson(ex.getMessage()));
        }

        return result;
    }

    /**
     * Gửi báo cáo cho bản ghi chấm công
     *
     * @param attendanceId ID của bản ghi chấm công
     * @param reportContent Nội dung báo cáo
     * @param nhanVienId ID nhân viên gửi báo cáo (để xác thực)
     * @return true nếu thành công, false nếu thất bại
     * @throws SQLException
     */
    public boolean guiBaoCaoChamCong(int attendanceId, String reportContent, int nhanVienId) throws SQLException {
        String sql = "UPDATE cham_cong SET bao_cao = ? WHERE id = ? AND nhan_vien_id = ?";

        try (PreparedStatement stmt = this.cn.prepareStatement(sql)) {
            stmt.setString(1, reportContent);
            stmt.setInt(2, attendanceId);
            stmt.setInt(3, nhanVienId);

            int rowsUpdated = stmt.executeUpdate();
            return rowsUpdated > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Lấy danh sách báo cáo chấm công của nhân viên
     *
     * @param nhanVienId ID nhân viên
     * @return List các báo cáo có nội dung
     * @throws SQLException
     */
    public List<Map<String, Object>> getBaoCaoChamCongByNhanVien(int nhanVienId) throws SQLException {
        List<Map<String, Object>> reports = new ArrayList<>();

        String sql = "SELECT ngay, bao_cao FROM cham_cong "
                + "WHERE nhan_vien_id = ? AND bao_cao IS NOT NULL AND bao_cao != '' "
                + "ORDER BY ngay DESC LIMIT 10";

        try (PreparedStatement stmt = this.cn.prepareStatement(sql)) {
            stmt.setInt(1, nhanVienId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> report = new HashMap<>();
                    report.put("ngay", rs.getDate("ngay"));
                    report.put("bao_cao", rs.getString("bao_cao"));
                    reports.add(report);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return reports;
    }

    /**
     * Lấy báo cáo chấm công theo ID chấm công cụ thể
     *
     * @param attendanceId ID chấm công
     * @return Map chứa thông tin báo cáo hoặc null nếu không có
     * @throws SQLException
     */
    public Map<String, Object> getBaoCaoChamCongByAttendanceId(int attendanceId) throws SQLException {
        String sql = "SELECT cc.ngay, cc.bao_cao, nv.ho_ten "
                + "FROM cham_cong cc "
                + "LEFT JOIN nhanvien nv ON cc.nhan_vien_id = nv.id "
                + "WHERE cc.id = ?";

        try (PreparedStatement stmt = this.cn.prepareStatement(sql)) {
            stmt.setInt(1, attendanceId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> report = new HashMap<>();
                    report.put("ngay", rs.getDate("ngay"));
                    report.put("bao_cao", rs.getString("bao_cao"));
                    report.put("ho_ten", rs.getString("ho_ten"));
                    return report;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public List<Map<String, Object>> getTaskDetailByStatus(
            int nhanVienId, String status,
            String tuNgay, String denNgay) throws SQLException {

        List<Map<String, Object>> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder("""
            SELECT 
                cv.id,
                cv.ten_cong_viec,
                cv.trang_thai,
                cv.ngay_bat_dau,
                cv.han_hoan_thanh,
                cv.ngay_hoan_thanh,
                da.ten_du_an
            FROM cong_viec cv
            JOIN cong_viec_nguoi_nhan cvr ON cv.id = cvr.cong_viec_id
            JOIN du_an da ON cv.du_an_id = da.id
            WHERE cvr.nhan_vien_id = ?
        """);

        java.sql.Date sqlTu = java.sql.Date.valueOf(tuNgay);
        java.sql.Date sqlDen = java.sql.Date.valueOf(denNgay);

        List<Object> params = new ArrayList<>();
        params.add(nhanVienId);

        switch (status) {

            case "Đã hoàn thành":
                sql.append("""
                AND cv.ngay_hoan_thanh BETWEEN ? AND ?
            """);
                params.add(sqlTu);  // 1
                params.add(sqlDen); // 2
                break;

            case "Đang thực hiện":
                sql.append("""
                AND cv.ngay_hoan_thanh IS NULL
                AND cv.ngay_bat_dau <= ?
                AND (cv.han_hoan_thanh IS NULL OR cv.han_hoan_thanh >= ?)
            """);
                params.add(sqlDen); // ngày bắt đầu <= denNgay
                params.add(sqlDen); // hạn >= denNgay
                break;

            case "Trễ hạn":
                sql.append("""
                AND cv.ngay_hoan_thanh IS NULL
                AND cv.han_hoan_thanh IS NOT NULL
                AND cv.han_hoan_thanh < ?
            """);
                params.add(sqlDen); // hạn < denNgay
                break;

            case "Chưa bắt đầu":
                sql.append("""
                AND cv.ngay_bat_dau > ?
            """);
                params.add(sqlDen); // ngày bắt đầu > denNgay
                break;

            default:
                return list; // trạng thái không hợp lệ
        }

        sql.append(" ORDER BY cv.id DESC ");

        try (PreparedStatement stmt = cn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getInt("id"));
                    row.put("ten_cong_viec", rs.getString("ten_cong_viec"));
                    row.put("trang_thai", rs.getString("trang_thai"));
                    row.put("ten_du_an", rs.getString("ten_du_an"));
                    row.put("ngay_bat_dau", rs.getString("ngay_bat_dau"));
                    row.put("han_hoan_thanh", rs.getString("han_hoan_thanh"));
                    row.put("ngay_hoan_thanh", rs.getString("ngay_hoan_thanh"));

                    list.add(row);
                }
            }
        }

        return list;
    }

    public Map<String, Integer> getSoLuongDuAnTheoNhom() throws SQLException {
        Map<String, Integer> map = new HashMap<>();

        String sql = "SELECT nhom_du_an, COUNT(*) AS so_luong "
                + "FROM du_an "
                + "WHERE id <> 1 "
                + "GROUP BY nhom_du_an";

        PreparedStatement ps = cn.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            String nhom = rs.getString("nhom_du_an");
            int soLuong = rs.getInt("so_luong");
            map.put(nhom, soLuong);
        }

        return map;
    }

    public Map<String, Map<String, Integer>> getSoLuongDuAnTheoNhomVaPhongBan() throws SQLException {
        Map<String, Map<String, Integer>> result = new HashMap<>();

        String sql = """
        SELECT nhom_du_an, phong_ban, COUNT(*) AS so_luong
        FROM du_an
        WHERE id <> 1
        GROUP BY nhom_du_an, phong_ban
    """;

        PreparedStatement ps = cn.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            String nhom = rs.getString("nhom_du_an");
            String phong = rs.getString("phong_ban"); // tên phòng ban trong DB
            int so = rs.getInt("so_luong");

            result.putIfAbsent(nhom, new HashMap<>());
            result.get(nhom).put(phong, so);
        }
        return result;
    }

    public int batNhacViecTheoTrangThai(String csvTrangThai) throws SQLException {
        if (csvTrangThai == null || csvTrangThai.trim().isEmpty()) {
            return 0;
        }

        String[] arr = csvTrangThai.split(",");
        StringBuilder inClause = new StringBuilder();

        for (int i = 0; i < arr.length; i++) {
            inClause.append("?");
            if (i < arr.length - 1) {
                inClause.append(",");
            }
        }

        String sql = "UPDATE cong_viec SET nhac_viec = 1 "
                + "WHERE tinh_trang IS NULL AND trang_thai IN (" + inClause + ")";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            for (int i = 0; i < arr.length; i++) {
                stmt.setString(i + 1, arr[i].trim());
            }
            return stmt.executeUpdate();
        }
    }

    // Lấy tiến độ dự án theo nhóm dự án thay vì phòng ban  
    public Map<String, Object> getTienDoDuAnTheoNhom(String nhomDuAn) throws SQLException {
        Map<String, Object> data = new HashMap<>();
        List<String> projectNames = new ArrayList<>();
        List<Double> progressValues = new ArrayList<>();

        String sql = """
            SELECT 
                da.ten_du_an,
                ROUND(AVG(COALESCE(
                    CASE 
                        WHEN cv.trang_thai = 'Đã hoàn thành' THEN 100
                        WHEN cv.trang_thai = 'Đang thực hiện' THEN 
                            COALESCE((
                                SELECT MAX(ctd.phan_tram) 
                                FROM cong_viec_tien_do ctd 
                                WHERE ctd.cong_viec_id = cv.id
                            ), 30)
                        WHEN cv.trang_thai = 'Trễ hạn' THEN 
                            COALESCE((
                                SELECT MAX(ctd.phan_tram) 
                                FROM cong_viec_tien_do ctd 
                                WHERE ctd.cong_viec_id = cv.id
                            ), 20)
                        ELSE 0
                    END, 0
                )), 1) AS tien_do
            FROM du_an da
            LEFT JOIN cong_viec cv ON da.id = cv.du_an_id
            WHERE da.nhom_du_an = ? OR ? = 'Tất cả'
            GROUP BY da.id, da.ten_du_an
            HAVING COUNT(cv.id) > 0
            ORDER BY da.ten_du_an
            LIMIT 15
        """;

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setString(1, nhomDuAn);
            stmt.setString(2, nhomDuAn);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    String projectName = rs.getString("ten_du_an");
                    double progress = rs.getDouble("tien_do");

                    projectNames.add(projectName);
                    progressValues.add(progress);
                }
            }
        }

        data.put("projectNames", projectNames);
        data.put("progressValues", progressValues);
        return data;
    }

    // Lấy tiến độ dự án theo phòng ban
    public Map<String, Object> getTienDoDuAnTheoPhongBan(String phongBan) throws SQLException {
        Map<String, Object> data = new HashMap<>();
        List<Map<String, Object>> rows = new ArrayList<>();

        String sql = """
        SELECT
            da.id,
            da.ten_du_an,
            da.ngay_ket_thuc,
            COALESCE(AVG(cvtd.phan_tram), 0) AS tien_do,
            da.trang_thai_duan
        FROM du_an da
        LEFT JOIN cong_viec cv ON cv.du_an_id = da.id
        LEFT JOIN cong_viec_tien_do cvtd ON cvtd.cong_viec_id = cv.id
        WHERE da.phong_ban = ?
        GROUP BY da.id, da.ten_du_an, da.ngay_ket_thuc, da.trang_thai_duan
    """;

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setString(1, phongBan);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    int id = rs.getInt("id");

                    // 👉 Bỏ qua dự án có ID = 1
                    if (id == 1) {
                        continue;
                    }

                    Map<String, Object> r = new HashMap<>();
                    r.put("id", id);
                    r.put("ten", rs.getString("ten_du_an"));
                    double tiendoValue = rs.getDouble("tien_do");
                    r.put("tien_do", tiendoValue);

                    String ngayKT = rs.getString("ngay_ket_thuc");
                    r.put("ngay_ket_thuc", ngayKT);

                    String status = rs.getString("trang_thai_duan");
                    if (status == null || status.trim().isEmpty()) {
                        status = "Chưa bắt đầu";
                    }

                    // ✅ KIỂM TRA VÀ TỰ ĐỘNG CẬP NHẬT TRẠNG THÁI DỰ ÁN (2 CHIỀU)
                    // Chỉ xử lý 2 trạng thái: "Đang thực hiện" và "Đã hoàn thành"
                    // Không động vào "Tạm ngưng" và "Đóng dự án"
                    // Logic 1: Nếu tiến độ >= 99.5% (coi như 100%) và đang ở trạng thái "Đang thực hiện"
                    // Thì tự động chuyển sang "Đã hoàn thành"
                    if (tiendoValue >= 99.5 && status.equals("Đang thực hiện")) {
                        try {
                            String updateSql = "UPDATE du_an SET trang_thai_duan = ? WHERE id = ?";
                            try (PreparedStatement updateStmt = cn.prepareStatement(updateSql)) {
                                updateStmt.setString(1, "Đã hoàn thành");
                                updateStmt.setInt(2, id);
                                updateStmt.executeUpdate();
                            }
                            status = "Đã hoàn thành";
                        } catch (Exception ex) {
                            // Nếu cập nhật thất bại, vẫn lấy status từ database
                            ex.printStackTrace();
                        }
                    } // Logic 2: Nếu tiến độ < 99.5% (chưa đến 100%) và đang ở trạng thái "Đã hoàn thành"
                    // Thì tự động chuyển về "Đang thực hiện" (vì có thêm việc mới)
                    else if (tiendoValue < 99.5 && status.equals("Đã hoàn thành")) {
                        try {
                            String updateSql = "UPDATE du_an SET trang_thai_duan = ? WHERE id = ?";
                            try (PreparedStatement updateStmt = cn.prepareStatement(updateSql)) {
                                updateStmt.setString(1, "Đang thực hiện");
                                updateStmt.setInt(2, id);
                                updateStmt.executeUpdate();
                            }
                            status = "Đang thực hiện";
                        } catch (Exception ex) {
                            // Nếu cập nhật thất bại, vẫn lấy status từ database
                            ex.printStackTrace();
                        }
                    }
                    r.put("trang_thai_duan", status);

                    // Chỉ tính daysLeft nếu dự án chưa hoàn thành hoàn toàn (< 100%)
                    int daysLeft = 0;
                    if (tiendoValue < 99.5 && ngayKT != null) {
                        try {
                            java.sql.Date end = java.sql.Date.valueOf(ngayKT);
                            long now = System.currentTimeMillis();
                            long diff = end.getTime() - now;
                            daysLeft = (int) Math.ceil(diff / (1000.0 * 60 * 60 * 24));
                        } catch (Exception ex) {
                            daysLeft = 0;
                        }
                    }
                    r.put("days_left", daysLeft);

                    rows.add(r);
                }
            }
        }

        // Định nghĩa thứ tự hiển thị trạng thái
        List<String> statusOrder = Arrays.asList("Đang thực hiện", "Chưa bắt đầu", "Đã kết thúc", "Không thể thực hiện");

        // Sắp xếp rows theo statusOrder rồi theo tên dự án
        rows.sort((a, b) -> {
            String sa = (String) a.get("trang_thai_duan");
            String sb = (String) b.get("trang_thai_duan");
            int ia = statusOrder.indexOf(sa);
            int ib = statusOrder.indexOf(sb);
            if (ia == -1) {
                ia = 99;
            }
            if (ib == -1) {
                ib = 99;
            }
            if (ia != ib) {
                return Integer.compare(ia, ib);
            }
            return ((String) a.get("ten")).compareToIgnoreCase((String) b.get("ten"));
        });

        // Tách thành các list song song để trả về (giữ tương thích frontend)
        List<Integer> projectIds = new ArrayList<>();
        List<String> projectNames = new ArrayList<>();
        List<Double> progressValues = new ArrayList<>();
        List<String> endDates = new ArrayList<>();
        List<Integer> daysLeftList = new ArrayList<>();
        List<String> projectStatuses = new ArrayList<>();

        for (Map<String, Object> r : rows) {
            projectIds.add((Integer) r.get("id"));
            projectNames.add((String) r.get("ten"));
            progressValues.add((Double) r.get("tien_do"));
            endDates.add((String) r.get("ngay_ket_thuc"));
            daysLeftList.add((Integer) r.get("days_left"));
            projectStatuses.add((String) r.get("trang_thai_duan"));
        }

        data.put("projectIds", projectIds);
        data.put("projectNames", projectNames);
        data.put("progressValues", progressValues);
        data.put("endDates", endDates);
        data.put("daysLeft", daysLeftList);
        data.put("projectStatuses", projectStatuses);

        return data;
    }

    public List<String> getQuyenTheoNhanVien(int nhanvienId) throws SQLException {
        List<String> danhSach = new ArrayList<>();

        String sql = """
        SELECT q.ma_quyen
        FROM nhanvien_quyen nq
        JOIN quyen q ON q.id = nq.quyen_id
        WHERE nq.nhanvien_id = ?
    """;

        PreparedStatement ps = cn.prepareStatement(sql);
        ps.setInt(1, nhanvienId);

        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            danhSach.add(rs.getString("ma_quyen"));
        }
        return danhSach;
    }

    public boolean luuPhanQuyenNhanVien(int nhanvienId, String[] dsQuyen) throws SQLException {
        cn.setAutoCommit(false);

        try {
            // Xóa quyền cũ
            PreparedStatement xoa = cn.prepareStatement(
                    "DELETE FROM nhanvien_quyen WHERE nhanvien_id = ?"
            );
            xoa.setInt(1, nhanvienId);
            xoa.executeUpdate();

            // Thêm quyền mới
            PreparedStatement them = cn.prepareStatement(
                    "INSERT INTO nhanvien_quyen (nhanvien_id, quyen_id) "
                    + "VALUES (?, (SELECT id FROM quyen WHERE ma_quyen = ?))"
            );

            for (String q : dsQuyen) {
                them.setInt(1, nhanvienId);
                them.setString(2, q);
                them.executeUpdate();
            }

            cn.commit();
            return true;

        } catch (Exception e) {
            cn.rollback();
            e.printStackTrace();
            return false;
        }
    }

    public void insertNguoiNhanQuyTrinh(int stepId, int nhanId) throws SQLException {
        String sql = "INSERT INTO quy_trinh_nguoi_nhan (step_id, nhan_id) VALUES (?, ?)";
        PreparedStatement stmt = cn.prepareStatement(sql);
        stmt.setInt(1, stepId);
        stmt.setInt(2, nhanId);
        stmt.executeUpdate();
        stmt.close();
    }

    public void deleteNguoiNhanByStepId(int stepId) throws SQLException {
        String sql = "DELETE FROM quy_trinh_nguoi_nhan WHERE step_id = ?";
        PreparedStatement stmt = cn.prepareStatement(sql);
        stmt.setInt(1, stepId);
        stmt.executeUpdate();
        stmt.close();
    }

    public void close() throws SQLException {
        if (cn != null && !cn.isClosed()) {
            cn.close();
        }
    }

    private String escapeJson(String message) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    // ===================================
    // QUẢN LÝ THƯ VIỆN TÀI LIỆU
    // ===================================
    /**
     * Lấy danh sách tất cả tài liệu (chỉ tài liệu đang hoạt động)
     */
    public List<TaiLieu> getAllTaiLieu() throws SQLException {
        List<TaiLieu> list = new ArrayList<>();
        String sql = "SELECT tl.*, nv.ho_ten as ten_nguoi_tao, nv.avatar_url as avatar_nguoi_tao "
                + "FROM tai_lieu tl "
                + "LEFT JOIN nhanvien nv ON tl.nguoi_tao_id = nv.id "
                + "WHERE tl.trang_thai = 'Hoạt động' "
                + "ORDER BY tl.ngay_tao DESC";

        try (PreparedStatement stmt = cn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                TaiLieu tl = new TaiLieu();
                tl.setId(rs.getInt("id"));
                tl.setTenTaiLieu(rs.getString("ten_tai_lieu"));
                tl.setLoaiTaiLieu(rs.getString("loai_tai_lieu"));
                tl.setMoTa(rs.getString("mo_ta"));
                tl.setFileName(rs.getString("file_name"));
                tl.setFilePath(rs.getString("file_path"));
                tl.setFileSize(rs.getLong("file_size"));
                tl.setFileType(rs.getString("file_type"));
                tl.setNguoiTaoId(rs.getInt("nguoi_tao_id"));
                tl.setNgayTao(rs.getTimestamp("ngay_tao"));
                tl.setNgayCapNhat(rs.getTimestamp("ngay_cap_nhat"));
                tl.setTrangThai(rs.getString("trang_thai"));
                tl.setLuotXem(rs.getInt("luot_xem"));
                tl.setLuotTai(rs.getInt("luot_tai"));
                tl.setTenNguoiTao(rs.getString("ten_nguoi_tao"));
                tl.setAvatarNguoiTao(rs.getString("avatar_nguoi_tao"));
                list.add(tl);
            }
        }
        return list;
    }

    /**
     * Lấy tài liệu theo ID
     */
    public TaiLieu getTaiLieuById(int id) throws SQLException {
        String sql = "SELECT tl.*, nv.ho_ten as ten_nguoi_tao, nv.avatar_url as avatar_nguoi_tao "
                + "FROM tai_lieu tl "
                + "LEFT JOIN nhanvien nv ON tl.nguoi_tao_id = nv.id "
                + "WHERE tl.id = ?";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    TaiLieu tl = new TaiLieu();
                    tl.setId(rs.getInt("id"));
                    tl.setTenTaiLieu(rs.getString("ten_tai_lieu"));
                    tl.setLoaiTaiLieu(rs.getString("loai_tai_lieu"));
                    tl.setMoTa(rs.getString("mo_ta"));
                    tl.setFileName(rs.getString("file_name"));
                    tl.setFilePath(rs.getString("file_path"));
                    tl.setFileSize(rs.getLong("file_size"));
                    tl.setFileType(rs.getString("file_type"));
                    tl.setNguoiTaoId(rs.getInt("nguoi_tao_id"));
                    tl.setNgayTao(rs.getTimestamp("ngay_tao"));
                    tl.setNgayCapNhat(rs.getTimestamp("ngay_cap_nhat"));
                    tl.setTrangThai(rs.getString("trang_thai"));
                    tl.setLuotXem(rs.getInt("luot_xem"));
                    tl.setLuotTai(rs.getInt("luot_tai"));
                    tl.setTenNguoiTao(rs.getString("ten_nguoi_tao"));
                    tl.setAvatarNguoiTao(rs.getString("avatar_nguoi_tao"));
                    return tl;
                }
            }
        }
        return null;
    }

    /**
     * Thêm tài liệu mới
     */
    public int insertTaiLieu(TaiLieu tl) throws SQLException {
        String sql = "INSERT INTO tai_lieu (nhom_tai_lieu_id, ten_tai_lieu, loai_tai_lieu, mo_ta, file_name, "
                + "file_path, file_size, file_type, nguoi_tao_id, doi_tuong_xem) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement stmt = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, tl.getNhomTaiLieuId());
            stmt.setString(2, tl.getTenTaiLieu());
            stmt.setString(3, tl.getLoaiTaiLieu());
            stmt.setString(4, tl.getMoTa());
            stmt.setString(5, tl.getFileName());
            stmt.setString(6, tl.getFilePath());
            stmt.setLong(7, tl.getFileSize());
            stmt.setString(8, tl.getFileType());
            stmt.setInt(9, tl.getNguoiTaoId());
            stmt.setString(10, tl.getDoiTuongXem() != null ? tl.getDoiTuongXem() : "Tất cả");

            int affectedRows = stmt.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        }
        return -1;
    }

    /**
     * Cập nhật thông tin tài liệu
     */
    public boolean updateTaiLieu(TaiLieu tl) throws SQLException {
        String sql = "UPDATE tai_lieu SET ten_tai_lieu = ?, loai_tai_lieu = ?, mo_ta = ? "
                + "WHERE id = ?";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setString(1, tl.getTenTaiLieu());
            stmt.setString(2, tl.getLoaiTaiLieu());
            stmt.setString(3, tl.getMoTa());
            stmt.setInt(4, tl.getId());

            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Xóa tài liệu (soft delete)
     */
    public boolean deleteTaiLieu(int id) throws SQLException {
        String sql = "UPDATE tai_lieu SET trang_thai = 'Đã xóa' WHERE id = ?";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Tăng lượt xem tài liệu
     */
    public void incrementLuotXem(int id) throws SQLException {
        String sql = "UPDATE tai_lieu SET luot_xem = luot_xem + 1 WHERE id = ?";
        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            stmt.executeUpdate();
        }
    }

    /**
     * Tăng lượt tải tài liệu
     */
    public void incrementLuotTai(int id) throws SQLException {
        String sql = "UPDATE tai_lieu SET luot_tai = luot_tai + 1 WHERE id = ?";
        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            stmt.executeUpdate();
        }
    }

    /**
     * Tìm kiếm tài liệu theo từ khóa
     */
    public List<TaiLieu> searchTaiLieu(String keyword) throws SQLException {
        List<TaiLieu> list = new ArrayList<>();
        String sql = "SELECT tl.*, nv.ho_ten as ten_nguoi_tao, nv.avatar_url as avatar_nguoi_tao "
                + "FROM tai_lieu tl "
                + "LEFT JOIN nhanvien nv ON tl.nguoi_tao_id = nv.id "
                + "WHERE tl.trang_thai = 'Hoạt động' "
                + "AND (tl.ten_tai_lieu LIKE ? OR tl.mo_ta LIKE ? OR tl.loai_tai_lieu LIKE ?) "
                + "ORDER BY tl.ngay_tao DESC";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            String searchPattern = "%" + keyword + "%";
            stmt.setString(1, searchPattern);
            stmt.setString(2, searchPattern);
            stmt.setString(3, searchPattern);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    TaiLieu tl = new TaiLieu();
                    tl.setId(rs.getInt("id"));
                    tl.setTenTaiLieu(rs.getString("ten_tai_lieu"));
                    tl.setLoaiTaiLieu(rs.getString("loai_tai_lieu"));
                    tl.setMoTa(rs.getString("mo_ta"));
                    tl.setFileName(rs.getString("file_name"));
                    tl.setFilePath(rs.getString("file_path"));
                    tl.setFileSize(rs.getLong("file_size"));
                    tl.setFileType(rs.getString("file_type"));
                    tl.setNguoiTaoId(rs.getInt("nguoi_tao_id"));
                    tl.setNgayTao(rs.getTimestamp("ngay_tao"));
                    tl.setNgayCapNhat(rs.getTimestamp("ngay_cap_nhat"));
                    tl.setTrangThai(rs.getString("trang_thai"));
                    tl.setLuotXem(rs.getInt("luot_xem"));
                    tl.setLuotTai(rs.getInt("luot_tai"));
                    tl.setTenNguoiTao(rs.getString("ten_nguoi_tao"));
                    tl.setAvatarNguoiTao(rs.getString("avatar_nguoi_tao"));
                    list.add(tl);
                }
            }
        }
        return list;
    }

    public List<TaiLieu> searchTaiLieu(String keyword, String loai) throws SQLException {
        List<TaiLieu> list = new ArrayList<>();

        String sql
                = "SELECT tl.*, nv.ho_ten AS ten_nguoi_tao, nv.avatar_url AS avatar_nguoi_tao "
                + "FROM tai_lieu tl "
                + "LEFT JOIN nhanvien nv ON tl.nguoi_tao_id = nv.id "
                + "WHERE tl.trang_thai = 'Hoạt động' "
                + "AND (tl.ten_tai_lieu LIKE ? OR tl.mo_ta LIKE ?) "
                + "AND tl.loai_tai_lieu = ? "
                + "ORDER BY tl.ngay_tao DESC";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            String pattern = "%" + keyword + "%";
            stmt.setString(1, pattern);
            stmt.setString(2, pattern);
            stmt.setString(3, loai);

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                TaiLieu tl = new TaiLieu();
                list.add(tl);
            }
        }
        return list;
    }

    /**
     * Lấy danh sách loại tài liệu duy nhất
     */
    public List<String> getLoaiTaiLieuList() throws SQLException {
        List<String> list = new ArrayList<>();
        String sql = "SELECT DISTINCT loai_tai_lieu FROM tai_lieu "
                + "WHERE trang_thai = 'Hoạt động' AND loai_tai_lieu IS NOT NULL "
                + "ORDER BY loai_tai_lieu";

        try (PreparedStatement stmt = cn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(rs.getString("loai_tai_lieu"));
            }
        }
        return list;
    }

    /**
     * Lọc tài liệu theo loại
     */
    public List<TaiLieu> getTaiLieuByLoai(String loai) throws SQLException {
        List<TaiLieu> list = new ArrayList<>();
        String sql = "SELECT tl.*, nv.ho_ten as ten_nguoi_tao, nv.avatar_url as avatar_nguoi_tao "
                + "FROM tai_lieu tl "
                + "LEFT JOIN nhanvien nv ON tl.nguoi_tao_id = nv.id "
                + "WHERE tl.trang_thai = 'Hoạt động' AND tl.loai_tai_lieu = ? "
                + "ORDER BY tl.ngay_tao DESC";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setString(1, loai);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    TaiLieu tl = new TaiLieu();
                    tl.setId(rs.getInt("id"));
                    tl.setTenTaiLieu(rs.getString("ten_tai_lieu"));
                    tl.setLoaiTaiLieu(rs.getString("loai_tai_lieu"));
                    tl.setMoTa(rs.getString("mo_ta"));
                    tl.setFileName(rs.getString("file_name"));
                    tl.setFilePath(rs.getString("file_path"));
                    tl.setFileSize(rs.getLong("file_size"));
                    tl.setFileType(rs.getString("file_type"));
                    tl.setNguoiTaoId(rs.getInt("nguoi_tao_id"));
                    tl.setNgayTao(rs.getTimestamp("ngay_tao"));
                    tl.setNgayCapNhat(rs.getTimestamp("ngay_cap_nhat"));
                    tl.setTrangThai(rs.getString("trang_thai"));
                    tl.setLuotXem(rs.getInt("luot_xem"));
                    tl.setLuotTai(rs.getInt("luot_tai"));
                    tl.setTenNguoiTao(rs.getString("ten_nguoi_tao"));
                    tl.setAvatarNguoiTao(rs.getString("avatar_nguoi_tao"));
                    list.add(tl);
                }
            }
        }
        return list;
    }

    // =============== METHODS CHO NHÓM TÀI LIỆU ===============
    /**
     * Lấy tất cả nhóm tài liệu
     */
    public List<NhomTaiLieu> getAllNhomTaiLieu() throws SQLException {
        List<NhomTaiLieu> list = new ArrayList<>();
        String sql = "SELECT ntl.*, nv.ho_ten as ten_nguoi_tao, "
                + "(SELECT COUNT(*) FROM tai_lieu WHERE nhom_tai_lieu_id = ntl.id AND trang_thai = 'Hoạt động') as so_luong_tai_lieu "
                + "FROM nhom_tai_lieu ntl "
                + "LEFT JOIN nhanvien nv ON ntl.nguoi_tao_id = nv.id "
                + "WHERE ntl.trang_thai = 'Hoạt động' "
                + "ORDER BY ntl.thu_tu, ntl.ten_nhom";

        try (PreparedStatement stmt = cn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                NhomTaiLieu ntl = new NhomTaiLieu();
                ntl.setId(rs.getInt("id"));
                ntl.setTenNhom(rs.getString("ten_nhom"));
                ntl.setMoTa(rs.getString("mo_ta"));
                ntl.setIcon(rs.getString("icon"));
                ntl.setMauSac(rs.getString("mau_sac"));
                ntl.setNguoiTaoId(rs.getInt("nguoi_tao_id"));
                ntl.setNgayTao(rs.getTimestamp("ngay_tao"));
                ntl.setNgayCapNhat(rs.getTimestamp("ngay_cap_nhat"));
                ntl.setTrangThai(rs.getString("trang_thai"));
                ntl.setThuTu(rs.getInt("thu_tu"));
                ntl.setDoiTuongXem(rs.getString("doi_tuong_xem"));
                ntl.setTenNguoiTao(rs.getString("ten_nguoi_tao"));
                ntl.setSoLuongTaiLieu(rs.getInt("so_luong_tai_lieu"));
                list.add(ntl);
            }
        }
        return list;
    }

    public List<NhomTaiLieu> getAllNhomTaiLieuNV() throws SQLException {
        List<NhomTaiLieu> list = new ArrayList<>();

        String sql = "SELECT ntl.*, nv.ho_ten AS ten_nguoi_tao, "
                + "(SELECT COUNT(*) FROM tai_lieu "
                + " WHERE nhom_tai_lieu_id = ntl.id AND trang_thai = 'Hoạt động') AS so_luong_tai_lieu "
                + "FROM nhom_tai_lieu ntl "
                + "LEFT JOIN nhanvien nv ON ntl.nguoi_tao_id = nv.id "
                + "WHERE ntl.trang_thai = 'Hoạt động' "
                + "AND ntl.doi_tuong_xem IN ('Tất cả', 'Chỉ nhân viên') "
                + "ORDER BY ntl.thu_tu, ntl.ten_nhom";

        try (PreparedStatement stmt = cn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                NhomTaiLieu ntl = new NhomTaiLieu();
                ntl.setId(rs.getInt("id"));
                ntl.setTenNhom(rs.getString("ten_nhom"));
                ntl.setMoTa(rs.getString("mo_ta"));
                ntl.setIcon(rs.getString("icon"));
                ntl.setMauSac(rs.getString("mau_sac"));
                ntl.setNguoiTaoId(rs.getInt("nguoi_tao_id"));
                ntl.setNgayTao(rs.getTimestamp("ngay_tao"));
                ntl.setNgayCapNhat(rs.getTimestamp("ngay_cap_nhat"));
                ntl.setTrangThai(rs.getString("trang_thai"));
                ntl.setThuTu(rs.getInt("thu_tu"));
                ntl.setDoiTuongXem(rs.getString("doi_tuong_xem"));
                ntl.setTenNguoiTao(rs.getString("ten_nguoi_tao"));
                ntl.setSoLuongTaiLieu(rs.getInt("so_luong_tai_lieu"));
                list.add(ntl);
            }
        }
        return list;
    }

    /**
     * Lấy nhóm tài liệu theo ID
     */
    public NhomTaiLieu getNhomTaiLieuById(int id) throws SQLException {
        String sql = "SELECT ntl.*, nv.ho_ten as ten_nguoi_tao, "
                + "(SELECT COUNT(*) FROM tai_lieu WHERE nhom_tai_lieu_id = ntl.id AND trang_thai = 'Hoạt động') as so_luong_tai_lieu "
                + "FROM nhom_tai_lieu ntl "
                + "LEFT JOIN nhanvien nv ON ntl.nguoi_tao_id = nv.id "
                + "WHERE ntl.id = ?";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    NhomTaiLieu ntl = new NhomTaiLieu();
                    ntl.setId(rs.getInt("id"));
                    ntl.setTenNhom(rs.getString("ten_nhom"));
                    ntl.setMoTa(rs.getString("mo_ta"));
                    ntl.setIcon(rs.getString("icon"));
                    ntl.setMauSac(rs.getString("mau_sac"));
                    ntl.setNguoiTaoId(rs.getInt("nguoi_tao_id"));
                    ntl.setNgayTao(rs.getTimestamp("ngay_tao"));
                    ntl.setNgayCapNhat(rs.getTimestamp("ngay_cap_nhat"));
                    ntl.setTrangThai(rs.getString("trang_thai"));
                    ntl.setThuTu(rs.getInt("thu_tu"));
                    ntl.setDoiTuongXem(rs.getString("doi_tuong_xem"));
                    ntl.setTenNguoiTao(rs.getString("ten_nguoi_tao"));
                    ntl.setSoLuongTaiLieu(rs.getInt("so_luong_tai_lieu"));
                    return ntl;
                }
            }
        }
        return null;
    }

    /**
     * Kiểm tra thứ tự nhóm tài liệu đã tồn tại chưa
     */
    public boolean isThuTuExists(int thuTu, Integer excludeId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM nhom_tai_lieu WHERE thu_tu = ? AND trang_thai = 'Hoạt động'";
        if (excludeId != null) {
            sql += " AND id != ?";
        }

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, thuTu);
            if (excludeId != null) {
                stmt.setInt(2, excludeId);
            }
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    /**
     * Thêm nhóm tài liệu mới
     */
    public int insertNhomTaiLieu(NhomTaiLieu ntl) throws SQLException {
        String sql = "INSERT INTO nhom_tai_lieu (ten_nhom, mo_ta, icon, mau_sac, nguoi_tao_id, thu_tu, doi_tuong_xem) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement stmt = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, ntl.getTenNhom());
            stmt.setString(2, ntl.getMoTa());
            stmt.setString(3, ntl.getIcon());
            stmt.setString(4, ntl.getMauSac());
            stmt.setInt(5, ntl.getNguoiTaoId());
            stmt.setInt(6, ntl.getThuTu());
            stmt.setString(7, ntl.getDoiTuongXem() != null ? ntl.getDoiTuongXem() : "Tất cả");

            int affectedRows = stmt.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        }
        return -1;
    }

    /**
     * Cập nhật nhóm tài liệu
     */
    public boolean updateNhomTaiLieu(NhomTaiLieu ntl) throws SQLException {
        String sql = "UPDATE nhom_tai_lieu SET ten_nhom = ?, mo_ta = ?, icon = ?, mau_sac = ?, thu_tu = ?, doi_tuong_xem = ? "
                + "WHERE id = ?";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setString(1, ntl.getTenNhom());
            stmt.setString(2, ntl.getMoTa());
            stmt.setString(3, ntl.getIcon());
            stmt.setString(4, ntl.getMauSac());
            stmt.setInt(5, ntl.getThuTu());
            stmt.setString(6, ntl.getDoiTuongXem() != null ? ntl.getDoiTuongXem() : "Tất cả");
            stmt.setInt(7, ntl.getId());

            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Xóa nhóm tài liệu (soft delete)
     */
    public boolean deleteNhomTaiLieu(int id) throws SQLException {
        String sql = "UPDATE nhom_tai_lieu SET trang_thai = 'Đã xóa' WHERE id = ?";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Lấy tất cả tài liệu theo nhóm
     */
    public List<TaiLieu> getTaiLieuByNhomId(int nhomId) throws SQLException {
        List<TaiLieu> list = new ArrayList<>();
        String sql = "SELECT tl.*, nv.ho_ten as ten_nguoi_tao, nv.avatar_url as avatar_nguoi_tao, ntl.ten_nhom as ten_nhom_tai_lieu "
                + "FROM tai_lieu tl "
                + "LEFT JOIN nhanvien nv ON tl.nguoi_tao_id = nv.id "
                + "LEFT JOIN nhom_tai_lieu ntl ON tl.nhom_tai_lieu_id = ntl.id "
                + "WHERE tl.trang_thai = 'Hoạt động' AND tl.nhom_tai_lieu_id = ? "
                + "ORDER BY tl.ngay_tao DESC";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nhomId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    TaiLieu tl = new TaiLieu();
                    tl.setId(rs.getInt("id"));
                    tl.setNhomTaiLieuId(rs.getInt("nhom_tai_lieu_id"));
                    tl.setTenTaiLieu(rs.getString("ten_tai_lieu"));
                    tl.setLoaiTaiLieu(rs.getString("loai_tai_lieu"));
                    tl.setMoTa(rs.getString("mo_ta"));
                    tl.setFileName(rs.getString("file_name"));
                    tl.setFilePath(rs.getString("file_path"));
                    tl.setFileSize(rs.getLong("file_size"));
                    tl.setFileType(rs.getString("file_type"));
                    tl.setNguoiTaoId(rs.getInt("nguoi_tao_id"));
                    tl.setNgayTao(rs.getTimestamp("ngay_tao"));
                    tl.setNgayCapNhat(rs.getTimestamp("ngay_cap_nhat"));
                    tl.setTrangThai(rs.getString("trang_thai"));
                    tl.setLuotXem(rs.getInt("luot_xem"));
                    tl.setLuotTai(rs.getInt("luot_tai"));
                    tl.setDoiTuongXem(rs.getString("doi_tuong_xem"));
                    tl.setTenNguoiTao(rs.getString("ten_nguoi_tao"));
                    tl.setAvatarNguoiTao(rs.getString("avatar_nguoi_tao"));
                    tl.setTenNhomTaiLieu(rs.getString("ten_nhom_tai_lieu"));
                    list.add(tl);
                }
            }
        }
        return list;
    }

    /**
     * Tìm kiếm tài liệu theo từ khóa trong một nhóm
     */
    public List<TaiLieu> searchTaiLieuInNhom(int nhomId, String keyword) throws SQLException {
        List<TaiLieu> list = new ArrayList<>();
        String sql = "SELECT tl.*, nv.ho_ten as ten_nguoi_tao, nv.avatar_url as avatar_nguoi_tao, ntl.ten_nhom as ten_nhom_tai_lieu "
                + "FROM tai_lieu tl "
                + "LEFT JOIN nhanvien nv ON tl.nguoi_tao_id = nv.id "
                + "LEFT JOIN nhom_tai_lieu ntl ON tl.nhom_tai_lieu_id = ntl.id "
                + "WHERE tl.trang_thai = 'Hoạt động' AND tl.nhom_tai_lieu_id = ? "
                + "AND (tl.ten_tai_lieu LIKE ? OR tl.mo_ta LIKE ? OR tl.loai_tai_lieu LIKE ?) "
                + "ORDER BY tl.ngay_tao DESC";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            String searchPattern = "%" + keyword + "%";
            stmt.setInt(1, nhomId);
            stmt.setString(2, searchPattern);
            stmt.setString(3, searchPattern);
            stmt.setString(4, searchPattern);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    TaiLieu tl = new TaiLieu();
                    tl.setId(rs.getInt("id"));
                    tl.setNhomTaiLieuId(rs.getInt("nhom_tai_lieu_id"));
                    tl.setTenTaiLieu(rs.getString("ten_tai_lieu"));
                    tl.setLoaiTaiLieu(rs.getString("loai_tai_lieu"));
                    tl.setMoTa(rs.getString("mo_ta"));
                    tl.setFileName(rs.getString("file_name"));
                    tl.setFilePath(rs.getString("file_path"));
                    tl.setFileSize(rs.getLong("file_size"));
                    tl.setFileType(rs.getString("file_type"));
                    tl.setNguoiTaoId(rs.getInt("nguoi_tao_id"));
                    tl.setNgayTao(rs.getTimestamp("ngay_tao"));
                    tl.setNgayCapNhat(rs.getTimestamp("ngay_cap_nhat"));
                    tl.setTrangThai(rs.getString("trang_thai"));
                    tl.setLuotXem(rs.getInt("luot_xem"));
                    tl.setLuotTai(rs.getInt("luot_tai"));
                    tl.setTenNguoiTao(rs.getString("ten_nguoi_tao"));
                    tl.setAvatarNguoiTao(rs.getString("avatar_nguoi_tao"));
                    tl.setTenNhomTaiLieu(rs.getString("ten_nhom_tai_lieu"));
                    list.add(tl);
                }
            }
        }
        return list;
    }

    // ============================================
    // QUẢN LÝ ĐƠN XIN NGHỈ PHÉP
    // ============================================
    /**
     * Lấy danh sách tất cả đơn nghỉ phép (cho Admin)
     */
    public List<Map<String, Object>> getAllDonNghiPhep(String trangThai, int thang, int nam) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT d.*, nv.ho_ten AS ten_nhan_vien, nv.email AS email_nhan_vien, ");
        sql.append("nv.avatar_url, pb.ten_phong AS ten_phong_ban, ");
        sql.append("nd.ho_ten AS ten_nguoi_duyet ");
        sql.append("FROM don_nghi_phep d ");
        sql.append("LEFT JOIN nhanvien nv ON d.nhan_vien_id = nv.id ");
        sql.append("LEFT JOIN phong_ban pb ON nv.phong_ban_id = pb.id ");
        sql.append("LEFT JOIN nhanvien nd ON d.nguoi_duyet_id = nd.id ");
        sql.append("WHERE 1=1 ");

        if (trangThai != null && !trangThai.isEmpty() && !trangThai.equals("all")) {
            sql.append("AND d.trang_thai = ? ");
        }
        // ✅ FIX: Lọc theo năm và tháng riêng biệt
        if (thang > 0 && nam > 0) {
            sql.append("AND (MONTH(d.ngay_bat_dau) = ? OR MONTH(d.ngay_ket_thuc) = ?) ");
            sql.append("AND (YEAR(d.ngay_bat_dau) = ? OR YEAR(d.ngay_ket_thuc) = ?) ");
        } else if (nam > 0) {
            // Chỉ lọc theo năm khi không có tháng
            sql.append("AND (YEAR(d.ngay_bat_dau) = ? OR YEAR(d.ngay_ket_thuc) = ?) ");
        }
        sql.append("ORDER BY d.thoi_gian_tao DESC");

        try (PreparedStatement stmt = cn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (trangThai != null && !trangThai.isEmpty() && !trangThai.equals("all")) {
                stmt.setString(paramIndex++, trangThai);
            }
            if (thang > 0 && nam > 0) {
                stmt.setInt(paramIndex++, thang);
                stmt.setInt(paramIndex++, thang);
                stmt.setInt(paramIndex++, nam);
                stmt.setInt(paramIndex++, nam);
            } else if (nam > 0) {
                // Chỉ bind năm
                stmt.setInt(paramIndex++, nam);
                stmt.setInt(paramIndex++, nam);
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> don = new HashMap<>();
                    don.put("id", rs.getInt("id"));
                    don.put("nhan_vien_id", rs.getInt("nhan_vien_id"));
                    don.put("ten_nhan_vien", rs.getString("ten_nhan_vien"));
                    don.put("email_nhan_vien", rs.getString("email_nhan_vien"));
                    don.put("avatar_url", rs.getString("avatar_url"));
                    don.put("ten_phong_ban", rs.getString("ten_phong_ban"));
                    don.put("loai_phep", rs.getString("loai_phep"));
                    don.put("ngay_bat_dau", rs.getDate("ngay_bat_dau"));
                    don.put("ngay_ket_thuc", rs.getDate("ngay_ket_thuc"));
                    don.put("so_ngay", rs.getBigDecimal("so_ngay"));
                    don.put("ly_do", rs.getString("ly_do"));
                    don.put("trang_thai", rs.getString("trang_thai"));
                    don.put("ly_do_tu_choi", rs.getString("ly_do_tu_choi"));
                    don.put("nguoi_duyet_id", rs.getInt("nguoi_duyet_id"));
                    don.put("ten_nguoi_duyet", rs.getString("ten_nguoi_duyet"));
                    don.put("thoi_gian_tao", rs.getTimestamp("thoi_gian_tao"));
                    don.put("thoi_gian_duyet", rs.getTimestamp("thoi_gian_duyet"));
                    don.put("ghi_chu", rs.getString("ghi_chu"));
                    list.add(don);
                }
            }
        }
        return list;
    }

    /**
     * Lấy danh sách đơn nghỉ phép của nhân viên cụ thể
     */
    public List<Map<String, Object>> getDonNghiPhepByNhanVien(int nhanVienId) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();

        String sql = "SELECT d.*, nd.ho_ten AS ten_nguoi_duyet "
                + "FROM don_nghi_phep d "
                + "LEFT JOIN nhanvien nd ON d.nguoi_duyet_id = nd.id "
                + "WHERE d.nhan_vien_id = ? "
                + "ORDER BY d.thoi_gian_tao DESC";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nhanVienId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> don = new HashMap<>();
                    don.put("id", rs.getInt("id"));
                    don.put("loai_phep", rs.getString("loai_phep"));
                    don.put("ngay_bat_dau", rs.getDate("ngay_bat_dau"));
                    don.put("ngay_ket_thuc", rs.getDate("ngay_ket_thuc"));
                    don.put("so_ngay", rs.getBigDecimal("so_ngay"));
                    don.put("ly_do", rs.getString("ly_do"));
                    don.put("trang_thai", rs.getString("trang_thai"));
                    don.put("ly_do_tu_choi", rs.getString("ly_do_tu_choi"));
                    don.put("ten_nguoi_duyet", rs.getString("ten_nguoi_duyet"));
                    don.put("thoi_gian_tao", rs.getTimestamp("thoi_gian_tao"));
                    don.put("thoi_gian_duyet", rs.getTimestamp("thoi_gian_duyet"));
                    don.put("ghi_chu", rs.getString("ghi_chu"));
                    list.add(don);
                }
            }
        }
        return list;
    }

    /**
     * Kiểm tra xem có đơn nghỉ phép nào trùng khoảng thời gian không
     */
    public boolean hasOverlappingLeaveRequest(int nhanVienId, java.sql.Date ngayBatDau, java.sql.Date ngayKetThuc, Integer excludeDonId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM don_nghi_phep " +
                     "WHERE nhan_vien_id = ? " +
                     "AND trang_thai IN ('cho_duyet', 'da_duyet') " +
                     "AND ((ngay_bat_dau <= ? AND ngay_ket_thuc >= ?) " +
                     "OR (ngay_bat_dau <= ? AND ngay_ket_thuc >= ?) " +
                     "OR (ngay_bat_dau >= ? AND ngay_ket_thuc <= ?))";
        
        if (excludeDonId != null) {
            sql += " AND id != ?";
        }

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nhanVienId);
            stmt.setDate(2, ngayBatDau);
            stmt.setDate(3, ngayBatDau);
            stmt.setDate(4, ngayKetThuc);
            stmt.setDate(5, ngayKetThuc);
            stmt.setDate(6, ngayBatDau);
            stmt.setDate(7, ngayKetThuc);
            
            if (excludeDonId != null) {
                stmt.setInt(8, excludeDonId);
            }
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    /**
     * Tạo đơn xin nghỉ phép mới
     */
    public int taoDonNghiPhep(int nhanVienId, String loaiPhep, java.sql.Date ngayBatDau,
            java.sql.Date ngayKetThuc, double soNgay, String lyDo, Integer nguoiTaoId, String ghiChu) throws SQLException {

        String sql = "INSERT INTO don_nghi_phep (nhan_vien_id, loai_phep, ngay_bat_dau, ngay_ket_thuc, "
                + "so_ngay, ly_do, trang_thai, nguoi_tao_id, ghi_chu) VALUES (?, ?, ?, ?, ?, ?, 'cho_duyet', ?, ?)";

        try (PreparedStatement stmt = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, nhanVienId);
            stmt.setString(2, loaiPhep);
            stmt.setDate(3, ngayBatDau);
            stmt.setDate(4, ngayKetThuc);
            stmt.setDouble(5, soNgay);
            stmt.setString(6, lyDo);
            if (nguoiTaoId != null) {
                stmt.setInt(7, nguoiTaoId);
            } else {
                stmt.setNull(7, java.sql.Types.INTEGER);
            }
            stmt.setString(8, ghiChu);

            int affectedRows = stmt.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        return generatedKeys.getInt(1);
                    }
                }
            }
        }
        return -1;
    }

    /**
     * Duyệt đơn nghỉ phép
     */
    public boolean duyetDonNghiPhep(int donId, int nguoiDuyetId) throws SQLException {
        String sql = "UPDATE don_nghi_phep SET trang_thai = 'da_duyet', nguoi_duyet_id = ?, "
                + "thoi_gian_duyet = NOW() WHERE id = ? AND trang_thai = 'cho_duyet'";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nguoiDuyetId);
            stmt.setInt(2, donId);
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Từ chối đơn nghỉ phép
     */
    public boolean tuChoiDonNghiPhep(int donId, int nguoiDuyetId, String lyDoTuChoi) throws SQLException {
        String sql = "UPDATE don_nghi_phep SET trang_thai = 'tu_choi', nguoi_duyet_id = ?, "
                + "ly_do_tu_choi = ?, thoi_gian_duyet = NOW() WHERE id = ? AND trang_thai = 'cho_duyet'";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nguoiDuyetId);
            stmt.setString(2, lyDoTuChoi);
            stmt.setInt(3, donId);
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Lấy thông tin chi tiết đơn nghỉ phép
     */
    public Map<String, Object> getDonNghiPhepById(int donId) throws SQLException {
        String sql = "SELECT d.*, nv.ho_ten AS ten_nhan_vien, nv.email AS email_nhan_vien, "
                + "nv.avatar_url, pb.ten_phong AS ten_phong_ban, nd.ho_ten AS ten_nguoi_duyet "
                + "FROM don_nghi_phep d "
                + "LEFT JOIN nhanvien nv ON d.nhan_vien_id = nv.id "
                + "LEFT JOIN phong_ban pb ON nv.phong_ban_id = pb.id "
                + "LEFT JOIN nhanvien nd ON d.nguoi_duyet_id = nd.id "
                + "WHERE d.id = ?";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, donId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> don = new HashMap<>();
                    don.put("id", rs.getInt("id"));
                    don.put("nhan_vien_id", rs.getInt("nhan_vien_id"));
                    don.put("ten_nhan_vien", rs.getString("ten_nhan_vien"));
                    don.put("email_nhan_vien", rs.getString("email_nhan_vien"));
                    don.put("avatar_url", rs.getString("avatar_url"));
                    don.put("ten_phong_ban", rs.getString("ten_phong_ban"));
                    don.put("loai_phep", rs.getString("loai_phep"));
                    don.put("ngay_bat_dau", rs.getDate("ngay_bat_dau"));
                    don.put("ngay_ket_thuc", rs.getDate("ngay_ket_thuc"));
                    don.put("so_ngay", rs.getBigDecimal("so_ngay"));
                    don.put("ly_do", rs.getString("ly_do"));
                    don.put("trang_thai", rs.getString("trang_thai"));
                    don.put("ly_do_tu_choi", rs.getString("ly_do_tu_choi"));
                    don.put("ten_nguoi_duyet", rs.getString("ten_nguoi_duyet"));
                    don.put("thoi_gian_tao", rs.getTimestamp("thoi_gian_tao"));
                    don.put("thoi_gian_duyet", rs.getTimestamp("thoi_gian_duyet"));
                    don.put("ghi_chu", rs.getString("ghi_chu"));
                    return don;
                }
            }
        }
        return null;
    }

    /**
     * Lấy thông tin ngày phép của nhân viên trong năm Bao gồm cả ngày phép năm
     * cũ chuyển sang
     */
    public Map<String, Object> getNgayPhepNam(int nhanVienId, int nam) throws SQLException {
        // Kiểm tra nếu chưa có bản ghi thì tạo mới
        String checkSql = "SELECT * FROM ngay_phep_nam WHERE nhan_vien_id = ? AND nam = ?";
        try (PreparedStatement checkStmt = cn.prepareStatement(checkSql)) {
            checkStmt.setInt(1, nhanVienId);
            checkStmt.setInt(2, nam);

            try (ResultSet rs = checkStmt.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> result = new HashMap<>();
                    result.put("id", rs.getInt("id"));
                    result.put("nhan_vien_id", rs.getInt("nhan_vien_id"));
                    result.put("nam", rs.getInt("nam"));
                    result.put("tong_ngay_phep", rs.getBigDecimal("tong_ngay_phep"));
                    result.put("ngay_phep_da_dung", rs.getBigDecimal("ngay_phep_da_dung"));
                    result.put("ngay_phep_con_lai", rs.getBigDecimal("ngay_phep_con_lai"));
                    result.put("ngay_phep_nam_truoc", rs.getBigDecimal("ngay_phep_nam_truoc"));
                    result.put("da_cong_phep_dau_nam", rs.getInt("da_cong_phep_dau_nam"));
                    return result;
                }
            }
        }

        // Nếu chưa có, tạo bản ghi mới với số ngày phép = 0 (sẽ được cộng bởi job tự động)
        String insertSql = "INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc, da_cong_phep_dau_nam) "
                + "VALUES (?, ?, 0.0, 0.0, 0.0, 0.0, 0)";
        try (PreparedStatement insertStmt = cn.prepareStatement(insertSql)) {
            insertStmt.setInt(1, nhanVienId);
            insertStmt.setInt(2, nam);
            insertStmt.executeUpdate();
        }

        // Lấy lại dữ liệu sau khi insert
        try (PreparedStatement stmt = cn.prepareStatement(checkSql)) {
            stmt.setInt(1, nhanVienId);
            stmt.setInt(2, nam);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> result = new HashMap<>();
                    result.put("id", rs.getInt("id"));
                    result.put("nhan_vien_id", rs.getInt("nhan_vien_id"));
                    result.put("nam", rs.getInt("nam"));
                    result.put("tong_ngay_phep", rs.getBigDecimal("tong_ngay_phep"));
                    result.put("ngay_phep_da_dung", rs.getBigDecimal("ngay_phep_da_dung"));
                    result.put("ngay_phep_con_lai", rs.getBigDecimal("ngay_phep_con_lai"));
                    result.put("ngay_phep_nam_truoc", rs.getBigDecimal("ngay_phep_nam_truoc"));
                    result.put("da_cong_phep_dau_nam", rs.getInt("da_cong_phep_dau_nam"));
                    return result;
                }
            }
        }
        return null;
    }

    /**
     * Hủy đơn xin nghỉ phép (chỉ hủy được đơn chờ duyệt)
     */
    public boolean huyDonNghiPhep(int donId) throws SQLException {
        String sql = "UPDATE don_nghi_phep SET trang_thai = 'da_huy' WHERE id = ? AND trang_thai = 'cho_duyet'";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, donId);
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Cập nhật số ngày phép đã dùng từ ID đơn (tính tổng từ các đơn đã duyệt)
     */
    public boolean capNhatNgayPhepDaDung(int donId) throws SQLException {
        // Lấy thông tin đơn
        String getDonSql = "SELECT nhan_vien_id, so_ngay, ngay_bat_dau FROM don_nghi_phep WHERE id = ?";

        try (PreparedStatement getStmt = cn.prepareStatement(getDonSql)) {
            getStmt.setInt(1, donId);

            try (ResultSet rs = getStmt.executeQuery()) {
                if (rs.next()) {
                    int nhanVienId = rs.getInt("nhan_vien_id");
                    double soNgay = rs.getDouble("so_ngay");
                    Date ngayBatDau = rs.getDate("ngay_bat_dau");

                    // Tính năm từ ngày bắt đầu
                    Calendar cal = Calendar.getInstance();
                    cal.setTime(new java.util.Date(ngayBatDau.getTime()));
                    int nam = cal.get(Calendar.YEAR);

                    // Cập nhật ngày phép đã dùng
                    String updateSql = "UPDATE ngay_phep_nam SET "
                            + "ngay_phep_da_dung = ngay_phep_da_dung + ?, "
                            + "ngay_phep_con_lai = tong_ngay_phep - (ngay_phep_da_dung + ?) "
                            + "WHERE nhan_vien_id = ? AND nam = ?";

                    try (PreparedStatement updateStmt = cn.prepareStatement(updateSql)) {
                        updateStmt.setDouble(1, soNgay);
                        updateStmt.setDouble(2, soNgay);
                        updateStmt.setInt(3, nhanVienId);
                        updateStmt.setInt(4, nam);
                        return updateStmt.executeUpdate() > 0;
                    }
                }
            }
        }
        return false;
    }

    /**
     * Cập nhật số ngày phép đã dùng theo ID nhân viên và năm
     */
    public boolean capNhatNgayPhepDaDung(int nhanVienId, int nam, double soNgayThemVao) throws SQLException {
        String sql = "UPDATE ngay_phep_nam SET "
                + "ngay_phep_da_dung = ngay_phep_da_dung + ?, "
                + "ngay_phep_con_lai = tong_ngay_phep - (ngay_phep_da_dung + ?) "
                + "WHERE nhan_vien_id = ? AND nam = ?";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setDouble(1, soNgayThemVao);
            stmt.setDouble(2, soNgayThemVao);
            stmt.setInt(3, nhanVienId);
            stmt.setInt(4, nam);
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Cập nhật phép năm với ưu tiên trừ phép năm trước trước Nếu còn phép năm
     * trước, trừ phép năm trước trước Nếu phép năm trước không đủ hoặc hết, mới
     * trừ phép năm hiện tại
     */
    public boolean capNhatNgayPhepDaDungUuTien(int nhanVienId, int nam, double soNgayDung) throws SQLException {
        try {
            String sqlGetPhep = "SELECT ngay_phep_nam_truoc, ngay_phep_da_dung, tong_ngay_phep "
                    + "FROM ngay_phep_nam WHERE nhan_vien_id = ? AND nam = ?";

            double phepNamTruoc = 0.0;
            double phepDaDung = 0.0;
            double tongPhep = 0.0;

            try (PreparedStatement stmt = cn.prepareStatement(sqlGetPhep)) {
                stmt.setInt(1, nhanVienId);
                stmt.setInt(2, nam);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        phepNamTruoc = rs.getDouble("ngay_phep_nam_truoc");
                        phepDaDung = rs.getDouble("ngay_phep_da_dung");
                        tongPhep = rs.getDouble("tong_ngay_phep");
                    }
                }
            }

            double phepNamTruocMoi = phepNamTruoc;
            double phepDaDungMoi = phepDaDung; // Khởi tạo với giá trị hiện tại

            // ✅ ƯU TIÊN TRỪ PHÉP NĂM TRƯỚC TRƯỚC
            if (phepNamTruoc >= soNgayDung) {
                // Phép năm trước đủ, trừ hoàn toàn từ năm trước
                phepNamTruocMoi = phepNamTruoc - soNgayDung;
                // ⚠️ QUAN TRỌNG: Cũng phải tính ngay_phep_da_dung!
                phepDaDungMoi = phepDaDung + soNgayDung;
            } else if (phepNamTruoc > 0) {
                // Phép năm trước không đủ, trừ hết phép năm trước + phần còn lại từ phép năm nay
                double soNgayTruPhepNay = soNgayDung - phepNamTruoc;
                phepNamTruocMoi = 0.0;
                phepDaDungMoi = phepDaDung + soNgayTruPhepNay;
            } else {
                // Không có phép năm trước, trừ toàn bộ từ phép năm nay
                phepDaDungMoi = phepDaDung + soNgayDung;
            }

            // ✅ Tính phép năm hiện tại còn lại (KHÔNG cộng phép năm cũ)
            double phepConLaiMoi = tongPhep - phepDaDungMoi;
            if (phepConLaiMoi < 0) {
                phepConLaiMoi = 0;
            }

            String sqlUpdate = "UPDATE ngay_phep_nam SET "
                    + "ngay_phep_nam_truoc = ?, "
                    + "ngay_phep_da_dung = ?, "
                    + "ngay_phep_con_lai = ? "
                    + "WHERE nhan_vien_id = ? AND nam = ?";

            try (PreparedStatement stmt = cn.prepareStatement(sqlUpdate)) {
                stmt.setDouble(1, phepNamTruocMoi);
                stmt.setDouble(2, phepDaDungMoi);
                stmt.setDouble(3, phepConLaiMoi);
                stmt.setInt(4, nhanVienId);
                stmt.setInt(5, nam);
                stmt.executeUpdate();
            }

            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Đếm số đơn nghỉ phép theo trạng thái
     */
    public Map<String, Integer> thongKeDonNghiPhep() throws SQLException {
        Map<String, Integer> stats = new HashMap<>();

        String sql = "SELECT trang_thai, COUNT(*) as so_luong FROM don_nghi_phep GROUP BY trang_thai";

        try (PreparedStatement stmt = cn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                stats.put(rs.getString("trang_thai"), rs.getInt("so_luong"));
            }
        }

        // Đảm bảo có đủ các key
        stats.putIfAbsent("cho_duyet", 0);
        stats.putIfAbsent("da_duyet", 0);
        stats.putIfAbsent("tu_choi", 0);

        return stats;
    }

    /**
     * Lấy thống kê ngày phép của tất cả nhân viên cho admin
     *
     * @param nam Năm cần xem thống kê
     * @return Danh sách thông tin ngày phép của tất cả nhân viên
     */
    public List<Map<String, Object>> getThongKeNgayPhepAllNhanVien(int nam) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();

        String sql = "SELECT nv.id, nv.ho_ten, nv.email, nv.avatar_url, "
                + "pb.ten_phong AS ten_phong_ban, nv.chuc_vu, nv.ngay_vao_lam, "
                + "COALESCE(np.tong_ngay_phep, 0) AS tong_ngay_phep, "
                + "COALESCE(np.ngay_phep_da_dung, 0) AS ngay_phep_da_dung, "
                + "COALESCE(np.ngay_phep_con_lai, 0) AS ngay_phep_con_lai, "
                + "COALESCE(np.ngay_phep_nam_truoc, 0) AS ngay_phep_nam_truoc, "
                + "np.da_cong_phep_dau_nam "
                + "FROM nhanvien nv "
                + "LEFT JOIN phong_ban pb ON nv.phong_ban_id = pb.id "
                + "LEFT JOIN ngay_phep_nam np ON nv.id = np.nhan_vien_id AND np.nam = ? "
                + "WHERE nv.trang_thai_lam_viec = 'Đang làm' "
                + "ORDER BY nv.ho_ten ASC";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nam);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> emp = new HashMap<>();
                    emp.put("id", rs.getInt("id"));
                    emp.put("ho_ten", rs.getString("ho_ten"));
                    emp.put("email", rs.getString("email"));
                    emp.put("avatar_url", rs.getString("avatar_url"));
                    emp.put("ten_phong_ban", rs.getString("ten_phong_ban"));
                    emp.put("chuc_vu", rs.getString("chuc_vu"));
                    emp.put("ngay_vao_lam", rs.getDate("ngay_vao_lam"));
                    emp.put("tong_ngay_phep", rs.getBigDecimal("tong_ngay_phep"));
                    emp.put("ngay_phep_da_dung", rs.getBigDecimal("ngay_phep_da_dung"));
                    emp.put("ngay_phep_con_lai", rs.getBigDecimal("ngay_phep_con_lai"));
                    emp.put("ngay_phep_nam_truoc", rs.getBigDecimal("ngay_phep_nam_truoc"));
                    emp.put("da_cong_phep_dau_nam", rs.getInt("da_cong_phep_dau_nam"));

                    // Tính tổng phép còn lại (bao gồm phép năm trước)
                    double conLai = rs.getDouble("ngay_phep_con_lai");
                    double namTruoc = rs.getDouble("ngay_phep_nam_truoc");
                    emp.put("tong_phep_con_lai", conLai + namTruoc);

                    list.add(emp);
                }
            }
        }

        return list;
    }

    /**
     * Xóa đơn nghỉ phép (chỉ được xóa đơn đang chờ duyệt)
     */
    public boolean xoaDonNghiPhep(int donId, int nhanVienId) throws SQLException {
        String sql = "DELETE FROM don_nghi_phep WHERE id = ? AND nhan_vien_id = ? AND trang_thai = 'cho_duyet'";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, donId);
            stmt.setInt(2, nhanVienId);
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Tạo đơn nghỉ phép từ quản lý/admin (trạng thái da_duyet) Được sử dụng khi
     * admin tạo lệnh nghỉ trực tiếp cho nhân viên
     */
    public int taoDonNghiPhepQuanLy(int nhanVienId, String loaiPhep, java.sql.Date ngayBatDau,
            java.sql.Date ngayKetThuc, double soNgay, String lyDo, Integer nguoiTaoId, String ghiChu) throws SQLException {

        String sql = "INSERT INTO don_nghi_phep (nhan_vien_id, loai_phep, ngay_bat_dau, ngay_ket_thuc, "
                + "so_ngay, ly_do, trang_thai, nguoi_duyet_id, ghi_chu, thoi_gian_duyet) VALUES (?, ?, ?, ?, ?, ?, 'da_duyet', ?, ?, NOW())";

        try (PreparedStatement stmt = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, nhanVienId);
            stmt.setString(2, loaiPhep);
            stmt.setDate(3, ngayBatDau);
            stmt.setDate(4, ngayKetThuc);
            stmt.setDouble(5, soNgay);
            stmt.setString(6, lyDo);
            if (nguoiTaoId != null) {
                stmt.setInt(7, nguoiTaoId);
            } else {
                stmt.setNull(7, java.sql.Types.INTEGER);
            }
            stmt.setString(8, ghiChu);

            int affectedRows = stmt.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        return generatedKeys.getInt(1);
                    }
                }
            }
        }
        return -1;
    }

    /**
     * Lấy thông tin nhân viên theo ID
     */
    public Map<String, Object> getNhanVienById(int nhanVienId) throws SQLException {
        Map<String, Object> nhanVien = new HashMap<>();
        String sql = "SELECT nv.*, pb.ten_phong "
                + "FROM nhanvien nv "
                + "LEFT JOIN phong_ban pb ON nv.phong_ban_id = pb.id "
                + "WHERE nv.id = ?";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nhanVienId);
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

    /**
     * Lấy tất cả dự án với công việc và tiến độ
     */
    public List<Map<String, Object>> getAllDuAnWithTasks() throws SQLException {
        List<Map<String, Object>> duAnList = new ArrayList<>();

        // Truy vấn tất cả dự án
        String sqlDuAn = """
            SELECT da.id, da.ten_du_an, da.mo_ta, da.nhom_du_an, 
                   da.phong_ban, da.trang_thai_duan, da.ngay_bat_dau, da.ngay_ket_thuc,
                   nv.ho_ten as lead_name
            FROM du_an da
            LEFT JOIN nhanvien nv ON da.lead_id = nv.id
            WHERE da.id <> 1
            ORDER BY 
                CASE da.trang_thai_duan
                    WHEN 'Đang thực hiện' THEN 1
                    WHEN 'Tạm ngưng' THEN 2
                    WHEN 'Đã hoàn thành' THEN 3
                    ELSE 4
                END,
                da.ngay_tao DESC
        """;

        try (PreparedStatement psDuAn = cn.prepareStatement(sqlDuAn); ResultSet rsDuAn = psDuAn.executeQuery()) {

            while (rsDuAn.next()) {
                Map<String, Object> duAn = new HashMap<>();
                int duAnId = rsDuAn.getInt("id");

                duAn.put("id", duAnId);
                duAn.put("ten_du_an", rsDuAn.getString("ten_du_an"));
                duAn.put("mo_ta", rsDuAn.getString("mo_ta"));
                duAn.put("nhom_du_an", rsDuAn.getString("nhom_du_an"));
                duAn.put("phong_ban", rsDuAn.getString("phong_ban"));
                duAn.put("trang_thai_duan", rsDuAn.getString("trang_thai_duan"));
                duAn.put("ngay_bat_dau", rsDuAn.getDate("ngay_bat_dau"));
                duAn.put("ngay_ket_thuc", rsDuAn.getDate("ngay_ket_thuc"));
                duAn.put("lead_name", rsDuAn.getString("lead_name"));

                // Tính tiến độ dự án
                double tienDo = tinhTienDoDuAn(duAnId);
                duAn.put("tien_do", tienDo);

                // Lấy danh sách công việc của dự án
                List<Map<String, Object>> congViecList = getCongViecByDuAn(duAnId);
                duAn.put("cong_viec", congViecList);

                duAnList.add(duAn);
            }
        }

        return duAnList;
    }

    /**
     * Tính tiến độ dự án dựa trên công việc
     */
    private double tinhTienDoDuAn(int duAnId) throws SQLException {
        String sql = """
            SELECT 
                COUNT(*) as tong_cv,
                SUM(CASE WHEN cv.trang_thai = 'Đã hoàn thành' THEN 1 ELSE 0 END) as cv_hoan_thanh
            FROM cong_viec cv
            WHERE cv.du_an_id = ?
        """;

        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, duAnId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int tongCV = rs.getInt("tong_cv");
                    int cvHoanThanh = rs.getInt("cv_hoan_thanh");

                    if (tongCV > 0) {
                        return Math.round((cvHoanThanh * 100.0 / tongCV) * 10) / 10.0;
                    }
                }
            }
        }

        return 0.0;
    }

    /**
     * Lấy danh sách công việc của một dự án
     */
    private List<Map<String, Object>> getCongViecByDuAn(int duAnId) throws SQLException {
        List<Map<String, Object>> congViecList = new ArrayList<>();

        String sql = """
            SELECT 
                cv.id, cv.ten_cong_viec, cv.mo_ta, cv.trang_thai, 
                cv.trang_thai_duyet, cv.muc_do_uu_tien,
                cv.ngay_bat_dau, cv.han_hoan_thanh, cv.ngay_hoan_thanh,
                nv.ho_ten as nguoi_giao_name,
                pb.ten_phong as phong_ban_name,
                (SELECT GROUP_CONCAT(nv2.ho_ten SEPARATOR ', ')
                 FROM cong_viec_nguoi_nhan cvnn
                 JOIN nhanvien nv2 ON cvnn.nhan_vien_id = nv2.id
                 WHERE cvnn.cong_viec_id = cv.id) as nguoi_nhan_names
            FROM cong_viec cv
            LEFT JOIN nhanvien nv ON cv.nguoi_giao_id = nv.id
            LEFT JOIN phong_ban pb ON cv.phong_ban_id = pb.id
            WHERE cv.du_an_id = ?
            ORDER BY 
                CASE cv.trang_thai
                    WHEN 'Đang thực hiện' THEN 1
                    WHEN 'Chưa bắt đầu' THEN 2
                    WHEN 'Trễ hạn' THEN 3
                    WHEN 'Đã hoàn thành' THEN 4
                    ELSE 5
                END,
                cv.ngay_tao DESC
        """;

        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, duAnId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> congViec = new HashMap<>();
                    int congViecId = rs.getInt("id");

                    congViec.put("id", congViecId);
                    congViec.put("ten_cong_viec", rs.getString("ten_cong_viec"));
                    congViec.put("mo_ta", rs.getString("mo_ta"));
                    congViec.put("trang_thai", rs.getString("trang_thai"));
                    congViec.put("trang_thai_duyet", rs.getString("trang_thai_duyet"));
                    congViec.put("muc_do_uu_tien", rs.getString("muc_do_uu_tien"));
                    congViec.put("ngay_bat_dau", rs.getDate("ngay_bat_dau"));
                    congViec.put("han_hoan_thanh", rs.getDate("han_hoan_thanh"));
                    congViec.put("ngay_hoan_thanh", rs.getDate("ngay_hoan_thanh"));
                    congViec.put("nguoi_giao_name", rs.getString("nguoi_giao_name"));
                    congViec.put("phong_ban_name", rs.getString("phong_ban_name"));
                    congViec.put("nguoi_nhan_names", rs.getString("nguoi_nhan_names"));

                    // Tính tiến độ công việc
                    double tienDo = tinhTienDoCongViec(congViecId);
                    congViec.put("tien_do", tienDo);

                    // Lấy danh sách quy trình con
                    List<Map<String, Object>> quyTrinhList = getQuyTrinhByCongViec(congViecId);
                    congViec.put("quy_trinh", quyTrinhList);

                    congViecList.add(congViec);
                }
            }
        }

        return congViecList;
    }

    /**
     * Tính tiến độ công việc dựa trên quy trình
     */
    private double tinhTienDoCongViec(int congViecId) throws SQLException {
        String sql = """
            SELECT 
                COUNT(*) as tong_qt,
                SUM(CASE WHEN trang_thai = 'Đã hoàn thành' THEN 1 ELSE 0 END) as qt_hoan_thanh
            FROM cong_viec_quy_trinh
            WHERE cong_viec_id = ?
        """;

        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, congViecId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int tongQT = rs.getInt("tong_qt");
                    int qtHoanThanh = rs.getInt("qt_hoan_thanh");

                    if (tongQT > 0) {
                        return Math.round((qtHoanThanh * 100.0 / tongQT) * 10) / 10.0;
                    } else {
                        // Nếu không có quy trình thì tính theo trạng thái
                        String sqlTrangThai = "SELECT trang_thai FROM cong_viec WHERE id = ?";
                        try (PreparedStatement psTS = cn.prepareStatement(sqlTrangThai)) {
                            psTS.setInt(1, congViecId);
                            try (ResultSet rsTS = psTS.executeQuery()) {
                                if (rsTS.next()) {
                                    String trangThai = rsTS.getString("trang_thai");
                                    switch (trangThai) {
                                        case "Đã hoàn thành":
                                            return 100.0;
                                        case "Đang thực hiện":
                                            return 50.0;
                                        default:
                                            return 0.0;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        return 0.0;
    }

    /**
     * Lấy danh sách quy trình của một công việc
     */
    private List<Map<String, Object>> getQuyTrinhByCongViec(int congViecId) throws SQLException {
        List<Map<String, Object>> quyTrinhList = new ArrayList<>();

        String sql = """
            SELECT 
                qt.id, qt.ten_buoc, qt.mo_ta, qt.trang_thai,
                qt.ngay_bat_dau, qt.ngay_ket_thuc
            FROM cong_viec_quy_trinh qt
            WHERE qt.cong_viec_id = ?
            ORDER BY qt.id ASC
        """;

        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, congViecId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> quyTrinh = new HashMap<>();

                    int qtId = rs.getInt("id");
                    quyTrinh.put("id", qtId);
                    quyTrinh.put("ten_buoc", rs.getString("ten_buoc"));
                    quyTrinh.put("mo_ta", rs.getString("mo_ta"));
                    quyTrinh.put("trang_thai", rs.getString("trang_thai"));
                    quyTrinh.put("ngay_bat_dau", rs.getDate("ngay_bat_dau"));
                    quyTrinh.put("ngay_ket_thuc", rs.getDate("ngay_ket_thuc"));

                    // ✅ Lấy danh sách người nhận của quy trình này
                    List<Map<String, Object>> nguoiNhanList = getNguoiNhanByStepId(qtId);
                    quyTrinh.put("nguoi_nhan_list", nguoiNhanList);

                    // ✅ Tạo chuỗi tên người nhận để hiển thị
                    StringBuilder nguoiNhanNames = new StringBuilder();
                    for (int i = 0; i < nguoiNhanList.size(); i++) {
                        if (i > 0) {
                            nguoiNhanNames.append(", ");
                        }
                        nguoiNhanNames.append(nguoiNhanList.get(i).get("ten"));
                    }
                    quyTrinh.put("nguoi_nhan_names", nguoiNhanNames.toString());

                    // Tính tiến độ quy trình (đơn giản dựa trên trạng thái)
                    String trangThai = rs.getString("trang_thai");
                    double tienDo = 0.0;
                    if (trangThai != null) {
                        switch (trangThai) {
                            case "Đã hoàn thành":
                                tienDo = 100.0;
                                break;
                            case "Đang thực hiện":
                                tienDo = 50.0;
                                break;
                            default:
                                tienDo = 0.0;
                        }
                    }
                    quyTrinh.put("tien_do", tienDo);

                    quyTrinhList.add(quyTrinh);
                }
            }
        }

        return quyTrinhList;
    }

    /**
     * Lấy báo cáo chi tiết dự án theo khoảng thời gian
     */
    public List<Map<String, Object>> getBaoCaoDuAnByDateRange(String tuNgay, String denNgay, String phongBan) throws SQLException {
        List<Map<String, Object>> baoCaoDuAn = new ArrayList<>();

        StringBuilder sql = new StringBuilder();
        sql.append("""
            SELECT 
                da.id,
                da.ten_du_an,
                da.mo_ta,
                da.nhom_du_an,
                da.phong_ban,
                da.trang_thai_duan,
                da.muc_do_uu_tien,
                da.ngay_bat_dau,
                da.ngay_ket_thuc,
                nv.ho_ten as lead_name,
                
                -- Thống kê công việc
                COUNT(cv.id) AS tong_cong_viec,
                SUM(CASE WHEN cv.trang_thai = 'Đã hoàn thành' THEN 1 ELSE 0 END) AS cv_hoan_thanh,
                SUM(CASE WHEN cv.trang_thai = 'Đang thực hiện' THEN 1 ELSE 0 END) AS cv_dang_thuc_hien,
                SUM(CASE WHEN cv.trang_thai = 'Trễ hạn' THEN 1 ELSE 0 END) AS cv_tre_han,
                SUM(CASE WHEN cv.trang_thai = 'Chưa bắt đầu' THEN 1 ELSE 0 END) AS cv_chua_bat_dau,
                
                -- Công việc có vấn đề (trễ hạn hoặc gần deadline)
                SUM(CASE 
                    WHEN cv.han_hoan_thanh < CURDATE() AND cv.trang_thai <> 'Đã hoàn thành' 
                    THEN 1 ELSE 0 
                END) AS cv_qua_han,
                
                SUM(CASE 
                    WHEN cv.han_hoan_thanh BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 3 DAY) 
                         AND cv.trang_thai <> 'Đã hoàn thành' 
                    THEN 1 ELSE 0 
                END) AS cv_sap_het_han
                
            FROM du_an da
            LEFT JOIN nhanvien nv ON da.lead_id = nv.id
            LEFT JOIN cong_viec cv ON da.id = cv.du_an_id
            WHERE da.id <> 1
        """);

        List<Object> params = new ArrayList<>();

        // Lọc theo khoảng thời gian (dự án có deadline trong khoảng này hoặc đang active)
        if (tuNgay != null && !tuNgay.isEmpty() && denNgay != null && !denNgay.isEmpty()) {
            sql.append("""
                AND (
                    (da.ngay_ket_thuc BETWEEN ? AND ?)
                    OR (da.trang_thai_duan = 'Đang thực hiện')
                )
            """);
            params.add(java.sql.Date.valueOf(tuNgay));
            params.add(java.sql.Date.valueOf(denNgay));
        }

        // Lọc theo phòng ban
        if (phongBan != null && !phongBan.trim().isEmpty()) {
            sql.append(" AND da.phong_ban = ? ");
            params.add(phongBan);
        }

        sql.append("""
            GROUP BY da.id, da.ten_du_an, da.mo_ta, da.nhom_du_an, 
                     da.phong_ban, da.trang_thai_duan, da.muc_do_uu_tien,
                     da.ngay_bat_dau, da.ngay_ket_thuc, nv.ho_ten
            ORDER BY 
                CASE da.trang_thai_duan
                    WHEN 'Đang thực hiện' THEN 1
                    WHEN 'Tạm ngưng' THEN 2
                    WHEN 'Đã hoàn thành' THEN 3
                    ELSE 4
                END,
                cv_qua_han DESC,
                cv_sap_het_han DESC,
                da.ngay_ket_thuc ASC
        """);

        try (PreparedStatement stmt = cn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getInt("id"));
                    row.put("ten_du_an", rs.getString("ten_du_an"));
                    row.put("mo_ta", rs.getString("mo_ta"));
                    row.put("nhom_du_an", rs.getString("nhom_du_an"));
                    row.put("phong_ban", rs.getString("phong_ban"));
                    row.put("trang_thai_duan", rs.getString("trang_thai_duan"));
                    row.put("muc_do_uu_tien", rs.getString("muc_do_uu_tien"));
                    row.put("ngay_bat_dau", rs.getDate("ngay_bat_dau"));
                    row.put("ngay_ket_thuc", rs.getDate("ngay_ket_thuc"));
                    row.put("lead_name", rs.getString("lead_name"));

                    int tongCV = rs.getInt("tong_cong_viec");
                    int cvHoanThanh = rs.getInt("cv_hoan_thanh");

                    row.put("tong_cong_viec", tongCV);
                    row.put("cv_hoan_thanh", cvHoanThanh);
                    row.put("cv_dang_thuc_hien", rs.getInt("cv_dang_thuc_hien"));
                    row.put("cv_tre_han", rs.getInt("cv_tre_han"));
                    row.put("cv_chua_bat_dau", rs.getInt("cv_chua_bat_dau"));
                    row.put("cv_qua_han", rs.getInt("cv_qua_han"));
                    row.put("cv_sap_het_han", rs.getInt("cv_sap_het_han"));

                    // Tính tiến độ
                    double tienDo = tongCV > 0 ? Math.round((cvHoanThanh * 100.0 / tongCV) * 10) / 10.0 : 0.0;
                    row.put("tien_do", tienDo);

                    baoCaoDuAn.add(row);
                }
            }
        }

        return baoCaoDuAn;
    }

    /**
     * Lấy chi tiết công việc trong dự án để xuất báo cáo
     */
    public List<Map<String, Object>> getChiTietCongViecDuAn(String tuNgay, String denNgay, String phongBan, String trangThaiDuAn) throws SQLException {
        List<Map<String, Object>> chiTietList = new ArrayList<>();

        StringBuilder sql = new StringBuilder();
        sql.append("""
            SELECT 
                da.ten_du_an,
                da.trang_thai_duan,
                da.ngay_ket_thuc as deadline_duan,
                nv_lead.ho_ten as leader,
                cv.ten_cong_viec,
                cv.trang_thai as trang_thai_cv,
                cv.ngay_bat_dau,
                cv.han_hoan_thanh,
                cv.ngay_hoan_thanh,
                cv.muc_do_uu_tien,
                GROUP_CONCAT(DISTINCT nv_nhan.ho_ten SEPARATOR ', ') as nguoi_nhan
            FROM du_an da
            LEFT JOIN nhanvien nv_lead ON da.lead_id = nv_lead.id
            LEFT JOIN cong_viec cv ON da.id = cv.du_an_id
            LEFT JOIN cong_viec_nguoi_nhan cvnn ON cv.id = cvnn.cong_viec_id
            LEFT JOIN nhanvien nv_nhan ON cvnn.nhan_vien_id = nv_nhan.id
            WHERE da.id <> 1
        """);

        List<Object> params = new ArrayList<>();

        // Lọc theo khoảng thời gian
        if (tuNgay != null && !tuNgay.isEmpty() && denNgay != null && !denNgay.isEmpty()) {
            sql.append("""
                AND (
                    (da.ngay_ket_thuc BETWEEN ? AND ?)
                    OR (da.trang_thai_duan = 'Đang thực hiện')
                )
            """);
            params.add(java.sql.Date.valueOf(tuNgay));
            params.add(java.sql.Date.valueOf(denNgay));
        }

        // Lọc theo phòng ban
        if (phongBan != null && !phongBan.trim().isEmpty()) {
            sql.append(" AND da.phong_ban = ? ");
            params.add(phongBan);
        }

        // Lọc theo trạng thái dự án
        if (trangThaiDuAn != null && !trangThaiDuAn.trim().isEmpty()) {
            sql.append(" AND da.trang_thai_duan = ? ");
            params.add(trangThaiDuAn);
        }

        sql.append("""
            GROUP BY da.ten_du_an, da.trang_thai_duan, da.ngay_ket_thuc,
                     nv_lead.ho_ten, cv.id, cv.ten_cong_viec, cv.trang_thai,
                     cv.ngay_bat_dau, cv.han_hoan_thanh, cv.ngay_hoan_thanh, cv.muc_do_uu_tien
            ORDER BY 
                CASE da.trang_thai_duan
                    WHEN 'Đang thực hiện' THEN 1
                    WHEN 'Tạm ngưng' THEN 2
                    WHEN 'Đã hoàn thành' THEN 3
                    ELSE 4
                END,
                da.ten_du_an,
                cv.han_hoan_thanh ASC
        """);

        try (PreparedStatement stmt = cn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("ten_du_an", rs.getString("ten_du_an"));
                    row.put("trang_thai_duan", rs.getString("trang_thai_duan"));
                    row.put("deadline_duan", rs.getDate("deadline_duan"));
                    row.put("leader", rs.getString("leader"));
                    row.put("ten_cong_viec", rs.getString("ten_cong_viec"));
                    row.put("trang_thai_cv", rs.getString("trang_thai_cv"));
                    row.put("ngay_bat_dau", rs.getDate("ngay_bat_dau"));
                    row.put("han_hoan_thanh", rs.getDate("han_hoan_thanh"));
                    row.put("ngay_hoan_thanh", rs.getDate("ngay_hoan_thanh"));
                    row.put("muc_do_uu_tien", rs.getString("muc_do_uu_tien"));
                    row.put("nguoi_nhan", rs.getString("nguoi_nhan"));

                    chiTietList.add(row);
                }
            }
        }

        return chiTietList;
    }

    /**
     * Lấy chi tiết công việc của dự án theo trạng thái
     */
    public List<Map<String, Object>> getProjectTasksByStatus(String projectName, String status, String tuNgay, String denNgay) throws SQLException {
        List<Map<String, Object>> result = new ArrayList<>();

        StringBuilder sql = new StringBuilder();
        sql.append("""
            SELECT 
                cv.id,
                cv.ten_cong_viec,
                cv.trang_thai as trang_thai_cv,
                cv.ngay_bat_dau,
                cv.han_hoan_thanh,
                cv.ngay_hoan_thanh,
                cv.muc_do_uu_tien,
                GROUP_CONCAT(DISTINCT nv.ho_ten SEPARATOR ', ') as nguoi_nhan
            FROM du_an da
            LEFT JOIN cong_viec cv ON da.id = cv.du_an_id
            LEFT JOIN cong_viec_nguoi_nhan cvnn ON cv.id = cvnn.cong_viec_id
            LEFT JOIN nhanvien nv ON cvnn.nhan_vien_id = nv.id
            WHERE da.ten_du_an = ?
        """);

        List<Object> params = new ArrayList<>();
        params.add(projectName);

        // Filter theo trạng thái
        if ("Đã hoàn thành".equals(status)) {
            sql.append(" AND cv.trang_thai = 'Đã hoàn thành' ");
        } else if ("Đang thực hiện".equals(status)) {
            sql.append(" AND cv.trang_thai = 'Đang thực hiện' ");
        } else if ("Quá hạn".equals(status)) {
            sql.append(" AND cv.trang_thai IS NOT NULL ");
            sql.append(" AND cv.ngay_hoan_thanh IS NULL ");
            sql.append(" AND cv.han_hoan_thanh IS NOT NULL ");
            sql.append(" AND cv.han_hoan_thanh < CURDATE() ");
        } else if ("Chưa bắt đầu".equals(status)) {
            sql.append(" AND (cv.trang_thai = 'Chưa bắt đầu' OR (cv.ngay_bat_dau > CURDATE() AND cv.ngay_hoan_thanh IS NULL)) ");
        }

        sql.append(" GROUP BY cv.id, cv.ten_cong_viec, cv.trang_thai, cv.ngay_bat_dau, cv.han_hoan_thanh, cv.ngay_hoan_thanh, cv.muc_do_uu_tien ");
        sql.append(" ORDER BY cv.han_hoan_thanh ASC ");

        try (PreparedStatement stmt = cn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getInt("id"));
                    row.put("ten_cong_viec", rs.getString("ten_cong_viec"));
                    row.put("trang_thai_cv", rs.getString("trang_thai_cv"));
                    row.put("nguoi_nhan", rs.getString("nguoi_nhan"));
                    row.put("muc_do_uu_tien", rs.getString("muc_do_uu_tien"));

                    java.sql.Date ngayBatDau = rs.getDate("ngay_bat_dau");
                    row.put("ngay_bat_dau", ngayBatDau != null ? sdf.format(ngayBatDau) : "");

                    java.sql.Date hanHoanThanh = rs.getDate("han_hoan_thanh");
                    row.put("han_hoan_thanh", hanHoanThanh != null ? sdf.format(hanHoanThanh) : "");

                    java.sql.Date ngayHoanThanh = rs.getDate("ngay_hoan_thanh");
                    row.put("ngay_hoan_thanh", ngayHoanThanh != null ? sdf.format(ngayHoanThanh) : "");

                    result.add(row);
                }
            }
        }

        return result;
    }

    // ========== PHƯƠNG THỨC MỚI CHO HỆ THỐNG NGHỈ PHÉP ==========
    /**
     * Cộng 12 ngày phép đầu năm cho các nhân viên đã làm > 12 tháng Chuyển ngày
     * phép năm cũ còn lại sang năm mới
     */
    public void congPhepDauNam(int nam) throws SQLException {
        String sql = "CALL sp_cong_phep_dau_nam(?)";
        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nam);
            stmt.execute();
        }
    }

    /**
     * Cộng 1 ngày phép hàng tháng cho nhân viên chưa đủ 12 tháng Chỉ cộng nếu
     * nhân viên vào làm trước ngày 15 của tháng đó
     */
    public void congPhepHangThang(int nam, int thang) throws SQLException {
        String sql = "CALL sp_cong_phep_hang_thang(?, ?)";
        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nam);
            stmt.setInt(2, thang);
            stmt.execute();
        }
    }

    /**
     * Xóa ngày phép năm cũ khi hết quý 1 (bước sang quý 2)
     */
    public void xoaPhepNamCu(int nam) throws SQLException {
        String sql = "CALL sp_xoa_phep_nam_cu(?)";
        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nam);
            stmt.execute();
        }
    }

    /**
     * Kiểm tra ngày có phải là ngày nghỉ lễ không
     */
    public boolean isNgayNghiLe(java.sql.Date ngay) throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM ngay_nghi_le "
                + "WHERE ? BETWEEN ngay_bat_dau AND ngay_ket_thuc";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setDate(1, ngay);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count") > 0;
                }
            }
        }
        return false;
    }

    /**
     * Kiểm tra ngày có phải là cuối tuần (thứ 7, chủ nhật) không
     */
    public boolean isCuoiTuan(java.sql.Date ngay) {
        Calendar cal = Calendar.getInstance();
        cal.setTime(new java.util.Date(ngay.getTime()));
        int dayOfWeek = cal.get(Calendar.DAY_OF_WEEK);
        return dayOfWeek == Calendar.SATURDAY || dayOfWeek == Calendar.SUNDAY;
    }

    /**
     * Lấy danh sách ngày nghỉ lễ trong khoảng thời gian
     */
    public List<Map<String, Object>> getDanhSachNgayNghiLe(int nam) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT * FROM ngay_nghi_le "
                + "WHERE YEAR(ngay_bat_dau) = ? OR lap_lai_hang_nam = 1 "
                + "ORDER BY ngay_bat_dau";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nam);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> ngayLe = new HashMap<>();
                    ngayLe.put("id", rs.getInt("id"));
                    ngayLe.put("ten_ngay_le", rs.getString("ten_ngay_le"));
                    ngayLe.put("ngay_bat_dau", rs.getDate("ngay_bat_dau"));
                    ngayLe.put("ngay_ket_thuc", rs.getDate("ngay_ket_thuc"));
                    ngayLe.put("lap_lai_hang_nam", rs.getBoolean("lap_lai_hang_nam"));
                    list.add(ngayLe);
                }
            }
        }
        return list;
    }

    /**
     * Lấy lịch sử cộng phép của nhân viên
     */
    public List<Map<String, Object>> getLichSuCongPhep(int nhanVienId, int nam) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT * FROM lich_su_cong_phep "
                + "WHERE nhan_vien_id = ? AND nam = ? "
                + "ORDER BY ngay_cong DESC";

        try (PreparedStatement stmt = cn.prepareStatement(sql)) {
            stmt.setInt(1, nhanVienId);
            stmt.setInt(2, nam);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> lichSu = new HashMap<>();
                    lichSu.put("id", rs.getInt("id"));
                    lichSu.put("thang", rs.getInt("thang"));
                    lichSu.put("so_ngay_cong", rs.getBigDecimal("so_ngay_cong"));
                    lichSu.put("loai_cong", rs.getString("loai_cong"));
                    lichSu.put("ly_do", rs.getString("ly_do"));
                    lichSu.put("ngay_cong", rs.getTimestamp("ngay_cong"));
                    list.add(lichSu);
                }
            }
        }
        return list;
    }

    /**
     * Cộng 1 ngày phép hàng tháng cho nhân viên chưa đủ 12 tháng
     * Kiểm tra từ bảng lich_su_cong_phep: nếu tháng trước chưa cộng thì cộng +1
     * Ví dụ: Hôm nay 3/2/2026 → check tháng 1 đã cộng chưa, chưa thì cộng vào tháng 1
     * Gọi khi user truy cập index.jsp hoặc userDashboard
     */
    public void congPhepTheoThang() throws SQLException {
        Logger logger = Logger.getLogger(KNCSDL.class.getName());
        
        try {
            Calendar cal = Calendar.getInstance();
            int currentYear = cal.get(Calendar.YEAR);
            int currentMonth = cal.get(Calendar.MONTH) + 1;
            
            // Tính tháng trước
            int previousMonth = (currentMonth == 1) ? 12 : currentMonth - 1;
            int previousYear = (currentMonth == 1) ? currentYear - 1 : currentYear;
            
            logger.info("🔍 [congPhepTheoThang] Bắt đầu kiểm tra cộng phép hàng tháng");
            logger.info("   Tháng hiện tại: " + currentMonth + "/" + currentYear + ", Tháng check: " + previousMonth + "/" + previousYear);
            
            // Lấy danh sách tất cả nhân viên đang làm
            String sqlNhanVien = "SELECT nv.id, nv.ho_ten, nv.ngay_vao_lam FROM nhanvien nv WHERE nv.trang_thai_lam_viec = 'Đang làm' AND nv.ngay_vao_lam IS NOT NULL ORDER BY nv.id";
            
            try (PreparedStatement stmtNV = cn.prepareStatement(sqlNhanVien);
                 ResultSet rsNV = stmtNV.executeQuery()) {
                
                int totalChecked = 0;
                int totalInserted = 0;
                
                while (rsNV.next()) {
                    int nhanVienId = rsNV.getInt("id");
                    String hoTen = rsNV.getString("ho_ten");
                    java.sql.Date ngayVaoLam = rsNV.getDate("ngay_vao_lam");
                    totalChecked++;
                    
                    // Tính số tháng đã làm
                    int monthsWorked = calculateMonthsDifference(ngayVaoLam, new java.sql.Date(System.currentTimeMillis()));
                    
                    logger.info("   [" + totalChecked + "] NV ID " + nhanVienId + " (" + hoTen + ") - Ngày vào: " + ngayVaoLam + ", Tháng làm: " + monthsWorked);
                    
                    // Chỉ cộng cho nhân viên chưa đủ 12 tháng
                    if (monthsWorked < 12) {
                        logger.info("       ✓ < 12 tháng, kiểm tra lịch sử...");
                        
                        // Kiểm tra xem tháng trước (previousMonth) đã cộng chưa
                        String sqlCheck = "SELECT COUNT(*) as cnt FROM lich_su_cong_phep WHERE nhan_vien_id = ? AND nam = ? AND thang = ? AND loai_cong IN ('hang_thang', 'dau_nam')";
                        
                        try (PreparedStatement stmtCheck = cn.prepareStatement(sqlCheck)) {
                            stmtCheck.setInt(1, nhanVienId);
                            stmtCheck.setInt(2, previousYear);
                            stmtCheck.setInt(3, previousMonth);
                            
                            try (ResultSet rsCheck = stmtCheck.executeQuery()) {
                                if (rsCheck.next()) {
                                    int count = rsCheck.getInt("cnt");
                                    logger.info("       → Lịch sử tháng " + previousMonth + "/" + previousYear + ": " + count + " record");
                                    
                                    // Nếu tháng trước chưa cộng (count = 0) thì cộng +1 ngày
                                    if (count == 0) {
                                        logger.info("       ✅ Tháng " + previousMonth + " chưa cộng, thực hiện INSERT...");
                                        
                                        // Thêm record vào lich_su_cong_phep
                                        String sqlInsert = "INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do, ngay_cong) VALUES (?, ?, ?, 1.0, 'hang_thang', ?, NOW())";
                                        
                                        try (PreparedStatement stmtInsert = cn.prepareStatement(sqlInsert)) {
                                            String lyDo = "Cộng 1 ngày phép hàng tháng cho tháng " + previousMonth + "/" + previousYear;
                                            stmtInsert.setInt(1, nhanVienId);
                                            stmtInsert.setInt(2, previousYear);
                                            stmtInsert.setInt(3, previousMonth);
                                            stmtInsert.setString(4, lyDo);
                                            int rows = stmtInsert.executeUpdate();
                                            
                                            if (rows > 0) {
                                                logger.info("       💾 Đã INSERT vào lich_su_cong_phep");
                                                
                                                // 2. Cập nhật bảng ngay_phep_nam (cho năm hiện tại)
                                                String sqlUpdate = "INSERT INTO ngay_phep_nam (nhan_vien_id, nam, tong_ngay_phep, ngay_phep_da_dung, ngay_phep_con_lai, ngay_phep_nam_truoc) " +
                                                                   "VALUES (?, ?, 1.0, 0.0, 1.0, 0) " +
                                                                   "ON DUPLICATE KEY UPDATE " +
                                                                   "tong_ngay_phep = tong_ngay_phep + 1.0, " +
                                                                   "ngay_phep_con_lai = ngay_phep_con_lai + 1.0";
                                                
                                                try (PreparedStatement stmtUpdate = cn.prepareStatement(sqlUpdate)) {
                                                    stmtUpdate.setInt(1, nhanVienId);
                                                    stmtUpdate.setInt(2, currentYear);
                                                    int updateRows = stmtUpdate.executeUpdate();
                                                    
                                                    if (updateRows > 0) {
                                                        totalInserted++;
                                                        logger.info("       💾 Đã cập nhật ngay_phep_nam (năm " + currentYear + ")");
                                                    } else {
                                                        logger.warning("       ❌ UPDATE ngay_phep_nam thất bại");
                                                    }
                                                }
                                            } else {
                                                logger.warning("       ❌ INSERT lich_su_cong_phep thất bại");
                                            }
                                        }
                                    } else {
                                        logger.info("       ⏭️ Tháng " + previousMonth + " đã cộng rồi");
                                    }
                                }
                            }
                        }
                    } else {
                        logger.info("       ✗ >= 12 tháng, skip");
                    }
                }
                
                logger.info("🎯 [congPhepTheoThang] Hoàn tất - Kiểm tra: " + totalChecked + " nhân viên, INSERT: " + totalInserted + " record");
                
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "❌ [congPhepTheoThang] SQL Exception: " + ex.getMessage(), ex);
            throw ex;
        } catch (Exception ex) {
            logger.log(Level.SEVERE, "❌ [congPhepTheoThang] Exception: " + ex.getMessage(), ex);
            throw new SQLException(ex);
        }
    }
    
    /**
     * Tính số tháng chênh lệch giữa 2 ngày
     */
    private int calculateMonthsDifference(java.sql.Date from, java.sql.Date to) {
        Calendar calFrom = Calendar.getInstance();
        Calendar calTo = Calendar.getInstance();
        calFrom.setTime(from);
        calTo.setTime(to);
        
        int months = calTo.get(Calendar.MONTH) - calFrom.get(Calendar.MONTH);
        months += (calTo.get(Calendar.YEAR) - calFrom.get(Calendar.YEAR)) * 12;
        
        return months;
    }

    /**
     * Xử lý trường hợp sinh nhật công việc (anniversary)
     * Khi nhân viên đủ 12 tháng làm việc vào đúng ngày anniversary, cộng hết số ngày phép còn lại
     * Kiểm tra từ bảng lich_su_cong_phep để tính số ngày đã cộng
     * Gọi khi user truy cập index.jsp hoặc userDashboard
     */
    public void congPhepAnniversary() throws SQLException {
        Calendar cal = Calendar.getInstance();
        int currentYear = cal.get(Calendar.YEAR);
        int currentMonth = cal.get(Calendar.MONTH) + 1;
        int currentDay = cal.get(Calendar.DAY_OF_MONTH);
        java.sql.Date today = new java.sql.Date(System.currentTimeMillis());
        
        Logger logger = Logger.getLogger(KNCSDL.class.getName());
        logger.info("🎉 Kiểm tra Anniversary - Ngày hôm nay: " + currentDay + "/" + currentMonth + "/" + currentYear);
        
        // Lấy danh sách tất cả nhân viên đang làm
        String sqlNhanVien = "SELECT nv.id, nv.ngay_vao_lam FROM nhanvien nv WHERE nv.trang_thai_lam_viec = 'Đang làm' AND nv.ngay_vao_lam IS NOT NULL";
        
        try (PreparedStatement stmtNV = cn.prepareStatement(sqlNhanVien);
             ResultSet rsNV = stmtNV.executeQuery()) {
            
            while (rsNV.next()) {
                int nhanVienId = rsNV.getInt("id");
                java.sql.Date ngayVaoLam = rsNV.getDate("ngay_vao_lam");
                
                // Tính số tháng đã làm
                int monthsWorked = calculateMonthsDifference(ngayVaoLam, today);
                
                // Lấy ngày và tháng vào làm
                Calendar calVao = Calendar.getInstance();
                calVao.setTime(ngayVaoLam);
                int dayVao = calVao.get(Calendar.DAY_OF_MONTH);
                int monthVao = calVao.get(Calendar.MONTH) + 1;
                
                // Kiểm tra xem hôm nay có phải là ngày anniversary (đủ 12 tháng)
                if (monthsWorked >= 12 && currentDay == dayVao && currentMonth == monthVao) {
                    logger.info("✅ NV ID " + nhanVienId + " - Hôm nay là ngày Anniversary (đủ 12 tháng)! Ngày vào: " + dayVao + "/" + monthVao);
                    
                    // Kiểm tra xem năm này đã cộng anniversary chưa
                    String sqlCheckAnniversary = "SELECT COUNT(*) as cnt FROM lich_su_cong_phep WHERE nhan_vien_id = ? AND nam = ? AND loai_cong = 'anniversary'";
                    
                    try (PreparedStatement stmtCheckAni = cn.prepareStatement(sqlCheckAnniversary)) {
                        stmtCheckAni.setInt(1, nhanVienId);
                        stmtCheckAni.setInt(2, currentYear);
                        
                        try (ResultSet rsCheckAni = stmtCheckAni.executeQuery()) {
                            if (rsCheckAni.next()) {
                                int countAnniversary = rsCheckAni.getInt("cnt");
                                
                                if (countAnniversary == 0) {
                                    // Chưa cộng anniversary - tính số ngày phép còn lại
                                    String sqlSumDays = "SELECT COALESCE(SUM(so_ngay_cong), 0) as tong_da_cong FROM lich_su_cong_phep WHERE nhan_vien_id = ? AND nam = ? AND loai_cong IN ('hang_thang', 'dau_nam')";
                                    
                                    try (PreparedStatement stmtSum = cn.prepareStatement(sqlSumDays)) {
                                        stmtSum.setInt(1, nhanVienId);
                                        stmtSum.setInt(2, currentYear);
                                        
                                        try (ResultSet rsSum = stmtSum.executeQuery()) {
                                            if (rsSum.next()) {
                                                double tongDaCong = rsSum.getDouble("tong_da_cong");
                                                double soNgayConLai = 12.0 - tongDaCong;
                                                
                                                if (soNgayConLai > 0) {
                                                    logger.info("📊 NV ID " + nhanVienId + " - Đã cộng: " + tongDaCong + " ngày, Còn lại: " + soNgayConLai + " ngày");
                                                    
                                                    // Cộng số ngày phép còn lại
                                                    String sqlInsertAnniversary = "INSERT INTO lich_su_cong_phep (nhan_vien_id, nam, thang, so_ngay_cong, loai_cong, ly_do, ngay_cong) VALUES (?, ?, ?, ?, 'anniversary', ?, NOW())";
                                                    
                                                    try (PreparedStatement stmtInsertAni = cn.prepareStatement(sqlInsertAnniversary)) {
                                                        String lyDo = "🎉 Sinh nhật công việc 12 tháng! Cộng " + soNgayConLai + " ngày phép còn lại của năm " + currentYear + ". Ngày vào: " + dayVao + "/" + monthVao + ". Không cộng hàng tháng nữa.";
                                                        
                                                        stmtInsertAni.setInt(1, nhanVienId);
                                                        stmtInsertAni.setInt(2, currentYear);
                                                        stmtInsertAni.setInt(3, currentMonth);
                                                        stmtInsertAni.setDouble(4, soNgayConLai);
                                                        stmtInsertAni.setString(5, lyDo);
                                                        stmtInsertAni.executeUpdate();
                                                        
                                                        logger.info("💾 Đã lưu Anniversary bonus cho NV ID " + nhanVienId + " - " + soNgayConLai + " ngày");
                                                    }
                                                } else {
                                                    logger.info("⏭️ NV ID " + nhanVienId + " - Đã cộng đủ 12 ngày rồi, không cộng thêm");
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    logger.info("⏭️ NV ID " + nhanVienId + " - Năm " + currentYear + " đã cộng anniversary rồi, bỏ qua");
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ===== 6 NEW CHART DATA METHODS =====
    
    // 1. Overdue tasks per project
    public List<Map<String, Object>> getDataForOverdueChart() throws SQLException {
        List<Map<String, Object>> data = new ArrayList<>();
        String sql = "SELECT da.ten_du_an AS project_name, COUNT(cv.id) AS count " +
                "FROM du_an da " +
                "LEFT JOIN cong_viec cv ON da.id = cv.du_an_id " +
                "WHERE cv.trang_thai = 'Trễ hạn' " +
                "GROUP BY da.id, da.ten_du_an " +
                "HAVING COUNT(cv.id) > 0 " +
                "ORDER BY count DESC";
        
        try (PreparedStatement stmt = cn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("project_name", rs.getString("project_name"));
                row.put("count", rs.getInt("count"));
                data.add(row);
            }
        }
        return data;
    }

    // 2. Top 10 employees by open task count
    public List<Map<String, Object>> getDataForTopWorkloadChart() throws SQLException {
        List<Map<String, Object>> data = new ArrayList<>();
        String sql = "SELECT nv.ho_ten AS employee_name, COUNT(cv.id) AS task_count " +
                "FROM nhanvien nv " +
                "LEFT JOIN cong_viec_nguoi_nhan cvn ON nv.id = cvn.nhan_vien_id " +
                "LEFT JOIN cong_viec cv ON cvn.cong_viec_id = cv.id " +
                "WHERE cv.trang_thai IN ('Chưa bắt đầu', 'Đang thực hiện') " +
                "GROUP BY nv.id, nv.ho_ten " +
                "ORDER BY task_count DESC " +
                "LIMIT 10";
        
        try (PreparedStatement stmt = cn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("employee_name", rs.getString("employee_name"));
                row.put("task_count", rs.getInt("task_count"));
                data.add(row);
            }
        }
        return data;
    }

    // 3. Created vs Completed tasks - Last 30 days
    public List<Map<String, Object>> getDataForBurnupChart() throws SQLException {
        List<Map<String, Object>> data = new ArrayList<>();
        String sql = "SELECT DATE_FORMAT(dates.date, '%d/%m') AS day, " +
                "COALESCE(created.count, 0) AS created, " +
                "COALESCE(completed.count, 0) AS completed " +
                "FROM (" +
                "  SELECT DATE_SUB(CURDATE(), INTERVAL n DAY) AS date " +
                "  FROM (SELECT 0 AS n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 " +
                "        UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15 UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20 " +
                "        UNION SELECT 21 UNION SELECT 22 UNION SELECT 23 UNION SELECT 24 UNION SELECT 25 UNION SELECT 26 UNION SELECT 27 UNION SELECT 28 UNION SELECT 29) nums " +
                ") dates " +
                "LEFT JOIN (SELECT DATE(ngay_tao) AS date, COUNT(*) AS count FROM cong_viec WHERE ngay_tao >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) GROUP BY DATE(ngay_tao)) created ON dates.date = created.date " +
                "LEFT JOIN (SELECT DATE(ngay_hoan_thanh) AS date, COUNT(*) AS count FROM cong_viec WHERE ngay_hoan_thanh >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) GROUP BY DATE(ngay_hoan_thanh)) completed ON dates.date = completed.date " +
                "ORDER BY dates.date ASC";
        
        try (PreparedStatement stmt = cn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("day", rs.getString("day"));
                row.put("created", rs.getInt("created"));
                row.put("completed", rs.getInt("completed"));
                data.add(row);
            }
        }
        return data;
    }

    // 4. Task priority distribution
    public Map<String, Integer> getDataForPriorityChart() throws SQLException {
        Map<String, Integer> data = new HashMap<>();
        String sql = "SELECT muc_do_uu_tien, COUNT(*) AS count FROM cong_viec " +
                "GROUP BY muc_do_uu_tien";
        
        try (PreparedStatement stmt = cn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                String priority = rs.getString("muc_do_uu_tien");
                int count = rs.getInt("count");
                data.put(priority, count);
            }
        }
        // Ensure all priorities exist
        data.putIfAbsent("Cao", 0);
        data.putIfAbsent("Trung bình", 0);
        data.putIfAbsent("Thấp", 0);
        return data;
    }

    // 5. Average open age per project (days task remains open)
    public List<Map<String, Object>> getDataForAvgOpenAgeChart() throws SQLException {
        List<Map<String, Object>> data = new ArrayList<>();
        String sql = "SELECT da.ten_du_an AS project_name, " +
                "ROUND(AVG(DATEDIFF(CURDATE(), cv.ngay_tao))) AS avg_open_days " +
                "FROM du_an da " +
                "LEFT JOIN cong_viec cv ON da.id = cv.du_an_id " +
                "WHERE cv.trang_thai IN ('Chưa bắt đầu', 'Đang thực hiện', 'Trễ hạn') " +
                "GROUP BY da.id, da.ten_du_an " +
                "ORDER BY avg_open_days DESC";
        
        try (PreparedStatement stmt = cn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("project_name", rs.getString("project_name"));
                row.put("avg_open_days", rs.getInt("avg_open_days"));
                data.add(row);
            }
        }
        return data;
    }

    // 6. SLA breach rate (deadline compliance)
    public Map<String, Integer> getDataForSlaBreach() throws SQLException {
        Map<String, Integer> data = new HashMap<>();
        String sql = "SELECT " +
                "SUM(CASE WHEN ngay_hoan_thanh IS NOT NULL AND han_hoan_thanh IS NOT NULL AND ngay_hoan_thanh > han_hoan_thanh THEN 1 ELSE 0 END) AS breached, " +
                "SUM(CASE WHEN ngay_hoan_thanh IS NOT NULL AND han_hoan_thanh IS NOT NULL AND ngay_hoan_thanh <= han_hoan_thanh THEN 1 ELSE 0 END) AS on_time " +
                "FROM cong_viec WHERE ngay_hoan_thanh IS NOT NULL";
        
        try (PreparedStatement stmt = cn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                int breached = rs.getInt("breached");
                int onTime = rs.getInt("on_time");
                data.put("Breached", breached);
                data.put("On-time", onTime);
            }
        }
        return data;
    }

}
