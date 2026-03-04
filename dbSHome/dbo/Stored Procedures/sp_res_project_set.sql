-- =============================================
-- Author:		System
-- Create date: 2025-01-29
-- Description:	Tạo/Cập nhật bảng MAS_Projects
-- Updated: Hỗ trợ cả projectCd và Oid (backward compatible)
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[sp_res_project_set]
	@UserId			UNIQUEIDENTIFIER = NULL,
	@acceptLanguage	NVARCHAR(50) = N'vi-VN',
	@Oid			UNIQUEIDENTIFIER = NULL, -- Ưu tiên sử dụng (GUID)
	@projectCd		NVARCHAR(10) = NULL, -- Backward compatible
	@projectName	NVARCHAR(50) = NULL,
	@address		NVARCHAR(250) = NULL,
	@timeWorking	NVARCHAR(50) = NULL,
	@bank_acc_name	NVARCHAR(250) = NULL,
	@bank_acc_no	NVARCHAR(250) = NULL,
	@bank_code		NVARCHAR(250) = NULL,
	@bank_branch	NVARCHAR(200) = NULL,
	@representative_name NVARCHAR(250) = NULL,
	@investorName	NVARCHAR(200) = NULL,
	@mailSender		NVARCHAR(100) = NULL,
	@dayOfIndexElectric	INT = NULL,
	@dayOfIndexWater	INT = NULL,
	@caculateVehicleType	INT = NULL,
	@dayOfNotice1	NVARCHAR(20) = NULL,
	@dayOfNotice2	NVARCHAR(20) = NULL,
	@dayOfNotice3	NVARCHAR(20) = NULL,
	@dayStopService	NVARCHAR(20) = NULL,
	@type_discount_elec INT = NULL,
	@type_discount_water INT = NULL,
	@is_proxy_payment BIT = NULL
AS
BEGIN
BEGIN TRY
	SET NOCOUNT ON;
	
	DECLARE @valid BIT = 0;
	DECLARE @messages NVARCHAR(250);
	DECLARE @action NVARCHAR(20);
	DECLARE @ActualOid UNIQUEIDENTIFIER = NULL;
	DECLARE @ActualProjectCd NVARCHAR(10) = NULL;

	-- Xác định Oid từ projectCd nếu có
	IF @projectCd IS NOT NULL AND @Oid IS NULL
	BEGIN
		SELECT @ActualOid = oid, @ActualProjectCd = @projectCd
		FROM MAS_Projects
		WHERE projectCd = @projectCd;
	END
	ELSE IF @Oid IS NOT NULL
	BEGIN
		SELECT @ActualOid = @Oid, @ActualProjectCd = projectCd
		FROM MAS_Projects
		WHERE oid = @Oid;
	END
	
	-- Kiểm tra INSERT hay UPDATE
	IF @ActualOid IS NOT NULL AND EXISTS (SELECT 1 FROM MAS_Projects WHERE oid = @ActualOid)
	BEGIN
		-- =============================================
		-- UPDATE - Cập nhật bản ghi
		-- =============================================
		SET @action = N'UPDATE';
		
		UPDATE MAS_Projects
		SET [investorName] = ISNULL(@investorName, investorName)
			,[address] = ISNULL(@address, address)
			,[timeWorking] = ISNULL(@timeWorking, timeWorking)
			,[bank_acc_no] = ISNULL(@bank_acc_no, bank_acc_no)
			,[bank_acc_name] = ISNULL(@bank_acc_name, bank_acc_name)
			,[bank_branch] = ISNULL(@bank_branch, bank_branch)
			,bank_code = ISNULL(@bank_code, bank_code)
			,[mailSender] = ISNULL(@mailSender, mailSender)
			,dayOfIndexElectric = ISNULL(@dayOfIndexElectric, dayOfIndexElectric)
			,dayOfIndexWater = ISNULL(@dayOfIndexWater, dayOfIndexWater)
			,caculateVehicleType = ISNULL(@caculateVehicleType, caculateVehicleType)
			,dayOfNotice1 = CASE WHEN @dayOfNotice1 IS NOT NULL THEN CONVERT(DATETIME, @dayOfNotice1, 103) ELSE dayOfNotice1 END
			,dayOfNotice2 = CASE WHEN @dayOfNotice2 IS NOT NULL THEN CONVERT(DATETIME, @dayOfNotice2, 103) ELSE dayOfNotice2 END
			,dayOfNotice3 = CASE WHEN @dayOfNotice3 IS NOT NULL THEN CONVERT(DATETIME, @dayOfNotice3, 103) ELSE dayOfNotice3 END
			,dayStopService = CASE WHEN @dayStopService IS NOT NULL THEN CONVERT(DATETIME, @dayStopService, 103) ELSE dayStopService END
			,type_discount_elec = ISNULL(@type_discount_elec, type_discount_elec)
			,type_discount_water = ISNULL(@type_discount_water, type_discount_water)
			,is_proxy_payment = ISNULL(@is_proxy_payment, is_proxy_payment)
			,representative_name = ISNULL(@representative_name, representative_name)
		WHERE oid = @ActualOid;

		SET @valid = 1;
		SET @messages = N'Cập nhật thành công';
	END
	ELSE
	BEGIN
		-- =============================================
		-- INSERT - Thêm mới bản ghi (không hỗ trợ trong procedure này)
		-- =============================================
		SET @valid = 0;
		SET @messages = N'Không tìm thấy dự án';
		SET @action = N'NOT_FOUND';
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
	EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, N'MAS_Projects', N'SET', @SessionID, @AddlInfo;
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