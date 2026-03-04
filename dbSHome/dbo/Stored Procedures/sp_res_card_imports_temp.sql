CREATE procedure [dbo].[sp_res_card_imports_temp]
	@userId			nvarchar(50) = null	

as
	begin TRY
		
		-- Data
		SELECT DISTINCT projectCd AS value
			  ,projectName AS name
		FROM dbo.MAS_Projects p
		WHERE exists(SELECT projectCd
							FROM UserProject where userId = @userId and projectCd = p.projectCd)
		ORDER BY projectCd

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_cardBase_imports_temp ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' @user: ' + @userId 

		exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'cardBase', 'GET', @SessionID, @AddlInfo
	end CATCH