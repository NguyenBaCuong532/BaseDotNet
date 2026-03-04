CREATE FUNCTION fn_apartment_host_check (
    @apartmentId BIGINT
    , @customerId UNIQUEIDENTIFIER
    )
RETURNS BIT

BEGIN
    DECLARE @host_relation_id INT = 0
    DECLARE @valid_member_status INT = 1
    DECLARE @is_host BIT = 0
    DECLARE @login_name NVARCHAR(100)

    SELECT @login_name = loginName
    FROM UserInfo
    WHERE custId = @customerId

    IF EXISTS (
            SELECT 1
            FROM MAS_Apartments
            WHERE UserLogin = @login_name
            )
        OR EXISTS (
            SELECT 1
            FROM MAS_Apartment_Member
            WHERE ApartmentId = @apartmentId
                AND CustId = @customerId
                AND member_st = @valid_member_status
                AND RelationId = @host_relation_id
            )
        SET @is_host = 1

    RETURN @is_host
END