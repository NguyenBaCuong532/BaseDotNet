

CREATE   procedure [dbo].[sp_res_elevator_device_import_temp]
	@UserId			UNIQUEIDENTIFIER = NULL,
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
	begin TRY

		-- Data
		SELECT DISTINCT projectCd AS value
			  ,projectName AS name
		FROM dbo.MAS_Projects p
		WHERE exists(select 1 from UserProject x 
			where x.userId = @UserId and x.projectCd = p.projectCd)
		ORDER BY projectCd

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_elevator_device_imports_temp ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' @user: ' + ISNULL(CAST(@UserId AS NVARCHAR(50)), '') 

		exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'elevatorDevice', 'GET', @SessionID, @AddlInfo
	end CATCH