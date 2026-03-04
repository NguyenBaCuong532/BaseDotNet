






CREATE procedure [dbo].[sp_Hom_Apartment_User_ByPush]
	@userId	nvarchar(450),
	--@action	nvarchar(50),
	@projectCd	nvarchar(20),
	@buildingCd	nvarchar(40),
	@apartments	nvarchar(max)

as
	begin try
	set @buildingCd = isnull(@buildingCd,'')
	set @apartments = isnull(@apartments,'')

		SELECT distinct a.[ApartmentId] 
			  ,a.[RoomCode] as room
			  ,c.FullName 
			  ,c.AvatarUrl as Avatar
			  ,userId = ma.memberUserId
			  ,c.CustId
			  ,left(isnull(c.Phone,''),20) as Phone
			  ,isnull(c.Email,'') as Email
			  ,isnull(a.isLinkApp,0) as isLinkApp
	  FROM [MAS_Apartments] a 
		 join UserInfo u on a.UserLogin = u.loginName
		 join MAS_Apartment_Member ma on a.ApartmentId = ma.ApartmentId and (u.CustId = ma.CustId or ma.isNotification = 1)
		 JOIN MAS_Customers c ON ma.CustId = c.CustId 
		 join MAS_Rooms r on a.RoomCode = r.RoomCode
		 JOIN MAS_Buildings b On r.BuildingCd = b.BuildingCd 
		 left join UserInfo ua on u.CustId = ua.custId and ua.userType = 2
	  WHERE (a.ProjectCd = @projectCd
		and (@buildingCd = '' or b.BuildingCd = @buildingCd)
		and (@apartments = '' or a.ApartmentId in (select part from dbo.SplitString(@apartments, ',')))
		) 
		or a.ApartmentId = 7414

		

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Apartment_User_ByPush ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Apartment', 'GET', @SessionID, @AddlInfo
	end catch