

CREATE procedure [dbo].[sp_Crm_Apartment_GetListChatByUserId]
	@UserId nvarchar(450)=null,
	@ExchangeId bigint
as
	begin try		
		select ExchangeDetailId,
			   ExchangeId,
			   Content,
			   Type,
			   FileName,
			   FileSize,
			   Icon,
			   (case when CreatedBy = @UserId then 1 else 0 end) as IsMyChat,
			   Created,
			   LinkFile,
			   isnull(dbo.fn_GetNameByUserId(CreatedBy),'No name') as CreatedBy
		from CRM_Apartment_HandOver_Exchange_Detail
		where ExchangeId  = @ExchangeId
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_GetListChatByUserId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CRM_Apartment_HandOver_WorkStatus', 'GET', @SessionID, @AddlInfo
	end catch