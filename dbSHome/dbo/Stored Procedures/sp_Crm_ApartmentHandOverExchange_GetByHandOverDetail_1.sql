

CREATE procedure [dbo].[sp_Crm_ApartmentHandOverExchange_GetByHandOverDetail]
	@UserId nvarchar(450)=null,
	@HandOverDetailId bigint
as
	begin try		
		 select N'Bàn giao căn hộ: ' + RoomCode as Title, HandOverId from CRM_Apartment_HandOver_Detail where HandOverDetailId = @HandOverDetailId

		 select ExchangeId,
				HandOverDetailId,
				Title,
				UserAssign,
				UserAdminAssign,
				a.TeamType,
				a.WorkStatusId,
				b.WorkStatusName as WorkStatusName,
				b.Color as WorkStatusColor,
				a.StartDate,
				a.EndDate,
				a.PercentDone as PercentDone,
				DATEDIFF(DAY,isnull(StartDate,getdate()),isnull(EndDate,getdate())) as TotalTime,
				a.CreatedBy
		 from CRM_Apartment_HandOver_Exchange a left join CRM_Apartment_HandOver_WorkStatus b on a.WorkStatusId = b.WorkStatusId
		 where HandOverDetailId = @HandOverDetailId
		 order by a.Created desc

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_ApartmentHandOverExchange_GetByHandOverDetail ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CRM_Apartment_HandOver_CheckList', 'GET', @SessionID, @AddlInfo
	end catch