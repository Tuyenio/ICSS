<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
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

            .group-card {
                background: white;
                padding: 26px;
                border-radius: 14px;
                text-align: center;
                box-shadow: 0 3px 14px rgba(0,0,0,0.08);
                cursor: pointer;
                transition: .25s;
            }
            .group-card:hover {
                transform: translateY(-4px);
                box-shadow: 0 8px 20px rgba(0,0,0,0.15);
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
        </style>

        <script>
            var PAGE_TITLE = '<i class="fa-solid fa-layer-group me-2"></i>Nhóm Dự án';
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
                %>

                <div class="main-content">

                    <h3 class="mb-4"><i class="fa-solid fa-layer-group me-2"></i>Nhóm Dự án</h3>

                    <div class="row g-4">

                        <!-- Template card -->
                        <%!
                            void renderGroupCard(JspWriter out, String ten, String icon, Map<String, Integer> map) throws java.io.IOException {
                                int soLuong = map.getOrDefault(ten, 0);
                                out.write(
                                    "<div class='col-md-4'>" +
                                        "<div class='group-card' onclick=\"location.href='dsDuan?nhom_du_an=" + ten + "'\">" +
                                            "<div class='group-icon'><i class='" + icon + "'></i></div>" +
                                            "<h5 class='mt-3'>" + ten + "</h5>" +
                                            "<div class='project-count'>" + soLuong + " dự án</div>" +
                                        "</div>" +
                                    "</div>"
                                );
                            }
                        %>

                        <%
                            renderGroupCard(out, "Dashboard", "fa-solid fa-chart-line", soLuongMap);
                            renderGroupCard(out, "An ninh bảo mật", "fa-solid fa-shield-halved", soLuongMap);
                            renderGroupCard(out, "Oracle Cloud", "fa-solid fa-cloud", soLuongMap);
                            renderGroupCard(out, "Đào tạo", "fa-solid fa-graduation-cap", soLuongMap);
                            renderGroupCard(out, "Chuyển đổi số", "fa-solid fa-rotate", soLuongMap);
                            renderGroupCard(out, "Khác", "fa-solid fa-box-open", soLuongMap);
                        %>

                    </div>
                </div>
            </div>
        </div>

    </body>
</html>