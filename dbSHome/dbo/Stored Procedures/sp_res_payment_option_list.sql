-- =============================================
-- Author:		namhhm
-- Create date: 06/10/2025
-- Description:	lấy các lựa chọn khoản tiền thanh toán
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_payment_option_list] 
	-- Add the parameters for the stored procedure here
	 @UserId NVARCHAR(40) = NULL,
	 @receiveId int = 0
AS
BEGIN TRY
		-- Lấy danh sách các khoản đã thanh toán
		DECLARE @PaidSections NVARCHAR(MAX);
		SET @PaidSections = STUFF((
			SELECT ',' + [PaymentSection]
			FROM [dbSHome].[dbo].[MAS_Service_Receipts]
			WHERE ReceiveId = @receiveId
			FOR XML PATH('')
		), 1, 1, '');

		-- Lấy danh sách các khoản cần thanh toán (chưa thanh toán)
		SELECT 
			CASE 
				WHEN FeeType = 'CommonFee' THEN N'Phí dịch vụ chung'
				WHEN FeeType = 'VehicleAmt' THEN N'Phí giữ xe'
				WHEN FeeType = 'DebitAmt' THEN N'Số tiền nợ'
				WHEN FeeType = 'LivingElectricAmt' THEN N'Tiền điện sinh hoạt'
				WHEN FeeType = 'LivingWaterAmt' THEN N'Tiền nước sinh hoạt'
			END AS name,
			CASE 
				WHEN FeeType = 'CommonFee' THEN 'Common'
				WHEN FeeType = 'VehicleAmt' THEN 'Vehicle'
				WHEN FeeType = 'DebitAmt' THEN 'Debt'
				WHEN FeeType = 'LivingElectricAmt' THEN 'Electric'
				WHEN FeeType = 'LivingWaterAmt' THEN 'Water'
			END AS value
		FROM (
			SELECT 
				CAST(CommonFee AS DECIMAL(18,2)) AS CommonFee, 
				CAST(VehicleAmt AS DECIMAL(18,2)) AS VehicleAmt, 
				CAST(DebitAmt AS DECIMAL(18,2)) AS DebitAmt,
				CAST([LivingElectricAmt] AS DECIMAL(18,2)) AS LivingElectricAmt,
				CAST([LivingWaterAmt] AS DECIMAL(18,2)) AS LivingWaterAmt
			FROM [dbSHome].[dbo].[MAS_Service_ReceiveEntry]
			WHERE ReceiveId = @ReceiveId
		) AS src
		UNPIVOT (
			Amount FOR FeeType IN (CommonFee, VehicleAmt, DebitAmt, LivingElectricAmt, LivingWaterAmt)
		) AS unpvt
		WHERE Amount > 0
			AND CHARINDEX(
				CASE 
					WHEN FeeType = 'CommonFee' THEN N'Common'
					WHEN FeeType = 'VehicleAmt' THEN N'Vehicle'
					WHEN FeeType = 'DebitAmt' THEN N'Debt'
					WHEN FeeType = 'LivingElectricAmt' THEN 'Electric'
					WHEN FeeType = 'LivingWaterAmt' THEN 'Water'
				END,
				ISNULL(@PaidSections, '')
			) = 0  -- Loại bỏ các khoản đã thanh toán

		--UNION ALL

		--SELECT 
		--	ServiceObject as name,
		--	CASE 
		--		WHEN ServiceTypeId = 4 THEN N'Water'
		--		WHEN ServiceTypeId = 3 THEN N'Electric'
		--	END as value
		--FROM MAS_Service_Receivable
		--WHERE ReceiveId = @receiveId 
		--	AND (ServiceTypeId = 3 OR ServiceTypeId = 4)
		--	AND TotalAmt > 0
		--	AND CHARINDEX(
		--		CASE 
		--			WHEN ServiceTypeId = 4 THEN N'Water'
		--			WHEN ServiceTypeId = 3 THEN N'Electric'
		--		END, 
		--		ISNULL(@PaidSections, '')
		--	) = 0;  -- Loại bỏ các khoản đã thanh toán
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_payment_option_list' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';
    EXEC utl_Insert_ErrorLog @ErrorNum,
                             @ErrorMsg,
                             @ErrorProc,
                             'Payment option',
                             'GET',
                             @SessionID,
                             @AddlInfo; 
END CATCH;