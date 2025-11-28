
(function () {
    const h = document.getElementById('chartDataHolder');
    if (!h)
        return;
    const pbLabels = h.dataset.pbLabels ? h.dataset.pbLabels.split('|').filter(v => v) : [];
    const pbValues = h.dataset.pbValues ? h.dataset.pbValues.split(',').map(Number) : [];
    const ccLabels = h.dataset.ccLabels ? h.dataset.ccLabels.split('|').filter(v => v) : [];
    const ccValues = h.dataset.ccValues ? h.dataset.ccValues.split(',').map(Number) : [];
    const tongNgay = parseInt(h.dataset.tongNgay || '0');
    const diMuon = parseInt(h.dataset.diMuon || '0');
    // Tiến độ phòng ban (horizontal bar for better balance)
    const ctxPB = document.getElementById('chartTienDoPB');
    if (ctxPB) {
        // sort phòng ban theo % giảm dần để trực quan
        const pbPairs = pbLabels.map((l, i) => ({label: l, val: pbValues[i] || 0})).sort((a, b) => b.val - a.val);
        const sortedLabels = pbPairs.map(p => p.label);
        const sortedVals = pbPairs.map(p => p.val);
        const colorScale = v => {
            if (v >= 90)
                return '#10b981';  // Modern green
            if (v >= 70)
                return '#3b82f6';  // Modern blue  
            if (v >= 50)
                return '#f59e0b';  // Modern amber
            if (v >= 30)
                return '#f97316';  // Modern orange
            return '#ef4444';      // Modern red
        };
        const barColors = sortedVals.map(colorScale);
        new Chart(ctxPB, {type: 'bar', data: {labels: sortedLabels, datasets: [{label: '% Hoàn thành', data: sortedVals, backgroundColor: barColors, borderWidth: 0, barPercentage: 0.55, categoryPercentage: 0.55}]}, options: {indexAxis: 'y', responsive: true, plugins: {legend: {display: false}, tooltip: {callbacks: {label: (c) => c.parsed.x + '%'}}}, scales: {x: {beginAtZero: true, max: 100, ticks: {callback: (v) => v + '%'}}, y: {ticks: {autoSkip: false}}}}});
    }
    // Trạng thái công việc - Doughnut
    const ctxTT = document.getElementById('chartTrangThaiCV');
    if (ctxTT) {
        const trangThaiData = [parseInt(h.dataset.stHt || '0'), parseInt(h.dataset.stTh || '0'), parseInt(h.dataset.stTre || '0'), parseInt(h.dataset.stCbd || '0')];
        const colorsTT = ['#10b981', '#3b82f6', '#ef4444', '#64748b']; // Modern green, blue, red, gray
        const labelsTT = ['Hoàn thành', 'Đang thực hiện', 'Trễ hạn', 'Chưa bắt đầu'];
        const totalTT = trangThaiData.reduce((a, b) => a + b, 0);
        const centerText = totalTT + " CV";
        new Chart(ctxTT, {type: 'doughnut', data: {labels: labelsTT, datasets: [{data: trangThaiData, backgroundColor: colorsTT, borderWidth: 1}]}, options: {cutout: '70%', plugins: {legend: {display: false}, tooltip: {callbacks: {label: (ctx) => ctx.label + ': ' + ctx.parsed + ' (' + (totalTT ? Math.round(ctx.parsed * 100 / totalTT) : 0) + '%)'}}}}, plugins: [{id: 'centerText', afterDraw(chart, args, opts) {
                        const {ctx} = chart;
                        const meta = chart.getDatasetMeta(0);
                        if (!meta || !meta.data || !meta.data.length)
                            return;
                        ctx.save();
                        ctx.font = '600 17px system-ui';
                        ctx.fillStyle = '#212529';
                        ctx.textAlign = 'center';
                        ctx.textBaseline = 'middle';
                        const x = meta.data[0].x, y = meta.data[0].y;
                        ctx.fillText(centerText, x, y - 4);
                        ctx.font = '400 11px system-ui';
                        ctx.fillStyle = '#6c757d';
                        ctx.fillText('Tổng', x, y + 16);
                        ctx.restore();
                    }}]});
    }
    // (Removed personnel composition chart)
    // Chuyển dữ liệu chấm công theo ngày sang data-* để tránh lỗi JSP parser
    const attHolder = document.createElement('div');
    const ctxCCongNgay = document.getElementById('chartChamCongNgay');
    if (ctxCCongNgay) {
        const h2 = document.getElementById('attDataHolder');
        const parseArr = s => s ? s.split(',').map(Number) : [];
        const days = h2.dataset.days ? h2.dataset.days.split(',') : [];
        const ds = [
            {label: 'Đủ công', data: parseArr(h2.dataset.du), backgroundColor: '#10b981', stack: 'att'}, // Modern green
            {label: 'Đi muộn', data: parseArr(h2.dataset.muon), backgroundColor: '#3b82f6', stack: 'att'}, // Modern blue
            {label: 'Thiếu giờ', data: parseArr(h2.dataset.thieu), backgroundColor: '#f59e0b', stack: 'att'}, // Modern amber
            {label: 'Vắng', data: parseArr(h2.dataset.vang), backgroundColor: '#ef4444', stack: 'att'}, // Modern red
            {label: 'OT/WFH', data: parseArr(h2.dataset.ot), backgroundColor: '#8b5cf6', stack: 'att'}        // Modern purple
        ];
        new Chart(ctxCCongNgay, {type: 'bar', data: {labels: days, datasets: ds}, options: {responsive: true, plugins: {legend: {position: 'bottom'}, tooltip: {mode: 'index', intersect: false}}, scales: {x: {stacked: true}, y: {stacked: true, beginAtZero: true}}}});
    }

    // Biểu đồ tiến độ dự án theo nhóm
    const ctxTienDoDuAn = document.getElementById('chartTienDoDuAn');

    if (ctxTienDoDuAn) {
        const h = document.getElementById('chartDataHolder');

        // DỮ LIỆU PHÒNG BAN (lấy từ JSP data-*)
        const kyThuatProjectNames = h.dataset.ktProjectNames ? h.dataset.ktProjectNames.split('|') : [];
        const kyThuatProgress = h.dataset.ktProgress ? h.dataset.ktProgress.split(',').map(Number) : [];

        const kinhDoanhProjectNames = h.dataset.kdProjectNames ? h.dataset.kdProjectNames.split('|') : [];
        const kinhDoanhProgress = h.dataset.kdProgress ? h.dataset.kdProgress.split(',').map(Number) : [];

        let currentChart = null;

        const createProjectChart = (labels, values, endDates, daysLeft) => {

            if (currentChart)
                currentChart.destroy();

            // Tạo nhãn mới: kèm '(Còn X ngày)' hoặc '(Quá hạn Y ngày)'
            const labelsWithDeadline = labels.map((name, i) => {
                const d = daysLeft[i];
                if (d < 0)
                    return `${name} (Quá hạn ${Math.abs(d)} ngày)`;
                return `${name} (Còn ${d} ngày)`;
            });

            // Màu tiến độ giữ nguyên
            const colorScale = v => {
                if (v >= 90)
                    return '#10b981';
                if (v >= 70)
                    return '#3b82f6';
                if (v >= 50)
                    return '#f59e0b';
                if (v >= 30)
                    return '#f97316';
                return '#ef4444';
            };
            const barColors = values.map(colorScale);

            currentChart = new Chart(ctxTienDoDuAn, {
                type: 'bar',
                data: {
                    labels: labelsWithDeadline,
                    datasets: [{
                            label: '% Tiến độ',
                            data: values,
                            backgroundColor: barColors,
                            borderWidth: 0
                        }]
                },
                options: {
                    indexAxis: 'y',
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        tooltip: {
                            callbacks: {
                                afterLabel: (ctx) => {
                                    const i = ctx.dataIndex;
                                    return "Hạn kết thúc: " + endDates[i];
                                }
                            }
                        }
                    }
                }
            });

            document.getElementById('projectCountInfo').textContent =
                    "Hiển thị " + labels.length + " dự án";
        };

        const ktEndDates = h.dataset.ktEndDates.split("|");
        const ktDaysLeft = JSON.parse(h.dataset.ktDaysLeft);

        const kdEndDates = h.dataset.kdEndDates.split("|");
        const kdDaysLeft = JSON.parse(h.dataset.kdDaysLeft);

// Load mặc định
        createProjectChart(
                kyThuatProjectNames,
                kyThuatProgress,
                ktEndDates,
                ktDaysLeft
                );

// Khi đổi nhóm dự án
        document.getElementById('phongBanSelect').addEventListener('change', function () {
            if (this.value === 'kyThuat') {
                createProjectChart(kyThuatProjectNames, kyThuatProgress, ktEndDates, ktDaysLeft);
            } else {
                createProjectChart(kinhDoanhProjectNames, kinhDoanhProgress, kdEndDates, kdDaysLeft);
            }
        });
    }
})();
document.getElementById("btnNhacViecAll").addEventListener("click", function () {

    Swal.fire({
        title: "Chọn trạng thái cần bật nhắc việc",
        html:
                "<div style='text-align:left; margin-left:40px'>" +
                "<label><input type='checkbox' id='cb_chua_bd'> Chưa bắt đầu</label><br>" +
                "<label><input type='checkbox' id='cb_dang_th'> Đang thực hiện</label><br>" +
                "<label><input type='checkbox' id='cb_tre_han'> Trễ hạn</label>" +
                "</div>",
        icon: "question",
        showCancelButton: true,
        confirmButtonText: "Bật nhắc việc",
        cancelButtonText: "Hủy"
    }).then(result => {

        if (!result.isConfirmed)
            return;

        // === LẤY DANH SÁCH TRẠNG THÁI ĐƯỢC CHỌN ===
        let selected = [];
        if (document.getElementById('cb_chua_bd').checked)
            selected.push("Chưa bắt đầu");
        if (document.getElementById('cb_dang_th').checked)
            selected.push("Đang thực hiện");
        if (document.getElementById('cb_tre_han').checked)
            selected.push("Trễ hạn");

        if (selected.length === 0) {
            Swal.fire("Thông báo", "Bạn phải chọn ít nhất 1 trạng thái!", "warning");
            return;
        }

        // Chuỗi dạng: "Chưa bắt đầu,Đang thực hiện"
        const dataSend = selected.join(",");

        // === GỬI SANG SERVLET (POST + text) ===
        fetch("batNhacViecAll", {
            method: "POST",
            headers: {"Content-Type": "application/x-www-form-urlencoded"},
            body: "states=" + encodeURIComponent(dataSend)
        })
                .then(res => res.text())
                .then(text => {

                    if (text === "OK") {
                        Swal.fire("Thành công!", "Đã bật nhắc việc cho các trạng thái đã chọn!", "success");
                    } else if (text === "NO_UPDATE") {
                        Swal.fire("Thông báo", "Không có công việc nào cần cập nhật!", "info");
                    } else {
                        Swal.fire("Lỗi", "Không thể bật nhắc việc!", "error");
                    }

                })
                .catch(err => {
                    console.error(err);
                    Swal.fire("Lỗi", "Không thể kết nối máy chủ!", "error");
                });

    });
});