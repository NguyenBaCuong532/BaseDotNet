








CREATE procedure [dbo].[sp_Hom_App_Apartment_Page]
	@UserId nvarchar(450)

as
	begin try
	
		--1 list
		SELECT a.[ApartmentId]
			  ,a.[RoomCode]
			  ,c.FullName
			  ,c.AvatarUrl
			  ,r.[Floor]
			  ,m.memberUserId [UserId]
			  ,a.[UserLogin]
			  ,a.[BuildingCd]
			  ,a.[FamilyImageUrl]
			  ,b.ProjectName
			  ,c.Phone
			  ,c.Email
			  ,a.IsReceived
			  ,convert(nvarchar(10),a.ReceiveDt,103) as ReceiveDate
			  ,a.IsRent 
			  ,m.main_st as isMain 
			  ,a.projectCd
	  FROM [MAS_Apartments] a 
		join MAS_Apartment_Member m on a.ApartmentId = m.ApartmentId 
		join MAS_Rooms r on r.RoomCode = a.RoomCode
		JOIN MAS_Projects b On a.projectCd = b.projectCd 
		JOIN MAS_Customers c ON m.CustId = c.CustId 
	  WHERE m.memberUserId = @UserId
		and m.member_st = 1
		and a.IsReceived = 1

		

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Apartment_Page_Home' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'SalerMonthly', 'GET', @SessionID, @AddlInfo
	end catch