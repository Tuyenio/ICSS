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