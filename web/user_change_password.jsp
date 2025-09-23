<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <link rel="icon" type="image/png" href="Img/logoics.png">
        <title>Đổi mật khẩu</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <style>
            html, body {
                font-family: 'Inter', 'Roboto', Arial, sans-serif !important;
                background: #f4f6fa;
                color: #23272f;
            }
            /* Responsive styles for included sidebar */
            .main-content {
                padding: 36px 36px 24px 36px;
                min-height: 100vh;
                margin-left: 260px;
            }
            .avatar {
                width: 38px;
                height: 38px;
                border-radius: 50%;
                object-fit: cover;
            }
            .main-box {
                background: #fff;
                border-radius: 14px;
                box-shadow: 0 2px 12px #0001;
                padding: 32px 24px;
            }
            @media (max-width: 1200px) {
                .main-content {
                    margin-left: 240px;
                }
            }
            @media (max-width: 992px) {
                .main-content {
                    padding: 18px 6px;
                    margin-left: 76px;
                }
            }
            @media (max-width: 768px) {
                .main-box {
                    padding: 10px 2px;
                }
            }
            @media (max-width: 576px) {
                .main-content {
                    margin-left: 60px;
                }
            }
        </style>
        <script>
            var USER_PAGE_TITLE = '<i class="fa-solid fa-key me-2"></i>Đổi mật khẩu';
        </script>
    </head>
    <body>
        <%@ include file="sidebarnv.jsp" %>
        <%@ include file="user_header.jsp" %>
        <div class="main-content">
            <div class="main-box mb-3">
                <h3 class="mb-0"><i class="fa-solid fa-key me-2"></i>Đổi mật khẩu</h3>
                <form id="changePasswordForm" class="col-md-6 mx-auto">
                    <div class="mb-3">
                        <label class="form-label">Mật khẩu cũ</label>
                        <input type="password" class="form-control" name="old_password" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Mật khẩu mới</label>
                        <input type="password" class="form-control" name="new_password" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Nhập lại mật khẩu mới</label>
                        <input type="password" class="form-control" name="confirm_password" required>
                    </div>
                    <button type="submit" class="btn btn-primary rounded-pill">Đổi mật khẩu</button>
                </form>
                <div id="msg" class="mt-3"></div>
            </div>
        </div>
    </body>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
                     document.getElementById('changePasswordForm').addEventListener('submit', async function (e) {
                         e.preventDefault();

                         const form = e.target;
                         const fd = new FormData(form);

                         const old_password = (fd.get('old_password') || '').trim();
                         const new_password = (fd.get('new_password') || '').trim();
                         const confirm_password = (fd.get('confirm_password') || '').trim();

                         const msg = document.getElementById('msg');
                         const show = (ok, text) => {
                             msg.className = 'mt-3 alert ' + (ok ? 'alert-success' : 'alert-danger');
                             msg.textContent = text;
                         };

                         // Kiểm tra client
                         if (!old_password || !new_password || !confirm_password)
                             return show(false, 'Vui lòng nhập đầy đủ thông tin.');
                         if (new_password !== confirm_password)
                             return show(false, 'Mật khẩu mới và xác nhận không khớp.');
                         if (new_password.length < 8)
                             return show(false, 'Mật khẩu mới phải tối thiểu 8 ký tự.');
                         if (new_password === old_password)
                             return show(false, 'Mật khẩu mới không được trùng mật khẩu cũ.');

                         try {
                             const res = await fetch('./apidoiMK', {
                                 method: 'POST',
                                 headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
                                 body: new URLSearchParams({old_password, new_password, confirm_password})
                             });

                             const text = await res.text();
                             if (res.ok) {
                                 show(true, text || 'Đổi mật khẩu thành công.');
                                 form.reset();
                             } else {
                                 show(false, text || ('HTTP ' + res.status));
                             }
                         } catch (err) {
                             show(false, 'Có lỗi khi gửi yêu cầu: ' + err);
                         }
                     });
    </script>
</html>