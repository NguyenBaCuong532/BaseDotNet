







CREATE procedure [dbo].[sp_Hom_Get_BuildFloor_List_ByManager]
	@ProjectCd	nvarchar(40),
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out
as
	begin try
	
		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@ProjectCd				= isnull(@ProjectCd,'')

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		select	@Total					= count(a.[Floor])
			FROM (SELECT distinct 
			 right('0' + cast([Floor] as varchar(2)),2) as [Floor]
			  ,t2.[BuildingCd]
		  FROM [MAS_Apartments] t1 inner join MAS_Rooms t2 on t1.RoomCode = t2.RoomCode) a INNER JOIN MAS_Buildings b On a.BuildingCd = b.BuildingCd 
			WHERE ProjectCd like @ProjectCd + '%'

		set @TotalFiltered = @Total

		--1 profile
		SELECT b.ProjectCd
		  ,b.ProjectName
		  ,a.[BuildingCd]
		  ,b.BuildingName
		  ,a.[Floor]
		  ,substring(b.ProjectName,10,len(b.projectName)-9) as ProjectShort

	  FROM (SELECT distinct 
			 right('0' + cast([Floor] as varchar(2)),2) as [Floor]
			  ,t2.[BuildingCd]
		  FROM [MAS_Apartments] t1 
			inner join MAS_Rooms t2 on t1.RoomCode = t2.RoomCode) a 
		 INNER JOIN MAS_Buildings b On a.BuildingCd = b.BuildingCd 
	  WHERE ProjectCd like @ProjectCd +'%'
		ORDER BY  a.[Floor]
				  offset @Offset rows	
					fetch next @PageSize rows only

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Get_BuildFloor_List_ByManager ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'BuildFloor', 'GET', @SessionID, @AddlInfo
	end catch