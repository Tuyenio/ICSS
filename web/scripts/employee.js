   

            function openAddModal() {
                $('#employeeForm')[0].reset();              // Xóa trắng tất cả field
                $('#empId').val('');                        // Gán ID rỗng => thêm mới
                $('#avatarPreview').attr('src', 'https://ui-avatars.com/api/?name=Avatar');
                $('#modalEmployee').modal('show');          // Mở modal
            }

            document.addEventListener("DOMContentLoaded", function () {
                // Load nhóm công việc
                fetch('./apiPhongban')
                        .then(res => res.text())
                        .then(html => {
                            const defaultOption = '<option value="" selected>Tất cả phòng ban</option>';
                            const finalHTML = defaultOption + html;

                            // Gán cho cả bộ lọc và modal
                            $('#menuloc select[name="ten_phong_ban"]').html(finalHTML);
                            $('#modalnhanvien select[name="ten_phong_ban"]').html(html);

                            // Gán flag đã load xong
                            window.phongBanLoaded = true;
                        });
            });

            //AJAX loc
            $('#btnFilter').on('click', function () {
                const keyword = $('#searchName').val();
                const phongBan = $('#filterDepartment').val();
                const trangThai = $('#filterStatus').val();
                const vaiTro = $('#filterRole').val();

                $.ajax({
                    url: './locNhanvien',
                    type: 'POST',
                    data: {
                        keyword: keyword,
                        phong_ban: phongBan,
                        trang_thai: trangThai,
                        vai_tro: vaiTro
                    },
                    success: function (html) {
                        $('#employeeTableBody').html(html);
                    },
                    error: function () {
                        $('#employeeTableBody').html("<tr><td colspan='13' class='text-danger text-center'>Lỗi khi lọc dữ liệu</td></tr>");
                    }
                });
            });
            // AJAX tìm kiếm realtime
            $('#searchName, #filterDepartment, #filterStatus, #filterRole').on('input change', function () {
                // TODO: AJAX load lại bảng nhân viên theo filter
                // $.get('api/employee', {...}, function(data){ ... });
            });

            function getBadgeClass(status) {
                switch (status) {
                    case 'Đang làm':
                        return 'bg-success';
                    case 'Tạm nghỉ':
                        return 'bg-warning text-dark';
                    case 'Nghỉ việc':
                        return 'bg-danger';
                    default:
                        return 'bg-secondary';
                }
            }

            function getRoleClass(role) {
                switch (role) {
                    case 'Admin':
                        return 'bg-danger text-white';
                    case 'Quản lý':
                        return 'bg-warning text-dark';
                    case 'Nhân viên':
                        return 'bg-info text-dark';
                    default:
                        return 'bg-secondary';
                }
            }
            // Nút xem chi tiết
            $(document).on('click', '.emp-detail-link', function (e) {
                e.preventDefault();

                const email = $(this).data('email');

                $.ajax({
                    url: './chitietNV',
                    method: 'GET',
                    data: {email: email},
                    dataType: 'json',
                    success: function (data) {
                        // Gán dữ liệu vào modal
                        $('#modalEmpDetail .emp-name').text(data.ho_ten);
                        $('#modalEmpDetail .emp-email').text(data.email);
                        $('#modalEmpDetail .emp-phone').text(data.so_dien_thoai);
                        $('#modalEmpDetail .emp-gender').text(data.gioi_tinh);
                        $('#modalEmpDetail .emp-birth').text(data.ngay_sinh);
                        $('#modalEmpDetail .emp-dept').text(data.ten_phong_ban);
                        $('#modalEmpDetail .emp-position').text(data.chuc_vu);
                        $('#modalEmpDetail .emp-start').text(data.ngay_vao_lam);

                        const avatarUrl = data.avatar_url && data.avatar_url.trim() !== ''
                                ? data.avatar_url
                                : 'https://ui-avatars.com/api/?name=' + encodeURIComponent(data.ho_ten || 'User');

                        $('#modalEmpDetail #avatarPreview').attr('src', avatarUrl);

                        // Xử lý badge màu trạng thái
                        const statusClass = getBadgeClass(data.trang_thai_lam_viec);
                        $('#modalEmpDetail .emp-status')
                                .text(data.trang_thai_lam_viec)
                                .removeClass('bg-success bg-warning bg-danger bg-secondary')
                                .addClass(statusClass);

                        // Xử lý badge màu vai trò
                        const roleClass = getRoleClass(data.vai_tro);
                        $('#modalEmpDetail .emp-role')
                                .text(data.vai_tro)
                                .removeClass('bg-danger bg-warning bg-info bg-secondary text-white text-dark')
                                .addClass(roleClass);

                        // Reset tab về tab đầu tiên
                        $('#empDetailTab .nav-link').removeClass('active');
                        $('#empDetailTabContent .tab-pane').removeClass('show active');
                        $('#tab-info').addClass('active');
                        $('#tabInfo').addClass('show active');

                        // Hiển thị modal
                        const modal = new bootstrap.Modal(document.getElementById('modalEmpDetail'));
                        modal.show();
                    },
                    error: function () {
                        showToast('error', 'Không thể tải chi tiết nhân viên');
                    }
                });
            });

            // Xem password
            $(document).on('click', '#togglePassword', function () {
                const input = $('#empPassword');
                const type = input.attr('type') === 'password' ? 'text' : 'password';
                input.attr('type', type);

                // Toggle icon
                $(this).toggleClass('fa-eye fa-eye-slash');
            });
            // Nút sửa
            $(document).on('click', '.edit-emp-btn', function () {
                const button = $(this);
                const phongBanId = button.data('phong-ban-id');

                function fillForm() {
                    $('#empId').val(button.data('id'));
                    $('#empName').val(button.data('name'));
                    $('#empEmail').val(button.data('email'));
                    $('#empPassword').val(button.data('pass'));
                    $('#empPhone').val(button.data('phone'));
                    $('#empGender').val(button.data('gender'));
                    $('#empBirth').val(button.data('birth'));
                    $('#empStartDate').val(button.data('startdate'));

                    // ✅ Gán đúng phòng ban theo ID (ví dụ: <option value="2">Phòng Kỹ thuật</option>)
                    $('#empDepartment').val(phongBanId);

                    $('#empPosition').val(button.data('position'));
                    $('#empStatus').val(button.data('status'));
                    $('#empRole').val(button.data('role'));
                    $('#empAvatar').val(button.data('avatar'));

                    // Avatar preview
                    const avatarUrl = button.data('avatar') || 'https://ui-avatars.com/api/?name=' + encodeURIComponent(button.data('name'));
                    $('#avatarPreview').attr('src', avatarUrl);

                    // Hiển thị modal
                    $('#modalEmployee').modal('show');
                }

                if (CURRENT_USER_CHUCVU.toLowerCase().includes('trưởng phòng')) {
                    $('#empRole').prop('disabled', true); // Không cho chỉnh vai trò nếu người đăng nhập là Trưởng phòng
                } else {
                    $('#empRole').prop('disabled', false);
                }

                // Nếu phòng ban đã load, thì điền luôn
                if (window.phongBanLoaded) {
                    fillForm();
                } else {
                    // Nếu chưa load xong, chờ rồi điền
                    const interval = setInterval(() => {
                        if (window.phongBanLoaded) {
                            clearInterval(interval);
                            fillForm();
                        }
                    }, 100);
                }
            });

            // Nút xoá
            $(document).on('click', '.delete-emp-btn', function () {
                const id = $(this).data('id');
                const row = $(this).closest('tr');

                Swal.fire({
                    title: 'Xác nhận xoá?',
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonText: 'Xoá',
                    cancelButtonText: 'Huỷ'
                }).then((result) => {
                    if (result.isConfirmed) {
                        // Gửi AJAX POST đến Servlet
                        $.ajax({
                            url: './xoaNhanvien',
                            method: 'POST',
                            data: {id: id},
                            success: function (res) {
                                if (res.status === 'ok') {
                                    $('#toastSuccess').toast('show');
                                    row.remove(); // Xoá dòng khỏi bảng
                                } else {
                                    $('#toastError').toast('show');
                                }
                            },
                            error: function () {
                                $('#toastError').toast('show');
                            }
                        });
                    }
                });
            });

            // Submit form thêm/sửa
            $('#employeeForm').on('submit', function (e) {
                e.preventDefault();
                // TODO: AJAX submit form
                $('#modalEmployee').modal('hide');
                $('#toastSuccess').toast('show');
            });

            // Toast init
            $('.toast').toast({delay: 2000});

            // TODO: AJAX load phòng ban cho filter và form
            // TODO: AJAX load phân quyền động cho vai trò từ bảng phan_quyen_chuc_nang
            // TODO: AJAX load lịch sử thay đổi nhân sự cho modalEmpDetail

            // Avatar preview
            $('#empAvatar').on('input', function () {
                $('#avatarPreview').attr('src', $(this).val() || 'https://ui-avatars.com/api/?name=Avatar');
            });

          
           
            $('#employeeForm').on('submit', function (e) {
                e.preventDefault(); // Ngăn form gửi mặc định

                const empId = $('#empId').val(); // Dùng empId để phân biệt thêm/sửa
                const formData = $(this).serialize(); // Lấy toàn bộ dữ liệu form

                const url = empId ? './dsnhanvien' : './themNhanvien';

                $.ajax({
                    url: url,
                    type: 'POST',
                    data: formData,
                    success: function (response) {
                        $('#modalEmployee').modal('hide');
                        showToast('success', empId ? 'Cập nhật thành công' : 'Thêm mới thành công');
                        location.reload(); // Hoặc cập nhật bảng bằng JS
                    },
                    error: function () {
                        showToast('error', empId ? 'Cập nhật thất bại' : 'Thêm mới thất bại');
                    }
                });
            });



            function showToast(type, message) {
                const toastId = type === 'success' ? '#toastSuccess' : '#toastError';
                $(toastId).find('.toast-body').text(message);
                new bootstrap.Toast($(toastId)).show();
            }
          