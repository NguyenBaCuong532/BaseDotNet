

CREATE procedure [dbo].[sp_Crm_Apartment_TaskDetailItem_List]
	@UserId nvarchar(450)=null,
	@TeamType int,
	@WorkStatus int = 1,
	@HandOverDetailId bigint
as
	begin try	
		 
		 select dbo.fn_GetNameByUserId(CreatedBy) as CreatedBy,
				Created,
				Title,
				Note,
				ExchangeId,
				PercentDone as PercentDone
		 from CRM_Apartment_HandOver_Exchange
		 where HandOverDetailId = @HandOverDetailId and TeamType = @TeamType and WorkStatusId = @WorkStatus

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_TaskDetailItem_List ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CRM_Apartment_HandOver_Detail', 'GET', @SessionID, @AddlInfo
	end catch