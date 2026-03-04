
CREATE procedure [dbo].[sp_res_notify_push_del]
	@UserId nvarchar(450),
	@Id bigint
as
	begin try	
		declare @valid bit = 1
		declare @messages nvarchar(200)
		if not exists (select id from NotifySent where id = @Id and (sms_st = 2 or email_st = 2))
			DELETE FROM [dbo].NotifySent
			  WHERE id = @Id
		else
			begin
				set @valid = 0
				set @messages = N'Đã gửi thông tin cho khách hàng, không thể xóa'
			end

		select @valid as valid
		      ,@messages as [messages]

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_notify_push_del ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@User ' + @UserId 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'NotificationLog', 'Insert', @SessionID, @AddlInfo
	end catch