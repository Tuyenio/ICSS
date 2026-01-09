package controller;

import java.sql.Timestamp;

/**
 * Entity class đại diện cho bảng tai_lieu trong database
 * Quản lý thông tin tài liệu trong thư viện tài liệu
 */
public class TaiLieu {
    private int id;
    private int nhomTaiLieuId;  // Thêm field nhóm tài liệu
    private String tenTaiLieu;
    private String loaiTaiLieu;
    private String moTa;
    private String fileName;
    private String filePath;
    private long fileSize;
    private String fileType;
    private int nguoiTaoId;
    private Timestamp ngayTao;
    private Timestamp ngayCapNhat;
    private String trangThai;
    private int luotXem;
    private int luotTai;
    private String doiTuongXem;  // Đối tượng được xem: 'Tất cả', 'Giám đốc và Trưởng phòng', 'Chỉ nhân viên'
    
    // Thông tin bổ sung từ join
    private String tenNguoiTao;
    private String avatarNguoiTao;
    private String tenNhomTaiLieu;  // Tên nhóm tài liệu

    // Constructor mặc định
    public TaiLieu() {
        this.trangThai = "Hoạt động";
        this.luotXem = 0;
        this.luotTai = 0;
        this.doiTuongXem = "Tất cả";
    }

    // Constructor đầy đủ
    public TaiLieu(int id, int nhomTaiLieuId, String tenTaiLieu, String loaiTaiLieu, String moTa, 
                   String fileName, String filePath, long fileSize, String fileType,
                   int nguoiTaoId, Timestamp ngayTao, Timestamp ngayCapNhat, 
                   String trangThai, int luotXem, int luotTai) {
        this.id = id;
        this.nhomTaiLieuId = nhomTaiLieuId;
        this.tenTaiLieu = tenTaiLieu;
        this.loaiTaiLieu = loaiTaiLieu;
        this.moTa = moTa;
        this.fileName = fileName;
        this.filePath = filePath;
        this.fileSize = fileSize;
        this.fileType = fileType;
        this.nguoiTaoId = nguoiTaoId;
        this.ngayTao = ngayTao;
        this.ngayCapNhat = ngayCapNhat;
        this.trangThai = trangThai;
        this.luotXem = luotXem;
        this.luotTai = luotTai;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTenTaiLieu() {
        return tenTaiLieu;
    }

    public void setTenTaiLieu(String tenTaiLieu) {
        this.tenTaiLieu = tenTaiLieu;
    }

    public String getLoaiTaiLieu() {
        return loaiTaiLieu;
    }

    public void setLoaiTaiLieu(String loaiTaiLieu) {
        this.loaiTaiLieu = loaiTaiLieu;
    }

    public String getMoTa() {
        return moTa;
    }

    public void setMoTa(String moTa) {
        this.moTa = moTa;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public String getFilePath() {
        return filePath;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }

    public long getFileSize() {
        return fileSize;
    }

    public void setFileSize(long fileSize) {
        this.fileSize = fileSize;
    }

    public String getFileType() {
        return fileType;
    }

    public void setFileType(String fileType) {
        this.fileType = fileType;
    }

    public int getNguoiTaoId() {
        return nguoiTaoId;
    }

    public void setNguoiTaoId(int nguoiTaoId) {
        this.nguoiTaoId = nguoiTaoId;
    }

    public Timestamp getNgayTao() {
        return ngayTao;
    }

    public void setNgayTao(Timestamp ngayTao) {
        this.ngayTao = ngayTao;
    }

    public Timestamp getNgayCapNhat() {
        return ngayCapNhat;
    }

    public void setNgayCapNhat(Timestamp ngayCapNhat) {
        this.ngayCapNhat = ngayCapNhat;
    }

    public String getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(String trangThai) {
        this.trangThai = trangThai;
    }

    public int getLuotXem() {
        return luotXem;
    }

    public void setLuotXem(int luotXem) {
        this.luotXem = luotXem;
    }

    public int getLuotTai() {
        return luotTai;
    }

    public void setLuotTai(int luotTai) {
        this.luotTai = luotTai;
    }

    public String getTenNguoiTao() {
        return tenNguoiTao;
    }

    public void setTenNguoiTao(String tenNguoiTao) {
        this.tenNguoiTao = tenNguoiTao;
    }

    public String getAvatarNguoiTao() {
        return avatarNguoiTao;
    }

    public void setAvatarNguoiTao(String avatarNguoiTao) {
        this.avatarNguoiTao = avatarNguoiTao;
    }

    public int getNhomTaiLieuId() {
        return nhomTaiLieuId;
    }

    public void setNhomTaiLieuId(int nhomTaiLieuId) {
        this.nhomTaiLieuId = nhomTaiLieuId;
    }

    public String getTenNhomTaiLieu() {
        return tenNhomTaiLieu;
    }

    public void setTenNhomTaiLieu(String tenNhomTaiLieu) {
        this.tenNhomTaiLieu = tenNhomTaiLieu;
    }

    public String getDoiTuongXem() {
        return doiTuongXem;
    }

    public void setDoiTuongXem(String doiTuongXem) {
        this.doiTuongXem = doiTuongXem;
    }

    /**
     * Trả về kích thước file dạng human-readable (KB, MB, GB)
     */
    public String getFileSizeFormatted() {
        if (fileSize < 1024) {
            return fileSize + " B";
        } else if (fileSize < 1024 * 1024) {
            return String.format("%.2f KB", fileSize / 1024.0);
        } else if (fileSize < 1024 * 1024 * 1024) {
            return String.format("%.2f MB", fileSize / (1024.0 * 1024));
        } else {
            return String.format("%.2f GB", fileSize / (1024.0 * 1024 * 1024));
        }
    }

    /**
     * Lấy icon FontAwesome dựa trên loại file
     */
    public String getFileIcon() {
        if (fileType == null) return "fa-file";
        
        if (fileType.contains("pdf")) return "fa-file-pdf";
        if (fileType.contains("word") || fileType.contains("document")) return "fa-file-word";
        if (fileType.contains("excel") || fileType.contains("spreadsheet")) return "fa-file-excel";
        if (fileType.contains("powerpoint") || fileType.contains("presentation")) return "fa-file-powerpoint";
        if (fileType.contains("image")) return "fa-file-image";
        if (fileType.contains("video")) return "fa-file-video";
        if (fileType.contains("audio")) return "fa-file-audio";
        if (fileType.contains("zip") || fileType.contains("rar") || fileType.contains("compressed")) return "fa-file-zipper";
        if (fileType.contains("text")) return "fa-file-lines";
        
        return "fa-file";
    }

    /**
     * Lấy màu icon dựa trên loại file
     */
    public String getFileIconColor() {
        if (fileType == null) return "#6c757d";
        
        if (fileType.contains("pdf")) return "#dc3545";
        if (fileType.contains("word") || fileType.contains("document")) return "#0d6efd";
        if (fileType.contains("excel") || fileType.contains("spreadsheet")) return "#198754";
        if (fileType.contains("powerpoint") || fileType.contains("presentation")) return "#fd7e14";
        if (fileType.contains("image")) return "#20c997";
        if (fileType.contains("video")) return "#6f42c1";
        if (fileType.contains("audio")) return "#d63384";
        if (fileType.contains("zip") || fileType.contains("rar") || fileType.contains("compressed")) return "#ffc107";
        
        return "#6c757d";
    }

    @Override
    public String toString() {
        return "TaiLieu{" +
                "id=" + id +
                ", tenTaiLieu='" + tenTaiLieu + '\'' +
                ", loaiTaiLieu='" + loaiTaiLieu + '\'' +
                ", fileName='" + fileName + '\'' +
                ", fileSize=" + fileSize +
                ", ngayTao=" + ngayTao +
                '}';
    }
}
