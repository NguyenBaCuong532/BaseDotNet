









CREATE procedure [dbo].[sp_Hom_App_Apartment_Cart_List]
	@UserId nvarchar(450)

as
	begin try
	
	--1 profile
		SELECT a.[ApartmentId]
			  ,r.[RoomCode]
			  ,c.FullName
			  ,c.AvatarUrl
			  ,r.[Floor]
			  ,u.[UserId]
			  ,a.[UserLogin]
			  ,b.[BuildingCd]
			  ,a.projectCd
			  ,b.ProjectName
			  ,c.Phone
			  ,c.Email
			  ,a.IsReceived
			  ,convert(nvarchar(10),a.ReceiveDt,103) as ReceiveDate
			  ,a.IsRent 
			  --,d.roomCd
			  ,case when a.IsReceived = 1 then 2 else 1 end as handOver_st
			  ,case when a.IsReceived = 1 then N'Đã bàn giao' else N'Đủ điều kiện bàn giao' end as handOver_status
			  ,a.isMain 
	  FROM [MAS_Apartments] a 
			join MAS_Rooms r on r.RoomCode = a.RoomCode
			JOIN MAS_Buildings b On r.BuildingCd = b.BuildingCd 
			--join BLD_Rooms d on r.RoomCode = d.code 
			join UserInfo u on a.UserLogin = u.loginName 
			join  MAS_Customers c ON u.CustId = c.CustId 
	  WHERE exists(select userId from UserInfo t
		where userid = @UserId and t.CustId = u.CustId)

		

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_App_Apartment_Cart_List' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Apartment_Cart', 'GET', @SessionID, @AddlInfo
	end catch