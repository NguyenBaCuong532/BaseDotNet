

CREATE PROCEDURE [dbo].[sp_res_card_resident_set] 
	  @UserId NVARCHAR(50)
    , @custId NVARCHAR(50)
    , @apartmentId NVARCHAR(20) = NULL
    --, @CustName NVARCHAR(100)
    , @cardCd NVARCHAR(50)
    , @ImageUrl NVARCHAR(250) = NULL
    , @IssueDate NVARCHAR(50) = NULL
    , @ExpireDate NVARCHAR(50) = NULL
    , @CardTypeId INT = 1
    , @RoomCode NVARCHAR(50) = NULL
    , @CardStatus INT = 1
    --, @ProjectCd NVARCHAR(30)
    --, @partner_id INT = 0
AS
BEGIN TRY
    DECLARE @valid BIT = 0
    DECLARE @messages NVARCHAR(200) = ''
    DECLARE @OldCustId NVARCHAR(50) = NULL
    DECLARE @OldOwnerName NVARCHAR(200) = NULL
    DECLARE @NewOwnerName NVARCHAR(200) = NULL
    DECLARE @CardId INT = NULL
    DECLARE @ProjectCd NVARCHAR(30) = NULL
    DECLARE @ActualApartmentId INT = NULL
    DECLARE @ActualIssueDate DATETIME = NULL
    DECLARE @ActualExpireDate DATETIME = NULL

    IF NOT EXISTS (
            SELECT Code
            FROM MAS_CardBase
            WHERE Code = @CardCd
            )
    BEGIN
        SET @Messages = N'Không tìm thấy thông tin mã thẻ [' + @CardCd + N']!'
		goto FINAL
    END

    -- Lấy thông tin thẻ và apartmentId nếu chưa có
    IF EXISTS (SELECT 1 FROM MAS_Cards WHERE CardCd = @cardCd)
    BEGIN
        SELECT TOP 1 
            @CardId = CardId,
            @OldCustId = CustId,
            @ProjectCd = ProjectCd,
            @ActualApartmentId = ISNULL(ApartmentId, CONVERT(INT, @apartmentId))
        FROM MAS_Cards WITH (NOLOCK)
        WHERE CardCd = @cardCd
    END
    ELSE
    BEGIN
        -- Lấy apartmentId từ @apartmentId hoặc @RoomCode
        IF @apartmentId IS NOT NULL
        BEGIN
            SET @ActualApartmentId = CONVERT(INT, @apartmentId)
        END
        ELSE IF @RoomCode IS NOT NULL
        BEGIN
            SELECT TOP 1 
                @ActualApartmentId = ApartmentId,
                @ProjectCd = ProjectCd
            FROM MAS_Apartments WITH (NOLOCK)
            WHERE RoomCode = @RoomCode
        END
        
        -- Lấy ProjectCd nếu chưa có
        IF @ProjectCd IS NULL AND @ActualApartmentId IS NOT NULL
        BEGIN
            SELECT TOP 1 @ProjectCd = ProjectCd
            FROM MAS_Apartments WITH (NOLOCK)
            WHERE ApartmentId = @ActualApartmentId
        END
    END

    -- Nếu không có apartmentId từ thẻ và không truyền vào thì lấy từ member hoặc RoomCode
    IF @ActualApartmentId IS NULL AND @apartmentId IS NOT NULL
    BEGIN
        SET @ActualApartmentId = CONVERT(INT, @apartmentId)
    END
    ELSE IF @ActualApartmentId IS NULL AND @RoomCode IS NOT NULL
    BEGIN
        SELECT TOP 1 @ActualApartmentId = ApartmentId
        FROM MAS_Apartments WITH (NOLOCK)
        WHERE RoomCode = @RoomCode
    END
    ELSE IF @ActualApartmentId IS NULL
    BEGIN
        SELECT TOP 1 @ActualApartmentId = ApartmentId
        FROM MAS_Apartment_Member WITH (NOLOCK)
        WHERE CustId = @custId
        ORDER BY member_st DESC, approveDt DESC
    END

    -- Xử lý IssueDate và ExpireDate
    IF @IssueDate IS NOT NULL AND LTRIM(RTRIM(@IssueDate)) <> ''
    BEGIN
        SET @ActualIssueDate = CONVERT(DATETIME, @IssueDate, 103)
    END
    ELSE
    BEGIN
        SET @ActualIssueDate = GETDATE()
    END

    IF @ExpireDate IS NOT NULL AND LTRIM(RTRIM(@ExpireDate)) <> ''
    BEGIN
        SET @ActualExpireDate = CONVERT(DATETIME, @ExpireDate, 103)
    END

    -- Kiểm tra thành viên trong căn hộ
    IF @ActualApartmentId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM MAS_Apartment_Member WHERE CustId = @custId AND ApartmentId = @ActualApartmentId)
    BEGIN
        SET @Valid = 0
        SET @Messages = N'Không tìm thấy thành viên trong căn hộ' 
        GOTO FINAL
    END

    --ELSE IF NOT EXISTS (
    --        SELECT *
    --        FROM MAS_Projects
    --        WHERE projectCd = @ProjectCd
    --        )
    --BEGIN
    --    SET @Messages = N'Chưa chọn dự án!'
    --END
    --ELSE
    BEGIN
        BEGIN TRANSACTION

        --IF EXISTS (
        --        SELECT TOP 1 CustId
        --        FROM MAS_Customers
        --        WHERE Phone LIKE @CustPhone
        --        )
        --    SET @CustId = (
        --            SELECT TOP 1 CustId
        --            FROM MAS_Customers
        --            WHERE Phone LIKE @CustPhone
        --            )
        --ELSE
        --BEGIN
        --    SET @custId = newid()

        --    INSERT INTO [dbo].[MAS_Customers] (
        --        CustId
        --        , [FullName]
        --        , [Phone]
        --        , [Email]
        --        , [AvatarUrl]
        --        , [IsSex]
        --        , IsForeign
        --        , sysDate
        --        )
        --    --,created_by
        --    VALUES (
        --        @custId
        --        , @CustName
        --        , @CustPhone
        --        , NULL
        --        , NULL
        --        , 1
        --        , 0
        --        , getdate()
        --        --,@UserID
        --        )
        --END

        --IF EXISTS (
        --        SELECT *
        --        FROM [MAS_Cards]
        --        WHERE [CardCd] = @CardCd
        --            AND Card_St >= 3
        --        )
        --    EXECUTE [dbo].[sp_Hom_Card_Del] @userId
        --        , @CardCd

        IF NOT EXISTS (
                SELECT *
                FROM [MAS_Cards]
                WHERE [CardCd] = @CardCd
                )
        BEGIN
            -- Đảm bảo có @ActualApartmentId trước khi INSERT
            IF @ActualApartmentId IS NULL
            BEGIN
                SET @Valid = 0
                SET @Messages = N'Không tìm thấy thông tin căn hộ' 
                ROLLBACK TRANSACTION
                GOTO FINAL
            END

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
                , ApartmentId
                , ImageUrl
                , created_by
                )
            select
                @CardCd
                , @ActualIssueDate
                , @ActualExpireDate
                , @CardStatus
                , 0
                , 0
                , 0
                , 1
                , @CustId
                , @CardTypeId
                , N'Thẻ cư dân'
                , a.ProjectCd
                , 0
                , 0
                , ApartmentId
                , @ImageUrl
                , @UserID
             from MAS_Apartments a
			 where ApartmentId = @ActualApartmentId

            UPDATE MAS_CardBase
            SET IsUsed = 1
            WHERE Code = @CardCd

            --
            SET @valid = 1
            SET @messages = N'Thêm mới thành công'
        END
        ELSE
        BEGIN
            -- Lấy thông tin chủ cũ và chủ mới để lưu lịch sử
            IF @OldCustId IS NULL
            BEGIN
                SELECT TOP 1 @OldCustId = CustId
                FROM MAS_Cards WITH (NOLOCK)
                WHERE CardCd = @cardCd
            END

            -- Lấy tên chủ cũ và chủ mới
            IF @OldCustId IS NOT NULL AND @OldCustId <> @CustId
            BEGIN
                SELECT TOP 1 @OldOwnerName = FullName
                FROM MAS_Customers WITH (NOLOCK)
                WHERE CustId = @OldCustId

                SELECT TOP 1 @NewOwnerName = FullName
                FROM MAS_Customers WITH (NOLOCK)
                WHERE CustId = @CustId
            END

            --UPDATE [MAS_Cards] SET partner_id = @partner_id 
            --WHERE CardCd = @CardCd 
            UPDATE [MAS_Cards]
            SET CustId = @CustId
                , [IssueDate] = CASE WHEN @IssueDate IS NOT NULL AND LTRIM(RTRIM(@IssueDate)) <> '' THEN CONVERT(DATETIME, @IssueDate, 103) ELSE IssueDate END
                , [ExpireDate] = CASE WHEN @ExpireDate IS NOT NULL AND LTRIM(RTRIM(@ExpireDate)) <> '' THEN CONVERT(DATETIME, @ExpireDate, 103) ELSE ExpireDate END
                , [Card_St] = @CardStatus
                , [IsClose] = CASE WHEN @CardStatus >= 3 THEN 1 ELSE 0 END
                , IsDaily = 0
                , [IsVip] = 0
                , IsGuest = 1
                , CardTypeId = @CardTypeId
                , CardName = N'Thẻ cư dân'
                , ImageUrl = CASE WHEN @ImageUrl IS NOT NULL AND LTRIM(RTRIM(@ImageUrl)) <> '' THEN @ImageUrl ELSE ImageUrl END
                , isVehicle = 0
                , isCredit = 0
                --, partner_id = @partner_id
            WHERE CardCd = @cardCd

            -- Lấy CardId sau khi update
            IF @CardId IS NULL
            BEGIN
                SELECT TOP 1 @CardId = CardId
                FROM MAS_Cards WITH (NOLOCK)
                WHERE CardCd = @cardCd
            END

            -- Lưu lịch sử đổi chủ sở hữu thẻ (nếu có thay đổi)
            IF @OldCustId IS NOT NULL AND @OldCustId <> @CustId AND @CardId IS NOT NULL
            BEGIN
                -- Lấy ProjectCd nếu chưa có
                IF @ProjectCd IS NULL
                BEGIN
                    SELECT TOP 1 @ProjectCd = ProjectCd
                    FROM MAS_Cards WITH (NOLOCK)
                    WHERE CardId = @CardId
                END

                -- Lấy username của người thực hiện
                -- Lấy username của người thực hiện
                DECLARE @Operator NVARCHAR(100) = NULL
                SELECT TOP 1 @Operator = loginName
                FROM UserInfo WITH (NOLOCK)
                WHERE userId = @UserId OR loginName = @UserId -- Fallback if regex/convert fail or passed as loginName

                SET @Operator = ISNULL(@Operator, @UserId) -- Default to input if not found

                -- Lấy thông tin phương tiện (nếu có)
                DECLARE @VehicleTypeId INT = NULL
                DECLARE @VehicleTypeName NVARCHAR(100) = NULL
                DECLARE @VehicleNo NVARCHAR(16) = NULL
                
                SELECT TOP 1 
                    @VehicleTypeId = cv.VehicleTypeId,
                    @VehicleTypeName = vt.VehicleTypeName,
                    @VehicleNo = cv.VehicleNo
                FROM MAS_CardVehicle cv WITH (NOLOCK)
                LEFT JOIN MAS_VehicleTypes vt WITH (NOLOCK) ON cv.VehicleTypeId = vt.VehicleTypeId
                WHERE cv.CardId = @CardId
                ORDER BY cv.CardVehicleId DESC

                -- Lấy IssueDate của thẻ để làm FromDate
                DECLARE @HistoryIssueDate DATE = NULL
                SELECT TOP 1 @HistoryIssueDate = CONVERT(DATE, IssueDate)
                FROM MAS_Cards WITH (NOLOCK)
                WHERE CardId = @CardId

                -- Lưu vào bảng lịch sử thẻ
                INSERT INTO MAS_CardVehicle_Card_H (
                    ActionType,
                    ActionTypeName,
                    CardId,
                    CardVehicleId,
                    FromDate,
                    ToDate,
                    VehicleTypeId,
                    VehicleTypeName,
                    OldCardCode,
                    NewCardCode,
                    OldOwner,
                    NewOwner,
                    OldOwnerCustId,
                    NewOwnerCustId,
                    VehicleNo,
                    Operator,
                    ActionTime,
                    Notes,
                    ProjectCd,
                    CreatedDate
                )
                VALUES (
                    2,  -- ActionType: 2 = Đổi chủ sở hữu
                    N'Đổi chủ sở hữu',
                    @CardId,
                    NULL,  -- Không phải thẻ xe
                    @HistoryIssueDate,  -- Từ ngày: Ngày bắt đầu sử dụng thẻ của chủ sở hữu cũ
                    GETDATE(),  -- Đến ngày: Ngày kết thúc sử dụng thẻ của chủ sở hữu cũ
                    @VehicleTypeId,  -- VehicleTypeId (nếu có)
                    @VehicleTypeName, -- VehicleTypeName (nếu có)
                    @cardCd,  -- Mã thẻ giữ nguyên
                    @cardCd,  -- Mã thẻ giữ nguyên
                    @OldOwnerName,  -- Chủ sở hữu cũ
                    @NewOwnerName,  -- Chủ sở hữu mới
                    @OldCustId,  -- CustId chủ cũ
                    @CustId,  -- CustId chủ mới
                    @VehicleNo,  -- Biển số xe (nếu có)
                    @Operator,  -- Người thao tác
                    GETDATE(),  -- Thời gian thực hiện
                    N'Đổi chủ sở hữu thẻ cư dân',  -- Ghi chú
                    @ProjectCd,
                    GETDATE()
                )
            END
        END

        --UPDATE [dbo].[MAS_Customers]
        --SET [FullName] = @CustName
        --    , [Phone] = @CustPhone
        --WHERE CustId = @CustId

        SET @valid = 1
        SET @messages = N'Cập nhật thành công'

        COMMIT
    END

END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_res_card_resident_set ' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = '@CardCd ' + isnull(@cardCd, 'NULL') + ', @CustId ' + isnull(@custId, 'NULL')

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'CardResident'
        , 'Set'
        , @SessionID
        , @AddlInfo
    
    SET @messages = @ErrorMsg
    SET @valid = 0
    
END CATCH

FINAL:
SELECT @valid AS valid
        , @messages AS [messages]