










CREATE procedure [dbo].[sp_Hom_Service_Receipt_Page]
	@userId		nvarchar(450),
	@clientId	nvarchar(50),
	@ProjectCd	nvarchar(30),
	@isExpected	int,
	@isResident	int,
	@filter		nvarchar(200),
	@isDateFilter		bit = 0,
	@FromDate			nvarchar(10) = null,
	@ToDate				nvarchar(10) = null,
	@gridWidth			int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out
as
	begin try
		declare @ToDt datetime
		declare @webId nvarchar(50) --= (select id from [dbAppManager].[dbo].[ClientWebs] where clientId = @clientId or clientIdDev = @clientId)
		declare @tbCats TABLE 
		(
			categoryCd [nvarchar](20) not null  INDEX IX1_category NONCLUSTERED
		)
		set		@projectCd				= isnull(@projectCd,'')
		INSERT INTO @tbCats
		select distinct u.categoryCd from [dbSHome].[dbo].[MAS_Category_User] u 
			where u.UserId = @UserId and u.webId = @webId and u.isAll = 0 
			and not exists(select CategoryCd from @tbCats where categoryCd = u.CategoryCd)
			and (@ProjectCd = '' or u.categoryCd = @ProjectCd)
		INSERT INTO @tbCats
		select distinct n.categoryCd from [dbSHome].[dbo].[MAS_Category_User] u join [dbSHome].[dbo].MAS_Category n on n.base_type = u.base_type 
			where u.UserId = @UserId and u.webId = @webId and u.isAll = 1
			and not exists(select CategoryCd from @tbCats where categoryCd = n.CategoryCd)
			and (@ProjectCd = '' or n.categoryCd = @ProjectCd)

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')
		set		@ProjectCd				= isnull(@ProjectCd,'')
		set		@isExpected				= isnull(@isExpected,-1)
		set		@IsResident				= isnull(@IsResident,-1)
		set		@isDateFilter			= isnull(@isDateFilter,0)

		if		@PageSize	<= 0		set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		
		if @Offset = 0
		begin
			SELECT * FROM dbo.[fn_config_list_gets] ('view_Hom_Service_Receipt_Page', @gridWidth) 
			ORDER BY [ordinal]
		end

		select	@Total					= count(a.ReceiptId)
		FROM MAS_Service_ReceiveEntry d
			join [dbo].MAS_Service_Receipts a on d.ReceiveId = a.ReceiveId
			left join  MAS_Apartments b on d.ApartmentId = b.ApartmentId 
			left join MAS_Customers c on a.CustId= c.CustId
				--join @tbCats ca on b.projectCd = ca.categoryCd 
		WHERE exists(select categoryCd from @tbCats where categoryCd = b.projectCd)
			and (@isExpected = -1 or d.isExpected = @isExpected)
			and (@IsResident = -1 
				or (@IsResident = 0 and not exists(select 1 from MAS_Apartments where ApartmentId = d.ApartmentId))
				or (@IsResident = 1 and exists(select 1 from MAS_Apartments where ApartmentId = d.ApartmentId))
				)
			and(@isDateFilter = 0 or (@isDateFilter = 1 and a.ReceiptDt between convert(datetime,@fromDate,103) and dateadd(day,1,convert(datetime,@toDate,103))))
			and (@filter = '' or b.RoomCode like '%' + @filter + '%' or c.Phone like @filter)

		set @TotalFiltered = @Total

		--1 profile
		  SELECT [ReceiptId]
			  ,[ReceiptNo]
			  ,convert(nvarchar(10),[ReceiptDt],103) as [ReceiptDate]
			  --,a.[ApartmentId]
			  ,a.ReceiveId
			  ,a.TranferCd
			  ,isnull([Object],c.fullName) as [Object]
			  ,isnull(a.[Pass_No],c.Pass_No) as PassNo
			  ,A.[Address]
			  ,[Contents]
			  ,[Attach]
			  ,[IsDBCR]
			  ,a.[Amount]
			  ,u2.loginName as [CreatorCd]
			  ,[CreateDate]
			  ,a.ReceiptBillViewUrl
			  --,[AccountLeft]
			  --,[AccountRight]
			  --,d.[ProjectCd]
			  ,b.RoomCode 
			  --,c.FullName
		  FROM MAS_Service_ReceiveEntry d
			join [dbo].MAS_Service_Receipts a on d.ReceiveId = a.ReceiveId
			left join  MAS_Apartments b on d.ApartmentId = b.ApartmentId 			
			left join MAS_Customers c on a.CustId= c.CustId			
			left join Users u2 on a.CreatorCd = u2.UserId 
		WHERE exists(select categoryCd from @tbCats where categoryCd = b.projectCd)
			and (@isExpected = -1 or d.isExpected = @isExpected)
			and (@IsResident = -1 
				or (@IsResident = 0 and not exists(select 1 from MAS_Apartments where ApartmentId = d.ApartmentId))
				or (@IsResident = 1 and exists(select 1 from MAS_Apartments where ApartmentId = d.ApartmentId))
				)
			and(@isDateFilter = 0 or (@isDateFilter = 1 and a.ReceiptDt between convert(datetime,@fromDate,103) and dateadd(day,1,convert(datetime,@toDate,103))))
			and (@filter = '' or b.RoomCode like '%' + @filter + '%' or c.Phone like @filter)
			ORDER BY a.[ReceiptDt] DESC 
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
		set @ErrorMsg					= 'sp_Hom_Service_Receipt_Page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Service_Receipt', 'GET', @SessionID, @AddlInfo
	end catch