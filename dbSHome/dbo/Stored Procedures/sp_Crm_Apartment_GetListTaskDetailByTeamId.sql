

CREATE procedure [dbo].[sp_Crm_Apartment_GetListTaskDetailByTeamId]
	@UserId nvarchar(450)=null,
	@TeamId int,
	@HandOverDetailId bigint
as
	begin try		
		 declare @table Table(
				DangChoCount int,
				DangLamCount int,
				HoanThanhCount int)
		insert into @table (DangChoCount,DangLamCount,HoanThanhCount) 
		values ((select count(ExchangeId) from CRM_Apartment_HandOver_Exchange where TeamType = @TeamId and HandOverDetailId = @HandOverDetailId and WorkStatusId = 1),
			     (select count(ExchangeId) from CRM_Apartment_HandOver_Exchange where TeamType = @TeamId and HandOverDetailId = @HandOverDetailId and WorkStatusId = 2),
				 (select count(ExchangeId) from CRM_Apartment_HandOver_Exchange where TeamType = @TeamId and HandOverDetailId = @HandOverDetailId and WorkStatusId = 3))
	    select * from @table
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_GetListTaskDetailByTeamId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CRM_Apartment_HandOver_Detail', 'GET', @SessionID, @AddlInfo
	end catch