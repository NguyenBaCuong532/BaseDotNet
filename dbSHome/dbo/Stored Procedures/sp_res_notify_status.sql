







CREATE procedure [dbo].[sp_res_notify_status]
	@userId nvarchar(200)
as
	begin try	

		select -1 as value, N'Tất cả' as name
		union 
		select 0 as value, N'Nháp' as name
		union 
		select 1 as value, N'Đang gửi' as name
		union 
		select 2 as value, N'Đã gửi' as name
		union
		select 3 as value, N'Không gửi được' as name
		union
		select 4 as value, N'Không áp dụng' as name

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_hrm_notify_status ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@Id ' + @userId

		exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'notify', 'get', @SessionID, @AddlInfo
	end catch