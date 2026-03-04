

CREATE procedure [dbo].[sp_Hom_Card_Resident_ByHaveNumber]
	@ProjectCd	nvarchar(40),
	@filter nvarchar(50),
	@cardnum int,
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

	
		select	@Total					= count(a.[ApartmentId])
			FROM [MAS_Apartments] a 
			 join MAS_Rooms r on a.RoomCode = r.RoomCode 
			 JOIN MAS_Buildings b On r.BuildingCd = b.BuildingCd 
			 join UserInfo cc ON a.UserLogin = cc.loginName 
			 JOIN MAS_Customers c ON c.CustId = cc.CustId --and (IsManager is null or IsManager = 0)
			WHERE a.ProjectCd = @ProjectCd and (select count(cardId) from MAS_Cards where ApartmentId = a.ApartmentId) = @cardnum
				and (r.RoomCode like '%' + @filter + '%' or c.FullName like '%' + @filter +'%')
		set @TotalFiltered = @Total

	--1 profile
		SELECT b.ProjectName
			  ,a.[ApartmentId]
			  ,b.BuildingName
			  ,a.[RoomCode]
			  ,c.FullName
			  ,c.AvatarUrl
			  ,r.[Floor]
			  ,a.WaterwayArea
			  ,b.ProjectCd
			  ,a.[UserLogin]
			  ,a.[Cif_No] as CifNo
			  ,b.[BuildingCd]
			  ,a.[FamilyImageUrl]
			  ,MemberCount = (Select count(cif_no) from MAS_Customers where ApartmentId = a.ApartmentId)
	  FROM [MAS_Apartments] a 
	   join MAS_Rooms r on a.RoomCode = r.RoomCode 
	   JOIN MAS_Buildings b On r.BuildingCd = b.BuildingCd 
	   join UserInfo cc ON a.UserLogin = cc.loginName 
	   JOIN MAS_Customers c ON cc.CustId = c.CustId
	  WHERE a.ProjectCd = @ProjectCd and (select count(cardId) from MAS_Cards where ApartmentId = a.ApartmentId) = @cardnum
			and (a.RoomCode like '%' + @filter + '%' or c.FullName like '%' + @filter +'%')
		ORDER BY  a.[RoomCode] 
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
		set @ErrorMsg					= 'sp_Get_Card_HaveNumber_ByManager ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Apartment', 'GET', @SessionID, @AddlInfo
	end catch