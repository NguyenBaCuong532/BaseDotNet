








CREATE procedure [dbo].[sp_res_user_feedback_by_manager]
	@UserId	nvarchar(450),
	@clientId	nvarchar(50),
	@projectCd	nvarchar(40) = null,
	@filter nvarchar(100),
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out
as
	begin try
		--declare @appId int
		--set @appId = (select appid from PAR_AppClient where ClientId = @ClientID)
		--declare @webId nvarchar(50) = (select id from [dbAppManager].[dbo].[ClientWebs] where clientId = @clientId or clientIdDev = @clientId)
		--declare @tbCats TABLE 
		--(
		--	categoryCd [nvarchar](50) not null
		--)
		--set		@projectCd				= isnull(@projectCd,'')
		--INSERT INTO @tbCats
		--select distinct u.categoryCd from [dbSHome].[dbo].[MAS_Category_User] u 
		--	where u.UserId = @UserId and u.webId = @webId and u.isAll = 0 
		--	and (@ProjectCd = '' or u.categoryCd = @ProjectCd)
		--	and not exists(select CategoryCd from @tbCats where categoryCd = u.CategoryCd)
		--INSERT INTO @tbCats
		--select distinct n.categoryCd from [dbSHome].[dbo].[MAS_Category_User] u join [dbSHome].[dbo].MAS_Category n on n.base_type = u.base_type 
		--	where u.UserId = @UserId and u.webId = @webId and u.isAll = 1
		--	and (@ProjectCd = '' or n.categoryCd = @ProjectCd)
		--	and not exists(select CategoryCd from @tbCats where categoryCd = n.CategoryCd)

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		select	@Total					= count(a.FeedbackId)
			FROM [MAS_Feedbacks] a 
				inner join UserInfo b on a.UserId = b.UserId 
				INNER JOIN MAS_Customers c ON b.CustId = c.CustId
				inner join [MAS_Apartments] n on a.ApartmentId = n.ApartmentId 
				--join @tbCats t on n.projectCd = t.categoryCd 
				join MAS_Projects p on n.projectCd = p.projectCd 
			WHERE (@filter = '' or n.RoomCode like @filter or c.Phone like '%' + @filter + '%' or c.FullName like '%' + @filter +'%')
				--and exists (SELECT * FROM [dbo].[fn_Exists_CustCategory] (@UserId,null) where CategoryCd = mb.ProjectCd)
		set @TotalFiltered = @Total

	--1 profile
		SELECT p.projectName
			  ,n.[RoomCode]
			  ,c.FullName
			  ,c.AvatarUrl
			  ,f.FeedbackTypeName 
			  ,a.Title 
			  ,left(a.Comment,80) + case when len(a.Comment)>80 then ' ...' else '' end as Comment
			  ,dbo.fn_Get_DateAgo(a.InputDate,getdate()) FeedbackDate
			  ,a.FeedbackId
			  ,a.[Status]
			  ,case a.[Status] when 0 then N'Mới tại' when 1 then N'Đang thực hiện' else N'Hoàn thành' end as StatusName
	  FROM [MAS_Feedbacks] a 
			inner join UserInfo b on a.UserId = b.UserId 
			INNER JOIN MAS_Customers c ON b.CustId = c.CustId
			inner join [MAS_Apartments] n on a.ApartmentId = n.ApartmentId 
			--join @tbCats t on n.projectCd = t.categoryCd 
			join MAS_Projects p on n.projectCd = p.projectCd 
			left join MAS_FeedbackType f on f.FeedbackTypeId = a.FeedbackTypeId 
	  WHERE (@filter = '' or n.RoomCode like @filter or c.Phone like '%' + @filter + '%' or c.FullName like '%' + @filter +'%')
		ORDER BY a.[InputDate] DESC
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
		set @ErrorMsg					= 'sp_User_Get_Feedback_List_ByManager ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'FeedbackList', 'GET', @SessionID, @AddlInfo
	end catch