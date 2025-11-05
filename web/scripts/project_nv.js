function goToProjectTask(projectId, event) {
// Ngăn click vào nút Xem/Sửa/Xóa bị trigger
if (event.target.tagName.toLowerCase() === 'button' ||
        event.target.closest('button')) {
return;
}
// Chuyển hướng sang servlet khác
window.location.href = "dsCongviecDuan?projectId=" + projectId;
}

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
        event.stopPropagation();
        currentProjectId = projectId;
        $.getJSON("chitietDuan", {id: projectId}, function (project) {
        if (project && !project.error) {
        $("#detailTenDuAn").text(project.ten_du_an);
                $("#detailMoTa").text(project.mo_ta || 'Chưa có mô tả');
                $("#detailNgayBatDau").text(formatDate(project.ngay_bat_dau));
                $("#detailNgayKetThuc").text(formatDate(project.ngay_ket_thuc));
                $("#detailNgayTao").text(formatDate(project.ngay_tao));
                $("#detailTongCongViec").text(project.tong_cong_viec || 0);
                $("#detailTongNguoi").text(project.tong_nguoi || 0);
                $("#modalProjectDetail").modal("show");
        } else {
        showToast('error', project.error || "Không lấy được chi tiết dự án");
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
                $("#modalProject").modal("show");
        } else {
        showToast('error', project.error || "Không lấy được dữ liệu dự án");
        }
        });
            }

            // Set ngày tối thiểu là hôm nay cho các trường ngày
            document.addEventListener('DOMContentLoaded', function () {
        const today = new Date().toISOString().split('T')[0];
        const startDateInput = document.querySelector('input[name="ngay_bat_dau"]');
        const endDateInput = document.querySelector('input[name="ngay_ket_thuc"]');
        if (startDateInput)
        startDateInput.setAttribute('min', today);
        if (endDateInput)
        endDateInput.setAttribute('min', today);
        // Khi thay đổi ngày bắt đầu, update ngày kết thúc tối thiểu
        if (startDateInput) {
startDateInput.addEventListener('change', function () {
if (endDateInput) {
endDateInput.setAttribute('min', this.value);
}
});
}
            });