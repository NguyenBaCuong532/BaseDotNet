
CREATE FUNCTION [dbo].[fn_get_apartment_main] (@custId UNIQUEIDENTIFIER)
RETURNS BIGINT
AS
BEGIN
    DECLARE @apartment_id BIGINT

    SELECT TOP 1 @apartment_id = ApartmentId
    FROM MAS_Apartment_Member
    WHERE CustId = @custId
        AND main_st = 1

    IF @apartment_id IS NULL
    BEGIN
        SELECT TOP 1 @apartment_id = ApartmentId
        FROM MAS_Apartment_Member
        WHERE CustId = @custId
    END

    RETURN @apartment_id
END