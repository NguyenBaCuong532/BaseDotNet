-- =============================================
-- Author:		Namhm
-- Create date: 24/06/2025
-- Description:	bank gọi thanh toán về
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_bank_response_set] 
	@success	bit = null
   ,@interBankTrace nvarchar(100) = null
   ,@virtualAccount nvarchar(100) = null
   ,@actualAccount nvarchar(100) = null
   ,@fromBin nvarchar(100) = null
   ,@fromAccount nvarchar(100) = null
   ,@amount decimal(18,0) = null
   ,@statusCode nvarchar(10) = null
   ,@txnNumber nvarchar(50) = null
   ,@transferDesc nvarchar(100) = null
   ,@time nvarchar(50) = null
   ,@userId nvarchar(50) = null
   ,@acceptLanguage nvarchar(50) = 'vi-VN'
AS
BEGIN TRY
    declare @valid bit = 1
    declare @messages nvarchar(100) = N'Lưu thành công!' 
	DECLARE @totalAmt decimal(18,0) = 0
	DECLARE @receiveIds NVARCHAR(MAX)
	DECLARE @notiQue bit = 1

	DECLARE @json NVARCHAR(MAX) = NULL;
	DECLARE @ids NVARCHAR(200);
	
	-- Variables for receipt creation
	DECLARE @ReceiveId INT;
	DECLARE @ProjectCd NVARCHAR(10);
	DECLARE @CustId NVARCHAR(50);
	DECLARE @ApartmentId INT;
	DECLARE @groups VARCHAR(100);

	if not exists (select 1 from [trans_response_klb] where interBankTrace = @interBankTrace)
	begin
		if @interBankTrace is null or @interBankTrace = ''
			begin
				set @messages = N'Mã hạch toán không hợp lệ'
				set @valid = 0
				goto FINAL
			end
		
		SET @totalAmt = (SELECT re.TotalAmt FROM transaction_payment_draft tpd
						INNER JOIN MAS_Service_ReceiveEntry re ON tpd.sourceOid = re.entryId
						WHERE tpd.virtualAcc = @virtualAccount)

		-- kiểm tra cập nhật trạng thái thanh toán 
		IF @totalAmt = @amount
			BEGIN
				UPDATE re
				SET re.IsPayed = 1
				FROM MAS_Service_ReceiveEntry re
				INNER JOIN transaction_payment_draft tpd ON tpd.sourceOid = re.entryId
				WHERE tpd.virtualAcc = @virtualAccount;

				-- Cập nhật tất cả các phần thành đã thanh toán 
				UPDATE a
				SET 
					a.IsPaid = 1,
					a.PaymentDate = GETDATE()
				FROM dbo.MAS_Service_Receivable a
				JOIN MAS_Service_ReceiveEntry b ON a.ReceiveId = b.ReceiveId
				JOIN transaction_payment_draft c ON b.entryId = c.sourceOid
				WHERE c.virtualAcc = @virtualAccount
			END
		ELSE
			BEGIN
				SELECT @json = metadata 
					FROM transaction_payment_draft
					WHERE virtualAcc = @virtualAccount

				IF(@json is not null or @json != '')
				BEGIN
					SELECT @ids = value
					FROM OPENJSON(@json)
					WHERE [key] = 'ReceivableIds';

					SELECT @groups = value
					FROM OPENJSON(@json)
					WHERE [key] = 'groups';

					-- Tạo bảng tạm (table variable)
					DECLARE @ReceivableIds TABLE (ReceivableId BIGINT);

					-- Tách chuỗi và insert vào bảng tạm
					INSERT INTO @ReceivableIds (ReceivableId)
						SELECT TRY_CAST(TRIM(value) AS BIGINT)
						FROM STRING_SPLIT(@ids, ',')
						WHERE TRIM(value) <> '';

					-- cập trạng thái đã thanh toán
					UPDATE r
					SET 
						r.IsPaid = 1,
						r.PaymentDate = GETDATE()
					FROM dbo.MAS_Service_Receivable r
					INNER JOIN @ReceivableIds ids ON r.ReceivableId = ids.ReceivableId;
				END
			END

		-- Get data for receipt creation
		SELECT TOP 1
			@ReceiveId = re.ReceiveId,
			@ProjectCd = a.projectCd,
			--@CustId = re.CustId,
			@ApartmentId = a.ApartmentId
		FROM MAS_Service_ReceiveEntry re
		INNER JOIN transaction_payment_draft tpd ON tpd.sourceOid = re.entryId
		LEFT JOIN MAS_Apartments a ON re.ApartmentId = a.ApartmentId
		WHERE tpd.virtualAcc = @virtualAccount;

		declare @date nvarchar(10) = CONVERT(NVARCHAR(10), GETDATE(), 103)
		-- Create receipt for bank transfer payment
		IF @ReceiveId IS NOT NULL
		BEGIN
			EXEC sp_res_receipt_SetInfo
				@UserID = @userId
				,@ReceiptId = 0
				,@ProjectCd = @ProjectCd
				,@ReceiptNo = NULL
				,@ReceiptDate = @date
				,@ReceiveId = @ReceiveId
				,@CustId = @CustId
				,@ApartmentId = @ApartmentId
				,@TranferCd = 'transfer'
				,@Object = NULL
				,@PassNo = NULL
				,@PassDate = NULL
				,@PassPlc = NULL
				,@Address = NULL
				,@Contents = @transferDesc
				,@Amount = @amount
				,@Attach = NULL
				,@IsDBCR = 0
				,@IsDebit = 0
				,@AmtSubtractPoint = 0
				,@PaymentOption = @groups;
		END

		--ghi log
		INSERT INTO [dbo].[trans_response_klb]
				([id]
				,[success]
				,[interBankTrace]
				,[virtualAccount]
				,[actualAccount]
				,[fromBin]
				,[fromAccount]
				,[amount]
				,[statusCode]
				,[txnNumber]
				,[transferDesc]
				,[time]
				,[created]
				,rc_count)
			VALUES
				(newid()
				,@success
				,@interBankTrace
				,@virtualAccount
				,@actualAccount
				,@fromBin
				,@fromAccount
				,@amount
				,@statusCode
				,@txnNumber
				,@transferDesc
				,@time
				,getdate()
				,1)



	end
	else
		begin
			SET @notiQue = 0
			update [trans_response_klb]
				set rc_count = rc_count +1
				where interBankTrace = @interBankTrace
		end

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_res_Receipt_SetInfo ' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = '@CustId ' + @userId

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'MAS_Receipts'
        , 'Insert'
        , @SessionID
        , @AddlInfo
END CATCH
FINAL:
select @valid as valid
	   ,@messages as [messages]
	   ,@notiQue as	notiQue