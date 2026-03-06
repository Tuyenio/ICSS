function enableEdit() {
    document.getElementById('btnEditProfile').style.display = 'none';
    document.getElementById('editBtnGroup').style.display = '';
    // Avatar
    document.getElementById('avatarView').style.display = 'none';
    document.getElementById('avatarEdit').style.display = '';
    // Họ tên
    document.getElementById('profileNameView').style.display = 'none';
    document.getElementById('profileNameEdit').style.display = '';
    // SĐT
    document.getElementById('profilePhoneView').style.display = 'none';
    document.getElementById('profilePhoneEdit').style.display = '';
    // Giới tính
    document.getElementById('profileGenderView').style.display = 'none';
    document.getElementById('profileGenderEdit').style.display = '';
    // Ngày sinh
    document.getElementById('profileBirthView').style.display = 'none';
    document.getElementById('profileBirthEdit').style.display = '';
}
function disableEdit() {
    document.getElementById('btnEditProfile').style.display = '';
    document.getElementById('editBtnGroup').style.display = 'none';
    document.getElementById('avatarView').style.display = '';
    document.getElementById('avatarEdit').style.display = 'none';
    document.getElementById('profileNameView').style.display = '';
    document.getElementById('profileNameEdit').style.display = 'none';
    document.getElementById('profilePhoneView').style.display = '';
    document.getElementById('profilePhoneEdit').style.display = 'none';
    document.getElementById('profileGenderView').style.display = '';
    document.getElementById('profileGenderEdit').style.display = 'none';
    document.getElementById('profileBirthView').style.display = '';
    document.getElementById('profileBirthEdit').style.display = 'none';
}
// Xem trước avatar khi nhập URL
document.addEventListener('DOMContentLoaded', function () {
    var avatarUrlInput = document.getElementById('avatarUrlInput');
    if (avatarUrlInput) {
        avatarUrlInput.addEventListener('input', function (e) {
            var url = e.target.value.trim();
            if (url && (url.startsWith('http://') || url.startsWith('https://'))) {
                document.getElementById('avatarPreview').src = url;
            }
        });
    }
});

