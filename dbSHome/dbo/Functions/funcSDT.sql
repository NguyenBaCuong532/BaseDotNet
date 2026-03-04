CREATE function [dbo].[funcSDT]
(
@SoDT nvarchar(Max)
)
returns bit
as
begin
Declare @KQ bit;	
Set @KQ=0;
Declare @So tinyint;	
Set @So=0;
Declare @i	tinyint;	
Set @i=0;
if (charindex(substring(@SoDT,1,1),'0')!=0) and (charindex(substring(@SoDT,2,1),'35789')!=0)
begin
	While (@i<=len(@SoDT))
	begin
	if (charindex(substring(@SoDT,@i,1),'0123456789')!=0)
	Set @So=@So+1;
	Set @i=@i+1;
	end
	if (@SoDT='' or @So=10)--Điều kiện kiểm tra số đt ở đây	
	Set @KQ=1;
	if ISNUMERIC(@SoDT) = 0
	SET @KQ = 0
end

return @KQ;
end