
-- Lịch sử giao dịch theo căn hộ
CREATE procedure [dbo].[sp_res_service_receipt_byapartid]
	@UserId			UNIQUEIDENTIFIER = NULL,
	@ApartmentId	bigint,
	@filter			nvarchar(40),
	@gridWidth			int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@AcceptLanguage VARCHAR(20) = 'vi-VN'
	--@Total				int out,
	--@TotalFiltered		int OUT,
	--@GridKey		nvarchar(100) out
as
	begin try
		declare @Total		bigint
		declare @GridKey	nvarchar(100) = 'view_service_receipt_byApartmentId_page'

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		

		select	@Total					= count(a.ReceiptId)
			FROM MAS_Service_Receipts a 
				join MAS_Service_ReceiveEntry d on a.ReceiveId = d.ReceiveId 
			WHERE d.ApartmentId = @ApartmentId
			
		--root	
		select recordsTotal = @Total
			  ,recordsFiltered = @Total
			  ,gridKey = @GridKey
			  ,valid = 1
		--grid config
		if @Offset = 0
			begin
				SELECT * FROM dbo.[fn_config_list_gets_lang] (@GridKey, @gridWidth, @AcceptLanguage) 
				ORDER BY [ordinal]
			end
		
	--1 profile
	   SELECT [ReceiptId]
			  ,[ReceiptNo]
			  ,convert(nvarchar(10),[ReceiptDt],103) as [ReceiptDate]
			  ,a.[ApartmentId]
			  ,a.ReceiveId
			  ,cd.par_desc AS [TranferCd]
			  ,isnull([Object],c.fullName) as [Object]
			  ,a.[Pass_No] as PassNo
			  ,a.[Address]
			  ,[Contents]
			  ,[Attach]
			  ,case when [IsDBCR] = 1 then N'Phiếu thu' else N'Phiếu chi' end as DBCR
			  ,[Amount]
			  ,u.loginName as [CreatorCd]
			  ,format([CreateDate], 'dd/MM/yyyy hh:mm:ss') as [CreateDate]
			  ,[AccountLeft]
			  ,[AccountRight]
			  ,a.[ProjectCd]
			  ,b.RoomCode 
			  ,c.FullName
			  ,c.CustId
	  FROM [dbo].MAS_Service_Receipts a 
		join MAS_Service_ReceiveEntry d on a.ReceiveId = d.ReceiveId 
		join  MAS_Apartments b on d.ApartmentId = b.ApartmentId 
		left join MAS_Customers c on a.CustId = c.CustId
		left join Users u on a.CreatorCd = u.UserId 
		LEFT JOIN dbo.sys_config_data cd ON cd.key_1 = 'debtTransfer_method' AND cd.value1 = a.TranferCd
		WHERE b.ApartmentId = @ApartmentId
			ORDER BY  a.[ReceiptDt] DESC 
				  offset @Offset rows	
					fetch next @PageSize rows only
	

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_service_receipt_byApartmentId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Document', 'GET', @SessionID, @AddlInfo
	end catch