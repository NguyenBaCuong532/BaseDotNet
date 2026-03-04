CREATE FUNCTION [dbo].[fn_TKM_ALL_1000_Split](@sIn nvarchar(MAX), @sSeparate nchar(1) ) 
returns @table Table
(
	data nvarchar(255) 
) 
AS
BEGIN
	DECLARE @part nvarchar(255) 
	
	While len(@sIn) > 0 
	BEGIN
		-- Không có dấu phân cách nào
		IF (charindex(@sSeparate, @sIn, 0) = 0) 
		BEGIN
			Insert Into @table(data) VALUES(Ltrim(Rtrim(@sIn) ) ) 
			Select @sIn = ''
		END
		ELSE
		-- lấy phần trước phân cách
		BEGIN
			Select @part = substring(@sIn, 0, charindex(@sSeparate, @sIn, 0) ) 
			SELECT @part = Ltrim(Rtrim(@part) ) 
			--IF NOT EXISTS(SELECT data FROM @table WHERE data = @part) 
				Insert Into @table(data) VALUES(@part) 
			Select @sIn = substring(@sIn, charindex(@sSeparate, @sIn, 0) + 1, len(@sIn) ) 
		END
	END
	return
END