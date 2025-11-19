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

        events: CONTEXT + "/dsLichtrinh",  // LOAD dữ liệu từ servlet

        eventClick: function (info) {
            var e = info.event;

            $("#eventForm")[0].reset();
            $("input[name='id']").val(e.id);
            $("input[name='title']").val(e.title);

            $("input[name='start']").val(e.startStr);
            $("input[name='end']").val(e.endStr ? e.endStr.substring(0, 10) : "");

            $("textarea[name='description']").val(e.extendedProps.description || "");

            $("#btnDeleteEvent").show();
            $("#modalEvent").modal("show");
        },

        dateClick: function (info) {
            $("#eventForm")[0].reset();
            $("input[name='start']").val(info.dateStr);
            $("#btnDeleteEvent").hide();
            $("#modalEvent").modal("show");
        }
    });

    calendar.render();

    // Thêm mới
    $("#btnAddSchedule").click(function () {
        $("#eventForm")[0].reset();
        $("input[name='start']").val(todayDate);
        $("#btnDeleteEvent").hide();
        $("#modalEvent").modal("show");
    });

    // Lưu
    $("#eventForm").submit(function (e) {
        e.preventDefault();

        $.ajax({
            url: CONTEXT + "/luuLichTrinh",
            type: "POST",
            contentType: "application/json;charset=UTF-8",
            data: JSON.stringify({
                id: $("input[name='id']").val(),
                title: $("input[name='title']").val(),
                start: $("input[name='start']").val(),
                end: $("input[name='end']").val(),
                description: $("textarea[name='description']").val()
            }),
            success: function (res) {
                if (res.success) {
                    Swal.fire("Đã lưu", "", "success");
                    $("#modalEvent").modal("hide");
                    calendar.refetchEvents();
                }
            }
        });
    });

    // Xóa
    $("#btnDeleteEvent").click(function () {

        $.post(CONTEXT + "/xoaLichTrinh", { id: $("input[name='id']").val() }, function (res) {
            if (res.success) {
                Swal.fire("Đã xóa!", "", "success");
                $("#modalEvent").modal("hide");
                calendar.refetchEvents();
            }
        }, "json");
    });
});
