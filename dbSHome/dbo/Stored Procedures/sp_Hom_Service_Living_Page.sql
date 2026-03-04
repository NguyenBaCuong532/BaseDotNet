


 --exec sp_Hom_Service_Living_Page null,null,'03',2,'',10,2020,100,0,10,100,100
CREATE procedure [dbo].[sp_Hom_Service_Living_Page]
	@UserId		nvarchar(450),
	@clientId	nvarchar(50),
	@ProjectCd	nvarchar(40),
	@LivingTypeId int,
	@filter		nvarchar(30)=null,
	@month		int,
	@year		int,
	@gridWidth			int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out
as
	begin try
		declare @tbService TABLE 
		(
			id [Int] null
		)
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
		--set		@filter					= isnull(@filter,'')

		set		@year					= isnull(@year, (select max(PeriodYear) from MAS_Service_Living_Tracking))
		set		@month					= isnull(@month, 0) --(select max(PeriodMonth) from TRS_LivingService where PeriodYear = @year))

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		if @Offset = 0
		begin
			SELECT * FROM dbo.[fn_config_list_gets] ('view_Hom_Service_Living_Page', @gridWidth) 
			ORDER BY [ordinal]
		end

	if @month > 0
	begin
		select	@Total					= count(a.LivingId)
			FROM MAS_Apartment_Service_Living a
				inner join MAS_Apartments b on a.ApartmentId = b.ApartmentId 
				join @tbCats ca on b.projectCd = ca.categoryCd 
				left join (select * from MAS_Service_Living_Tracking where PeriodMonth = @month and PeriodYear = @year) c on a.LivingId = c.LivingId
			  WHERE a.LivingTypeId = @LivingTypeId
			   and (@filter is null or b.RoomCode like '%' + @filter + '%')
				and exists(select categoryCd from @tbCats where categoryCd = b.projectCd and (@ProjectCd = '' or categoryCd = @ProjectCd))
				--and c.[PeriodMonth] = @month and c.PeriodYear = @year
				--and b.RoomCode like '%' + @filter
			   
			  
		set @TotalFiltered = @Total

	--1 profile
		SELECT c.TrackingId
			  ,a.[ApartmentId]
			  ,b.RoomCode
			  ,d.FullName
			  ,isnull(c.[PeriodMonth],@month) as PeriodMonth
			  ,isnull(c.[PeriodYear],@year) as PeriodYear
			  ,convert(nvarchar(20),isnull(c.[FromDt],a.MeterLastDt),103) as fromDate
			  ,convert(nvarchar(20),c.[ToDt],103) as toDate
			  ,lt.LivingTypeName 
			  ,isnull(c.[FromNum],a.MeterLastNum) as [FromNum]
			  ,c.[ToNum]
			  ,c.TotalNum
			  ,c.[Amount]
			  ,c.InputType
			  ,c.InputId
			  ,a.MeterSeri as MeterSerial
			  ,isnull(c.IsCalculate,0) as IsCalculate
			  ,isnull(c.IsBill,0) as IsBill
			  ,isnull(c.IsReceivable,0) as IsReceivable
			  ,a.LivingId
			  ,a.LivingTypeId
	  FROM MAS_Apartment_Service_Living a 
			inner join MAS_Apartments b on a.ApartmentId = b.ApartmentId 
			join @tbCats ca on b.projectCd = ca.categoryCd 
			left join (select * from MAS_Service_Living_Tracking where PeriodMonth = @month and PeriodYear = @year) c on a.LivingId = c.LivingId
			inner join UserInfo cc on cc.loginName = b.UserLogin 
			inner join MAS_Customers d on cc.CustId = d.CustId
			inner join [MAS_LivingTypes] lt on a.LivingTypeId = lt.LivingTypeId 
			  WHERE  a.LivingTypeId = @LivingTypeId
			  	and (@filter is null or b.RoomCode like '%' + @filter + '%')
				and exists(select categoryCd from @tbCats where categoryCd = b.projectCd and (@ProjectCd = '' or categoryCd = @ProjectCd))
				--and b.RoomCode like '%' + @filter
				ORDER BY RoomCode DESC
						  offset @Offset rows	
							fetch next @PageSize rows only
	end
	else
	begin
		select	@Total					= count(a.LivingId)
			FROM MAS_Apartment_Service_Living a
				inner join MAS_Apartments b on a.ApartmentId = b.ApartmentId 
				join @tbCats ca on b.projectCd = ca.categoryCd 
				left join (select * from MAS_Service_Living_Tracking where  PeriodYear = @year) c on a.LivingId = c.LivingId
			  WHERE (@filter = '' or b.RoomCode like '%' + @filter + '%')
			    and a.LivingTypeId = @LivingTypeId
				and exists(select categoryCd from @tbCats where categoryCd = b.projectCd and (@ProjectCd = '' or categoryCd = @ProjectCd))

		set @TotalFiltered = @Total

	--1 profile
		SELECT c.TrackingId
			  ,a.[ApartmentId]
			  ,b.RoomCode as RoomCd
			  ,d.FullName
			  ,isnull(c.[PeriodMonth],@month) as PeriodMonth
			  ,isnull(c.[PeriodYear],@year) as PeriodYear
			  ,convert(nvarchar(20),isnull(c.[FromDt],a.MeterLastDt),103) as fromDate
			  ,convert(nvarchar(20),c.[ToDt],103) as toDate
			  ,lt.LivingTypeName 
			  ,isnull(c.[FromNum],a.MeterLastNum) as [FromNum]
			  ,c.[ToNum]
			  ,c.TotalNum
			  ,c.[Amount]
			  ,c.InputType
			  ,c.InputId
			  ,a.MeterSeri as MeterSerial
			  ,isnull(c.IsCalculate,0) as IsCalculate
			  ,isnull(c.IsBill,0) as IsBill
			  ,isnull(c.IsReceivable,0) as IsReceivable
			  ,a.LivingId
	  FROM MAS_Apartment_Service_Living a 
			inner join MAS_Apartments b on a.ApartmentId = b.ApartmentId 
			join @tbCats ca on b.projectCd = ca.categoryCd 
			left join (select * from MAS_Service_Living_Tracking where PeriodYear = @year) c on a.LivingId = c.LivingId
			inner join UserInfo cc on cc.loginName = b.UserLogin 
			inner join MAS_Customers d on cc.CustId = d.CustId
			inner join [MAS_LivingTypes] lt on a.LivingTypeId = lt.LivingTypeId 
			  WHERE (@filter = '' or b.RoomCode like '%' + @filter + '%')
			    and a.LivingTypeId = @LivingTypeId
				and exists(select categoryCd from @tbCats where categoryCd = b.projectCd and (@ProjectCd = '' or categoryCd = @ProjectCd))
				ORDER BY RoomCode DESC
						  offset @Offset rows	
							fetch next @PageSize rows only
	end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Service_Living_Page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ServiceLiving', 'GET', @SessionID, @AddlInfo
	end catch