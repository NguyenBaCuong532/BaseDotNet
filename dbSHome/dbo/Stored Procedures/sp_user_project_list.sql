



CREATE procedure [dbo].[sp_user_project_list]
	@userId			nvarchar(450) = null
   ,@orgId			uniqueidentifier = '51f67c15-28e1-4a6d-abb0-cb58ce5dc0e0'

as
	begin try
			--
			SELECT DISTINCT projectCd AS value
				  ,projectName AS name
			FROM dbo.MAS_Projects
			ORDER BY projectCd

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_hrm_user_company_list ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'org', 'GET', @SessionID, @AddlInfo
	end catch