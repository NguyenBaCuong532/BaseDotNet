



CREATE procedure [dbo].[sp_Hom_Get_Request_Services]
	@userId		nvarchar(450),
	@clientId	nvarchar(50),
	@projectCd	nvarchar(50),
	@filter		nvarchar(500),
	@statuses	nvarchar(200), 
	@RequestKey nvarchar(100),
	@IsCardReq	bit,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out
as
	begin try	
		declare @tbstatus TABLE 
		(
			id [Int] null
		)
		declare @webId nvarchar(50) --= (select id from [dbAppManager].[dbo].[ClientWebs] where clientId = @clientId or clientIdDev = @clientId)
		set @webId = '77929A9C-3085-4158-AE32-320A67704899'
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
		set		@filter					= isnull(@filter, '%')
		set		@statuses				= isnull(@statuses, '0,1,2,3,4,5')
		set		@RequestKey				= isnull(@RequestKey, '%')
		set		@projectCd				= isnull(@projectCd,'')

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		if		@filter		= ''		set @filter		= '%'
		if		@statuses		= ''	set @statuses	= '0,1,2,3,4,5'
		if		@RequestKey		= ''	set @RequestKey	= '%'

		INSERT INTO @tbstatus SELECT [part] FROM [dbo].[SplitString](@statuses,',')

	
		select	@Total					= count(RequestId)
		FROM MAS_Requests a 
			JOIN MAS_Apartments b On a.ApartmentId = b.ApartmentId 
			join @tbCats r on b.projectCd = r.categoryCd
			
			WHERE b.RoomCode like @filter 
				and isnull([Status],0) in (select id from @tbstatus)
				AND RequestKey like @RequestKey AND RequestKey like 'Card%' 
		set	@TotalFiltered = @Total

		if @PageSize < 0
		begin
			set	@PageSize				= 10
		end

		SELECT RequestKey
			  ,a.RequestId
			  ,p.ProjectCd 
			  ,ProjectName
			  ,b.RoomCode 
			  ,RequestTypeName 
			  ,TypeName
			  ,[dbo].[fn_Get_TimeAgo1](a.RequestDt,getdate()) as RequestDate
			  ,a.RequestDt as RequestDt
			  ,a.RequestTypeId as TypeId
			  ,isnull([Status],0) [Status]
			  ,case RequestKey 
				when 'RequestFix' then
					case isnull([Status],0) when 0 then N'Mới yêu cầu' when 1 then N'Đã phân công' when 2 then N'Đang xử lý' else N'Hoàn thành' end 
				when 'RequestSev' then
					case isnull([Status],0) when 0 then N'Mới yêu cầu' when 1 then N'Đã phân công' when 2 then N'Đang xử lý' else N'Hoàn thành' end 
				when 'CardRegister' then
					case isnull([Status],0) when 0 then N'Mới yêu cầu' when 1 then N'Đã xem' when 2 then N'Đâ cấp thẻ' else N'Từ chối' end 
				when 'CardAdd' then
					case isnull([Status],0) when 0 then N'Mới yêu cầu' when 1 then N'Đã xem' when 2 then N'Đâ phê duyệt' else N'Từ chối' end 
				else
					case isnull([Status],0) when 0 then N'Yêu cầu khóa' when 1 then N'Đã xem' when 2 then N'Đã khóa thẻ' else N'Từ chối' end 
			  end as	[StatusName]
			  ,d.FullName
			  ,e.CardCd
		  FROM MAS_Requests a 
			join MAS_Apartments b On a.ApartmentId = b.ApartmentId
			join MAS_Request_Types c ON a.RequestTypeId = c.RequestTypeId  
				JOIN UserInfo cc ON b.UserLogin = cc.loginName
				JOIN MAS_Customers d ON cc.CustId = d.CustId
				join MAS_Projects p ON b.projectCd = p.projectCd  
				join @tbCats r on b.projectCd = r.categoryCd
				left join MAS_Cards e on a.RequestId = e.RequestId 
			WHERE b.RoomCode like @filter 
			and isnull([Status],0) in (select id from @tbstatus)
				AND RequestKey like @RequestKey AND RequestKey like 'Card%' 
		ORDER BY [Status], RequestDt DESC
			offset @Offset rows	
					fetch next @PageSize rows only

	--end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Get_RequestFixs_ByUserId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserId ' 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'RequestFixs', 'GET', @SessionID, @AddlInfo
	end catch