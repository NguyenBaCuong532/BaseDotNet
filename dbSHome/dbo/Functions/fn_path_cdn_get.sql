CREATE FUNCTION [dbo].[fn_path_cdn_get](@url nvarchar(max))
RETURNS nvarchar(max)
AS
BEGIN
    DECLARE @SvgUrl nvarchar(max);

    -- Kiểm tra xem URL có đuôi .svg hay không
    IF @url LIKE '%.svg%' or @url like '%.jpg%' or @url like '%.png%' or @url like '%.jpeg%' or @url like '%.pdf%'
    BEGIN
        -- Cắt bỏ từ dấu '?' trở đi nếu có
        SET @SvgUrl = LEFT(@url, CHARINDEX('?', @url + '?') - 1)
    END
    ELSE
    BEGIN
        -- Nếu không phải đuôi .svg thì giữ nguyên
        SET @SvgUrl = @url
    END

    RETURN @SvgUrl
END;