CREATE FUNCTION [dbo].[fn_get_member_host] (@custId UNIQUEIDENTIFIER)
RETURNS UNIQUEIDENTIFIER
AS
BEGIN
    DECLARE @ApartmentId INT;
    DECLARE @Oid UNIQUEIDENTIFIER;

    -- Lấy ApartmentId chính
    SELECT TOP 1 @ApartmentId = ApartmentId
    FROM MAS_Apartment_Member
    WHERE CustId = @custId AND main_st = 1;

 -- Lấy Oid tương ứng
    SELECT TOP 1 @Oid = Oid
    FROM MAS_Apartment_Member
    WHERE CustId = @custId AND ApartmentId = @ApartmentId;

    RETURN @Oid;
END