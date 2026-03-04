








CREATE procedure [dbo].[sp_Hom_Service_Receivable_Page]
	@UserID				nvarchar(450) = null,
	@clientId			nvarchar(50) = null,
	@ProjectCd			nvarchar(10) = null,
	@filter				nvarchar(100) = '',
	@isDateFilter		bit = 0,
	@ToDate				nvarchar(10) = null,
	@StatusPayed		int = 0,
	@IsBill				bit = 0,
	@IsPush				bit = 0,
	@gridWidth			int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int = 1000 out,
	@TotalFiltered		int = 1000 out
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

		--set @ToDate = isnull(@ToDate,convert(nvarchar(10),getdate(),103))
		if @isDateFilter = 1
		set @ToDt = EOMONTH(convert(datetime,@todate,103))
	
		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		select	@Total					= count(e.[ReceiveId])
			FROM MAS_Service_ReceiveEntry e
			join MAS_Apartments b on e.ApartmentId = b.ApartmentId
			join @tbCats ca on b.projectCd = ca.categoryCd 
			join MAS_Rooms a on a.RoomCode = b.RoomCode 
			join MAS_Buildings c on a.BuildingCd = c.BuildingCd 
			join UserInfo u on b.UserLogin = u.loginName
			join MAS_Customers d on u.CustId = d.CustId
				WHERE (@filter ='' or b.RoomCode like '%' + @filter + '%' )
				    and e.isExpected = 1
					and (@StatusPayed = -1 or (@StatusPayed = 0 and e.IsPayed = 0) or (@StatusPayed = 1 and e.PaidAmt = 0) or (@StatusPayed = 2 and e.IsPayed = 1))
					and ((@IsBill is not null and isnull(e.IsBill,0) = @IsBill) or @IsBill is null)
					and (@IsPush is null or isnull(e.isPush,0) = @IsPush)
					and (@isDateFilter = 0 or (@isDateFilter = 1 and month(e.ToDt) = month(@ToDt) and year(e.ToDt) = year(@ToDt)))
		set	@TotalFiltered = @Total

		if @Offset = 0
		begin
			SELECT * FROM dbo.[fn_config_list_gets] ('view_Hom_Service_Receivable_Page', @gridWidth) 
			ORDER BY [ordinal]
		end

		--1
		SELECT e.[ReceiveId]
			  ,e.[ApartmentId]
			  ,format(e.[ReceiveDt],'dd/MM/yyyy hh:mm:ss') as receiveDate
			  --,convert(nvarchar(10),e.[FromDt],103) as fromDate
			  ,convert(nvarchar(10),e.[ToDt],103) as toDate
			  ,e.TotalAmt
			  ,convert(nvarchar(10),e.[ExpireDate],103) as [ExpireDate]
			  ,e.[IsPayed]
			  ,e.PaidAmt
			  ,format(e.PayedDt,'dd/MM/yyyy hh:mm:ss') as payedDate
			  ,e.TotalAmt - isnull(e.PaidAmt,0) as RemainAmt
			  ,b.RoomCode
			  ,d.FullName
			  ,b.WaterwayArea
			  ,e.IsBill
			  ,e.BillUrl
			  ,e.isPush
			  ,e.BillViewUrl
			  ,STUFF((
					  SELECT ',' + [ReceiptNo]
					  FROM MAS_Service_Receipts mr
					  WHERE mr.ReceiveId = e.ReceiveId
					  FOR XML PATH('')), 1, 1, '') as [ReceiptNos] 


		  FROM MAS_Service_ReceiveEntry e
			join MAS_Apartments b on e.ApartmentId = b.ApartmentId
			join @tbCats ca on b.projectCd = ca.categoryCd 
			join MAS_Rooms a on a.RoomCode = b.RoomCode 
			join MAS_Buildings c on a.BuildingCd = c.BuildingCd 
			join UserInfo u on b.UserLogin = u.loginName
			join MAS_Customers d on u.CustId = d.CustId
				WHERE (@filter ='' or b.RoomCode like '%' + @filter + '%' )
				    and e.isExpected = 1
					and (@StatusPayed = -1 or (@StatusPayed = 0 and e.IsPayed = 0) or (@StatusPayed = 1 and e.PaidAmt = 0) or (@StatusPayed = 2 and e.IsPayed = 1))
					and ((@IsBill is not null and isnull(e.IsBill,0) = @IsBill) or @IsBill is null)
					and (@IsPush is null or isnull(e.isPush,0) = @IsPush)
					and (@isDateFilter = 0 or (@isDateFilter = 1 and month(e.ToDt) = month(@ToDt) and year(e.ToDt) = year(@ToDt)))
				ORDER BY  e.[ReceiveDt] DESC, b.RoomCode
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
		set @ErrorMsg					= 'sp_Hom_Service_Receivable_Page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Expectables', 'Get', @SessionID, @AddlInfo
	end catch