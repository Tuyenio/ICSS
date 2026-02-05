ALTER TABLE cham_cong ADD COLUMN loai_cham_cong VARCHAR(20) DEFAULT 'office' AFTER check_out;

-- Cập nhật các bản ghi cũ có trang_thai = 'WFH' sang loai_cham_cong = 'WFH'
UPDATE cham_cong 
SET loai_cham_cong = 'WFH' 
WHERE trang_thai = 'WFH';

-- Cập nhật các bản ghi còn lại thành 'office'
UPDATE cham_cong 
SET loai_cham_cong = 'office' 
WHERE loai_cham_cong IS NULL OR loai_cham_cong = '';
