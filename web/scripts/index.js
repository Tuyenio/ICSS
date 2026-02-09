
(function () {
    // Hiệu ứng đổ bóng nhẹ tạo cảm giác nổi khối
    const shadowPlugin = {
        id: 'shadowPlugin',
        beforeDraw(chart) {
            const {ctx} = chart;
            ctx.save();
            ctx.shadowColor = 'rgba(15,23,42,0.16)';
            ctx.shadowBlur = 12;
            ctx.shadowOffsetX = 0;
            ctx.shadowOffsetY = 6;
        },
        afterDraw(chart) {
            chart.ctx.restore();
        }
    };

    const h = document.getElementById('chartDataHolder');
    if (!h)
        return;

    let pbLabels = h.dataset.pbLabels ? h.dataset.pbLabels.split('|').filter(v => v) : [];
    let pbValues = h.dataset.pbValues ? h.dataset.pbValues.split(',').map(Number) : [];
    if (!pbLabels.length) {
        pbLabels = ['Chưa có dữ liệu'];
        pbValues = [0];
    }

    const ccLabels = h.dataset.ccLabels ? h.dataset.ccLabels.split('|').filter(v => v) : [];
    const ccValues = h.dataset.ccValues ? h.dataset.ccValues.split(',').map(Number) : [];
    const tongNgay = parseInt(h.dataset.tongNgay || '0');
    const diMuon = parseInt(h.dataset.diMuon || '0');
    const hcDangLam = parseInt(h.dataset.hcDangLam || '0');
    const hcTamNghi = parseInt(h.dataset.hcTamNghi || '0');
    const hcNghiViec = parseInt(h.dataset.hcNghiViec || '0');
    const hcTong = parseInt(h.dataset.hcTong || '0');

    // Tiến độ phòng ban (horizontal bar)
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
        new Chart(ctxPB, {
            type: 'bar',
            data: {labels: sortedLabels, datasets: [{label: '% Hoàn thành', data: sortedVals, backgroundColor: barColors, borderRadius: 10, borderWidth: 0, barPercentage: 0.55, categoryPercentage: 0.55}]},
            options: {indexAxis: 'y', responsive: true, plugins: {legend: {display: false}, tooltip: {callbacks: {label: (c) => c.parsed.x + '%'}}}, scales: {x: {beginAtZero: true, max: 100, ticks: {callback: (v) => v + '%'}, grid: {color: '#e2e8f0'}}, y: {ticks: {autoSkip: false}}}},
            plugins: [shadowPlugin]
        });
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

        // Dữ liệu dự án hiện có (kỹ thuật / kinh doanh)
        const kyThuatProjectNames = h.dataset.ktProjectNames ? h.dataset.ktProjectNames.split('|').filter(v => v !== '') : [];
        const kyThuatProgress = h.dataset.ktProgress ? h.dataset.ktProgress.split(',').map(Number) : [];
        const kyThuatProjectIds = h.dataset.ktProjectIds ? h.dataset.ktProjectIds.split(',').map(v => v === '' ? null : parseInt(v)) : [];
        const kyThuatStatuses = h.dataset.ktStatuses ? h.dataset.ktStatuses.split('|').filter(v => v !== '') : [];
        const ktEndDates = h.dataset.ktEndDates ? h.dataset.ktEndDates.split("|") : [];
        const ktDaysLeft = h.dataset.ktDaysLeft ? JSON.parse(h.dataset.ktDaysLeft) : [];

        const kinhDoanhProjectNames = h.dataset.kdProjectNames ? h.dataset.kdProjectNames.split('|').filter(v => v !== '') : [];
        const kinhDoanhProgress = h.dataset.kdProgress ? h.dataset.kdProgress.split(',').map(Number) : [];
        const kinhDoanhProjectIds = h.dataset.kdProjectIds ? h.dataset.kdProjectIds.split(',').map(v => v === '' ? null : parseInt(v)) : [];
        const kinhDoanhStatuses = h.dataset.kdStatuses ? h.dataset.kdStatuses.split('|').filter(v => v !== '') : [];
        const kdEndDates = h.dataset.kdEndDates ? h.dataset.kdEndDates.split("|") : [];
        const kdDaysLeft = h.dataset.kdDaysLeft ? JSON.parse(h.dataset.kdDaysLeft) : [];

        // Thứ tự hiển thị trạng thái theo yêu cầu
        const STATUS_ORDER = ['Đang thực hiện', 'Tạm ngưng', 'Đã hoàn thành', 'Đóng dự án'];
        const STATUS_COLOR = {
            'Đang thực hiện': '#0284C7', // blue-600
            'Tạm ngưng': '#F59E0B', // amber-500
            'Đã hoàn thành': '#16A34A', // green-600
            'Đóng dự án': '#DC2626'         // red-600
        };

        // helper: màu theo tiến độ (0 -> đỏ, 50 -> vàng, 100 -> xanh)
        const progressColor = (p) => {
            const hue = Math.round((p / 100) * 120); // 0..120 (red -> green)
            return `hsl(${hue} 75% 45%)`;
        };

        // inject minimal styles for progress fill if not present
        if (!document.getElementById('projProgressStyles')) {
            const s = document.createElement('style');
            s.id = 'projProgressStyles';
            s.textContent = `
                .proj-name-wrap{
                    position: relative;
                    width: 100%;
                    padding: 6px 10px;
                    border-radius: 8px;
                    overflow: hidden;
                    background: transparent;
                }
                .proj-progress-fill{
                    position: absolute;
                    left: 0;
                    top: 0;
                    bottom: 0;
                    width: 0%;
                    z-index: 1;
                    opacity: 0.18;
                    border-radius: 8px;
                    transition: width .7s ease, background-color .5s ease;
                }
                .proj-name-text{
                    position: relative;
                    z-index: 2;
                    font-weight: 600;
                    color: #0b1220;
                    white-space: nowrap;
                }
            `;
            document.head.appendChild(s);
        }

        // Nơi render: dùng parent của canvas (giữ canvas để không phá layout). Tạo container hiển thị danh sách.
        const renderContainer = (canvasEl) => {
            // tìm thẻ chứa canvas; nếu có .chart-wrapper -> dùng, ngược lại dùng parentNode
            return canvasEl.parentElement || canvasEl.parentNode;
        };

        const renderGroupedProjects = (names, progresses, endDates, daysLeft, ids, statuses) => {
            const container = renderContainer(ctxTienDoDuAn);
            // wipe previous content then append a custom list; giữ canvas but hide nó
            ctxTienDoDuAn.style.display = 'none';
            // create wrapper
            let wrapper = container.querySelector('.project-group-wrapper');
            if (!wrapper) {
                wrapper = document.createElement('div');
                wrapper.className = 'project-group-wrapper';
                wrapper.style.padding = '12px';
                wrapper.style.color = '#1e293b';
                wrapper.style.fontWeight = '500';
                container.appendChild(wrapper);
            }
            wrapper.innerHTML = '';

            // Build grouped map
            const groups = {};
            for (let i = 0; i < names.length; i++) {
                const st = statuses[i] || 'Đang thực hiện';
                if (!groups[st])
                    groups[st] = [];
                groups[st].push({
                    id: ids[i],
                    name: names[i],
                    progress: typeof progresses[i] === 'number' ? Math.round(progresses[i]) : 0,
                    endDate: endDates[i] || '',
                    daysLeft: daysLeft && daysLeft[i] !== undefined ? daysLeft[i] : null
                });
            }

            // Render for each status in STATUS_ORDER if exists
            STATUS_ORDER.forEach(st => {
                const items = groups[st];
                if (!items || items.length === 0)
                    return; // bỏ trạng thái không có project
                // Section header
                const header = document.createElement('div');
                header.style.display = 'flex';
                header.style.alignItems = 'center';
                header.style.gap = '10px';
                header.style.marginTop = '10px';
                header.style.marginBottom = '6px';
                const bullet = document.createElement('span');
                bullet.style.width = '12px';
                bullet.style.height = '12px';
                bullet.style.borderRadius = '50%';
                bullet.style.display = 'inline-block';
                bullet.style.background = STATUS_COLOR[st] || '#64748b';
                bullet.style.boxShadow = `0 0 8px ${bullet.style.background}33`;
                const title = document.createElement('strong');
                title.textContent = `${st}`;
                title.style.fontSize = '1rem';
                title.style.color = '#0f172a';
                header.appendChild(bullet);
                header.appendChild(title);
                wrapper.appendChild(header);

                // Items under this status
                items.forEach(proj => {
                    const row = document.createElement('div');
                    row.style.display = 'flex';
                    row.style.justifyContent = 'space-between';
                    row.style.alignItems = 'center';
                    row.style.padding = '2px 4px';
                    row.style.borderRadius = '8px';
                    row.style.cursor = 'pointer';
                    row.style.marginBottom = '3px';
                    row.style.background = 'rgba(15,23,42,0.02)';
                    row.onmouseover = () => {
                        row.style.background = 'rgba(59,130,246,0.06)';
                    };
                    row.onmouseleave = () => {
                        row.style.background = 'rgba(15,23,42,0.02)';
                    };
                    row.onclick = () => {
                        if (proj.id !== undefined && proj.id !== null && proj.id !== "") {
                            window.location.href = 'dsCongviecDuan?projectId=' + encodeURIComponent(proj.id);
                        }
                    };

                    const left = document.createElement('div');
                    left.style.display = 'flex';
                    left.style.gap = '10px';
                    left.style.alignItems = 'center';

                    const dot = document.createElement('span');
                    dot.style.width = '8px';
                    dot.style.height = '8px';
                    dot.style.borderRadius = '50%';
                    dot.style.display = 'inline-block';
                    dot.style.background = STATUS_COLOR[st] || '#64748b';

                    // name wrapper with progress fill
                    const nameWrap = document.createElement('div');
                    nameWrap.className = 'proj-name-wrap';
                    nameWrap.style.padding = '6px 10px';
                    nameWrap.style.borderRadius = '8px';
                    nameWrap.style.background = 'transparent';
                    nameWrap.style.display = 'block';

                    const fill = document.createElement('div');
                    fill.className = 'proj-progress-fill';
                    const p = Math.min(100, Math.max(0, proj.progress || 0));
                    fill.style.width = p + '%';
                    fill.style.background = progressColor(p);
                    fill.style.opacity = '0.18';
                    fill.style.position = "absolute";
                    fill.style.left = "0";
                    fill.style.top = "0";
                    fill.style.bottom = "0";
                    fill.style.borderRadius = "8px";
                    fill.style.zIndex = "0";
                    row.style.position = "relative";
                    row.prepend(fill);
                    const nameEl = document.createElement('div');
                    nameEl.className = 'proj-name-text';
                    nameEl.textContent = proj.name;
                    nameEl.style.padding = '0 6px';
                    nameWrap.appendChild(nameEl);
                    left.appendChild(dot);
                    left.appendChild(nameWrap);
                    const right = document.createElement('div');
                    right.style.display = 'flex';
                    right.style.flexDirection = 'column';
                    right.style.alignItems = 'flex-end';
                    right.style.gap = '4px';

                    const pct = document.createElement('span');
                    pct.textContent = proj.progress + '%';
                    pct.style.fontWeight = '700';
                    pct.style.color = STATUS_COLOR[st] || '#0b1220';
                    right.appendChild(pct);

                    // ✅ KIỂM TRA: Nếu tiến độ = 100% thì hiển thị badge "Đã hoàn thành" thay vì daysInfo
                    if (proj.progress >= 100) {
                        const completedBadge = document.createElement('span');
                        completedBadge.textContent = '✓ Hoàn thành';
                        completedBadge.style.fontSize = '0.75rem';
                        completedBadge.style.fontWeight = '700';
                        completedBadge.style.color = '#16A34A';
                        completedBadge.style.background = 'rgba(22, 163, 74, 0.1)';
                        completedBadge.style.padding = '3px 8px';
                        completedBadge.style.borderRadius = '12px';
                        completedBadge.style.display = 'inline-block';
                        completedBadge.style.whiteSpace = 'nowrap';
                        right.appendChild(completedBadge);
                    } else {
                        // Nếu chưa 100% thì hiển thị thông tin ngày còn lại / quá hạn
                        const daysInfo = document.createElement('span');
                        daysInfo.style.fontSize = '0.85rem';
                        daysInfo.style.fontWeight = '600';

                        if (proj.daysLeft > 0) {
                            daysInfo.textContent = "Còn lại " + proj.daysLeft + " ngày";
                            daysInfo.style.color = "#059669";
                        } else if (proj.daysLeft === 0) {
                            daysInfo.textContent = "Hôm nay là hạn cuối";
                            daysInfo.style.color = "#d97706";
                        } else {
                            daysInfo.textContent = "Đã quá hạn " + Math.abs(proj.daysLeft) + " ngày";
                            daysInfo.style.color = "#dc2626";
                        }
                        right.appendChild(daysInfo);
                    }

                    row.appendChild(left);
                    row.appendChild(right);
                    wrapper.appendChild(row);

                    // small animation: after append ensure width animated (in case CSS loaded after)
                    requestAnimationFrame(() => {
                        fill.style.width = p + '%';
                    });
                });
            });

            // Info footer
            const info = document.createElement('div');
            info.className = 'small text-muted mt-2';
            info.style.marginTop = '10px';
            info.textContent = `Hiển thị ${names.length} dự án`;
            wrapper.appendChild(info);
        };

        // Wrapper to call renderGroupedProjects for selected group
        const createProjectChart = (names, values, endDates, daysLeft, projectIds, statuses) => {
            // Render grouped list
            renderGroupedProjects(names, values, endDates, daysLeft, projectIds, statuses);
        };

        // Load mặc định (kỹ thuật)
        createProjectChart(
                kyThuatProjectNames,
                kyThuatProgress,
                ktEndDates,
                ktDaysLeft,
                kyThuatProjectIds,
                kyThuatStatuses
                );

        // Khi đổi nhóm dự án
        const sel = document.getElementById('phongBanSelect');
        if (sel) {
            sel.addEventListener('change', function () {
                // show/hide canvas wrapper reset
                const wrapper = ctxTienDoDuAn.parentElement.querySelector('.project-group-wrapper');
                if (wrapper)
                    wrapper.remove();
                ctxTienDoDuAn.style.display = '';

                if (this.value === 'kyThuat') {
                    createProjectChart(kyThuatProjectNames, kyThuatProgress, ktEndDates, ktDaysLeft, kyThuatProjectIds, kyThuatStatuses);
                } else {
                    createProjectChart(kinhDoanhProjectNames, kinhDoanhProgress, kdEndDates, kdDaysLeft, kinhDoanhProjectIds, kinhDoanhStatuses);
                }
            });
        }
    }

    if (!h)
        return;

    // Debug: Log all new chart data attributes
    console.log('=== NEW CHARTS DATA DEBUG ===');
    console.log('Overdue Projects:', h.dataset.overdueProjects);
    console.log('Overdue Counts:', h.dataset.overdueCounts);
    console.log('Workload Names:', h.dataset.workloadNames);
    console.log('Workload Counts:', h.dataset.workloadCounts);
    console.log('Burnup Days:', h.dataset.burnupDays);
    console.log('Priority Labels:', h.dataset.priorityLabels);
    console.log('Priority Counts:', h.dataset.priorityCounts);
    console.log('Avg Age Projects:', h.dataset.avgAgeProjects);
    console.log('SLA Breached:', h.dataset.slaBreached, 'On-time:', h.dataset.slaOntime);

    // 1. Overdue Tasks by Project
    const ctxOverdue = document.getElementById('chartOverdueByProject');
    if (ctxOverdue) {
        const overdueProjects = h.dataset.overdueProjects ? h.dataset.overdueProjects.split('|').filter(v => v) : [];
        const overdueCounts = h.dataset.overdueCounts ? h.dataset.overdueCounts.split(',').map(Number) : [];
        console.log('Chart 1 - Overdue:', overdueProjects.length, 'projects', overdueProjects, overdueCounts);
        console.log('Canvas ctxOverdue:', ctxOverdue, 'rendering context:', ctxOverdue?.getContext('2d'));

        if (overdueProjects.length === 0) {
            console.warn('No overdue data available');
            ctxOverdue.parentElement.innerHTML = '<div class="text-center text-muted py-5"><i class="fa-solid fa-inbox fa-2x mb-2"></i><br>Không có dữ liệu</div>';
        } else {
            try {
                const colors = ['#ef4444', '#f97316', '#f59e0b', '#3b82f6', '#10b981'].reverse();
                new Chart(ctxOverdue, {
                    type: 'bar',
                    data: {
                        labels: overdueProjects,
                        datasets: [{
                                label: 'Số task quá hạn',
                                data: overdueCounts,
                                backgroundColor: overdueCounts.map((_, i) => colors[i % colors.length]),
                                borderRadius: 8,
                                borderWidth: 0
                            }]
                    },
                    options: {
                        indexAxis: 'y',
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {legend: {display: false}, tooltip: {callbacks: {label: (c) => c.parsed.x + ' tasks'}}},
                        scales: {x: {beginAtZero: true, ticks: {callback: (v) => v}}, y: {ticks: {autoSkip: false}}}
                    },
                    plugins: [shadowPlugin]
                });
                console.log('Chart 1 rendered successfully!');
            } catch (e) {
                console.error('Chart 1 error:', e);
            }
        }
    }

    // 2. Top 10 Employees Workload
    const ctxWorkload = document.getElementById('chartTopWorkload');
    if (ctxWorkload) {
        const workloadNames = h.dataset.workloadNames ? h.dataset.workloadNames.split('|').filter(v => v) : [];
        const workloadCounts = h.dataset.workloadCounts ? h.dataset.workloadCounts.split(',').map(Number) : [];
        console.log('Chart 2 - Workload:', workloadNames.length, 'employees', workloadNames, workloadCounts);

        if (workloadNames.length === 0) {
            console.warn('No workload data available');
            ctxWorkload.parentElement.innerHTML = '<div class="text-center text-muted py-5"><i class="fa-solid fa-inbox fa-2x mb-2"></i><br>Không có dữ liệu</div>';
        } else {
            try {
                const workloadColors = workloadCounts.map(v => v > 15 ? '#ef4444' : v > 10 ? '#f59e0b' : '#10b981');
                new Chart(ctxWorkload, {
                    type: 'bar',
                    data: {
                        labels: workloadNames,
                        datasets: [{
                                label: 'Số task đang mở',
                                data: workloadCounts,
                                backgroundColor: workloadColors,
                                borderRadius: 8,
                                borderWidth: 0,
                                barPercentage: 0.6
                            }]
                    },
                    options: {
                        indexAxis: 'y',
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {legend: {display: false}, tooltip: {callbacks: {label: (c) => c.parsed.x + ' tasks'}}},
                        scales: {x: {beginAtZero: true}, y: {ticks: {autoSkip: false}}}
                    },
                    plugins: [shadowPlugin]
                });
                console.log('Chart 2 rendered successfully!');
            } catch (e) {
                console.error('Chart 2 error:', e);
            }
        }
    }

    // 3. Created vs Completed Trend (30 days)
    const ctxBurnup = document.getElementById('chartCreatedVsCompleted');
    if (ctxBurnup) {
        const burnupDays = h.dataset.burnupDays ? h.dataset.burnupDays.split('|').filter(v => v) : [];
        const burnupCreated = h.dataset.burnupCreated ? h.dataset.burnupCreated.split(',').map(Number) : [];
        const burnupCompleted = h.dataset.burnupCompleted ? h.dataset.burnupCompleted.split(',').map(Number) : [];
        console.log('Chart 3 - Burnup:', burnupDays.length, 'days', burnupCreated, burnupCompleted);

        if (burnupDays.length === 0) {
            console.warn('No burnup data available');
            ctxBurnup.parentElement.innerHTML = '<div class="text-center text-muted py-5"><i class="fa-solid fa-inbox fa-2x mb-2"></i><br>Không có dữ liệu</div>';
        } else {
            try {
                new Chart(ctxBurnup, {
                    type: 'line',
                    data: {
                        labels: burnupDays,
                        datasets: [
                            {
                                label: 'Tasks tạo mới',
                                data: burnupCreated,
                                borderColor: '#3b82f6',
                                backgroundColor: 'rgba(59, 130, 246, 0.1)',
                                tension: 0.3,
                                fill: true,
                                pointRadius: 3,
                                pointBackgroundColor: '#3b82f6'
                            },
                            {
                                label: 'Tasks hoàn thành',
                                data: burnupCompleted,
                                borderColor: '#10b981',
                                backgroundColor: 'rgba(16, 185, 129, 0.1)',
                                tension: 0.3,
                                fill: true,
                                pointRadius: 3,
                                pointBackgroundColor: '#10b981'
                            }
                        ]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {legend: {position: 'bottom'}, tooltip: {mode: 'index', intersect: false}},
                        scales: {y: {beginAtZero: true}}
                    },
                    plugins: [shadowPlugin]
                });
                console.log('Chart 3 rendered successfully!');
            } catch (e) {
                console.error('Chart 3 error:', e);
            }
        }
    }

    // 4. Priority Distribution
    const ctxPriority = document.getElementById('chartPriorityDist');
    if (ctxPriority) {
        const priorityLabels = h.dataset.priorityLabels ? h.dataset.priorityLabels.split('|').filter(v => v) : [];
        const priorityCounts = h.dataset.priorityCounts ? h.dataset.priorityCounts.split(',').map(Number) : [];
        console.log('Chart 4 - Priority:', priorityLabels, priorityCounts);

        if (priorityLabels.length === 0 || priorityCounts.reduce((a, b) => a + b, 0) === 0) {
            console.warn('No priority data available');
            ctxPriority.parentElement.innerHTML = '<div class="text-center text-muted py-5"><i class="fa-solid fa-inbox fa-2x mb-2"></i><br>Không có dữ liệu</div>';
        } else {
            try {
                const priorityColors = {'Cao': '#ef4444', 'Trung bình': '#f59e0b', 'Thấp': '#3b82f6'};
                const colors = priorityLabels.map(l => priorityColors[l] || '#64748b');
                new Chart(ctxPriority, {
                    type: 'doughnut',
                    data: {
                        labels: priorityLabels,
                        datasets: [{data: priorityCounts, backgroundColor: colors, borderWidth: 1}]
                    },
                    options: {
                        cutout: '60%',
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: {position: 'bottom'},
                            tooltip: {callbacks: {label: (ctx) => ctx.label + ': ' + ctx.parsed + ' (' + (Math.round(ctx.parsed * 100 / priorityCounts.reduce((a, b) => a + b, 0))) + '%)'}}
                        }
                    },
                    plugins: [shadowPlugin]
                });
                console.log('Chart 4 rendered successfully!');
            } catch (e) {
                console.error('Chart 4 error:', e);
            }
        }
    }

    // 5. Average Open Age
    const ctxAvgAge = document.getElementById('chartAvgOpenAge');
    if (ctxAvgAge) {
        const avgAgeProjects = h.dataset.avgAgeProjects ? h.dataset.avgAgeProjects.split('|').filter(v => v) : [];
        const avgAgeDays = h.dataset.avgAgeDays ? h.dataset.avgAgeDays.split(',').map(Number) : [];
        console.log('Chart 5 - Avg Age:', avgAgeProjects.length, 'projects', avgAgeDays);

        if (avgAgeProjects.length === 0) {
            console.warn('No avg age data available');
            ctxAvgAge.parentElement.innerHTML = '<div class="text-center text-muted py-5"><i class="fa-solid fa-inbox fa-2x mb-2"></i><br>Không có dữ liệu</div>';
        } else {
            try {
                const ageColors = avgAgeDays.map(d => d > 30 ? '#ef4444' : d > 20 ? '#f59e0b' : d > 10 ? '#3b82f6' : '#10b981');
                new Chart(ctxAvgAge, {
                    type: 'bar',
                    data: {
                        labels: avgAgeProjects,
                        datasets: [{
                                label: 'Ngày',
                                data: avgAgeDays,
                                backgroundColor: ageColors,
                                borderRadius: 8,
                                borderWidth: 0,
                                barPercentage: 0.6
                            }]
                    },
                    options: {
                        indexAxis: 'y',
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {legend: {display: false}, tooltip: {callbacks: {label: (c) => c.parsed.x + ' ngày'}}},
                        scales: {x: {beginAtZero: true}, y: {ticks: {autoSkip: false}}}
                    },
                    plugins: [shadowPlugin]
                });
                console.log('Chart 5 rendered successfully!');
            } catch (e) {
                console.error('Chart 5 error:', e);
            }
        }
    }

    // 6. SLA Breach Rate
    const ctxSLA = document.getElementById('chartSlaBreach');
    if (ctxSLA) {
        const slaBreached = parseInt(h.dataset.slaBreached || '0');
        const slaOnTime = parseInt(h.dataset.slaOntime || '0');
        const total = slaBreached + slaOnTime;
        console.log('Chart 6 - SLA:', 'breached=', slaBreached, 'ontime=', slaOnTime, 'total=', total);

        if (total === 0) {
            console.warn('No SLA data available');
            ctxSLA.parentElement.innerHTML = '<div class="text-center text-muted py-5"><i class="fa-solid fa-inbox fa-2x mb-2"></i><br>Không có dữ liệu</div>';
        } else {
            try {
                const breachPct = total > 0 ? Math.round(slaBreached * 100 / total) : 0;
                const onTimePct = total > 0 ? Math.round(slaOnTime * 100 / total) : 0;
                new Chart(ctxSLA, {
                    type: 'doughnut',
                    data: {
                        labels: ['Vi phạm', 'Đúng hạn'],
                        datasets: [{data: [slaBreached, slaOnTime], backgroundColor: ['#ef4444', '#10b981'], borderWidth: 1}]
                    },
                    options: {
                        cutout: '65%',
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: {position: 'bottom'},
                            tooltip: {callbacks: {label: (ctx) => ctx.label + ': ' + ctx.parsed + ' (' + (ctx.parsed === slaBreached ? breachPct : onTimePct) + '%)'}}
                        }
                    },
                    plugins: [{
                            id: 'centerText',
                            afterDraw(chart) {
                                const {ctx} = chart;
                                const meta = chart.getDatasetMeta(0);
                                if (!meta || !meta.data || !meta.data.length)
                                    return;
                                ctx.save();
                                ctx.font = '600 18px system-ui';
                                ctx.fillStyle = breachPct > 30 ? '#ef4444' : '#10b981';
                                ctx.textAlign = 'center';
                                ctx.textBaseline = 'middle';
                                const x = meta.data[0].x, y = meta.data[0].y;
                                ctx.fillText(breachPct + '%', x, y - 4);
                                ctx.font = '400 11px system-ui';
                                ctx.fillStyle = '#6c757d';
                                ctx.fillText('Vi phạm', x, y + 16);
                                ctx.restore();
                            }
                        }, shadowPlugin]
                });
                console.log('Chart 6 rendered successfully!');
            } catch (e) {
                console.error('Chart 6 error:', e);
            }
        }
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
    });  // Close .then(result =>
});
