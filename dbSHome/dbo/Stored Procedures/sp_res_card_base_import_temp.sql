CREATE procedure [dbo].[sp_res_card_base_import_temp]
	@userId			nvarchar(50) = null	
  , @project_code NVARCHAR(50) = NULL

as
	begin TRY

		-- Data
		SELECT DISTINCT projectCd AS value
			  ,projectName AS name
		FROM dbo.MAS_Projects p
		WHERE exists(select 1 from UserProject x 
			where x.userId = @userId and x.projectCd = p.projectCd)
		ORDER BY projectCd

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_card_base_import_temp ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' @user: ' + @userId 

		exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'cardBase', 'GET', @SessionID, @AddlInfo
	end CATCH