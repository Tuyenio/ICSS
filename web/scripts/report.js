// Gắn reportType theo tab đang active & kiểm tra đơn giản
(function () {
    var form = document.getElementById('formExportReport');
    form.addEventListener('submit', function (e) {
        var activePane = document.querySelector('#reportExportTabContent .tab-pane.active');
        var reportType = 'summary';
        if (activePane && activePane.id === 'tabExportKPI')
            reportType = 'kpi';
        if (activePane && activePane.id === 'tabExportTask')
            reportType = 'task';
        document.getElementById('reportTypeHidden').value = reportType;

        // Validate tối thiểu (ví dụ cho Summary)
        if (reportType === 'summary') {
            var fromDate = form.querySelector('input[name="fromDate"]').value;
            var toDate = form.querySelector('input[name="toDate"]').value;
            if (!fromDate || !toDate) {
                e.preventDefault();
                showToast('error', 'Vui lòng chọn đầy đủ khoảng thời gian.');
                return;
            }
        }
        // KPI có thể kiểm tra monthKPI nếu bạn muốn bắt buộc
        // Task không bắt buộc (đã có mặc định)
        // Không dùng AJAX để trình duyệt nhận stream file tải về
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

    // Xóa bộ lọc date range
    $('#clearDateRange').click(function () {
        var phongBan = $('#phongBanFilter').val();
        var url = window.location.pathname;

        // Quay về chế độ lọc theo tháng hiện tại
        var now = new Date();
        var thang = now.getMonth() + 1;
        var nam = now.getFullYear();

        url += '?thang=' + thang + '&nam=' + nam;
        if (phongBan) {
            url += '&phong_ban=' + encodeURIComponent(phongBan);
        }
        window.location.href = url;
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

// Enhanced filter table với cập nhật số lượng
$('#keywordFilter').on('input', function () {
    var keyword = $(this).val().toLowerCase();
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
    