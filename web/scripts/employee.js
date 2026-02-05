function hasPermission(code) {
    return USER_PERMISSIONS && USER_PERMISSIONS.includes(code);
}

document.addEventListener("DOMContentLoaded", function () {

    if (!hasPermission("xem_nhanvien")) {
        $("#employeeTableBody").html(
                "<tr><td colspan='13' class='text-center text-danger'>Bạn không có quyền xem dữ liệu nhân sự</td></tr>"
                );
        $(".btn-primary").hide();
    }

    if (!hasPermission("them_nhanvien")) {
        // Nút thêm mới trên header
        $(".btn.btn-primary[data-bs-target='#modalEmployee']").hide();

        // Tắt nút Lưu trong modal
        $("#modalEmployee button[type=submit]").hide();
    }

    if (!hasPermission("sua_nhanvien")) {
        $(".edit-emp-btn").remove(); // nút sửa
        $("#modalEmployee button[type=submit]").hide(); // không cho lưu modal
    }

    if (!hasPermission("xoa_nhanvien")) {
        $(".delete-emp-btn").remove();
    }

    if (!hasPermission("xem_nhanvien")) {
        $(".emp-detail-link").css("pointer-events", "none")
                .addClass("text-muted")
                .removeClass("text-primary");
    }

    if (!hasPermission("phanquyen_nhanvien")) {
        // Ẩn TAB phân quyền
        $("#tab-permission").hide();

        // Ẩn nút Lưu phân quyền
        $("#btnSavePermissions").hide();
        $("#btnResetPermissions").hide();
        $("#btnCopyPermissions").hide();
    }
});
document.addEventListener("DOMContentLoaded", function () {

    // Tick tất cả quyền
    $("#checkAllPermission").on("change", function () {
        let checked = $(this).is(":checked");

        // Lấy toàn bộ checkbox con TRONG permissions-container
        $(".permissions-container .form-check-input").prop("checked", checked);
    });

});

function openAddModal() {
    $('#employeeForm')[0].reset();              // Xóa trắng tất cả field
    $('#empId').val('');                        // Gán ID rỗng => thêm mới
    $('#avatarPreview').attr('src', 'https://ui-avatars.com/api/?name=Avatar');
    $('#modalEmployee').modal('show');          // Mở modal
}

document.addEventListener("DOMContentLoaded", function () {
    // Load nhóm công việc
    fetch('./apiPhongban')
            .then(res => res.text())
            .then(html => {
                const defaultOption = '<option value="" selected>Tất cả phòng ban</option>';
                const finalHTML = defaultOption + html;

                // Gán cho cả bộ lọc và modal
                $('#menuloc select[name="ten_phong_ban"]').html(finalHTML);
                $('#modalnhanvien select[name="ten_phong_ban"]').html(html);

                // Gán flag đã load xong
                window.phongBanLoaded = true;
            });
});

//AJAX loc
$('#btnFilter').on('click', function () {
    const keyword = $('#searchName').val();
    const phongBan = $('#filterDepartment').val();
    const trangThai = $('#filterStatus').val();
    const vaiTro = $('#filterRole').val();

    $.ajax({
        url: './locNhanvien',
        type: 'POST',
        data: {
            keyword: keyword,
            phong_ban: phongBan,
            trang_thai: trangThai,
            vai_tro: vaiTro
        },
        success: function (html) {
            $('#employeeTableBody').html(html);
        },
        error: function () {
            $('#employeeTableBody').html("<tr><td colspan='13' class='text-danger text-center'>Lỗi khi lọc dữ liệu</td></tr>");
        }
    });
});
// AJAX tìm kiếm realtime
$('#searchName, #filterDepartment, #filterStatus, #filterRole').on('input change', function () {
    // TODO: AJAX load lại bảng nhân viên theo filter
    // $.get('api/employee', {...}, function(data){ ... });
});

function getBadgeClass(status) {
    switch (status) {
        case 'Đang làm':
            return 'bg-success';
        case 'Tạm nghỉ':
            return 'bg-warning text-dark';
        case 'Nghỉ việc':
            return 'bg-danger';
        default:
            return 'bg-secondary';
    }
}

function getRoleClass(role) {
    switch (role) {
        case 'Admin':
            return 'bg-danger text-white';
        case 'Quản lý':
            return 'bg-warning text-dark';
        case 'Nhân viên':
            return 'bg-info text-dark';
        default:
            return 'bg-secondary';
    }
}
// Nút xem chi tiết
$(document).on('click', '.emp-detail-link', function (e) {
    e.preventDefault();

    const email = $(this).data('email');

    $.ajax({
        url: './chitietNV',
        method: 'GET',
        data: {email: email},
        dataType: 'json',
        success: function (data) {
            // Lưu employee ID vào modal để sử dụng cho phân quyền
            $('#modalEmpDetail').data('employee-id', data.id);

            // Gán dữ liệu vào modal
            $('#modalEmpDetail .emp-name').text(data.ho_ten);
            $('#modalEmpDetail .emp-email').text(data.email);
            $('#modalEmpDetail .emp-phone').text(data.so_dien_thoai);
            $('#modalEmpDetail .emp-gender').text(data.gioi_tinh);
            $('#modalEmpDetail .emp-birth').text(data.ngay_sinh);
            $('#modalEmpDetail .emp-dept').text(data.ten_phong_ban);
            $('#modalEmpDetail .emp-position').text(data.chuc_vu);
            $('#modalEmpDetail .emp-start').text(data.ngay_vao_lam);

            const avatarUrl = data.avatar_url && data.avatar_url.trim() !== ''
                    ? data.avatar_url
                    : 'https://ui-avatars.com/api/?name=' + encodeURIComponent(data.ho_ten || 'User');

            $('#modalEmpDetail #avatarPreview').attr('src', avatarUrl);

            // Xử lý badge màu trạng thái
            const statusClass = getBadgeClass(data.trang_thai_lam_viec);
            $('#modalEmpDetail .emp-status')
                    .text(data.trang_thai_lam_viec)
                    .removeClass('bg-success bg-warning bg-danger bg-secondary')
                    .addClass(statusClass);

            // Xử lý badge màu vai trò
            const roleClass = getRoleClass(data.vai_tro);
            $('#modalEmpDetail .emp-role')
                    .text(data.vai_tro)
                    .removeClass('bg-danger bg-warning bg-info bg-secondary text-white text-dark')
                    .addClass(roleClass);

            // Reset tab về tab đầu tiên
            $('#empDetailTab .nav-link').removeClass('active');
            $('#empDetailTabContent .tab-pane').removeClass('show active');
            $('#tab-info').addClass('active');
            $('#tabInfo').addClass('show active');

            // Hiển thị modal
            const modal = new bootstrap.Modal(document.getElementById('modalEmpDetail'));
            modal.show();
        },
        error: function () {
            showToast('error', 'Không thể tải chi tiết nhân viên');
        }
    });
});

// Xem password
$(document).on('click', '#togglePassword', function () {
    const input = $('#empPassword');
    const type = input.attr('type') === 'password' ? 'text' : 'password';
    input.attr('type', type);

    // Toggle icon
    $(this).toggleClass('fa-eye fa-eye-slash');
});
// Nút sửa
$(document).on('click', '.edit-emp-btn', function () {
    const button = $(this);
    const phongBanId = button.data('phong-ban-id');

    function fillForm() {
        $('#empId').val(button.data('id'));
        $('#empName').val(button.data('name'));
        $('#empEmail').val(button.data('email'));
        $('#empPassword').val(button.data('pass'));
        $('#empPhone').val(button.data('phone'));
        $('#empGender').val(button.data('gender'));
        $('#empBirth').val(button.data('birth'));
        $('#empStartDate').val(button.data('startdate'));

        // ✅ Gán đúng phòng ban theo ID (ví dụ: <option value="2">Phòng Kỹ thuật</option>)
        $('#empDepartment').val(phongBanId);

        $('#empPosition').val(button.data('position'));
        $('#empStatus').val(button.data('status'));
        $('#empRole').val(button.data('role'));
        $('#empAvatar').val(button.data('avatar'));

        // Avatar preview
        const avatarUrl = button.data('avatar') || 'https://ui-avatars.com/api/?name=' + encodeURIComponent(button.data('name'));
        $('#avatarPreview').attr('src', avatarUrl);

        // Hiển thị modal
        $('#modalEmployee').modal('show');
    }

    if (CURRENT_USER_CHUCVU.toLowerCase().includes('trưởng phòng')) {
        $('#empRole').prop('disabled', true); // Không cho chỉnh vai trò nếu người đăng nhập là Trưởng phòng
    } else {
        $('#empRole').prop('disabled', false);
    }

    // Nếu phòng ban đã load, thì điền luôn
    if (window.phongBanLoaded) {
        fillForm();
    } else {
        // Nếu chưa load xong, chờ rồi điền
        const interval = setInterval(() => {
            if (window.phongBanLoaded) {
                clearInterval(interval);
                fillForm();
            }
        }, 100);
    }
});

// Nút xoá
$(document).on('click', '.delete-emp-btn', function () {
    const id = $(this).data('id');
    const row = $(this).closest('tr');

    Swal.fire({
        title: 'Xác nhận xoá?',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonText: 'Xoá',
        cancelButtonText: 'Huỷ'
    }).then((result) => {
        if (result.isConfirmed) {
            // Gửi AJAX POST đến Servlet
            $.ajax({
                url: './xoaNhanvien',
                method: 'POST',
                data: {id: id},
                success: function (res) {
                    if (res.status === 'ok') {
                        const toastSuccess = bootstrap.Toast.getOrCreateInstance(document.getElementById('toastSuccess'));
                        toastSuccess.show();
                        row.remove(); // Xoá dòng khỏi bảng
                    } else {
                        const toastError = bootstrap.Toast.getOrCreateInstance(document.getElementById('toastError'));
                        toastError.show();
                    }
                },
                error: function () {
                    $('#toastError').toast('show');
                }
            });
        }
    });
});

// Submit form thêm/sửa
$('#employeeForm').on('submit', function (e) {
    e.preventDefault();
    // TODO: AJAX submit form
    $('#modalEmployee').modal('hide');
    $('#toastSuccess').toast('show');
});

// Toast init
document.querySelectorAll('.toast').forEach(toastEl => {
    const toast = bootstrap.Toast.getOrCreateInstance(toastEl, {delay: 2000});
});

// ============ PHÂN QUYỀN FUNCTIONS ============

// Định nghĩa các quyền mặc định theo vai trò
const DEFAULT_PERMISSIONS = {
    'Admin': [
        'xem_nhanvien', 'them_nhanvien', 'sua_nhanvien', 'xoa_nhanvien', 'phanquyen_nhanvien',
        'xem_phongban', 'them_phongban', 'sua_phongban', 'xoa_phongban',
        'xem_duan', 'them_duan', 'sua_duan', 'xoa_duan',
        'xem_congviec', 'them_congviec', 'sua_congviec', 'xoa_congviec',
        'duyet_congviec', 'capnhat_tiendo',
        'xem_chamcong', 'quanly_chamcong',
        'xem_luong', 'quanly_luong',
        'xem_baocao', 'xuat_baocao', 'xem_phan_tich',
        'sao_luu', 'khoi_phuc',
        'xem_nhatky', 'them_quytrinh','nhacviec','cauhinh_hethong','saoluu_khoiphuc'
    ],

    'Quản lý': [
        'xem_nhanvien', 'them_nhanvien', 'sua_nhanvien',
        'xem_phongban', 'them_phongban', 'sua_phongban',
        'xem_duan', 'them_duan', 'sua_duan',
        'xem_congviec', 'them_congviec', 'sua_congviec',
        'duyet_congviec', 'capnhat_tiendo',
        'xem_chamcong', 'quanly_chamcong',
        'xem_luong', 'quanly_luong',
        'xem_baocao', 'xuat_baocao', 'xem_phan_tich','xoa_duan','xoa_congviec','nhacviec','them_quytrinh'
    ],

    'Nhân viên': [
        'xem_duan',
        'xem_congviec', 'capnhat_tiendo',
        'xem_chamcong',
        'xem_luong'
    ]
};

// Lưu phân quyền
$('#btnSavePermissions').on('click', function () {
    const employeeId = $('#modalEmpDetail').data('employee-id'); // Lưu ID khi mở modal
    const permissions = [];

    $('.permissions-container input[type="checkbox"]:checked').each(function () {
        permissions.push($(this).attr('id'));
    });

    Swal.fire({
        title: 'Xác nhận lưu phân quyền?',
        text: `Bạn đã chọn ${permissions.length} quyền cho nhân viên này.`,
        icon: 'question',
        showCancelButton: true,
        confirmButtonText: 'Lưu',
        cancelButtonText: 'Hủy',
        confirmButtonColor: '#28a745'
    }).then((result) => {
        if (result.isConfirmed) {
            // TODO: AJAX call để lưu phân quyền vào database
            console.log('Saving permissions for employee:', employeeId, permissions);

            // Giả lập API call thành công
            setTimeout(() => {
                Swal.fire({
                    title: 'Thành công!',
                    text: 'Đã cập nhật phân quyền cho nhân viên.',
                    icon: 'success',
                    timer: 2000,
                    showConfirmButton: false
                });
            }, 500);
        }
    });
});

// Khôi phục quyền mặc định
$('#btnResetPermissions').on('click', function () {
    const role = $('#modalEmpDetail .emp-role').text().trim();
    const defaultPerms = DEFAULT_PERMISSIONS[role];

    if (!defaultPerms) {
        showToast('error', 'Không tìm thấy quyền mặc định của vai trò!');
        return;
    }

    Swal.fire({
        title: 'Khôi phục quyền mặc định?',
        text: `Áp dụng quyền mặc định cho vai trò "${role}".`,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonText: 'Khôi phục',
        cancelButtonText: 'Hủy',
        confirmButtonColor: '#ffc107'
    }).then((result) => {
        if (result.isConfirmed) {

            // ❌ Bỏ chọn tất cả checkbox
            $('.permissions-container input[type="checkbox"]').prop('checked', false);

            // ✔ Chọn lại quyền mặc định
            defaultPerms.forEach(q => {
                $('#' + q).prop('checked', true);
            });

            showToast('success', 'Đã khôi phục quyền mặc định');
        }
    });
});

// Sao chép quyền từ vai trò khác
$('#btnCopyPermissions').on('click', function () {
    Swal.fire({
        title: 'Sao chép quyền từ vai trò',
        input: 'select',
        inputOptions: {
            'Admin': 'Admin (Toàn quyền)',
            'Quản lý': 'Quản lý (Quyền trung gian)',
            'Nhân viên': 'Nhân viên (Quyền cơ bản)'
        },
        inputPlaceholder: 'Chọn vai trò',
        showCancelButton: true,
        confirmButtonText: 'Sao chép',
        cancelButtonText: 'Hủy',
        confirmButtonColor: '#17a2b8'
    }).then((result) => {
        if (result.isConfirmed && result.value) {

            const roleCopy = result.value;
            const perms = DEFAULT_PERMISSIONS[roleCopy];

            if (!perms) {
                showToast('error', 'Vai trò không hợp lệ!');
                return;
            }

            // ❌ Bỏ chọn tất cả checkbox
            $('.permissions-container input[type="checkbox"]').prop('checked', false);

            // ✔ Chọn quyền theo vai trò đã copy
            perms.forEach(p => {
                $('#' + p).prop('checked', true);
            });

            showToast('success', `Đã sao chép quyền từ vai trò "${roleCopy}"`);
        }
    });
});

// Cập nhật trạng thái "Chọn tất cả"
const total = $('.permissions-container .form-check-input').length;
const checked = $('.permissions-container .form-check-input:checked').length;

$("#checkAllPermission").prop("checked", total === checked);

// Avatar preview
$('#empAvatar').on('input', function () {
    $('#avatarPreview').attr('src', $(this).val() || 'https://ui-avatars.com/api/?name=Avatar');
});



$('#employeeForm').on('submit', function (e) {
    e.preventDefault(); // Ngăn form gửi mặc định

    const empId = $('#empId').val(); // Dùng empId để phân biệt thêm/sửa
    const email = $('#empEmail').val();
    const phone = $('#empPhone').val();

    // ✅ VALIDATION EMAIL
    const emailRegex = /^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;
    if (!emailRegex.test(email)) {
        showToast('error', '❌ Email không đúng định dạng!');
        return;
    }

    // ✅ VALIDATION SỐ ĐIỆN THOẠI (chỉ số, 10-11 chữ số)
    if (phone && phone.trim() !== '') {
        const phoneRegex = /^[0-9]{10,11}$/;
        if (!phoneRegex.test(phone)) {
            showToast('error', '❌ Số điện thoại không đúng định dạng! (10-11 chữ số)');
            return;
        }
    }

    const formData = $(this).serialize(); // Lấy toàn bộ dữ liệu form

    const url = empId ? './dsnhanvien' : './themNhanvien';

    $.ajax({
        url: url,
        type: 'POST',
        data: formData,
        success: function (response) {
            if (response === 'error_email') {
                showToast('error', '❌ Email không đúng định dạng!');
                return;
            }
            if (response === 'error_phone') {
                showToast('error', '❌ Số điện thoại không đúng định dạng! (10-11 chữ số)');
                return;
            }
            $('#modalEmployee').modal('hide');
            showToast('success', empId ? 'Cập nhật thành công' : 'Thêm mới thành công');
            location.reload(); // Hoặc cập nhật bảng bằng JS
        },
        error: function () {
            showToast('error', empId ? 'Cập nhật thất bại' : 'Thêm mới thất bại');
        }
    });
});

$(document).on('shown.bs.tab', '#tab-permission', function () {

    const idNV = $('#modalEmpDetail').data('employee-id');

    $.get('./loadQuyenNV', {id: idNV}, function (ds) {

        $('.permissions-container input[type="checkbox"]').prop('checked', false);

        ds.forEach(mq => {
            $('#' + mq).prop('checked', true);
        });
    });
});

$('#btnSavePermissions').click(function () {

    const idNV = $('#modalEmpDetail').data('employee-id');
    const dsQuyen = [];

    $('.permissions-container input[type="checkbox"]:checked').each(function () {
        const id = $(this).attr('id');
        if (id !== 'checkAllPermission') {   // bỏ checkbox chọn tất cả
            dsQuyen.push(id);
        }
    });

    $.ajax({
        url: './luuQuyenNV',
        method: 'POST',
        traditional: true,
        data: {id: idNV, 'quyen[]': dsQuyen},
        success: function (res) {
            if (res.status === "ok") {
                showToast('success', 'Đã lưu phân quyền!');
            } else {
                showToast('error', 'Lưu thất bại!');
            }
        },
        error: function () {
            showToast('error', 'Có lỗi xảy ra!');
        }
    });
});

function showToast(type, message) {
    const toastId = type === 'success' ? 'toastSuccess' : 'toastError';
    const toastEl = document.getElementById(toastId);

    // Cập nhật nội dung thông báo
    toastEl.querySelector('.toast-body').textContent = message;

    // Hiển thị toast
    const toast = bootstrap.Toast.getOrCreateInstance(toastEl, {delay: 2500});
    toast.show();
}