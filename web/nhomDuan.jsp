<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <link rel="icon" type="image/png" href="Img/logoics.png">
        <title>Nhóm Dự án</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <style>
            body {
                background: #f4f6fa;
            }
            .main-content {
                padding: 36px;
                margin-left: 240px;
                min-height:100vh;
            }

            .flip-card {
                background-color: transparent;
                width: 100%;
                height: 250px;
                perspective: 1000px;
            }

            .flip-card-inner {
                position: relative;
                width: 100%;
                height: 100%;
                text-align: center;
                transition: transform 0.6s;
                transform-style: preserve-3d;
            }

            .flip-card:hover .flip-card-inner {
                transform: rotateY(180deg);
            }

            .flip-card-front, .flip-card-back {
                position: absolute;
                width: 100%;
                height: 100%;
                -webkit-backface-visibility: hidden;
                backface-visibility: hidden;
                border-radius: 14px;
                box-shadow: 0 3px 14px rgba(0,0,0,0.08);
                display: flex;
                align-items: center;
                justify-content: center;
                flex-direction: column;
            }

            .flip-card-front {
                background: white;
                padding: 26px;
            }

            .flip-card-back {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                transform: rotateY(180deg);
                padding: 20px;
            }

            .department-option {
                background: rgba(255,255,255,0.2);
                border: 1px solid rgba(255,255,255,0.3);
                border-radius: 8px;
                padding: 15px;
                margin: 10px 0;
                cursor: pointer;
                transition: all 0.3s;
                width: 80%;
            }

            .department-option:hover {
                background: rgba(255,255,255,0.3);
                transform: scale(1.05);
            }

            .group-card {
                background: white;
                padding: 26px;
                border-radius: 14px;
                text-align: center;
                box-shadow: 0 3px 14px rgba(0,0,0,0.08);
                cursor: pointer;
                transition: .25s;
                height: 100%;
                display: flex;
                align-items: center;
                justify-content: center;
                flex-direction: column;
            }
            .group-icon {
                font-size: 36px;
                background: #e8f0fe;
                color: #0d6efd;
                padding: 18px;
                border-radius: 50%;
            }
            .project-count {
                margin-top: 10px;
                font-size: 1.5rem;
                font-weight: 700;
                color: #0d6efd;
            }
            @media (max-width: 991.98px) {
                .main-content {
                    margin-left: 70px !important;
                    padding: 16px;
                }

                /* Nếu sidebar đang là dạng fixed hoặc width lớn */
                .sidebar {
                    width: 70px !important; /* hoặc 0 nếu muốn ẩn */
                }
            }
        </style>

        <script>
            var PAGE_TITLE = '<i class="fa-solid fa-layer-group me-2"></i>Nhóm Dự án';

            function handleDepartmentClick(element) {
                var nhomDuAn = element.getAttribute('data-group');
                var phongBan = element.getAttribute('data-dept');

                // Chuyển đổi tên phòng ban từ viết tắt sang đầy đủ
                var fullPhongBan = '';
                if (phongBan === 'KY_THUAT') {
                    fullPhongBan = 'Phòng Kỹ Thuật';
                } else if (phongBan === 'KINH_DOANH') {
                    fullPhongBan = 'Phòng Kinh Doanh';
                }

                window.location.href = 'dsDuan?nhom_du_an=' + encodeURIComponent(nhomDuAn) + '&phong_ban=' + encodeURIComponent(fullPhongBan);
            }
        </script>
    </head>
    <body>
        <div class="d-flex">
            <%@ include file="sidebar.jsp" %>
            <div class="flex-grow-1">
                <%@ include file="header.jsp" %>
                <%
                    Map<String, Integer> soLuongMap = (Map<String, Integer>) request.getAttribute("mapSoLuongNhom");
                    if (soLuongMap == null) soLuongMap = new HashMap<>();
                    Map<String, Map<String, Integer>> mapPB = (Map<String, Map<String, Integer>>) request.getAttribute("mapSoLuongPB");
                    if (mapPB == null) mapPB = new HashMap<>();
                %>
                <div class="main-content">
                    <h3 class="mb-4"><i class="fa-solid fa-layer-group me-2"></i>Nhóm Dự án</h3>
                    <div class="row g-4">
                        <!-- Template flip card -->
                        <%!
                        void renderFlipCard(JspWriter out, String ten, String icon,
                                            Map<String, Integer> mapNhom,
                                            Map<String, Map<String, Integer>> mapPB) throws java.io.IOException {

                            int soLuong = mapNhom.getOrDefault(ten, 0);

                            // Lấy số lượng phòng ban
                            Map<String, Integer> pbMap = mapPB.getOrDefault(ten, new HashMap<>());
                            int soKT = pbMap.getOrDefault("Phòng Kỹ Thuật", 0);
                            int soKD = pbMap.getOrDefault("Phòng Kinh Doanh", 0);

                            out.write(
                                "<div class='col-md-4'>" +
                                    "<div class='flip-card'>" +
                                        "<div class='flip-card-inner'>" +

                                            "<div class='flip-card-front'>" +
                                                "<div class='group-card'>" +
                                                    "<div class='group-icon'><i class='" + icon + "'></i></div>" +
                                                    "<h5 class='mt-3'>" + ten + "</h5>" +
                                                    "<div class='project-count'>" + soLuong + " dự án</div>" +
                                                "</div>" +
                                            "</div>" +

                                            "<div class='flip-card-back'>" +
                                                "<h5 class='mb-3'>" + ten + "</h5>" +

                                                "<div class='department-option' data-group='" + ten + "' data-dept='KY_THUAT' onclick='handleDepartmentClick(this)'>" +
                                                    "<i class='fa-solid fa-laptop-code me-2'></i>" +
                                                    "<strong>Phòng Kỹ Thuật</strong>" +
                                                    "<span class='badge bg-light text-dark ms-2'>" + soKT + "</span>" +
                                                "</div>" +

                                                "<div class='department-option' data-group='" + ten + "' data-dept='KINH_DOANH' onclick='handleDepartmentClick(this)'>" +
                                                    "<i class='fa-solid fa-handshake me-2'></i>" +
                                                    "<strong>Phòng Kinh Doanh</strong>" +
                                                    "<span class='badge bg-light text-dark ms-2'>" + soKD + "</span>" +
                                                "</div>" +

                                            "</div>" +

                                        "</div>" +
                                    "</div>" +
                                "</div>"
                            );
                        }
                        %>

                        <%
                            renderFlipCard(out, "Dashboard", "fa-solid fa-chart-line", soLuongMap, mapPB);
                            renderFlipCard(out, "An ninh bảo mật", "fa-solid fa-shield-halved", soLuongMap, mapPB);
                            renderFlipCard(out, "Oracle Cloud", "fa-solid fa-cloud", soLuongMap, mapPB);
                            renderFlipCard(out, "Đào tạo", "fa-solid fa-graduation-cap", soLuongMap, mapPB);
                            renderFlipCard(out, "Chuyển đổi số", "fa-solid fa-rotate", soLuongMap, mapPB);
                            renderFlipCard(out, "Khác", "fa-solid fa-box-open", soLuongMap, mapPB);
                        %>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>