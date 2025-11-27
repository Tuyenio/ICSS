function hasPermission(code) {
    return USER_PERMISSIONS && USER_PERMISSIONS.includes(code);
}
document.addEventListener("DOMContentLoaded", function () {

    // 👉 1. Tạo dự án
    if (!hasPermission("them_duan")) {
        $(".btn-add-project").hide();      // nút Thêm dự án trên header
        $("#modalProject button[type=submit]").remove();  // không cho lưu trong modal
    }

    // 👉 2. Sửa dự án
    if (!hasPermission("sua_duan")) {
        $(".btn-warning").remove(); // nút edit trong bảng
        $("#modalProject button[type=submit]").remove();   // không cho lưu modal
    }

    // 👉 3. Xóa dự án
    if (!hasPermission("xoa_duan")) {
        $(".delete-project-btn").remove(); // nút xóa trong bảng
    }

    // 👉 4. Xem dự án (tuỳ bạn có muốn phân quyền hay không)
    if (!hasPermission("xem_duan")) {
        $(".btn-info").remove();  // nút xem chi tiết
        $(".project-row").css("pointer-events", "none"); // không click được
    }

});
$(document).on("click", ".project-row", function (e) {
    if ($(e.target).closest(".btn").length > 0) return;

    let id = $(this).data("id");
    window.location.href = "dsCongviecDuanNV?projectId=" + id;
});

// Hàm hiển thị toast
function showToast(type, message) {
    if (type === 'success') {
        $('#toastSuccess .toast-body').text(message);
        $('#toastSuccess').toast('show');
    } else {
        $('#toastError .toast-body').text(message);
        $('#toastError').toast('show');
    }
}

function initProjectSorting() {
    const headers = document.querySelectorAll('.project-list-view thead th.sortable');

    headers.forEach(header => {
        header.addEventListener('click', function () {
            const field = this.dataset.sort;
            const isAsc = this.classList.contains('sort-asc');

            headers.forEach(h => h.classList.remove('sort-asc', 'sort-desc'));
            this.classList.add(isAsc ? 'sort-desc' : 'sort-asc');

            sortProjectTable(field, isAsc ? 'desc' : 'asc');
        });
    });
}

function sortProjectTable(field, order) {
    const tbody = document.querySelector('.project-list-view tbody');
    const rows = Array.from(tbody.querySelectorAll('tr'));

    rows.sort((a, b) => {
        let aVal = a.dataset[field] || "";
        let bVal = b.dataset[field] || "";

        // Ưu tiên → sắp theo thứ tự custom
        if (field === 'uutien') {
            const priorityOrder = { "Thấp": 1, "Trung bình": 2, "Cao": 3 };
            aVal = priorityOrder[aVal] || 0;
            bVal = priorityOrder[bVal] || 0;
        }

        // Ngày → convert Date
        if (field === 'ngaybatdau' || field === 'ngayketthuc') {
            aVal = new Date(aVal);
            bVal = new Date(bVal);
        }

        if (aVal < bVal) return order === "asc" ? -1 : 1;
        if (aVal > bVal) return order === "asc" ? 1 : -1;
        return 0;
    });

    rows.forEach(r => tbody.appendChild(r));
}

document.addEventListener('DOMContentLoaded', function () {
    initProjectSorting();

    // 1) Sort theo ngày kết thúc (gần nhất → xa nhất)
    sortProjectTable("ngayketthuc", "asc");

    // 2) Sort theo ưu tiên (Cao → Trung bình → Thấp)
    sortProjectTable("uutien", "desc");
});

$(document).on('click', '.delete-project-btn', function () {
    let id = $(this).data('id');
    Swal.fire({
        title: 'Xác nhận xóa?',
        text: 'Bạn có chắc chắn muốn xóa dự án này?',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonText: 'Xóa',
        cancelButtonText: 'Hủy',
        confirmButtonColor: '#dc3545'
    }).then((result) => {
        if (result.isConfirmed) {
            $.ajax({
                url: './xoaDuan',
                type: 'POST',
                data: {id: id},
                dataType: 'json',
                success: function (response) {
                    console.log("Response:", response); // 👈 Debug
                    if (response && response.success) {
                        showToast('success', 'Đã xóa dự án thành công!');
                        setTimeout(() => location.reload(), 500); // reload luôn trang hiện tại
                    } else {
                        showToast('error', response.message || 'Xóa thất bại!');
                    }
                },
                error: function (xhr, status, error) {
                    console.error("Delete error:", xhr.responseText);
                    showToast('error', 'Lỗi khi xóa dự án!');
                }
            });
        }
    });
});

$("#projectForm").on("submit", function (e) {
    e.preventDefault();

    let formData = $(this).serialize(); // lấy toàn bộ input trong form
    let id = $("#projectForm input[name='id']").val();
    let url = id ? "suaDuan" : "themDuan"; // nếu có id → sửa, ngược lại thêm

    $.post(url, formData, function (response) {
        if (response.success) {
            Swal.fire({
                icon: 'success',
                title: 'Thành công',
                text: id ? 'Cập nhật dự án thành công!' : 'Thêm dự án thành công!'
            }).then(() => location.reload());
        } else {
            Swal.fire({
                icon: 'error',
                title: 'Lỗi',
                text: response.message || (id ? 'Sửa thất bại!' : 'Thêm thất bại!')
            });
        }
    }, 'json');
});

// Dữ liệu mẫu cho dự án (thay thế bằng dữ liệu thực từ backend)
const sampleProjects = {
    '1': {
        id: 1,
        ten_du_an: 'Dự án code Web',
        mo_ta: 'Xây dựng website quản lý nhân sự',
        ngay_bat_dau: '2025-01-15',
        ngay_ket_thuc: '2025-12-31',
        ngay_tao: '2025-01-10',
        tong_cong_viec: 8,
        tong_nguoi: 12
    }
};

let currentProjectId = null;

function showProjectDetail(event, projectId) {
    if (event)
        event.stopPropagation();
    currentProjectId = projectId;

    $.getJSON("chitietDuan", {id: projectId}, function (project) {

        if (project && !project.error) {
            $("#detailTenDuAn").text(project.ten_du_an);
            $("#detailMoTa").text(project.mo_ta ? project.mo_ta : "Chưa có mô tả");
            $("#detailNgayBatDau").text(project.ngay_bat_dau ? project.ngay_bat_dau : "");
            $("#detailNgayKetThuc").text(project.ngay_ket_thuc ? project.ngay_ket_thuc : "");
            $("#detailNgayTao").text(project.ngay_tao ? project.ngay_tao : "");
            $("#detailTongCongViec").text(project.tong_cong_viec ? project.tong_cong_viec : 0);
            $("#detailNhomDuAn").text(project.nhom_du_an);
            $("#detailPhongBan").text(project.phong_ban ? project.phong_ban : "Chưa phân");
            $("#detailTongNguoi").text(project.tong_nguoi ? project.tong_nguoi : 0);

            // Bootstrap 5 API để mở modal
            var modal = new bootstrap.Modal(document.getElementById("modalProjectDetail"));
            modal.show();
        } else {
            showToast('error', project.error ? project.error : "Không lấy được chi tiết dự án");
        }
    });
}

function editProject(projectId) {
    currentProjectId = projectId;
    $.getJSON("chitietDuan", {id: projectId}, function (project) {
        if (project && !project.error) {
            $("#projectForm")[0].reset();
            $("#projectForm input[name='id']").val(project.id);
            $("#projectForm input[name='ten_du_an']").val(project.ten_du_an);
            $("#projectForm textarea[name='mo_ta']").val(project.mo_ta);
            $("#projectForm input[name='ngay_bat_dau']").val(project.ngay_bat_dau);
            $("#projectForm input[name='ngay_ket_thuc']").val(project.ngay_ket_thuc);
            $("select[name='muc_do_uu_tien']").val(project.muc_do_uu_tien);
            $("select[name='nhom_du_an']").val(project.nhom_du_an);
            $("select[name='phong_ban']").val(project.phong_ban);
            // 🔥 Load Lead dự án
            $("select[name='lead_id']").val(project.lead_id);

            $("#modalProject").modal("show");
        } else {
            showToast('error', project.error || "Không lấy được dữ liệu dự án");
        }
    });
}
