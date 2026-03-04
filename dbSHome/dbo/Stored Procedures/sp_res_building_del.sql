-- =============================================
-- Author:		System
-- Create date: 2025-01-29
-- Description:	Xóa bản ghi từ bảng MAS_Buildings
-- Updated: Hỗ trợ cả buildingCd/id và Oid (backward compatible)
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[sp_res_building_del] 
	@userId			UNIQUEIDENTIFIER = NULL,
	@acceptLanguage	NVARCHAR(50) = N'vi-VN',
	@id				NVARCHAR(50) = NULL, -- Backward compatible (Id hoặc buildingCd)
	@Oid			UNIQUEIDENTIFIER = NULL -- Ưu tiên sử dụng (GUID)
AS
BEGIN
BEGIN TRY
	SET NOCOUNT ON;
	
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
			SELECT 
				0 AS valid, 
				N'Người dùng không có quyền truy cập' AS [messages];
			RETURN;
		END
	END
	
	DECLARE @valid BIT = 0;
	DECLARE @messages NVARCHAR(250);
	DECLARE @ActualOid UNIQUEIDENTIFIER = NULL;
	DECLARE @ActualId INT = NULL;
	DECLARE @ActualBuildingCd NVARCHAR(50) = NULL;

	-- Xác định Oid từ id hoặc buildingCd nếu có (có kiểm tra tenant_oid)
	IF @Oid IS NOT NULL
	BEGIN
		SELECT @ActualOid = @Oid, @ActualId = Id, @ActualBuildingCd = BuildingCd
		FROM MAS_Buildings
		WHERE oid = @Oid
		  AND (@tenantOid IS NULL OR tenant_oid = @tenantOid);
	END
	ELSE IF @id IS NOT NULL
	BEGIN
		-- Thử parse như INT (Id)
		IF ISNUMERIC(@id) = 1
		BEGIN
			SELECT @ActualOid = oid, @ActualId = CAST(@id AS INT), @ActualBuildingCd = BuildingCd
			FROM MAS_Buildings
			WHERE Id = CAST(@id AS INT)
			  AND (@tenantOid IS NULL OR tenant_oid = @tenantOid);
		END
		ELSE
		BEGIN
			-- Nếu không phải số, coi như buildingCd
			SELECT @ActualOid = oid, @ActualId = Id, @ActualBuildingCd = @id
			FROM MAS_Buildings
			WHERE BuildingCd = @id
			  AND (@tenantOid IS NULL OR tenant_oid = @tenantOid);
		END
	END

	-- Kiểm tra bản ghi tồn tại
	IF @ActualOid IS NULL OR NOT EXISTS(SELECT 1 FROM MAS_Buildings WHERE oid = @ActualOid)
	BEGIN
		SET @valid = 0;
		SET @messages = N'Không tìm thấy tòa nhà';
		SELECT 
			@valid AS valid, 
			@messages AS [messages];
		RETURN;
	END

	-- =============================================
	-- KIỂM TRA CÁC BẢNG QUAN HỆ TRƯỚC KHI XÓA
	-- =============================================
	
	-- Kiểm tra ELE_BuildArea
	IF EXISTS (
		SELECT TOP 1 1
		FROM ELE_BuildArea c
		JOIN MAS_Buildings b ON c.AreaCd = b.BuildingCd
		WHERE b.oid = @ActualOid
	)
	BEGIN
		SET @valid = 0;
		SET @messages = N'Khu vực đã được sử dụng. Không thể xóa';
		SELECT 
			@valid AS valid, 
			@messages AS [messages];
		RETURN;
	END

	-- Kiểm tra MAS_Apartments (qua buildingOid)
	IF EXISTS (
		SELECT TOP 1 1
		FROM MAS_Apartments c
		WHERE c.buildingOid = @ActualOid
	)
	BEGIN
		SET @valid = 0;
		SET @messages = N'Khu vực đã được sử dụng ở căn hộ. Không thể xóa';
		SELECT 
			@valid AS valid, 
			@messages AS [messages];
		RETURN;
	END

	-- Kiểm tra MAS_Apartments (qua BuildingCd - backward compatible)
	IF EXISTS (
		SELECT TOP 1 1
		FROM MAS_Apartments c
		JOIN MAS_Buildings b ON c.BuildingCd = b.BuildingCd
		WHERE b.oid = @ActualOid
	)
	BEGIN
		SET @valid = 0;
		SET @messages = N'Khu vực đã được sử dụng ở căn hộ. Không thể xóa';
		SELECT 
			@valid AS valid, 
			@messages AS [messages];
		RETURN;
	END

	-- =============================================
	-- THỰC HIỆN XÓA (có kiểm tra tenant_oid)
	-- =============================================
	DELETE FROM MAS_Buildings
	WHERE oid = @ActualOid
	  AND (@tenantOid IS NULL OR tenant_oid = @tenantOid);

	SET @valid = 1;
	SET @messages = N'Xóa thành công';

END TRY
BEGIN CATCH
	DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50),
			@SessionID INT, @AddlInfo VARCHAR(MAX);
	SET @ErrorNum = ERROR_NUMBER();
	SET @ErrorMsg = N'sp_res_building_del ' + ERROR_MESSAGE();
	SET @ErrorProc = ERROR_PROCEDURE();
	SET @AddlInfo = N'';
	
	SET @valid = 0;
	SET @messages = ERROR_MESSAGE();
	EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, N'MAS_Buildings', N'DEL', @SessionID, @AddlInfo;
END CATCH

	-- =============================================
	-- RESULT - Trả về kết quả
	-- =============================================
	SELECT 
		@valid AS valid, 
		@messages AS [messages];
END