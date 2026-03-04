CREATE   procedure [dbo].[sp_res_service_TotalAmt_imports] 
	@UserId UNIQUEIDENTIFIER = NULL,
	@totalAmtImport TotalAmtImportType READONLY,
	@accept BIT = 0,
	@check BIT = 0,
	@livingTypeId INT = 1,
	@impId UNIQUEIDENTIFIER = NULL,
	@fileName NVARCHAR(200) = NULL,
	@fileType NVARCHAR(100) = NULL,
	@fileSize BIGINT = NULL,
	@fileUrl NVARCHAR(400) = NULL,
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		DECLARE @valid BIT = 1;
		DECLARE @messages NVARCHAR(MAX);
		DECLARE @recordsAccepted BIGINT;

		IF NOT EXISTS (SELECT 1 FROM @totalAmtImport)
		BEGIN
			SET @valid = 0;
			SET @messages = N'File không có dữ liệu!';
			GOTO FINAL;
		END

		DECLARE @checkTieuDe NVARCHAR(MAX);
		SELECT TOP 1 @checkTieuDe = ISNULL(RoomCode, '') + ISNULL(TotalAmt, '')
		FROM @totalAmtImport;

		IF @checkTieuDe <> N'Mã căn(*)Tổng tiền hóa đơn(*)' AND @check = 0
		BEGIN
			SET @valid = 0;
			SET @messages = N'File mẫu không đúng';
			GOTO FINAL;
		END

		CREATE TABLE #totalAmtImp (
			RoomCode NVARCHAR(MAX),
			TotalAmt NVARCHAR(MAX)
		);

		INSERT INTO #totalAmtImp (RoomCode, TotalAmt)
		SELECT RoomCode, TotalAmt FROM @totalAmtImport;

		DELETE TOP(1) FROM #totalAmtImp WHERE @check = 0;

		-- CORRECTED PART: Added table aliases 'imp' and 's' to resolve ambiguity
		SELECT DISTINCT
			imp.RoomCode,
			imp.TotalAmt,
			CASE 
				WHEN ISNULL(imp.RoomCode, '') = '' THEN N'Mã căn không được để trống !' ELSE '' 
			END +
			CASE 
				WHEN ISNULL(imp.TotalAmt, '') = '' THEN N'Tổng tiền hóa đơn không được để trống !' 
				WHEN TRY_CAST(imp.TotalAmt AS DECIMAL(18, 0)) IS NULL THEN N'Tổng tiền không hợp lệ !' 
				ELSE '' 
			END +
			CASE 
				WHEN s.IsBill = 1 THEN N'Hóa đơn đã xuất, không thể cập nhật tổng tiền !'
				ELSE ''
			END AS errors
		INTO #totalAmtImpType_Import
		FROM #totalAmtImp AS imp
		LEFT JOIN MAS_Apartments as ma ON ma.RoomCode = imp.RoomCode
		LEFT JOIN MAS_Service_ReceiveEntry AS s ON ma.ApartmentId = s.ApartmentId;

		IF (@impId IS NULL OR NOT EXISTS (SELECT 1 FROM ImportFiles WHERE impId = @impId)) AND @fileName IS NOT NULL
		BEGIN
			SET @impId = NEWID();
			INSERT INTO ImportFiles (
				impId, import_type, upload_file_name, upload_file_type, 
				upload_file_url, upload_file_size, created_by, created_dt, 
				row_count, updated_st
			)
			VALUES (
				@impId, 'living_import', @fileName, @fileType, 
				@fileUrl, @fileSize, CAST(@UserId AS NVARCHAR(50)), GETDATE(), 
				(SELECT COUNT(*) FROM #totalAmtImpType_Import), 0
			);
		END

		IF @accept = 1
		BEGIN
			UPDATE s
			SET s.TotalAmt = TRY_CAST(i.TotalAmt AS DECIMAL(18, 0))
			FROM MAS_Service_ReceiveEntry s
			JOIN MAS_Apartments ma ON s.ApartmentId = ma.ApartmentId
			JOIN #totalAmtImpType_Import i ON ma.RoomCode = i.RoomCode
			WHERE TRY_CAST(i.TotalAmt AS DECIMAL(18, 0)) IS NOT NULL;

		END

		SET @recordsAccepted = (SELECT COUNT(*) FROM #totalAmtImpType_Import WHERE errors = '');

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK;
		DECLARE @ErrorNum INT = ERROR_NUMBER();
		DECLARE @ErrorMsg VARCHAR(200) = 'sp_res_service_TotalAmt_imports ' + ERROR_MESSAGE();
		DECLARE @ErrorProc VARCHAR(50) = ERROR_PROCEDURE();
		DECLARE @AddlInfo VARCHAR(MAX) = '@UserId ' + ISNULL(CAST(@UserId AS NVARCHAR(50)), '');

		SET @valid = 0;
		SET @messages = ERROR_MESSAGE();

		EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_res_service_TotalAmt_imports', 'Set', NULL, @AddlInfo;
	END CATCH

FINAL:
	IF @valid = 0
	BEGIN
		SELECT @valid AS valid,
			   @messages AS messages,
			   'view_total_amt_import_page' AS GridKey,
			   recordsTotal = 0,
			   recordsFail = 0,
			   recordsAccepted = CASE WHEN @accept = 1 THEN @recordsAccepted ELSE 0 END,
			   accept = CASE WHEN @recordsAccepted > 0 THEN 1 ELSE 0 END;

		SELECT * FROM dbo.fn_config_list_gets_lang('view_total_amt_import_page', 500, @acceptLanguage);

		SELECT NULL;

		SELECT impId = @impId, fileName = @fileName, fileType = @fileType, fileSize = @fileSize, fileUrl = @fileUrl;

		GOTO FINAL2;
	END

	SELECT @valid AS valid,
		   @messages AS messages,
		   'view_total_amt_import_page' AS GridKey,
		   recordsTotal = (SELECT COUNT(*) FROM #totalAmtImpType_Import),
		   recordsFail = (SELECT COUNT(*) FROM #totalAmtImpType_Import) - @recordsAccepted,
		   recordsAccepted = CASE WHEN @accept = 1 THEN @recordsAccepted ELSE 0 END,
		   accept = CASE WHEN @recordsAccepted > 0 THEN 1 ELSE 0 END;

	SELECT * FROM dbo.fn_config_list_gets_lang('view_total_amt_import_page', 500, @acceptLanguage);

	SELECT
		RoomCode,
		TotalAmt,
		apccept = @accept,
		errors = CASE 
			WHEN errors = '' THEN 
				CASE 
					WHEN @valid = 1 AND @accept = 1 THEN N'<span class="bg-success noti-number ml5">Done</span>'
					WHEN @valid = 0 AND @accept = 1 THEN N'<span class="bg-warning noti-number ml5">Error</span>'
					ELSE N'<span class="bg-success noti-number ml5">OK</span>'
				END
			ELSE N'<span class="bg-danger noti-number ml5">' + errors + '</span>'  
		END
	FROM #totalAmtImpType_Import
	ORDER BY errors;

	SELECT impId = @impId, fileName = @fileName, fileType = @fileType, fileSize = @fileSize, fileUrl = @fileUrl;

FINAL2:
END