/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

import jakarta.servlet.http.HttpSession;
import java.sql.*;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class KNCSDL2 {

    Connection cn;
    String path = "jdbc:mysql://localhost:3306/qlns";

    public KNCSDL2() throws ClassNotFoundException, SQLException {
        Class.forName("com.mysql.cj.jdbc.Driver");
        this.cn = DriverManager.getConnection(path, "root", "");
        //this.cn = DriverManager.getConnection(path, "icssapp", "StrongPass!123");
    }

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
}
