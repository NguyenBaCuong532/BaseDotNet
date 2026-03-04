CREATE OR ALTER PROCEDURE [dbo].[sp_res_apartment_changeRoomCode_set] 	
	@userId UNIQUEIDENTIFIER = NULL,
	@acceptLanguage NVARCHAR(50) = N'vi-VN',
	@Oid UNIQUEIDENTIFIER = NULL, -- Ưu tiên sử dụng (GUID)
	@roomCode NVARCHAR(50) = NULL, -- Backward compatible
	@buildingCd NVARCHAR(50) = NULL, -- Backward compatible
	@roomCodeView NVARCHAR(50)
AS
BEGIN
    DECLARE @valid BIT = 0
        , @messages NVARCHAR(250) = '';
	DECLARE @ActualOid UNIQUEIDENTIFIER = NULL;

    BEGIN TRY
		-- =============================================
		-- LẤY TENANT_OID TỪ USERS
		-- =============================================
		DECLARE @tenantOid UNIQUEIDENTIFIER = NULL;
		
		IF @userId IS NOT NULL
		BEGIN
			SELECT @tenantOid = tenant_oid
			FROM Users
			WHERE userId = @userId;
			
			-- Kiểm tra user có tenant_oid không
			IF @tenantOid IS NULL
			BEGIN
				SET @valid = 0;
				SET @messages = N'Người dùng không có quyền truy cập';
				SELECT @valid AS valid, @messages AS [messages];
				RETURN;
			END
		END

		-- Xác định ActualOid từ Oid hoặc roomCode + buildingCd (có kiểm tra tenant_oid)
		IF @Oid IS NOT NULL
		BEGIN
			SELECT @ActualOid = @Oid
			FROM MAS_Apartments
			WHERE oid = @Oid
			  AND (@tenantOid IS NULL OR tenant_oid = @tenantOid);
		END
		ELSE IF @roomCode IS NOT NULL AND @buildingCd IS NOT NULL
		BEGIN
			SELECT @ActualOid = a.oid
			FROM MAS_Apartments a
			LEFT JOIN MAS_Buildings b ON a.buildingOid = b.oid
			WHERE a.RoomCode = @roomCode
			  AND b.BuildingCd = @buildingCd
			  AND (@tenantOid IS NULL OR a.tenant_oid = @tenantOid);
		END

		-- Kiểm tra căn hộ tồn tại
		IF @ActualOid IS NULL
		BEGIN
			SET @valid = 0;
			SET @messages = N'Không tìm thấy căn hộ hoặc không có quyền truy cập';
			SELECT @valid AS valid, @messages AS [messages];
			RETURN;
		END

		-- Kiểm tra mã căn hộ mới không bị trùng
		IF NOT EXISTS (SELECT 1 FROM dbo.MAS_Apartments WHERE RoomCode = @roomCodeView AND (@tenantOid IS NULL OR tenant_oid = @tenantOid))
		BEGIN
			-- Cập nhật RoomCode
			UPDATE dbo.MAS_Apartments 
			SET RoomCode = @roomCodeView
			WHERE oid = @ActualOid
			  AND (@tenantOid IS NULL OR tenant_oid = @tenantOid);
			
			SET @valid = 1;
			SET @messages = N'Đổi căn hộ thành công';
		END 
		ELSE
		BEGIN
			SET @valid = 0;
			SET @messages = N'Mã căn hộ bị trùng!';
		END 

    END TRY

    BEGIN CATCH
        

        DECLARE @ErrorNum INT
            , @ErrorMsg VARCHAR(200)
            , @ErrorProc VARCHAR(50)
            , @SessionID INT
            , @AddlInfo VARCHAR(MAX);

        SET @ErrorNum = ERROR_NUMBER();
        SET @ErrorMsg = 'sp_res_apartment_changeRoomCode_set ' + ERROR_MESSAGE();
        SET @ErrorProc = ERROR_PROCEDURE();
        SET @AddlInfo = '';

        EXEC utl_errorlog_set @ErrorNum
            , @ErrorMsg
            , @ErrorProc
            , 'MAS_Apartments'
            , 'SET'
            , @SessionID
            , @AddlInfo;

        SET @messages = @ErrorMsg
    END CATCH;

    SELECT @valid AS valid
        , @messages AS [messages];
END;