CREATE procedure [dbo].[sp_res_apartment_user_byPush]
	@UserId UNIQUEIDENTIFIER = NULL,
	@AcceptLanguage VARCHAR(20) = 'vi-VN',
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
			  ,ma.memberUserId as userId 
			  ,c.CustId
			  ,left(isnull(c.Phone,''),20) as Phone
			  ,isnull(c.Email,'') as Email
			  ,isnull(a.isLinkApp,0) as isLinkApp
	  FROM [MAS_Apartments] a 
		 join UserInfo u on a.UserLogin = u.loginName
		 join MAS_Apartment_Member ma on a.ApartmentId = ma.ApartmentId and (u.CustId = ma.CustId or ma.isNotification = 1)
		 JOIN MAS_Customers c ON ma.CustId = c.CustId 
		 LEFT JOIN MAS_Buildings b On a.buildingOid = b.oid 
		 left join UserInfo ua on u.CustId = ua.custId and ua.userType = 2
	  WHERE (a.ProjectCd = @projectCd
		and (@buildingCd = 'all' or b.BuildingCd = @buildingCd)
		and (@apartments = '' or a.ApartmentId in (select part from dbo.SplitString(@apartments, ',')))
		) 
		--or a.ApartmentId = 7414

		

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_apartment_user_byPush ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Apartment', 'GET', @SessionID, @AddlInfo
	end catch