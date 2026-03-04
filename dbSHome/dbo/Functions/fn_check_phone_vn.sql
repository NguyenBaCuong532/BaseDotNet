



CREATE FUNCTION [dbo].[fn_check_phone_vn]
(
@phone nvarchar(50)
)
returns bit
as
begin
Declare @KQ bit = 0;	
Declare @So tinyint = 0;	
Declare @i tinyint = 0;	
if (charindex(substring(@phone,1,1),'0')!=0) and (charindex(substring(@phone,2,1),'35789')!=0)
begin
	While (@i< = len(@phone))
	begin
	if (charindex(substring(@phone,@i,1),'0123456789')!=0)
	set @so = @so + 1;
	set @i = @i+1;
	end
	if (@phone = '' or @So = 10)--Điều kiện kiểm tra số đt ở đây	
	Set @KQ=1;
end

return @KQ;
end