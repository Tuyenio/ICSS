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
document.addEventListener('show.bs.modal', function (event) {
    // Kiểm tra xem có đúng modal cần xử lý không
    const modal = event.target;
    if (modal.id !== 'modalEditAttendance')
        return;

    const button = event.relatedTarget;
    if (!button)
        return;

    const attendanceId = button.getAttribute('data-id');
    const row = button.closest('tr');

    // Lấy dữ liệu từ bảng
    const date = row.querySelector('td:nth-child(6)')?.textContent.trim() || '-';
    const checkIn = row.querySelector('td:nth-child(7)')?.textContent.trim() || '-';
    const checkOut = row.querySelector('td:nth-child(8)')?.textContent.trim() || '-';

    // Hàm định dạng giờ
    const formatTime = time => time !== '-' ? time.substring(0, 5) : '';

    // Gán dữ liệu vào modal
    modal.querySelector('#editAttendanceId').value = attendanceId;
    modal.querySelector('input[name="checkInTime"]').value = formatTime(checkIn);
    modal.querySelector('input[name="checkOutTime"]').value = formatTime(checkOut);
});