
CREATE FUNCTION [dbo].[fn_get_apartment_host_userid] (@apartmentId BIGINT)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @userId NVARCHAR(50)

    SELECT @userId = userId
    FROM UserInfo a
    WHERE EXISTS (
            SELECT 1
            FROM MAS_Apartments sa
            WHERE sa.ApartmentId = @apartmentId
                AND sa.UserLogin = a.loginName
            )
        OR EXISTS (
            SELECT TOP 1 1
            FROM MAS_Apartment_Member sb
            WHERE sb.ApartmentId = @apartmentId
                AND sb.CustId = dbo.fn_get_customerid(a.userId)
                AND sb.RelationId = 0
            )

    RETURN @userId
END