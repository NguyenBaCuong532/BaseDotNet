
CREATE   FUNCTION [dbo].[GetUserType]
(
    @UserId nvarchar(450)
)
RETURNS int
AS
BEGIN
    DECLARE @userType int;

    SELECT @userType =
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM dbo.Users u
                WHERE u.UserId = @UserId
                  AND u.admin_st = 1
            ) THEN 0  -- super admin

            WHEN EXISTS (
                SELECT 1
                FROM dbo.UserInfo ui
                JOIN dbo.MAS_Customers  mc ON mc.CustId = ui.CustId
                JOIN dbo.MAS_Apartments ma ON ma.Cif_No = mc.Cif_No
                WHERE ui.UserId = @UserId
                  AND ma.IsReceived = 1
            ) THEN 3  -- cư dân

            ELSE -1   -- khách vãng lai
        END;

    RETURN @userType;
END