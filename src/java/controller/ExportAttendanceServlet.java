package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.time.YearMonth;
import java.util.List;
import java.util.Map;
import java.util.ArrayList;

import controller.apiBaoCao;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import com.lowagie.text.*;
import com.lowagie.text.pdf.*;

@WebServlet(name = "ExportAttendanceServlet", urlPatterns = {"/exportAttendance"})
public class ExportAttendanceServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String exportType = param(req, "exportType");
        String thangNam = param(req, "thangNam");
        String employeeId = req.getParameter("employeeId");

        if (exportType == null || exportType.isEmpty()) {
            exportType = "Excel";
        }
        if (thangNam == null || thangNam.isEmpty()) {
            handleError(resp, "Thiếu dữ liệu tháng/năm.");
            return;
        }

        String[] parts = thangNam.split("-");
        String nam = parts[0];
        String thang = parts[1];

        String baseName = "ChamCong_" + (employeeId.equals("all") ? "TatCa" : "NV_" + employeeId) + "_" + thang + "-" + nam;
        String fileName = baseName + ("Excel".equalsIgnoreCase(exportType) ? ".xlsx" : ".pdf");

        prepareDownloadHeaders(resp,
                "Excel".equalsIgnoreCase(exportType)
                ? "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                : "application/pdf",
                fileName);

        try (OutputStream os = resp.getOutputStream()) {
            if ("Excel".equalsIgnoreCase(exportType)) {
                try (Workbook wb = new XSSFWorkbook()) {
                    exportExcel(wb, thang, nam, employeeId);
                    wb.write(os);
                }
            } else {
                Document doc = new Document(PageSize.A4.rotate());
                PdfWriter.getInstance(doc, os);
                doc.open();
                exportPDF(doc, thang, nam, employeeId);
                doc.close();
            }
        } catch (Exception e) {
            handleError(resp, "Lỗi xuất file: " + e.getMessage());
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

    private void handleError(HttpServletResponse resp, String message) throws IOException {
        resp.reset();
        resp.setContentType("text/plain; charset=UTF-8");
        resp.setStatus(500);
        PrintWriter pw = resp.getWriter();
        pw.println(message);
        pw.flush();
    }

    private void exportExcel(Workbook wb, String thang, String nam, String employeeId) throws Exception {
        Sheet sheet = wb.createSheet("ChamCong");
        int r = 0;

        String[] headers = {"STT", "Họ tên", "Phòng ban", "Ngày vào", "Ngày", "Check-in", "Check-out", "Số giờ", "Trạng thái", "Lương ngày"};
        var header = sheet.createRow(r++);
        for (int i = 0; i < headers.length; i++) {
            header.createCell(i).setCellValue(headers[i]);
        }

        KNCSDL kn = new KNCSDL();
        List<Map<String, Object>> list = kn.getDanhSachChamCong(thang, nam, null, null, employeeId);

        int stt = 1;
        for (Map<String, Object> cc : list) {
            var row = sheet.createRow(r++);
            row.createCell(0).setCellValue(stt++);
            row.createCell(1).setCellValue((String) cc.get("ho_ten"));
            row.createCell(2).setCellValue((String) cc.get("ten_phong"));
            row.createCell(3).setCellValue(String.valueOf(cc.get("ngay_vao_lam")));
            row.createCell(4).setCellValue(String.valueOf(cc.get("ngay")));
            row.createCell(5).setCellValue(String.valueOf(cc.get("check_in")));
            row.createCell(6).setCellValue(String.valueOf(cc.get("check_out")));
            row.createCell(7).setCellValue(cc.get("so_gio_lam") != null ? ((Number) cc.get("so_gio_lam")).doubleValue() : 0);
            row.createCell(8).setCellValue((String) cc.get("trang_thai"));
            row.createCell(9).setCellValue((Double) cc.get("luong_ngay"));
        }

        for (int i = 0; i < headers.length; i++) {
            sheet.autoSizeColumn(i);
        }
    }

    private void exportPDF(Document doc, String thang, String nam, String employeeId) throws Exception {
        doc.add(new Paragraph("PHIẾU CHẤM CÔNG", FontFactory.getFont(FontFactory.HELVETICA_BOLD, 16)));
        doc.add(new Paragraph("Tháng: " + thang + "/" + nam));
        doc.add(new Paragraph("Nhân viên: " + ("all".equals(employeeId) ? "Tất cả" : "ID: " + employeeId)));
        doc.add(Chunk.NEWLINE);

        PdfPTable table = new PdfPTable(10);
        table.setWidthPercentage(100);
        String[] headers = {"STT", "Họ tên", "Phòng ban", "Ngày vào", "Ngày", "Check-in", "Check-out", "Số giờ", "Trạng thái", "Lương ngày"};
        for (String h : headers) {
            table.addCell(h);
        }

        KNCSDL kn = new KNCSDL();
        List<Map<String, Object>> list = kn.getDanhSachChamCong(thang, nam, null, null, employeeId);

        int stt = 1;
        for (Map<String, Object> cc : list) {
            table.addCell(String.valueOf(stt++));
            table.addCell((String) cc.get("ho_ten"));
            table.addCell((String) cc.get("ten_phong"));
            table.addCell(String.valueOf(cc.get("ngay_vao_lam")));
            table.addCell(String.valueOf(cc.get("ngay")));
            table.addCell(String.valueOf(cc.get("check_in")));
            table.addCell(String.valueOf(cc.get("check_out")));
            table.addCell(cc.get("so_gio_lam") != null ? String.format("%.1f", (Double) cc.get("so_gio_lam")) : "0");
            table.addCell((String) cc.get("trang_thai"));
            table.addCell(String.format("%,.0f", (Double) cc.get("luong_ngay")));
        }

        doc.add(table);
    }

}
