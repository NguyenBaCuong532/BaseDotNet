



CREATE procedure [dbo].[sp_config_gridview_del]
	 @UserId	nvarchar(450)
	,@acceptLanguage nvarchar (50) = 'vi-VN'
	,@id		bigint = 0
as
	begin try	
		declare @valid bit =  1
		declare @messages nvarchar(500) = N'Xóa thành công'

		if not exists (select id from sys_config_list where id = @id)
		begin
			set @valid = 0
			set @messages = N'Không tìm thấy thông tin'
			goto FINAL
		end

		delete d from sys_config_list d  where id = @id
		

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_config_gridview_del ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserId	' 
		set @valid = 0
		set @messages = error_message()

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'sys_config_list', 'Del', @SessionID, @AddlInfo
	end catch

	FINAL:
	select @valid as valid, @messages as [messages]