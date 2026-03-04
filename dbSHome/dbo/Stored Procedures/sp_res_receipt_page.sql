CREATE procedure [dbo].[sp_res_receipt_page]
	@userId		UNIQUEIDENTIFIER = NULL,
	@clientId	nvarchar(50) = null,
	@periods_oid	nvarchar(50) = null,
	@ProjectCd	nvarchar(30) = '-1',
	@isExpected	INT = -1,
	@isResident	INT = -1,
	@filter		NVARCHAR(200) = NULL,
	@isDateFilter		BIT = 0,
	@FromDate			NVARCHAR(10) = NULL,
	@ToDate				NVARCHAR(10) = NULL,
	@gridWidth			INT				= 0,
	@Offset				INT				= 0,
	@PageSize			INT				= 10,
	@acceptLanguage		NVARCHAR(50)	= N'vi-VN'
AS
BEGIN TRY
		DECLARE @Total		BIGINT
		DECLARE @GridKey	NVARCHAR(100) = 'view_receipt_page'
		DECLARE @ToDt DATETIME
		
		SET		@Offset					= ISNULL(@Offset, 0)
		SET		@PageSize				= ISNULL(@PageSize, 10)
		SET		@Total					= ISNULL(@Total, 0)
		SET		@filter					= ISNULL(@filter,'')
		SET		@ProjectCd				= ISNULL(@ProjectCd,'')
		SET		@isExpected				= ISNULL(@isExpected,-1)
		SET		@IsResident				= ISNULL(@IsResident,-1)
		SET		@isDateFilter			= ISNULL(@isDateFilter,0)

		IF		@PageSize	<= 0		SET @PageSize	= 10
		IF		@Offset		< 0			SET @Offset		=  0
		
		SELECT	@Total = COUNT(a.ReceiptId)
		FROM
        MAS_Service_ReceiveEntry d
        JOIN [dbo].MAS_Service_Receipts a ON d.ReceiveId = a.ReceiveId
        LEFT JOIN  MAS_Apartments b ON d.ApartmentId = b.ApartmentId 
        LEFT JOIN MAS_Customers c ON a.CustId= c.CustId
		WHERE
        (@ProjectCd ='-1' OR b.projectCd = @ProjectCd) 
        AND EXISTS(SELECT 1 FROM UserProject up WHERE up.userId = @userId AND up.projectCd = @ProjectCd)
        AND (@isExpected = -1 OR d.isExpected = @isExpected)
        AND (@IsResident = -1 
          OR (@IsResident = 0 AND NOT EXISTS(SELECT 1 FROM MAS_Apartments WHERE ApartmentId = d.ApartmentId))
          OR (@IsResident = 1 AND EXISTS(SELECT 1 FROM MAS_Apartments WHERE ApartmentId = d.ApartmentId))
          )
        AND(@isDateFilter = 0 OR (@isDateFilter = 1 AND a.ReceiptDt BETWEEN CONVERT(DATETIME,@fromDate,103) AND DATEADD(DAY,1,CONVERT(DATETIME,@toDate,103))))
        AND (@filter = '' OR b.RoomCode LIKE '%' + @filter + '%' OR c.Phone LIKE '%'+@filter+'%' OR a.ReceiveId LIKE '%'+@filter+'%')
        AND (@periods_oid IS NULL OR d.periods_oid = @periods_oid)

		 --root	
		SELECT recordsTotal = @Total
			  ,recordsFiltered = @Total
			  ,gridKey = @GridKey
			  ,valid = 1
		--grid config
		IF @Offset = 0
		BEGIN
			SELECT *
			FROM [dbo].fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
			ORDER BY [ordinal];
		END

		--1 profile
		  -- Thêm cột đã dịch vào SELECT
    SELECT 
				[ReceiptId]
				,[ReceiptNo]
				,CONVERT(NVARCHAR(10), [ReceiptDt], 103) AS [ReceiptDate]
				,a.ReceiveId
				,a.TranferCd
				,[TranferName] = pm.name
				,ISNULL([Object], c.fullName) AS [Object]
				,ISNULL(a.[Pass_No], c.Pass_No) AS PassNo
				,A.[Address]
				,[Contents]
				,[Attach]
				,[IsDBCR]
				,a.[Amount]
				,u2.loginName AS [CreatorCd]
				,[CreateDate] = FORMAT([CreateDate], 'dd/MM/yyyy HH:mm')
				,a.ReceiptBillViewUrl
				,b.RoomCode
				-- Dịch PaymentSection
				,PaymentSection = (
					SELECT STRING_AGG(
						CASE TRIM(s.value)
							WHEN 'Common'   THEN N'Dịch vụ chung'
							WHEN 'Debt'     THEN N'Nợ phí'
							WHEN 'Electric' THEN N'Điện sinh hoạt'
							WHEN 'Water'    THEN N'Nước sạch'
							WHEN 'Vehicle'  THEN N'Phí gửi phương tiện'
							ELSE TRIM(s.value)
						END, ', ')
					FROM STRING_SPLIT(a.PaymentSection, ',') AS s
				)
    FROM
        MAS_Service_ReceiveEntry d
        JOIN [dbo].MAS_Service_Receipts a ON d.ReceiveId = a.ReceiveId
        LEFT JOIN (SELECT code = value1, [name] = par_desc FROM sys_config_data WHERE key_1 = 'payment_method') pm ON pm.code = a.TranferCd
        LEFT JOIN MAS_Apartments b ON d.ApartmentId = b.ApartmentId
        LEFT JOIN MAS_Customers c ON a.CustId = c.CustId
        LEFT JOIN dbo.Users u2 ON a.CreatorCd = u2.UserId
    WHERE
        (@ProjectCd = '-1' OR b.projectCd = @ProjectCd)
			  AND EXISTS(SELECT 1 FROM UserProject up WHERE up.userId = @userId AND up.projectCd = @ProjectCd)
			  AND (@isExpected = -1 OR d.isExpected = @isExpected)
			  AND (@IsResident = -1
            OR (@IsResident = 0 AND NOT EXISTS(SELECT 1 FROM MAS_Apartments WHERE ApartmentId = d.ApartmentId))
            OR (@IsResident = 1 AND EXISTS(SELECT 1 FROM MAS_Apartments WHERE ApartmentId = d.ApartmentId)))
			  AND (@isDateFilter = 0 
             OR (@isDateFilter = 1 
					   AND a.ReceiptDt BETWEEN CONVERT(DATETIME, @fromDate, 103) 
						AND DATEADD(DAY, 1, CONVERT(DATETIME, @toDate, 103))))
			  AND (@filter = '' 
            OR b.RoomCode LIKE '%' + @filter + '%' 
            OR c.Phone LIKE '%' + @filter + '%' 
            OR ReceiptNo LIKE '%' + @filter + '%')
        AND (@periods_oid IS NULL OR d.periods_oid = @periods_oid)
			ORDER BY a.[ReceiptDt] DESC
			OFFSET @Offset ROWS
			FETCH NEXT @PageSize ROWS ONLY;
	
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_receipt_page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Service_Receipt', 'GET', @SessionID, @AddlInfo
	end catch