




CREATE procedure [dbo].[sp_res_user_project_page]
	@userId			nvarchar(450) = null
   

as
	begin try
			--
			SELECT projectCd
				  ,projectName
				  ,[ProjectCd] as project_cd
				  ,[ProjectName] as project_name
			FROM dbo.MAS_Projects p
			where exists(select 1 from MAS_Apartments a 
				join MAS_Apartment_Member u on a.ApartmentId = u.ApartmentId
				where u.memberUserId = @userId and a.projectCd = p.projectCd
					and u.member_st = 1
				)
			ORDER BY projectCd

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_user_project_byUser ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'org', 'GET', @SessionID, @AddlInfo
	end catch