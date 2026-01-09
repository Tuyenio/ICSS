function hasPermission(code) {
    return USER_PERMISSIONS && USER_PERMISSIONS.includes(code);
}
document.addEventListener("DOMContentLoaded", function () {

    // Tạo task
    if (!hasPermission("them_congviec")) {
        $("#btnCreateTask").hide();
        $(".kanban-add-btn").hide(); // nút + trong Kanban
    }

    // Xóa task
    if (!hasPermission("xoa_congviec")) {
        $(".task-action-item.delete").remove();
        $(".task-action-item.permanent-delete-action").remove();
    }

    if (!hasPermission("them_quytrinh")) {
        $("#btnAddProcessStep").hide();
    }

    // Lưu thay đổi task
    if (!hasPermission("sua_congviec")) {
        $("#btnSaveTask").remove();
    }

    // Nhắc việc
    if (!hasPermission("nhacviec")) {
        $(".task-action-item.remind").remove();
    }

    // Duyệt task
    if (!hasPermission("duyet_congviec")) {
        $("#btnXetDuyet").remove();
    }
});
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
function saveAndReload() {
    try {
        const activeTab = document.querySelector('.nav-link.active');
        if (activeTab && activeTab.id) {
            localStorage.setItem('lastTab', activeTab.id);
        }
        localStorage.setItem('lastView', currentView || 'kanban');
    } catch (e) {
        // ignore any DOM/read errors
    }
    location.reload();
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
                    saveAndReload();
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
        const tenDuAn = button.getAttribute("data-ten_du_an") || "";
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
        modal.querySelector(".modal-title").innerHTML =
                '<i class="fa-solid fa-info-circle text-primary"></i> '
                + tenDuAn;
        modal.querySelector('[name="mo_ta"]').value = moTa;
        modal.querySelector('[name="ngay_bat_dau"]').value = ngay_bat_dau;
        modal.querySelector('[name="han_hoan_thanh"]').value = hanHT;
        modal.querySelector('[name="trang_thai_duyet"]').value = trangthaiduyet;
        selectOptionByText(modal.querySelector('[name="muc_do_uu_tien"]'), uuTien);
        selectOptionByText(modal.querySelector('[name="ten_nguoi_giao"]'), nguoiGiao);
        // ❌ bỏ dòng selectOptionByText cho người nhận
        selectOptionByText(modal.querySelector('[name="ten_phong_ban"]'), phongban);
        selectOptionByText(modal.querySelector('[name="trang_thai"]'), trangthai);
        
        // Hiển thị link tài liệu
        const linkTaiLieuContainer = modal.querySelector('#linkTaiLieuContainer');
        if (linkTaiLieuContainer) {
            if (tailieu && tailieu.trim() !== '' && tailieu.toLowerCase() !== 'null') {
                linkTaiLieuContainer.innerHTML = '<a href="' + tailieu + '" target="_blank" class="btn btn-sm btn-primary"><i class="fa-solid fa-external-link-alt me-1"></i>Xem tài liệu</a>';
            } else {
                linkTaiLieuContainer.innerHTML = '<small class="text-muted">Chưa có link tài liệu</small>';
            }
        }
        modal.querySelector('[name="tai_lieu_cv"]').value = tailieu;

        // === Hiển thị / ẩn phần gia hạn công việc ===
        const adminBox = document.getElementById("extensionSectionAdmin");
        const adminForm = document.getElementById("adminGiaHanForm");
        const adminBtn = document.getElementById("btnAdminGiaHan");

        const userBox = document.getElementById("extensionSectionUser");
        const userForm = document.getElementById("userGiaHanForm");
        const userBtn = document.getElementById("btnUserGiaHan");

        const isOverdue = trangthai.toLowerCase().includes("trễ hạn");

// --- RESET mặc định ---
        if (adminBox)
            adminBox.style.display = "none";
        if (userBox)
            userBox.style.display = "none";
        if (adminForm)
            adminForm.style.display = "none";
        if (userForm)
            userForm.style.display = "none";

// --- Nếu công việc trễ hạn → hiển thị đúng form theo vai trò ---
        if (isOverdue) {

            // Nếu admin đăng nhập → chỉ hiển thị box của admin
            if (adminBox) {
                adminBox.style.display = "block";

                if (adminBtn) {
                    adminBtn.onclick = function () {
                        adminForm.style.display = "block";
                    };
                }
            }

            // Nếu là user → hiển thị form user
            if (userBox) {
                userBox.style.display = "block";

                if (userBtn) {
                    userBtn.onclick = function () {
                        userForm.style.display = "block";
                    };
                }
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

            // Tạo nút xoá
            const closeBtn = document.createElement("button");
            closeBtn.type = "button";
            closeBtn.className = "btn btn-sm btn-close ms-2";
            closeBtn.setAttribute("aria-label", "Xoá");

            // Sự kiện xoá
            closeBtn.addEventListener("click", function () {
                tag.remove();
                capNhatHiddenInput();
            });

            // Gắn phần text và nút xoá vào thẻ
            tag.appendChild(tenNode);
            tag.appendChild(closeBtn);

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

// Nút trong modal tạo mới
document.getElementById("btnOpenNguoiNhanCreate").addEventListener("click", function () {
    currentTarget = "create";
    syncNguoiNhanCheckboxes("nguoiNhanHidden2"); // tick theo hidden của form tạo
    new bootstrap.Modal(document.getElementById("modalChonNguoiNhan")).show();
});

// Nút trong modal chi tiết
document.getElementById("btnOpenNguoiNhanDetail").addEventListener("click", function () {
    currentTarget = "detail";
    syncNguoiNhanCheckboxes("nguoiNhanHidden"); // tick theo hidden của form chi tiết
    new bootstrap.Modal(document.getElementById("modalChonNguoiNhan")).show();
});
document.getElementById("btnOpenNguoiNhanProcess").addEventListener("click", function () {
    currentTarget = "process";
    syncNguoiNhanCheckboxes("nguoiNhanProcessHidden");

    let md = new bootstrap.Modal(document.getElementById("modalChonNguoiNhan"));
    md.show();
});

document.addEventListener("shown.bs.modal", function (event) {
    const modal = event.target;

    // Nếu đây là modal mở thứ 2 trở lên
    if ($('.modal.show').length > 1) {
        let zIndex = 1050 + ($('.modal.show').length * 20);
        $(modal).css('z-index', zIndex);

        // cũng tăng z-index của backdrop
        setTimeout(function () {
            $('.modal-backdrop').not('.stacked')
                    .css('z-index', zIndex - 10)
                    .addClass('stacked');
        }, 50);
    }
});

document.getElementById("btnXacNhanNguoiNhan").addEventListener("click", function () {
    var checked = document.querySelectorAll(".nguoiNhanItem:checked");

    var danhSachDiv, hiddenInput;
    if (currentTarget === "create") {
        danhSachDiv = document.getElementById("danhSachNguoiNhan2");
        hiddenInput = document.getElementById("nguoiNhanHidden2");
    } else if (currentTarget === "detail") {
        danhSachDiv = document.getElementById("danhSachNguoiNhan");
        hiddenInput = document.getElementById("nguoiNhanHidden");
    } else if (currentTarget === "process") {
        danhSachDiv = document.getElementById("danhSachNguoiNhanProcess");
        hiddenInput = document.getElementById("nguoiNhanProcessHidden");
    } else if (currentTarget === "editStep") {
        // NEW: khi gọi từ modal sửa bước
        danhSachDiv = document.getElementById("danhSachNguoiNhanEdit");
        hiddenInput = document.getElementById("nguoiNhanEditHidden");
    }

    if (!danhSachDiv || !hiddenInput) {
        // an toàn: nếu không tìm thấy element, đóng modal chọn
        bootstrap.Modal.getInstance(document.getElementById("modalChonNguoiNhan")).hide();
        return;
    }

    danhSachDiv.innerHTML = "";
    var values = [];

    for (var i = 0; i < checked.length; i++) {
        var ten = checked[i].value;
        values.push(ten);

        var tag = document.createElement("span");
        tag.className = "badge bg-primary d-flex align-items-center me-2";
        tag.style.padding = "0.5em 0.75em";
        tag.setAttribute("data-ten", ten);
        tag.innerHTML = ten +
                '<button type="button" class="btn btn-sm btn-close ms-2" aria-label="Xoá"></button>';

        tag.querySelector(".btn-close").addEventListener("click", function () {
            this.parentElement.remove();
            capNhatHiddenInput(danhSachDiv, hiddenInput);
        });

        danhSachDiv.appendChild(tag);
    }

    hiddenInput.value = values.join(",");

    bootstrap.Modal.getInstance(document.getElementById("modalChonNguoiNhan")).hide();
});

function capNhatHiddenInput(danhSachDiv, hiddenInput) {
    var badges = danhSachDiv.querySelectorAll("span[data-ten]");
    var arr = [];
    for (var i = 0; i < badges.length; i++) {
        arr.push(badges[i].getAttribute("data-ten"));
    }
    hiddenInput.value = arr.join(",");
}

$('#taskForm').on('submit', function (e) {
    e.preventDefault();

    // Client-side validation cho trường bắt buộc
    var ten = $(this).find('[name="ten_cong_viec"]').val() || '';
    var duAn = $(this).find('[name="du_an_id"]').val() || '';
    var nguoiGiao = $(this).find('[name="ten_nguoi_giao"]').val() || '';
    var phongBan = $(this).find('[name="ten_phong_ban"]').val() || '';

    var missing = [];
    if (!ten.trim())
        missing.push({field: 'ten_cong_viec', msg: 'Vui lòng nhập tên công việc'});
    if (!duAn.trim())
        missing.push({field: 'du_an_id', msg: 'Vui lòng chọn dự án'});
    if (!nguoiGiao.trim())
        missing.push({field: 'ten_nguoi_giao', msg: 'Vui lòng chọn người giao'});
    if (!phongBan.trim())
        missing.push({field: 'ten_phong_ban', msg: 'Vui lòng chọn phòng ban'});

    if (missing.length > 0) {
        // Hiện thông báo cho trường đầu tiên thiếu và focus vào input tương ứng
        showToast('error', missing[0].msg);
        var fld = $(this).find('[name="' + missing[0].field + '"]');
        if (fld && fld.length)
            fld.focus();
        return;
    }

    const formData = new FormData(this);
    let url = './themCongviec'; // luôn là thêm mới

    $.ajax({
        url: url,
        type: 'POST',
        data: formData,
        processData: false,
        contentType: false,
        success: function (response) {
            if (response.success) {
                $('#modalTask').modal('hide');
                showToast('success', 'Thêm mới thành công');
                location.reload();
            } else {
                // Hiện message trả về từ server (đã rõ ràng)
                showToast('error', response.message || 'Thêm mới thất bại');
            }
        },
        error: function (xhr) {
            var msg = 'Thêm mới thất bại';
            try {
                var json = JSON.parse(xhr.responseText);
                if (json && json.message)
                    msg = json.message;
            } catch (e) {
            }
            showToast('error', msg);
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
            projectId: 0,
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
                + '            <button class="btn btn-sm btn-info" title="Nhắc việc" onclick="event.stopPropagation(); remindTask(\'' + task.id + '\')">'
                + '                <i class="fa-solid fa-bell"></i>'
                + '            </button>'
                + '            <button class="btn btn-sm btn-danger" title="Xóa" onclick="event.stopPropagation(); deleteTask(\'' + task.id + '\')">'
                + '                <i class="fa-solid fa-trash"></i>'
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

    // 👇 Gửi phần trăm về server và cập nhật UI nếu cần
    var taskId = $('#taskId').val();
    if (taskId) {
        $.ajax({
            url: 'capnhatTiendo',
            method: 'POST',
            data: {cong_viec_id: taskId, phan_tram: percent},
            success: function () {
                // Nếu tất cả bước hoàn thành -> cập nhật trạng thái task thành "Đã hoàn thành" trên UI ngay
                if (percent === 100) {
                    var newStatus = 'Đã hoàn thành';

                    // 1) Cập nhật select hiển thị trong modal đang mở (nếu có)
                    var modal = $('#modalTaskDetail');
                    if (modal.length) {
                        var select = modal.find('[name="trang_thai"]');
                        if (select.length)
                            select.val(newStatus);
                        modal.find('[name="trang_thai_duyet"]').val(modal.find('[name="trang_thai_duyet"]').val()); // giữ nguyên duyệt
                    }

                    // 2) Cập nhật thẻ Kanban (cả dạng data-task-id và data-id)
                    var card = $('.kanban-task[data-task-id="' + taskId + '"], .kanban-task[data-id="' + taskId + '"]');
                    if (card.length) {
                        // cập nhật data attribute
                        card.attr('data-trang-thai', newStatus);

                        // cập nhật badge hiển thị trong card
                        var statusBadge = card.find('.task-status');
                        if (statusBadge.length) {
                            statusBadge.text(newStatus).removeClass().addClass('task-status badge bg-success');
                        }

                        // tìm tab pane chứa card (archived / deleted / active)
                        var parentTab = card.closest('.tab-pane');
                        var completedCol = $();
                        if (parentTab && parentTab.length) {
                            completedCol = parentTab.find('.kanban-col.completed').first();
                        }
                        // nếu không tìm thấy trong same tab, fallback về global
                        if (!completedCol || completedCol.length === 0) {
                            completedCol = $('.kanban-col.completed').first();
                        }
                        if (completedCol && completedCol.length) {
                            completedCol.append(card);
                        }
                    }

                    // 3) Cập nhật List view (nếu có hàng tương ứng)
                    var row = $('tr[data-id="' + taskId + '"]');
                    if (row.length) {
                        // update data attribute
                        row.attr('data-trang-thai', newStatus);

                        // cột trạng thái thường là cột thứ 8 (index 7)
                        var statusCell = row.find('td').eq(7);
                        if (statusCell.length) {
                            statusCell.html('<span class="badge status-completed">' + newStatus + '</span>');
                        }
                    }

                    showToast('success', 'Cập nhật tiến độ 100% — công việc được đánh là "Đã hoàn thành" trên giao diện.');
                } else {
                    showToast('success', 'Cập nhật tiến độ thành công');
                }
            },
            error: function () {
                showToast('error', 'Lỗi khi cập nhật tiến độ');
            }
        });
    } else {
        // không có taskId chỉ cập nhật progress bar local
        if (percent === 100) {
            showToast('success', 'Tiến độ đạt 100% (cập nhật local).');
        }
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
            var receiverNames = '';
            if (Array.isArray(step.receivers) && step.receivers.length > 0) {
                receiverNames = step.receivers.map(r => r.name).join(', ');
            }

            var editBtn =
                    '<button class="btn btn-sm btn-outline-secondary me-1" onclick="showEditStepModal(' + idx + ')">' +
                    '<i class="fa-solid fa-pen"></i> Chỉnh sửa</button>';
            var deleteBtn =
                    '<button class="btn btn-sm btn-danger ms-1" onclick="removeProcessStep(' + idx + ')">' +
                    '<i class="fa-solid fa-trash"></i></button>';

            var taiLieuHtml = '';
            if (step.linkTaiLieu || step.fileTaiLieu) {
                taiLieuHtml = '<div class="text-muted small mt-1"><i class="fa-solid fa-paperclip"></i> Tài liệu: ';
                if (step.linkTaiLieu && step.linkTaiLieu.trim() !== '' && step.linkTaiLieu.toLowerCase() !== 'null') {
                    taiLieuHtml += '<a href="' + step.linkTaiLieu + '" target="_blank" class="text-decoration-none"><i class="fa-solid fa-external-link-alt me-1"></i>Link</a>';
                }
                if (step.linkTaiLieu && step.linkTaiLieu.trim() !== '' && step.linkTaiLieu.toLowerCase() !== 'null' && step.fileTaiLieu) {
                    taiLieuHtml += ' | ';
                }
                if (step.fileTaiLieu) {
                    var files = step.fileTaiLieu.split(';').map(f => f.trim()).filter(Boolean);
                    if (files.length === 1) {
                        taiLieuHtml += '<a href="downloadFile?file=' + encodeURIComponent(files[0]) + '" target="_blank" class="text-decoration-none"><i class="fa-solid fa-download me-1"></i>File</a>';
                    } else {
                        taiLieuHtml += '<span class="me-2"><i class="fa-solid fa-file-download me-1"></i>' + files.length + ' file:</span>';
                        files.forEach(function(file, idx) {
                            var fileName = file.split('/').pop();
                            taiLieuHtml += '<a href="downloadFile?file=' + encodeURIComponent(file) + '" target="_blank" class="text-decoration-none me-2" title="' + fileName + '">';
                            taiLieuHtml += '<i class="fa-solid fa-download"></i> ' + (idx + 1) + '</a>';
                        });
                    }
                }
                taiLieuHtml += '</div>';
            }
            
            var html = '<li class="list-group-item d-flex justify-content-between align-items-center">' +
                    '<div>' +
                    '<b>' + step.name + '</b> ' +
                    '<span class="badge ' + badgeClass + '">' + step.status + '</span><br>' +
                    '<small>' + (step.desc ? step.desc : '') + '</small>' +
                    '<div class="text-muted small"><i class="fa-solid fa-user"></i> Người nhận: ' + (receiverNames || 'Chưa có') + '</div>' +
                    '<div class="text-muted small">Từ ' + (step.start || '-') + ' đến ' + (step.end || '-') + '</div>' +
                    taiLieuHtml +
                    '</div>' +
                    '<div>' + editBtn + deleteBtn + '</div>' +
                    '</li>';
            list.append(html);
        });
    }
}

function renderTaskReviews(data) {
    const list = document.getElementById("taskReviewList");
    list.innerHTML = "";

    data.forEach(function (item) {

        // Avatar fallback
        var avatar = (item.anh_dai_dien && item.anh_dai_dien.trim() !== "")
                ? item.anh_dai_dien
                : "https://ui-avatars.com/api/?name=" + encodeURIComponent(item.ten_nguoi_danh_gia);

        var timeStr = new Date(item.thoi_gian).toLocaleString("vi-VN");

        var isRight = item.is_from_worker == 1;

        var li = document.createElement("li");
        li.className = "chat-item " + (isRight ? "chat-item-right" : "chat-item-left");

        // ❇️ KHÔNG DÙNG TEMPLATE LITERAL, KHÔNG CÓ `${}`
        var html = ""
                + "<img class='chat-avatar' src='" + avatar + "'>"
                + "<div>"
                + "    <div class='chat-bubble " + (isRight ? "chat-right" : "chat-left") + "'>"
                + "        <div class='fw-bold'>" + item.ten_nguoi_danh_gia + "</div>"
                + "        <div>" + item.nhan_xet + "</div>"
                + "    </div>"
                + "    <div class='chat-time'>" + timeStr + "</div>"
                + "</div>";

        li.innerHTML = html;
        list.appendChild(li);
    });
}

function showEditStepModal(idx) {
    var step = processSteps[idx];
    if (!step)
        return;

    // Xóa modal cũ nếu tồn tại
    $('#modalEditStepStatus').remove();

    // Tạo HTML modal (thêm phần chọn người nhận)
    var modalHtml = `
        <div class="modal fade" id="modalEditStepStatus" tabindex="-1">
          <div class="modal-dialog">
            <form class="modal-content" id="formEditStepStatus">
              <input type="hidden" name="stepid" value="${step.id}">
              <div class="modal-header">
                <h5 class="modal-title">
                  <i class="fa-solid fa-pen"></i> Chỉnh sửa bước quy trình
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
              </div>
              <div class="modal-body">
                <div class="mb-2">
                  <label class="form-label">Tên bước/giai đoạn</label>
                  <input type="text" class="form-control" name="stepName" value="${step.name || ''}" required>
                </div>
                <div class="mb-2">
                  <label class="form-label">Mô tả</label>
                  <textarea class="form-control" name="stepDesc" rows="2">${step.desc || ''}</textarea>
                </div>
                <div class="mb-2">
                  <label class="form-label">Người nhận</label>
                  <div id="danhSachNguoiNhanEdit" class="mb-2 d-flex flex-wrap"></div>
                  <input type="hidden" id="nguoiNhanEditHidden" name="nguoiNhanEditHidden" value="">
                  <div>
                    <button type="button" class="btn btn-outline-secondary btn-sm" id="btnOpenNguoiNhanEdit">
                      <i class="fa-solid fa-users me-1"></i> Chọn người nhận
                    </button>
                  </div>
                </div>
                <div class="mb-2">
                  <label class="form-label">Trạng thái</label>
                  <select class="form-select" name="stepStatus">
                    <option value="Chưa bắt đầu" ${step.status === "Chưa bắt đầu" ? "selected" : ""}>Chưa bắt đầu</option>
                    <option value="Đang thực hiện" ${step.status === "Đang thực hiện" ? "selected" : ""}>Đang thực hiện</option>
                    <option value="Đã hoàn thành" ${step.status === "Đã hoàn thành" ? "selected" : ""}>Đã hoàn thành</option>
                  </select>
                </div>

                <div class="mb-2 row">
                  <div class="col">
                    <label class="form-label">Ngày bắt đầu</label>
                    <input type="date" class="form-control" name="stepStart" value="${step.start || ''}">
                  </div>
                  <div class="col">
                    <label class="form-label">Ngày kết thúc</label>
                    <input type="date" class="form-control" name="stepEnd" value="${step.end || ''}">
                  </div>
                </div>
                <div class="mb-2">
                  <label class="form-label">Link tài liệu</label>
                  <input type="text" class="form-control" name="stepLinkTaiLieu" value="${step.linkTaiLieu || ''}" placeholder="https://...">
                  <small class="text-muted">Link tài liệu tham khảo (Google Drive, Dropbox, v.v.)</small>
                </div>
                <div class="mb-2">
                  <label class="form-label">File tài liệu hiện tại</label>
                  <div id="currentStepFiles" class="mb-2"></div>
                  <input type="hidden" name="file_tai_lieu_cu" id="fileTaiLieuCuEdit" value="${step.fileTaiLieu || ''}">
                  <label class="form-label">Thêm file mới</label>
                  <input type="file" class="form-control" name="stepFileTaiLieu" accept=".pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx" multiple>
                  <small class="text-muted">Chọn một hoặc nhiều file để thêm vào file hiện tại</small>
                </div>
              </div>
              <div class="modal-footer">
                <button type="submit" class="btn btn-primary rounded-pill">Cập nhật</button>
                <button type="button" class="btn btn-secondary rounded-pill" data-bs-dismiss="modal">Huỷ</button>
              </div>
            </form>
          </div>
        </div>`;

    $('body').append(modalHtml);

    var modalEl = document.getElementById('modalEditStepStatus');
    var modal = new bootstrap.Modal(modalEl, {backdrop: 'static', keyboard: true});

    // ✅ Fix chồng modal: tăng z-index
    const parentModal = document.getElementById('modalTaskDetail');
    if (parentModal && $(parentModal).hasClass('show')) {
        $(modalEl).css('z-index', parseInt($(parentModal).css('z-index')) + 20);
        $('.modal-backdrop').last().css('z-index', parseInt($(parentModal).css('z-index')) + 10);
    }

    // Hiển thị danh sách file hiện tại từng dòng kèm nút xoá
    var filesContainer = $(modalEl).find('#currentStepFiles');
    var hiddenFilesInput = $(modalEl).find('#fileTaiLieuCuEdit');

    function renderCurrentFiles(filesStr) {
        filesContainer.empty();
        var files = (filesStr || '').split(';').map(function (f) {
            return f.trim();
        }).filter(Boolean);

        if (files.length === 0) {
            filesContainer.append('<small class="text-muted">Chưa có file nào</small>');
            return;
        }

        files.forEach(function (f, fileIdx) {
            var fileName = f.split('/').pop();
            var row = ''
                    + '<div class="d-flex align-items-center mb-1 p-2 border rounded">'
                    + '  <i class="fa-solid fa-file me-2"></i>'
                    + '  <a href="' + f + '" target="_blank" class="flex-grow-1 text-truncate">' + fileName + '</a>'
                    + '  <button type="button" class="btn btn-sm btn-outline-danger ms-2 btn-remove-file" data-file-idx="' + fileIdx + '">'
                    + '    <i class="fa-solid fa-xmark"></i>'
                    + '  </button>'
                    + '</div>';
            filesContainer.append(row);
        });
    }

    renderCurrentFiles(hiddenFilesInput.val());

    $(modalEl).on('click', '.btn-remove-file', function () {
        var fileIdx = parseInt($(this).data('file-idx'), 10);
        var files = (hiddenFilesInput.val() || '').split(';').map(function (f) {
            return f.trim();
        }).filter(Boolean);

        if (!isNaN(fileIdx) && fileIdx >= 0 && fileIdx < files.length) {
            files.splice(fileIdx, 1);
            var updated = files.join(';');
            hiddenFilesInput.val(updated);
            renderCurrentFiles(updated);
        }
    });

    // --- populate người nhận ban đầu ---
    (function populateEditReceivers() {
        var hidden = $('#nguoiNhanEditHidden');
        var badgeContainer = $('#danhSachNguoiNhanEdit');
        badgeContainer.empty();

        // step.receivers có thể là mảng {id, name} hoặc step.receiverNames (chuỗi)
        var names = [];
        if (Array.isArray(step.receivers) && step.receivers.length > 0) {
            names = step.receivers.map(r => r.name || r.ten || '').filter(Boolean);
        } else if (step.receiver_names) {
            names = String(step.receiver_names).split(',').map(s => s.trim()).filter(Boolean);
        } else if (step.receiver || step.receivers_names) {
            names = String(step.receiver || step.receivers_names).split(',').map(s => s.trim()).filter(Boolean);
        }

        hidden.val(names.join(','));

        names.forEach(function (ten) {
            var tag = $('<span>').addClass('badge bg-primary d-flex align-items-center me-2').css('padding', '0.5em 0.75em').attr('data-ten', ten);
            var tenNode = $('<span>').text(ten);
            var closeBtn = $('<button type="button" class="btn btn-sm btn-close ms-2" aria-label="Xoá"></button>');
            closeBtn.on('click', function () {
                tag.remove();
                // cập nhật hidden
                var arr = [];
                badgeContainer.find('span[data-ten]').each(function () {
                    arr.push($(this).data('ten'));
                });
                hidden.val(arr.join(','));
            });
            tag.append(tenNode).append(closeBtn);
            badgeContainer.append(tag);
        });
    })();

    modal.show();

    // mở modal chọn người nhận từ modal edit
    $(modalEl).find('#btnOpenNguoiNhanEdit').on('click', function () {
        currentTarget = 'editStep';
        syncNguoiNhanCheckboxes('nguoiNhanEditHidden');
        new bootstrap.Modal(document.getElementById('modalChonNguoiNhan')).show();
    });

    // Xử lý submit cập nhật (gửi cả danh sách người nhận dưới dạng ID tới backend)
    $('#formEditStepStatus').on('submit', function (e) {
        e.preventDefault();

        var currentFilesStr = $(modalEl).find('#fileTaiLieuCuEdit').val() || '';

        // cập nhật object lokal
        processSteps[idx] = {
            id: $(this).find('[name="stepid"]').val(),
            name: $(this).find('[name="stepName"]').val(),
            desc: $(this).find('[name="stepDesc"]').val(),
            status: $(this).find('[name="stepStatus"]').val(),
            start: $(this).find('[name="stepStart"]').val(),
            end: $(this).find('[name="stepEnd"]').val(),
            linkTaiLieu: $(this).find('[name="stepLinkTaiLieu"]').val(),
            fileTaiLieu: currentFilesStr,
            // lưu tên người nhận tạm thời
            receivers: (function () {
                var names = ($('#nguoiNhanEditHidden').val() || '').split(',').map(s => s.trim()).filter(Boolean);
                return names.map(n => ({name: n}));
            })()
        };

        renderProcessSteps();
        modal.hide();

        // map tên -> id (tương tự phần thêm)
        var nguoiNhanNames = $('#nguoiNhanEditHidden').val() || "";
        var nguoiNhanIds = [];
        nguoiNhanNames.split(',').map(t => t.trim()).forEach(function (ten) {
            var el = Array.from(document.querySelectorAll('.nguoiNhanItem')).find(c => c.value.trim() === ten);
            if (el) {
                var id = el.id.replace('nv_', '');
                nguoiNhanIds.push(id);
            }
        });

        // Gửi cập nhật về server kèm process_nguoi_nhan (IDs) và file (nếu có)
        var formData = new FormData();
        formData.append('step_id', processSteps[idx].id);
        formData.append('name', processSteps[idx].name);
        formData.append('desc', processSteps[idx].desc);
        formData.append('stepStatus', processSteps[idx].status);
        formData.append('start', processSteps[idx].start);
        formData.append('end', processSteps[idx].end);
        formData.append('link_tai_lieu', processSteps[idx].linkTaiLieu || '');
        formData.append('process_nguoi_nhan', nguoiNhanIds.join(','));
        formData.append('file_tai_lieu_cu', currentFilesStr);
        
        // Thêm tất cả file nếu có
        var fileInput = $(e.target).find('[name="stepFileTaiLieu"]')[0];
        if (fileInput && fileInput.files && fileInput.files.length > 0) {
            for (var i = 0; i < fileInput.files.length; i++) {
                formData.append('file_tai_lieu', fileInput.files[i]);
            }
        }
        
        $.ajax({
            url: './apiTaskSteps',
            method: 'POST',
            data: formData,
            processData: false,
            contentType: false,
            success: function (response) {
                // Cập nhật fileTaiLieu nếu server trả về
                if (response && response.fileTaiLieu) {
                    processSteps[idx].fileTaiLieu = response.fileTaiLieu;
                }
                renderProcessSteps();
                showToast('success', 'Cập nhật bước thành công');
            },
            error: function () {
                showToast('error', 'Cập nhật bước thất bại');
            }
        });
    });

    $(modalEl).on('hidden.bs.modal', function () {
        // Remove the modal element itself
        $(this).remove();

        // Remove ONLY the backdrop that was added for this modal (the last one)
        var $backdrops = $('.modal-backdrop');
        if ($backdrops.length > 0) {
            $backdrops.last().remove();
        }

        // Nếu vẫn còn modal khác đang mở → đảm bảo body giữ class modal-open
        if ($('.modal.show').length > 0) {
            $('body').addClass('modal-open').css('padding-right', '');
        } else {
            // Không còn modal → dọn sạch trạng thái
            $('body').removeClass('modal-open').css('padding-right', '');
        }
    });
}

window.removeProcessStep = function (idx) {
    var step = processSteps[idx];
    if (!step || !step.id) {
        showToast('error', 'Không thể xác định bước cần xóa.');
        return;
    }

    Swal.fire({
        title: 'Xác nhận xóa bước quy trình?',
        html: 'Bạn có chắc chắn muốn xóa bước: <b>' + (step.name || '') + '</b> ?',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d33',
        cancelButtonColor: '#6c757d',
        confirmButtonText: 'Xóa',
        cancelButtonText: 'Hủy',
        focusCancel: true
    }).then(function (result) {
        if (!result.isConfirmed)
            return;

        Swal.fire({
            title: 'Đang xóa...',
            allowOutsideClick: false,
            didOpen: () => Swal.showLoading()
        });

        fetch('./xoaQuytrinh', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: new URLSearchParams({action: 'delete', step_id: String(step.id)})
        })
                .then(async res => {
                    const text = await res.text();
                    let data = {};
                    try {
                        data = text ? JSON.parse(text) : {};
                    } catch {
                        data = {success: res.ok};
                    }
                    if (res.ok && data.success) {
                        // Cập nhật UI local
                        processSteps.splice(idx, 1);
                        renderProcessSteps();
                        Swal.fire({icon: 'success', title: 'Đã xóa!', text: 'Bước quy trình đã được xóa.'});
                    } else {
                        const msg = data.message || 'Xóa thất bại. Vui lòng thử lại.';
                        Swal.fire('Lỗi!', msg, 'error');
                    }
                })
                .catch(err => {
                    console.error('Delete step error:', err);
                    Swal.fire('Lỗi!', 'Không thể kết nối tới server.', 'error');
                });
    });
};

$('#btnAddProcessStep').on('click', function () {
    $('#formAddProcessStep')[0].reset();
    $('#modalAddProcessStep').modal('show');
});

$('#formAddProcessStep').on('submit', function (e) {
    e.preventDefault();
    var taskId = document.getElementById("taskId").value;
    var step = {
        name: $(this).find('[name="stepName"]').val(),
        desc: $(this).find('[name="stepDesc"]').val(),
        status: $(this).find('[name="stepStatus"]').val(),
        start: $(this).find('[name="stepStart"]').val(),
        end: $(this).find('[name="stepEnd"]').val(),
        linkTaiLieu: $(this).find('[name="stepLinkTaiLieu"]').val(),
        fileTaiLieu: ''
    };

    var nguoiNhanNames = ($('#nguoiNhanProcessHidden').val() || "").split(',')
            .map(t => t.trim()).filter(Boolean);

    var nguoiNhanIds = [];
    var receivers = [];
    nguoiNhanNames.forEach(function (ten) {
        var el = Array.from(document.querySelectorAll('.nguoiNhanItem')).find(c => c.value.trim() === ten);
        if (el) {
            var id = el.id.replace('nv_', '');
            nguoiNhanIds.push(id);
            receivers.push({id: id, name: ten});
        } else {
            receivers.push({name: ten});
        }
    });

    step.receivers = receivers;

    var formData = new FormData();
    formData.append('action', 'add');
    formData.append('task_id', taskId);
    formData.append('name', step.name);
    formData.append('desc', step.desc);
    formData.append('stepStatus', step.status);
    formData.append('start', step.start);
    formData.append('end', step.end);
    formData.append('link_tai_lieu', step.linkTaiLieu || '');
    formData.append('process_nguoi_nhan', nguoiNhanIds.join(','));
    
    // Thêm tất cả file nếu có
    var fileInput = $(this).find('[name="stepFileTaiLieu"]')[0];
    if (fileInput && fileInput.files && fileInput.files.length > 0) {
        for (var i = 0; i < fileInput.files.length; i++) {
            formData.append('file_tai_lieu', fileInput.files[i]);
        }
    }

    $.ajax({
        url: './xoaQuytrinh',
        method: 'POST',
        data: formData,
        processData: false,
        contentType: false,
        success: function (resp) {
            var data = resp;
            if (typeof resp === 'string') {
                try {
                    data = JSON.parse(resp);
                } catch (e) {
                    data = resp;
                }
            }

            if (data && data.success === false) {
                showToast('error', data.message || 'Thêm bước thất bại');
                return;
            }

            var newId = (data && data.id) ? data.id : resp;
            step.id = newId;
            if (data && data.fileTaiLieu) {
                step.fileTaiLieu = data.fileTaiLieu;
            }
            if (data && data.linkTaiLieu !== undefined) {
                step.linkTaiLieu = data.linkTaiLieu;
            }
            if (data && data.name) {
                step.name = data.name;
            }
            if (data && data.desc) {
                step.desc = data.desc;
            }

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
    if (tabProgress) {
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
    }

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
document.addEventListener("hidden.bs.modal", function () {
    // Nếu chỉ còn 1 modal mở → reset backdrop
    if ($('.modal.show').length === 1) {
        $('.modal-backdrop').removeClass('stacked').css('z-index', '');
    }

    // Nếu không còn modal nào mở → xoá mọi backdrop còn sót
    if ($('.modal.show').length === 0) {
        $('.modal-backdrop').remove();
        $('body').removeClass('modal-open').css('padding-right', '');
    }
});
document.getElementById("btnAddReview").addEventListener("click", function () {
    var taskId = document.getElementById("taskId").value;
    var comment = document.getElementById("reviewComment").value.trim();
    var reviewerId = document.getElementById("currentUserId").value;

    if (!comment) {
        showToast('error', 'Vui lòng nhập nhận xét.');
        return;
    }

    var formData = new URLSearchParams();
    formData.append("cong_viec_id", taskId);
    formData.append("nguoi_danh_gia_id", reviewerId);
    formData.append("nhan_xet", comment);

    fetch("./apiDanhgiaCV", {
        method: "POST",
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: formData.toString()
    })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    showToast('success', 'Thêm đánh giá thành công!');
                    document.getElementById("reviewComment").value = "";
                    loadTaskReviews(taskId);
                } else {
                    showToast('error', 'Thêm thất bại: ' + (data.message || ''));
                }
            })
            .catch(() => {
                showToast('error', 'Đã xảy ra lỗi khi thêm đánh giá.');
            });
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
                case 'remind':
                    remindTask(taskId);
                    break;
                case 'delete':
                    deleteTask(taskId);
                    break;
                case 'restore':
                    restoreTask(taskId);
                    break;
                case 'permanent-delete':
                    permanentDeleteTask(taskId);
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
                                saveAndReload();
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

function remindTask(taskId) {
    fetch('./suaCongviec', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: new URLSearchParams({
            task_id: String(taskId),
            action: 'remind',
            nhac_viec: '1'
        })
    })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    Swal.fire('Thành công!', 'Nhắc việc thành công.', 'success');
                    setTimeout(() => {
                        // Ghi nhớ view + tab trước khi reload
                        saveAndReload();
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

function deleteTask(taskId) {
    Swal.fire({
        title: 'Xác nhận xóa?',
        text: 'Bạn có chắc chắn muốn xóa công việc này? (Sẽ được chuyển vào thùng rác)',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d33',
        cancelButtonColor: '#6c757d',
        confirmButtonText: 'Xóa',
        cancelButtonText: 'Hủy'
    }).then((result) => {
        if (result.isConfirmed) {
            showToast('info', '🗑️ Đang chuyển vào thùng rác...');

            fetch('./suaCongviec', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: new URLSearchParams({
                    task_id: String(taskId),
                    action: 'delete',
                    tinh_trang: 'Đã xóa'
                })
            })
                    .then(res => res.json())
                    .then(data => {
                        if (data.success) {
                            Swal.fire('Đã xóa!', 'Công việc đã được chuyển vào thùng rác.', 'success');
                            setTimeout(() => {
                                // Ghi nhớ view + tab trước khi reload
                                saveAndReload();
                            }, 1200);
                        } else {
                            Swal.fire('Lỗi!', data.message || 'Xóa thất bại.', 'error');
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

// ====== XÓA VĨNH VIỄN CÔNG VIỆC ======
function permanentDeleteTask(taskId) {
    Swal.fire({
        title: 'Xác nhận xóa vĩnh viễn?',
        text: '⚠️ Hành động này không thể hoàn tác. Công việc sẽ bị xóa hoàn toàn khỏi hệ thống!',
        icon: 'error',
        showCancelButton: true,
        confirmButtonColor: '#d33', // đỏ đậm
        cancelButtonColor: '#6c757d', // xám
        confirmButtonText: 'Xóa vĩnh viễn',
        cancelButtonText: 'Hủy',
        reverseButtons: true
    }).then((result) => {
        if (result.isConfirmed) {
            Swal.fire({
                title: 'Đang xóa...',
                text: 'Vui lòng chờ trong giây lát',
                allowOutsideClick: false,
                didOpen: () => Swal.showLoading()
            });

            fetch('./xoaCongviec', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: new URLSearchParams({id: String(taskId), task_id: String(taskId), permanent: 'true'})
            })
                    .then(async (res) => {
                        const text = await res.text();            // lấy text thuần
                        let data;
                        try {
                            data = text ? JSON.parse(text) : {success: res.ok, message: ''};
                        } catch {
                            data = {success: res.ok, message: text};
                        } // nếu không phải JSON, vẫn coi là ok nếu res.ok

                        if (data.success) {
                            Swal.fire({icon: 'success', title: 'Đã xóa vĩnh viễn!', showConfirmButton: false, timer: 1400});
                            setTimeout(() => {
                                const tab = document.querySelector('.nav-link.active');
                                if (tab?.id === 'deleted-tasks-tab')
                                    loadDeletedTasks();
                                else {
                                    saveAndReload();
                                }
                            }, 1400);
                        } else {
                            Swal.fire('Lỗi!', data.message || 'Xóa vĩnh viễn thất bại.', 'error');
                        }
                    })
                    .catch((err) => {
                        console.error('Network/parse error:', err);
                        Swal.fire('Lỗi!', 'Không thể kết nối tới server.', 'error');
                    });
        }
    });
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
            case 'permanent-delete':
                permanentDeleteTask(taskId);
                break;
            case 'archive':
                archiveTask(taskId);
                break;
            case 'remind':
                remindTask(taskId);
                break;
            case 'delete':
                deleteTask(taskId);
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
                        saveAndReload();
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

// Hàm lưu trạng thái vào localStorage
function saveViewState(view) {
    localStorage.setItem('taskViewMode', view);
}

function saveTabState(tab) {
    localStorage.setItem('taskTabState', tab);
}

// Hàm lấy trạng thái từ localStorage
function getViewState() {
    return localStorage.getItem('taskViewMode') || 'kanban';
}

function getTabState() {
    return localStorage.getItem('taskTabState') || 'active';
}

function switchView(viewType) {
    saveViewState(viewType);
    currentView = viewType;

    console.log('🔄 Switching to view:', viewType);

    // Lấy các containers
    const kanbanContainer = document.querySelector('.kanban-view-container');
    const listContainer = document.querySelector('.list-view-container');
    const calendarContainer = document.querySelector('.calendar-view-container');

    // Ẩn tất cả views
    if (kanbanContainer) {
        kanbanContainer.classList.remove('active');
        kanbanContainer.style.display = 'none';
    }
    if (listContainer) {
        listContainer.classList.remove('active');
        listContainer.style.display = 'none';
    }
    if (calendarContainer) {
        calendarContainer.classList.remove('active');
        calendarContainer.style.display = 'none';
    }

    // Hiển thị view được chọn
    if (viewType === 'kanban') {
        if (kanbanContainer) {
            kanbanContainer.classList.add('active');
            kanbanContainer.style.display = 'block';
        }
        console.log('✅ Kanban view activated');
    } else if (viewType === 'list') {
        if (listContainer) {
            listContainer.classList.add('active');
            listContainer.style.display = 'block';
        }
        // Initialize table sorting
        setTimeout(() => {
            initTableSorting();
            sortTable('trang_thai', 'asc');
        }, 100);
        console.log('✅ List view activated');
    } else if (viewType === 'calendar') {
        if (calendarContainer) {
            calendarContainer.classList.add('active');
            calendarContainer.style.display = 'block';
        }
        // Initialize calendar
        setTimeout(() => {
            if (typeof initCalendar === 'function') {
                initCalendar();
            } else {
                console.error('❌ initCalendar function not found');
            }
        }, 100);
        console.log('✅ Calendar view activated');
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

function getDatasetValue(row, field) {
    // field = "trang_thai" → chúng ta phải hỗ trợ cả 2 dạng:
    // data-trangthai  AND  data-trang-thai

    // 1) dạng không dấu gạch: "trangthai"
    let key1 = field.replace(/_/g, '');

    // 2) dạng camelCase do HTML chuyển: "trangThai"
    let parts = field.split('_');
    let key2 = parts[0] + parts.slice(1).map(
            p => p.charAt(0).toUpperCase() + p.slice(1)
    ).join('');

    return row.dataset[key1] || row.dataset[key2] || '';
}

function sortTable(field, order) {
    const tbody = document.getElementById('taskListTableBody');
    const rows = Array.from(tbody.querySelectorAll('tr'));

    rows.sort((a, b) => {
        let aVal = getDatasetValue(a, field);
        let bVal = getDatasetValue(b, field);

        // 🔥 Nếu đang sort theo trạng thái → dùng bảng thứ tự ưu tiên
        if (field === 'trang_thai') {

            const priority = {
                'Chưa bắt đầu': 2,
                'Đang thực hiện': 3,
                'Đã hoàn thành': 4,
                'Trễ hạn': 1
            };

            aVal = priority[aVal] || 99;
            bVal = priority[bVal] || 99;

            return order === 'asc' ? (aVal - bVal) : (bVal - aVal);
        }

        // 🔧 Nếu sort theo deadline → convert sang Date
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

// ====== DROPDOWN NAVIGATION HANDLERS ======
document.addEventListener('DOMContentLoaded', function () {
    // Tab Dropdown Handler
    const tabDropdownItems = document.querySelectorAll('#tabDropdown + .dropdown-menu .dropdown-item');
    const tabDropdownBtn = document.getElementById('tabDropdown');
    const tabDropdownIcon = document.getElementById('tabDropdownIcon');
    const tabDropdownText = document.getElementById('tabDropdownText');

    tabDropdownItems.forEach(item => {
        item.addEventListener('click', function (e) {
            e.preventDefault();

            const tab = this.getAttribute('data-tab');
            const icon = this.getAttribute('data-icon');
            const text = this.getAttribute('data-text');

            // Remove active từ tất cả items
            tabDropdownItems.forEach(i => i.classList.remove('active'));

            // Add active cho item được chọn
            this.classList.add('active');

            // Update button text và icon
            tabDropdownIcon.className = `fa-solid ${icon}`;
            tabDropdownText.textContent = text;

            // Save state
            saveTabState(tab);
            currentTabState = tab;

            // Load nội dung tương ứng
            if (tab === 'active') {
                document.getElementById('active-tasks').classList.add('show', 'active');
                document.getElementById('archived-tasks').classList.remove('show', 'active');
                document.getElementById('deleted-tasks').classList.remove('show', 'active');
            } else if (tab === 'archived') {
                document.getElementById('active-tasks').classList.remove('show', 'active');
                document.getElementById('archived-tasks').classList.add('show', 'active');
                document.getElementById('deleted-tasks').classList.remove('show', 'active');
                loadArchivedTasks();
            } else if (tab === 'deleted') {
                document.getElementById('active-tasks').classList.remove('show', 'active');
                document.getElementById('archived-tasks').classList.remove('show', 'active');
                document.getElementById('deleted-tasks').classList.add('show', 'active');
                loadDeletedTasks();
            }
        });
    });

    // View Mode Dropdown Handler
    const viewDropdownItems = document.querySelectorAll('#viewDropdown + .dropdown-menu .dropdown-item');
    const viewDropdownBtn = document.getElementById('viewDropdown');
    const viewDropdownIcon = document.getElementById('viewDropdownIcon');
    const viewDropdownText = document.getElementById('viewDropdownText');

    viewDropdownItems.forEach(item => {
        item.addEventListener('click', function (e) {
            e.preventDefault();

            const view = this.getAttribute('data-view');
            const icon = this.getAttribute('data-icon');
            const text = this.getAttribute('data-text');

            // Remove active từ tất cả items
            viewDropdownItems.forEach(i => i.classList.remove('active'));

            // Add active cho item được chọn
            this.classList.add('active');

            // Update button text và icon
            viewDropdownIcon.className = `fa-solid ${icon}`;
            viewDropdownText.textContent = text;

            // Switch view
            switchView(view);
        });
    });

    // Khôi phục trạng thái đã lưu khi load trang
    const savedView = getViewState();
    const savedTab = getTabState();

    // Khôi phục tab
    const savedTabItem = document.querySelector(`[data-tab="${savedTab}"]`);
    if (savedTabItem) {
        savedTabItem.click();
    }

    // Khôi phục view
    const savedViewItem = document.querySelector(`[data-view="${savedView}"]`);
    if (savedViewItem) {
        savedViewItem.click();
    }
});

// load trang đúng view
document.addEventListener('DOMContentLoaded', function () {
    // Khôi phục trạng thái đã lưu khi load trang
    const savedView = getViewState();
    const savedTab = getTabState();

    console.log('🔸 Khôi phục - savedTab:', savedTab, 'savedView:', savedView);

    // Khôi phục tab state
    currentTabState = savedTab;

    // Khôi phục tab UI
    const savedTabItem = document.querySelector(`[data-tab="${savedTab}"]`);
    if (savedTabItem) {
        // Update dropdown button
        const icon = savedTabItem.getAttribute('data-icon');
        const text = savedTabItem.getAttribute('data-text');
        document.getElementById('tabDropdownIcon').className = `fa-solid ${icon}`;
        document.getElementById('tabDropdownText').textContent = text;

        // Update active state
        document.querySelectorAll('#tabDropdown + .dropdown-menu .dropdown-item').forEach(i => i.classList.remove('active'));
        savedTabItem.classList.add('active');

        // Show correct tab content
        if (savedTab === 'active') {
            document.getElementById('active-tasks').classList.add('show', 'active');
            document.getElementById('archived-tasks').classList.remove('show', 'active');
            document.getElementById('deleted-tasks').classList.remove('show', 'active');
        } else if (savedTab === 'archived') {
            document.getElementById('active-tasks').classList.remove('show', 'active');
            document.getElementById('archived-tasks').classList.add('show', 'active');
            document.getElementById('deleted-tasks').classList.remove('show', 'active');
            loadArchivedTasks();
        } else if (savedTab === 'deleted') {
            document.getElementById('active-tasks').classList.remove('show', 'active');
            document.getElementById('archived-tasks').classList.remove('show', 'active');
            document.getElementById('deleted-tasks').classList.add('show', 'active');
            loadDeletedTasks();
        }
    }

    // Khôi phục view UI
    const savedViewItem = document.querySelector(`[data-view="${savedView}"]`);
    if (savedViewItem) {
        // Update dropdown button
        const icon = savedViewItem.getAttribute('data-icon');
        const text = savedViewItem.getAttribute('data-text');
        document.getElementById('viewDropdownIcon').className = `fa-solid ${icon}`;
        document.getElementById('viewDropdownText').textContent = text;

        // Update active state
        document.querySelectorAll('#viewDropdown + .dropdown-menu .dropdown-item').forEach(i => i.classList.remove('active'));
        savedViewItem.classList.add('active');
    }

    // Khôi phục dạng xem
    if (typeof switchView === 'function') {
        switchView(savedView);
    }
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
function updateToastZIndex() {
    var maxZ = 0;
    $('.modal.show, .modal-backdrop').each(function () {
        var z = parseInt($(this).css('z-index')) || 0;
        if (z > maxZ)
            maxZ = z;
    });

    var $container = $('#toastContainer');
    if ($container.length === 0) {
        $container = $('<div id="toastContainer" class="toast-container position-fixed bottom-0 end-0 p-3"></div>');
        $('body').append($container);
    }

    // đảm bảo toast luôn trên modal/backdrop
    var newZ = Math.max(maxZ + 30, 20000); // chọn giá trị đủ lớn
    $container.css('z-index', newZ);

    return newZ;
}

// cập nhật khi modal mở/đóng
document.addEventListener('shown.bs.modal', updateToastZIndex);
document.addEventListener('hidden.bs.modal', updateToastZIndex);

function showToast(type, message) {
    // đảm bảo container có z-index cao hơn modal/backdrop
    var z = updateToastZIndex();

    var map = {
        success: 'toastSuccess',
        error: 'toastError',
        info: 'toastInfo',
        warning: 'toastWarning'
    };
    var toastId = map[type] || 'toastInfo';
    var $container = $('#toastContainer');

    // tạo toast element nếu chưa có
    var $toast = $('#' + toastId);
    if ($toast.length === 0) {
        var toastHtml =
                '<div id="' + toastId + '" class="toast align-items-center border-0 mb-2" role="alert" aria-live="assertive" aria-atomic="true">' +
                '<div class="d-flex">' +
                '<div class="toast-body"></div>' +
                '<button type="button" class="btn-close me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>' +
                '</div>' +
                '</div>';
        $toast = $(toastHtml);
        // đảm bảo toast nằm trong container có z-index cao
        $container.append($toast);
    } else {
        // nếu đã tồn tại ở body do phiên bản cũ, di chuyển vào container
        if ($toast.parent()[0] !== $container[0]) {
            $container.append($toast);
        }
    }

    // đặt nội dung và z-index inline phòng trường hợp cha không áp dụng
    $toast.find('.toast-body').text(message);
    $toast.attr('style',
            'background-color: #fbbf24 !important;' + // màu vàng nhạt
            'color: #000 !important;' + // chữ đen
            'font-weight: 600 !important;' +
            'z-index: ' + (z + 10) + ' !important;'
            );

    var bsToast = new bootstrap.Toast($toast[0], {delay: 2500, autohide: true});
    bsToast.show();
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
document.addEventListener("DOMContentLoaded", function () {
    const btn = document.getElementById("btnUserGiaHan");
    const form = document.getElementById("userGiaHanForm");
    const confirm = document.getElementById("btnUserConfirmGiaHan");
    const cancel = document.getElementById("btnUserCancelGiaHan");

    if (!btn)
        return;  // user không có form admin → không chạy đoạn này

    btn.addEventListener("click", () => {
        form.style.display = form.style.display === "none" ? "block" : "none";
    });

    cancel.addEventListener("click", () => form.style.display = "none");

    confirm.addEventListener("click", function () {
        const taskId = document.querySelector('[name="task_id"]').value;
        const date = document.getElementById("userNgayGiaHan").value;
        const lydo = document.getElementById("userLyDoGiaHan").value;

        fetch('./suaCongviec', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: new URLSearchParams({
                action: 'extend',
                task_id: taskId,
                ngay_gia_han: date,
                ly_do_gia_han: lydo
            })
        })
                .then(r => r.json())
                .then(d => {
                    if (d.success) {
                        showToast('success', 'Yêu cầu gia hạn đã gửi');
                        form.style.display = "none";
                    } else
                        showToast('error', d.message);
                });
    });
});
document.addEventListener("click", function (e) {
    // đảm bảo ngăn submit form mặc định và xử lý an toàn
    if (e.target && e.target.id === "btnApproveExtend") {
        e.preventDefault();
        const taskIdEl = document.querySelector('[name="task_id"]');
        const taskId = taskIdEl ? taskIdEl.value : null;
        const newDeadlineEl = document.getElementById('requestedExtendDate');
        const newDeadline = newDeadlineEl ? newDeadlineEl.value : null;

        if (!taskId || !newDeadline) {
            showToast('error', 'Không tìm thấy ID hoặc ngày gia hạn để duyệt.');
            return;
        }

        fetch('./suaCongviec', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: new URLSearchParams({
                action: 'approveextend',
                task_id: String(taskId),
                new_deadline: String(newDeadline)
            }).toString()
        })
                .then(r => r.json())
                .then(d => {
                    if (d && d.success) {
                        showToast('success', 'Đã duyệt gia hạn');
                        // Option A: reload an toàn
                        setTimeout(() => {
                            window.location.href = '/ICSS/dsCongviec';
                        }, 700);
                    } else {
                        showToast('error', d && d.message ? d.message : 'Duyệt thất bại');
                    }
                })
                .catch(err => {
                    console.error(err);
                    showToast('error', 'Lỗi kết nối server.');
                });
    }
});
document.addEventListener("DOMContentLoaded", function () {
    const btn = document.getElementById("btnAdminGiaHan");
    const form = document.getElementById("adminGiaHanForm");
    const confirm = document.getElementById("btnAdminXacNhanGiaHan");

    if (!btn)
        return; // admin không có form user → không chạy đoạn kia

    btn.addEventListener("click", () => {
        form.style.display = form.style.display === "none" ? "block" : "none";
    });

    confirm.addEventListener("click", function () {
        const taskId = document.querySelector('[name="task_id"]').value;
        const date = document.getElementById("adminNgayGiaHan").value;

        fetch('./suaCongviec', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: new URLSearchParams({
                action: 'approveextend',
                task_id: taskId,
                new_deadline: date
            })
        })
                .then(r => r.json())
                .then(d => {
                    if (d.success) {
                        showToast('success', 'Đã duyệt gia hạn');
                        window.location.href = '/ICSS/dsCongviec';
                    } else
                        showToast('error', d.message);
                });
    });
});