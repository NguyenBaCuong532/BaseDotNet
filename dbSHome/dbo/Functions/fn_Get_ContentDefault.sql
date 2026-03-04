

CREATE FUNCTION [dbo].[fn_Get_ContentDefault]()
RETURNS nVarchar(4000)
AS
BEGIN
  DECLARE @content as nVarchar(4000)
  set @content = 
  N'<div style="display: block;">
		<p><strong>Nội dung đang được soạn thảo - đây là dữ liệu demo:</strong></p>
					<p>Sunshine Marina Nha Trang Bay - khu nghỉ dưỡng phức hợp 5 sao++ đầu tiên tại Việt Nam áp dụng theo mô hình Integrated Resort. Với quần thể nghỉ dưỡng quy mô tầm cỡ quốc tế, hội tụ mọi hoạt động du lịch, vui chơi, giải trí đỉnh cao của Thế giới, Sunshine Marina Nha Trang Bay hứa hẹn đưa du lịch nghỉ dưỡng Nha Trang bước sang kỷ nguyên mới</p>
                    <ul>
                        <li>Dự án hội tụ đầy đủ đặc điểm của mô hình Integrated Resort, xu hướng nghỉ dưỡng đang bùng nổ trên thế giới.</li>
                        <li>Sunshine Marina Nha Trang Bay tọa lạc trên vị trí đắc địa gắn liền với lịch sử phát triển của du lịch Nha Trang.</li>
                        <li>Dự án được phát triển dựa trên 4 yếu tố quan trọng tác động đến thị trường BĐS nghỉ dưỡng VN: xu hướng thế giới, mô hình siêu đô thị, nhu cầu của thế hệ vàng và CNTT.</li>
                    </ul>
                    <p><strong>Sunshine Marina Nha Trang Bay - Đỉnh cao mới của giới thượng lưu</strong></p>
				</div>'
  RETURN @content
END