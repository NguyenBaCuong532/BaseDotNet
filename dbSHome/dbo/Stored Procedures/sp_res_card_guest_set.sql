
CREATE PROCEDURE [dbo].[sp_res_card_guest_set] 
	  @UserId NVARCHAR(50)
    , @CustId NVARCHAR(50)
    , @CustPhone NVARCHAR(20)
    , @CustName NVARCHAR(100)
    , @CardCd NVARCHAR(50)
    , @IssueDate NVARCHAR(20)
    , @ExpireDate NVARCHAR(20)
    , @ProjectCd NVARCHAR(30)
    , @partner_id INT = 0
AS
BEGIN TRY
    DECLARE @valid BIT = 0
    DECLARE @messages NVARCHAR(200) = ''
    DECLARE @CardTypeId INT

    SET @CardTypeId = 4 --the guest

    IF NOT EXISTS (
            SELECT Code
            FROM MAS_CardBase
            WHERE Code = @CardCd
            )
    BEGIN
        SET @Messages = N'Không tìm thấy thông tin mã thẻ [' + @CardCd + N']!'
    END
            --else if exists(select cardId from MAS_Cards where CardCd = @CardCd and Card_St < 3)
            --	begin
            --		set @Valid = 0
            --		set @Messages = N'Số thẻ [' + @CardCd + N'] đang được sử dụng, Cần phải khóa trước cấp!' 
            --	end
    ELSE IF NOT EXISTS (
            SELECT *
            FROM MAS_Projects
            WHERE projectCd = @ProjectCd
            )
    BEGIN
        SET @Messages = N'Chưa chọn dự án!'
    END
    ELSE
    BEGIN
        BEGIN TRANSACTION

        IF EXISTS (
                SELECT TOP 1 CustId
                FROM MAS_Customers
                WHERE Phone LIKE @CustPhone
                )
            SET @CustId = (
                    SELECT TOP 1 CustId
                    FROM MAS_Customers
                    WHERE Phone LIKE @CustPhone
                    )
        ELSE
        BEGIN
            SET @custId = newid()

            INSERT INTO [dbo].[MAS_Customers] (
                CustId
                , [FullName]
                , [Phone]
                , [Email]
                , [AvatarUrl]
                , [IsSex]
                , IsForeign
                , sysDate
                )
            --,created_by
            VALUES (
                @custId
                , @CustName
                , @CustPhone
                , NULL
                , NULL
                , 1
                , 0
                , getdate()
                --,@UserID
                )
        END

        IF EXISTS (
                SELECT *
                FROM [MAS_Cards]
                WHERE [CardCd] = @CardCd
                    AND Card_St >= 3
                )
            EXECUTE [dbo].[sp_Hom_Card_Del] @userId
                , @CardCd

        IF NOT EXISTS (
                SELECT *
                FROM [MAS_Cards]
                WHERE [CardCd] = @CardCd
                )
        BEGIN
            INSERT INTO [dbo].[MAS_Cards] (
                [CardCd]
                , [IssueDate]
                , [ExpireDate]
                , [Card_St]
                , [IsClose]
                , IsDaily
                , [IsVip]
                , IsGuest
                , CustId
                , CardTypeId
                , CardName
                , ProjectCd
                , isVehicle
                , isCredit
                , partner_id
                , created_by
                )
            VALUES (
                @CardCd
                , Getdate() --isnull(convert(date,@IssueDate,103),Getdate())
                , isnull(convert(DATE, @ExpireDate, 103), Getdate())
                , 1
                , 0
                , 0
                , 0
                , 1
                , @CustId
                , @CardTypeId
                , N'Thẻ Khách'
                , @ProjectCd
                , 0
                , 0
                , @partner_id
                , @UserID
                )

            UPDATE MAS_CardBase
            SET IsUsed = 1
            WHERE Code = @CardCd

            --
            SET @valid = 1
            SET @messages = N'Thêm mới thành công'
        END
        ELSE
            --UPDATE [MAS_Cards] SET partner_id = @partner_id 
            --WHERE CardCd = @CardCd 
            UPDATE [MAS_Cards]
            SET CustId = @CustId
                --[IssueDate] =   isnull(convert(date,@IssueDate,103),Getdate())
                , [ExpireDate] = isnull(convert(DATE, @ExpireDate, 103), Getdate())
                , [Card_St] = 1
                , [IsClose] = 0
                , IsDaily = 0
                , [IsVip] = 0
                , IsGuest = 1
                , CardTypeId = @CardTypeId
                , CardName = N'Thẻ Khách'
                , ProjectCd = @ProjectCd
                , isVehicle = 0
                , isCredit = 0
                , partner_id = @partner_id
            WHERE CardCd = @CardCd

        UPDATE [dbo].[MAS_Customers]
        SET [FullName] = @CustName
            , [Phone] = @CustPhone
        WHERE CustId = @CustId

        SET @valid = 1
        SET @messages = N'Cập nhật thành công'

        COMMIT
    END

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
    SET @ErrorMsg = 'sp_Hom_Insert_Card_Guest ' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = '@CardCd ' + isnull(@CardCd, 'NULL')

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'CardGuest'
        , 'Insert'
        , @SessionID
        , @AddlInfo
    
    SET @messages = @ErrorMsg
    SELECT @valid AS valid
        , @messages AS [messages]
END CATCH