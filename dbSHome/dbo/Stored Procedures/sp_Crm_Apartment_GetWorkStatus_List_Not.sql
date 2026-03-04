

CREATE procedure [dbo].[sp_Crm_Apartment_GetWorkStatus_List_Not]
	@UserId nvarchar(450)=null,
	@WorkStatusId int
as
	begin try		
		select *
		from CRM_Apartment_HandOver_WorkStatus
		where WorkStatusId not in (4,@WorkStatusId)
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_GetWorkStatus_List_Not ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CRM_Apartment_HandOver_WorkStatus', 'GET', @SessionID, @AddlInfo
	end catch