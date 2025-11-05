
// Hiển thị danh sách file ngay khi chọn
document.getElementById('taskFiles').addEventListener('change', function () {
    let files = this.files;
    let list = "";
    for (let i = 0; i < files.length; i++) {
        list += "📄 " + files[i].name + "<br>";
    }
    document.getElementById('taskFileList').innerHTML = list || "Chưa có file nào được chọn";
});

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



document.addEventListener("DOMContentLoaded", function () {
    const btnSave = document.getElementById('btnSaveTask');
    btnSave.addEventListener('click', function () {
        const form = document.getElementById('formTaskDetail');
        const formData = new FormData(form);

        fetch('./suaCongviec', {
            method: 'POST',
            body: formData
        })
                .then(res => res.json())
                .then(data => {
                    if (data.success) {
                        showToast('success', '✅ Cập nhật công việc thành công!');

                        // ✅ Đóng modal TaskDetail
                        const modalEl = document.getElementById('modalTaskDetail');
                        const modalInstance = bootstrap.Modal.getInstance(modalEl);
                        if (modalInstance) {
                            modalInstance.hide();
                        } else {
                            // fallback nếu instance chưa được lấy ra
                            const closeBtn = modalEl.querySelector('.btn-close');
                            if (closeBtn)
                                closeBtn.click();
                        }

                        // ✅ Sau khi modal đóng 300ms thì redirect
                        setTimeout(() => {
                            window.location.href = './dsCongviecNV';
                        }, 300);

                    } else {
                        showToast('error', data.message || '❌ Lỗi khi cập nhật');
                    }
                })
                .catch(err => {
                    console.error(err);
                    showToast('error', '❌ Lỗi kết nối server');
                });
    });
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
                document.querySelector('#phongban select[name="ten_phong_ban"]').innerHTML = finalHTML;
            });
    // Load danh sách nhân viên (giao & nhận)
    fetch('./apiNhanvien')
            .then(res => res.text())
            .then(html => {
                //document.querySelector('#modalTaskDetail select[name="ten_nguoi_giao"]').innerHTML = html;
                //document.querySelector('#modalTaskDetail select[name="ten_nguoi_nhan"]').innerHTML = html;
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
        const nguoiNhan = button.getAttribute("data-ten_nguoi_nhan") || "";
        const phongban = button.getAttribute("data-ten_phong_ban") || "";
        const trangthai = button.getAttribute("data-trang-thai") || "";
        const tailieu = button.getAttribute("data-tai_lieu_cv") || "";
        // Gán dữ liệu
        modal.querySelector('[name="task_id"]').value = id;
        modal.querySelector('[name="ten_cong_viec"]').value = tenCV;
        modal.querySelector('[name="mo_ta"]').value = moTa;
        modal.querySelector('[name="han_hoan_thanh"]').value = hanHT;
        selectOptionByText(modal.querySelector('[name="muc_do_uu_tien"]'), uuTien);
        //selectOptionByText(modal.querySelector('[name="ten_nguoi_giao"]'), nguoiGiao);
        modal.querySelector('[name="ten_nguoi_giao"]').value = nguoiGiao;
        modal.querySelector('[name="ten_nguoi_nhan"]').value = nguoiNhan;
        selectOptionByText(modal.querySelector('[name="ten_phong_ban"]'), phongban);
        selectOptionByText(modal.querySelector('[name="trang_thai"]'), trangthai);
        modal.querySelector('[name="tai_lieu_cv"]').value = tailieu;

        let fileTaiLieu = button.getAttribute("data-file_tai_lieu") || "";
        if (fileTaiLieu.toLowerCase() === "null") {
            fileTaiLieu = "";
        }

        const fileListDiv = modal.querySelector("#taskFileList");
        if (!fileTaiLieu && taskFiles.files.length === 0) {
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

        // Mở lại tab đầu tiên khi show modal
        const tabTrigger = modal.querySelector('#tab-task-info');
        if (tabTrigger)
            new bootstrap.Tab(tabTrigger).show();
    });
});



$('#btnFilter').on('click', function () {
    const keyword = $('input[name="keyword"]').val();
    const trangThai = $('select[name="trangThai"]').val();

    $.ajax({
        url: './locCongviec',
        type: 'POST',
        data: {
            keyword: keyword,
            trang_thai: trangThai
        },
        success: function (html) {
            $('.kanban-board').replaceWith(html); // Thay thế toàn bộ bảng Kanban
        },
        error: function () {
            $('.kanban-board').html("<div class='text-danger text-center'>Lỗi khi lọc công việc</div>");
        }
    });
});
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

function calcProgressPercent() {
    if (!processSteps || processSteps.length === 0)
        return 0;
    var done = processSteps.filter(s => s.status === "Đã hoàn thành").length;
    return Math.round((done / processSteps.length) * 100);
}

// Hiển thị các bước quy trình với nút chỉnh sửa trạng thái (logic đẹp mắt, chỉ 1 nút)
function renderProcessSteps() {
    var percent = calcProgressPercent();
    var barClass = percent === 100 ? "bg-success" : "bg-warning";
    $('#taskProgressBar').css('width', percent + '%').removeClass('bg-warning bg-success').addClass(barClass).text(percent + '%');

    // 👇 Gửi phần trăm về server
    var taskId = $('#taskId').val(); // đảm bảo có input ẩn chứa id công việc
    if (taskId) {
        $.ajax({
            url: 'capnhatTiendo', // servlet xử lý
            method: 'POST',
            data: {
                cong_viec_id: taskId,
                phan_tram: percent
            },
            success: function (res) {
                console.log("Cập nhật tiến độ thành công");
            },
            error: function () {
                console.error("Lỗi khi cập nhật tiến độ");
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

            // Nút chỉnh sửa
            var editBtn =
                    '<button class="btn btn-sm btn-outline-secondary me-1" onclick="showEditStepModal(' + idx + ')">' +
                    '<i class="fa-solid fa-pen"></i> Chỉnh sửa' +
                    '</button>';

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

    if (!data || data.length === 0) {
        var emptyLi = document.createElement("li");
        emptyLi.className = "list-group-item text-muted";
        emptyLi.textContent = "Chưa có đánh giá nào.";
        list.appendChild(emptyLi);
        return;
    }

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


// Modal chỉnh sửa trạng thái bước quy trình
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
            '<input type="text" class="form-control" name="stepName" value="' + step.name + '" disabled>' +
            '</div>' +
            '<div class="mb-2">' +
            '<label class="form-label">Mô tả</label>' +
            '<textarea class="form-control" name="stepDesc" rows="2" disabled>' + (step.desc || '') + '</textarea>' +
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
            '<div class="col">' +
            '<label class="form-label">Ngày bắt đầu</label>' +
            '<input type="date" class="form-control" name="stepStart" value="' + (step.start || '') + '" disabled>' +
            '</div>' +
            '<div class="col">' +
            '<label class="form-label">Ngày kết thúc</label>' +
            '<input type="date" class="form-control" name="stepEnd" value="' + (step.end || '') + '" disabled>' +
            '</div>' +
            '</div>' +
            '</div>' +
            '<div class="modal-footer">' +
            '<button type="submit" class="btn btn-primary rounded-pill">Cập nhật</button>' +
            '<button type="button" class="btn btn-secondary rounded-pill" data-bs-dismiss="modal">Huỷ</button>' +
            '</div>' +
            '</form>' +
            '</div>' +
            '</div>';
    // Xóa modal cũ nếu có
    $('#modalEditStepStatus').remove();
    // Thêm modal vào body
    $('body').append(modalHtml);
    // Hiển thị modal
    var modal = new bootstrap.Modal(document.getElementById('modalEditStepStatus'));
    modal.show();
    // Xử lý submit cập nhật
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
        // TODO: AJAX cập nhật trạng thái bước quy trình cho công việc
        const taskId = document.getElementById("taskId").value;
        $.ajax({
            url: './apiTaskSteps',
            method: 'POST', // hoặc 'PUT' tùy backend bạn thiết kế
            contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
            data: {
                step_id: processSteps[idx].id,
                name: processSteps[idx].name,
                desc: processSteps[idx].desc,
                status: processSteps[idx].status,
                start: processSteps[idx].start,
                end: processSteps[idx].end
            },
            success: function () {
                console.log("Cập nhật thành công");
            },
            error: function () {
                showToast('error', '✅ Cập nhật thất bại!');
            }
        });
    });
    // Khi đóng modal thì xóa khỏi DOM
    $('#modalEditStepStatus').on('hidden.bs.modal', function () {
        $('#modalEditStepStatus').remove();
    });
}

$('#modalTaskDetail').on('show.bs.modal', function () {
    renderProcessSteps();
});

document.addEventListener("DOMContentLoaded", function () {
    const tabProgress = document.getElementById("tab-task-progress");

    tabProgress.addEventListener("shown.bs.tab", function () {
        const taskId = document.getElementById("taskId").value;

        $.ajax({
            url: './apiTaskSteps?task_id=' + taskId,
            method: 'GET',
            success: function (data) {
                processSteps = data;
                renderProcessSteps();
            },
            error: function () {
                showToast('error', 'Không thể tải quy trinh!');
            }
        });
    });

    const tabReview = document.getElementById("tab-task-review");
    if (tabReview) {
        tabReview.addEventListener("shown.bs.tab", function () {
            const taskId = document.getElementById("taskId").value;

            $.ajax({
                url: './apiDanhgiaCV?taskId=' + taskId,
                method: 'GET',
                success: function (data) {
                    renderTaskReviews(data);
                },
                error: function () {
                    showToast('error', 'Không thể tải đánh giá!');
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
                showToast('error', 'Không thể tải lại danh sách đánh giá!');
            });
}

function updateAllTaskProgressBars() {
    document.querySelectorAll('.task-progress-bar').forEach(function (bar) {
        const taskId = bar.getAttribute('data-task-id');
        fetch('./apiTaskSteps?task_id=' + encodeURIComponent(taskId))
                .then(res => res.json())
                .then(processSteps => {
                    const percent = calcProgressPercent(processSteps);
                    let barClass = "bg-warning";
                    if (percent === 100)
                        barClass = "bg-success";
                    else if (percent === 0)
                        barClass = "bg-secondary";

                    bar.style.width = percent + "%";
                    bar.textContent = percent + "%";
                    bar.className = "progress-bar task-progress-bar " + barClass;
                })
                .catch(err => {
                    console.error("Lỗi khi tải bước quy trình:", err);
                });
    });
}
document.addEventListener("DOMContentLoaded", function () {
    updateAllTaskProgressBars();
});



// ====== XỬ LÝ NHẮC NHỞ CÔNG VIỆC ======
document.addEventListener('DOMContentLoaded', function () {
    // Xử lý khi người dùng click vào task có chuông nhắc nhở
    document.addEventListener('click', function (e) {
        const taskCard = e.target.closest('.kanban-task');
        if (taskCard && taskCard.querySelector('.task-reminder-bell')) {
            const taskId = taskCard.getAttribute('data-id');

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
                    setTimeout(() => location.reload(), 1200);
                } else {
                    Swal.fire('Lỗi!', data.message || 'Đọc thất bại.', 'error');
                }
            })
            .catch(err => {
                console.error(err);
                Swal.fire('Lỗi!', 'Không thể kết nối tới server.', 'error');
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

    // Thêm keyboard navigation cho tabs
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Tab' && e.target.classList.contains('nav-link')) {
            e.preventDefault();
        }
    });
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
        body: 'trang_thai=Lưu trữ&view=archived'
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
        body: 'trang_thai=Đã xóa&view=deleted'
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
    // Trong thực tế, bạn sẽ parse HTML response và phân chia theo trạng thái
    resetArchivedPlaceholders();
    showToast('info', 'Đã tải công việc lưu trữ');
}

// ====== RENDER DELETED TASKS ======
function renderDeletedTasks(html) {
    // Placeholder cho việc render deleted tasks
    // Trong thực tế, bạn sẽ parse HTML response và phân chia theo trạng thái
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

