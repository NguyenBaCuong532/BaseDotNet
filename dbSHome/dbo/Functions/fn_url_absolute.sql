



-- =============================================
-- Author:		duongpx
-- Create date: 1/1/2025 7:26:55 AM
-- Description:	lay link base
-- =============================================
CREATE FUNCTION [dbo].[fn_url_absolute]
(
    @url nvarchar(500)
)
RETURNS nvarchar(max)
AS
BEGIN
	DECLARE @rs nvarchar(max) = null
	-- check if url is null or empty
	IF @url IS NULL OR @url = ''
        RETURN @url;

    -- check if url is absolute
    IF CHARINDEX(N'http://', @url) = 1 OR CHARINDEX(N'https://', @url) = 1
        RETURN @url;

	-- select base url from table sys_config_data where key2 = 'api_storage_url'
	DECLARE @base_url nvarchar(500) = (select value1 from sys_config_data where key_2 = N'api_storage_url')
    
	-- check if base url is null or empty
	IF @base_url IS NULL OR @base_url = ''
        RETURN @url;
	
	-- join base url and url to get absolute url
	SET @rs = @base_url + N'?path=' + @url;

	RETURN @rs;

END