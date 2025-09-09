package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import controller.apiBaoCao;
import java.util.List;
import java.util.Map;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import com.lowagie.text.*;
import com.lowagie.text.pdf.*;
import java.time.YearMonth;

@WebServlet(name = "ExportReportServlet", urlPatterns = {"/exportReport"})
public class ExportReportServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String reportType = param(req, "reportType");
        String exportType = param(req, "exportType");
        if (reportType == null || reportType.isEmpty()) reportType = "summary";
        if (exportType == null || exportType.isEmpty()) exportType = "Excel";

        String baseName = "BaoCao";  // tên mặc định

        // Lấy tháng, năm từ request
        String thangNam = req.getParameter("thangNam"); // kiểu "2025-09"
        String[] parts = thangNam.split("-");
        int nambc = Integer.parseInt(parts[0]);
        int thangbc = Integer.parseInt(parts[1]);

        // Đổi số tháng -> chữ (nếu bạn muốn hiển thị bằng chữ)
        String[] thangChu = {"", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"};

        // Lấy tên phòng ban (nếu có chọn)
        String phongBan = req.getParameter("phongBan"); // null hoặc "all" nếu tất cả

        // Xác định tên file
        if ("all".equalsIgnoreCase(phongBan) || phongBan == null || phongBan.isEmpty()) {
            baseName = "BaoCao_Thang_" + thangChu[thangbc] + "-" + nambc;
        } else {
            baseName = "BaoCao_Phong_" + phongBan + "_Thang_" + thangChu[thangbc] + "-" + nambc;
        }

        String fileName = baseName + ("Excel".equalsIgnoreCase(exportType) ? ".xlsx" : ".pdf");
        prepareDownloadHeaders(resp,
                "Excel".equalsIgnoreCase(exportType) ?
                        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" :
                        "application/pdf",
                fileName);

        try (OutputStream os = resp.getOutputStream()) {
            if ("Excel".equalsIgnoreCase(exportType)) {
                try (Workbook wb = new XSSFWorkbook()) {
                    if ("summary".equals(reportType)) {
                        String thang = param(req, "thangNam").split("-")[1];
                        String nam = param(req, "thangNam").split("-")[0];
                        String dept = param(req, "departmentTask");
                        exportSummaryExcel(wb, thang, nam, dept);
                    }
                    wb.write(os);
                    os.flush();
                }
            } else {
                Document doc = new Document(PageSize.A4);
                PdfWriter.getInstance(doc, os);
                doc.open();

                if ("summary".equals(reportType)) {
                    String thang = param(req, "thangNam").split("-")[1];
                    String nam = param(req, "thangNam").split("-")[0];
                    String dept = param(req, "departmentTask");
                    exportSummaryPDF(doc, thang, nam, dept);
                }

                doc.close();
                os.flush();
            }
        } catch (Exception ex) {
            handleServerError(resp, ex);
        }
    }

    private String param(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        return v != null ? v.trim() : null;
    }

    private void prepareDownloadHeaders(HttpServletResponse resp, String contentType, String fileName) throws UnsupportedEncodingException {
        resp.setContentType(contentType + "; charset=UTF-8");
        String encoded = URLEncoder.encode(fileName, StandardCharsets.UTF_8.toString()).replace("+", "%20");
        resp.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"; filename*=UTF-8''" + encoded);
        resp.setHeader("Pragma", "public");
        resp.setHeader("Cache-Control", "max-age=0");
    }

    private YearMonth parseYearMonth(String s) {
        try { return s != null && s.length() > 0 ? YearMonth.parse(s) : null; } catch (Exception e) { return null; }
    }

    private void handleServerError(HttpServletResponse resp, Exception ex) throws IOException {
        resp.reset();
        resp.setContentType("text/plain; charset=UTF-8");
        resp.setStatus(500);
        PrintWriter pw = resp.getWriter();
        pw.println("Xuất báo cáo thất bại: " + ex.getMessage());
        pw.flush();
    }

    private void exportSummaryExcel(Workbook wb, String thang, String nam, String phongBan) throws Exception {
        Sheet sh = wb.createSheet("BaoCaoTongHop");
        int r = 0;

        org.apache.poi.ss.usermodel.Row header = sh.createRow(r++);
        String[] cols = {"STT", "Nhân viên", "Phòng ban", "Số task", "Đã hoàn thành", "Đang thực hiện", "Trễ hạn", "Tỷ lệ hoàn thành"};
        for (int i = 0; i < cols.length; i++) header.createCell(i).setCellValue(cols[i]);

        List<Map<String, Object>> list = apiBaoCao.getBaoCaoNhanVien(thang, nam, phongBan);
        int stt = 1;
        for (Map<String, Object> nv : list) {
            org.apache.poi.ss.usermodel.Row row = sh.createRow(r++);
            int soTask = (int) nv.getOrDefault("so_task", 0);
            int daHoanThanh = (int) nv.getOrDefault("da_hoan_thanh", 0);
            int dangThucHien = (int) nv.getOrDefault("dang_thuc_hien", 0);
            int treHan = (int) nv.getOrDefault("tre_han", 0);
            String tyLe = soTask > 0 ? String.format("%.1f%%", (daHoanThanh * 100.0 / soTask)) : "0%";

            row.createCell(0).setCellValue(stt++);
            row.createCell(1).setCellValue((String) nv.get("ho_ten"));
            row.createCell(2).setCellValue((String) nv.get("ten_phong"));
            row.createCell(3).setCellValue(soTask);
            row.createCell(4).setCellValue(daHoanThanh);
            row.createCell(5).setCellValue(dangThucHien);
            row.createCell(6).setCellValue(treHan);
            row.createCell(7).setCellValue(tyLe);
        }

        for (int i = 0; i < 8; i++) sh.autoSizeColumn(i);
    }

    private void exportSummaryPDF(Document doc, String thang, String nam, String phongBan) throws Exception {
        doc.add(new Paragraph("BÁO CÁO TỔNG HỢP"));
        doc.add(new Paragraph("Tháng: " + thang + "/" + nam));
        doc.add(new Paragraph("Phòng ban: " + (phongBan != null && !phongBan.isEmpty() ? phongBan : "Tất cả")));
        doc.add(Chunk.NEWLINE);

        PdfPTable tbl = new PdfPTable(8);
        tbl.setWidthPercentage(100);
        String[] cols = {"STT", "Nhân viên", "Phòng ban", "Số task", "Đã hoàn thành", "Đang thực hiện", "Trễ hạn", "Tỷ lệ hoàn thành"};
        for (String c : cols) tbl.addCell(c);

        List<Map<String, Object>> list = apiBaoCao.getBaoCaoNhanVien(thang, nam, phongBan);
        int stt = 1;
        for (Map<String, Object> nv : list) {
            int soTask = (int) nv.getOrDefault("so_task", 0);
            int daHoanThanh = (int) nv.getOrDefault("da_hoan_thanh", 0);
            int dangThucHien = (int) nv.getOrDefault("dang_thuc_hien", 0);
            int treHan = (int) nv.getOrDefault("tre_han", 0);
            String tyLe = soTask > 0 ? String.format("%.1f%%", (daHoanThanh * 100.0 / soTask)) : "0%";

            tbl.addCell(String.valueOf(stt++));
            tbl.addCell((String) nv.get("ho_ten"));
            tbl.addCell((String) nv.get("ten_phong"));
            tbl.addCell(String.valueOf(soTask));
            tbl.addCell(String.valueOf(daHoanThanh));
            tbl.addCell(String.valueOf(dangThucHien));
            tbl.addCell(String.valueOf(treHan));
            tbl.addCell(tyLe);
        }

        doc.add(tbl);
    }
}
