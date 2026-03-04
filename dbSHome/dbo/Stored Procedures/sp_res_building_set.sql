-- =============================================
-- Author:		duongpx
-- Create date: 2025-01-29
-- Description:	Tạo/Cập nhật bảng MAS_Buildings
-- Updated: Hỗ trợ cả buildingCd/id và Oid (backward compatible)
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[sp_res_building_set]
	@UserId			UNIQUEIDENTIFIER = NULL,
	@acceptLanguage	NVARCHAR(50) = N'vi-VN',
	@Oid			UNIQUEIDENTIFIER = NULL, -- Ưu tiên sử dụng (GUID)
	@Id				INT = NULL, -- Backward compatible (Id cũ)
	@buildingCd		NVARCHAR(50) = NULL, -- Backward compatible
	@buildingName	NVARCHAR(255) = NULL,
	@ProjectCd		NVARCHAR(30) = NULL,
	@intorder		INT = NULL
AS
BEGIN
BEGIN TRY
	SET NOCOUNT ON;
	
	-- =============================================
	-- LẤY TENANT_OID TỪ USERS
	-- =============================================
	DECLARE @tenantOid UNIQUEIDENTIFIER = NULL;
	
	IF @UserId IS NOT NULL
	BEGIN
		SELECT @tenantOid = tenant_oid
		FROM Users
		WHERE userId = @UserId;
		
		-- Kiểm tra user có tenant_oid không
		IF @tenantOid IS NULL
		BEGIN
			SELECT 
				0 AS valid, 
				N'Người dùng không có quyền truy cập' AS [messages],
				NULL AS id,
				N'ERROR' AS action;
			RETURN;
		END
	END
	
	DECLARE @valid BIT = 0;
	DECLARE @messages NVARCHAR(250);
	DECLARE @action NVARCHAR(20);
	DECLARE @ActualOid UNIQUEIDENTIFIER = NULL;
	DECLARE @ActualId INT = NULL;
	DECLARE @ActualBuildingCd NVARCHAR(50) = NULL;

	-- Xác định Oid từ Id hoặc buildingCd nếu có (có kiểm tra tenant_oid)
	IF @Oid IS NOT NULL
	BEGIN
		SELECT @ActualOid = @Oid, @ActualId = Id, @ActualBuildingCd = BuildingCd
		FROM MAS_Buildings
		WHERE oid = @Oid
		  AND (@tenantOid IS NULL OR tenant_oid = @tenantOid);
	END
	ELSE IF @Id IS NOT NULL AND @Id > 0
	BEGIN
		SELECT @ActualOid = oid, @ActualId = @Id, @ActualBuildingCd = BuildingCd
		FROM MAS_Buildings
		WHERE Id = @Id
		  AND (@tenantOid IS NULL OR tenant_oid = @tenantOid);
	END
	ELSE IF @buildingCd IS NOT NULL AND @ProjectCd IS NOT NULL
	BEGIN
		SELECT @ActualOid = oid, @ActualId = Id, @ActualBuildingCd = @buildingCd
		FROM MAS_Buildings
		WHERE BuildingCd = @buildingCd AND ProjectCd = @ProjectCd
		  AND (@tenantOid IS NULL OR tenant_oid = @tenantOid);
	END
	
	-- Kiểm tra INSERT hay UPDATE
	IF @ActualOid IS NOT NULL AND EXISTS (SELECT 1 FROM MAS_Buildings WHERE oid = @ActualOid)
	BEGIN
		-- =============================================
		-- UPDATE - Cập nhật bản ghi
		-- =============================================
		SET @action = N'UPDATE';
		
		-- Kiểm tra tenant_oid trước khi UPDATE
		IF NOT EXISTS(SELECT 1 FROM MAS_Buildings WHERE oid = @ActualOid AND (@tenantOid IS NULL OR tenant_oid = @tenantOid))
		BEGIN
			SET @valid = 0;
			SET @messages = N'Không có quyền cập nhật tòa nhà này';
			SET @action = N'PERMISSION_DENIED';
			SELECT 
				@valid AS valid, 
				@messages AS [messages],
				@ActualOid AS id,
				@action AS action;
			RETURN;
		END
		
		UPDATE MAS_Buildings
		SET [buildingCd] = ISNULL(@buildingCd, buildingCd)
			,[buildingName] = ISNULL(@buildingName, buildingName)
			,[ProjectCd] = ISNULL(@ProjectCd, ProjectCd)
			,[created_at] = GETDATE()
			,[created_by] = ISNULL(@UserId, created_by)
			,intOrder = ISNULL(@intorder, intOrder)
		WHERE oid = @ActualOid
		  AND (@tenantOid IS NULL OR tenant_oid = @tenantOid);

		SET @valid = 1;
		SET @messages = N'Cập nhật thành công';
	END
	ELSE
	BEGIN
		-- =============================================
		-- INSERT - Thêm mới bản ghi
		-- =============================================
		SET @action = N'INSERT';
		
		-- Tạo Oid mới nếu cần
		IF @ActualOid IS NULL 
			SET @ActualOid = NEWID();
		
		-- Tạo Id mới nếu cần
		IF @ActualId IS NULL OR @ActualId = 0
			SET @ActualId = (SELECT ISNULL(MAX(Id), 0) + 1 FROM MAS_Buildings);

		INSERT INTO MAS_Buildings
			(oid
			,Id
			,[buildingCd]
			,[buildingName]
			,[ProjectCd]
			,[created_at]
			,[created_by]
			,intOrder
			,tenant_oid
			)
		VALUES
			(@ActualOid
			,@ActualId
			,@buildingCd
			,@buildingName
			,@ProjectCd
			,GETDATE()
			,@UserId
			,@intorder
			,@tenantOid
			);

		SET @valid = 1;
		SET @messages = N'Thêm mới thành công';
	END

END TRY
BEGIN CATCH
	DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50),
			@SessionID INT, @AddlInfo VARCHAR(MAX);
	SET @ErrorNum = ERROR_NUMBER();
	SET @ErrorMsg = ERROR_MESSAGE();
	SET @ErrorProc = ERROR_PROCEDURE();
	SET @AddlInfo = N'';
	
	SET @valid = 0;
	SET @messages = ERROR_MESSAGE();
	SET @action = N'ERROR';
	EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, N'MAS_Buildings', N'SET', @SessionID, @AddlInfo;
END CATCH

	-- =============================================
	-- RESULT - Trả về kết quả
	-- =============================================
	SELECT 
		@valid AS valid, 
		@messages AS [messages],
		@ActualOid AS id,
		@action AS action;
END