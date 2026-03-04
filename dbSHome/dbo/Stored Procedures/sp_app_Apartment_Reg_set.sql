-- =============================================
-- Author: ANHTT
-- Create date: 2025-09-05 12:38:38
-- Description:	create or update MAS_Apartment_Reg
-- Output: status & messages
-- =============================================
CREATE PROCEDURE [dbo].[sp_app_apartment_reg_set] 
	  @userId UNIQUEIDENTIFIER = NULL
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
    , @apartmentId BIGINT = NULL
    , @apartmentRegId BIGINT = NULL
    , @roomCode NVARCHAR(40)
    , @contractNo NVARCHAR(200)
    , @relationId INT = NULL
    --, @reg_dt DATETIME
    --, @reg_st INT
    -- , @auth_dt DATETIME
AS
BEGIN TRY
    DECLARE @valid BIT = 0
        , @messages NVARCHAR(250);
    
    DECLARE @row_guid UNIQUEIDENTIFIER
    DECLARE @customerId UNIQUEIDENTIFIER
    DECLARE @fullName NVARCHAR(250)
    DECLARE @phone NVARCHAR(20)

    --
    SELECT @customerId = custId
        , @fullName = fullName
        , @phone = phone
    FROM UserInfo
    WHERE userId = @userId

    --
    IF @customerId IS NULL
    BEGIN
        SET @customerId = NEWID()

        BEGIN TRAN

        INSERT INTO [dbo].[MAS_Customers] (
            [CustId]
            , [Cif_No]
            , [FullName]
            , [AvatarUrl]
            , [IsSex]
            , [Birthday]
            , [Phone]
            , [Email]
            , [Pass_No]
            , [Pass_Dt]
            , [Pass_Plc]
            , [Address]
            , [ProvinceCd]
            , [IsForeign]
            , [CountryCd]
            )
        SELECT @customerId
            , a.cif_no
            , a.fullName
            , a.avatarUrl
            , a.sex
            , a.birthday
            , a.phone
            , a.email
            , a.idcard_No
            , a.idcard_Issue_Dt
            , a.idcard_Issue_Plc
            , a.res_Add
            , a.res_City
            , CASE 
                WHEN a.res_Cntry IS NULL
                    OR a.res_Cntry = 'VN'
                    THEN 0
                ELSE 1
                END
            , a.res_Cntry
        FROM UserInfo a
        WHERE a.userId = @userId

        UPDATE UserInfo
        SET custId = @customerId
        WHERE userId = @userId

        COMMIT
    END

    -- Kiểm tra xem đã tồn tại bản ghi với cùng roomCode và userId chưa
    IF EXISTS (
        SELECT 1
        FROM MAS_Apartment_Reg
        WHERE roomCode = @roomCode
            AND userId = @userId
    )
    BEGIN
        -- Nếu đã tồn tại, lấy thông tin bản ghi hiện có
        SELECT @apartmentRegId = Id,
               @row_guid = row_guid
        FROM MAS_Apartment_Reg
        WHERE roomCode = @roomCode
            AND userId = @userId;

        SET @valid = 0;
        SET @messages = N'Thành viên/cư dân đã tồn tại';
    END
    ELSE IF (@apartmentRegId IS NULL)
        OR NOT EXISTS (
            SELECT 1
            FROM MAS_Apartment_Reg
            WHERE Id = @apartmentRegId
            )
    BEGIN
        -- IF @id IS NULL
        --     SET @id = NEWID();
        -- insert
        SET @row_guid = NEWID()
        INSERT INTO MAS_Apartment_Reg (
            -- Id,
            userId
            , roomCode
            , contractNo
            , relationId
            , row_guid
            )
        VALUES (
            -- @Id,
            @userId
            , @roomCode
            , @contractNo
            , @relationId
            ,@row_guid
            )

        SET @apartmentRegId = SCOPE_IDENTITY()
        SET @valid = 1;
        SET @messages = N'Thông tin đăng ký cư dân của quý khách đã được gửi. Quý khác vui lòng chờ BQLTN xác nhận thông tin.';
    END;
    ELSE
    BEGIN
        SELECT @row_guid = row_guid FROM MAS_Apartment_Reg WHERE  Id = @apartmentRegId
        UPDATE MAS_Apartment_Reg
        SET roomCode = @roomCode
            , contractNo = @contractNo
            , relationId = @relationId
        --, reg_dt = @reg_dt
        --, reg_st = @reg_st
        --, auth_dt = @auth_dt
        WHERE Id = @apartmentRegId
            AND reg_st = 0

        --
        SET @valid = 1;
        SET @messages = N'Thông tin đăng ký cư dân của quý khách đã được gửi. Quý khác vui lòng chờ BQLTN xác nhận thông tin.';
    END;

    FINAL:

    SELECT valid = @valid
        --, [Data] = @apartmentRegId
       -- , code = 'RES_MEM_REG_APP' --template code
        , id = @row_guid
        , [messages] = @messages;

  --  IF @valid = 1
    IF @apartmentRegId IS NOT NULL
        -- Thông tin gửi thông báo
        SELECT a.RoomCode
            , floorNo = ISNULL(ef.FloorName, a.floorNo)
            , buildingCode = b.BuildingCd
            , projectCode = p.ProjectCd
            , projectName = p.projectName
            , CustomerId = LOWER(@customerId)
            , fullName = @fullName
            , phone = @phone
            , email = p.mailSender
        FROM MAS_Apartments a
        LEFT JOIN MAS_Buildings b ON a.buildingOid = b.oid
        LEFT JOIN MAS_Projects p ON p.oid = b.tenant_oid
        LEFT JOIN MAS_Elevator_Floor ef ON a.floorOid = ef.oid
        WHERE a.RoomCode = @roomCode
END TRY

BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK;

    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '@Userid: ' --+ @userId;

    BEGIN
        EXEC utl_ErrorLog_Set @ErrorNum
            , @ErrorMsg
            , @ErrorProc
            , 'MAS_Apartment_Reg'
            , 'SET'
            , @SessionID
            , @AddlInfo;

        SELECT @ErrorMsg AS [messages];
    END
END CATCH;