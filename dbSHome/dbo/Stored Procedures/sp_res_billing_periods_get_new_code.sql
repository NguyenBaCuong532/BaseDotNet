CREATE PROCEDURE dbo.sp_res_billing_periods_get_new_code
    @Result NVARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra và tạo SEQUENCE tự động nếu chưa có (Dùng để tạo mã tăng tự động)
    IF NOT EXISTS (SELECT 1 FROM sys.sequences WHERE name = 'seq_billing_periods_new_code')
    BEGIN
        EXEC('
            CREATE SEQUENCE dbo.seq_billing_periods_new_code
            AS BIGINT
            START WITH 1
            INCREMENT BY 1
        ');
    END

    DECLARE @Prefix NVARCHAR(10) = 'KTT';
    DECLARE @MinLength INT = 6;

    SET @Result =
        @Prefix + '_'
--         + CAST(YEAR(GETDATE()) AS CHAR(4)) + '_'
        + RIGHT(
              REPLICATE('0', @MinLength) +
              CAST(NEXT VALUE FOR dbo.seq_billing_periods_new_code AS VARCHAR),
              @MinLength
          );
END