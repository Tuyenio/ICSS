<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>404 - Page Not Found</title>

        <link href="https://fonts.googleapis.com/css2?family=Arvo:wght@400;700&display=swap" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>

        <style>

            body {
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                background: #fff;
                font-family: 'Arvo', serif;
            }

            .page_404 {
                padding: 80px 0;
                width: 100%;
                text-align: center;
            }

            .four_zero_four_bg {
                background-image: url(https://cdn.dribbble.com/users/285475/screenshots/2083086/dribbble_1.gif);
                background-position: center;
                background-repeat: no-repeat;
                background-size: contain;
                height: 400px; /* ảnh trung tâm */
                margin-bottom: 20px;
            }

            .page_404 h1 {
                font-size: 120px;
                font-weight: 700;
                color: #000;
                margin-bottom: 10px;
            }

            .contant_box_404 {
                margin-top: 20px;
            }

            .contant_box_404 h3 {
                font-size: 28px;
                font-weight: 700;
                margin-bottom: 10px;
            }

            .contant_box_404 p {
                color: #555;
                font-size: 17px;
                margin-bottom: 30px;
            }

            .link_404 {
                color: #fff !important;
                padding: 12px 30px;
                background: #39ac31;
                border-radius: 6px;
                text-decoration: none;
                display: inline-block;
                font-size: 16px;
                transition: all 0.2s ease;
            }

            .link_404:hover {
                opacity: 0.9;
                transform: scale(1.05);
            }

            @media (max-width: 768px) {
                .page_404 h1 {
                    font-size: 90px;
                }
                .four_zero_four_bg {
                    height: 300px;
                }
            }
        </style>
    </head>
    <body>
        <section class="page_404">
            <div class="container">
                <div class="row justify-content-center">
                    <div class="col-lg-8 col-md-10 text-center">

                        <!-- Chữ 404 nằm trên -->
                        <h1>404</h1>
                        <!-- Ảnh GIF -->
                        <div class="four_zero_four_bg"></div>
                        <!-- Nội dung -->
                        <div class="contant_box_404">
                            <h3>Look like you're lost</h3>
                            <p>The page you are looking for is not available!</p>
                            <a href="login.jsp" class="link_404">Go to Home</a>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </body>
</html>