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
            .then(res => res.text())
            .then(html => {
                document.querySelectorAll('#nguoiNhanSelect').forEach(el => el.innerHTML = html);
                // (hoặc document.getElementById("nguoiNhanSelect").innerHTML = html;)
            });
    fetch('./apiNhanvien')
            .then(res => res.text())
            .then(html => {
                document.querySelectorAll('#nguoiNhanSelect2').forEach(el => el.innerHTML = html);
                // (hoặc document.getElementById("nguoiNhanSelect").innerHTML = html;)
            });
    fetch('./apiNhanvien')
            .then(res => res.text())
            .then(html => {
                document.querySelector('#modalTaskDetail select[name="ten_nguoi_giao"]').innerHTML = html;
                //document.querySelector('#modalTaskDetail select[name="ten_nguoi_nhan"]').innerHTML = html;
                document.querySelector('#modalTaskDetail select[name="ten_nguoi_danh_gia"]').innerHTML = html;
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
        const hanHT = button.getAttribute("data-han") || "";
        const uuTien = button.getAttribute("data-uu-tien") || "";
        const nguoiGiao = button.getAttribute("data-ten_nguoi_giao") || "";
        const nguoiNhan = button.getAttribute("data-ten_nguoi_nhan") || ""; // nhiều tên, ngăn cách dấu phẩy
        const phongban = button.getAttribute("data-ten_phong_ban") || "";
        const trangthai = button.getAttribute("data-trang-thai") || "";
        const tailieu = button.getAttribute("data-tai_lieu_cv") || "";

        // Gán dữ liệu cơ bản
        modal.querySelector('[name="task_id"]').value = id;
        modal.querySelector('[name="ten_cong_viec"]').value = tenCV;
        modal.querySelector('[name="mo_ta"]').value = moTa;
        modal.querySelector('[name="han_hoan_thanh"]').value = hanHT;
        selectOptionByText(modal.querySelector('[name="muc_do_uu_tien"]'), uuTien);
        selectOptionByText(modal.querySelector('[name="ten_nguoi_giao"]'), nguoiGiao);
        // ❌ bỏ dòng selectOptionByText cho người nhận
        selectOptionByText(modal.querySelector('[name="ten_phong_ban"]'), phongban);
        selectOptionByText(modal.querySelector('[name="trang_thai"]'), trangthai);
        modal.querySelector('[name="tai_lieu_cv"]').value = tailieu;

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
                        body: "file=" + encodeURIComponent(path) + "&taskId=" + encodeURIComponent(taskId) + "&projectId=" + encodeURIComponent(PROJECT_ID)
                    })
                            .then(res => res.json())
                            .then(data => {
                                if (data.success) {
                                    fileItem.remove();

                                    if (fileListDiv.children.length === 0) {
                                        fileListDiv.innerHTML = "Chưa có file nào được đính kèm";
                                    }

                                    showToast('success', '🗑️ File đã được xoá');
                                    window.location.href = "<%=request.getContextPath()%>/dsCongviecDuan?projectId=" + data.projectId;
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


$('#taskForm').on('submit', function (e) {
    e.preventDefault(); // Ngăn form submit mặc định

    const taskId = $('#taskId').val(); // nếu có ID thì là sửa, không thì là thêm
    const formData = new FormData(this); // lấy dữ liệu form bao gồm cả file

    formData.append("du_an_id", PROJECT_ID);

    const url = taskId ? './capNhatCongviec' : './themCongviec';

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

    $.ajax({
        url: './locCongviec',
        type: 'POST',
        data: {
            keyword: keyword,
            phong_ban: phongBan,
            trang_thai: trangThai,
            projectId: PROJECT_ID
        },
        dataType: 'html',
        beforeSend: function () {
            $btn.prop('disabled', true).data('orig-text', $btn.html()).html('Đang lọc...');
        },
        success: function (html) {
            if (html && $.trim(html).length > 0) {
                $('.kanban-board').replaceWith(html);
                showToast('success', 'Đã áp dụng bộ lọc.');
            } else {
                $('.kanban-board').html('<div class="text-center text-muted p-3">Không có dữ liệu phù hợp</div>');
                showToast('info', 'Không tìm thấy kết quả phù hợp.');
            }
        },
        error: function () {
            $('.kanban-board').html('<div class="text-danger text-center p-3">Lỗi khi lọc công việc</div>');
            showToast('error', 'Lỗi khi lọc công việc.');
        },
        complete: function () {
            $btn.prop('disabled', false).html($btn.data('orig-text') || 'Lọc');
        }
    });
});

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
            var deleteBtn =
                    '<button class="btn btn-sm btn-danger ms-1" onclick="removeProcessStep(' + idx + ')">' +
                    '<i class="fa-solid fa-trash"></i></button>';

            var html = '<li class="list-group-item d-flex justify-content-between align-items-center">' +
                    '<div>' +
                    '<b>' + step.name + '</b> ' +
                    '<span class="badge ' + badgeClass + '">' + step.status + '</span><br>' +
                    '<small>' + (step.desc ? step.desc : '') + '</small>' +
                    '<div class="text-muted small">Từ ' + (step.start || '-') + ' đến ' + (step.end || '-') + '</div>' +
                    '</div>' +
                    '<div>' + editBtn + deleteBtn + '</div>' +
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
            '<input type="text" class="form-control" name="stepName" value="' + step.name + '" required>' +
            '</div>' +
            '<div class="mb-2">' +
            '<label class="form-label">Mô tả</label>' +
            '<textarea class="form-control" name="stepDesc" rows="2">' + (step.desc || '') + '</textarea>' +
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
            '<input type="date" class="form-control" name="stepStart" value="' + (step.start || '') + '"></div>' +
            '<div class="col"><label class="form-label">Ngày kết thúc</label>' +
            '<input type="date" class="form-control" name="stepEnd" value="' + (step.end || '') + '"></div>' +
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

window.removeProcessStep = function (idx) {
    var step = processSteps[idx];
    if (!step || !step.id) {
        showToast('error', 'Không thể xác định bước cần xóa.');
        return;
    }
    if (confirm("Bạn có chắc chắn muốn xóa bước này không?")) {
        $.ajax({
            url: './xoaQuytrinh',
            method: 'POST',
            data: {action: 'delete', step_id: step.id},
            success: function () {
                processSteps.splice(idx, 1);
                renderProcessSteps();
                showToast('success', 'Đã xóa bước thành công.');
            },
            error: function () {
                showToast('error', 'Xóa thất bại. Vui lòng thử lại.');
            }
        });
    }
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

$('#modalTaskDetail').on('show.bs.modal', function () {
    renderProcessSteps();
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

document.getElementById("btnAddReview").addEventListener("click", function () {
    var taskId = document.getElementById("taskId").value;
    var reviewerSelect = document.querySelector('select[name="ten_nguoi_danh_gia"]');
    var reviewerId = reviewerSelect.value;
    var comment = document.getElementById("reviewComment").value.trim();

    if (!reviewerId || !comment) {
        showToast('error', 'Vui lòng chọn người đánh giá và nhập nhận xét.');
        return;
    }
    if (!confirm("Bạn có chắc chắn muốn thêm đánh giá này không?")) {
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
            .then(function (res) {
                return res.json();
            })
            .then(function (data) {
                if (data.success) {
                    showToast('success', 'Thêm đánh giá thành công!');
                    document.getElementById("reviewComment").value = "";
                    setTimeout(function () {
                        loadTaskReviews(taskId);
                    }, 300);
                } else {
                    showToast('error', 'Thêm thất bại: ' + (data.message || ''));
                }
            })
            .catch(function () {
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