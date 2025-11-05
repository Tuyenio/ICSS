            // Hàm xóa chấm công
            function deleteAttendance(attendanceId) {
                Swal.fire({
                    title: 'Bạn có chắc chắn muốn xóa?',
                    text: 'Hành động này không thể hoàn tác!',
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#d33',
                    confirmButtonText: 'Xóa',
                    cancelButtonText: 'Hủy'
                }).then(function (result) {
                    if (result.isConfirmed) {
                        fetch("dsChamCong?id=" + attendanceId, {
                            method: 'DELETE'
                        })
                                .then(function (response) {
                                    if (response.ok) {
                                        Swal.fire('Đã xóa!', 'Chấm công đã được xóa.', 'success').then(function () {
                                            location.reload();
                                        });
                                    } else {
                                        Swal.fire('Lỗi!', 'Không thể xóa chấm công.', 'error');
                                    }
                                })
                                .catch(function (error) {
                                    Swal.fire('Lỗi!', 'Đã xảy ra lỗi khi xóa.', 'error');
                                });
                    }
                });
            }

            // Hiển thị dữ liệu trong modal sửa chấm công
            $(document).on('show.bs.modal', '#modalEditAttendance', function (event) {
                var button = $(event.relatedTarget);
                var attendanceId = button.data('id');
                var row = button.closest('tr');

                // Lấy dữ liệu từ bảng
                var date = row.find('td:nth-child(6)').text().trim();       // Ngày
                var checkIn = row.find('td:nth-child(7)').text().trim();    // Check-in
                var checkOut = row.find('td:nth-child(8)').text().trim();   // Check-out

                // Gán vào modal
                const formatTime = time => time !== '-' ? time.substring(0, 5) : '';

                $(this).find('#editAttendanceId').val(attendanceId);
                $(this).find('input[name="checkInTime"]').val(formatTime(checkIn));
                $(this).find('input[name="checkOutTime"]').val(formatTime(checkOut));
            });