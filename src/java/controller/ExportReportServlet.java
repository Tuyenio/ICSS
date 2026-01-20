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
import java.awt.Color;
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

        // Ưu tiên lấy date range, nếu không có thì lấy tháng/năm
        String tuNgay = req.getParameter("tu_ngay");
        String denNgay = req.getParameter("den_ngay");
        String thangNam = req.getParameter("thangNam");
        
        int nambc, thangbc;
        String dateRangeLabel = "";
        
        if (tuNgay != null && !tuNgay.isEmpty() && denNgay != null && !denNgay.isEmpty()) {
            // Sử dụng date range
            dateRangeLabel = tuNgay + " đến " + denNgay;
            // Lấy năm từ tuNgay
            nambc = Integer.parseInt(tuNgay.split("-")[0]);
            thangbc = Integer.parseInt(tuNgay.split("-")[1]);
        } else if (thangNam != null && !thangNam.isEmpty()) {
            // Sử dụng tháng/năm cũ
            String[] parts = thangNam.split("-");
            nambc = Integer.parseInt(parts[0]);
            thangbc = Integer.parseInt(parts[1]);
            dateRangeLabel = "Thang_" + thangbc + "-" + nambc;
        } else {
            // Mặc định tháng hiện tại
            java.time.LocalDate now = java.time.LocalDate.now();
            nambc = now.getYear();
            thangbc = now.getMonthValue();
            dateRangeLabel = "Thang_" + thangbc + "-" + nambc;
        }

        // Đổi số tháng -> chữ (nếu bạn muốn hiển thị bằng chữ)
        String[] thangChu = {"", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"};

        // Lấy tên phòng ban (tùy loại báo cáo)
        String phongBan = null;
        if ("summary".equals(reportType)) {
            phongBan = req.getParameter("departmentTask");
        } else if ("project".equals(reportType)) {
            phongBan = req.getParameter("departmentProject");
        }

        // Xác định tên file
        String prefix = "summary".equals(reportType) ? "BaoCao_NhanVien_" : "BaoCao_DuAn_";
        if ("all".equalsIgnoreCase(phongBan) || phongBan == null || phongBan.isEmpty()) {
            baseName = prefix + dateRangeLabel.replace(" ", "_").replace("/", "-");
        } else {
            baseName = prefix + "Phong_" + phongBan.replace(" ", "_") + "_" + dateRangeLabel.replace(" ", "_").replace("/", "-");
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
                        String dept = param(req, "departmentTask");
                        if (tuNgay != null && !tuNgay.isEmpty() && denNgay != null && !denNgay.isEmpty()) {
                            exportSummaryExcelByDateRange(wb, tuNgay, denNgay, dept);
                        } else {
                            String thang = String.valueOf(thangbc);
                            String nam = String.valueOf(nambc);
                            exportSummaryExcel(wb, thang, nam, dept);
                        }
                    } else if ("project".equals(reportType)) {
                        String dept = param(req, "departmentProject");
                        String projectStatus = param(req, "projectStatus");
                        if (tuNgay != null && !tuNgay.isEmpty() && denNgay != null && !denNgay.isEmpty()) {
                            exportProjectExcel(wb, tuNgay, denNgay, dept, projectStatus);
                        }
                    }
                    wb.write(os);
                    os.flush();
                }
            } else {
                Document doc = new Document(PageSize.A4.rotate());
                PdfWriter.getInstance(doc, os);
                doc.open();

                if ("summary".equals(reportType)) {
                    String dept = param(req, "departmentTask");
                    if (tuNgay != null && !tuNgay.isEmpty() && denNgay != null && !denNgay.isEmpty()) {
                        exportSummaryPDFByDateRange(doc, tuNgay, denNgay, dept);
                    } else {
                        String thang = String.valueOf(thangbc);
                        String nam = String.valueOf(nambc);
                        exportSummaryPDF(doc, thang, nam, dept);
                    }
                } else if ("project".equals(reportType)) {
                    String dept = param(req, "departmentProject");
                    String projectStatus = param(req, "projectStatus");
                    if (tuNgay != null && !tuNgay.isEmpty() && denNgay != null && !denNgay.isEmpty()) {
                        exportProjectPDF(doc, tuNgay, denNgay, dept, projectStatus);
                    }
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

    private void exportSummaryExcelByDateRange(Workbook wb, String tuNgay, String denNgay, String phongBan) throws Exception {
        Sheet sh = wb.createSheet("BaoCaoTongHop");
        int r = 0;

        org.apache.poi.ss.usermodel.Row header = sh.createRow(r++);
        String[] cols = {"STT", "Nhân viên", "Phòng ban", "Số task", "Đã hoàn thành", "Đang thực hiện", "Trễ hạn", "Tỷ lệ hoàn thành"};
        for (int i = 0; i < cols.length; i++) header.createCell(i).setCellValue(cols[i]);

        List<Map<String, Object>> list = apiBaoCao.getBaoCaoNhanVienByDateRange(tuNgay, denNgay, phongBan);
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
    
    private void exportSummaryPDFByDateRange(Document doc, String tuNgay, String denNgay, String phongBan) throws Exception {
        doc.add(new Paragraph("BÁO CÁO TỔNG HỢP"));
        doc.add(new Paragraph("Từ ngày: " + tuNgay + " - Đến ngày: " + denNgay));
        doc.add(new Paragraph("Phòng ban: " + (phongBan != null && !phongBan.isEmpty() ? phongBan : "Tất cả")));
        doc.add(Chunk.NEWLINE);

        PdfPTable tbl = new PdfPTable(8);
        tbl.setWidthPercentage(100);
        String[] cols = {"STT", "Nhân viên", "Phòng ban", "Số task", "Đã hoàn thành", "Đang thực hiện", "Trễ hạn", "Tỷ lệ hoàn thành"};
        for (String c : cols) tbl.addCell(c);

        List<Map<String, Object>> list = apiBaoCao.getBaoCaoNhanVienByDateRange(tuNgay, denNgay, phongBan);
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
    
    /**
     * Xuất báo cáo dự án chi tiết ra Excel
     */
    private void exportProjectExcel(Workbook wb, String tuNgay, String denNgay, String phongBan, String trangThaiDuAn) throws Exception {
        Sheet sh = wb.createSheet("ChiTietDuAn");
        
        // ========== STYLES ==========
        // Header style
        CellStyle headerStyle = wb.createCellStyle();
        org.apache.poi.ss.usermodel.Font headerFont = wb.createFont();
        headerFont.setBold(true);
        headerFont.setColor(IndexedColors.WHITE.getIndex());
        headerFont.setFontHeightInPoints((short) 11);
        headerStyle.setFont(headerFont);
        headerStyle.setFillForegroundColor(IndexedColors.DARK_BLUE.getIndex());
        headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        headerStyle.setAlignment(HorizontalAlignment.CENTER);
        headerStyle.setVerticalAlignment(VerticalAlignment.CENTER);
        headerStyle.setBorderBottom(BorderStyle.THIN);
        headerStyle.setBorderTop(BorderStyle.THIN);
        headerStyle.setBorderLeft(BorderStyle.THIN);
        headerStyle.setBorderRight(BorderStyle.THIN);
        
        // Title style
        CellStyle titleStyle = wb.createCellStyle();
        org.apache.poi.ss.usermodel.Font titleFont = wb.createFont();
        titleFont.setBold(true);
        titleFont.setFontHeightInPoints((short) 14);
        titleStyle.setFont(titleFont);
        titleStyle.setAlignment(HorizontalAlignment.LEFT);
        
        // Data style
        CellStyle dataStyle = wb.createCellStyle();
        dataStyle.setBorderBottom(BorderStyle.THIN);
        dataStyle.setBorderTop(BorderStyle.THIN);
        dataStyle.setBorderLeft(BorderStyle.THIN);
        dataStyle.setBorderRight(BorderStyle.THIN);
        dataStyle.setVerticalAlignment(VerticalAlignment.TOP);
        dataStyle.setWrapText(true);
        
        // Center align style
        CellStyle centerStyle = wb.createCellStyle();
        centerStyle.setAlignment(HorizontalAlignment.CENTER);
        centerStyle.setVerticalAlignment(VerticalAlignment.CENTER);
        centerStyle.setBorderBottom(BorderStyle.THIN);
        centerStyle.setBorderTop(BorderStyle.THIN);
        centerStyle.setBorderLeft(BorderStyle.THIN);
        centerStyle.setBorderRight(BorderStyle.THIN);
        
        int r = 0;
        
        // Tiêu đề
        org.apache.poi.ss.usermodel.Row titleRow = sh.createRow(r++);
        org.apache.poi.ss.usermodel.Cell titleCell = titleRow.createCell(0);
        titleCell.setCellValue("BÁO CÁO CHI TIẾT DỰ ÁN - CÔNG VIỆC");
        titleCell.setCellStyle(titleStyle);
        sh.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 10));
        
        // Thông tin khoảng thời gian
        r++;
        org.apache.poi.ss.usermodel.Row infoRow1 = sh.createRow(r++);
        infoRow1.createCell(0).setCellValue("Từ ngày: " + tuNgay + " → Đến ngày: " + denNgay);
        if (phongBan != null && !phongBan.isEmpty()) {
            org.apache.poi.ss.usermodel.Row infoRow2 = sh.createRow(r++);
            infoRow2.createCell(0).setCellValue("Phòng ban: " + phongBan);
        }
        if (trangThaiDuAn != null && !trangThaiDuAn.isEmpty()) {
            org.apache.poi.ss.usermodel.Row infoRow3 = sh.createRow(r++);
            infoRow3.createCell(0).setCellValue("Trạng thái dự án: " + trangThaiDuAn);
        }
        r++; // Dòng trống
        
        // Header
        org.apache.poi.ss.usermodel.Row header = sh.createRow(r++);
        String[] cols = {"STT", "Dự án", "Trạng thái", "Leader", "Công việc", "Người nhận", 
                        "TT CV", "Ưu tiên", "Ngày BĐ", "Hạn HT", "Ngày HT"};
        for (int i = 0; i < cols.length; i++) {
            org.apache.poi.ss.usermodel.Cell cell = header.createCell(i);
            cell.setCellValue(cols[i]);
            cell.setCellStyle(headerStyle);
        }
        
        // Data
        List<Map<String, Object>> list = apiBaoCao.getChiTietCongViecDuAn(tuNgay, denNgay, phongBan, trangThaiDuAn);
        int stt = 1;
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
        
        for (Map<String, Object> item : list) {
            org.apache.poi.ss.usermodel.Row row = sh.createRow(r++);
            int col = 0;
            
            // STT
            org.apache.poi.ss.usermodel.Cell sttCell = row.createCell(col++);
            sttCell.setCellValue(stt++);
            sttCell.setCellStyle(centerStyle);
            
            // Dự án
            org.apache.poi.ss.usermodel.Cell projectCell = row.createCell(col++);
            projectCell.setCellValue((String) item.get("ten_du_an"));
            projectCell.setCellStyle(dataStyle);
            
            // Trạng thái
            org.apache.poi.ss.usermodel.Cell statusCell = row.createCell(col++);
            statusCell.setCellValue((String) item.get("trang_thai_duan"));
            statusCell.setCellStyle(centerStyle);
            
            // Leader
            org.apache.poi.ss.usermodel.Cell leadCell = row.createCell(col++);
            leadCell.setCellValue((String) item.get("leader"));
            leadCell.setCellStyle(dataStyle);
            
            // Công việc
            org.apache.poi.ss.usermodel.Cell taskCell = row.createCell(col++);
            taskCell.setCellValue((String) item.get("ten_cong_viec"));
            taskCell.setCellStyle(dataStyle);
            row.setHeightInPoints(Math.max(row.getHeightInPoints(), 30));
            
            // Người nhận
            org.apache.poi.ss.usermodel.Cell receiverCell = row.createCell(col++);
            receiverCell.setCellValue((String) item.get("nguoi_nhan"));
            receiverCell.setCellStyle(dataStyle);
            
            // Trạng thái CV
            org.apache.poi.ss.usermodel.Cell taskStatusCell = row.createCell(col++);
            taskStatusCell.setCellValue((String) item.get("trang_thai_cv"));
            taskStatusCell.setCellStyle(centerStyle);
            
            // Mức độ ưu tiên
            org.apache.poi.ss.usermodel.Cell priorityCell = row.createCell(col++);
            priorityCell.setCellValue((String) item.get("muc_do_uu_tien"));
            priorityCell.setCellStyle(centerStyle);
            
            // Ngày bắt đầu
            org.apache.poi.ss.usermodel.Cell startDateCell = row.createCell(col++);
            java.sql.Date ngayBatDau = (java.sql.Date) item.get("ngay_bat_dau");
            startDateCell.setCellValue(ngayBatDau != null ? sdf.format(ngayBatDau) : "");
            startDateCell.setCellStyle(centerStyle);
            
            // Hạn hoàn thành
            org.apache.poi.ss.usermodel.Cell dueDateCell = row.createCell(col++);
            java.sql.Date hanHoanThanh = (java.sql.Date) item.get("han_hoan_thanh");
            dueDateCell.setCellValue(hanHoanThanh != null ? sdf.format(hanHoanThanh) : "");
            dueDateCell.setCellStyle(centerStyle);
            
            // Ngày hoàn thành
            org.apache.poi.ss.usermodel.Cell completeDateCell = row.createCell(col++);
            java.sql.Date ngayHoanThanh = (java.sql.Date) item.get("ngay_hoan_thanh");
            completeDateCell.setCellValue(ngayHoanThanh != null ? sdf.format(ngayHoanThanh) : "");
            completeDateCell.setCellStyle(centerStyle);
        }
        
        // Auto-size columns & set width
        sh.setColumnWidth(0, 5 * 256);    // STT
        sh.setColumnWidth(1, 20 * 256);   // Dự án
        sh.setColumnWidth(2, 15 * 256);   // Trạng thái
        sh.setColumnWidth(3, 15 * 256);   // Leader
        sh.setColumnWidth(4, 25 * 256);   // Công việc
        sh.setColumnWidth(5, 15 * 256);   // Người nhận
        sh.setColumnWidth(6, 12 * 256);   // TT CV
        sh.setColumnWidth(7, 12 * 256);   // Ưu tiên
        sh.setColumnWidth(8, 12 * 256);   // Ngày BĐ
        sh.setColumnWidth(9, 12 * 256);   // Hạn HT
        sh.setColumnWidth(10, 12 * 256);  // Ngày HT
        
        // Freeze header row
        sh.createFreezePane(0, 4);
    }
    
    /**
     * Xuất báo cáo dự án chi tiết ra PDF
     */
    private void exportProjectPDF(Document doc, String tuNgay, String denNgay, String phongBan, String trangThaiDuAn) throws Exception {
        // Font cho tiếng Việt
        BaseFont bf = BaseFont.createFont("c:/windows/fonts/arial.ttf", BaseFont.IDENTITY_H, BaseFont.EMBEDDED);
        com.lowagie.text.Font titleFont = new com.lowagie.text.Font(bf, 14, com.lowagie.text.Font.BOLD);
        com.lowagie.text.Font headerFont = new com.lowagie.text.Font(bf, 9, com.lowagie.text.Font.BOLD);
        com.lowagie.text.Font normalFont = new com.lowagie.text.Font(bf, 8, com.lowagie.text.Font.NORMAL);
        com.lowagie.text.Font smallFont = new com.lowagie.text.Font(bf, 7, com.lowagie.text.Font.NORMAL);
        
        // Tiêu đề
        Paragraph title = new Paragraph("BÁO CÁO CHI TIẾT DỰ ÁN - CÔNG VIỆC", titleFont);
        title.setAlignment(Element.ALIGN_CENTER);
        doc.add(title);
        doc.add(Chunk.NEWLINE);
        
        // Thông tin (spacing)
        Paragraph info = new Paragraph();
        info.add(new Chunk("Từ ngày: ", normalFont));
        info.add(new Chunk(tuNgay, new com.lowagie.text.Font(bf, 8, com.lowagie.text.Font.BOLD)));
        info.add(new Chunk("  →  Đến ngày: ", normalFont));
        info.add(new Chunk(denNgay, new com.lowagie.text.Font(bf, 8, com.lowagie.text.Font.BOLD)));
        doc.add(info);
        
        if (phongBan != null && !phongBan.isEmpty()) {
            Paragraph pbInfo = new Paragraph("Phòng ban: " + phongBan, normalFont);
            doc.add(pbInfo);
        }
        
        if (trangThaiDuAn != null && !trangThaiDuAn.isEmpty()) {
            Paragraph statusInfo = new Paragraph("Trạng thái dự án: " + trangThaiDuAn, normalFont);
            doc.add(statusInfo);
        }
        
        doc.add(Chunk.NEWLINE);
        
        // Table - Chi tiết
        PdfPTable tbl = new PdfPTable(11);
        tbl.setWidthPercentage(100);
        tbl.setWidths(new int[]{3, 12, 8, 10, 16, 12, 8, 8, 8, 8, 8});
        tbl.getDefaultCell().setVerticalAlignment(com.lowagie.text.Element.ALIGN_MIDDLE);
        tbl.getDefaultCell().setPadding(4);
        
        // Header
        String[] cols = {"STT", "Dự án", "TT Dự án", "Leader", "Công việc", "Người nhận", 
                        "TT CV", "Ưu tiên", "Ngày BĐ", "Hạn HT", "Ngày HT"};
        for (String c : cols) {
            PdfPCell cell = new PdfPCell(new Phrase(c, headerFont));
            cell.setBackgroundColor(new Color(65, 105, 225)); // Xanh đậm
            cell.setHorizontalAlignment(Element.ALIGN_CENTER);
            cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
            cell.setPadding(6);
            tbl.addCell(cell);
        }
        
        // Data
        List<Map<String, Object>> list = apiBaoCao.getChiTietCongViecDuAn(tuNgay, denNgay, phongBan, trangThaiDuAn);
        int stt = 1;
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yy");
        
        if (list != null && !list.isEmpty()) {
            for (Map<String, Object> item : list) {
                // STT
                PdfPCell sttCell = new PdfPCell(new Phrase(String.valueOf(stt++), normalFont));
                sttCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                tbl.addCell(sttCell);
                
                // Dự án
                tbl.addCell(new Phrase((String) item.get("ten_du_an"), normalFont));
                
                // Trạng thái dự án
                PdfPCell statusCell = new PdfPCell(new Phrase((String) item.get("trang_thai_duan"), smallFont));
                statusCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                tbl.addCell(statusCell);
                
                // Leader
                tbl.addCell(new Phrase((String) item.get("leader"), smallFont));
                
                // Công việc
                tbl.addCell(new Phrase((String) item.get("ten_cong_viec"), normalFont));
                
                // Người nhận
                tbl.addCell(new Phrase((String) item.get("nguoi_nhan"), smallFont));
                
                // Trạng thái CV
                PdfPCell cvStatusCell = new PdfPCell(new Phrase((String) item.get("trang_thai_cv"), smallFont));
                cvStatusCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                tbl.addCell(cvStatusCell);
                
                // Ưu tiên
                PdfPCell priorityCell = new PdfPCell(new Phrase((String) item.get("muc_do_uu_tien"), smallFont));
                priorityCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                tbl.addCell(priorityCell);
                
                // Ngày bắt đầu
                java.sql.Date ngayBatDau = (java.sql.Date) item.get("ngay_bat_dau");
                PdfPCell startCell = new PdfPCell(new Phrase(ngayBatDau != null ? sdf.format(ngayBatDau) : "", smallFont));
                startCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                tbl.addCell(startCell);
                
                // Hạn hoàn thành
                java.sql.Date hanHoanThanh = (java.sql.Date) item.get("han_hoan_thanh");
                PdfPCell dueCell = new PdfPCell(new Phrase(hanHoanThanh != null ? sdf.format(hanHoanThanh) : "", smallFont));
                dueCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                tbl.addCell(dueCell);
                
                // Ngày hoàn thành
                java.sql.Date ngayHoanThanh = (java.sql.Date) item.get("ngay_hoan_thanh");
                PdfPCell completeCell = new PdfPCell(new Phrase(ngayHoanThanh != null ? sdf.format(ngayHoanThanh) : "", smallFont));
                completeCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                tbl.addCell(completeCell);
            }
        } else {
            // No data
            PdfPCell noDataCell = new PdfPCell(new Phrase("Không có dữ liệu", normalFont));
            noDataCell.setColspan(11);
            noDataCell.setHorizontalAlignment(Element.ALIGN_CENTER);
            tbl.addCell(noDataCell);
        }
        
        doc.add(tbl);
        
        // Footer
        doc.add(Chunk.NEWLINE);
        Paragraph footer = new Paragraph("Báo cáo được tạo tự động. Ngày: " + new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new java.util.Date()), smallFont);
        footer.setAlignment(Element.ALIGN_RIGHT);
        doc.add(footer);
    }
}
