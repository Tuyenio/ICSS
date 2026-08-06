function hasPermission(code) {
    return USER_PERMISSIONS && USER_PERMISSIONS.includes(code);
}

document.addEventListener("DOMContentLoaded", function () {

    /* ======================================================
       🔹 1. QUYỀN XEM BÁO CÁO (xem_baocao)
       ====================================================== */
    if (!hasPermission("xem_baocao")) {

        $(".main-box").html(`
            <div class="text-center py-5">
                <i class="fa-solid fa-ban fa-3x text-danger mb-3"></i>
                <h4 class="text-danger">Bạn không có quyền xem báo cáo</h4>
                <p class="text-muted">Vui lòng liên hệ quản trị viên để được cấp quyền.</p>
            </div>
        `);

        return; // không cho chạy các quyền dưới
    }

    /* ======================================================
       🔹 2. QUYỀN LÀM MỚI DỮ LIỆU
       ====================================================== */
    if (!hasPermission("xem_baocao")) {
        $("#refreshData").hide();
    }

    /* ======================================================
       🔹 3. QUYỀN XUẤT FILE (xuat_baocao)
       ====================================================== */
    if (!hasPermission("xuat_baocao")) {

        // Ẩn nút xuất báo cáo
        $(".btn-action-success").hide();  

        // Ẩn nút Lưu trong modal Export
        $("#modalExportReport button[type=submit]").hide();
    }

    /* ======================================================
       🔹 4. QUYỀN XEM CHI TIẾT TASK (click badge)
       ====================================================== */
    if (!hasPermission("xem_baocao")) {
        $(".task-detail").css("pointer-events", "none")
            .removeClass("text-primary")
            .addClass("text-muted");
    }

    /* ======================================================
       🔹 5. (TÙY CHỌN) Ẩn chart nếu không có quyền xem báo cáo
       ====================================================== */
    if (!hasPermission("xem_baocao")) {
        $("#pieChart").parent().hide();
        $("#barChart").parent().hide();
    }

});
// Gắn reportType theo tab đang active & kiểm tra đơn giản
(function () {
    var form = document.getElementById('formExportReport');
    if (!form) return; // Nếu không tìm thấy form thì không làm gì
    
    form.addEventListener('submit', function (e) {
        // Kiểm tra date range đã được chọn chưa
        var tuNgay = document.getElementById('exportTuNgay');
        var denNgay = document.getElementById('exportDenNgay');
        
        if (!tuNgay || !denNgay || !tuNgay.value || !denNgay.value) {
            e.preventDefault();
            showToast('error', 'Vui lòng chọn khoảng thời gian để xuất báo cáo.');
            return false;
        }
        
        // Kiểm tra ngày kết thúc phải sau ngày bắt đầu
        if (tuNgay.value > denNgay.value) {
            e.preventDefault();
            showToast('error', 'Ngày kết thúc phải sau hoặc bằng ngày bắt đầu.');
            return false;
        }
        
        // Nếu tất cả hợp lệ, cho phép submit
        return true;
    });
})();

// Validation cho form export DỰ ÁN
(function () {
    var form = document.getElementById('formExportProjectReport');
    if (!form) return;
    
    form.addEventListener('submit', function (e) {
        var tuNgay = document.getElementById('exportProjectTuNgay');
        var denNgay = document.getElementById('exportProjectDenNgay');
        
        if (!tuNgay || !denNgay || !tuNgay.value || !denNgay.value) {
            e.preventDefault();
            showToast('error', 'Vui lòng chọn khoảng thời gian để xuất báo cáo dự án.');
            return false;
        }
        
        if (tuNgay.value > denNgay.value) {
            e.preventDefault();
            showToast('error', 'Ngày kết thúc phải sau hoặc bằng ngày bắt đầu.');
            return false;
        }
        
        return true;
    });
})();

// Hàm showToast bạn đang dùng (giả sử đã có)
function showToast(type, message) {
    var map = {success: '#toastSuccess', error: '#toastError', info: '#toastInfo', warning: '#toastWarning'};
    var id = map[type] || '#toastInfo';
    if (!$(id).length) {
        var html = '<div id="' + id.substring(1) + '" class="toast align-items-center border-0 position-fixed bottom-0 end-0 m-3" role="alert" aria-live="assertive" aria-atomic="true"><div class="d-flex"><div class="toast-body"></div><button type="button" class="btn-close me-2 m-auto" data-bs-dismiss="toast"></button></div></div>';
        $('body').append(html);
    }
    $(id).find('.toast-body').text(message);
    new bootstrap.Toast($(id)[0], {delay: 2500, autohide: true}).show();
}

// Debug dữ liệu
console.log('Pie Chart Data:', pieChartData);
console.log('Bar Chart Data:', barChartData);

// Khởi tạo Date Range Picker
$(function () {
    var tuNgay = $('#tuNgayHidden').val();
    var denNgay = $('#denNgayHidden').val();

    var startDate = tuNgay ? moment(tuNgay) : moment().startOf('month');
    var endDate = denNgay ? moment(denNgay) : moment().endOf('month');

    $('#dateRangeFilter').daterangepicker({
        startDate: startDate,
        endDate: endDate,
        locale: {
            format: 'DD/MM/YYYY',
            separator: ' - ',
            applyLabel: 'Áp dụng',
            cancelLabel: 'Hủy',
            fromLabel: 'Từ',
            toLabel: 'Đến',
            customRangeLabel: 'Tùy chọn',
            weekLabel: 'T',
            daysOfWeek: ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'],
            monthNames: ['Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
                'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'],
            firstDay: 1
        },
        ranges: {
            'Hôm nay': [moment(), moment()],
            'Hôm qua': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
            '7 ngày qua': [moment().subtract(6, 'days'), moment()],
            '30 ngày qua': [moment().subtract(29, 'days'), moment()],
            'Tháng này': [moment().startOf('month'), moment().endOf('month')],
            'Tháng trước': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
        },
        alwaysShowCalendars: true,
        autoApply: false
    }, function (start, end, label) {
        console.log('Date range selected:', start.format('YYYY-MM-DD'), 'to', end.format('YYYY-MM-DD'));
    });

    // Khởi tạo Date Range Picker cho modal xuất báo cáo
    $('#dateRangeExport').daterangepicker({
        startDate: moment().startOf('month'),
        endDate: moment().endOf('month'),
        locale: {
            format: 'DD/MM/YYYY',
            separator: ' - ',
            applyLabel: 'Áp dụng',
            cancelLabel: 'Hủy',
            fromLabel: 'Từ',
            toLabel: 'Đến',
            customRangeLabel: 'Tùy chọn',
            weekLabel: 'T',
            daysOfWeek: ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'],
            monthNames: ['Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
                'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'],
            firstDay: 1
        },
        ranges: {
            'Hôm nay': [moment(), moment()],
            'Hôm qua': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
            '7 ngày qua': [moment().subtract(6, 'days'), moment()],
            '30 ngày qua': [moment().subtract(29, 'days'), moment()],
            'Tháng này': [moment().startOf('month'), moment().endOf('month')],
            'Tháng trước': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')],
            'Quý này': [moment().startOf('quarter'), moment().endOf('quarter')],
            'Năm nay': [moment().startOf('year'), moment().endOf('year')]
        },
        alwaysShowCalendars: true,
        autoApply: false
    });

    // Cập nhật hidden fields khi chọn date range trong modal
    $('#dateRangeExport').on('apply.daterangepicker', function (ev, picker) {
        $('#exportTuNgay').val(picker.startDate.format('YYYY-MM-DD'));
        $('#exportDenNgay').val(picker.endDate.format('YYYY-MM-DD'));
    });

    // Khởi tạo Date Range Picker cho modal xuất báo cáo DỰ ÁN
    $('#dateRangeExportProject').daterangepicker({
        startDate: moment().startOf('month'),
        endDate: moment().endOf('month'),
        locale: {
            format: 'DD/MM/YYYY',
            separator: ' - ',
            applyLabel: 'Áp dụng',
            cancelLabel: 'Hủy',
            fromLabel: 'Từ',
            toLabel: 'Đến',
            customRangeLabel: 'Tùy chọn',
            weekLabel: 'T',
            daysOfWeek: ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'],
            monthNames: ['Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
                'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'],
            firstDay: 1
        },
        ranges: {
            'Hôm nay': [moment(), moment()],
            'Hôm qua': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
            '7 ngày qua': [moment().subtract(6, 'days'), moment()],
            '30 ngày qua': [moment().subtract(29, 'days'), moment()],
            'Tháng này': [moment().startOf('month'), moment().endOf('month')],
            'Tháng trước': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')],
            'Quý này': [moment().startOf('quarter'), moment().endOf('quarter')],
            'Năm nay': [moment().startOf('year'), moment().endOf('year')]
        },
        alwaysShowCalendars: true,
        autoApply: false
    });

    // Cập nhật hidden fields khi chọn date range trong modal DỰ ÁN
    $('#dateRangeExportProject').on('apply.daterangepicker', function (ev, picker) {
        $('#exportProjectTuNgay').val(picker.startDate.format('YYYY-MM-DD'));
        $('#exportProjectDenNgay').val(picker.endDate.format('YYYY-MM-DD'));
    });

    // Xử lý khi chọn khoảng thời gian
    $('#dateRangeFilter').on('apply.daterangepicker', function (ev, picker) {
        var tuNgay = picker.startDate.format('YYYY-MM-DD');
        var denNgay = picker.endDate.format('YYYY-MM-DD');
        var phongBan = $('#phongBanFilter').val();

        // Cập nhật URL và reload trang
        var url = window.location.pathname + '?tu_ngay=' + tuNgay + '&den_ngay=' + denNgay;
        if (phongBan) {
            url += '&phong_ban=' + encodeURIComponent(phongBan);
        }
        window.location.href = url;
    });

    // Nút đặt lại bộ lọc
    $('#resetFilter').click(function () {
        // Xóa tất cả filter: quay lại URL gốc không có tham số
        window.location.href = window.location.pathname;
    });
});

// Chart.js implementation
$(function () {
    // Pie Chart - Trạng thái công việc
    // Pie Chart - Trạng thái công việc
    if (pieChartData && pieChartData.labels && pieChartData.labels.length > 0) {
        console.log("Pie labels raw:", pieChartData.labels);

        // Map màu tương ứng chính xác với nhãn tiếng Việt
        const colorMap = {
            'Chưa bắt đầu': '#b0b0b0', // Xám
            'Đang thực hiện': '#facc15', // Vàng
            'Đã hoàn thành': '#22c55e', // Xanh lá
            'Trễ hạn': '#ef4444'         // Đỏ
        };

        // Duyệt qua từng label để lấy đúng màu theo tên
        const colors = pieChartData.labels.map(label => {
            const cleanLabel = label.trim(); // loại bỏ khoảng trắng thừa
            return colorMap[cleanLabel] || '#6b7280'; // nếu label lạ => xám nhạt
        });

        // Khởi tạo biểu đồ
        new Chart(document.getElementById('pieChart'), {
            type: 'pie',
            data: {
                labels: pieChartData.labels,
                datasets: [{
                        data: pieChartData.data,
                        backgroundColor: colors
                    }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {position: 'bottom'},
                    tooltip: {
                        callbacks: {
                            label: function (context) {
                                const label = context.label || '';
                                const value = context.parsed || 0;
                                return `${label}: ${value}`;
                            }
                        }
                    }
                }
            }
        });
    } else {
        document.getElementById('pieChart').parentElement.innerHTML =
                '<div class="text-center p-4"><i class="fa-solid fa-chart-pie fa-3x text-muted mb-3"></i><br><span class="text-muted">Không có dữ liệu để hiển thị</span></div>';
    }


    // Bar Chart - Tiến độ phòng ban
    if (barChartData && barChartData.labels && barChartData.labels.length > 0) {
        new Chart(document.getElementById('barChart'), {
            type: 'bar',
            data: {
                labels: barChartData.labels,
                datasets: [{
                        label: 'Tiến độ (%)',
                        data: barChartData.data,
                        backgroundColor: ['#0d6efd', '#198754', '#ffc107', '#dc3545', '#6f42c1', '#20c997']
                    }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {display: false}
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        max: 100,
                        ticks: {
                            callback: function (value) {
                                return value + '%';
                            }
                        }
                    }
                }
            }
        });
    } else {
        // Hiển thị thông báo khi không có dữ liệu
        document.getElementById('barChart').parentElement.innerHTML =
                '<div class="text-center p-4"><i class="fa-solid fa-chart-bar fa-3x text-muted mb-3"></i><br><span class="text-muted">Không có dữ liệu để hiển thị</span></div>';
    }
});

// Filter functionality
$('#phongBanFilter').change(function () {
    var phongBan = $(this).val();
    var tuNgay = $('#tuNgayHidden').val();
    var denNgay = $('#denNgayHidden').val();

    var url = window.location.pathname;

    // Kiểm tra xem đang dùng date range hay tháng/năm
    if (tuNgay && denNgay) {
        url += '?tu_ngay=' + tuNgay + '&den_ngay=' + denNgay;
    } else {
        // Sử dụng tháng/năm hiện tại
        var now = new Date();
        var thang = now.getMonth() + 1;
        var nam = now.getFullYear();
        url += '?thang=' + thang + '&nam=' + nam;
    }

    if (phongBan) {
        url += '&phong_ban=' + encodeURIComponent(phongBan);
    }

    window.location.href = url;
});

// Refresh button functionality
$('#refreshData').click(function () {
    window.location.reload();
});

// Xuất báo cáo Excel
function exportToExcel() {
    var table = document.getElementById('reportTable');
    var workbook = XLSX.utils.table_to_book(table, {sheet: "Báo cáo nhân viên"});
    XLSX.writeFile(workbook, 'bao_cao_nhan_vien_' + new Date().toISOString().slice(0, 10) + '.xlsx');
}

// Xuất báo cáo PDF
function exportToPDF() {
    window.print();
}

// Refresh data
function refreshData() {
    window.location.reload();
}

// Enhanced filter table với cập nhật số lượng - Hoạt động cho cả 2 tab
$('#keywordFilter').on('input', function () {
    var keyword = $(this).val().toLowerCase();
    
    // Kiểm tra tab nào đang active
    var activeTab = $('.nav-link.active').attr('id');
    
    if (activeTab === 'nhanvien-tab') {
        // Filter bảng nhân viên
        var visibleRows = 0;
        var totalRows = 0;

        $('#reportTableBody tr').each(function () {
            // Bỏ qua các row thông báo "không có dữ liệu"
            if ($(this).find('td').length < 8)
                return;

            totalRows++;
            var text = $(this).text().toLowerCase();
            var visible = text.indexOf(keyword) > -1;
            $(this).toggle(visible);
            if (visible)
                visibleRows++;
        });

        // Cập nhật số lượng hiển thị
        $('.text-muted strong').text(visibleRows);

        // Show/hide "no data" message
        if (visibleRows === 0 && keyword !== '' && totalRows > 0) {
            if ($('#no-data-row').length === 0) {
                $('#reportTableBody').append(
                        '<tr id="no-data-row"><td colspan="8" class="text-center text-muted py-4">' +
                        '<i class="fa-solid fa-search fa-2x mb-2"></i><br>' +
                        'Không tìm thấy kết quả cho từ khóa "<strong>' + keyword + '</strong>"</td></tr>'
                        );
            }
        } else {
            $('#no-data-row').remove();
        }
    } else if (activeTab === 'duan-tab') {
        // Filter card dự án - Tìm theo tên dự án hoặc leader
        var visibleProjects = 0;
        var totalProjects = 0;

        $('.project-card').each(function () {
            totalProjects++;
            var projectName = $(this).data('project-name') ? $(this).data('project-name').toLowerCase() : '';
            var projectLead = $(this).data('project-lead') ? $(this).data('project-lead').toLowerCase() : '';
            var visible = projectName.indexOf(keyword) > -1 || projectLead.indexOf(keyword) > -1;
            $(this).toggle(visible);
            if (visible)
                visibleProjects++;
        });

        // Hiển thị thông báo nếu không tìm thấy
        if (visibleProjects === 0 && keyword !== '' && totalProjects > 0) {
            if ($('#no-project-found').length === 0) {
                $('.row.g-4').append(
                        '<div id="no-project-found" class="col-12 text-center py-5">' +
                        '<i class="fa-solid fa-search fa-3x text-muted mb-3"></i><br>' +
                        '<span class="text-muted">Không tìm thấy dự án cho từ khóa "<strong>' + keyword + '</strong>"</span></div>'
                        );
            }
        } else {
            $('#no-project-found').remove();
        }
    }
});

// Ô tìm kiếm trong tab dự án: dùng chung logic lọc với #keywordFilter
$('#keywordProjectFilter').on('input', function () {
    $('#keywordFilter').val($(this).val()).trigger('input');
});

// Enter trong các ô tìm kiếm: chỉ áp dụng lọc (đã lọc realtime), không submit
$('#keywordFilter, #keywordProjectFilter').on('keydown', function (e) {
    if (e.key === 'Enter') {
        e.preventDefault();
        $(this).trigger('input');
    }
});

// Status filter
$('#trangThaiFilter').change(function () {
    var selectedStatus = $(this).val();
    if (selectedStatus === 'Tất cả trạng thái') {
        // Show all rows
        $('#reportTableBody tr').show();
    } else {
        // Filter based on status
        // This would need to be implemented based on your data structure
        console.log('Status filter not yet implemented for:', selectedStatus);
    }
});
$(document).on("click", ".task-detail", function () {

    var nvId = $(this).data("nvid");
    var tenNV = $(this).data("tennv");
    var status = $(this).data("status");
    var soTask = $(this).data("sotask");

    if (soTask == 0)
        return;

    // Lấy khoảng thời gian hiện đang lọc
    var tuNgay = $("#tuNgayHidden").val();
    var denNgay = $("#denNgayHidden").val();

    $("#modalTenNV").text(tenNV);
    $("#modalTrangThai").text(status);
    $("#modalTaskTable").html('<tr><td colspan="3" class="text-center text-muted">Đang tải...</td></tr>');

    $("#modalTaskDetail").modal("show");

    // Gọi API lấy chi tiết task
    $.ajax({
        url: "getTaskDetail",
        type: "GET",
        data: {
            nvId: nvId,
            status: status,
            tu: tuNgay,
            den: denNgay
        },
        success: function (res) {
            if (!res || res.length === 0) {
                $("#modalTaskTable").html('<tr><td colspan="3" class="text-center text-muted">Không có công việc</td></tr>');
                return;
            }

            var html = "";
            res.forEach(function (task) {

                html += '<tr>'
                        + '<td>' + (task.ten_cong_viec ? task.ten_cong_viec : '-') + '</td>'
                        + '<td>' + (task.ten_du_an ? task.ten_du_an : '-') + '</td>'
                        + '<td>' + (task.ngay_bat_dau ? task.ngay_bat_dau : '-') + '</td>'
                        + '<td>' + (task.han_hoan_thanh ? task.han_hoan_thanh : '-') + '</td>'
                        + '<td>' + (task.ngay_hoan_thanh ? task.ngay_hoan_thanh : '-') + '</td>'
                        + '</tr>';
            });

            $("#modalTaskTable").html(html);
        },
        error: function () {
            $("#modalTaskTable").html('<tr><td colspan="3" class="text-center text-danger">Lỗi tải dữ liệu</td></tr>');
        }
    });
});

// ============================================
// FILTER DỰ ÁN & CLICK STATUS BOX
// ============================================

// Click status box để xem chi tiết công việc
$('.status-box').on('click', function() {
    var projectName = $(this).data('project');
    var status = $(this).data('status');
    var count = $(this).data('count');
    
    // Cập nhật modal header
    $('#projectName').text(projectName);
    $('#projectTaskStatus').text(status).attr('class', 'badge ' + getStatusBadgeClass(status));
    $('#projectDetailTitle').html('<i class="fa-solid fa-list-check me-2"></i>Chi tiết công việc (' + status + ')');
    
    // Làm trống bảng
    $('#projectTaskTableBody').html('<tr><td colspan="6" class="text-center text-muted py-3">Đang tải dữ liệu...</td></tr>');
    
    // Tải dữ liệu từ backend
    $.ajax({
        url: './getProjectTasks',
        type: 'POST',
        dataType: 'json',
        data: {
            projectName: projectName,
            status: status,
            tu_ngay: $('#tuNgayHidden').val(),
            den_ngay: $('#denNgayHidden').val()
        },
        success: function(tasks) {
            var html = '';
            var stt = 1;
            
            if (tasks.length === 0) {
                html = '<tr><td colspan="6" class="text-center text-muted py-3">Không có công việc</td></tr>';
            } else {
                tasks.forEach(function(task) {
                    var statusBadge = getTaskStatusBadge(task.trang_thai_cv);
                    html += '<tr>' +
                            '<td class="text-center">' + (stt++) + '</td>' +
                            '<td><strong>' + (task.ten_cong_viec || '-') + '</strong></td>' +
                            '<td>' + (task.nguoi_nhan || '-') + '</td>' +
                            '<td>' + (task.ngay_bat_dau || '-') + '</td>' +
                            '<td>' + (task.han_hoan_thanh || '-') + '</td>' +
                            '<td>' + statusBadge + '</td>' +
                            '</tr>';
                });
            }
            
            $('#projectTaskTableBody').html(html);
            
            // Hiển thị modal
            var modal = new bootstrap.Modal(document.getElementById('modalProjectTaskDetail'));
            modal.show();
        },
        error: function() {
            $('#projectTaskTableBody').html('<tr><td colspan="6" class="text-center text-danger py-3">Lỗi tải dữ liệu</td></tr>');
            var modal = new bootstrap.Modal(document.getElementById('modalProjectTaskDetail'));
            modal.show();
        }
    });
});

// Hàm lấy badge class theo status
function getStatusBadgeClass(status) {
    switch(status) {
        case 'Đã hoàn thành': return 'bg-success';
        case 'Đang thực hiện': return 'bg-info';
        case 'Quá hạn': return 'bg-danger';
        case 'Chưa bắt đầu': return 'bg-secondary';
        default: return 'bg-secondary';
    }
}

// Hàm lấy badge HTML cho trạng thái công việc
function getTaskStatusBadge(status) {
    var badgeClass = 'bg-secondary';
    var icon = 'fa-circle-check';
    
    if (status === 'Đã hoàn thành') {
        badgeClass = 'bg-success';
        icon = 'fa-check-circle';
    } else if (status === 'Đang thực hiện') {
        badgeClass = 'bg-info';
        icon = 'fa-spinner';
    } else if (status === 'Trễ hạn') {
        badgeClass = 'bg-danger';
        icon = 'fa-exclamation-circle';
    } else if (status === 'Chưa bắt đầu') {
        badgeClass = 'bg-secondary';
        icon = 'fa-circle';
    }
    
    return '<span class="badge ' + badgeClass + '"><i class="fa-solid ' + icon + ' me-1"></i>' + status + '</span>';
}

// Xử lý chuyển đổi giữa báo cáo nhân viên và dự án trong modal
$(document).ready(function() {
    // Xử lý khi thay đổi loại báo cáo
    $('#reportTypeSelector').on('change', function() {
        var selectedType = $(this).val();
        $('#reportTypeInput').val(selectedType);

        // Hiển thị/ẩn các trường tương ứng
        if (selectedType === 'summary') {
            // Báo cáo nhân viên
            $('#employeeReportFields').show();
            $('#projectReportFields').hide();
            
            // Disable các trường của dự án để không gửi lên server
            $('#projectReportFields input, #projectReportFields select').prop('disabled', true);
            $('#employeeReportFields input, #employeeReportFields select').prop('disabled', false);
        } else {
            // Báo cáo dự án
            $('#employeeReportFields').hide();
            $('#projectReportFields').show();
            
            // Disable các trường của nhân viên
            $('#employeeReportFields input, #employeeReportFields select').prop('disabled', true);
            $('#projectReportFields input, #projectReportFields select').prop('disabled', false);
        }
    });

    // Trigger change event khi modal được mở để đảm bảo hiển thị đúng
    $('#modalExportReport').on('show.bs.modal', function() {
        $('#reportTypeSelector').trigger('change');
    });
});