alter PROCEDURE [dbo].[sp_res_service_payment_imports] 
	@UserId UNIQUEIDENTIFIER = NULL,
	@paymentImport PaymentImportType READONLY,
	@accept BIT = 0,
	@check BIT = 0,
	@tranferCd NVARCHAR(250) = 'cash',
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
		DECLARE @recordsAccepted BIGINT = 0;
		DECLARE @gridKey NVARCHAR(100) = 'view_payment_import_page';

		IF NOT EXISTS (SELECT 1 FROM @paymentImport)
		BEGIN
			SET @valid = 0;
			SET @messages = N'File không có dữ liệu!';
			GOTO FINAL;
		END

		CREATE TABLE #paymentImportStaging (
			RowNum INT IDENTITY(1,1) PRIMARY KEY,
			RoomCode NVARCHAR(100),
			InvoiceCode NVARCHAR(100),
			EndDate NVARCHAR(50),
			PaymentSection NVARCHAR(200),
			PaymentAmount NVARCHAR(50),
			Target NVARCHAR(200),
			PaymentContent NVARCHAR(500),
			PaymentDate NVARCHAR(50)
		);

		INSERT INTO #paymentImportStaging (RoomCode, InvoiceCode, EndDate, PaymentSection, PaymentAmount, Target, PaymentContent, PaymentDate)
		SELECT RoomCode, InvoiceCode, EndDate, PaymentSection, PaymentAmount, Target, PaymentContent, PaymentDate
		FROM @paymentImport;

		IF @check = 0
		BEGIN
			DELETE TOP (1) FROM #paymentImportStaging;
		END

		IF NOT EXISTS (SELECT 1 FROM #paymentImportStaging)
		BEGIN
			SET @valid = 0;
			SET @messages = N'File không có dữ liệu!';
			GOTO FINAL;
		END

		CREATE TABLE #paymentImportResult (
			RowNum INT PRIMARY KEY,
			RoomCode NVARCHAR(100),
			InvoiceCode NVARCHAR(100),
			EndDate NVARCHAR(50),
			PaymentSection NVARCHAR(200),
			PaymentAmount NVARCHAR(50),
			Target NVARCHAR(200),
			PaymentContent NVARCHAR(500),
			PaymentDate NVARCHAR(50),
			CleanPaymentSection NVARCHAR(200),
			ApartmentId BIGINT,
			ReceiveId BIGINT,
			ProjectCd NVARCHAR(30),
			PaymentAmtValue DECIMAL(18,2),
			PaymentDateValue DATETIME,
			errors NVARCHAR(MAX),
			isProcessed BIT DEFAULT(0)
		);

		INSERT INTO #paymentImportResult (
			RowNum,
			RoomCode,
			InvoiceCode,
			EndDate,
			PaymentSection,
			PaymentAmount,
			Target,
			PaymentContent,
			PaymentDate,
			CleanPaymentSection,
			ApartmentId,
			ReceiveId,
			ProjectCd,
			PaymentAmtValue,
			PaymentDateValue,
			errors
		)
		SELECT
			p.RowNum,
			p.RoomCode,
			p.InvoiceCode,
			p.EndDate,
			p.PaymentSection,
			p.PaymentAmount,
			p.Target,
			p.PaymentContent,
			p.PaymentDate,
			sec.CleanSection,
			ma.ApartmentId,
			re.ReceiveId,
			ISNULL(re.ProjectCd, ma.projectCd),
			TRY_CONVERT(DECIMAL(18,2), p.PaymentAmount),
			TRY_CONVERT(DATETIME, p.PaymentDate, 103),
			(
				CASE WHEN ISNULL(p.RoomCode, '') = '' THEN N'Mã căn không được để trống !' ELSE '' END +
				CASE WHEN ISNULL(p.RoomCode, '') <> '' AND ma.ApartmentId IS NULL THEN N'Mã căn không tồn tại trong hệ thống !' ELSE '' END +
				CASE WHEN ISNULL(p.InvoiceCode, '') = '' THEN N'Mã hóa đơn không được để trống !'
					 WHEN TRY_CONVERT(BIGINT, p.InvoiceCode) IS NULL THEN N'Mã hóa đơn không hợp lệ !'
					 WHEN TRY_CONVERT(BIGINT, p.InvoiceCode) IS NOT NULL AND re.ReceiveId IS NULL THEN N'Không tìm thấy hóa đơn tương ứng !'
					 WHEN ma.ApartmentId IS NOT NULL AND re.ReceiveId IS NOT NULL AND ISNULL(ma.ApartmentId, -1) <> ISNULL(re.ApartmentId, -2) THEN N'Hóa đơn không thuộc về căn hộ này !'
					 ELSE '' END +
				CASE 
					WHEN LTRIM(RTRIM(ISNULL(p.PaymentAmount, ''))) = '' AND ISNULL(sec.CleanSection, '') = '' THEN N'Số tiền thanh toán không được để trống !'
					WHEN LTRIM(RTRIM(ISNULL(p.PaymentAmount, ''))) <> '' AND TRY_CONVERT(DECIMAL(18,2), p.PaymentAmount) IS NULL THEN N'Số tiền thanh toán không hợp lệ !'
					WHEN LTRIM(RTRIM(ISNULL(p.PaymentAmount, ''))) <> '' AND TRY_CONVERT(DECIMAL(18,2), p.PaymentAmount) <= 0 THEN N'Số tiền thanh toán phải lớn hơn 0 !'
					ELSE '' 
				END +
				CASE WHEN ISNULL(p.PaymentDate, '') = '' THEN N'Ngày thanh toán không được để trống !'
					 WHEN TRY_CONVERT(DATETIME, p.PaymentDate, 103) IS NULL THEN N'Ngày thanh toán không hợp lệ (định dạng dd/MM/yyyy)!'
					 ELSE '' END +
				CASE WHEN ISNULL(sec.InvalidCount, 0) > 0 THEN N'Khoản thanh toán không hợp lệ !'
					 WHEN ISNULL(sec.AlreadyPaidCount, 0) > 0 THEN N'Khoản thanh toán đã được ghi nhận trước đó !'
					 WHEN ISNULL(sec.ZeroCount, 0) > 0 THEN N'Khoản thanh toán đã hết hoặc không còn dư nợ !'
					 ELSE '' END
			)
		FROM #paymentImportStaging p
		LEFT JOIN MAS_Apartments ma ON ma.RoomCode = p.RoomCode
		LEFT JOIN MAS_Service_ReceiveEntry re ON re.ReceiveId = TRY_CONVERT(BIGINT, p.InvoiceCode)
		OUTER APPLY (
			SELECT 
				CleanSection     = STRING_AGG(ps.SectionEn, ','),
				SectionCount     = COUNT(*),
				InvalidCount     = SUM(ps.IsInvalid),
				AlreadyPaidCount = SUM(ps.IsPaidFlag),
				ZeroCount        = SUM(ps.IsZeroFlag)
			FROM (
				SELECT DISTINCT 
					SectionEn = CASE 
									WHEN LOWER(LTRIM(RTRIM(value))) IN ('common','vehicle','electric','water','debt') THEN 
										CONCAT(UPPER(LEFT(LTRIM(RTRIM(value)),1)), LOWER(SUBSTRING(LTRIM(RTRIM(value)),2,LEN(LTRIM(RTRIM(value)))))) 
									WHEN LOWER(LTRIM(RTRIM(value))) = N'tiền điện' THEN 'Electric'
									WHEN LOWER(LTRIM(RTRIM(value))) = N'tiền nước' THEN 'Water'
									WHEN LOWER(LTRIM(RTRIM(value))) IN (N'phí giữ xe', N'tiền xe', N'tiền giữ xe', N'tiền gửi xe') THEN 'Vehicle'
									WHEN LOWER(LTRIM(RTRIM(value))) = N'phí dịch vụ chung' THEN 'Common'
									WHEN LOWER(LTRIM(RTRIM(value))) = N'tiền nợ' THEN 'Debt'
									ELSE NULL
								END,
					AmountForSection = CASE 
											WHEN LOWER(LTRIM(RTRIM(value))) IN (N'phí dịch vụ chung', 'common') THEN ISNULL(re.CommonFee,0)
											WHEN LOWER(LTRIM(RTRIM(value))) IN (N'phí giữ xe', N'tiền xe', N'tiền giữ xe', N'tiền gửi xe', 'vehicle') THEN ISNULL(re.VehicleAmt,0)
											WHEN LOWER(LTRIM(RTRIM(value))) IN (N'tiền điện', 'electric') THEN ISNULL(re.LivingElectricAmt,0)
											WHEN LOWER(LTRIM(RTRIM(value))) IN (N'tiền nước', 'water') THEN ISNULL(re.LivingWaterAmt,0)
											WHEN LOWER(LTRIM(RTRIM(value))) IN (N'tiền nợ', 'debt') THEN ISNULL(re.DebitAmt,0)
											ELSE 0
										END,
					IsInvalid = CASE WHEN LOWER(LTRIM(RTRIM(value))) NOT IN ('common','vehicle','electric','water','debt',
																			N'tiền điện', N'tiền nước', N'phí giữ xe', N'tiền xe', N'tiền giữ xe', N'tiền gửi xe', N'phí dịch vụ chung', N'tiền nợ')
										THEN 1 ELSE 0 END,
					IsPaidFlag = CASE 
									 WHEN re.ReceiveId IS NOT NULL
										  AND EXISTS (
												SELECT 1 
												FROM MAS_Service_Receipts r
												CROSS APPLY STRING_SPLIT(ISNULL(r.PaymentSection, ''), ',') s
												WHERE r.ReceiveId = re.ReceiveId
												  AND LTRIM(RTRIM(s.value)) = 
														CASE 
															WHEN LOWER(LTRIM(RTRIM(value))) IN ('common','vehicle','electric','water','debt') THEN 
																CONCAT(UPPER(LEFT(LTRIM(RTRIM(value)),1)), LOWER(SUBSTRING(LTRIM(RTRIM(value)),2,LEN(LTRIM(RTRIM(value)))))) 
															WHEN LOWER(LTRIM(RTRIM(value))) = N'tiền điện' THEN 'Electric'
															WHEN LOWER(LTRIM(RTRIM(value))) = N'tiền nước' THEN 'Water'
															WHEN LOWER(LTRIM(RTRIM(value))) IN (N'phí giữ xe', N'tiền xe', N'tiền giữ xe', N'tiền gửi xe') THEN 'Vehicle'
															WHEN LOWER(LTRIM(RTRIM(value))) = N'phí dịch vụ chung' THEN 'Common'
															WHEN LOWER(LTRIM(RTRIM(value))) = N'tiền nợ' THEN 'Debt'
															ELSE NULL
														END
											)
									THEN 1 ELSE 0 END,
					IsZeroFlag = CASE 
									WHEN re.ReceiveId IS NULL THEN 1
									WHEN CASE 
											WHEN LOWER(LTRIM(RTRIM(value))) IN (N'phí dịch vụ chung', 'common') THEN ISNULL(re.CommonFee,0)
											WHEN LOWER(LTRIM(RTRIM(value))) IN (N'phí giữ xe', N'tiền xe', N'tiền giữ xe', N'tiền gửi xe', 'vehicle') THEN ISNULL(re.VehicleAmt,0)
											WHEN LOWER(LTRIM(RTRIM(value))) IN (N'tiền điện', 'electric') THEN ISNULL(re.LivingElectricAmt,0)
											WHEN LOWER(LTRIM(RTRIM(value))) IN (N'tiền nước', 'water') THEN ISNULL(re.LivingWaterAmt,0)
											WHEN LOWER(LTRIM(RTRIM(value))) IN (N'tiền nợ', 'debt') THEN ISNULL(re.DebitAmt,0)
											ELSE 0 END <= 0 THEN 1 ELSE 0 END
				FROM STRING_SPLIT(REPLACE(ISNULL(p.PaymentSection, ''), ';', ','), ',')
				WHERE LTRIM(RTRIM(value)) <> ''
			) ps
			WHERE ps.SectionEn IS NOT NULL
		) sec;

		IF (@impId IS NULL OR NOT EXISTS (SELECT 1 FROM ImportFiles WHERE impId = @impId)) AND @fileName IS NOT NULL
		BEGIN
			SET @impId = NEWID();
			INSERT INTO ImportFiles (
				impId, import_type, upload_file_name, upload_file_type,
				upload_file_url, upload_file_size, created_by, created_dt,
				row_count, updated_st
			)
			VALUES (
				@impId, 'payment_import', @fileName, @fileType,
				@fileUrl, @fileSize, CAST(@UserId AS NVARCHAR(50)), GETDATE(),
				(SELECT COUNT(*) FROM #paymentImportResult), 0
			);
		END

		IF @accept = 1
		BEGIN
			DECLARE @RowNum INT,
					@ApartmentId BIGINT,
					@ReceiveId BIGINT,
					@ProjectCd NVARCHAR(30),
					@CleanSection NVARCHAR(200),
					@PaymentAmt DECIMAL(18,2),
					@PaymentDateValue DATETIME,
					@PaymentDateText NVARCHAR(10),
					@contents NVARCHAR(350),
					@object NVARCHAR(200),
					@SectionTotal DECIMAL(18,2);

			DECLARE cur_payment CURSOR FAST_FORWARD FOR
				SELECT RowNum, ApartmentId, ReceiveId, ProjectCd, CleanPaymentSection, PaymentAmtValue, PaymentDateValue, PaymentContent, Target
				FROM #paymentImportResult
				WHERE ISNULL(errors, '') = '';

			OPEN cur_payment;
			FETCH NEXT FROM cur_payment INTO @RowNum, @ApartmentId, @ReceiveId, @ProjectCd, @CleanSection, @PaymentAmt, @PaymentDateValue, @contents, @object;

			WHILE @@FETCH_STATUS = 0
			BEGIN
				BEGIN TRY
					SET @PaymentDateText = CONVERT(NVARCHAR(10), ISNULL(@PaymentDateValue, GETDATE()), 103);
					IF ISNULL(@contents, '') = '' SET @contents = N'Import thanh toán cư dân';

					-- Tính tổng tiền theo các khoản thanh toán đã chọn (nếu có)
					SET @SectionTotal = NULL;
					IF ISNULL(@CleanSection, '') <> ''
					BEGIN
						SELECT @SectionTotal = SUM(
							CASE ss.value
								WHEN 'Common'  THEN ISNULL(re.CommonFee, 0)
								WHEN 'Vehicle' THEN ISNULL(re.VehicleAmt, 0)
								WHEN 'Electric' THEN ISNULL(re.LivingElectricAmt, 0)
								WHEN 'Water'   THEN ISNULL(re.LivingWaterAmt, 0)
								WHEN 'Debt'    THEN ISNULL(re.DebitAmt, 0)
								ELSE 0
							END)
						FROM STRING_SPLIT(@CleanSection, ',') ss
						CROSS JOIN MAS_Service_ReceiveEntry re
						WHERE re.ReceiveId = @ReceiveId;
					END

					-- Nếu không nhập số tiền nhưng có khoản thanh toán -> lấy tổng khoản thanh toán
					IF ( @PaymentAmt IS NULL OR @PaymentAmt = 0 ) AND @SectionTotal IS NOT NULL
					BEGIN
						SET @PaymentAmt = @SectionTotal;
						UPDATE #paymentImportResult
						SET PaymentAmtValue = @PaymentAmt
						WHERE RowNum = @RowNum;
					END

					-- Nếu nhập cả số tiền và khoản thanh toán nhưng lệch -> báo lỗi và bỏ qua dòng
					IF @PaymentAmt IS NOT NULL AND @SectionTotal IS NOT NULL AND @PaymentAmt <> @SectionTotal
					BEGIN
						UPDATE #paymentImportResult
						SET errors = ISNULL(errors, '') + CASE WHEN ISNULL(errors,'')='' THEN '' ELSE N' ' END
									+ N'Số tiền không khớp tổng khoản thanh toán đã chọn!'
						WHERE RowNum = @RowNum;
						FETCH NEXT FROM cur_payment INTO @RowNum, @ApartmentId, @ReceiveId, @ProjectCd, @CleanSection, @PaymentAmt, @PaymentDateValue, @contents, @object;
						CONTINUE;
					END

					EXEC [dbo].[sp_res_Receipt_SetInfo]
						@UserID = @UserId,
						@ReceiptId = 0,
						@ProjectCd = @ProjectCd,
						@ReceiptNo = NULL,
						@ReceiptDate = @PaymentDateText,
						@ReceiveId = @ReceiveId,
						@CustId = NULL,
						@ApartmentId = @ApartmentId,
						@TranferCd = 'cash',
						@Object = @object,
						@PassNo = NULL,
						@PassDate = NULL,
						@PassPlc = NULL,
						@Address = NULL,
						@Contents = @contents,
						@Amount = @PaymentAmt,
						@Attach = NULL,
						@IsDBCR = 0,
						@IsDebit = 0,
						@AmtSubtractPoint = 0,
						@PaymentOption = @CleanSection;

					UPDATE #paymentImportResult
					SET isProcessed = 1
					WHERE RowNum = @RowNum;
				END TRY
				BEGIN CATCH
					UPDATE #paymentImportResult
					SET errors = ISNULL(errors, '') 
								+ CASE WHEN ISNULL(errors, '') = '' THEN '' ELSE N' ' END
								+ ERROR_MESSAGE()
					WHERE RowNum = @RowNum;
				END CATCH;

				FETCH NEXT FROM cur_payment INTO @RowNum, @ApartmentId, @ReceiveId, @ProjectCd, @CleanSection, @PaymentAmt, @PaymentDateValue, @contents, @object;
			END

			CLOSE cur_payment;
			DEALLOCATE cur_payment;

			SET @recordsAccepted = (
				SELECT COUNT(*) 
				FROM #paymentImportResult 
				WHERE ISNULL(errors, '') = '' AND isProcessed = 1
			);
		END
		ELSE
		BEGIN
			SET @recordsAccepted = (
				SELECT COUNT(*) 
				FROM #paymentImportResult 
				WHERE ISNULL(errors, '') = ''
			);
		END

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK;
		DECLARE @ErrorNum INT = ERROR_NUMBER();
		DECLARE @ErrorMsg VARCHAR(200) = 'sp_res_service_payment_imports ' + ERROR_MESSAGE();
		DECLARE @ErrorProc VARCHAR(50) = ERROR_PROCEDURE();
		DECLARE @AddlInfo VARCHAR(MAX) = '@UserId ' + ISNULL(CAST(@UserId AS NVARCHAR(50)), '');

		SET @valid = 0;
		SET @messages = ERROR_MESSAGE();

		EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_res_service_payment_imports', 'Set', NULL, @AddlInfo;
	END CATCH

FINAL:
	IF @valid = 0
	BEGIN
		SELECT @valid AS valid,
			   @messages AS messages,
			   @gridKey AS GridKey,
			   recordsTotal = 0,
			   recordsFail = 0,
			   recordsAccepted = CASE WHEN @accept = 1 THEN @recordsAccepted ELSE 0 END,
			   accept = CASE WHEN @recordsAccepted > 0 THEN 1 ELSE 0 END;

		SELECT * FROM dbo.fn_config_list_gets_lang(@gridKey, 500, @acceptLanguage);

		SELECT NULL;

		SELECT impId = @impId, fileName = @fileName, fileType = @fileType, fileSize = @fileSize, fileUrl = @fileUrl;
		GOTO FINAL2;
	END

	SELECT @valid AS valid,
		   @messages AS messages,
		   @gridKey AS GridKey,
		   recordsTotal = (SELECT COUNT(*) FROM #paymentImportResult),
		   recordsFail = (SELECT COUNT(*) FROM #paymentImportResult) - @recordsAccepted,
		   recordsAccepted = CASE WHEN @accept = 1 THEN @recordsAccepted ELSE 0 END,
		   accept = CASE WHEN @recordsAccepted > 0 THEN 1 ELSE 0 END;

	SELECT * FROM dbo.fn_config_list_gets_lang(@gridKey, 500, @acceptLanguage);

	SELECT
		RoomCode,
		InvoiceCode,
		EndDate,
		PaymentSection = CASE 
							WHEN ISNULL(CleanPaymentSection, '') <> '' THEN (
								SELECT STRING_AGG(
									CASE 
										WHEN LTRIM(RTRIM(ss.value)) = 'Common'  THEN N'Phí dịch vụ chung'
										WHEN LTRIM(RTRIM(ss.value)) = 'Vehicle' THEN N'Phí giữ xe'
										WHEN LTRIM(RTRIM(ss.value)) = 'Electric' THEN N'Tiền điện'
										WHEN LTRIM(RTRIM(ss.value)) = 'Water'   THEN N'Tiền nước'
										WHEN LTRIM(RTRIM(ss.value)) = 'Debt'    THEN N'Tiền nợ'
										ELSE LTRIM(RTRIM(ss.value))
									END, ',')
								FROM STRING_SPLIT(CleanPaymentSection, ',') ss
								WHERE LTRIM(RTRIM(ss.value)) <> ''
							)
							WHEN ISNULL(PaymentSection, '') <> '' THEN (
								SELECT STRING_AGG(
									CASE 
										WHEN LOWER(LTRIM(RTRIM(value))) IN ('common','vehicle','electric','water','debt') THEN 
											CASE 
												WHEN LOWER(LTRIM(RTRIM(value))) = 'common' THEN N'Phí dịch vụ chung'
												WHEN LOWER(LTRIM(RTRIM(value))) = 'vehicle' THEN N'Phí giữ xe'
												WHEN LOWER(LTRIM(RTRIM(value))) = 'electric' THEN N'Tiền điện'
												WHEN LOWER(LTRIM(RTRIM(value))) = 'water' THEN N'Tiền nước'
												WHEN LOWER(LTRIM(RTRIM(value))) = 'debt' THEN N'Tiền nợ'
											END
										WHEN LOWER(LTRIM(RTRIM(value))) = N'tiền điện' THEN N'Tiền điện'
										WHEN LOWER(LTRIM(RTRIM(value))) = N'tiền nước' THEN N'Tiền nước'
										WHEN LOWER(LTRIM(RTRIM(value))) IN (N'phí giữ xe', N'tiền xe', N'tiền giữ xe', N'tiền gửi xe') THEN N'Phí giữ xe'
										WHEN LOWER(LTRIM(RTRIM(value))) = N'phí dịch vụ chung' THEN N'Phí dịch vụ chung'
										WHEN LOWER(LTRIM(RTRIM(value))) = N'tiền nợ' THEN N'Tiền nợ'
										ELSE LTRIM(RTRIM(value))
									END, ',')
								FROM STRING_SPLIT(REPLACE(ISNULL(PaymentSection, ''), ';', ','), ',')
								WHERE LTRIM(RTRIM(value)) <> ''
							)
							ELSE NULL
						END,
		PaymentAmount,
		Target,
		PaymentContent,
		PaymentDate,
		apccept = @accept,
		errors = CASE 
					WHEN ISNULL(errors, '') = '' THEN 
						CASE 
							WHEN @valid = 1 AND @accept = 1 THEN N'<span class="bg-success noti-number ml5">Done</span>'
							WHEN @valid = 0 AND @accept = 1 THEN N'<span class="bg-warning noti-number ml5">Error</span>'
							ELSE N'<span class="bg-success noti-number ml5">OK</span>'
						END
					ELSE N'<span class="bg-danger noti-number ml5">' + errors + '</span>'
				END
	FROM #paymentImportResult
	ORDER BY errors;

	SELECT impId = @impId, fileName = @fileName, fileType = @fileType, fileSize = @fileSize, fileUrl = @fileUrl;

FINAL2:
END


