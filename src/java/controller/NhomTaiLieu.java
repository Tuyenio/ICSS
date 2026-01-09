package controller;

import java.sql.Timestamp;

/**
 * Entity class đại diện cho bảng nhom_tai_lieu trong database Quản lý thông tin
 * nhóm tài liệu trong thư viện
 */
public class NhomTaiLieu {

    private int id;
    private String tenNhom;
    private String moTa;
    private String icon;
    private String mauSac;
    private int nguoiTaoId;
    private Timestamp ngayTao;
    private Timestamp ngayCapNhat;
    private String trangThai;
    private int thuTu;
    private String doiTuongXem;  // Đối tượng được xem: 'Tất cả', 'Giám đốc và Trưởng phòng', 'Chỉ nhân viên'

    // Thông tin bổ sung từ join
    private String tenNguoiTao;
    private int soLuongTaiLieu; // Số lượng tài liệu trong nhóm

    // Constructor mặc định
    public NhomTaiLieu() {
        this.trangThai = "Hoạt động";
        this.thuTu = 0;
        this.icon = "fa-folder";
        this.mauSac = "#3b82f6";
        this.doiTuongXem = "Tất cả";
    }

    // Constructor đầy đủ
    public NhomTaiLieu(int id, String tenNhom, String moTa, String icon, String mauSac,
            int nguoiTaoId, Timestamp ngayTao, Timestamp ngayCapNhat,
            String trangThai, int thuTu, String doiTuongXem) {
        this.id = id;
        this.tenNhom = tenNhom;
        this.moTa = moTa;
        this.icon = icon;
        this.mauSac = mauSac;
        this.nguoiTaoId = nguoiTaoId;
        this.ngayTao = ngayTao;
        this.ngayCapNhat = ngayCapNhat;
        this.trangThai = trangThai;
        this.thuTu = thuTu;
        this.doiTuongXem = doiTuongXem;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTenNhom() {
        return tenNhom;
    }

    public void setTenNhom(String tenNhom) {
        this.tenNhom = tenNhom;
    }

    public String getMoTa() {
        return moTa;
    }

    public void setMoTa(String moTa) {
        this.moTa = moTa;
    }

    public String getIcon() {
        return icon;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public String getMauSac() {
        return mauSac;
    }

    public void setMauSac(String mauSac) {
        this.mauSac = mauSac;
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

    public int getThuTu() {
        return thuTu;
    }

    public void setThuTu(int thuTu) {
        this.thuTu = thuTu;
    }

    public String getTenNguoiTao() {
        return tenNguoiTao;
    }

    public void setTenNguoiTao(String tenNguoiTao) {
        this.tenNguoiTao = tenNguoiTao;
    }

    public int getSoLuongTaiLieu() {
        return soLuongTaiLieu;
    }

    public void setSoLuongTaiLieu(int soLuongTaiLieu) {
        this.soLuongTaiLieu = soLuongTaiLieu;
    }

    public String getDoiTuongXem() {
        return doiTuongXem;
    }

    public void setDoiTuongXem(String doiTuongXem) {
        this.doiTuongXem = doiTuongXem;
    }

    @Override
    public String toString() {
        return "NhomTaiLieu{"
                + "id=" + id
                + ", tenNhom='" + tenNhom + '\''
                + ", moTa='" + moTa + '\''
                + ", icon='" + icon + '\''
                + ", mauSac='" + mauSac + '\''
                + ", nguoiTaoId=" + nguoiTaoId
                + ", ngayTao=" + ngayTao
                + ", ngayCapNhat=" + ngayCapNhat
                + ", trangThai='" + trangThai + '\''
                + ", thuTu=" + thuTu
                + ", doiTuongXem='" + doiTuongXem + '\''
                + ", soLuongTaiLieu=" + soLuongTaiLieu
                + +'}';
    }
}
