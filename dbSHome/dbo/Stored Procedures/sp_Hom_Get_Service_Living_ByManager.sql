


CREATE procedure [dbo].[sp_Hom_Get_Service_Living_ByManager]
	@ProjectCd	nvarchar(40),
	@LivingTypeId int,
	@filter nvarchar(30),
	@month int,
	@year int,
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

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')

		set		@year					= isnull(@year, (select max(PeriodYear) from MAS_Service_Living_Tracking))
		set		@month					= isnull(@month, 0) --(select max(PeriodMonth) from TRS_LivingService where PeriodYear = @year))

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

	if @month > 0
	begin
		select	@Total					= count(a.LivingId)
			FROM MAS_Apartment_Service_Living a
				inner join MAS_Apartments b on a.ApartmentId = b.ApartmentId 
			  WHERE a.ProjectCd = @ProjectCd  
			  and b.RoomCode like '%' + @filter + '%'
			  and a.LivingTypeId = @LivingTypeId
			  
		set @TotalFiltered = @Total

	--1 profile
		SELECT c.TrackingId
			  ,a.[ApartmentId]
			  ,b.RoomCode as RoomCd
			  ,d.FullName
			  ,c.[PeriodMonth]
			  ,c.[PeriodYear]
			  ,convert(nvarchar(10),isnull([FromDt],a.MeterLastDt),103) as fromDate
			  ,convert(nvarchar(10),[ToDt],103) as toDate
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
			left join (select * from MAS_Service_Living_Tracking where PeriodMonth = @month and PeriodYear = @year) c on a.LivingId = c.LivingId
			inner join UserInfo cc on cc.loginName = b.UserLogin 
			inner join MAS_Customers d on cc.CustId = d.CustId
			inner join [MAS_LivingTypes] lt on a.LivingTypeId = lt.LivingTypeId 
			  WHERE a.ProjectCd = @ProjectCd 
			  and b.RoomCode like '%' + @filter + '%'
			  and a.LivingTypeId = @LivingTypeId
				ORDER BY RoomCode DESC
						  offset @Offset rows	
							fetch next @PageSize rows only
	end
	else
	begin
		select	@Total					= count(a.LivingId)
			FROM MAS_Apartment_Service_Living a
				inner join MAS_Apartments b on a.ApartmentId = b.ApartmentId 
			  WHERE a.ProjectCd = @ProjectCd  
			  and b.RoomCode like '%' + @filter + '%'
			  and a.LivingTypeId = @LivingTypeId

		set @TotalFiltered = @Total

	--1 profile
		SELECT c.TrackingId
			  ,a.[ApartmentId]
			  ,b.RoomCode as RoomCd
			  ,d.FullName
			  ,c.[PeriodMonth]
			  ,c.[PeriodYear]
			  ,convert(nvarchar(10),isnull([FromDt],a.MeterLastDt),103) as fromDate
			  ,convert(nvarchar(10),[ToDt],103) as toDate
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
			left join (select * from MAS_Service_Living_Tracking where PeriodYear = @year) c on a.LivingId = c.LivingId
			inner join UserInfo cc on cc.loginName = b.UserLogin 
			inner join MAS_Customers d on cc.CustId = d.CustId
			inner join [MAS_LivingTypes] lt on a.LivingTypeId = lt.LivingTypeId 
			  WHERE a.ProjectCd = @ProjectCd 
			  and b.RoomCode like '%' + @filter + '%'
			  and a.LivingTypeId = @LivingTypeId
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
		set @ErrorMsg					= 'sp_Hom_Get_Service_Living_ByManager ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ServiceLiving', 'GET', @SessionID, @AddlInfo
	end catch