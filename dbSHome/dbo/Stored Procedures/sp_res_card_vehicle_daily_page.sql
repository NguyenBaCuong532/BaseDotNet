
CREATE procedure [dbo].[sp_res_card_vehicle_daily_page]
	@userId		UNIQUEIDENTIFIER,
	@clientId	nvarchar(50) = null,
	@projectCd	nvarchar(30),
	@filter		nvarchar(60),
	@Statuses			int = null,
	@gridWidth          int = 0,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@acceptLanguage		NVARCHAR(50) = N'vi-VN'
as
	begin try
		declare @Total		bigint
		declare @GridKey	nvarchar(100) = 'view_vehicleCard_daily_page'
		
		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')
		set		@ProjectCd				= isnull(@ProjectCd,'')
		set		@Statuses				= isnull(@Statuses,-1)

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		--1
		select	@Total					= count(a.CardId)
			FROM [MAS_Cards] a 
				join dbo.MAS_Projects p on p.projectCd = a.ProjectCd 
			WHERE a.CardTypeId = 3
				and a.IsDaily = 1
				and a.CardCd like @filter + '%'
				and (@Statuses = -1 or Card_St = @Statuses)
				AND (@ProjectCd ='-1' or a.projectCd = @ProjectCd) 
				and exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = a.ProjectCd)
		
	--root	
	select recordsTotal = @Total
		  ,recordsFiltered = @Total
		  ,gridKey = @GridKey
		  ,valid = 1
    
	--grid config
		if @Offset = 0
		BEGIN
			SELECT *
			FROM [dbo].fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
			ORDER BY [ordinal];
		END;
			
		--2
		SELECT a.[CardCd]
			  ,convert(nvarchar(10),a.[IssueDate],103) [InputDate]
			  ,s.[StatusNameLable] AS  CardStatus
			  ,CASE WHEN a.Card_St = 1 THEN N'<span class="bg-success noti-number ml5">Đang sử dụng</span>'
			  ELSE N'<span class="bg-danger noti-number ml5">Không sử dụng</span>'
			  END AS UsedStatus
			  , a.Card_St AS [Status]
			  ,a.VehicleTypeId
			  ,VehicleTypeName
			  ,a.ProjectCd
			  ,a.IsClose 
			  ,a.CloseDate 
			  ,p.ProjectName
			  ,0 AS CountUsed
			  , NULL AS [expireDate]
			  , 0 AS isLost
			  ,'false' AS IsUsed
			  ,NULL AS LastUsed
			  ,NULL AS lostDate 
			  ,0 AS lostTrackId
			  , NULL as startDate
		  FROM [MAS_Cards] a 
			join MAS_VehicleTypes b on a.VehicleTypeId = b.VehicleTypeId 
			join MAS_CardStatus s on a.Card_St = s.StatusId
			left join MAS_Projects p on a.ProjectCd = p.ProjectCd
			WHERE a.CardTypeId = 3 
				and a.IsDaily = 1
				and a.CardCd like @filter + '%'
				and (@Statuses = -1 or Card_St = @Statuses)
				AND (@ProjectCd ='-1' or a.projectCd = @ProjectCd) 
				and exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = a.ProjectCd)
			ORDER BY [CardCd] 
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
		set @ErrorMsg					= 'sp_res_vehicleCard_daily_get ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'VehicleCard Daily', 'GET', @SessionID, @AddlInfo
	end catch