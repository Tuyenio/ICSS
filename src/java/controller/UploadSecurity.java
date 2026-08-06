package controller;

import java.nio.file.Paths;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

/**
 * Tiện ích bảo mật cho upload file:
 *  - Loại bỏ path traversal trong tên file (chỉ giữ basename)
 *  - Kiểm tra phần mở rộng theo whitelist, chặn các đuôi thực thi (jsp, php, exe, sh...)
 *  - Sinh tên lưu trữ an toàn, duy nhất
 *
 * Dùng chung cho toàn bộ servlet xử lý upload trong dự án.
 */
public final class UploadSecurity {

    private UploadSecurity() {}

    /** Các đuôi file được phép upload (tài liệu, ảnh, nén). */
    public static final Set<String> ALLOWED_EXT = new HashSet<>(Arrays.asList(
            "pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx", "txt", "csv",
            "png", "jpg", "jpeg", "gif", "webp", "bmp", "heic",
            "zip", "rar", "7z"
    ));

    /** Các đuôi tuyệt đối KHÔNG được phép (phòng thủ nhiều lớp). */
    public static final Set<String> BLOCKED_EXT = new HashSet<>(Arrays.asList(
            "jsp", "jspx", "jspf", "jhtml", "war", "ear", "class", "java",
            "sh", "bash", "exe", "dll", "bat", "cmd", "com", "msi", "scr",
            "php", "phtml", "phar", "asp", "aspx", "cgi", "pl", "py", "rb",
            "js", "mjs", "html", "htm", "svg", "xhtml", "htaccess"
    ));

    /** Ngoại lệ khi file upload không hợp lệ. */
    public static class InvalidUploadException extends RuntimeException {
        public InvalidUploadException(String message) { super(message); }
    }

    /** Lấy basename thuần (loại bỏ mọi thành phần đường dẫn / traversal). */
    public static String baseName(String submitted) {
        if (submitted == null) {
            throw new InvalidUploadException("Tên file rỗng");
        }
        String name = submitted.replace("\\", "/");
        name = Paths.get(name).getFileName().toString();
        name = name.replaceAll("[\\x00-\\x1F]", "").trim();
        if (name.isEmpty() || name.equals(".") || name.equals("..")) {
            throw new InvalidUploadException("Tên file không hợp lệ");
        }
        return name;
    }

    /** Lấy phần mở rộng (lowercase, không gồm dấu chấm). */
    public static String extension(String name) {
        int dot = name.lastIndexOf('.');
        if (dot < 0 || dot == name.length() - 1) {
            return "";
        }
        return name.substring(dot + 1).toLowerCase();
    }

    /**
     * Kiểm tra đuôi file hợp lệ (whitelist) và không chứa đuôi nguy hiểm.
     * @return true nếu được phép.
     */
    public static boolean extAllowed(String submitted) {
        try {
            String base = baseName(submitted);
            String ext = extension(base);
            if (ext.isEmpty() || BLOCKED_EXT.contains(ext) || !ALLOWED_EXT.contains(ext)) {
                return false;
            }
            // Chặn double-extension kiểu shell.jsp.png
            String lower = base.toLowerCase();
            for (String b : BLOCKED_EXT) {
                if (lower.contains("." + b + ".")) {
                    return false;
                }
            }
            return true;
        } catch (InvalidUploadException e) {
            return false;
        }
    }

    /** Thông điệp lỗi thân thiện khi đuôi không hợp lệ. */
    public static String rejectMessage() {
        return "Loại file không được phép. Chỉ chấp nhận: "
                + String.join(", ", ALLOWED_EXT);
    }

    /**
     * Sinh tên lưu trữ an toàn, duy nhất, giữ đúng đuôi đã được whitelist.
     * Ném InvalidUploadException nếu đuôi không hợp lệ.
     */
    public static String safeStorageName(String submitted) {
        String base = baseName(submitted);
        if (!extAllowed(base)) {
            throw new InvalidUploadException(rejectMessage());
        }
        return UUID.randomUUID().toString().replace("-", "")
                + "_" + System.currentTimeMillis() + "." + extension(base);
    }

    /**
     * Trả về basename đã được làm sạch ký tự lạ (giữ tên gốc để hiển thị/lưu).
     * Ném InvalidUploadException nếu đuôi không hợp lệ.
     */
    public static String sanitizedOriginalName(String submitted) {
        String base = baseName(submitted);
        if (!extAllowed(base)) {
            throw new InvalidUploadException(rejectMessage());
        }
        return base.replaceAll("[^A-Za-z0-9._\\-\\p{L}\\p{N} ]", "_");
    }
}
