



CREATE procedure [dbo].[sp_config_formview_del]
	@UserId		nvarchar(450),
	@id			bigint,
	@acceptLanguage nvarchar (50) = 'vi-VN'
as
	begin try	
		declare @valid bit =  1
		declare @messages nvarchar(500) = N'Xóa thành công'

		if not exists (select id from sys_config_form where id = @id)
		begin
			set @valid = 0
			set @messages = N'Không tìm thấy thông tin'
			goto FINAL
		end

		delete d from sys_config_form d  where id = @id

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_config_formview_del ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserId	' 

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'ca830pb', 'Del', @SessionID, @AddlInfo

		
	end catch
	FINAL:
		select @valid as valid, @messages as [messages]