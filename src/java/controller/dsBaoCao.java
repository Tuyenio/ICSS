package controller;

import jakarta.servlet.http.HttpSession;
import java.util.*;

public class dsBaoCao {

    public static void layDuLieuBaoCao(
            jakarta.servlet.http.HttpServletRequest request,
            jakarta.servlet.http.HttpServletResponse response) {

        HttpSession session = request.getSession();
        try {
            // Lấy tham số lọc
            String thangParam = request.getParameter("thang");
            String namParam = request.getParameter("nam");
            String tuNgayParam = request.getParameter("tu_ngay");
            String denNgayParam = request.getParameter("den_ngay");
            String phongBanParam = request.getParameter("phong_ban");

            List<Map<String, Object>> baoCaoNhanVien;
            Map<String, Object> pieChartData;
            Map<String, Object> barChartData;

            // ✅ Nếu có khoảng thời gian
            if (tuNgayParam != null && !tuNgayParam.isEmpty()
                    && denNgayParam != null && !denNgayParam.isEmpty()) {

                baoCaoNhanVien = apiBaoCao.getBaoCaoNhanVienByDateRange(tuNgayParam, denNgayParam, phongBanParam);
                pieChartData = apiBaoCao.getDataForPieChart(tuNgayParam, denNgayParam, phongBanParam);
                barChartData = apiBaoCao.getDataForBarChart(session, tuNgayParam, denNgayParam, phongBanParam);

            } else {
                // Không có khoảng thời gian → mặc định theo tháng
                if (thangParam == null || thangParam.isEmpty()) {
                    Calendar cal = Calendar.getInstance();
                    thangParam = String.valueOf(cal.get(Calendar.MONTH) + 1);
                    namParam = String.valueOf(cal.get(Calendar.YEAR));
                }
                baoCaoNhanVien = apiBaoCao.getBaoCaoNhanVien(thangParam, namParam, phongBanParam);

                java.time.YearMonth ym = java.time.YearMonth.of(Integer.parseInt(namParam), Integer.parseInt(thangParam));
                String start = ym.atDay(1).toString();
                String end = ym.atEndOfMonth().toString();

                pieChartData = apiBaoCao.getDataForPieChart(start, end, phongBanParam);
                barChartData = apiBaoCao.getDataForBarChart(session, start, end, phongBanParam);
            }

            // Lấy danh sách phòng ban
            List<Map<String, Object>> danhSachPhongBan = new ArrayList<>();
            try {
                KNCSDL kn = new KNCSDL();
                danhSachPhongBan = kn.getAllPhongBan();
            } catch (Exception e) {
                e.printStackTrace();
            }

            // Đưa dữ liệu sang JSP
            request.setAttribute("baoCaoNhanVien", baoCaoNhanVien);
            request.setAttribute("pieChartData", pieChartData);
            request.setAttribute("barChartData", barChartData);
            request.setAttribute("danhSachPhongBan", danhSachPhongBan);
            request.setAttribute("thangHienTai", thangParam);
            request.setAttribute("namHienTai", namParam);
            request.setAttribute("phongBanDaChon", phongBanParam);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
