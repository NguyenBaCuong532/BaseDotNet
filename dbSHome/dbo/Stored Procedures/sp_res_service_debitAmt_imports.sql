CREATE PROCEDURE [dbo].[sp_res_service_debitAmt_imports] 
	@UserId NVARCHAR(50),
	@debitAmtImport DebitAmtImportType READONLY,
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

		IF NOT EXISTS (SELECT 1 FROM @debitAmtImport)
		BEGIN
			SET @valid = 0;
			SET @messages = N'File không có dữ liệu!';
			GOTO FINAL;
		END

		DECLARE @checkTieuDe NVARCHAR(MAX);
		SELECT TOP 1 @checkTieuDe = ISNULL(RoomCode, '') + ISNULL(DebitAmt, '')
		FROM @debitAmtImport;


		IF @checkTieuDe <> N'Mã căn(*)Tồn nợ cũ(*)' AND @check = 0
		BEGIN
			SET @valid = 0;
			SET @messages = N'File mẫu không đúng ' + @checkTieuDe;
			GOTO FINAL;
		END

		CREATE TABLE #debitAmtImp (
			RoomCode NVARCHAR(100),
			DebitAmt NVARCHAR(50)
		);

		INSERT INTO #debitAmtImp (RoomCode, DebitAmt)
		SELECT RoomCode, DebitAmt FROM @debitAmtImport;

		DELETE TOP(1) FROM #debitAmtImp WHERE @check = 0;

		SELECT DISTINCT
			#debitAmtImp.RoomCode,
			#debitAmtImp.DebitAmt,
			CASE 
				WHEN ISNULL(#debitAmtImp.RoomCode, '') = '' THEN N'Mã căn không được để trống !' ELSE '' 
			END +
			CASE 
				WHEN ISNULL(#debitAmtImp.DebitAmt, '') = '' THEN N'Nợ tồn cũ không được để trống !' 
				WHEN TRY_CAST(#debitAmtImp.DebitAmt AS DECIMAL(18, 0)) IS NULL THEN N'Nợ tồn cũ không hợp lệ !' 
				ELSE '' 
			END AS errors
		INTO #debitAmtImpType_Import
		FROM #debitAmtImp
		LEFT JOIN MAS_Apartments ON #debitAmtImp.RoomCode = MAS_Apartments.RoomCode;

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
				@fileUrl, @fileSize, @UserId, GETDATE(), 
				(SELECT COUNT(*) FROM #debitAmtImpType_Import), 0
			);
		END

		IF @accept = 1
		BEGIN
			UPDATE MAS_Apartments
			SET DebitAmt = CAST(i.DebitAmt AS DECIMAL(18, 0))
			FROM MAS_Apartments m
			JOIN #debitAmtImpType_Import i ON m.RoomCode = i.RoomCode
			WHERE TRY_CAST(i.DebitAmt AS DECIMAL(18, 0)) IS NOT NULL;
		END

		SET @recordsAccepted = (SELECT COUNT(*) FROM #debitAmtImpType_Import WHERE errors = '');

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK;
		DECLARE @ErrorNum INT = ERROR_NUMBER();
		DECLARE @ErrorMsg VARCHAR(200) = 'sp_res_service_debitAmt_imports ' + ERROR_MESSAGE();
		DECLARE @ErrorProc VARCHAR(50) = ERROR_PROCEDURE();
		DECLARE @AddlInfo VARCHAR(MAX) = '@UserId ' + @UserId;

		SET @valid = 0;
		SET @messages = ERROR_MESSAGE();

		EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_res_service_debitAmt_imports', 'Set', NULL, @AddlInfo;
	END CATCH

FINAL:
	IF @valid = 0
	BEGIN
		SELECT @valid AS valid,
			   @messages AS messages,
			   'view_debit_amt_import_page' AS GridKey,
			   recordsTotal = 0,
			   recordsFail = 0,
			   recordsAccepted = CASE WHEN @accept = 1 THEN @recordsAccepted ELSE 0 END,
			   accept = CASE WHEN @recordsAccepted > 0 THEN 1 ELSE 0 END;

		SELECT * FROM dbo.fn_config_list_gets_lang('view_debit_amt_import_page', 500, @acceptLanguage);

		SELECT NULL;

		SELECT impId = @impId, fileName = @fileName, fileType = @fileType, fileSize = @fileSize, fileUrl = @fileUrl;

		GOTO FINAL2;
	END

	SELECT @valid AS valid,
		   @messages AS messages,
		   'view_debit_amt_import_page' AS GridKey,
		   recordsTotal = (SELECT COUNT(*) FROM #debitAmtImpType_Import),
		   recordsFail = (SELECT COUNT(*) FROM #debitAmtImpType_Import) - @recordsAccepted,
		   recordsAccepted = CASE WHEN @accept = 1 THEN @recordsAccepted ELSE 0 END,
		   accept = CASE WHEN @recordsAccepted > 0 THEN 1 ELSE 0 END;

	SELECT * FROM dbo.fn_config_list_gets_lang('view_debit_amt_import_page', 500, @acceptLanguage);

	SELECT
		RoomCode,
		DebitAmt,
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
	FROM #debitAmtImpType_Import
	ORDER BY errors;

	SELECT impId = @impId, fileName = @fileName, fileType = @fileType, fileSize = @fileSize, fileUrl = @fileUrl;

FINAL2:
END