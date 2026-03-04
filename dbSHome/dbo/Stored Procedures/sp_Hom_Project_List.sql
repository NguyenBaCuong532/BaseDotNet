
CREATE procedure [dbo].[sp_Hom_Project_List]
	@userId nvarchar(450)
as
	begin try		
		select [ProjectCd]
			  ,[ProjectName]
			  ,[Address]
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

		set @AddlInfo					= '@NewsId ' + @userId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Projects', 'GET', @SessionID, @AddlInfo
	end catch