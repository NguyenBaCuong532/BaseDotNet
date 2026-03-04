



CREATE procedure [dbo].[sp_Spk_Project_get]
	@UserId nvarchar(450) ='f0c7892b-971e-45c4-8d6f-68a908f7d71d'
as
	begin try
	
	--1
	select sub_projectCd
		--,name = p.projectName
	from UserProject x 
		join [MAS_Projects] p on x.projectCd = p.projectCd
	where x.userId = @userId
	order by sub_projectCd
	
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Spk_Project_get ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'RoleCategory', 'GET', @SessionID, @AddlInfo
	end catch