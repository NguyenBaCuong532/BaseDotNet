
CREATE   FUNCTION [dbo].[fn_get_meta_file_url] (@sourceOid UNIQUEIDENTIFIER)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    RETURN (
            SELECT TOP 1 dbo.fn_url_absolute(file_url)
            FROM meta_info
            WHERE sourceOid = @sourceOid
            ORDER BY created DESC
            )
END