
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
                attHolder.id = 'attDataHolder';
                attHolder.dataset.days = "<%= daysStr.toString() %>";
                attHolder.dataset.du = "<%= jsDuCong.toString() %>";
                attHolder.dataset.muon = "<%= jsDiMuon.toString() %>";
                attHolder.dataset.thieu = "<%= jsThieuGio.toString() %>";
                attHolder.dataset.vang = "<%= jsVang.toString() %>";
                attHolder.dataset.ot = "<%= jsLamThem.toString() %>";
                document.body.appendChild(attHolder);
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
            })();