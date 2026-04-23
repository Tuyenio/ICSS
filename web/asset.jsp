<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%
    List<Map<String, Object>> danhSachTaiSan = (List<Map<String, Object>>) request.getAttribute("danhSachTaiSan");
    if (danhSachTaiSan == null) danhSachTaiSan = new ArrayList<>();
    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");

    int tongLoaiTaiSan = danhSachTaiSan.size();
    long tongSoLuong = 0;
    double tongGiaTri = 0;
    int sapHetCount = 0;
    Map<String, Integer> thongKeTinhTrang = new LinkedHashMap<>();

    for (Map<String, Object> ts : danhSachTaiSan) {
        int soLuong = 0;
        double giaCa = 0;
        String tinhTrang = "Chưa cập nhật";

        if (ts.get("so_luong") instanceof Number) {
            soLuong = ((Number) ts.get("so_luong")).intValue();
        } else if (ts.get("so_luong") != null) {
            try { soLuong = Integer.parseInt(ts.get("so_luong").toString()); } catch (Exception ignored) {}
        }

        if (ts.get("gia_ca") instanceof Number) {
            giaCa = ((Number) ts.get("gia_ca")).doubleValue();
        } else if (ts.get("gia_ca") != null) {
            try { giaCa = Double.parseDouble(ts.get("gia_ca").toString()); } catch (Exception ignored) {}
        }

        if (ts.get("tinh_trang") != null && !ts.get("tinh_trang").toString().trim().isEmpty()) {
            tinhTrang = ts.get("tinh_trang").toString().trim();
        }

        tongSoLuong += soLuong;
        tongGiaTri += (giaCa * soLuong);
        if (soLuong <= 2) sapHetCount++;

        if (!thongKeTinhTrang.containsKey(tinhTrang)) {
            thongKeTinhTrang.put(tinhTrang, 0);
        }
        thongKeTinhTrang.put(tinhTrang, thongKeTinhTrang.get(tinhTrang) + 1);
    }

    DecimalFormat moneyFmt = new DecimalFormat("#,##0");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <link rel="icon" type="image/png" href="Img/logoics.png">
    <title>Quản lý tài sản</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        var PAGE_TITLE = '<i class="fa-solid fa-boxes-stacked me-2"></i>Quản lý tài sản';
    </script>
    <style>
        body {
            background: #f8fafc;
            font-family: 'Segoe UI', Roboto, sans-serif;
            color: #1e293b;
        }

        .main-content {
            padding: 32px;
            min-height: 100vh;
            margin-left: 240px;
            animation: fadeIn 0.4s ease;
        }

        .page-head {
            border-radius: 16px;
            background: linear-gradient(135deg, #0ea5e9, #4f46e5);
            color: #fff;
            padding: 18px 20px;
            box-shadow: 0 10px 24px rgba(79, 70, 229, 0.2);
            margin-bottom: 18px;
        }

        .card-kpi {
            border: none;
            border-radius: 16px;
            box-shadow: 0 3px 14px rgba(0, 0, 0, 0.08);
            transition: all 0.25s ease;
            overflow: hidden;
        }

        .card-kpi:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.12);
        }

        .kpi-icon {
            width: 44px;
            height: 44px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
        }

        .main-box {
            background: #fff;
            border-radius: 16px;
            box-shadow: 0 3px 14px rgba(0, 0, 0, 0.08);
            padding: 24px;
        }

        .table thead th {
            white-space: nowrap;
            font-weight: 600;
        }

        .table-hover tbody tr:hover {
            background: #eef6ff;
        }

        .status-badge {
            border-radius: 999px;
            padding: 6px 10px;
            font-size: 0.8rem;
            font-weight: 600;
        }

        .table-action .btn {
            width: 34px;
            height: 34px;
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

        .chart-box {
            background: #fff;
            border-radius: 16px;
            box-shadow: 0 3px 14px rgba(0, 0, 0, 0.08);
            padding: 18px;
            min-height: 240px;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(8px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @media (max-width: 1200px) {
            .main-content {
                margin-left: 240px;
            }
        }

        @media (max-width: 992px) {
            .main-content {
                margin-left: 76px;
                padding: 14px;
            }
        }
    </style>
</head>
<body>
<div class="d-flex">
    <%@ include file="sidebar.jsp" %>
    <div class="flex-grow-1">
        <%@ include file="header.jsp" %>

        <div class="main-content">
            <div class="page-head d-flex justify-content-between align-items-center flex-wrap gap-2">
                <div>
                    <h5 class="mb-1"><i class="fa-solid fa-boxes-stacked me-2"></i>Quản lý tài sản</h5>
                    <div class="small opacity-75">Dashboard theo dõi tổng thể tài sản doanh nghiệp</div>
                </div>
                <button class="btn btn-light fw-semibold" data-bs-toggle="modal" data-bs-target="#modalAddAsset">
                    <i class="fa-solid fa-plus me-1"></i>Thêm tài sản
                </button>
            </div>

            <div class="row g-3 mb-3">
                <div class="col-xl-3 col-md-6">
                    <div class="card card-kpi">
                        <div class="card-body d-flex align-items-center justify-content-between">
                            <div>
                                <div class="text-muted small">Tổng loại tài sản</div>
                                <div class="fs-4 fw-bold"><%= tongLoaiTaiSan %></div>
                            </div>
                            <div class="kpi-icon" style="background:#dbeafe;color:#1d4ed8;">
                                <i class="fa-solid fa-layer-group"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-xl-3 col-md-6">
                    <div class="card card-kpi">
                        <div class="card-body d-flex align-items-center justify-content-between">
                            <div>
                                <div class="text-muted small">Tổng số lượng</div>
                                <div class="fs-4 fw-bold"><%= tongSoLuong %></div>
                            </div>
                            <div class="kpi-icon" style="background:#dcfce7;color:#15803d;">
                                <i class="fa-solid fa-cubes"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-xl-3 col-md-6">
                    <div class="card card-kpi">
                        <div class="card-body d-flex align-items-center justify-content-between">
                            <div>
                                <div class="text-muted small">Tổng giá trị tồn kho</div>
                                <div class="fs-5 fw-bold"><%= moneyFmt.format(tongGiaTri) %> VNĐ</div>
                            </div>
                            <div class="kpi-icon" style="background:#fef3c7;color:#b45309;">
                                <i class="fa-solid fa-money-bill-wave"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-xl-3 col-md-6">
                    <div class="card card-kpi">
                        <div class="card-body d-flex align-items-center justify-content-between">
                            <div>
                                <div class="text-muted small">Tài sản sắp hết (<= 2)</div>
                                <div class="fs-4 fw-bold text-danger"><%= sapHetCount %></div>
                            </div>
                            <div class="kpi-icon" style="background:#fee2e2;color:#b91c1c;">
                                <i class="fa-solid fa-triangle-exclamation"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row g-3 mb-3">
                <div class="col-lg-5">
                    <div class="chart-box">
                        <h6 class="mb-3"><i class="fa-solid fa-chart-pie me-2 text-primary"></i>Phân bố tình trạng tài sản</h6>
                        <div style="height:180px;">
                            <canvas id="assetStatusChart"></canvas>
                        </div>
                    </div>
                </div>
                <div class="col-lg-7">
                    <div class="chart-box">
                        <h6 class="mb-3"><i class="fa-solid fa-list-check me-2 text-primary"></i>Gợi ý theo dõi nhanh</h6>
                        <ul class="list-group list-group-flush">
                            <li class="list-group-item d-flex justify-content-between align-items-center px-0">
                                Tổng loại tài sản
                                <span class="badge bg-primary rounded-pill"><%= tongLoaiTaiSan %></span>
                            </li>
                            <li class="list-group-item d-flex justify-content-between align-items-center px-0">
                                Tổng số lượng thiết bị
                                <span class="badge bg-success rounded-pill"><%= tongSoLuong %></span>
                            </li>
                            <li class="list-group-item d-flex justify-content-between align-items-center px-0">
                                Tài sản cần ưu tiên bổ sung
                                <span class="badge bg-danger rounded-pill"><%= sapHetCount %></span>
                            </li>
                            <li class="list-group-item px-0 text-muted small">
                                Dữ liệu được tính theo số lượng và giá hiện tại của từng tài sản trong danh sách bên dưới.
                            </li>
                        </ul>
                    </div>
                </div>
            </div>

            <div class="main-box">
                <% if (success != null && !success.trim().isEmpty()) { %>
                <div class="alert alert-success py-2"><%= success %></div>
                <% } %>
                <% if (error != null && !error.trim().isEmpty()) { %>
                <div class="alert alert-danger py-2"><%= error %></div>
                <% } %>

                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h6 class="mb-0"><i class="fa-solid fa-table-list me-2"></i>Danh sách tài sản chi tiết</h6>
                    <span class="text-muted small">Cập nhật gần nhất theo thứ tự mới nhất</span>
                </div>

                <div class="table-responsive">
                    <table class="table table-bordered table-hover align-middle">
                        <thead class="table-light">
                            <tr>
                                <th>#</th>
                                <th>Tên tài sản</th>
                                <th>Số lượng</th>
                                <th>Tình trạng</th>
                                <th>Giá mỗi đơn vị</th>
                                <th>Tổng giá trị</th>
                                <th>Bảo hành</th>
                                <th>Mô tả</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% if (danhSachTaiSan.isEmpty()) { %>
                            <tr>
                                <td colspan="9" class="text-center text-muted">Chưa có dữ liệu tài sản</td>
                            </tr>
                        <% } else {
                            int stt = 1;
                            for (Map<String, Object> ts : danhSachTaiSan) {
                                int soLuong = 0;
                                double giaCa = 0;
                                if (ts.get("so_luong") instanceof Number) soLuong = ((Number) ts.get("so_luong")).intValue();
                                if (ts.get("gia_ca") instanceof Number) giaCa = ((Number) ts.get("gia_ca")).doubleValue();
                                String tinhTrang = (ts.get("tinh_trang") == null) ? "Chưa cập nhật" : ts.get("tinh_trang").toString();
                                String tinhTrangLower = tinhTrang.toLowerCase();

                                String statusCls = "bg-secondary";
                                if (tinhTrangLower.contains("moi") || tinhTrangLower.contains("tốt") || tinhTrangLower.contains("tot") || tinhTrangLower.contains("đang dùng") || tinhTrangLower.contains("dang dung")) {
                                    statusCls = "bg-success";
                                } else if (tinhTrangLower.contains("sửa") || tinhTrangLower.contains("sua") || tinhTrangLower.contains("bảo trì") || tinhTrangLower.contains("bao tri")) {
                                    statusCls = "bg-warning text-dark";
                                } else if (tinhTrangLower.contains("hỏng") || tinhTrangLower.contains("hong") || tinhTrangLower.contains("thanh lý") || tinhTrangLower.contains("thanh ly")) {
                                    statusCls = "bg-danger";
                                }
                        %>
                            <tr>
                                <td><%= stt++ %></td>
                                <td class="fw-semibold"><%= ts.get("ten_tai_san") %></td>
                                <td>
                                    <span class="badge <%= soLuong <= 2 ? "bg-danger" : "bg-primary" %>"><%= soLuong %></span>
                                </td>
                                <td><span class="status-badge <%= statusCls %>"><%= tinhTrang %></span></td>
                                <td><%= moneyFmt.format(giaCa) %> VNĐ</td>
                                <td class="fw-semibold"><%= moneyFmt.format(giaCa * soLuong) %> VNĐ</td>
                                <td><%= ts.get("bao_hanh") == null ? "" : ts.get("bao_hanh") %></td>
                                <td class="text-muted small"><%= ts.get("mo_ta") == null ? "" : ts.get("mo_ta") %></td>
                                <td class="table-action">
                                    <button class="btn btn-sm btn-outline-primary btn-edit"
                                            data-id="<%= ts.get("id") %>"
                                            data-ten="<%= ts.get("ten_tai_san") %>"
                                            data-soluong="<%= ts.get("so_luong") %>"
                                            data-tinhtrang="<%= ts.get("tinh_trang") %>"
                                            data-giaca="<%= ts.get("gia_ca") %>"
                                            data-baohanh="<%= ts.get("bao_hanh") %>"
                                            data-mota="<%= ts.get("mo_ta") == null ? "" : ts.get("mo_ta") %>">
                                        <i class="fa-solid fa-pen"></i>
                                    </button>
                                    <form action="dsTaiSan" method="post" class="d-inline" onsubmit="return confirm('Xóa tài sản này?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="<%= ts.get("id") %>">
                                        <button type="submit" class="btn btn-sm btn-outline-danger"><i class="fa-solid fa-trash"></i></button>
                                    </form>
                                </td>
                            </tr>
                        <% }
                           }
                        %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="modalAddAsset" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="dsTaiSan" method="post">
                <input type="hidden" name="action" value="add">
                <div class="modal-header">
                    <h5 class="modal-title">Thêm tài sản</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-2">
                        <label class="form-label">Tên tài sản</label>
                        <input type="text" class="form-control" name="ten_tai_san" required>
                    </div>
                    <div class="row g-2">
                        <div class="col-md-6">
                            <label class="form-label">Số lượng</label>
                            <input type="number" min="0" class="form-control" name="so_luong" value="1" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Giá cả</label>
                            <input type="number" min="0" step="0.01" class="form-control" name="gia_ca" value="0">
                        </div>
                    </div>
                    <div class="mb-2 mt-2">
                        <label class="form-label">Tình trạng</label>
                        <input type="text" class="form-control" name="tinh_trang" placeholder="Mới / Đang dùng / Cần sửa...">
                    </div>
                    <div class="mb-2">
                        <label class="form-label">Bảo hành</label>
                        <input type="text" class="form-control" name="bao_hanh" placeholder="Ví dụ: 12 tháng">
                    </div>
                    <div class="mb-2">
                        <label class="form-label">Mô tả</label>
                        <textarea class="form-control" rows="3" name="mo_ta"></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                    <button type="submit" class="btn btn-primary">Lưu</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="modalEditAsset" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="dsTaiSan" method="post">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="id" id="edit_id">
                <div class="modal-header">
                    <h5 class="modal-title">Cập nhật tài sản</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-2">
                        <label class="form-label">Tên tài sản</label>
                        <input type="text" class="form-control" name="ten_tai_san" id="edit_ten_tai_san" required>
                    </div>
                    <div class="row g-2">
                        <div class="col-md-6">
                            <label class="form-label">Số lượng</label>
                            <input type="number" min="0" class="form-control" name="so_luong" id="edit_so_luong" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Giá cả</label>
                            <input type="number" min="0" step="0.01" class="form-control" name="gia_ca" id="edit_gia_ca">
                        </div>
                    </div>
                    <div class="mb-2 mt-2">
                        <label class="form-label">Tình trạng</label>
                        <input type="text" class="form-control" name="tinh_trang" id="edit_tinh_trang">
                    </div>
                    <div class="mb-2">
                        <label class="form-label">Bảo hành</label>
                        <input type="text" class="form-control" name="bao_hanh" id="edit_bao_hanh">
                    </div>
                    <div class="mb-2">
                        <label class="form-label">Mô tả</label>
                        <textarea class="form-control" rows="3" name="mo_ta" id="edit_mo_ta"></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                    <button type="submit" class="btn btn-primary">Cập nhật</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    document.addEventListener('click', function (e) {
        var btn = e.target.closest('.btn-edit');
        if (!btn) return;

        document.getElementById('edit_id').value = btn.getAttribute('data-id') || '';
        document.getElementById('edit_ten_tai_san').value = btn.getAttribute('data-ten') || '';
        document.getElementById('edit_so_luong').value = btn.getAttribute('data-soluong') || '0';
        document.getElementById('edit_tinh_trang').value = btn.getAttribute('data-tinhtrang') || '';
        document.getElementById('edit_gia_ca').value = btn.getAttribute('data-giaca') || '0';
        document.getElementById('edit_bao_hanh').value = btn.getAttribute('data-baohanh') || '';
        document.getElementById('edit_mo_ta').value = btn.getAttribute('data-mota') || '';

        var modal = new bootstrap.Modal(document.getElementById('modalEditAsset'));
        modal.show();
    });

    (function () {
        var labels = [
            <% int _idx = 0; for (Map.Entry<String, Integer> e : thongKeTinhTrang.entrySet()) { %>
            '<%= e.getKey().replace("'", "\\'") %>'<%= (_idx++ < thongKeTinhTrang.size() - 1) ? "," : "" %>
            <% } %>
        ];

        var values = [
            <% int _i = 0; for (Map.Entry<String, Integer> e : thongKeTinhTrang.entrySet()) { %>
            <%= e.getValue() %><%= (_i++ < thongKeTinhTrang.size() - 1) ? "," : "" %>
            <% } %>
        ];

        var ctx = document.getElementById('assetStatusChart');
        if (!ctx) return;

        if (!labels.length) {
            labels = ['Chưa có dữ liệu'];
            values = [1];
        }

        new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: labels,
                datasets: [{
                    data: values,
                    backgroundColor: ['#0ea5e9', '#22c55e', '#f59e0b', '#ef4444', '#6366f1', '#14b8a6', '#a855f7'],
                    borderWidth: 1
                }]
            },
            options: {
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom'
                    }
                }
            }
        });
    })();
</script>
<script src="<%= request.getContextPath() %>/scripts/header.js?v=<%= System.currentTimeMillis() %>"></script>
</body>
</html>
