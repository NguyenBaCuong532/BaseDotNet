










CREATE procedure [dbo].[sp_Hom_Service_Receipt_ByApartmentId]
	@userId			nvarchar(450),
	@ApartmentId	bigint,
	@filter			nvarchar(40),
	@gridWidth			int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out
as
	begin try
	
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
				
		if @Offset = 0
			begin
				SELECT * FROM dbo.[fn_config_list_gets] ('view_Hom_Service_Receipt_Page_ByApartmentId', @gridWidth) 
				ORDER BY [ordinal]
			end
		set @TotalFiltered = @Total

	--1 profile
	   SELECT [ReceiptId]
			  ,[ReceiptNo]
			  ,convert(nvarchar(10),[ReceiptDt],103) as [ReceiptDate]
			  ,a.[ApartmentId]
			  ,a.ReceiveId
			  ,[TranferCd]
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
			  ,RoomCode 
			  ,c.FullName
	  FROM [dbo].MAS_Service_Receipts a 
		join MAS_Service_ReceiveEntry d on a.ReceiveId = d.ReceiveId 
		join  MAS_Apartments b on d.ApartmentId = b.ApartmentId 
		left join MAS_Customers c on a.CustId = c.CustId
		left join Users u on a.CreatorCd = u.UserId 
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
		set @ErrorMsg					= 'sp_Hom_Service_Receipt_ByApartmentId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Document', 'GET', @SessionID, @AddlInfo
	end catch