// ========== UTILITY FUNCTIONS ==========

// Toast notification function
function showToast(type, message) {
    const Toast = Swal.mixin({
        toast: true,
        position: 'top-end',
        showConfirmButton: false,
        timer: 3000,
        timerProgressBar: true,
        didOpen: (toast) => {
            toast.addEventListener('mouseenter', Swal.stopTimer);
            toast.addEventListener('mouseleave', Swal.resumeTimer);
        }
    });

    Toast.fire({
        icon: type,
        title: message
    });
}

// Helper function để cập nhật hidden input
function capNhatHiddenInput(danhSachDiv, hiddenInput) {
    var values = [];
    var badges = danhSachDiv.querySelectorAll("span");
    for (var i = 0; i < badges.length; i++) {
        values.push(badges[i].dataset.ten);
    }
    hiddenInput.value = values.join(",");
}

// ========== MODAL CONTROL FUNCTIONS ==========

var currentTarget = null;

// Mở modal thêm công việc cho dự án
function openAddTaskModal(projectId) {
    // Set project ID vào hidden field
    document.getElementById('taskProjectId').value = projectId;
    
    // Reset form
    document.getElementById('taskForm').reset();
    document.getElementById('danhSachNguoiNhan2').innerHTML = '';
    document.getElementById('nguoiNhanHidden2').value = '';
    
    // Hiển thị modal
    const modal = new bootstrap.Modal(document.getElementById('modalTask'));
    modal.show();
}

// Mở modal thêm công việc con (quy trình)
function openAddSubTaskModal(projectId, taskId) {
    // Set task ID vào hidden field
    document.getElementById('processParentTaskId').value = taskId;
    
    // Reset form
    document.getElementById('formAddProcessStep').reset();
    document.getElementById('danhSachNguoiNhanProcess').innerHTML = '';
    document.getElementById('nguoiNhanProcessHidden').value = '';
    
    // Hiển thị modal
    const modal = new bootstrap.Modal(document.getElementById('modalAddProcessStep'));
    modal.show();
}

// ========== NGƯỜI NHẬN SELECTION ==========

// Sync checkboxes với hidden input
function syncNguoiNhanCheckboxes(hiddenId) {
    const hidden = document.getElementById(hiddenId);
    if (!hidden) return;
    
    const selected = hidden.value.split(',').map(s => s.trim()).filter(s => s);
    
    document.querySelectorAll('.nguoiNhanItem').forEach(cb => {
        cb.checked = selected.includes(cb.value);
    });
}

// Nút trong modal tạo công việc
document.getElementById("btnOpenNguoiNhanCreate").addEventListener("click", function () {
    currentTarget = 'nguoiNhanHidden2';
    syncNguoiNhanCheckboxes(currentTarget);
    const modal = new bootstrap.Modal(document.getElementById('modalChonNguoiNhan'));
    modal.show();
});

// Nút trong modal thêm quy trình
document.getElementById("btnOpenNguoiNhanProcess").addEventListener("click", function () {
    currentTarget = 'nguoiNhanProcessHidden';
    syncNguoiNhanCheckboxes(currentTarget);
    const modal = new bootstrap.Modal(document.getElementById('modalChonNguoiNhan'));
    modal.show();
});

// Xác nhận chọn người nhận
document.getElementById("btnXacNhanNguoiNhan").addEventListener("click", function () {
    if (!currentTarget) return;
    
    const checkboxes = document.querySelectorAll('.nguoiNhanItem:checked');
    const selectedIds = Array.from(checkboxes).map(cb => cb.value);  // ✅ Lấy ID
    const selectedNames = Array.from(checkboxes).map(cb => cb.getAttribute('data-name'));  // ✅ Lấy tên từ data-name
    
    // Cập nhật hidden input với ID (phân cách bởi dấu phẩy)
    const hiddenInput = document.getElementById(currentTarget);
    if (hiddenInput) {
        hiddenInput.value = selectedIds.join(',');
    }
    
    // Cập nhật display tags
    let danhSachDiv;
    if (currentTarget === 'nguoiNhanHidden2') {
        danhSachDiv = document.getElementById('danhSachNguoiNhan2');
    } else if (currentTarget === 'nguoiNhanProcessHidden') {
        danhSachDiv = document.getElementById('danhSachNguoiNhanProcess');
    }
    
    if (danhSachDiv) {
        danhSachDiv.innerHTML = '';
        selectedNames.forEach(name => {
            const tag = document.createElement("span");
            tag.className = "badge bg-primary d-flex align-items-center me-2 mb-1";
            tag.style.padding = "0.5em 0.75em";
            tag.dataset.ten = name;
            tag.innerHTML = name + 
                '<button type="button" class="btn btn-sm btn-close ms-2" aria-label="Xoá"></button>';
            
            tag.querySelector(".btn-close").addEventListener("click", function () {
                tag.remove();
                capNhatHiddenInput(danhSachDiv, hiddenInput);
            });
            
            danhSachDiv.appendChild(tag);
        });
    }
    
    // Đóng modal
    bootstrap.Modal.getInstance(document.getElementById('modalChonNguoiNhan')).hide();
});

// ========== FORM SUBMISSIONS ==========

// Submit form tạo công việc
$('#taskForm').on('submit', function (e) {
    e.preventDefault();
    
    const projectId = document.getElementById('taskProjectId').value;
    if (!projectId) {
        showToast('error', '❌ Không xác định được ID dự án!');
        return;
    }
    
    const formData = new FormData(this);
    
    // Đảm bảo du_an_id được gửi đi
    formData.set('du_an_id', projectId);
    
    fetch('./themCongviec', {
        method: 'POST',
        body: formData
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            showToast('success', '✅ Thêm công việc thành công!');
            bootstrap.Modal.getInstance(document.getElementById('modalTask')).hide();
            setTimeout(() => location.reload(), 1500);
        } else {
            showToast('error', data.message || '❌ Lỗi khi thêm công việc');
        }
    })
    .catch(err => {
        console.error(err);
        showToast('error', '❌ Lỗi kết nối server');
    });
});

// Submit form thêm quy trình (công việc con)
$('#formAddProcessStep').on('submit', function (e) {
    e.preventDefault();
    
    const taskId = document.getElementById('processParentTaskId').value;
    if (!taskId) {
        showToast('error', '❌ Không xác định được ID công việc cha!');
        return;
    }
    
    const formData = new FormData(this);
    
    // Đảm bảo các tham số cần thiết được gửi đúng
    formData.set('task_id', taskId);  // ✅ Sửa: dùng task_id thay vì cong_viec_id
    formData.set('action', 'add');    // ✅ Thêm: action=add để servlet biết đây là thêm mới
    
    // Log để debug
    console.log('Submitting process step with data:');
    for (let pair of formData.entries()) {
        console.log(pair[0] + ': ' + pair[1]);
    }
    
    fetch('./xoaQuytrinh', {  // ✅ Sửa: gửi đến xoaQuytrinh servlet thay vì apiTaskSteps
        method: 'POST',
        body: formData
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            showToast('success', '✅ Thêm công việc con thành công!');
            bootstrap.Modal.getInstance(document.getElementById('modalAddProcessStep')).hide();
            setTimeout(() => location.reload(), 1500);
        } else {
            showToast('error', data.message || '❌ Lỗi khi thêm công việc con');
        }
    })
    .catch(err => {
        console.error(err);
        showToast('error', '❌ Lỗi kết nối server');
    });
});

// ========== FILE DISPLAY ==========

// Hiển thị danh sách file khi chọn
document.getElementById('taskFiles').addEventListener('change', function () {
    let files = this.files;
    let list = "";
    for (let i = 0; i < files.length; i++) {
        list += "📄 " + files[i].name + "<br>";
    }
    document.getElementById('taskFileList').innerHTML = list || "Chưa có file nào được chọn";
});

// ========== INITIALIZATION ==========

document.addEventListener("DOMContentLoaded", function () {
    // Không dùng CKEditor nữa, chỉ dùng textarea bình thường
    
    // Load danh sách phòng ban
    fetch('./apiPhongban')
        .then(res => res.text())
        .then(html => {
            const defaultOption = '<option value="" selected>Chọn phòng ban</option>';
            const finalHTML = defaultOption + html;
            document.querySelector('#taskForm select[name="ten_phong_ban"]').innerHTML = finalHTML;
        })
        .catch(err => console.error('Lỗi load phòng ban:', err));
    
    // Load danh sách nhân viên cho người giao
    fetch('./apiNhanvien')
        .then(res => res.text())
        .then(html => {
            document.querySelector('#taskForm select[name="ten_nguoi_giao"]').innerHTML = html;
        })
        .catch(err => console.error('Lỗi load nhân viên:', err));
    
    // Load danh sách nhân viên cho checkbox (người nhận)
    fetch('./apiNhanvien')
        .then(function (res) {
            return res.text();
        })
        .then(function (html) {
            var container = document.getElementById("listNguoiNhanCheckbox");
            container.innerHTML = "";
            
            // Tạo thẻ div để parse chuỗi option thành DOM
            var temp = document.createElement("div");
            temp.innerHTML = "<select>" + html + "</select>";
            var options = temp.querySelectorAll("option");
            
            for (var i = 0; i < options.length; i++) {
                var opt = options[i];
                if (!opt.value) continue;
                
                var col = document.createElement("div");
                col.className = "col-md-4";
                col.innerHTML =
                    '<div class="form-check">' +
                    '<input class="form-check-input nguoiNhanItem" type="checkbox" value="' + opt.value + '" data-name="' + opt.text + '" id="nv_' + opt.value + '">' +
                    '<label class="form-check-label" for="nv_' + opt.value + '">' + opt.text + '</label>' +
                    '</div>';
                container.appendChild(col);
            }
        })
        .catch(err => console.error('Lỗi load người nhận:', err));
});
