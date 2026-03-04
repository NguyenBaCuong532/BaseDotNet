


Create procedure [dbo].[sp_Crm_Loyal_Del]
	 @userId nvarchar(100)
	,@custId nvarchar(100)
as
	begin try	
	if not exists(select 1 from [dbo].[CRM_Customer] 
		 where custId = @custId)
	begin
		select 0 as valid, N'Bạn không có quyền xóa thông tin này!' as messages
	end
	else
	begin
		delete from [dbo].[CRM_Card] 
		 where custId = @custId;

		 delete from [dbo].[CRM_Customer] 
		 where custId = @custId;

		 select  1 as valid, 'success' as messages
	end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		
		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Loyal_Del' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Loyal', 'DEL', @SessionID, @AddlInfo
	end catch