# HƯỚNG DẪN CẬP NHẬT HỆ THỐNG NGHỈ PHÉP

## Tổng quan nâng cấp

Hệ thống nghỉ phép đã được nâng cấp với các tính năng mới:

1. **Logic tính ngày phép tự động theo thâm niên**
   - Nhân viên > 12 tháng: +12 ngày phép mỗi đầu năm
   - Nhân viên < 12 tháng: +1 ngày phép mỗi tháng (nếu vào trước ngày 15)
   
2. **Validation ngày nghỉ lễ và cuối tuần**
   - Chặn không cho chọn thứ 7, chủ nhật
   - Chặn không cho chọn các ngày nghỉ lễ chính thức
   
3. **Chuyển ngày phép năm cũ sang năm mới**
   - Ngày phép năm cũ chưa dùng hết → chuyển sang quý 1 năm sau
   - Hết quý 1 (sau 31/3) → tự động xóa ngày phép năm cũ còn lại
   - Giao diện hiển thị riêng: VD: "5 (2026) + 2 (2025)" ngày

## Các bước triển khai

### Bước 1: Cập nhật Database

Chạy file SQL để cập nhật cấu trúc database:

```bash
# Kết nối MySQL
mysql -u root -p qlns

# Chạy script cập nhật
source d:/ICSS/Back/ICSS/database_update_nghi_phep.sql
```

**Hoặc** sử dụng phpMyAdmin/MySQL Workbench:
1. Mở file `database_update_nghi_phep.sql`
2. Copy toàn bộ nội dung
3. Dán vào SQL query editor và Execute

**Những gì script này làm:**
- Thêm cột `ngay_phep_nam_truoc` và `da_cong_phep_dau_nam` vào bảng `ngay_phep_nam`
- Tạo bảng `ngay_nghi_le` để quản lý các ngày nghỉ lễ
- Tạo bảng `lich_su_cong_phep` để lưu lịch sử cộng phép tự động
- Tạo các Stored Procedures:
  - `sp_cong_phep_dau_nam(nam)` - Cộng phép đầu năm
  - `sp_cong_phep_hang_thang(nam, thang)` - Cộng phép hàng tháng
  - `sp_xoa_phep_nam_cu(nam)` - Xóa phép năm cũ sau quý 1
- Cập nhật trigger `trg_cap_nhat_ngay_phep_sau_duyet` để ưu tiên trừ phép năm cũ trước

### Bước 2: Biên dịch lại Project

```bash
# Di chuyển đến thư mục project
cd d:/ICSS/Back/ICSS

# Nếu đang dùng NetBeans, nhấn Clean and Build (Shift+F11)
# Hoặc chạy Ant build
ant clean-build
```

### Bước 3: Deploy lên Server

```bash
# Deploy bằng NetBeans: nhấn F6 hoặc Run
# Hoặc dùng Ant
ant deploy
```

**Hoặc deploy thủ công:**
1. Copy folder `build/web/*` sang thư mục deploy của GlassFish/Tomcat
2. Restart server

### Bước 4: Khởi tạo dữ liệu ngày phép năm 2025

Chạy script SQL để tính và cập nhật số ngày phép cho năm 2025 theo logic cũ:

```bash
# Kết nối MySQL
mysql -u root -p qlns

# Chạy script tính ngày phép 2025
source d:/ICSS/Back/ICSS/tinh_ngay_phep_2025.sql
```

**Hoặc** sử dụng phpMyAdmin/MySQL Workbench:
1. Mở file `tinh_ngay_phep_2025.sql`
2. Copy toàn bộ nội dung
3. Dán vào SQL query editor và Execute

Script này sẽ:
- Tính số ngày phép cho từng nhân viên dựa trên ngày vào làm
- Nhân viên vào trước 2024: 12 ngày
- Nhân viên vào trong 2024-2025: tính theo số tháng đã làm
- Tự động đánh dấu nhân viên đã đủ 12 tháng

### Bước 5: Thiết lập Scheduled Jobs

Hệ thống **Tự ĐỘNG** cộng phép khi có người dùng truy cập các trang chính của hệ thống (index, dashboard, nghỉ phép...). 

**Không cần thiết lập Task Scheduler hay Cron Job thủ công nữa!**

Filter `LeaveAccrualAutoFilter` đã được tích hợp sẵn và sẽ:
- ✅ Tự động chạy vào ngày 1/1: Cộng phép đầu năm
- ✅ Tự động chạy vào ngày 1 hàng tháng: Cộng phép hàng tháng
- ✅ Tự động chạy vào ngày 1/4: Xóa phép năm cũ
- ✅ Chỉ chạy 1 lần mỗi ngày (lưu trong session)

#### Cách 1: Để hệ thống tự động (Khuyến nghị - Đã tích hợp sẵn)

Không cần làm gì! Khi có người dùng bất kỳ truy cập vào các trang:
- `/index.jsp`
- `/userNghiPhep`
- `/adminNghiPhep`
- `/dsNghiPhep`
- `/user_dashboard.jsp`

Hệ thống sẽ tự động kiểm tra và chạy job nếu cần thiết.

#### Cách 2: Sử dụng Windows Task Scheduler (Tùy chọn - Cho server không có người dùng)

**Job 1: Cộng phép đầu năm (Chạy vào 1/1 hàng năm)**

```powershell
# Tạo task
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-Command `"Invoke-WebRequest -Uri 'http://localhost:8080/ICSS/scheduledLeaveAccrual?action=yearStart&key=ICSS_LEAVE_ACCRUAL_2026'`""
$trigger = New-ScheduledTaskTrigger -Daily -At "00:01AM" -DaysInterval 365
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable
Register-ScheduledTask -TaskName "ICSS - Cộng phép đầu năm" -Action $action -Trigger $trigger -Settings $settings -Description "Tự động cộng 12 ngày phép cho nhân viên đủ 12 tháng vào đầu năm"
```

**Job 2: Cộng phép hàng tháng (Chạy vào ngày 1 hàng tháng)**

```powershell
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-Command `"Invoke-WebRequest -Uri 'http://localhost:8080/ICSS/scheduledLeaveAccrual?action=monthStart&key=ICSS_LEAVE_ACCRUAL_2026'`""
$trigger = New-ScheduledTaskTrigger -Daily -At "00:05AM" -DaysInterval 30
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable
Register-ScheduledTask -TaskName "ICSS - Cộng phép hàng tháng" -Action $action -Trigger $trigger -Settings $settings -Description "Tự động cộng 1 ngày phép cho nhân viên mới mỗi tháng"
```

**Job 3: Xóa phép năm cũ (Chạy vào 1/4 hàng năm)**

```powershell
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-Command `"Invoke-WebRequest -Uri 'http://localhost:8080/ICSS/scheduledLeaveAccrual?action=q2Start&key=ICSS_LEAVE_ACCRUAL_2026'`""
$trigger = New-ScheduledTaskTrigger -Daily -At "00:10AM" -DaysInterval 365
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable
Register-ScheduledTask -TaskName "ICSS - Xóa phép năm cũ" -Action $action -Trigger $trigger -Settings $settings -Description "Tự động xóa phép năm cũ khi hết quý 1"
```

**Kiểm tra tasks:**
```powershell
Get-ScheduledTask | Where-Object {$_.TaskName -like "*ICSS*"}
```

#### Cách 3: Sử dụng Linux/Mac Cron Jobs (Tùy chọn)

```bash
# Mở crontab editor
crontab -e

# Thêm các dòng sau:
# Cộng phép đầu năm - chạy lúc 00:01 ngày 1/1
1 0 1 1 * curl "http://localhost:8080/ICSS/scheduledLeaveAccrual?action=yearStart&key=ICSS_LEAVE_ACCRUAL_2026"

# Cộng phép hàng tháng - chạy lúc 00:05 ngày 1 mỗi tháng  
5 0 1 * * curl "http://localhost:8080/ICSS/scheduledLeaveAccrual?action=monthStart&key=ICSS_LEAVE_ACCRUAL_2026"

# Xóa phép năm cũ - chạy lúc 00:10 ngày 1/4
10 0 1 4 * curl "http://localhost:8080/ICSS/scheduledLeaveAccrual?action=q2Start&key=ICSS_LEAVE_ACCRUAL_2026"
```

#### Cách 4: Chạy thủ công qua trình duyệt (Chỉ để test khẩn cấp)

**Lưu ý:** Chỉ dùng khi cần test hoặc khắc phục sự cố. Bình thường hệ thống đã tự động chạy.

Mở trình duyệt và truy cập các URL sau:

```
# Cộng phép đầu năm
http://localhost:8080/ICSS/scheduledLeaveAccrual?action=yearStart&key=ICSS_LEAVE_ACCRUAL_2026

# Cộng phép hàng tháng
http://localhost:8080/ICSS/scheduledLeaveAccrual?action=monthStart&key=ICSS_LEAVE_ACCRUAL_2026

# Xóa phép năm cũ (sau 31/3)
http://localhost:8080/ICSS/scheduledLeaveAccrual?action=q2Start&key=ICSS_LEAVE_ACCRUAL_2026

# Chạy tự động (phát hiện và chạy job phù hợp theo ngày hiện tại)
http://localhost:8080/ICSS/scheduledLeaveAccrual?action=auto&key=ICSS_LEAVE_ACCRUAL_2026
```

### Bước 6: Cập nhật dữ liệu ngày nghỉ lễ (Hàng năm)

File SQL đã tạo sẵn các ngày lễ 2026. Mỗi năm cần cập nhật lại:

```sql
-- Thêm ngày lễ cho năm mới
INSERT INTO ngay_nghi_le (ten_ngay_le, ngay_bat_dau, ngay_ket_thuc, lap_lai_hang_nam) VALUES
('Tết Nguyên Đán 2027', '2027-02-06', '2027-02-12', 0),
('Giỗ Tổ Hùng Vương 2027', '2027-04-21', '2027-04-21', 0);
```7

### Bước 6: Kiểm tra hoạt động

#### 6.1. Kiểm tra database
```sql
-- Xem cấu trúc bảng đã được cập nhật
DESC ngay_phep_nam;

-- Xem stored procedures
SHOW PROCEDURE STATUS WHERE Db = 'qlns';

-- Xem danh sách ngày nghỉ lễ
SELECT * FROM ngay_nghi_le;
```

#### 6.2. Kiểm tra tính năng trên web

1. **Đăng nhập với tài khoản nhân viên**
2. **Truy cập trang nghỉ phép**: Menu → Nghỉ phép
3. **Kiểm tra hiển thị ngày phép**:
   - Phải thấy số ngày phép năm cũ (nếu có): VD: "10 (2026) + 2 (2025)"
4. **Thử tạo đơn nghỉ phép**:
   - Chọn ngày thứ 7 hoặc chủ nhật → Phải báo lỗi và reset ô input
   - Chọn ngày lễ → Phải báo lỗi và reset ô input
   - Chọn ngày làm việc bình thường → Tạo đơn thành công

#### 6.3. Test scheduled jobs

```powershell
# Test job cộng phép đầu năm
Invoke-WebRequest -Uri "http://localhost:8080/ICSS/scheduledLeaveAccrual?action=yearStart&key=ICSS_LEAVE_ACCRUAL_2026"

# Kiểm tra kết quả
# Vào database xem bảng lich_su_cong_phep
```

```sql
-- Xem lịch sử cộng phép
SELECT ls.*, nv.ho_ten 
FROM lich_su_cong_phep ls
JOIN nhanvien nv ON ls.nhan_vien_id = nv.id
ORDER BY ls.ngay_cong DESC
LIMIT 20;

-- Xem ngày phép của nhân viên
SELECT np.*, nv.ho_ten, nv.ngay_vao_lam
FROM ngay_phep_nam np
JOIN nhanvien nv ON np.nhan_vien_id = nv.id
WHERE np.nam = 2026
ORDER BY nv.ho_ten;
```

#### 7.4. Kiểm tra tự động cộng phép

```sql
-- Xem log trong GlassFish/Tomcat console
-- Khi vào ngày 1 hàng tháng, bạn sẽ thấy log như:
-- "📅 Đầu tháng X/YYYY - Đang cộng phép hàng tháng..."
-- "✅ Đã cộng phép hàng tháng thành công cho tháng X"

-- K3. Về thời gian chạy jobs
- **Đầu năm (1/1)**: Tự động chạy khi có người dùng đầu tiên truy cập trong ngày
- **Đầu tháng (ngày 1)**: Tự động chạy khi có người dùng truy cập trong ngày
- **Đầu quý 2 (1/4)**: Tự động chạy khi có người dùng truy cập trong ngày
- ⚠️ **Nếu lo lắng không có ai truy cập**: Thiết lập Task Scheduler theo Cách 2 hoặc dùng URL thủ công Cách 4
4
**Để force chạy lại trong ngày:**
1. Clear session của user (logout và login lại)
2. Hoặc restart server
3. Hoặc dùng URL thủ công ở Cách 4

## Lưu ý quan trọng

### 1. Về tự động cộng phép
- ✅ **Tự động hoàn toàn**: Không cần cron job hay task scheduler
- ✅ **Chạy khi có người dùng**: Vào ngày đặc biệt (1/1, 1/X, 1/4), người dùng đầu tiên truy cập sẽ trigger job
- ✅ **Chỉ chạy 1 lần/ngày**: Dùng session để lưu, tránh chạy lặp
- ⚠️ **Lưu ý**: Nếu không có ai truy cập hệ thống vào ngày 1/1 hoặc 1/X, job sẽ không chạy → Dùng Cách 2 hoặc 4 để chạy thủ công

### 2. Về Security Key
- Key hiện tại: `ICSS_LEAVE_ACCRUAL_2026`
- **NÊN** thay đổi key này trong production
- Cập nhật key trong file `ScheduledLeaveAccrualJob.java` (dòng 28)
- Cập nhật key trong các scheduled tasks/cron jobs

### 2. Về thời gian chạy jobs
- **Đầu năm (1/1)**: Chạy càng sớm càng tốt (00:01 AM)
- **Đầu tháng (ngày 1)**: Chạy vào 00:05 AM để tránh conflict với job đầu năm
- **Đầu quý 2 (1/4)**: Chạy vào 00:10 AM để xóa phép năm cũ

### 3. Về logic cộng phép
- Nhân viên **đã làm > 12 tháng** tính từ ngày vào làm:
  - Được cộng **12 ngày** một lần vào đầu năm
  - **Không** được cộng phép hàng tháng nữa (có flag `da_cong_phep_dau_nam = 1`)
  
- Nhân viên **chưa đủ 12 tháng**:
  - Được cộng **1 ngày** mỗi đầu tháng (cho tháng trước đó)
  - Nếu vào làm **trước ngày 15** của tháng → tháng đó được tính phép
  - Nếu vào làm **sau ngày 15** của tháng → tháng đó không được tính phép
5
### 4. Về ngày phép năm cũ
- Ngày phép năm N chưa dùng hết → tự động chuyển sang năm N+1 vào 1/1
- Có thể dùng ngày phép năm cũ đến hết quý 1 (31/3)
- Từ 1/4 trở đi, ngày phép năm cũ sẽ bị xóa (không dùng được nữa)
- Khi duyệt đơn nghỉ phép: ưu tiên trừ phép năm cũ trước, sau đó mới trừ phép năm mới

### 6. Về validation
- **Không cho phép** đăng ký nghỉ phép vào:
  - Thứ 7 (Saturday)
  - Chủ nhật (Sunday)
  - Các ngày nghỉ lễ trong bảng `ngay_nghi_le`
- Khi chọn sai → hiện thông báo và reset ô input về trống

## Troubleshooting

### Lỗi: Scheduled job không chạy

**Kiểm tra:**
1. Server có đang chạy không?
2. URL có đúng không? (port, context path)
3. Security key có đúng không?
4. Xem log của scheduled task/cron job

**Giải pháp:**
- Windows: Xem Event Viewer → Task Scheduler
- Linux: Xem log: `grep CRON /var/log/syslog`

### Lỗi: Không thấy ngày phép năm cũ

**Kiểm tra:**
```sql
SELECT * FROM ngay_phep_nam WHERE nhan_vien_id = [ID_NHAN_VIEN];
```

**Nguyên nhân có thể:**
- Chưa chạy procedure `sp_cong_phep_dau_nam` cho năm mới
- Đã qua ngày 31/3 (phép năm cũ đã bị xóa)

### Lỗi: Nhân viên không được cộng phép

**Kiểm tra:**
1. Ngày vào làm của nhân viên
2. Trạng thái làm việc (`trang_thai_lam_viec = 'Đang làm'`)
3. Log trong bảng `lich_su_cong_phep`

```sql
-- Xem nhân viên có đủ điều kiện không
SELECT id, ho_ten, ngay_vao_lam, trang_thai_lam_viec,
       TIMESTAMPDIFF(MONTH, ngay_vao_lam, NOW()) as thang_lam_viec
FROM nhanvien
WHERE trang_thai_lam_viec = 'Đang làm';
```

### Lỗi: Không chặn được ngày cuối tuần

**Kiểm tra:**
- Cache của trình duyệt → Ctrl+F5 để hard refresh
- File `user_leave.jsp` và `admin_leave.jsp` đã được deploy đúng chưa

## Các file đã thay đổi

| File | Mô tả thay đổi |
|------|----------------|
| `database_update_nghi_phep.sql` | Script SQL cập nhật database (mới) |
| `tinh_ngay_phep_2025.sql` | Script tính ngày phép năm 2025 theo logic cũ (mới) |
| `src/java/controller/ScheduledLeaveAccrualJob.java` | Servlet xử lý scheduled jobs thủ công (mới) |
| `src/java/controller/LeaveAccrualAutoFilter.java` | Filter tự động cộng phép khi có người dùng (mới) |
| `src/java/controller/KNCSDL.java` | Thêm các phương thức mới cho nghỉ phép |
| `src/java/controller/apiNghiPhep.java` | Thêm validation ngày lễ/cuối tuần |
| `web/user_leave.jsp` | Cập nhật giao diện hiển thị và validation |
| `web/admin_leave.jsp` | Cập nhật giao diện hiển thị và validation |

## Liên hệ hỗ trợ

Nếu gặp vấn đề trong quá trình triển khai, vui lòng liên hệ:
- Email: support@icss.com.vn
- Hotline: 0900 000 001

---

**Lưu ý cuối:** Sau khi triển khai xong, nên test kỹ trên môi trường staging trước khi áp dụng lên production!
