

CREATE procedure [dbo].[sp_Hom_Building_List]
	@UserId	nvarchar(40) = null,
	@ProjectCd	nvarchar(40)
as
	begin try
		--1 
		SELECT b.ProjectCd
			  ,b.ProjectName
			  ,b.[BuildingCd]
			  ,b.BuildingName
	  FROM MAS_Buildings b 
	  WHERE ProjectCd like @ProjectCd +'%'
		ORDER BY BuildingCd

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Building_List ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'BuildFloor', 'GET', @SessionID, @AddlInfo
	end catch