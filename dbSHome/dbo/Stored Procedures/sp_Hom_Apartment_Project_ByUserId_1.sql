






CREATE procedure [dbo].[sp_Hom_Apartment_Project_ByUserId]
	@UserId	nvarchar(450)

as
	begin try
		
	select top 1 a.ApartmentId
			  ,u2.[UserId]
			  ,a.[UserLogin]
			  ,a.[ApartmentId]
			  ,a.[RoomCode]
			  --,d.[BuildingCd]
			  ,a.[FamilyImageUrl]
			  ,p.ProjectName
			  ,a.ProjectCd
			  ,am.CustId
		FROM [MAS_Apartments] a 
			join MAS_Apartment_Member am on a.ApartmentId = am.ApartmentId 
			join UserInfo u2 on am.CustId = u2.custId 
			join MAS_Projects p on a.projectCd = p.projectCd 
		WHERE u2.userId = @UserId 
			and am.member_st = 1
			and a.IsReceived = 1
		order by isnull(am.main_st,0) desc

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Get_Apartment_Project_ByUserId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'HomeProject', 'GET', @SessionID, @AddlInfo
	end catch