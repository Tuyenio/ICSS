
            // Demo dữ liệu lịch trình
            var demoEvents = [
                {id: 1, title: 'Công tác Hà Nội', start: '2025-09-18', end: '2025-09-20', description: 'Đi công tác gặp đối tác.'},
                {id: 2, title: 'Họp dự án', start: '2025-09-22', description: 'Họp với team dự án Web.'}
            ];

            // Ngày hiện tại từ server
            var todayDate = '<%= todayStr %>';

            let calendar;  // biến toàn cục

            document.addEventListener('DOMContentLoaded', function () {
                var calendarEl = document.getElementById('calendar');
                calendar = new FullCalendar.Calendar(calendarEl, {
                    initialView: 'dayGridMonth',
                    locale: 'vi',
                    height: 650,
                    headerToolbar: {
                        left: 'prev,next today',
                        center: 'title',
                        right: 'dayGridMonth,timeGridWeek,timeGridDay'
                    },
                    events: "dsLichtrinh",
                    eventClick: function (info) {
                        var event = info.event;
                        $("#eventForm")[0].reset();
                        $("#eventForm input[name='id']").val(event.id);
                        $("#eventForm input[name='title']").val(event.title);
                        $("#eventForm input[name='start']").val(event.startStr);
                        $("#eventForm input[name='end']").val(event.endStr ? event.endStr.split('T')[0] : '');
                        $("#eventForm textarea[name='description']").val(event.extendedProps.description || '');
                        // Ẩn nút Lưu và Xóa để chỉ xem
                        $("#eventForm button[type='submit']").hide();
                        $('#btnDeleteEvent').hide();
                        $("#modalEvent").modal("show");
                    },
                });
                calendar.render();

                // Xử lý nút "Thêm lịch trình" - set ngày hiện tại và ẩn nút xóa
                $('#btnAddSchedule').on('click', function () {
                    $("#eventForm")[0].reset();
                    $("#eventForm input[name='start']").val(todayDate);
                    $('#btnDeleteEvent').hide();
                    $("#modalEvent").modal("show");
                });

                // Lưu lịch trình
                $("#eventForm").on("submit", function (e) {
                    e.preventDefault();
                    let formData = $(this).serialize();
                    $.post("luuLichTrinh", formData, function (res) {
                        console.log("Kết quả server:", res);  // 👈 in ra console kiểm tra
                        if (res.success) {
                            Swal.fire({
                                icon: 'success',
                                title: 'Thành công',
                                text: 'Đã lưu lịch trình!',
                                timer: 1500,
                                showConfirmButton: false
                            }).then(() => {
                                $("#modalEvent").modal("hide");
                                calendar.refetchEvents();
                            });
                        } else {
                            Swal.fire('Lỗi', res.message || 'Không thể lưu', 'error');
                        }
                    }, "json").fail(function (xhr) {
                        console.error("AJAX lỗi:", xhr.responseText);  // 👈 xem lỗi
                    });
                });

                // Xóa lịch trình
                $('#btnDeleteEvent').on('click', function () {
                    let id = $("#eventForm input[name='id']").val();
                    if (id) {
                        $.post("xoaLichTrinh", {id: id}, function (res) {
                            if (res.success) {
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Đã xóa!',
                                    text: 'Lịch trình đã được xóa',
                                    timer: 1500,
                                    showConfirmButton: false
                                }).then(() => {
                                    $("#modalEvent").modal("hide");   // đóng modal
                                    calendar.refetchEvents();        // load lại dữ liệu
                                });
                            } else {
                                Swal.fire('Lỗi', res.message || 'Không thể xóa', 'error');
                            }
                        }, "json");
                    }
                });
            });