/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author Admin
 */
public class apiBaoCao {

    public static Map<String, Object> getDataForPieChart(String tuNgay, String denNgay, String phongBan) {
        try {
            KNCSDL kn = new KNCSDL();
            return kn.getDataForPieChart(tuNgay, denNgay, phongBan);
        } catch (Exception e) {
            e.printStackTrace();
            return new HashMap<>();
        }
    }

    public static Map<String, Object> getDataForBarChart(HttpSession session, String tuNgay, String denNgay, String phongBan) {
        try {
            KNCSDL kn = new KNCSDL();
            return kn.getDataForBarChart(session, tuNgay, denNgay, phongBan);
        } catch (Exception e) {
            e.printStackTrace();
            return new HashMap<>();
        }
    }

    public static List<Map<String, Object>> getBaoCaoNhanVien(String thang, String nam, String phongBan) {
        try {
            KNCSDL kn = new KNCSDL();
            return kn.getBaoCaoTongHopNhanVien(thang, nam, phongBan);
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    // Phương thức mới: lấy báo cáo theo khoảng thời gian
    public static List<Map<String, Object>> getBaoCaoNhanVienByDateRange(String tuNgay, String denNgay, String phongBan) {
        try {
            KNCSDL kn = new KNCSDL();
            return kn.getBaoCaoTongHopNhanVienByDateRange(tuNgay, denNgay, phongBan);
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    public static List<Map<String, Object>> getBaoCaoDuAnByDateRange(String tuNgay, String denNgay, String phongBan) {
        try {
            KNCSDL kn = new KNCSDL();
            return kn.getBaoCaoDuAnByDateRange(tuNgay, denNgay, phongBan);
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    public static List<Map<String, Object>> getChiTietCongViecDuAn(String tuNgay, String denNgay, String phongBan, String trangThaiDuAn) {
        try {
            KNCSDL kn = new KNCSDL();
            return kn.getChiTietCongViecDuAn(tuNgay, denNgay, phongBan, trangThaiDuAn);
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    public static String convertToJson(Map<String, Object> data) {
        StringBuilder json = new StringBuilder();
        json.append("{");

        @SuppressWarnings("unchecked")
        List<String> labels = (List<String>) data.get("labels");
        @SuppressWarnings("unchecked")
        List<? extends Number> values = (List<? extends Number>) data.get("data");

        if (labels != null && values != null) {
            json.append("\"labels\":[");
            for (int i = 0; i < labels.size(); i++) {
                if (i > 0) {
                    json.append(",");
                }
                json.append("\"").append(escapeJson(labels.get(i))).append("\"");
            }
            json.append("],");

            json.append("\"data\":[");
            for (int i = 0; i < values.size(); i++) {
                if (i > 0) {
                    json.append(",");
                }
                json.append(values.get(i));
            }
            json.append("]");
        }

        json.append("}");
        return json.toString();
    }

    public static String convertListToJson(List<Map<String, Object>> list) {
        StringBuilder json = new StringBuilder();
        json.append("[");

        for (int i = 0; i < list.size(); i++) {
            if (i > 0) {
                json.append(",");
            }
            Map<String, Object> item = list.get(i);
            json.append("{");

            boolean first = true;
            for (Map.Entry<String, Object> entry : item.entrySet()) {
                if (!first) {
                    json.append(",");
                }
                json.append("\"").append(entry.getKey()).append("\":");

                Object value = entry.getValue();
                if (value == null) {
                    json.append("null");
                } else if (value instanceof String) {
                    json.append("\"").append(escapeJson(value.toString())).append("\"");
                } else {
                    json.append(value.toString());
                }
                first = false;
            }

            json.append("}");
        }

        json.append("]");
        return json.toString();
    }

    private static String escapeJson(String input) {
        if (input == null) {
            return "";
        }
        return input.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}
