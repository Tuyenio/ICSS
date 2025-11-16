
// ====== BIẾN GLOBAL THEO DÕI TAB HIỆN TẠI ======
var currentTabState = 'active'; // 'active', 'archived', 'deleted'

// Hàm helper để lấy trạng thái tab hiện tại
function getCurrentTabState() {
    return currentTabState;
}

// Hàm helper để debug trạng thái tab
function debugTabState() {
    console.log('Tab hiện tại:', currentTabState);
    console.log('Tab name mapping:');
    console.log('- active: Công việc');
    console.log('- archived: Lưu trữ');
    console.log('- deleted: Thùng rác');
}

// Hiển thị danh sách file ngay khi chọn
document.getElementById('taskFiles').addEventListener('change', function () {
    let files = this.files;
    let list = "";
    for (let i = 0; i < files.length; i++) {
        list += "📄 " + files[i].name + "<br>";
    }
    document.getElementById('taskFileList').innerHTML = list || "Chưa có file nào được chọn";
});
document.getElementById('taskFiles2').addEventListener('change', function () {
    let files = this.files;
    let list = "";
    for (let i = 0; i < files.length; i++) {
        list += "📄 " + files[i].name + "<br>";
    }
    document.getElementById('taskFileList2').innerHTML = list || "Chưa có file nào được chọn";
});



// ====== LƯU CÔNG VIỆC (SỬA) ======
document.getElementById('btnSaveTask').addEventListener('click', function () {
    const form = document.getElementById('formTaskDetail');
    const formData = new FormData(form); // tự động lấy tất cả input, bao gồm cả file

    fetch('./suaCongviec', {
        method: 'POST',
        body: formData
    })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    showToast('success', '✅ Cập nhật công việc thành công!');
                    // Ẩn modal và làm mới danh sách (tuỳ theo bạn xử lý)
                    bootstrap.Modal.getInstance(document.getElementById('modalTaskDetail')).hide();
                    localStorage.setItem('lastTab', document.querySelector('.nav-link.active').id);
                    localStorage.setItem('lastView', currentView);
                    location.reload();
                } else {
                    showToast('error', data.message || '❌ Lỗi khi cập nhật');
                }
            })
            .catch(err => {
                console.error(err);
                showToast('error', '❌ Lỗi kết nối server');
            });
});

document.addEventListener("DOMContentLoaded", function () {
    var buttonsThemNguoiNhan = document.querySelectorAll("#btnThemNguoiNhan2");
    buttonsThemNguoiNhan.forEach(function (btnThem) {
        btnThem.addEventListener("click", function () {
            var container = btnThem.closest(".mb-3"); // nhóm đang thao tác
            var selectNguoiNhan = container.querySelector("select");
            var danhSachDiv = container.querySelector("#danhSachNguoiNhan2");
            var hiddenInput = container.parentElement.querySelector("#nguoiNhanHidden2");

            if (!selectNguoiNhan || !danhSachDiv || !hiddenInput)
                return;

            var selectedOption = selectNguoiNhan.options[selectNguoiNhan.selectedIndex];
            if (!selectedOption || !selectedOption.value)
                return;

            var ten = selectedOption.text.trim();
            var existing = danhSachDiv.querySelectorAll("span");
            for (var i = 0; i < existing.length; i++) {
                if (existing[i].dataset.ten === ten) {
                    showToast('info', 'Người này đã được thêm.');
                    return;
                }
            }

            var tag = document.createElement("span");
            tag.className = "badge bg-primary d-flex align-items-center me-2";
            tag.style.padding = "0.5em 0.75em";
            tag.dataset.ten = ten;
            tag.innerHTML = ten +
                    '<button type="button" class="btn btn-sm btn-close ms-2" aria-label="Xoá"></button>';
            tag.querySelector(".btn-close").addEventListener("click", function () {
                tag.remove();
                capNhatHiddenInput(danhSachDiv, hiddenInput);
            });
            danhSachDiv.appendChild(tag);

            capNhatHiddenInput(danhSachDiv, hiddenInput);
        });
    });

    function capNhatHiddenInput(danhSachDiv, hiddenInput) {
        var values = [];
        var badges = danhSachDiv.querySelectorAll("span");
        for (var i = 0; i < badges.length; i++) {
            values.push(badges[i].dataset.ten);
        }
        hiddenInput.value = values.join(",");
    }
});



document.addEventListener("DOMContentLoaded", function () {
    var buttonsThemNguoiNhan = document.querySelectorAll("#btnThemNguoiNhan");
    buttonsThemNguoiNhan.forEach(function (btnThem) {
        btnThem.addEventListener("click", function () {
            var container = btnThem.closest(".mb-3"); // nhóm đang thao tác
            var selectNguoiNhan = container.querySelector("select");
            var danhSachDiv = container.querySelector("#danhSachNguoiNhan");
            var hiddenInput = container.parentElement.querySelector("#nguoiNhanHidden");

            if (!selectNguoiNhan || !danhSachDiv || !hiddenInput)
                return;

            var selectedOption = selectNguoiNhan.options[selectNguoiNhan.selectedIndex];
            if (!selectedOption || !selectedOption.value)
                return;

            var ten = selectedOption.text.trim();
            var existing = danhSachDiv.querySelectorAll("span");
            for (var i = 0; i < existing.length; i++) {
                if (existing[i].dataset.ten === ten) {
                    showToast('info', 'Người này đã được thêm.');
                    return;
                }
            }

            var tag = document.createElement("span");
            tag.className = "badge bg-primary d-flex align-items-center me-2";
            tag.style.padding = "0.5em 0.75em";
            tag.dataset.ten = ten;
            tag.innerHTML = ten +
                    '<button type="button" class="btn btn-sm btn-close ms-2" aria-label="Xoá"></button>';
            tag.querySelector(".btn-close").addEventListener("click", function () {
                tag.remove();
                capNhatHiddenInput(danhSachDiv, hiddenInput);
            });
            danhSachDiv.appendChild(tag);

            capNhatHiddenInput(danhSachDiv, hiddenInput);
        });
    });

    function capNhatHiddenInput(danhSachDiv, hiddenInput) {
        var values = [];
        var badges = danhSachDiv.querySelectorAll("span");
        for (var i = 0; i < badges.length; i++) {
            values.push(badges[i].dataset.ten);
        }
        hiddenInput.value = values.join(",");
    }
});



// Hàm chọn option theo text
function selectOptionByText(selectEl, targetText) {
    if (!selectEl || !targetText)
        return;
    const normalizedTarget = targetText.trim().toLowerCase();
    const options = selectEl.options;
    for (let i = 0; i < options.length; i++) {
        if (options[i].text.trim().toLowerCase() === normalizedTarget) {
            selectEl.selectedIndex = i;
            return;
        }
    }
    selectEl.selectedIndex = -1; // Không tìm thấy
}

document.addEventListener("DOMContentLoaded", function () {
    // Load nhóm công việc
    fetch('./apiPhongban')
            .then(res => res.text())
            .then(html => {
                const defaultOption = '<option value="" selected>Tất cả phòng ban</option>';
                const finalHTML = defaultOption + html;
                document.querySelector('#modalTaskDetail select[name="ten_phong_ban"]').innerHTML = finalHTML;
                document.querySelector('#taskForm select[name="ten_phong_ban"]').innerHTML = finalHTML;
                document.querySelector('#phongban select[name="ten_phong_ban"]').innerHTML = finalHTML;
            });
    // Load danh sách nhân viên (giao & nhận)
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
                    if (!opt.value)
                        continue;
                    var col = document.createElement("div");
                    col.className = "col-md-4";
                    col.innerHTML =
                            '<div class="form-check">' +
                            '<input class="form-check-input nguoiNhanItem" type="checkbox" value="' + opt.text + '" id="nv_' + opt.value + '">' +
                            '<label class="form-check-label" for="nv_' + opt.value + '">' + opt.text + '</label>' +
                            '</div>';
                    container.appendChild(col);
                }
            });
    fetch('./apiNhanvien')
            .then(res => res.text())
            .then(html => {
                document.querySelector('#modalTaskDetail select[name="ten_nguoi_giao"]').innerHTML = html;
                //document.querySelector('#modalTaskDetail select[name="ten_nguoi_nhan"]').innerHTML = html;
                document.querySelector('#taskForm select[name="ten_nguoi_giao"]').innerHTML = html;
                //document.querySelector('#taskForm select[name="ten_nguoi_nhan"]').innerHTML = html;
            });
});
document.addEventListener("DOMContentLoaded", function () {
    const modal = document.getElementById("modalTaskDetail");
    modal.addEventListener("show.bs.modal", function (event) {
        const button = event.relatedTarget;
        if (!button)
            return;

        // Lấy dữ liệu từ nút
        const id = button.getAttribute("data-id") || "";
        const tenCV = button.getAttribute("data-ten") || "";
        const moTa = button.getAttribute("data-mo-ta") || "";
        const ngay_bat_dau = button.getAttribute("data-ngay-bat-dau") || "";
        const hanHT = button.getAttribute("data-han") || "";
        const uuTien = button.getAttribute("data-uu-tien") || "";
        const nguoiGiao = button.getAttribute("data-ten_nguoi_giao") || "";
        const nguoiNhan = button.getAttribute("data-ten_nguoi_nhan") || ""; // nhiều tên, ngăn cách dấu phẩy
        const phongban = button.getAttribute("data-ten_phong_ban") || "";
        const trangthai = button.getAttribute("data-trang-thai") || "";
        const tailieu = button.getAttribute("data-tai_lieu_cv") || "";
        const trangthaiduyet = button.getAttribute("data-trang-thai-duyet") || "";
        const ngayGiaHan = button.getAttribute("data-ngay-gia-han") || "";
        const giaHanInfo = modal.querySelector("#giaHanInfo");

        if (giaHanInfo) {
            if (ngayGiaHan && ngayGiaHan.trim() !== "" && ngayGiaHan.toLowerCase() !== "null") {
                const formattedDate = new Date(ngayGiaHan).toLocaleDateString("vi-VN");
                giaHanInfo.textContent = "Gia hạn đến " + formattedDate;
            } else {
                giaHanInfo.textContent = ""; // ẩn nếu không có ngày gia hạn
            }
        }

        // Gán dữ liệu cơ bản
        modal.querySelector('[name="task_id"]').value = id;
        modal.querySelector('[name="ten_cong_viec"]').value = tenCV;
        modal.querySelector('[name="mo_ta"]').value = moTa;
        modal.querySelector('[name="ngay_bat_dau"]').value = ngay_bat_dau;
        modal.querySelector('[name="han_hoan_thanh"]').value = hanHT;
        modal.querySelector('[name="trang_thai_duyet"]').value = trangthaiduyet;
        modal.querySelector('[name="muc_do_uu_tien"]').value = uuTien;
        modal.querySelector('[name="ten_nguoi_giao"]').value = nguoiGiao;
        modal.querySelector('[name="ten_phong_ban"]').value = phongban;
        modal.querySelector('[name="trang_thai"]').value = trangthai;
        modal.querySelector('[name="tai_lieu_cv"]').value = tailieu;

        // === Hiển thị / ẩn phần gia hạn công việc ===
        const extensionSection = document.getElementById('extensionSection');
        const giaHanForm = document.getElementById('giaHanForm');
        const btnGiaHan = document.getElementById('btnGiaHan');

        if (extensionSection && btnGiaHan) {
            if (trangthai.toLowerCase().includes('trễ hạn')) {
                // 👉 Nếu là công việc trễ hạn → hiển thị phần gia hạn
                extensionSection.style.display = 'block';
                giaHanForm.style.display = 'none'; // ẩn form con
                btnGiaHan.innerHTML = '<i class="fa-solid fa-clock"></i> Gia hạn công việc';
                btnGiaHan.classList.remove('btn-secondary');
                btnGiaHan.classList.add('btn-warning');
            } else {
                // 👉 Nếu không phải trễ hạn → ẩn hoàn toàn
                extensionSection.style.display = 'none';
                giaHanForm.style.display = 'none';
            }
        }

        let fileTaiLieu = button.getAttribute("data-file_tai_lieu") || "";
        if (fileTaiLieu.toLowerCase() === "null") {
            fileTaiLieu = "";
        }

        const fileListDiv = modal.querySelector("#taskFileList2");
        if (!fileTaiLieu && taskFiles2.files.length === 0) {
            fileListDiv.innerHTML = "Chưa có file nào được đính kèm";
        }

        if (fileTaiLieu) {
            const files = fileTaiLieu.split(";").map(x => x.trim()).filter(Boolean);
            const taskId = modal.querySelector('[name="task_id"]').value;

            files.forEach(path => {
                const tenFile = path.substring(path.lastIndexOf("/") + 1).split("\\").pop();

                const fileItem = document.createElement("div");
                fileItem.className = "d-flex align-items-center mb-1";

                const link = document.createElement("a");
                link.href = "downloadFile?file=" + encodeURIComponent(tenFile);
                link.className = "flex-grow-1 text-decoration-none";
                link.innerHTML = "📄 " + tenFile + " <i class='fa-solid fa-download'></i>";

                const delBtn = document.createElement("button");
                delBtn.className = "btn btn-sm btn-outline-danger ms-2";
                delBtn.innerHTML = "<i class='fa-solid fa-times'></i>";

                // 👉 KHÔNG cần confirm, gửi luôn full path
                delBtn.addEventListener("click", function () {
                    fetch("deleteFile", {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/x-www-form-urlencoded"
                        },
                        body: "file=" + encodeURIComponent(path) + "&taskId=" + encodeURIComponent(taskId)
                    })
                            .then(res => res.json())
                            .then(data => {
                                if (data.success) {
                                    fileItem.remove();

                                    if (fileListDiv.children.length === 0) {
                                        fileListDiv.innerHTML = "Chưa có file nào được đính kèm";
                                    }

                                    showToast('success', '🗑️ File đã được xoá');
                                } else {
                                    showToast('error', "❌ Lỗi xoá file: " + (data.message || "Không rõ nguyên nhân"));
                                }
                            })
                            .catch(err => {
                                console.error(err);
                                showToast('error', '❌ Lỗi kết nối server.');
                            });
                });

                fileItem.appendChild(link);
                fileItem.appendChild(delBtn);
                fileListDiv.appendChild(fileItem);
            });
        } else {
            fileListDiv.innerHTML = "Chưa có file nào được đính kèm";
        }


        // --- Xử lý nhiều người nhận ---
        const danhSachDiv = modal.querySelector("#danhSachNguoiNhan");
        const hiddenInput = modal.querySelector("#nguoiNhanHidden");
        danhSachDiv.innerHTML = "";
        hiddenInput.value = "";

        const tenArray = nguoiNhan.split(",").map(x => x.trim()).filter(Boolean);
        function capNhatHiddenInput() {
            const tags = danhSachDiv.querySelectorAll("span[data-ten]");
            const values = [];
            tags.forEach(tag => values.push(tag.getAttribute("data-ten")));
            hiddenInput.value = values.join(",");
        }

        tenArray.forEach(function (ten) {
            const tag = document.createElement("span");
            tag.className = "badge bg-primary d-flex align-items-center me-2";
            tag.style.padding = "0.5em 0.75em";
            tag.setAttribute("data-ten", ten);

            // Tạo phần text
            const tenNode = document.createElement("span");
            tenNode.textContent = ten;

            // Gắn phần text và nút xoá vào thẻ
            tag.appendChild(tenNode);

            // Thêm tag vào danh sách
            danhSachDiv.appendChild(tag);
        });

        capNhatHiddenInput();

        // Mở lại tab đầu tiên khi show modal
        const tabTrigger = modal.querySelector('#tab-task-info');
        if (tabTrigger)
            new bootstrap.Tab(tabTrigger).show();
    });
});



var currentTarget = null;

// Tick lại checkbox theo hidden input hiện tại
function syncNguoiNhanCheckboxes(hiddenId) {
    var hidden = document.getElementById(hiddenId);
    var selected = (hidden.value || "").split(",").map(function (s) {
        return s.trim();
    }).filter(function (s) {
        return s.length > 0;
    });

    var boxes = document.querySelectorAll(".nguoiNhanItem");
    for (var i = 0; i < boxes.length; i++) {
        boxes[i].checked = selected.indexOf(boxes[i].value) !== -1;
    }
}

function capNhatHiddenInput(danhSachDiv, hiddenInput) {
    var badges = danhSachDiv.querySelectorAll("span[data-ten]");
    var arr = [];
    for (var i = 0; i < badges.length; i++) {
        arr.push(badges[i].getAttribute("data-ten"));
    }
    hiddenInput.value = arr.join(",");
}



$('#taskForm').on('submit', function (e) {
    e.preventDefault(); // Ngăn form submit mặc định

    const taskId = $('#taskId').val(); // nếu có ID thì là sửa, không thì là thêm
    const formData = new FormData(this); // lấy dữ liệu form bao gồm cả file
    const url = taskId ? './suaCongviec' : './themCongviec';

    $.ajax({
        url: url,
        type: 'POST',
        data: formData,
        processData: false, // cần để gửi FormData
        contentType: false, // cần để gửi FormData
        success: function (response) {
            if (response.success) {
                $('#modalTask').modal('hide');
                showToast('success', taskId ? 'Cập nhật thành công' : 'Thêm mới thành công');
                localStorage.setItem('lastTab', document.querySelector('.nav-link.active').id);
                localStorage.setItem('lastView', currentView);
                location.reload();
            } else {
                showToast('error', response.message || (taskId ? 'Cập nhật thất bại' : 'Thêm mới thất bại'));
            }
        },
        error: function () {
            showToast('error', taskId ? 'Cập nhật thất bại' : 'Thêm mới thất bại');
        }
    });
});


// ====== LỌC CÔNG VIỆC ======
$('#btnFilter').on('click', function (e) {
    e.preventDefault();

    var $btn = $(this);
    var keyword = $('input[name="keyword"]').val() || '';
    var phongBan = $('select[name="ten_phong_ban"]').val() || '';
    var trangThai = $('select[name="trangThai"]').val() || '';
    var projectId = $('input[name="du_an_id"]').val() || '';

    // Debug: hiển thị trạng thái tab hiện tại
    console.log('Lọc với tabState:', currentTabState);

    $.ajax({
        url: './locCongviec',
        type: 'POST',
        data: {
            keyword: keyword,
            phong_ban: phongBan,
            trang_thai: trangThai,
            projectId: PROJECT_ID,
            tabState: currentTabState, // Thêm biến tab hiện tại
            returnJson: (currentView === 'list' || currentView === 'calendar') ? 'true' : 'false'
        },
        dataType: (currentView === 'list' || currentView === 'calendar') ? 'json' : 'html',
        beforeSend: function () {
            $btn.prop('disabled', true).data('orig-text', $btn.html()).html('<i class="fa fa-spinner fa-spin"></i> Đang lọc...');
        },
        success: function (response) {
            if (currentView === 'kanban') {
                // Kanban view - nhận HTML và update đúng container theo tab
                if (response && $.trim(response).length > 0) {
                    if (currentTabState === 'active') {
                        $('#active-tasks .kanban-board').replaceWith(response);
                    } else if (currentTabState === 'archived') {
                        $('#archived-tasks .kanban-board').replaceWith(response);
                    } else if (currentTabState === 'deleted') {
                        $('#deleted-tasks .kanban-board').replaceWith(response);
                    }
                    showToast('success', 'Đã áp dụng bộ lọc.');
                } else {
                    var emptyMsg = '<div class="text-center text-muted p-3">Không có dữ liệu phù hợp</div>';
                    if (currentTabState === 'active') {
                        $('#active-tasks .kanban-board').html(emptyMsg);
                    } else if (currentTabState === 'archived') {
                        $('#archived-tasks .kanban-board').html(emptyMsg);
                    } else if (currentTabState === 'deleted') {
                        $('#deleted-tasks .kanban-board').html(emptyMsg);
                    }
                    showToast('info', 'Không tìm thấy kết quả phù hợp.');
                }
            } else if (currentView === 'list') {
                // List view - nhận JSON và render
                renderListViewFromJson(response);
                showToast('success', 'Đã áp dụng bộ lọc cho danh sách.');
            } else if (currentView === 'calendar') {
                // Calendar view - nhận JSON và render
                renderCalendarViewFromJson(response);
                showToast('success', 'Đã áp dụng bộ lọc cho lịch.');
            }

            // Show clear filter button with premium animation
            var $clearBtn = $('#btnClearFilter');
            if ($clearBtn.length && !$clearBtn.hasClass('show')) {
                $clearBtn.removeClass('hide').addClass('show').css('display', 'flex');
            }
        },
        error: function () {
            if (currentView === 'kanban') {
                $('.kanban-board').html('<div class="text-danger text-center p-3">Lỗi khi lọc công việc</div>');
            }
            showToast('error', 'Lỗi khi lọc công việc.');
        },
        complete: function () {
            $btn.prop('disabled', false).html($btn.data('orig-text') || '<i class="fa-solid fa-filter"></i> Lọc');
        }
    });
});

// ====== CLEAR FILTER BUTTON HANDLER ======
$('#btnClearFilter').on('click', function (e) {
    e.preventDefault();

    var $clearBtn = $(this);

    // Add loading animation
    $clearBtn.addClass('filtering').html('<i class="fa fa-spinner fa-spin"></i>');

    // Show toast notification
    showToast('info', 'Đang hủy bộ lọc...');

    // Reload page to return to initial state (this preserves all tabs and data)
    setTimeout(function () {
        window.location.reload();
    }, 500);
});

// ====== RENDER LIST VIEW TỪ JSON ======
function renderListViewFromJson(tasks) {
    var tbody = $('#taskListTableBody');
    tbody.empty();

    if (!tasks || tasks.length === 0) {
        tbody.html('<tr><td colspan="10" class="text-center text-muted py-4">Không tìm thấy công việc phù hợp</td></tr>');
        return;
    }

    tasks.forEach(function (task) {
        var priorityClass =
                (task.muc_do_uu_tien === 'Cao') ? 'priority-high' :
                (task.muc_do_uu_tien === 'Trung bình') ? 'priority-medium' : 'priority-low';

        var statusClass =
                (task.trang_thai === 'Đang thực hiện') ? 'status-in-progress' :
                (task.trang_thai === 'Đã hoàn thành') ? 'status-completed' :
                (task.trang_thai === 'Trễ hạn') ? 'status-late' : 'status-not-started';

        var hasReminder = (task.nhac_viec == 1);
        var alertClass = hasReminder ? 'task-row--alert' : '';

        var row = ''
                + '<tr class="task-row ' + alertClass + '" data-bs-toggle="modal" data-bs-target="#modalTaskDetail"'
                + ' data-id="' + (task.id || '') + '"'
                + ' data-ten="' + (task.ten_cong_viec || '') + '"'
                + ' data-mo-ta="' + (task.mo_ta || '') + '"'
                + ' data-ngay-bat-dau="' + (task.ngay_bat_dau || '') + '"'
                + ' data-han="' + (task.han_hoan_thanh || '') + '"'
                + ' data-uu-tien="' + (task.muc_do_uu_tien || '') + '"'
                // 🔹 Dùng tên đầy đủ thay vì ID
                + ' data-ten_nguoi_giao="' + (task.ten_nguoi_giao || task.nguoi_giao_id || '') + '"'
                + ' data-ten_nguoi_nhan="' + (task.ten_nguoi_nhan || task.nguoi_nhan_ten || '') + '"'
                + ' data-ten_phong_ban="' + (task.ten_phong_ban || task.phong_ban_id || '') + '"'
                + ' data-trang-thai="' + (task.trang_thai || '') + '"'
                + ' data-tai_lieu_cv="' + (task.tai_lieu_cv || '') + '"'
                + ' data-file_tai_lieu="' + (task.file_tai_lieu || '') + '"'
                + ' data-trang-thai-duyet="' + (task.trang_thai_duyet || 'Chưa duyệt') + '"'
                + ' data-ly-do-duyet="' + (task.ly_do_duyet || '') + '"'
                + ' data-ngay-gia-han="' + (task.ngay_gia_han || '') + '"'
                + '>'
                + '    <td class="task-name">' + (task.ten_cong_viec || '') + '</td>'
                + '    <td>' + (task.ten_nguoi_giao || task.nguoi_giao_id || '') + '</td>'
                + '    <td>' + (task.ten_nguoi_nhan || task.nguoi_nhan_ten || '') + '</td>'
                + '    <td>' + (task.ten_phong_ban || task.phong_ban_id || '') + '</td>'
                + '    <td>' + (task.ngay_bat_dau || '') + '</td>'
                + '    <td>' + (task.han_hoan_thanh || '') + '</td>'
                + '    <td><span class="badge ' + priorityClass + '">' + (task.muc_do_uu_tien || '') + '</span></td>'
                + '    <td><span class="badge ' + statusClass + '">' + (task.trang_thai || '') + '</span></td>'
                + '    <td><span class="badge ' + getApprovalBadge(task.trang_thai_duyet) + '">' + (task.trang_thai_duyet || 'Chưa duyệt') + '</span></td>'
                + '    <td>'
                + '        <div class="action-btns">'
                + '            <button class="btn btn-sm btn-warning" title="Lưu trữ" onclick="event.stopPropagation(); archiveTask(\'' + task.id + '\')">'
                + '                <i class="fa-solid fa-archive"></i>'
                + '            </button>'
                + '        </div>'
                + '    </td>'
                + '</tr>';

        tbody.append(row);
    });
}

// ====== RENDER CALENDAR VIEW TỪ JSON ======
function renderCalendarViewFromJson(tasks) {
    if (!calendar) {
        initCalendar();
    }

    // Xóa tất cả events hiện tại
    calendar.removeAllEvents();

    if (!tasks || tasks.length === 0) {
        showToast('info', 'Không tìm thấy công việc phù hợp');
        return;
    }

    // Thêm events mới từ kết quả lọc
    tasks.forEach(function (task) {
        const eventClass =
                task.trang_thai === 'Đang thực hiện' ? 'event-in-progress' :
                task.trang_thai === 'Đã hoàn thành' ? 'event-completed' :
                task.trang_thai === 'Trễ hạn' ? 'event-late' :
                'event-not-started';

        calendar.addEvent({
            id: task.id,
            title: task.ten_cong_viec || '',
            start: task.ngay_bat_dau,
            end: task.han_hoan_thanh,
            className: eventClass,
            extendedProps: {
                nguoiGiao: task.ten_nguoi_giao || task.nguoi_giao_ten || task.nguoi_giao_id || '',
                nguoiNhan: task.ten_nguoi_nhan || task.nguoi_nhan_ten || task.nguoi_nhan || '',
                phongBan: task.ten_phong_ban || task.phong_ban_ten || task.phong_ban_id || '',
                uuTien: task.muc_do_uu_tien || '',
                trangThai: task.trang_thai || '',
                trangThaiDuyet: task.trang_thai_duyet || '',
                lyDoDuyet: task.ly_do_duyet || '',
                moTa: task.mo_ta || '',
                taiLieu: task.tai_lieu_cv || '',
                fileTaiLieu: task.file_tai_lieu || '',
                ngayGiaHan: task.ngay_gia_han || ''
            }
        });
    });
}

// ====== HÀM TOAST DÙNG CHUNG ======
function showToast(type, message) {
    var map = {
        success: '#toastSuccess',
        error: '#toastError',
        info: '#toastInfo',
        warning: '#toastWarning'
    };
    var toastId = map[type] || '#toastInfo';

    if ($(toastId).length === 0) {
        var toastHtml =
                '<div id="' + toastId.substring(1) + '" class="toast align-items-center border-0 position-fixed bottom-0 end-0 m-3" role="alert" aria-live="assertive" aria-atomic="true">' +
                '<div class="d-flex">' +
                '<div class="toast-body"></div>' +
                '<button type="button" class="btn-close me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>' +
                '</div>' +
                '</div>';
        $('body').append(toastHtml);
    }

    $(toastId).find('.toast-body').text(message);
    var bsToast = new bootstrap.Toast($(toastId)[0], {delay: 2500, autohide: true});
    bsToast.show();
}


// Danh sách các bước quy trình (demo, nên dùng AJAX thực tế)
var processSteps = [
    {
        id: "12",
        name: "Thiết kế UI",
        desc: "Thiết kế giao diện người dùng",
        status: "Hoàn thành",
        start: "2024-06-01",
        end: "2024-06-03"
    }
];

function calcProgressPercent(list) {
    var steps = list || processSteps;
    if (!steps || steps.length === 0)
        return 0;
    var done = steps.filter(function (s) {
        return s.status === "Đã hoàn thành";
    }).length;
    return Math.round((done / steps.length) * 100);
}

// Hiển thị các bước quy trình với nút chỉnh sửa trạng thái (logic đẹp mắt, chỉ 1 nút)
function renderProcessSteps() {
    var percent = calcProgressPercent();
    var barClass = percent === 100 ? "bg-success" : "bg-warning";
    $('#taskProgressBar')
            .css('width', percent + '%')
            .removeClass('bg-warning bg-success')
            .addClass(barClass)
            .text(percent + '%');

    // 👇 Gửi phần trăm về server
    var taskId = $('#taskId').val();
    if (taskId) {
        $.ajax({
            url: 'capnhatTiendo',
            method: 'POST',
            data: {cong_viec_id: taskId, phan_tram: percent},
            success: function () {
                showToast('success', 'Cập nhật tiến độ thành công');
            },
            error: function () {
                showToast('error', 'Lỗi khi cập nhật tiến độ');
            }
        });
    }

    var list = $('#processStepList');
    list.empty();
    if (processSteps.length === 0) {
        list.append('<li class="list-group-item text-muted">Chưa có bước quy trình nào.</li>');
    } else {
        processSteps.forEach(function (step, idx) {
            var badgeClass = "bg-secondary";
            if (step.status === "Đã hoàn thành")
                badgeClass = "bg-success";
            else if (step.status === "Đang thực hiện")
                badgeClass = "bg-warning text-dark";
            else if (step.status === "Trễ hạn")
                badgeClass = "bg-danger";

            var editBtn =
                    '<button class="btn btn-sm btn-outline-secondary me-1" onclick="showEditStepModal(' + idx + ')">' +
                    '<i class="fa-solid fa-pen"></i> Chỉnh sửa</button>';

            var html = '<li class="list-group-item d-flex justify-content-between align-items-center">' +
                    '<div>' +
                    '<b>' + step.name + '</b> ' +
                    '<span class="badge ' + badgeClass + '">' + step.status + '</span><br>' +
                    '<small>' + (step.desc ? step.desc : '') + '</small>' +
                    '<div class="text-muted small">Từ ' + (step.start || '-') + ' đến ' + (step.end || '-') + '</div>' +
                    '</div>' +
                    '<div>' + editBtn + '</div>' +
                    '</li>';
            list.append(html);
        });
    }
}

function renderTaskReviews(data) {
    var list = document.getElementById("taskReviewList");
    list.innerHTML = "";
    data.forEach(function (item) {
        var li = document.createElement("li");
        var html = "<b>Người đánh giá:</b> " + item.ten_nguoi_danh_gia + "<br>" +
                "<b>Nhận xét:</b> " + item.nhan_xet + "<br>" +
                "<i class='text-muted'>" + item.thoi_gian + "</i>";
        li.innerHTML = html;
        li.classList.add("mb-2", "border", "p-2", "rounded");
        list.appendChild(li);
    });
}

function showEditStepModal(idx) {
    var step = processSteps[idx];
    var modalHtml =
            '<div class="modal fade" id="modalEditStepStatus" tabindex="-1">' +
            '<div class="modal-dialog">' +
            '<form class="modal-content" id="formEditStepStatus">' +
            '<input type="hidden" name="stepid" value="' + step.id + '">' +
            '<div class="modal-header">' +
            '<h5 class="modal-title"><i class="fa-solid fa-pen"></i> Chỉnh sửa bước quy trình</h5>' +
            '<button type="button" class="btn-close" data-bs-dismiss="modal"></button>' +
            '</div>' +
            '<div class="modal-body">' +
            '<div class="mb-2">' +
            '<label class="form-label">Tên bước/giai đoạn</label>' +
            '<input type="text" class="form-control" name="stepName" value="' + step.name + '" required readonly>' +
            '</div>' +
            '<div class="mb-2">' +
            '<label class="form-label">Mô tả</label>' +
            '<textarea class="form-control" name="stepDesc" rows="2" readonly>' + (step.desc || '') + '</textarea>' +
            '</div>' +
            '<div class="mb-2">' +
            '<label class="form-label">Trạng thái</label>' +
            '<select class="form-select" name="stepStatus">' +
            '<option value="Chưa bắt đầu"' + (step.status === "Chưa bắt đầu" ? " selected" : "") + '>Chưa bắt đầu</option>' +
            '<option value="Đang thực hiện"' + (step.status === "Đang thực hiện" ? " selected" : "") + '>Đang thực hiện</option>' +
            '<option value="Đã hoàn thành"' + (step.status === "Đã hoàn thành" ? " selected" : "") + '>Đã hoàn thành</option>' +
            '</select>' +
            '</div>' +
            '<div class="mb-2 row">' +
            '<div class="col"><label class="form-label">Ngày bắt đầu</label>' +
            '<input type="date" class="form-control" name="stepStart" value="' + (step.start || '') + '" readonly></div>' +
            '<div class="col"><label class="form-label">Ngày kết thúc</label>' +
            '<input type="date" class="form-control" name="stepEnd" value="' + (step.end || '') + '" readonly></div>' +
            '</div>' +
            '</div>' +
            '<div class="modal-footer">' +
            '<button type="submit" class="btn btn-primary rounded-pill">Cập nhật</button>' +
            '<button type="button" class="btn btn-secondary rounded-pill" data-bs-dismiss="modal">Huỷ</button>' +
            '</div>' +
            '</form>' +
            '</div>' +
            '</div>';
    $('#modalEditStepStatus').remove();
    $('body').append(modalHtml);
    var modal = new bootstrap.Modal(document.getElementById('modalEditStepStatus'));
    modal.show();

    $('#formEditStepStatus').on('submit', function (e) {
        e.preventDefault();
        processSteps[idx] = {
            id: $(this).find('[name="stepid"]').val(),
            name: $(this).find('[name="stepName"]').val(),
            desc: $(this).find('[name="stepDesc"]').val(),
            status: $(this).find('[name="stepStatus"]').val(),
            start: $(this).find('[name="stepStart"]').val(),
            end: $(this).find('[name="stepEnd"]').val()
        };
        renderProcessSteps();
        modal.hide();
        $('#modalEditStepStatus').remove();
        var taskId = document.getElementById("taskId").value;
        $.ajax({
            url: './apiTaskSteps',
            method: 'POST',
            data: {
                step_id: processSteps[idx].id,
                name: processSteps[idx].name,
                desc: processSteps[idx].desc,
                status: processSteps[idx].status,
                start: processSteps[idx].start,
                end: processSteps[idx].end
            },
            success: function () {
                showToast('success', 'Cập nhật bước thành công');
            },
            error: function () {
                showToast('error', 'Cập nhật bước thất bại');
            }
        });
    });
    $('#modalEditStepStatus').on('hidden.bs.modal', function () {
        $('#modalEditStepStatus').remove();
    });
}

$('#formAddProcessStep').on('submit', function (e) {
    e.preventDefault();
    var taskId = document.getElementById("taskId").value;
    var step = {
        name: $(this).find('[name="stepName"]').val(),
        desc: $(this).find('[name="stepDesc"]').val(),
        status: $(this).find('[name="stepStatus"]').val(),
        start: $(this).find('[name="stepStart"]').val(),
        end: $(this).find('[name="stepEnd"]').val()
    };
    $.ajax({
        url: './xoaQuytrinh',
        method: 'POST',
        data: {
            action: 'add',
            task_id: taskId,
            name: step.name,
            desc: step.desc,
            status: step.status,
            start: step.start,
            end: step.end
        },
        success: function (newStepId) {
            step.id = newStepId;
            processSteps.push(step);
            renderProcessSteps();
            $('#modalAddProcessStep').modal('hide');
            showToast('success', 'Thêm bước thành công');
        },
        error: function () {
            showToast('error', 'Thêm bước thất bại');
        }
    });
});

$('#modalTaskDetail').off('show.bs.modal').on('show.bs.modal', function (event) {
    var button = event.relatedTarget;
    if (!button)
        return;

    var taskId = button.getAttribute('data-id');
    if (!taskId) {
        taskId = $('#formTaskDetail input[name="task_id"]').val();
    }

    if (!taskId) {
        console.error('❌ Không tìm thấy task_id khi mở modal');
        return;
    }

    // --- Reset danh sách quy trình để tránh hiển thị nhầm công việc trước ---
    $('#processStepList').empty().append('<li class="list-group-item text-muted">Đang tải quy trình...</li>');
    $('#taskProgressBar').css('width', '0%').text('0%');

    // 1️⃣ Gọi API lấy quy trình
    $.ajax({
        url: './apiTaskSteps?task_id=' + taskId,
        method: 'GET',
        dataType: 'json',
        success: function (data) {
            if (!Array.isArray(data)) {
                showToast('error', 'Dữ liệu quy trình không hợp lệ.');
                return;
            }
            processSteps = data;
            renderProcessSteps();
        },
        error: function (xhr, status, err) {
            console.error('Lỗi khi tải quy trình:', err);
            showToast('error', 'Không thể tải quy trình.');
        }
    });

    // 2️⃣ Lịch sử
    loadTaskHistory(taskId);

    // 3️⃣ Đánh giá
    $.ajax({
        url: './apiDanhgiaCV?taskId=' + taskId,
        method: 'GET',
        dataType: 'json',
        success: function (data) {
            renderTaskReviews(data);
        },
        error: function () {
            showToast('error', 'Không thể tải đánh giá.');
        }
    });
});

document.addEventListener("DOMContentLoaded", function () {
    var tabProgress = document.getElementById("tab-task-progress");
    tabProgress.addEventListener("shown.bs.tab", function () {
        var taskId = document.getElementById("taskId").value;
        $.ajax({
            url: './apiTaskSteps?task_id=' + taskId,
            method: 'GET',
            success: function (data) {
                processSteps = data;
                renderProcessSteps();
            },
            error: function () {
                showToast('error', 'Không thể tải quy trình.');
            }
        });
    });

    var tabReview = document.getElementById("tab-task-review");
    if (tabReview) {
        tabReview.addEventListener("shown.bs.tab", function () {
            var taskId = document.getElementById("taskId").value;
            $.ajax({
                url: './apiDanhgiaCV?taskId=' + taskId,
                method: 'GET',
                success: function (data) {
                    renderTaskReviews(data);
                },
                error: function () {
                    showToast('error', 'Không thể tải đánh giá.');
                }
            });
        });
    }
});

function loadTaskReviews(taskId) {
    fetch("./apiDanhgiaCV?taskId=" + encodeURIComponent(taskId))
            .then(function (res) {
                return res.json();
            })
            .then(function (data) {
                renderTaskReviews(data);
            })
            .catch(function () {
                showToast('error', 'Không thể tải lại danh sách đánh giá.');
            });
}

function updateAllTaskProgressBars() {
    document.querySelectorAll('.task-progress-bar').forEach(function (bar) {
        var taskId = bar.getAttribute('data-task-id');
        fetch('./apiTaskSteps?task_id=' + encodeURIComponent(taskId))
                .then(function (res) {
                    return res.json();
                })
                .then(function (steps) {
                    var percent = calcProgressPercent(steps);
                    var barClass = "bg-warning";
                    if (percent === 100)
                        barClass = "bg-success";
                    else if (percent === 0)
                        barClass = "bg-secondary";
                    bar.style.width = percent + "%";
                    bar.textContent = percent + "%";
                    bar.className = "progress-bar task-progress-bar " + barClass;
                })
                .catch(function () {
                    showToast('error', 'Lỗi khi tải bước quy trình');
                });
    });
}
document.addEventListener("DOMContentLoaded", function () {
    updateAllTaskProgressBars();
});



// ====== TAB NAVIGATION ======
document.addEventListener('DOMContentLoaded', function () {
    // Xử lý click tab để load dữ liệu và cập nhật currentTabState
    const activeTab = document.getElementById('active-tasks-tab');
    const archivedTab = document.getElementById('archived-tasks-tab');
    const deletedTab = document.getElementById('deleted-tasks-tab');

    // Tab Công việc (active)
    if (activeTab) {
        activeTab.addEventListener('shown.bs.tab', function () {
            currentTabState = 'active';
            console.log('Đang ở tab: Công việc (active)');
        });
    }

    // Tab Lưu trữ (archived)
    if (archivedTab) {
        archivedTab.addEventListener('shown.bs.tab', function () {
            currentTabState = 'archived';
            console.log('Đang ở tab: Lưu trữ (archived)');
            loadArchivedTasks();
        });
    }

    // Tab Thùng rác (deleted)
    if (deletedTab) {
        deletedTab.addEventListener('shown.bs.tab', function () {
            currentTabState = 'deleted';
            console.log('Đang ở tab: Thùng rác (deleted)');
            loadDeletedTasks();
        });
    }

    // Thêm keyboard navigation cho tabs
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Tab' && e.target.classList.contains('nav-link')) {
            e.target.focus();
        }
    });
});

// ====== LOAD ARCHIVED TASKS ======
function loadArchivedTasks() {
    const container = document.querySelector('.archived-tasks-container');
    container.innerHTML = '<div class="text-center py-3"><i class="fa-solid fa-spinner fa-spin"></i> Đang tải...</div>';

    fetch('./locCongviec', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'tinh_trang=Lưu trữ&view=archived&tabState=archived'
    })
            .then(res => res.text())
            .then(html => {
                if (html.trim()) {
                    renderArchivedTasks(html);
                } else {
                    container.innerHTML = '<div class="text-muted text-center py-4"><i class="fa-solid fa-archive fa-2x mb-2"></i><br>Chưa có công việc nào được lưu trữ</div>';
                }
            })
            .catch(err => {
                console.error(err);
                container.innerHTML = '<div class="text-danger text-center py-3">Lỗi khi tải dữ liệu</div>';
            });
}

// ====== LOAD DELETED TASKS ======
function loadDeletedTasks() {
    const container = document.querySelector('.deleted-tasks-container');
    container.innerHTML = '<div class="text-center py-3"><i class="fa-solid fa-spinner fa-spin"></i> Đang tải...</div>';

    fetch('./locCongviec', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'tinh_trang=Đã xóa&view=deleted&tabState=deleted'
    })
            .then(res => res.text())
            .then(html => {
                if (html.trim()) {
                    renderDeletedTasks(html);
                } else {
                    container.innerHTML = '<div class="text-muted text-center py-4"><i class="fa-solid fa-trash fa-2x mb-2"></i><br>Thùng rác trống</div>';
                }
            })
            .catch(err => {
                console.error(err);
                container.innerHTML = '<div class="text-danger text-center py-3">Lỗi khi tải dữ liệu</div>';
            });
}

// ====== RENDER ARCHIVED TASKS ======
function renderArchivedTasks(html) {
    // Tạm thời tạo HTML mẫu cho archived task
    const container = document.querySelector('.archived-tasks-container');
    container.innerHTML = `
                            <div class="archived-task kanban-task">
                                <div class="task-title">Mẫu công việc đã lưu trữ</div>
                                <div class="task-meta">Người giao: <b>Admin</b><br>Người nhận: <b>User</b></div>
                                <span class="task-priority badge bg-warning text-dark">Trung bình</span>
                                <span class="task-status badge bg-secondary">Lưu trữ</span>
                                <div class="progress">
                                    <div class="progress-bar bg-secondary" style="width: 75%;"></div>
                                </div>
                                <div class="task-actions">
                                    <button class="task-dots-btn" type="button">
                                        <i class="fa-solid fa-ellipsis-vertical"></i>
                                    </button>
                                    <div class="task-actions-dropdown">
                                        <button class="task-action-item restore-action" type="button" data-task-id="1" data-action="restore">
                                            <i class="fa-solid fa-undo"></i>
                                            <span>Khôi phục</span>
                                        </button>
                                        <button class="task-action-item permanent-delete-action" type="button" data-task-id="1" data-action="permanent-delete">
                                            <i class="fa-solid fa-trash-can"></i>
                                            <span>Xóa vĩnh viễn</span>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        `;
}

// ====== RENDER DELETED TASKS ======
function renderDeletedTasks(html) {
    // Tạm thời tạo HTML mẫu cho deleted task  
    const container = document.querySelector('.deleted-tasks-container');
    container.innerHTML = `
                            <div class="deleted-task kanban-task">
                                <div class="task-title">Mẫu công việc đã xóa</div>
                                <div class="task-meta">Người giao: <b>Admin</b><br>Người nhận: <b>User</b></div>
                                <span class="task-priority badge bg-danger">Cao</span>
                                <span class="task-status badge bg-danger">Đã xóa</span>
                                <div class="progress">
                                    <div class="progress-bar bg-danger" style="width: 30%;"></div>
                                </div>
                                <div class="task-actions">
                                    <button class="task-dots-btn" type="button">
                                        <i class="fa-solid fa-ellipsis-vertical"></i>
                                    </button>
                                    <div class="task-actions-dropdown">
                                        <button class="task-action-item restore-action" type="button" data-task-id="2" data-action="restore">
                                            <i class="fa-solid fa-undo"></i>
                                            <span>Khôi phục</span>
                                        </button>
                                        <button class="task-action-item permanent-delete-action" type="button" data-task-id="2" data-action="permanent-delete">
                                            <i class="fa-solid fa-trash-can"></i>
                                            <span>Xóa vĩnh viễn</span>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        `;
}

// ====== TASK ACTIONS - NÚT 3 CHẤM ======
document.addEventListener('DOMContentLoaded', function () {
    // Xử lý click cho các action item
    document.addEventListener('click', function (e) {
        if (e.target.closest('.task-action-item')) {
            const item = e.target.closest('.task-action-item');

            // Lấy từ chính button, fallback từ thẻ .kanban-task gần nhất
            const taskId =
                    item.dataset.taskId ||
                    item.closest('.kanban-task')?.dataset.id;

            if (!taskId) {
                console.error('Không tìm thấy task_id trên phần tử');
                showToast('error', 'Không tìm thấy ID công việc');
                return;
            }

            const action = item.dataset.action;
            e.stopPropagation();
            e.preventDefault();

            switch (action) {
                case 'archive':
                    archiveTask(taskId);
                    break;
                case 'restore':
                    restoreTask(taskId);
                    break;
            }
        }
    });

    // Ngăn dropdown đóng khi click vào
    document.addEventListener('click', function (e) {
        if (e.target.closest('.task-actions-dropdown')) {
            e.stopPropagation();
        }
    });
});

// ====== CÁC HÀM XỬ LÝ ACTION ======
function archiveTask(taskId) {
    Swal.fire({
        title: 'Lưu trữ công việc?',
        text: 'Bạn có chắc chắn muốn lưu trữ công việc này không?',
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#6c757d',
        confirmButtonText: 'Lưu trữ',
        cancelButtonText: 'Hủy'
    }).then((result) => {
        if (result.isConfirmed) {
            showToast('info', '📁 Đang lưu trữ công việc...');

            fetch('./suaCongviec', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: new URLSearchParams({
                    task_id: String(taskId),
                    action: 'archive',
                    tinh_trang: 'Lưu trữ'
                })
            })
                    .then(res => res.json())
                    .then(data => {
                        if (data.success) {
                            Swal.fire('Thành công!', 'Công việc đã được lưu trữ.', 'success');
                            setTimeout(() => {
                                // Ghi nhớ view + tab trước khi reload
                                localStorage.setItem('lastTab', document.querySelector('.nav-link.active').id);
                                localStorage.setItem('lastView', currentView);
                                location.reload();
                            }, 1200);
                        } else {
                            Swal.fire('Lỗi!', data.message || 'Lưu trữ thất bại.', 'error');
                        }
                    })
                    .catch(err => {
                        console.error(err);
                        Swal.fire('Lỗi!', 'Không thể kết nối tới server.', 'error');
                    });
        }
    });
}

// ====== KHÔI PHỤC CÔNG VIỆC ======
function restoreTask(taskId) {
    Swal.fire({
        title: 'Khôi phục công việc?',
        text: 'Bạn có muốn khôi phục công việc này không?',
        icon: 'info',
        showCancelButton: true,
        confirmButtonColor: '#28a745',
        cancelButtonColor: '#6c757d',
        confirmButtonText: 'Khôi phục',
        cancelButtonText: 'Hủy'
    }).then((result) => {
        if (result.isConfirmed) {
            showToast('info', '🔄 Đang khôi phục công việc...');

            fetch('./suaCongviec', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: new URLSearchParams({
                    task_id: String(taskId),
                    action: 'restore',
                    trang_thai: 'Chưa bắt đầu'
                })
            })
                    .then(res => res.json())
                    .then(data => {
                        if (data.success) {
                            Swal.fire('Thành công!', 'Công việc đã được khôi phục.', 'success');
                            setTimeout(() => {
                                // Ghi nhớ view + tab trước khi reload
                                localStorage.setItem('lastTab', document.querySelector('.nav-link.active').id);
                                localStorage.setItem('lastView', currentView);
                                location.reload();
                            }, 1200);
                        } else {
                            Swal.fire('Lỗi!', data.message || 'Khôi phục thất bại.', 'error');
                        }
                    })
                    .catch(err => {
                        console.error(err);
                        Swal.fire('Lỗi!', 'Không thể kết nối tới server.', 'error');
                    });
        }
    });
}

// ====== TAB NAVIGATION ======
document.addEventListener('DOMContentLoaded', function () {
    // Xử lý click tab để load dữ liệu
    const archivedTab = document.getElementById('archived-tasks-tab');
    const deletedTab = document.getElementById('deleted-tasks-tab');

    if (archivedTab) {
        archivedTab.addEventListener('shown.bs.tab', function () {
            loadArchivedTasks();
        });
    }

    if (deletedTab) {
        deletedTab.addEventListener('shown.bs.tab', function () {
            loadDeletedTasks();
        });
    }
});

// ====== LOAD ARCHIVED TASKS ======
function loadArchivedTasks() {
    const container = document.querySelector('.archived-tasks-container');
    const kanbanBoard = container.querySelector('.kanban-board');

    // Hiển thị loading
    kanbanBoard.querySelectorAll('.kanban-col').forEach(col => {
        const placeholder = col.querySelector('.text-center');
        if (placeholder) {
            placeholder.innerHTML = '<i class="fa-solid fa-spinner fa-spin fa-2x mb-2"></i><p>Đang tải...</p>';
        }
    });

    fetch('./locCongviec', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'tinh_trang=Lưu trữ&view=archived&tabState=archived'
    })
            .then(res => res.text())
            .then(html => {
                if (html.trim()) {
                    renderArchivedTasks(html);
                } else {
                    resetArchivedPlaceholders();
                }
            })
            .catch(err => {
                console.error(err);
                kanbanBoard.querySelectorAll('.kanban-col').forEach(col => {
                    const placeholder = col.querySelector('.text-center');
                    if (placeholder) {
                        placeholder.innerHTML = '<i class="fa-solid fa-exclamation-triangle fa-2x mb-2 text-danger"></i><p class="text-danger">Lỗi khi tải dữ liệu</p>';
                    }
                });
            });
}

// ====== LOAD DELETED TASKS ======
function loadDeletedTasks() {
    const container = document.querySelector('.deleted-tasks-container');
    const kanbanBoard = container.querySelector('.kanban-board');

    // Hiển thị loading
    kanbanBoard.querySelectorAll('.kanban-col').forEach(col => {
        const placeholder = col.querySelector('.text-center');
        if (placeholder) {
            placeholder.innerHTML = '<i class="fa-solid fa-spinner fa-spin fa-2x mb-2"></i><p>Đang tải...</p>';
        }
    });

    fetch('./locCongviec', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'tinh_trang=Đã xóa&view=deleted&tabState=deleted'
    })
            .then(res => res.text())
            .then(html => {
                if (html.trim()) {
                    renderDeletedTasks(html);
                } else {
                    resetDeletedPlaceholders();
                }
            })
            .catch(err => {
                console.error(err);
                kanbanBoard.querySelectorAll('.kanban-col').forEach(col => {
                    const placeholder = col.querySelector('.text-center');
                    if (placeholder) {
                        placeholder.innerHTML = '<i class="fa-solid fa-exclamation-triangle fa-2x mb-2 text-danger"></i><p class="text-danger">Lỗi khi tải dữ liệu</p>';
                    }
                });
            });
}

// ====== RENDER ARCHIVED TASKS ======
function renderArchivedTasks(html) {
    // Placeholder cho việc render archived tasks
    resetArchivedPlaceholders();
    showToast('info', 'Đã tải công việc lưu trữ');
}

// ====== RENDER DELETED TASKS ======
function renderDeletedTasks(html) {
    // Placeholder cho việc render deleted tasks
    resetDeletedPlaceholders();
    showToast('info', 'Đã tải thùng rác');
}

// ====== RESET PLACEHOLDERS ======
function resetArchivedPlaceholders() {
    document.querySelectorAll('.archived-col .text-center').forEach(placeholder => {
        placeholder.innerHTML = '<i class="fa-solid fa-inbox fa-2x mb-2"></i><p>Chưa có công việc lưu trữ</p>';
    });
}

function resetDeletedPlaceholders() {
    document.querySelectorAll('.deleted-col .text-center').forEach(placeholder => {
        placeholder.innerHTML = '<i class="fa-solid fa-trash fa-2x mb-2"></i><p>Thùng rác trống</p>';
    });
}


document.addEventListener('click', function (e) {
    const btn = e.target.closest('.task-dots-btn');
    const dropdown = btn?.nextElementSibling;

    // Nếu click vào nút 3 chấm
    if (btn && dropdown) {
        e.stopPropagation();
        e.preventDefault(); // 🔥 ngăn Bootstrap modal trigger
        document.querySelectorAll('.task-actions-dropdown.show').forEach(d => {
            if (d !== dropdown)
                d.classList.remove('show');
        });
        dropdown.classList.toggle('show');
        return;
    }

    // Nếu click ra ngoài thì ẩn tất cả menu
    if (!e.target.closest('.task-actions-dropdown')) {
        document.querySelectorAll('.task-actions-dropdown.show').forEach(d => d.classList.remove('show'));
    }
}, true);

// ====== XỬ LÝ TASK ACTIONS ======
document.addEventListener('click', function (e) {
    const actionBtn = e.target.closest('.task-action-item');
    if (actionBtn) {
        e.preventDefault();
        e.stopPropagation();

        const taskId = actionBtn.dataset.taskId;
        const action = actionBtn.dataset.action;

        // Ẩn dropdown sau khi click
        document.querySelectorAll('.task-actions-dropdown.show').forEach(d => d.classList.remove('show'));

        // Xử lý các actions
        switch (action) {
            case 'restore':
                restoreTask(taskId);
                break;
            case 'archive':
                archiveTask(taskId);
                break;
            default:
                console.log('Unknown action:', action);
        }
    }
});



// ====== XỬ LÝ NHẮC NHỞ CÔNG VIỆC ======
document.addEventListener('DOMContentLoaded', function () {
    // Xử lý khi người dùng click vào task có chuông nhắc nhở
    document.addEventListener('click', function (e) {
        const taskCard = e.target.closest('.kanban-task');
        if (taskCard && taskCard.querySelector('.task-reminder-bell')) {
            const taskId = taskCard.getAttribute('data-task-id');

            // Đánh dấu đã đọc nhắc nhở
            markReminderAsRead(taskId);

            // Ẩn chuông ngay lập tức để UX tốt hơn
            const bell = taskCard.querySelector('.task-reminder-bell');
            if (bell) {
                bell.style.opacity = '0';
                bell.style.transform = 'scale(0)';
                setTimeout(() => {
                    bell.style.display = 'none';
                }, 200);
            }
        }
    });
});

function markReminderAsRead(taskId) {
    fetch('./suaCongviec', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: new URLSearchParams({
            task_id: String(taskId),
            action: 'markRemind',
            nhac_viec: '0'
        })
    })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    Swal.fire('Đã đọc!', 'Đã tắt nhắc việc.', 'success');
                    setTimeout(() => {
                        // Ghi nhớ view + tab trước khi reload
                        localStorage.setItem('lastTab', document.querySelector('.nav-link.active').id);
                        localStorage.setItem('lastView', currentView);
                        location.reload();
                    }, 1200);
                } else {
                    Swal.fire('Lỗi!', data.message || 'Đọc thất bại.', 'error');
                }
            })
            .catch(err => {
                console.error(err);
                Swal.fire('Lỗi!', 'Không thể kết nối tới server.', 'error');
            });
}



// ====== VIEW SWITCHING (KANBAN / LIST / CALENDAR) ======
let currentView = 'kanban';
let calendar = null;

function switchView(viewType) {
    currentView = viewType;

    // Update button states
    document.querySelectorAll('.view-mode-toggle .btn').forEach(btn => btn.classList.remove('active'));

    if (viewType === 'kanban') {
        document.getElementById('viewKanban').classList.add('active');
        document.querySelector('.kanban-board').style.display = 'grid';
        document.getElementById('listView').classList.remove('active');
        document.getElementById('calendarView').classList.remove('active');
    } else if (viewType === 'list') {
        document.getElementById('viewList').classList.add('active');
        document.querySelector('.kanban-board').style.display = 'none';
        document.getElementById('listView').classList.add('active');
        document.getElementById('calendarView').classList.remove('active');
        initTableSorting();
    } else if (viewType === 'calendar') {
        document.getElementById('viewCalendar').classList.add('active');
        document.querySelector('.kanban-board').style.display = 'none';
        document.getElementById('listView').classList.remove('active');
        document.getElementById('calendarView').classList.add('active');
        initCalendar();
    }
}

// ====== TABLE SORTING ======
function initTableSorting() {
    const headers = document.querySelectorAll('.task-table thead th.sortable');
    headers.forEach(header => {
        header.addEventListener('click', function () {
            const sortField = this.dataset.sort;
            const currentSort = this.classList.contains('sort-asc') ? 'asc' :
                    this.classList.contains('sort-desc') ? 'desc' : 'none';

            // Remove sort classes from all headers
            headers.forEach(h => h.classList.remove('sort-asc', 'sort-desc'));

            // Apply new sort
            let newSort = currentSort === 'none' ? 'asc' : currentSort === 'asc' ? 'desc' : 'asc';
            this.classList.add('sort-' + newSort);

            sortTable(sortField, newSort);
        });
    });
}

function sortTable(field, order) {
    const tbody = document.getElementById('taskListTableBody');
    const rows = Array.from(tbody.querySelectorAll('tr'));

    rows.sort((a, b) => {
        let aVal = a.dataset[field.replace(/_/g, '')] || '';
        let bVal = b.dataset[field.replace(/_/g, '')] || '';

        // Handle dates
        if (field === 'han_hoan_thanh') {
            aVal = new Date(aVal);
            bVal = new Date(bVal);
        }

        if (aVal < bVal)
            return order === 'asc' ? -1 : 1;
        if (aVal > bVal)
            return order === 'asc' ? 1 : -1;
        return 0;
    });

    rows.forEach(row => tbody.appendChild(row));
}

function updateTaskDeadline(taskId, newDeadline) {
    fetch('./suaCongviec', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: new URLSearchParams({
            task_id: taskId,
            han_hoan_thanh: newDeadline,
            action: 'updateDeadline'
        })
    })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    Swal.fire({
                        icon: 'success',
                        title: 'Đã cập nhật!',
                        text: 'Deadline đã được thay đổi',
                        timer: 1500,
                        showConfirmButton: false
                    });
                } else {
                    Swal.fire('Lỗi!', data.message || 'Cập nhật thất bại', 'error');
                    calendar.refetchEvents();
                }
            })
            .catch(err => {
                console.error(err);
                Swal.fire('Lỗi!', 'Không thể kết nối server', 'error');
                calendar.refetchEvents();
            });
}

// load trang đúng view
document.addEventListener('DOMContentLoaded', function () {

    // 1️⃣ Lấy trạng thái cuối cùng
    const lastTab = localStorage.getItem('lastTab') || 'active-tasks-tab';
    const lastView = localStorage.getItem('lastView') || 'kanban';
    console.log('🔸 lastTab:', lastTab, '🔸 lastView:', lastView);

    // 2️⃣ Kích hoạt lại tab đã lưu
    const tabButton = document.getElementById(lastTab);
    if (tabButton) {
        const tabInstance = bootstrap.Tab.getOrCreateInstance(tabButton);
        tabInstance.show();

        if (lastTab.includes('archived'))
            currentTabState = 'archived';
        else if (lastTab.includes('deleted'))
            currentTabState = 'deleted';
        else
            currentTabState = 'active';
    }

    // 3️⃣ Khôi phục dạng xem
    if (typeof switchView === 'function') {
        switchView(lastView);
    }

    // 4️⃣ Ghi nhớ khi người dùng chuyển tab
    const tabButtons = document.querySelectorAll('#taskViewTabs .nav-link');
    tabButtons.forEach(btn => {
        btn.addEventListener('shown.bs.tab', e => {
            const newTabId = e.target.id;
            localStorage.setItem('lastTab', newTabId);

            if (newTabId.includes('archived'))
                currentTabState = 'archived';
            else if (newTabId.includes('deleted'))
                currentTabState = 'deleted';
            else
                currentTabState = 'active';

            console.log('🟢 Đang ở tab:', e.target.textContent.trim(), `(${currentTabState})`);
        });
    });

    // 5️⃣ Ghi nhớ khi người dùng đổi view
    document.querySelectorAll('.view-mode-toggle .btn').forEach(btn => {
        btn.addEventListener('click', function () {
            const newView = this.id.replace('view', '').toLowerCase();
            localStorage.setItem('lastView', newView);
            console.log('🟢 Đổi view:', newView);
            switchView(newView);
        });
    });
});

// ====== XỬ LÝ LOAD LỊCH SỬ CÔNG VIỆC ======
let currentTaskIdForHistory = null;
let historyLoaded = false;

// Lắng nghe sự kiện mở modal để lấy task ID
document.addEventListener('click', function (e) {
    const taskContent = e.target.closest('.task-content');
    if (taskContent) {
        currentTaskIdForHistory = taskContent.dataset.id;
        historyLoaded = false; // Reset khi mở modal mới
    }
});

// Hàm load lịch sử công việc
function loadTaskHistory(taskId) {
    const timeline = document.getElementById('taskHistoryTimeline');
    if (!timeline)
        return;

    // Hiển thị loading
    timeline.innerHTML = `
            <div class="history-empty">
                <i class="fa-solid fa-spinner fa-spin"></i>
                <p>Đang tải lịch sử công việc...</p>
            </div>
        `;

    // Gọi API
    fetch('./apiLichSuCongViec?taskId=' + taskId)
            .then(res => res.json())
            .then(data => {
                historyLoaded = true;
                renderTaskHistory(data);
            })
            .catch(err => {
                console.error('Lỗi khi tải lịch sử:', err);
                timeline.innerHTML = `
                <div class="history-empty">
                    <i class="fa-solid fa-circle-exclamation"></i>
                    <p>Không thể tải lịch sử công việc. Vui lòng thử lại.</p>
                </div>
            `;
            });
}

// Hàm render lịch sử công việc
function renderTaskHistory(historyData) {
    const timeline = document.getElementById('taskHistoryTimeline');
    if (!timeline)
        return;

    // Nếu không có dữ liệu
    if (!historyData || historyData.length === 0) {
        timeline.innerHTML = `
            <div class="history-empty">
                <i class="fa-solid fa-clock-rotate-left"></i>
                <p>Chưa có lịch sử thay đổi nào</p>
            </div>
        `;
        return;
    }

    // Render danh sách lịch sử
    let html = '';
    historyData.forEach((item, index) => {
        // Xử lý avatar
        const avatarSrc = item.anh_dai_dien && item.anh_dai_dien.trim() !== ''
                ? item.anh_dai_dien
                : 'https://ui-avatars.com/api/?name=' + encodeURIComponent(item.ten_nhan_vien || 'User') + '&background=007bff&color=fff';

        // Format thời gian
        let timeStr = '';
        if (item.thoi_gian) {
            const date = new Date(item.thoi_gian);
            const day = String(date.getDate()).padStart(2, '0');
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const year = date.getFullYear();
            const hours = String(date.getHours()).padStart(2, '0');
            const minutes = String(date.getMinutes()).padStart(2, '0');
            timeStr = day + '/' + month + '/' + year + ' ' + hours + ':' + minutes;
        }

        html += `
            <div class="history-item" style="animation-delay: ` + (index * 0.1) + `s">
                <div class="history-number">` + (index + 1) + `</div>
                <div class="history-avatar">
                    <img src="` + avatarSrc + `" alt="Avatar" onerror="this.src='https://ui-avatars.com/api/?name=User&background=007bff&color=fff'">
                </div>
                <div class="history-content">
                    <div class="history-user">` + (item.ten_nhan_vien || 'Không rõ') + `</div>
                    <div class="history-description">` + (item.mo_ta_thay_doi || '') + `</div>
                    <div class="history-time">
                        <i class="fa-solid fa-clock"></i> ` + timeStr + `
                    </div>
                </div>
            </div>
        `;
    });

    timeline.innerHTML = html;
}
function getApprovalBadge(status) {
    switch (status) {
        case 'Đã duyệt':
            return 'bg-success';
        case 'Từ chối':
            return 'bg-danger';
        case 'Chưa duyệt':
        default:
            return 'bg-secondary';
    }
}
