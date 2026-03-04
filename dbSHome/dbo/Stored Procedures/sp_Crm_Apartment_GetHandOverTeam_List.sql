

create procedure [dbo].[sp_Crm_Apartment_GetHandOverTeam_List]
	@UserId nvarchar(450)=null,
	@Type int
as
	begin try		
		 select * from CRM_Apartment_HandOver_Team where Type = @Type
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_GetHandOverTeam_List ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CRM_Apartment_HandOver_Team', 'GET', @SessionID, @AddlInfo
	end catch