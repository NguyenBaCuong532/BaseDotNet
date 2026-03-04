







CREATE procedure [dbo].[sp_Hom_Get_Payment_List_ByManager]
	@ProjectCd	nvarchar(40),
	@buildingCd nvarchar(30) = null,
	@floor int = 0,
	@filter nvarchar(100) = null,
	@Month				int				= 0,
	@Year				int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out
as
	begin try
	
		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@buildingCd				= isnull(@buildingCd,'%')
		set		@filter					= isnull(@filter,'')
		set		@floor					= isnull(@floor,0)
		set		@Month					= isnull(@Month,0)
		set		@Year					= isnull(@Year,0)

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		if		@buildingCd	= ''		set @buildingCd	=  '%'
		--if		@Month		= 0			set @Month		= month(getdate())
		if		@Year		= 0			set @Year		= (select year(max(ToDt)) from MAS_Service_ReceiveEntry a inner join MAS_Apartments b on a.ApartmentId = b.ApartmentId 
			inner join MAS_Rooms r on b.RoomCode = r.RoomCode inner join MAS_Buildings c on r.BuildingCd = c.BuildingCd where c.ProjectCd = @ProjectCd)
		if		@Month		= 0			set @Month		= (select month(max(ToDt)) from MAS_Service_ReceiveEntry a inner join MAS_Apartments b on a.ApartmentId = b.ApartmentId 
			inner join MAS_Rooms r on b.RoomCode = r.RoomCode inner join MAS_Buildings c on r.BuildingCd = c.BuildingCd where c.ProjectCd = @ProjectCd and year(a.ToDt) = @Year)

	if @floor = 0
	begin
		select	@Total					= count(a.[ApartmentId])
			FROM [MAS_Apartments] a 
			 join MAS_Rooms r on a.RoomCode = r.RoomCode
			 JOIN MAS_Buildings b On r.BuildingCd = b.BuildingCd 
			 JOIN MAS_Contacts cc ON a.Cif_No = cc.Cif_No
			 JOIN MAS_Customers c ON cc.CustId = c.CustId
			 join MAS_Service_ReceiveEntry d on d.ApartmentId = a.ApartmentId 
			WHERE b.ProjectCd = @ProjectCd and r.BuildingCd like @buildingCd and (r.RoomCode like '%' + @filter + '%' or c.FullName like '%' + @filter +'%')
				and month(d.ToDt) = @Month and year(d.ToDt) = @Year

		set @TotalFiltered = @Total

	--1 profile
		SELECT ProjectName
		  ,a.[ApartmentId]
		  ,b.BuildingName
		  ,a.[RoomCode]
		  ,c.FullName
		  ,r.[Floor]
		  ,a.WaterwayArea
		  ,b.ProjectCd
		  ,a.[Cif_No] as CifNo
		  ,[FamilyImageUrl]
		  ,month(d.ToDt) [PeriodMonth]
		  ,year(d.ToDt) [PeriodYear]
		  ,0 as F_CreditAmt
		  ,d.TotalAmt as CurrAmt
		  ,0 as DebitAmt
		  ,null as [PayDate]
		  

	  FROM [MAS_Apartments] a 
			 join MAS_Rooms r on a.RoomCode = r.RoomCode
			 JOIN MAS_Buildings b On r.BuildingCd = b.BuildingCd 
			 JOIN UserInfo cc ON a.UserLogin = cc.loginName
			 JOIN MAS_Customers c ON cc.CustId = c.CustId --and (IsManager is null or IsManager = 0)
			 join MAS_Service_ReceiveEntry d on d.ApartmentId = a.ApartmentId 
	  WHERE b.ProjectCd = @ProjectCd and r.BuildingCd like @buildingCd 
			and (r.RoomCode like '%' + @filter + '%' or c.FullName like '%' + @filter +'%')
			and month(d.ToDt) = @Month and year(d.ToDt) = @Year
		ORDER BY  a.[RoomCode] 
				  offset @Offset rows	
					fetch next @PageSize rows only
	end
	else
	begin
		select	@Total					= count(a.[ApartmentId])
			FROM [MAS_Apartments] a 
			 join MAS_Rooms r on a.RoomCode = r.RoomCode
			 JOIN MAS_Buildings b On r.BuildingCd = b.BuildingCd 
			 JOIN MAS_Contacts cc ON a.Cif_No = cc.Cif_No
			 JOIN MAS_Customers c ON cc.CustId = c.CustId
			 join MAS_Service_ReceiveEntry d on d.ApartmentId = a.ApartmentId 
			WHERE b.ProjectCd = @ProjectCd and r.BuildingCd like @buildingCd and [Floor] = @floor
				and (r.RoomCode like '%' + @filter + '%' or c.FullName like '%' + @filter +'%')
				and month(d.ToDt) = @Month and year(d.ToDt) = @Year
		set @TotalFiltered = @Total

	--1 profile
		SELECT ProjectName
		  ,a.[ApartmentId]
		  ,b.BuildingName
		  ,a.[RoomCode]
		  ,c.FullName
		  ,r.[Floor]
		  ,a.WaterwayArea
		  ,b.ProjectCd
		  ,a.[Cif_No] as CifNo
		  ,[FamilyImageUrl]
		  ,month(d.ToDt) [PeriodMonth]
		  ,year(d.ToDt) [PeriodYear]
		  ,0 as F_CreditAmt
		  ,0 as CurrAmt
		  ,0 as DebitAmt
		  ,null as [PayDate]

	  FROM [MAS_Apartments] a 
			 join MAS_Rooms r on a.RoomCode = r.RoomCode
			 JOIN MAS_Buildings b On r.BuildingCd = b.BuildingCd 
			 JOIN UserInfo cc ON a.UserLogin = cc.loginName
			 JOIN MAS_Customers c ON cc.CustId = c.CustId
			 join MAS_Service_ReceiveEntry d on d.ApartmentId = a.ApartmentId 
	  WHERE b.ProjectCd = @ProjectCd and r.BuildingCd like @buildingCd and [Floor] = @floor
		  and (r.RoomCode like '%' + @filter + '%' or c.FullName like '%' + @filter +'%')
		  and month(d.ToDt) = @Month and year(d.ToDt) = @Year
		ORDER BY  a.[RoomCode] 
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
		set @ErrorMsg					= 'sp_Hom_Get_Payment_List_ByManager ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'PaymentList', 'GET', @SessionID, @AddlInfo
	end catch