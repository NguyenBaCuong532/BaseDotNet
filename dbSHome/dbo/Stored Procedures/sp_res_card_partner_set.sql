
CREATE PROCEDURE [dbo].[sp_res_card_partner_set] @userID UNIQUEIDENTIFIER
    , @partner_id INT
    , @projectCd NVARCHAR(20)
    , @partner_name NVARCHAR(100)
    , @partner_cd NVARCHAR(50)
AS
BEGIN TRY
    DECLARE @valid BIT = 1
    DECLARE @messages NVARCHAR(200) = ''
    DECLARE @CardTypeId INT

    IF @partner_name IS NULL
        OR @partner_name = ''
    BEGIN
        SET @Valid = 0
        SET @Messages = N'Phải nhập thông tin tên'
    END
    ELSE IF EXISTS (
            SELECT partner_id
            FROM MAS_CardPartner
            WHERE partner_name = @partner_name
                AND projectCd = @projectCd
                AND partner_id <> @partner_id
            )
    BEGIN
        SET @Valid = 0
        SET @Messages = N'Thông tin đã tồn tại không được nhập trùng'
    END
    ELSE IF NOT EXISTS (
            SELECT *
            FROM MAS_Projects
            WHERE projectCd = @ProjectCd
            )
    BEGIN
        SET @Valid = 0
        SET @Messages = N'Chưa chọn dự án!'
    END
    ELSE
    BEGIN
        IF EXISTS (
                SELECT TOP 1 partner_id
                FROM MAS_CardPartner
                WHERE partner_id = @partner_id
                )
        BEGIN
            UPDATE [dbo].[MAS_CardPartner]
            SET [partner_cd] = @partner_cd
                , [partner_name] = @partner_name
                , [projectCd] = @projectCd
                , update_dt = getdate()
                , update_by = @UserID
            WHERE partner_id = @partner_id

            SET @messages = N'Cập nhật thành công'
        END
        ELSE
        BEGIN
            INSERT INTO [dbo].[MAS_CardPartner] (
                [partner_cd]
                , [partner_name]
                , [projectCd]
                , [create_dt]
                , [create_by]
                )
            VALUES (
                @partner_cd
                , @partner_name
                , @projectCd
                , getdate()
                , @UserID
                )

            SET @messages = N'Thêm mới thành công'
        END
    END

    /**TO DO***/
    SELECT @valid AS valid
        , @messages AS [messages]
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_res_Card_Partner_Set ' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = '@CardCd ' + isnull(@partner_name, 'NULL')

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'CardParter'
        , 'Set'
        , @SessionID
        , @AddlInfo

    SELECT @valid AS valid
        , @messages AS [messages]
END CATCH