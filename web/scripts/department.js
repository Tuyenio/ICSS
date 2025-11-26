function hasPermission(code) {
    return USER_PERMISSIONS && USER_PERMISSIONS.includes(code);
}

document.addEventListener("DOMContentLoaded", function () {

    if (!hasPermission("xem_phongban")) {
        $("#departmentTableBody").html(
            `<tr><td colspan="6" class="text-center text-danger">
                Bạn không có quyền xem dữ liệu phòng ban
            </td></tr>`
        );

        // Ẩn nút thêm mới
        $(".btn-primary[data-bs-target='#modalDepartment']").hide();
    }

    if (!hasPermission("them_phongban")) {
        // Ẩn nút thêm mới
        $(".btn-primary[data-bs-target='#modalDepartment']").hide();

        // Ẩn nút Lưu trong modal
        $("#modalDepartment button[type=submit]").hide();
    }

    if (!hasPermission("sua_phongban")) {
        $(".edit-dept-btn").remove();  // nút sửa
        $("#modalDepartment button[type=submit]").hide(); // không cho lưu modal
    }

    if (!hasPermission("xoa_phongban")) {
        $(".delete-dept-btn").remove(); // nút xóa
    }

    if (!hasPermission("xem_phongban")) {
        $(".btn-info").remove();  // nút xem chi tiết
    }
});
// ================== LOAD DANH SÁCH NHÂN VIÊN ==================
function loadNhanVien() {
    fetch('./apiNhanvien')
        .then(function (res) { return res.text(); })
        .then(function (data) {
            var parser = new DOMParser();
            var doc = parser.parseFromString(data, 'text/html');
            var options = '<option value="">-- Chọn nhân viên --</option>';
            var opts = doc.querySelectorAll('option');
            for (var i = 0; i < opts.length; i++) {
                var item = opts[i];
                var value = item.getAttribute('value') ? item.getAttribute('value').trim() : '';
                var text = item.textContent ? item.textContent.trim() : '';
                if (value && text) {
                    options += '<option value="' + value + '">' + text + '</option>';
                }
            }
            document.getElementById('deptLeader').innerHTML = options;
        })
        .catch(function () {
            showToast('error', 'Không thể tải danh sách nhân viên!');
        });
}

// ================== MỞ MODAL THÊM PHÒNG BAN ==================
function showAddModal() {
    document.getElementById('deptId').value = '';
    document.getElementById('deptName').value = '';
    document.getElementById('deptLeader').value = '';
    document.querySelector('.modal-title').innerHTML =
        '<i class="fa-solid fa-building"></i> Thêm phòng ban mới';

    loadNhanVien();

    var modalEl = document.getElementById('modalDepartment');
    var modal = bootstrap.Modal.getOrCreateInstance(modalEl);
    modal.show();
}

// ================== NÚT SỬA PHÒNG BAN ==================
document.addEventListener('click', function (e) {
    var btn = e.target.closest('.edit-dept-btn');
    if (!btn) return;
    var id = btn.getAttribute('data-id');

    fetch('./apiChiTietPhongban?id=' + id)
        .then(function (res) { return res.json(); })
        .then(function (data) {
            document.getElementById('deptId').value = data.id;
            document.getElementById('deptName').value = data.ten_phong;

            loadNhanVien();
            setTimeout(function () {
                document.getElementById('deptLeader').value = data.truong_phong_id;
            }, 500);

            document.querySelector('.modal-title').innerHTML =
                '<i class="fa-solid fa-building"></i> Sửa thông tin phòng ban';

            var modalEl = document.getElementById('modalDepartment');
            var modal = bootstrap.Modal.getOrCreateInstance(modalEl);
            modal.show();
        })
        .catch(function () {
            showToast('error', 'Không thể tải thông tin phòng ban!');
        });
});

// ================== NÚT XÓA PHÒNG BAN ==================
document.addEventListener('click', function (e) {
    var btn = e.target.closest('.delete-dept-btn');
    if (!btn) return;
    var id = btn.getAttribute('data-id');

    Swal.fire({
        title: 'Xác nhận xóa?',
        text: 'Bạn có chắc chắn muốn xóa phòng ban này?',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonText: 'Xóa',
        cancelButtonText: 'Hủy',
        confirmButtonColor: '#dc3545'
    }).then(function (result) {
        if (result.isConfirmed) {
            fetch('./xoaPhongban', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: 'id=' + encodeURIComponent(id)
            })
                .then(function (res) { return res.json(); })
                .then(function (response) {
                    if (response.status === 'success') {
                        showToast('success', response.message);
                        setTimeout(function () { location.reload(); }, 1500);
                    } else {
                        showToast('error', response.message);
                    }
                })
                .catch(function () {
                    showToast('error', 'Lỗi khi xóa phòng ban!');
                });
        }
    });
});

// ================== SUBMIT FORM THÊM / SỬA ==================
document.getElementById('departmentForm').addEventListener('submit', function (e) {
    e.preventDefault();

    var id = document.getElementById('deptId').value;
    var tenPhong = document.getElementById('deptName').value;
    var truongPhongId = document.getElementById('deptLeader').value;
    var formData = 'id=' + encodeURIComponent(id) +
                   '&ten_phong=' + encodeURIComponent(tenPhong) +
                   '&truong_phong_id=' + encodeURIComponent(truongPhongId);

    var url = id ? './suaPhongban' : './themPhongban';

    fetch(url, {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: formData
    })
        .then(function (res) { return res.json(); })
        .then(function (response) {
            var modalEl = document.getElementById('modalDepartment');
            var modal = bootstrap.Modal.getOrCreateInstance(modalEl);
            modal.hide();

            if (response.status === 'success') {
                showToast('success', response.message);
                setTimeout(function () { location.reload(); }, 1500);
            } else {
                showToast('error', response.message);
            }
        })
        .catch(function () {
            showToast('error', 'Lỗi khi lưu dữ liệu!');
        });
});

// ================== HIỂN THỊ CHI TIẾT PHÒNG BAN ==================
document.addEventListener('click', function (e) {
    var target = e.target.closest('[data-bs-target="#modalDeptDetail"]');
    if (!target) return;
    var id = target.getAttribute('data-id');

    fetch('./apiChiTietPhongban?id=' + id)
        .then(function (res) { return res.json(); })
        .then(function (data) {
            var html = '<b>Tên phòng ban:</b> ' + data.ten_phong + '<br>';
            html += '<b>Trưởng phòng:</b> ' + (data.truong_phong_ten || 'Chưa có') + '<br>';
            html += '<b>Tổng nhân viên:</b> ' + data.nhan_vien_list.length + '<br>';
            html += '<b>Ngày tạo:</b> ' + formatDate(data.ngay_tao) + '<br><br>';

            if (data.nhan_vien_list.length > 0) {
                html += '<b>Danh sách nhân viên:</b><br><div class="row">';
                for (var i = 0; i < data.nhan_vien_list.length; i++) {
                    var nv = data.nhan_vien_list[i];
                    html += '<div class="col-md-6 mb-2">' +
                                '<div class="card card-body p-2">' +
                                    '<small><b>' + nv.ho_ten + '</b><br>' +
                                    nv.email + '<br>' +
                                    '<span class="badge bg-secondary">' + nv.chuc_vu + '</span> ' +
                                    '<span class="badge bg-info">' + nv.vai_tro + '</span>' +
                                    '</small>' +
                                '</div>' +
                            '</div>';
                }
                html += '</div>';
            } else {
                html += '<i class="text-muted">Chưa có nhân viên nào trong phòng ban này.</i>';
            }

            document.getElementById('tabDeptInfo').innerHTML = html;
        })
        .catch(function () {
            document.getElementById('tabDeptInfo').innerHTML =
                '<div class="alert alert-danger">Không thể tải thông tin phòng ban!</div>';
        });
});

// ================== HIỂN THỊ TOAST (BOOTSTRAP 5) ==================
function showToast(type, message) {
    var toastId = (type === 'success') ? 'toastSuccess' : 'toastError';
    var toastEl = document.getElementById(toastId);
    if (!toastEl) return;

    toastEl.querySelector('.toast-body').textContent = message;
    var toast = bootstrap.Toast.getOrCreateInstance(toastEl, {delay: 3000});
    toast.show();
}

// ================== HÀM FORMAT NGÀY ==================
function formatDate(dateString) {
    if (!dateString) return '';
    var date = new Date(dateString);
    var d = date.getDate().toString().padStart(2, '0');
    var m = (date.getMonth() + 1).toString().padStart(2, '0');
    var y = date.getFullYear();
    return d + '/' + m + '/' + y;
}

// ================== NÚT THÊM MỚI ==================
document.addEventListener('click', function (e) {
    var addBtn = e.target.closest('[data-bs-target="#modalDepartment"]');
    if (addBtn) showAddModal();
});

// ================== KHỞI TẠO ==================
document.addEventListener('DOMContentLoaded', function () {
    console.log('Trang quản lý phòng ban');
});
