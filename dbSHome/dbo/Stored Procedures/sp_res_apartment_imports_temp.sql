CREATE procedure [dbo].[sp_res_apartment_imports_temp]
	@userId			nvarchar(50) = null	

as
	begin TRY
		-- Data
		SELECT DISTINCT(projectCd),projectName FROM dbo.MAS_Projects 
		ORDER BY projectCd

		SELECT ProjectCd,BuildingCd,ProjectName,BuildingName 
		FROM dbo.MAS_Buildings 
		ORDER BY ProjectCd,BuildingCd

		SELECT ef.ProjectCd,ef.buildingCd as BuildCd,FloorName,FloorNumber,p.ProjectName,BuildingName
		FROM dbo.MAS_Elevator_Floor ef
		JOIN dbo.MAS_Projects p ON ef.ProjectCd = p.projectCd
		JOIN dbo.MAS_Buildings b ON ef.buildingCd = b.BuildingCd
		--WHERE ef.ProjectCd = 04 AND ef.BuildCd = 'A'
		ORDER BY p.ProjectCd,ef.buildingCd,ef.FloorNumber


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_apartment_imports_temp ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' @user: ' + @userId 

		exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'apartment', 'GET', @SessionID, @AddlInfo
	end CATCH