


CREATE procedure [dbo].[sp_res_notify_temp_del]
	@userId nvarchar(450),
	@tempId	uniqueidentifier	
	
as
begin
	declare @valid bit = 1
	declare @messages nvarchar(300) = N'Xóa thông báo thành công'
	begin try

	if exists(select 1 from NotifyTemplate WHERE tempId = @tempId and app_st = 1)
		begin
			set @valid = 0
			set @messages = N'Chức danh đang ở trạng thái áp dụng, không được xóa.'
			goto FINAL
		end
	if not exists(select 1 from NotifyTemplate WHERE tempId = @tempId)
	begin
		set @valid = 0
		set @messages = N'Không tìm thấy mẫu thông báo!'
		goto FINAL
	end	
	else
	begin		

		delete from NotifyTemplate WHERE tempId = @tempId 
	end
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_notify_temp_del' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'NotificationApp', 'DEL', @SessionID, @AddlInfo
	end catch

	FINAL:
		select @valid as valid
				  ,@messages as [messages]

end