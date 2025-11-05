function loadKPIByMonth() {
    const thang = document.getElementById('filterThangKPI').value;
    const nam = document.getElementById('filterNamKPI').value;

    $.ajax({
        url: './userLuong',
        type: 'POST',
        data: {
            action: 'getKPIByMonth',
            thang: thang,
            nam: nam
        },
        success: function (response) {
            if (response.success) {
                let html = '';

                if (response.kpiList && response.kpiList.length > 0) {
                    response.kpiList.forEach(function (kpi) {
                        html += '<div class="card mb-3">';
                        html += '<div class="card-body">';
                        html += '<div class="row">';
                        html += '<div class="col-md-8">';
                        html += '<h6 class="card-title">' + kpi.chi_tieu + '</h6>';
                        html += '<p class="card-text">' + kpi.ket_qua + '</p>';
                        if (kpi.ghi_chu) {
                            html += '<small class="text-muted">' + kpi.ghi_chu + '</small>';
                        }
                        html += '</div>';
                        html += '<div class="col-md-4 text-end">';
                        html += '<h3 class="text-primary">' + parseFloat(kpi.diem_kpi).toFixed(1) + '</h3>';
                        html += '<small class="text-muted">' + kpi.ngay_tao + '</small>';
                        html += '</div>';
                        html += '</div>';
                        html += '</div>';
                        html += '</div>';
                    });
                } else {
                    html = '<div class="text-center py-5">';
                    html += '<i class="fa-solid fa-chart-line fa-3x text-muted mb-3"></i>';
                    html += '<p class="text-muted">Chưa có dữ liệu KPI tháng này</p>';
                    html += '</div>';
                }

                document.getElementById('kpiContent').innerHTML = html;
            } else {
                Swal.fire({
                    icon: 'error',
                    title: 'Lỗi!',
                    text: response.message
                });
            }
        },
        error: function () {
            Swal.fire({
                icon: 'error',
                title: 'Lỗi!',
                text: 'Không thể kết nối đến server'
            });
        }
    });
}