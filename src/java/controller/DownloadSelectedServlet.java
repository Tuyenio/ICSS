/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.util.zip.*;

public class DownloadSelectedServlet extends HttpServlet {
    private static final String UPLOAD_DIR = "uploads";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String[] fileNames = request.getParameterValues("fileNames");
        if (fileNames == null || fileNames.length == 0) {
            response.getWriter().println("Không có file nào được chọn.");
            return;
        }

        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;

        // Thiết lập header
        response.setContentType("application/zip");
        response.setHeader("Content-Disposition", "attachment;filename=selected_files.zip");

        try (ZipOutputStream zipOut = new ZipOutputStream(response.getOutputStream())) {
            byte[] buffer = new byte[1024];
            for (String fileName : fileNames) {
                File file = new File(uploadPath + File.separator + fileName);
                if (file.exists()) {
                    FileInputStream fis = new FileInputStream(file);
                    zipOut.putNextEntry(new ZipEntry(file.getName()));

                    int len;
                    while ((len = fis.read(buffer)) > 0) {
                        zipOut.write(buffer, 0, len);
                    }

                    zipOut.closeEntry();
                    fis.close();
                }
            }
        }
    }
}
