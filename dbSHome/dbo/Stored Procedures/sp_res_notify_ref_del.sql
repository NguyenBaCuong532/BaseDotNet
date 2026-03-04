







CREATE procedure [dbo].[sp_res_notify_ref_del]
	@userId		nvarchar(450),
	@source_ref	uniqueidentifier	
	
as
begin
	declare @valid bit = 0
	declare @messages nvarchar(300) = N'Có lỗi xảy ra'
	begin try
	if exists(select 1 from NotifyInbox i
				JOIN NotifyRef r ON i.source_ref = r.source_ref
				WHERE r.source_ref = @source_ref)
	begin
		set @valid = 0
		set @messages = N'Loại thông báo đã được sử dụng!'
		goto FINAL
	end
	if not exists(select 1 from NotifyRef WHERE source_ref = @source_ref)
	begin
		set @valid = 0
		set @messages = N'Không tìm thấy thông tin!'
		goto FINAL
	end

	if exists(select 1 from NotifyRef WHERE source_ref = @source_ref and ref_st >= 1)
	begin
		set @valid = 0
		set @messages = N'Loại thông báo đang ở trạng thái hoạt động không thể xóa!'
		goto FINAL
	end
	--delete
	begin
		delete from NotifyRef WHERE source_ref = @source_ref
		set @valid = 1
		set @messages = N'Xóa loại thông báo thành công!'
	end
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_notify_ref_del' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'notify_ref', 'DEL', @SessionID, @AddlInfo
	end catch

	FINAL:
	select @valid as valid
		  ,@messages as [messages]

end