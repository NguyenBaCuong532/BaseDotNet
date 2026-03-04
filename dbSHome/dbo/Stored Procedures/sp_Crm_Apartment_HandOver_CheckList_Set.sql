create procedure [dbo].[sp_Crm_Apartment_HandOver_CheckList_Set]
	@UserID	nvarchar(450),
	@CheckListId bigint,
	@Chon bit
as
	begin try		
		if exists(select CheckListId from [CRM_Apartment_HandOver_CheckList] where CheckListId = @CheckListId)
			begin
				update [dbo].[CRM_Apartment_HandOver_CheckList]
				set    Chon = @Chon  
				where CheckListId = @CheckListId
			end
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),
				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Apartment_HandOver_CheckList_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_Crm_Apartment_HandOver_CheckList_Set', 'Set', @SessionID, @AddlInfo
	end catch