package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.YearMonth;

// Excel
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

// PDF (OpenPDF hoặc iText 2/5; dưới đây ví dụ OpenPDF)
import com.lowagie.text.*;
import com.lowagie.text.pdf.*;

public class ExportReportServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String reportType = param(req, "reportType");   // summary | kpi | task
        String exportType = param(req, "exportType");   // Excel | PDF (chỉ có ở tab summary theo form)
        if (reportType == null || reportType.isEmpty()) reportType = "summary";
        if (exportType == null || exportType.isEmpty()) exportType = "Excel";

        // Đặt tên file
        String baseName = "BaoCao";
        if ("kpi".equals(reportType)) baseName = "BaoCao_KPI";
        if ("task".equals(reportType)) baseName = "BaoCao_CongViec";

        if ("Excel".equalsIgnoreCase(exportType)) {
            String fileName = baseName + ".xlsx";
            prepareDownloadHeaders(resp, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", fileName);

            try (Workbook wb = new XSSFWorkbook(); OutputStream os = resp.getOutputStream()) {
                if ("summary".equals(reportType)) {
                    LocalDate from = parseDate(param(req, "fromDate"));
                    LocalDate to   = parseDate(param(req, "toDate"));
                    exportSummaryExcel(wb, from, to);
                } else if ("kpi".equals(reportType)) {
                    String empId = param(req, "employeeKPI"); // có thể rỗng = tất cả
                    YearMonth ym = parseYearMonth(param(req, "monthKPI"));
                    exportKPIExcel(wb, empId, ym);
                } else { // task
                    String dept   = param(req, "departmentTask");
                    String status = param(req, "taskStatus");
                    exportTaskExcel(wb, dept, status);
                }
                wb.write(os);
                os.flush();
            } catch (Exception ex) {
                handleServerError(resp, ex);
            }
            return;
        }

        // PDF
        String fileName = baseName + ".pdf";
        prepareDownloadHeaders(resp, "application/pdf", fileName);
        try (OutputStream os = resp.getOutputStream()) {
            Document doc = new Document(PageSize.A4);
            PdfWriter.getInstance(doc, os);
            doc.open();

            if ("summary".equals(reportType)) {
                LocalDate from = parseDate(param(req, "fromDate"));
                LocalDate to   = parseDate(param(req, "toDate"));
                exportSummaryPDF(doc, from, to);
            } else if ("kpi".equals(reportType)) {
                String empId = param(req, "employeeKPI");
                YearMonth ym = parseYearMonth(param(req, "monthKPI"));
                exportKPIPDF(doc, empId, ym);
            } else {
                String dept   = param(req, "departmentTask");
                String status = param(req, "taskStatus");
                exportTaskPDF(doc, dept, status);
            }

            doc.close();
            os.flush();
        } catch (Exception ex) {
            handleServerError(resp, ex);
        }
    }

    // ====== Helpers ======
    private String param(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        return v != null ? v.trim() : null;
    }

    private void prepareDownloadHeaders(HttpServletResponse resp, String contentType, String fileName) throws UnsupportedEncodingException {
        resp.setContentType(contentType + "; charset=UTF-8");
        String encoded = URLEncoder.encode(fileName, StandardCharsets.UTF_8.toString()).replace("+", "%20");
        // header đôi cho trình duyệt khác nhau
        resp.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"; filename*=UTF-8''" + encoded);
        // tránh cache nếu cần
        resp.setHeader("Pragma", "public");
        resp.setHeader("Cache-Control", "max-age=0");
    }

    private LocalDate parseDate(String s) {
        try { return s != null && s.length() > 0 ? LocalDate.parse(s) : null; } catch (Exception e) { return null; }
    }

    private YearMonth parseYearMonth(String s) {
        try { return s != null && s.length() > 0 ? YearMonth.parse(s) : null; } catch (Exception e) { return null; }
    }

    private void handleServerError(HttpServletResponse resp, Exception ex) throws IOException {
        // Nếu muốn, có thể log server, còn client nhận thông điệp file lỗi
        resp.reset();
        resp.setContentType("text/plain; charset=UTF-8");
        resp.setStatus(500);
        PrintWriter pw = resp.getWriter();
        pw.println("Xuất báo cáo thất bại: " + ex.getMessage());
        pw.flush();
    }

    // ====== Excel exports (Apache POI) ======
    private void exportSummaryExcel(Workbook wb, LocalDate from, LocalDate to) {
        Sheet sh = wb.createSheet("TongHop");
        int r = 0;
        var header = sh.createRow(r++);
        header.createCell(0).setCellValue("Chỉ tiêu");
        header.createCell(1).setCellValue("Giá trị");
        header.createCell(2).setCellValue("Từ ngày");
        header.createCell(3).setCellValue("Đến ngày");

        // TODO: truy vấn DB theo from/to, ví dụ demo:
        var row = sh.createRow(r++);
        row.createCell(0).setCellValue("Số công việc hoàn thành");
        row.createCell(1).setCellValue(42);
        row.createCell(2).setCellValue(from != null ? from.toString() : "");
        row.createCell(3).setCellValue(to != null ? to.toString() : "");

        autosizeColumns(sh, 4);
    }

    private void exportKPIExcel(Workbook wb, String empId, YearMonth ym) {
        Sheet sh = wb.createSheet("KPI");
        int r = 0;
        var header = sh.createRow(r++);
        header.createCell(0).setCellValue("Nhân viên");
        header.createCell(1).setCellValue("Tháng");
        header.createCell(2).setCellValue("Điểm KPI");

        // TODO: truy vấn DB theo empId, ym
        var row = sh.createRow(r++);
        row.createCell(0).setCellValue(empId != null && empId.length() > 0 ? empId : "Tất cả");
        row.createCell(1).setCellValue(ym != null ? ym.toString() : "");
        row.createCell(2).setCellValue(8.75);

        autosizeColumns(sh, 3);
    }

    private void exportTaskExcel(Workbook wb, String dept, String status) {
        Sheet sh = wb.createSheet("CongViec");
        int r = 0;
        var header = sh.createRow(r++);
        header.createCell(0).setCellValue("Phòng ban");
        header.createCell(1).setCellValue("Trạng thái");
        header.createCell(2).setCellValue("Tên công việc");
        header.createCell(3).setCellValue("Người phụ trách");
        header.createCell(4).setCellValue("Hạn hoàn thành");

        // TODO: truy vấn DB theo dept, status
        var row = sh.createRow(r++);
        row.createCell(0).setCellValue(dept != null ? dept : "Tất cả");
        row.createCell(1).setCellValue(status != null ? status : "");
        row.createCell(2).setCellValue("Thiết kế UI");
        row.createCell(3).setCellValue("Nguyễn Văn A");
        row.createCell(4).setCellValue("2025-09-20");

        autosizeColumns(sh, 5);
    }

    private void autosizeColumns(Sheet sh, int count) {
        for (int i = 0; i < count; i++) {
            sh.autoSizeColumn(i);
        }
    }

    // ====== PDF exports (OpenPDF) ======
    private void exportSummaryPDF(Document doc, LocalDate from, LocalDate to) throws Exception {
        doc.add(new Paragraph("BÁO CÁO TỔNG HỢP"));
        doc.add(new Paragraph("Khoảng thời gian: " +
                (from != null ? from.toString() : "") + " - " +
                (to != null ? to.toString() : "")));
        doc.add(Chunk.NEWLINE);

        PdfPTable tbl = new PdfPTable(2);
        tbl.setWidthPercentage(100);
        tbl.addCell("Chỉ tiêu");
        tbl.addCell("Giá trị");

        // TODO: dữ liệu thật từ DB
        tbl.addCell("Số công việc hoàn thành");
        tbl.addCell("42");

        doc.add(tbl);
    }

    private void exportKPIPDF(Document doc, String empId, YearMonth ym) throws Exception {
        doc.add(new Paragraph("BÁO CÁO KPI"));
        doc.add(new Paragraph("Nhân viên: " + (empId != null && empId.length() > 0 ? empId : "Tất cả")));
        doc.add(new Paragraph("Tháng: " + (ym != null ? ym.toString() : "")));
        doc.add(Chunk.NEWLINE);

        PdfPTable tbl = new PdfPTable(2);
        tbl.setWidthPercentage(100);
        tbl.addCell("Hạng mục");
        tbl.addCell("Giá trị");

        tbl.addCell("Điểm KPI trung bình");
        tbl.addCell("8.75");

        doc.add(tbl);
    }

    private void exportTaskPDF(Document doc, String dept, String status) throws Exception {
        doc.add(new Paragraph("BÁO CÁO CÔNG VIỆC"));
        doc.add(new Paragraph("Phòng ban: " + (dept != null ? dept : "Tất cả")));
        doc.add(new Paragraph("Trạng thái: " + (status != null ? status : "")));
        doc.add(Chunk.NEWLINE);

        PdfPTable tbl = new PdfPTable(4);
        tbl.setWidthPercentage(100);
        tbl.addCell("Tên công việc");
        tbl.addCell("Người phụ trách");
        tbl.addCell("Trạng thái");
        tbl.addCell("Hạn");

        // TODO: dữ liệu thật từ DB
        tbl.addCell("Thiết kế UI");
        tbl.addCell("Nguyễn Văn A");
        tbl.addCell(status != null ? status : "");
        tbl.addCell("2025-09-20");

        doc.add(tbl);
    }
}
