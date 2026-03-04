
CREATE PROCEDURE [dbo].[sp_res_card_family_set]
    @UserID NVARCHAR(450) = NULL,
    @CardCd NVARCHAR(50) = NULL,
    @CustId NVARCHAR(50) = NULL,
    @ImageUrl NVARCHAR(250) = NULL,
    @IssueDate NVARCHAR(50) = NULL,
    @ExpireDate NVARCHAR(50) = NULL,
    @CardTypeId INT = NULL,
    @CurrentPoint NVARCHAR(50) = NULL,
    @StatusName NVARCHAR(50) = NULL,
    @fullname NVARCHAR(50) = NULL,
    @RoomCode NVARCHAR(50) = NULL,
    @CardTypeName NVARCHAR(50) = NULL,
    @ApartmentId NVARCHAR(50) = NULL,
    @CardStatus NVARCHAR(50) = NULL
AS
BEGIN TRY
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @valid BIT = 0,
            @messages NVARCHAR(250) = N'';

    IF ISNULL(NULLIF(LTRIM(RTRIM(@CardCd)),''),'') = ''
    BEGIN
        SET @messages = N'CardCd bắt buộc';
        RAISERROR(@messages, 16, 1);
        RETURN;
    END

    IF ISNULL(NULLIF(LTRIM(RTRIM(@CustId)),''),'') = ''
    BEGIN
        SET @messages = N'CustId bắt buộc';
        RAISERROR(@messages, 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM MAS_Customers WHERE CustId = @CustId)
    BEGIN
        SET @messages = N'Không tìm thấy thông tin khách hàng [' + @CustId + N']!';
        RAISERROR(@messages, 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM MAS_Cards WHERE CardCd = @CardCd)
    BEGIN
        SET @messages = N'Không tìm thấy thẻ [' + @CardCd + N']!';
        RAISERROR(@messages, 16, 1);
        RETURN;
    END

    DECLARE @IssueDt  DATETIME = TRY_CONVERT(DATETIME, @IssueDate, 103);
    DECLARE @ExpireDt DATETIME = TRY_CONVERT(DATETIME, @ExpireDate, 103);

    DECLARE @LocalTran BIT = 0;
    IF (@@TRANCOUNT = 0)
    BEGIN
        SET @LocalTran = 1;
        BEGIN TRAN;
    END

    UPDATE c
       SET
           c.CustId      = @CustId,
           c.ImageUrl    = COALESCE(@ImageUrl, c.ImageUrl),
           c.CardTypeId  = COALESCE(@CardTypeId, c.CardTypeId),
           c.ApartmentId = COALESCE(@ApartmentId, c.ApartmentId),
           c.Card_St     = COALESCE(TRY_CONVERT(INT, @CardStatus), c.Card_St),

           c.IssueDate   = COALESCE(@IssueDt, GETDATE()),
           c.ExpireDate  = COALESCE(@ExpireDt, c.ExpireDate),

           c.created_by  = @UserID
    FROM dbo.MAS_Cards c
    WHERE c.CardCd = @CardCd;

    IF (@LocalTran = 1) COMMIT;

    SET @valid = 1;
    SET @messages = N'Cập nhật thành công';
    SELECT @valid AS valid, @messages AS [messages];

END TRY
BEGIN CATCH
    IF (XACT_STATE() <> 0 AND @@TRANCOUNT > 0) ROLLBACK;

    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_card_family_set ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '@userId=' + ISNULL(@UserID,'') + ';@CardCd=' + ISNULL(@CardCd,'');

    EXEC utl_errorlog_set
          @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'apartment_family_card'
        , 'Set'
        , @SessionID
        , @AddlInfo;

    SELECT CAST(0 AS BIT) AS valid, ERROR_MESSAGE() AS [messages];
END CATCH;