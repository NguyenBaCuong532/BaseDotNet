CREATE   PROCEDURE [dbo].[sp_res_parcel_del]
    @Oid UNIQUEIDENTIFIER,
    @userId NVARCHAR(450) = NULL
AS
BEGIN TRY
    SET NOCOUNT ON;
    
    DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(500) = N'Có lỗi xảy ra';
    DECLARE @Status INT;

    -- Check if record exists
    IF NOT EXISTS (SELECT 1 FROM Parcel WHERE oid = @Oid)
    BEGIN
        SET @valid = 0;
        SET @messages = N'Bản ghi không tồn tại';
        SELECT @valid AS valid, @messages AS [messages];
        RETURN;
    END

    -- Get current status
    SELECT @Status = status
    FROM Parcel
    WHERE oid = @Oid;

    -- Only allow delete for pending parcels (Status = 0)
    IF @Status <> 0
    BEGIN
        SET @valid = 0;
        SET @messages = N'Chỉ có thể xóa bưu phẩm đang chờ nhận';
        SELECT @valid AS valid, @messages AS [messages];
        RETURN;
    END

    -- Delete the record
    DELETE FROM Parcel
    WHERE oid = @Oid;

    SET @valid = 1;
    SET @messages = N'Xóa thành công';

    SELECT @valid AS valid, @messages AS [messages];

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_parcel_del ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = N'@Oid: ' + ISNULL(CAST(@Oid AS NVARCHAR(100)), N'NULL');

    EXEC utl_ErrorLog_Set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'Parcel',
                          'DEL',
                          @SessionID,
                          @AddlInfo;

    SET @valid = 0;
    SET @messages = N'Có lỗi xảy ra: ' + ERROR_MESSAGE();
    SELECT @valid AS valid, @messages AS [messages];
END CATCH;