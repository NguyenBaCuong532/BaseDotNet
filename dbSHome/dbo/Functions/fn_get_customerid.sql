CREATE FUNCTION [dbo].[fn_get_customerid] (@userId NVARCHAR(50))
RETURNS NVARCHAR(50)
AS
BEGIN
    RETURN (
            SELECT custId
            FROM UserInfo
            WHERE userId = @userId
            )
END