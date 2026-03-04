





CREATE procedure [dbo].[sp_Hom_App_Apartment_Main_Set]
	@userId nvarchar(550),
	@apartmentId	int	
	
as
	begin try	
		
		UPDATE t
			Set main_st = case when t.ApartmentId = @apartmentId then 1 else 0 end
		FROM [dbo].MAS_Apartment_Member t
		join UserInfo u on t.CustId = u.custId
		WHERE t.memberUserId = @userId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_App_Apartment_Main_Set' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ApartmentMain', 'Set', @SessionID, @AddlInfo
	end catch