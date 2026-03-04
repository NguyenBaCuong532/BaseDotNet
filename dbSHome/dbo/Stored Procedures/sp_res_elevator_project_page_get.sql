CREATE procedure [dbo].[sp_res_elevator_project_page_get]
	@UserId UNIQUEIDENTIFIER = NULL,
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
	begin try		
		select [ProjectCd]
			  ,[ProjectName]
			  ,[Address]
			  ,[ProjectCd] as project_cd
			  ,[ProjectName] as project_name
			  ,value = projectCd 
			  ,name = projectName 
		from MAS_Projects
		--where IsActive = 1
		Order by projectCd

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Project_List ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserId ' + ISNULL(CAST(@UserId AS NVARCHAR(50)), '')

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Projects', 'GET', @SessionID, @AddlInfo
	end catch