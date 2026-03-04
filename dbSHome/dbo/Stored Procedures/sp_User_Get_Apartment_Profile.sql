





CREATE procedure [dbo].[sp_User_Get_Apartment_Profile]
	@userId nvarchar(450)
as
	begin try	
	
	
	select a.RoomCode
		  ,c.ProjectCd
		  ,c.ProjectName
		  ,a.ApartmentId
	From MAS_Apartments a 
		inner join MAS_Rooms b on a.RoomCode = b.RoomCode 
		inner join MAS_Buildings c on b.BuildingCd = c.BuildingCd
		where exists(select ApartmentId from MAS_Apartments m 
					inner join UserInfo u on m.UserLogin = u.loginName
					where u.UserId = @userId and m.ApartmentId = a.ApartmentId)


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_User_Get_Apartment_Profile ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'UserApartmentProfile', 'GET', @SessionID, @AddlInfo
	end catch