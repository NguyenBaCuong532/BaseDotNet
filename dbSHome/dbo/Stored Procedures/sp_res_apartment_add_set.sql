-- Updated: Hỗ trợ ApartmentId và Oid (backward compatible)
CREATE   procedure [dbo].[sp_res_apartment_add_set]
    @userId NVARCHAR(450),
    @ApartmentId INT = NULL,  -- Backward compatible
    @Oid UNIQUEIDENTIFIER = NULL, -- Ưu tiên sử dụng (GUID)
    @roomCode NVARCHAR(50),
    @projectCd NVARCHAR(50),
    @BuildingCd NVARCHAR(50),
    @FloorNumber decimal(18,2) = 0,
    @WallArea FLOAT = 0,
    @WaterwayArea FLOAT = 0
AS
BEGIN
    DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(250) = N'Có lỗi xảy ra!';
    
    -- Xác định ApartmentId từ Oid nếu có
    IF @Oid IS NOT NULL AND @ApartmentId IS NULL
    BEGIN
        SELECT @ApartmentId = ApartmentId FROM [dbo].[MAS_Apartments] WHERE oid = @Oid;
    END
    
    IF EXISTS(SELECT TOP 1 1 FROM MAS_Apartments WHERE RoomCode = @roomCode)
    BEGIN
        SET @messages = N'Mã căn hộ đã tồn tại. Vui lòng kiểm tra lại.';
        GOTO FINALLY;
    END

    BEGIN TRY
        IF ((@ApartmentId IS NULL OR @ApartmentId = 0) AND @Oid IS NULL)
            OR NOT EXISTS (SELECT 1 FROM [dbo].[MAS_Apartments] WHERE (@ApartmentId IS NOT NULL AND ApartmentId = @ApartmentId) OR (@Oid IS NOT NULL AND oid = @Oid))
        BEGIN
            -- lấy tên tầng và floorOid dựa vào số tầng
            DECLARE @FloorName NVARCHAR(150) = '';
            DECLARE @floorOid UNIQUEIDENTIFIER = NULL;
            DECLARE @buildingOid UNIQUEIDENTIFIER = NULL;
            
            SELECT @FloorName = FloorName, @floorOid = oid
            FROM dbo.MAS_Elevator_Floor
            WHERE
                ProjectCd = @projectCd
                AND buildingCd = @BuildingCd
                AND FloorNumber = @FloorNumber;
            
            SELECT @buildingOid = oid
            FROM dbo.MAS_Buildings
            WHERE ProjectCd = @projectCd AND BuildingCd = @BuildingCd;

            -- Thêm mới căn hộ (MAS_Rooms đã được merge vào MAS_Apartments)
            INSERT INTO MAS_Apartments
            (
                RoomCode,
                projectCd,
                buildingCd,
                buildingOid,
                floorOid,
                floorNo,
                WaterwayArea,
                WallArea,
                CurrBal
            )
            VALUES
            (@roomCode, @projectCd, @BuildingCd, @buildingOid, @floorOid, @FloorName, @WaterwayArea, @WallArea, 0);
            --
            SET @valid = 1;
            SET @messages = N'Thêm mới căn hộ thành công';
        END;
        ELSE
        BEGIN
            --
            UPDATE a
            SET
                a.RoomCode     = @roomCode,
                a.projectCd    = @projectCd,
                a.buildingCd   = @BuildingCd,
                a.buildingOid  = @buildingOid,
                a.floorOid     = @floorOid,
                a.floorNo      = @FloorName,
                a.WaterwayArea = @WaterwayArea,
                a.WallArea     = @WallArea
            FROM dbo.MAS_Apartments a
            WHERE (@Oid IS NOT NULL AND a.oid = @Oid)
               OR (@Oid IS NULL AND a.ApartmentId = @ApartmentId);

            SET @valid = 1;
            SET @messages = N'Cập nhật thành công';
            
        END;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX);

        SET @ErrorNum = ERROR_NUMBER();
        SET @ErrorMsg = 'sp_res_apartment_add_set' + ERROR_MESSAGE();
        SET @ErrorProc = ERROR_PROCEDURE();
        SET @AddlInfo = '@userId' + @userId;

        EXEC utl_errorlog_set @ErrorNum,
                              @ErrorMsg,
                              @ErrorProc,
                              'apartment',
                              'Set',
                              @SessionID,
                              @AddlInfo;

        SET @messages = @ErrorMsg;
    END CATCH;

    FINALLY:
        SELECT @valid AS valid,
               @messages AS [messages];
END;