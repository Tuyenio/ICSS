// Gắn reportType theo tab đang active & kiểm tra đơn giản
(function () {
    var form = document.getElementById('formExportReport');
    
    // Xử lý thay đổi loại xuất báo cáo
    $('#exportViewType').change(function() {
        var viewType = $(this).val();
        if (viewType === 'range') {
            $('#exportRangeDiv').show();
            $('#exportMonthDiv').hide();
        } else {
            $('#exportRangeDiv').hide();
            $('#exportMonthDiv').show();
        }
    });
    
    // Khởi tạo trạng thái ban đầu
    if ($('#exportViewType').val() === 'range') {
        $('#exportRangeDiv').show();
        $('#exportMonthDiv').hide();
    } else {
        $('#exportRangeDiv').hide();
        $('#exportMonthDiv').show();
    }
    
    form.addEventListener('submit', function (e) {
        var viewType = document.getElementById('exportViewType').value;
        
        // Validate
        if (viewType === 'range') {
            var fromDate = form.querySelector('input[name="fromDate"]').value;
            var toDate = form.querySelector('input[name="toDate"]').value;
            if (!fromDate || !toDate) {
                e.preventDefault();
                showToast('error', 'Vui lòng chọn khoảng thời gian.');
                return;
            }
        } else {
            var thangNam = form.querySelector('input[name="thangNam"]').value;
            if (!thangNam) {
                e.preventDefault();
                showToast('error', 'Vui lòng chọn tháng/năm.');
                return;
            }
        }
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
console.log('Current View Type:', currentViewType);
console.log('Current Period:', currentPeriod);

// Chart.js implementation
$(function () {
    // Pie Chart - Trạng thái công việc
    if (pieChartData && pieChartData.labels && pieChartData.labels.length > 0) {
        new Chart(document.getElementById('pieChart'), {
            type: 'pie',
            data: {
                labels: pieChartData.labels,
                datasets: [{
                        data: pieChartData.data,
                        backgroundColor: ['#198754', '#ffc107', '#dc3545', '#0d6efd']
                    }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'bottom'
                    },
                    title: {
                        display: true,
                        text: currentPeriod
                    }
                }
            }
        });
    } else {
        // Hiển thị thông báo khi không có dữ liệu
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
                    legend: {display: false},
                    title: {
                        display: true,
                        text: currentPeriod
                    }
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
$('#viewTypeFilter').change(function () {
    var viewType = $(this).val();
    
    if (viewType === 'range') {
        $('#fromDateDiv').show();
        $('#toDateDiv').show();
        $('#thangFilterDiv').hide();
    } else {
        $('#fromDateDiv').hide();
        $('#toDateDiv').hide();
        $('#thangFilterDiv').show();
    }
});

$('#thangFilter, #phongBanFilter, #fromDateFilter, #toDateFilter, #viewTypeFilter').change(function () {
    var viewType = $('#viewTypeFilter').val();
    var phongBan = $('#phongBanFilter').val();
    var url = window.location.pathname + '?viewType=' + viewType;

    if (viewType === 'range') {
        var fromDate = $('#fromDateFilter').val();
        var toDate = $('#toDateFilter').val();
        
        if (fromDate && toDate) {
            url += '&fromDate=' + fromDate + '&toDate=' + toDate;
        } else {
            // Nếu chưa chọn đủ ngày, không reload
            return;
        }
    } else {
        var thang = $('#thangFilter').val();
        if (thang) {
            var parts = thang.split('-');
            url += '&nam=' + parts[0] + '&thang=' + parseInt(parts[1]);
        }
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
    