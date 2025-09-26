package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.sql.PreparedStatement;

import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Row;

@MultipartConfig
public class UploadExcelServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Part filePart = request.getPart("excelFile");
        InputStream inputStream = filePart.getInputStream();

        try (Workbook workbook = WorkbookFactory.create(inputStream)) {
            Sheet sheet = workbook.getSheetAt(0);

            // gọi xử lý trong KNCSDL
            KNCSDL db = new KNCSDL();
            int inserted = db.importTasksFromExcel(sheet);

            response.sendRedirect("dsCongviec?import=success&count=" + inserted);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("dsCongviec?import=fail");
        }
    }
}