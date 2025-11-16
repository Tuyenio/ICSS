// ==================== XÉT DUYỆT & GIA HẠN CÔNG VIỆC ====================

// Khi toàn bộ DOM đã sẵn sàng
document.addEventListener("DOMContentLoaded", function () {

    // ==================== XÉT DUYỆT CÔNG VIỆC ====================

    const btnXetDuyet = document.getElementById('btnXetDuyet');
    const btnXacNhanXetDuyet = document.getElementById('btnXacNhanXetDuyet');

    if (btnXetDuyet && btnXacNhanXetDuyet) {

        // Mở modal xét duyệt
        btnXetDuyet.addEventListener('click', function () {
            const taskId = document.querySelector('#formTaskDetail input[name="task_id"]').value;
            const trangThaiDuyet = document.getElementById('trangThaiDuyet')?.value || '';

            // Nếu công việc đã duyệt thì cảnh báo và không mở modal
            if (trangThaiDuyet.trim() === 'Đã duyệt') {
                Swal.fire({
                    icon: 'info',
                    title: 'Công việc đã được duyệt',
                    text: 'Công việc này đã được duyệt, không thể xét duyệt lại!',
                    confirmButtonText: 'Đã hiểu',
                    confirmButtonColor: '#3085d6'
                });
                return;
            }

            // Nếu chưa duyệt hoặc bị từ chối → mở modal bình thường
            document.getElementById('xetDuyetTaskId').value = taskId;
            const modalXetDuyet = new bootstrap.Modal(document.getElementById('modalXetDuyet'));
            modalXetDuyet.show();
        });

        // Xác nhận xét duyệt
        btnXacNhanXetDuyet.addEventListener('click', async function () {
            const taskId = document.getElementById('xetDuyetTaskId').value;
            const quyetDinh = document.getElementById('quyetDinhDuyet').value;
            const lyDo = document.getElementById('lyDoXetDuyet').value;

            if (!lyDo.trim()) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Thiếu lý do',
                    text: 'Vui lòng nhập lý do xét duyệt hoặc từ chối!'
                });
                return;
            }

            // Gửi dữ liệu dạng form
            const formData = new URLSearchParams();
            formData.append('taskId', taskId);
            formData.append('quyetDinh', quyetDinh);
            formData.append('lyDo', lyDo);

            try {
                const res = await fetch('./xetDuyetCongViec', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: formData.toString()
                });
                const data = await res.json();

                if (data.success) {
                    Swal.fire({
                        icon: 'success',
                        title: 'Thành công!',
                        text: 'Đã xét duyệt công việc!',
                        timer: 2000
                    }).then(() => {
                        bootstrap.Modal.getInstance(document.getElementById('modalXetDuyet')).hide();
                        bootstrap.Modal.getInstance(document.getElementById('modalTaskDetail')).hide();
                        location.reload();
                    });
                } else {
                    Swal.fire({
                        icon: 'error',
                        title: 'Lỗi!',
                        text: data.message || 'Không thể xét duyệt công việc'
                    });
                }
            } catch (err) {
                console.error('Lỗi xét duyệt:', err);
                Swal.fire({
                    icon: 'error',
                    title: 'Lỗi kết nối',
                    text: 'Không thể kết nối đến server'
                });
            }
        });
    }


    // ==================== GIA HẠN CÔNG VIỆC ====================

    const btnGiaHan = document.getElementById('btnGiaHan');
    const btnXacNhanGiaHan = document.getElementById('btnXacNhanGiaHan');

    if (btnGiaHan && btnXacNhanGiaHan) {

        // Hiển thị / ẩn form gia hạn
        btnGiaHan.addEventListener('click', function () {
            const giaHanForm = document.getElementById('giaHanForm');
            if (giaHanForm.style.display === 'none') {
                giaHanForm.style.display = 'block';
                this.innerHTML = '<i class="fa-solid fa-times"></i> Hủy';
                this.classList.remove('btn-warning');
                this.classList.add('btn-secondary');
            } else {
                giaHanForm.style.display = 'none';
                this.innerHTML = '<i class="fa-solid fa-clock"></i> Gia hạn công việc';
                this.classList.remove('btn-secondary');
                this.classList.add('btn-warning');
            }
        });

        // Xác nhận gia hạn
        btnXacNhanGiaHan.addEventListener('click', async function () {
            const taskId = document.querySelector('#formTaskDetail input[name="task_id"]').value;
            const ngayGiaHan = document.getElementById('ngayGiaHan').value;

            if (!ngayGiaHan) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Chưa chọn ngày',
                    text: 'Vui lòng chọn ngày gia hạn!'
                });
                return;
            }

            // Gửi dữ liệu dạng form
            const formData = new URLSearchParams();
            formData.append('taskId', taskId);
            formData.append('ngayGiaHan', ngayGiaHan);

            try {
                const res = await fetch('./giaHanCongViec', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: formData.toString()
                });
                const data = await res.json();

                if (data.success) {
                    Swal.fire({
                        icon: 'success',
                        title: 'Gia hạn thành công!',
                        text: 'Công việc đã được gia hạn!',
                        timer: 2000
                    }).then(() => {
                        document.querySelector('#formTaskDetail input[name="han_hoan_thanh"]').value = ngayGiaHan;
                        document.getElementById('giaHanForm').style.display = 'none';
                        document.getElementById('extensionSection').style.display = 'none';
                        btnGiaHan.innerHTML = '<i class="fa-solid fa-clock"></i> Gia hạn công việc';
                        btnGiaHan.classList.remove('btn-secondary');
                        btnGiaHan.classList.add('btn-warning');

                        Swal.fire({
                            icon: 'info',
                            title: 'Lưu ý',
                            text: 'Vui lòng lưu thay đổi để cập nhật!'
                        });
                    });
                } else {
                    Swal.fire({
                        icon: 'error',
                        title: 'Lỗi!',
                        text: data.message || 'Không thể gia hạn công việc'
                    });
                }
            } catch (err) {
                console.error('Lỗi gia hạn:', err);
                Swal.fire({
                    icon: 'error',
                    title: 'Lỗi kết nối',
                    text: 'Không thể kết nối đến server'
                });
            }
        });
    }
});
