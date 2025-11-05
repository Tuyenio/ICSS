                                // 🏢 Toạ độ công ty
                                var companyLat = 20.980189371343553;   // vĩ độ
                                var companyLng = 105.81390992866262;  // kinh độ
                                var ALLOWED_RADIUS_METERS = 100; // bán kính cho phép (mét)

                                $(document).ready(function () {

                                    // Hàm tính khoảng cách giữa 2 điểm (Haversine)
                                    function calculateDistance(lat1, lon1, lat2, lon2) {
                                        var R = 6371e3; // bán kính Trái Đất (m)
                                        var dPhi = (lat2 - lat1) * Math.PI / 180;
                                        var dLambda = (lon2 - lon1) * Math.PI / 180;
                                        var a = Math.sin(dPhi / 2) * Math.sin(dPhi / 2) +
                                                Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
                                                Math.sin(dLambda / 2) * Math.sin(dLambda / 2);
                                        var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
                                        return R * c;
                                    }

                                    // ✅ Sự kiện click Check-in
                                    $('#btnCheckIn').click(function () {
                                        Swal.fire({
                                            title: 'Xác nhận check-in?',
                                            text: 'Bạn có chắc chắn muốn check-in không?',
                                            icon: 'question',
                                            showCancelButton: true,
                                            confirmButtonColor: '#3085d6',
                                            cancelButtonColor: '#d33',
                                            confirmButtonText: 'Có, check-in!',
                                            cancelButtonText: 'Hủy'
                                        }).then(function (result) {
                                            if (result.isConfirmed) {
                                                if (navigator.geolocation) {
                                                    navigator.geolocation.getCurrentPosition(
                                                            function (position) {
                                                                var userLat = position.coords.latitude;
                                                                var userLng = position.coords.longitude;
                                                                var distance = calculateDistance(userLat, userLng, companyLat, companyLng);

                                                                if (distance <= ALLOWED_RADIUS_METERS) {
                                                                    performCheckIn();
                                                                } else {
                                                                    Swal.fire({
                                                                        icon: 'warning',
                                                                        title: 'Quá xa vị trí công ty!',
                                                                        text: 'Khoảng cách hiện tại là ' + Math.round(distance) +
                                                                                ' m, vượt quá giới hạn ' + ALLOWED_RADIUS_METERS + ' m.'
                                                                    });
                                                                }
                                                            },
                                                            function (error) {
                                                                Swal.fire({
                                                                    icon: 'error',
                                                                    title: 'Không thể lấy vị trí!',
                                                                    text: 'Vui lòng bật GPS và cho phép truy cập vị trí để check-in.'
                                                                });
                                                            }
                                                    );
                                                } else {
                                                    Swal.fire({
                                                        icon: 'error',
                                                        title: 'Trình duyệt không hỗ trợ định vị!',
                                                        text: 'Thiết bị của bạn không hỗ trợ lấy vị trí.'
                                                    });
                                                }
                                            }
                                        });
                                    });

                                    // ✅ Sự kiện click Check-out
                                    $('#btnCheckOut').click(function () {
                                        Swal.fire({
                                            title: 'Xác nhận check-out?',
                                            text: 'Bạn có chắc chắn muốn check-out không?',
                                            icon: 'question',
                                            showCancelButton: true,
                                            confirmButtonColor: '#3085d6',
                                            cancelButtonColor: '#d33',
                                            confirmButtonText: 'Có, check-out!',
                                            cancelButtonText: 'Hủy'
                                        }).then(function (result) {
                                            if (result.isConfirmed) {
                                                performCheckOut();
                                            }
                                        });
                                    });
                                });

                                // ✅ Gọi AJAX Check-in
                                function performCheckIn() {
                                    showLoading();
                                    $('#btnCheckIn').prop('disabled', true);

                                    $.ajax({
                                        url: './userChamCong',
                                        type: 'POST',
                                        data: {action: 'checkin'},
                                        dataType: 'json',
                                        success: function (response) {
                                            hideLoading();
                                            if (response.success) {
                                                Swal.fire({
                                                    icon: 'success',
                                                    title: 'Check-in thành công!',
                                                    text: response.message,
                                                    showConfirmButton: false,
                                                    timer: 2000
                                                }).then(function () {
                                                    location.reload();
                                                });
                                            } else {
                                                Swal.fire({
                                                    icon: 'error',
                                                    title: 'Lỗi check-in!',
                                                    text: response.message
                                                });
                                                $('#btnCheckIn').prop('disabled', false);
                                            }
                                        },
                                        error: function () {
                                            hideLoading();
                                            Swal.fire({
                                                icon: 'error',
                                                title: 'Lỗi kết nối!',
                                                text: 'Không thể kết nối đến server. Vui lòng thử lại!'
                                            });
                                            $('#btnCheckIn').prop('disabled', false);
                                        }
                                    });
                                }

                                // ✅ Gọi AJAX Check-out
                                function performCheckOut() {
                                    showLoading();
                                    $('#btnCheckOut').prop('disabled', true);

                                    $.ajax({
                                        url: './userChamCong',
                                        type: 'POST',
                                        data: {action: 'checkout'},
                                        dataType: 'json',
                                        success: function (response) {
                                            hideLoading();
                                            if (response.success) {
                                                Swal.fire({
                                                    icon: 'success',
                                                    title: 'Check-out thành công!',
                                                    text: response.message,
                                                    showConfirmButton: false,
                                                    timer: 2000
                                                }).then(function () {
                                                    location.reload();
                                                });
                                            } else {
                                                Swal.fire({
                                                    icon: 'error',
                                                    title: 'Lỗi check-out!',
                                                    text: response.message
                                                });
                                                $('#btnCheckOut').prop('disabled', false);
                                            }
                                        },
                                        error: function () {
                                            hideLoading();
                                            Swal.fire({
                                                icon: 'error',
                                                title: 'Lỗi kết nối!',
                                                text: 'Không thể kết nối đến server. Vui lòng thử lại!'
                                            });
                                            $('#btnCheckOut').prop('disabled', false);
                                        }
                                    });
                                }

                                // ✅ Loading overlay
                                function showLoading() {
                                    $('#loadingOverlay').show();
                                }
                                function hideLoading() {
                                    $('#loadingOverlay').hide();
                                }

                                // ✅ Lọc theo tháng
                                function filterByMonth() {
                                    var thang = document.getElementById('filterThang').value;
                                    var nam = document.getElementById('filterNam').value;
                                    window.location.href = './userChamCong?thang=' + thang + '&nam=' + nam;
                                }