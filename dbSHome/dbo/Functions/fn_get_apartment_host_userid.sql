
CREATE FUNCTION [dbo].[fn_get_apartment_host_userid] (@apartmentId BIGINT)
RETURNS NVARCHAR
AS
BEGIN
    RETURN (
            SELECT userId
            FROM UserInfo a
            WHERE EXISTS (
                    SELECT 1
                    FROM MAS_Apartments sa
                    WHERE sa.ApartmentId = @apartmentId
                        AND sa.UserLogin = a.loginName
                    )
            )
END