function hasPermission(code) {
    return USER_PERMISSIONS && USER_PERMISSIONS.includes(code);
}

document.addEventListener("DOMContentLoaded", function () {

    if (!hasPermission("xem_chamcong")) {

        $("tbody").html(`
            <tr>
                <td colspan="12" class="text-center py-4 text-danger">
                    <i class="fa-solid fa-ban fs-1"></i>
                    <p class="mt-2 mb-0">Bạn không có quyền xem dữ liệu chấm công</p>
                </td>
            </tr>
        `);

        // Ẩn hai nút hành động chính
        $(".btn-action-primary").hide(); // Thêm chấm công
        $(".btn-action-success").hide(); // Xuất phiếu công

        return; // không cần kiểm tra tiếp
    }

    if (!hasPermission("quanly_chamcong")) {
        $(".btn-action-primary").hide(); // nút "Thêm chấm công"
        $("#modalAddAttendance button[type=submit]").hide(); // nút lưu trong modal
    }

    if (!hasPermission("quanly_chamcong")) {
        $(".btn-warning").remove(); // nút sửa
        $("#modalEditAttendance button[type=submit]").hide();
    }

    if (!hasPermission("quanly_chamcong")) {
        $(".btn-danger").remove(); // nút xóa
    }

    if (!hasPermission("xem_chamcong")) {
        $(".btn-info").remove(); // nút xem chi tiết
        $(".attendance-emp-detail").css("pointer-events", "none")
            .removeClass("text-primary")
            .addClass("text-muted");
    }

    if (!hasPermission("xem_luong")) {
        $(".btn-action-success").hide(); // nút "Xuất phiếu chấm công"
        $("#modalExportPayroll button[type=submit]").hide();
    }

    if (!hasPermission("xem_chamcong")) {
        $("#tab-att-report").hide(); // ẩn tab báo cáo
    }

});

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
    const modal = event.target;
    const button = event.relatedTarget;
    
    // Xử lý modal sửa chấm công
    if (modal.id === 'modalEditAttendance') {
        if (!button) return;

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
    }
    
    // Xử lý modal chi tiết chấm công
    if (modal.id === 'modalDetailAttendance') {
        if (!button) return;
        
        const attendanceId = button.getAttribute('data-id');
        const row = button.closest('tr');
        
        if (!attendanceId || !row) return;
        
        // Lấy dữ liệu từ row
        const cells = row.querySelectorAll('td');
        
        // Extract data từ các cột: #, Avatar, Họ tên, Phòng ban, Ngày vào, Ngày, Check-in, Check-out, Số giờ, Trạng thái, Hành động
        const avatarImg = row.querySelector('td:nth-child(2) img');
        const avatar = avatarImg?.src || './Img/default-avatar.png';
        const employeeName = cells[2]?.textContent.trim() || '-';
        const department = cells[3]?.textContent.trim() || '-';
        const attendanceDate = cells[5]?.textContent.trim() || '-';
        const checkIn = cells[6]?.textContent.trim() || '-';
        const checkOut = cells[7]?.textContent.trim() || '-';
        const workingHours = cells[8]?.textContent.trim() || '-';
        const statusElement = cells[9]?.querySelector('.badge');
        const statusText = statusElement?.textContent.trim() || '-';
        const statusClass = statusElement?.className || 'badge bg-secondary';
        
        // Cập nhật thông tin vào modal
        const modalAvatar = modal.querySelector('#modalEmployeeAvatar');
        const modalName = modal.querySelector('#modalEmployeeName');
        const modalDept = modal.querySelector('#modalEmployeeDepartment');
        const modalDate = modal.querySelector('#modalAttendanceDate');
        const modalCheckIn = modal.querySelector('#modalCheckIn');
        const modalCheckOut = modal.querySelector('#modalCheckOut');
        const modalHours = modal.querySelector('#modalWorkingHours');
        const modalStatus = modal.querySelector('#modalAttendanceStatus');
        
        if (modalAvatar) {
            modalAvatar.src = avatar;
            modalAvatar.onerror = function() {
                this.src = './Img/default-avatar.png';
            };
        }
        if (modalName) modalName.textContent = employeeName;
        if (modalDept) modalDept.textContent = department;
        if (modalDate) modalDate.textContent = attendanceDate;
        if (modalCheckIn) modalCheckIn.textContent = checkIn;
        if (modalCheckOut) modalCheckOut.textContent = checkOut;
        if (modalHours) modalHours.textContent = workingHours;
        if (modalStatus) {
            modalStatus.textContent = statusText;
            modalStatus.className = statusClass;
        }
        
        // Load báo cáo
        loadEmployeeReports(attendanceId);
    }
});

// Hàm load báo cáo của chấm công cụ thể
function loadEmployeeReports(attendanceId) {
    const reportContainer = document.getElementById('reportContent');
    
    // Hiển thị loading
    reportContainer.innerHTML = `
        <div class="text-center">
            <div class="spinner-border spinner-border-sm text-primary" role="status">
                <span class="visually-hidden">Loading...</span>
            </div>
            <span class="ms-2">Đang tải...</span>
        </div>
    `;
    
    // AJAX call để lấy báo cáo theo attendance ID
    fetch(`dsChamCong?action=getReportByAttendance&attendanceId=${attendanceId}`)
        .then(response => response.json())
        .then(data => {
            if (data.success && data.report) {
                const report = data.report;
                
                if (report.has_report && report.bao_cao && report.bao_cao.trim() !== '') {
                    // Có báo cáo
                    const formattedContent = report.bao_cao.replace(/\n/g, '<br>');
                    
                    const html = `
                        <div class="p-3">
                            <div class="card">
                                <div class="card-header d-flex justify-content-between align-items-center py-2">
                                    <small class="text-muted mb-0">
                                        <i class="fas fa-calendar-day me-1"></i>
                                        Ngày: ${report.ngay}
                                    </small>
                                    <small class="text-muted mb-0">
                                        <i class="fas fa-user me-1"></i>
                                        ${report.ho_ten || 'N/A'}
                                    </small>
                                </div>
                                <div class="card-body py-3">
                                    <div class="bg-light p-3 rounded border">
                                        <p class="mb-0" style="white-space: pre-wrap;">${formattedContent}</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    `;
                    reportContainer.innerHTML = html;
                } else {
                    // Chưa có báo cáo nhưng có record
                    reportContainer.innerHTML = `
                        <div class="alert alert-info d-flex align-items-center m-3">
                            <i class="fas fa-info-circle me-2"></i>
                            <div>
                                <strong>Ngày ${report.ngay} - ${report.ho_ten || 'N/A'}</strong><br>
                                <span>Chưa có báo cáo nào được gửi cho ngày chấm công này.</span>
                            </div>
                        </div>
                    `;
                }
            } else {
                reportContainer.innerHTML = `
                    <div class="alert alert-warning d-flex align-items-center m-3">
                        <i class="fas fa-exclamation-triangle me-2"></i>
                        <span>${data.message || 'Không tìm thấy thông tin chấm công.'}</span>
                    </div>
                `;
            }
        })
        .catch(error => {
            reportContainer.innerHTML = `
                <div class="alert alert-danger d-flex align-items-center m-3">
                    <i class="fas fa-exclamation-triangle me-2"></i>
                    <span>Lỗi khi tải báo cáo.</span>
                </div>
            `;
        });
}