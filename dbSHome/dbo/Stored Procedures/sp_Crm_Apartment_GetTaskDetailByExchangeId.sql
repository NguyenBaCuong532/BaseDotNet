

CREATE procedure [dbo].[sp_Crm_Apartment_GetTaskDetailByExchangeId]
	@UserId nvarchar(450)=null,
	@ExchangeId bigint
as
	begin try		
		 select HandOverDetailId,
				dbo.fn_GetNameByUserId(CreatedBy) as CreatedBy,
				Created,
				Title,
				Note,
				TeamType,
				PercentDone as PercentDone,
				isnull(TotalTime,DATEDIFF(DAY,isnull(StartDate,getdate()),isnull(EndDate,getdate()))) as TotalTime,
				StartDate as StartTime,
				EndDate as EndTime
		 from CRM_Apartment_HandOver_Exchange
		 where ExchangeId = @ExchangeId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_GetTaskDetailByExchangeId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CRM_Apartment_HandOver_Detail', 'GET', @SessionID, @AddlInfo
	end catch