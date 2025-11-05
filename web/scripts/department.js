
            // Load danh sách nhân viên cho select
            function loadNhanVien() {
                $.get('./apiNhanvien', function (data) {
                    let options = '<option value="">-- Chọn nhân viên --</option>';
                    $(data).each(function (index, item) {
                        const value = $(item).attr('value')?.trim() || '';
                        const text = $(item).text()?.trim() || '';
                        if (value && text) {
                            options += '<option value="' + value + '">' + text + '</option>';
                        }
                    });
                    $('#deptLeader').html(options);
                });
            }

            // Hiển thị modal thêm phòng ban
            function showAddModal() {
                $('#deptId').val('');
                $('#deptName').val('');
                $('#deptLeader').val('');
                $('.modal-title').html('<i class="fa-solid fa-building"></i> Thêm phòng ban mới');
                loadNhanVien();
                $('#modalDepartment').modal('show');
            }

            // Nút sửa phòng ban
            $(document).on('click', '.edit-dept-btn', function () {
                let id = $(this).data('id');
                // Load dữ liệu phòng ban
                $.get('./apiChiTietPhongban?id=' + id, function (data) {
                    $('#deptId').val(data.id);
                    $('#deptName').val(data.ten_phong);
                    loadNhanVien();
                    // Set trưởng phòng sau khi load xong danh sách
                    setTimeout(function () {
                        $('#deptLeader').val(data.truong_phong_id);
                    }, 500);
                    $('.modal-title').html('<i class="fa-solid fa-building"></i> Sửa thông tin phòng ban');
                    $('#modalDepartment').modal('show');
                }).fail(function () {
                    showToast('error', 'Không thể tải thông tin phòng ban!');
                });
            });
            // Nút xóa phòng ban
            $(document).on('click', '.delete-dept-btn', function () {
                let id = $(this).data('id');
                Swal.fire({
                    title: 'Xác nhận xóa?',
                    text: 'Bạn có chắc chắn muốn xóa phòng ban này?',
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonText: 'Xóa',
                    cancelButtonText: 'Hủy',
                    confirmButtonColor: '#dc3545'
                }).then((result) => {
                    if (result.isConfirmed) {
                        $.post('./xoaPhongban', {id: id}, function (response) {
                            if (response.status === 'success') {
                                showToast('success', response.message);
                                setTimeout(function () {
                                    location.reload();
                                }, 1500);
                            } else {
                                showToast('error', response.message);
                            }
                        }, 'json').fail(function () {
                            showToast('error', 'Lỗi khi xóa phòng ban!');
                        });
                    }
                });
            });
            // Submit form thêm/sửa phòng ban
            $('#departmentForm').on('submit', function (e) {
                e.preventDefault();
                let formData = {
                    id: $('#deptId').val(),
                    ten_phong: $('#deptName').val(),
                    truong_phong_id: $('#deptLeader').val()
                };
                let url = formData.id ? './suaPhongban' : './themPhongban';
                $.post(url, formData, function (response) {
                    if (response.status === 'success') {
                        $('#modalDepartment').modal('hide');
                        showToast('success', response.message);
                        setTimeout(function () {
                            location.reload();
                        }, 1500);
                    } else {
                        showToast('error', response.message);
                    }
                }, 'json').fail(function () {
                    showToast('error', 'Lỗi khi lưu dữ liệu!');
                });
            });
            // Hiển thị chi tiết phòng ban
            $(document).on('click', '[data-bs-target="#modalDeptDetail"]', function () {
                let id = $(this).data('id');
                $.get('./apiChiTietPhongban?id=' + id, function (data) {
                    let infoHtml = '<b>Tên phòng ban:</b> ' + data.ten_phong + '<br>';
                    infoHtml += '<b>Trưởng phòng:</b> ' + (data.truong_phong_ten || 'Chưa có') + '<br>';
                    infoHtml += '<b>Tổng nhân viên:</b> ' + data.nhan_vien_list.length + '<br>';
                    infoHtml += '<b>Ngày tạo:</b> ' + formatDate(data.ngay_tao) + '<br><br>';
                    if (data.nhan_vien_list.length > 0) {
                        infoHtml += '<b>Danh sách nhân viên:</b><br>';
                        infoHtml += '<div class="row">';
                        data.nhan_vien_list.forEach(function (nv) {
                            infoHtml += '<div class="col-md-6 mb-2">';
                            infoHtml += '<div class="card card-body p-2">';
                            infoHtml += '<small><b>' + nv.ho_ten + '</b><br>';
                            infoHtml += nv.email + '<br>';
                            infoHtml += '<span class="badge bg-secondary">' + nv.chuc_vu + '</span> ';
                            infoHtml += '<span class="badge bg-info">' + nv.vai_tro + '</span>';
                            infoHtml += '</small></div></div>';
                        });
                        infoHtml += '</div>';
                    } else {
                        infoHtml += '<i class="text-muted">Chưa có nhân viên nào trong phòng ban này.</i>';
                    }

                    $('#tabDeptInfo').html(infoHtml);
                }).fail(function () {
                    $('#tabDeptInfo').html('<div class="alert alert-danger">Không thể tải thông tin phòng ban!</div>');
                });
            });
            // Hàm hiển thị toast
            function showToast(type, message) {
                if (type === 'success') {
                    $('#toastSuccess .toast-body').text(message);
                    $('#toastSuccess').toast('show');
                } else {
                    $('#toastError .toast-body').text(message);
                    $('#toastError').toast('show');
                }
            }

            // Hàm format ngày
            function formatDate(dateString) {
                if (!dateString)
                    return '';
                let date = new Date(dateString);
                return date.getDate().toString().padStart(2, '0') + '/' +
                        (date.getMonth() + 1).toString().padStart(2, '0') + '/' +
                        date.getFullYear();
            }

            // Event listener cho nút thêm mới
            $(document).on('click', '[data-bs-target="#modalDepartment"]', function () {
                showAddModal();
            });
            // Toast init
            $('.toast').toast({delay: 3000});
            // Load dữ liệu ban đầu
            $(document).ready(function () {
                console.log('Trang quản lý phòng ban đã được tải');
            });