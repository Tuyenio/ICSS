// Doughnut chart giống admin cho báo cáo nhanh cá nhân
(function () {
    const box = document.getElementById('userQuickReport');
    if (!box)
        return;
    const ht = parseInt(box.dataset.ht || '0');
    const th = parseInt(box.dataset.th || '0');
    const tre = parseInt(box.dataset.tre || '0');
    const cbd = parseInt(box.dataset.cbd || '0');
    const total = ht + th + tre + cbd;
    // cập nhật số
    const set = (id, val) => {
        const el = document.getElementById(id);
        if (el)
            el.textContent = val;
    };
    set('cvHT', ht);
    set('cvTH', th);
    set('cvTre', tre);
    set('cvCBD', cbd);
    set('cvTotal', total);
    const pct = (v) => total ? Math.round(v * 100 / total) + '%' : '0%';
    set('pctHT', pct(ht));
    set('pctTH', pct(th));
    set('pctTre', pct(tre));
    set('pctCBD', pct(cbd));
    const ctx = document.getElementById('chartTrangThaiCaNhan');
    if (!ctx)
        return;
    const data = [ht, th, tre, cbd];
    const colors = ['#198754', '#0d6efd', '#dc3545', '#6c757d'];
    new Chart(ctx, {type: 'doughnut', data: {labels: ['Hoàn thành', 'Đang thực hiện', 'Trễ hạn', 'Chưa bắt đầu'], datasets: [{data, backgroundColor: colors, borderWidth: 1}]}, options: {cutout: '70%', plugins: {legend: {display: false}, tooltip: {callbacks: {label: (c) => c.label + ': ' + c.parsed + ' (' + (total ? Math.round(c.parsed * 100 / total) : 0) + '%)'}}}}, plugins: [{id: 'centerTxtUser', afterDraw(chart) {
                    const meta = chart.getDatasetMeta(0);
                    if (!meta.data.length)
                        return;
                    const {ctx} = chart;
                    const x = meta.data[0].x, y = meta.data[0].y;
                    ctx.save();
                    ctx.font = '600 16px system-ui';
                    ctx.fillStyle = '#212529';
                    ctx.textAlign = 'center';
                    ctx.textBaseline = 'middle';
                    ctx.fillText(total + ' CV', x, y - 4);
                    ctx.font = '400 11px system-ui';
                    ctx.fillStyle = '#6c757d';
                    ctx.fillText('Tổng', x, y + 14);
                    ctx.restore();
                }}]});
})();
// Hàm check-in
function checkIn() {
    fetch('./userChamCong', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'action=checkin'
    })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('Check-in thành công!');
                    location.reload();
                } else {
                    alert('Lỗi check-in: ' + data.message);
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Có lỗi xảy ra khi check-in');
            });
}

// Hàm check-out  
function checkOut() {
    fetch('./userChamCong', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'action=checkout'
    })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('Check-out thành công!');
                    location.reload();
                } else {
                    alert('Lỗi check-out: ' + data.message);
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Có lỗi xảy ra khi check-out');
            });
}

// Auto-refresh mỗi 5 phút để cập nhật dữ liệu
setInterval(function () {
    location.reload();
}, 300000); // 5 phút

// Hiển thị ngày hiện tại
document.addEventListener('DOMContentLoaded', function () {
    const currentDateElement = document.getElementById('currentDate');
    if (currentDateElement) {
        const now = new Date();
        const options = {
            weekday: 'long',
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        };
        currentDateElement.textContent = now.toLocaleDateString('vi-VN', options);
    }
});