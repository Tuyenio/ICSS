<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Chào mừng</title>
        <style>
            body, html {
                margin: 0;
                padding: 0;
                overflow: hidden;
                height: 100%;
                width: 100%;
                background-color: black;
            }

            .splash-screen {
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
            }

            video {
                width: 100%;
                height: 100%;
                object-fit: cover;
            }

            .slide-out {
                animation: slideOut 1s forwards;
            }

            @keyframes slideOut {
                0% {
                    transform: translateX(0);
                    opacity: 1;
                }
                100% {
                    transform: translateX(-100%);
                    opacity: 0;
                }
            }
        </style>
    </head>
    <body>
        <div class="splash-screen" id="splashScreen">
            <video autoplay muted playsinline id="introVideo">
                <source src="Img/123a.mp4" type="video/mp4">
                Trình duyệt của bạn không hỗ trợ video.
            </video>
        </div>

        <script>
            setTimeout(() => {
                const splash = document.getElementById("splashScreen");
                splash.classList.add("slide-out");

                setTimeout(() => {
                    window.location.href = "login.jsp";
                }, 1000); // thời gian hiệu ứng slide
            }, 8000); // thời gian chạy video (7 giây)
        </script>
    </body>
</html>
