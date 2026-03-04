

CREATE PROCEDURE [dbo].[sp_res_notify_to_page]
	@UserId			UNIQUEIDENTIFIER = NULL,
	@clientId		nvarchar(50) = null,
	@n_id			uniqueidentifier,
	@filter			nvarchar(30),
	@gridWidth			int			= 0,
	@Offset				int			= 0,
	@PageSize			int			= 10,
	@AcceptLanguage VARCHAR(20) = 'vi-VN'
	--@Total				bigint out,
	--@TotalFiltered		bigint OUT,
	--@GridKey		nvarchar(100) out
as
	begin try	
		declare @Total		bigint
		declare @GridKey	nvarchar(100) = 'view_notify_to_page'

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')
		
		if		@PageSize	<= 0		set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		begin
		select	@Total					= count(a.n_id)
			FROM NotifyInbox a 
				join NotifyTo b on a.n_id = b.sourceId 
			WHERE a.n_id = @n_id 

		--root	
		select recordsTotal = @Total
			  ,recordsFiltered = @Total
			  ,gridKey = @GridKey
			  ,valid = 1
		--grid config
		if @Offset = 0
		begin
			select * from [dbo].[fn_config_list_gets_lang] (@GridKey, @gridWidth, @AcceptLanguage) 
					order by [ordinal]
		end

		SELECT b.id 
			  ,b.to_level 
			  ,b.to_groups 
			  ,b.to_type
			  ,b.to_row 
			  ,cd1.par_desc AS to_level_name
			  ,b.createDt
			  ,CONVERT(NVARCHAR(50),b.id) as id
			  ,to_groups_name = case b.to_level when 0 then STUFF((
									  SELECT ',' +  tt.categoryName 
									  FROM MAS_Category tt 
									  WHERE tt.categoryCd in (select s.part from dbo.fn_split_string(b.to_groups,',') s)
									  FOR XML PATH('')), 1, 1, '') 
								when 1 then STUFF((
									  SELECT ',' +  tt.categoryName 
									  FROM MAS_Category tt 
									  WHERE tt.categoryCd in (select s.part from dbo.fn_split_string(b.to_groups,',') s)
									  FOR XML PATH('')), 1, 1, '')
								when 2 then STUFF((
									  SELECT ',' +  tt.GroupName 
									  FROM CRM_Group tt 
									  WHERE tt.GroupId in (select s.part from dbo.fn_split_string(b.to_groups,',') s)
									  FOR XML PATH('')), 1, 1, '')
								when 3 then STUFF((
									  SELECT ',' +  tt.FullName
									  FROM MAS_Customers tt 
									  WHERE tt.CustId in (select s.part from dbo.fn_split_string(b.to_groups,',') s)
									  FOR XML PATH('')), 1, 1, '')
								else b.to_groups end
	  FROM NotifyInbox a 
		join NotifyTo b on a.n_id = b.sourceId
		LEFT JOIN dbo.sys_config_data cd1 ON cd1.key_2 = b.to_level AND cd1.key_1 ='notify_to_level'
		WHERE a.n_id = @n_id 
		ORDER BY NotiDt DESC
		  offset @Offset rows	
			fetch next @PageSize rows only
		end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_notify_to_page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserId ' + cast(@UserId as varchar(50))

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'NotificationSent', 'GET', @SessionID, @AddlInfo
	end catch