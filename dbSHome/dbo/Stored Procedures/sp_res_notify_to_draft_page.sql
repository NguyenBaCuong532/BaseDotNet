

CREATE procedure [dbo].[sp_res_notify_to_draft_page]
	 @UserId		UNIQUEIDENTIFIER = NULL
	,@sourceId		uniqueidentifier
	,@Id			uniqueidentifier
	,@to_row		int
	,@to_groups		nvarchar(max)
	,@to_level		int
	,@to_type		int = 0
	
	,@filter			nvarchar(30) = NULL
	,@gridWidth			int			= 0
	,@Offset				int		= 0
	,@PageSize			int			= 10,
	@AcceptLanguage VARCHAR(20) = 'vi-VN'
as
begin
	declare @valid bit = 1
	declare @messages nvarchar(300) = N'Thành công'
	declare @Total		bigint
	declare @GridKey	nvarchar(100) = 'view_notificationApp_page_byNotiId_page'

	begin try	
		
		declare @tbUser table
		(
			[userId] [nvarchar](100) NULL,
			[custId] [nvarchar](100) NULL,
			[phone] [nvarchar](30) NULL,
			[email] [nvarchar](300) NULL,
			[fullName] [nvarchar](300) NULL,
			[room] [nvarchar](30) NULL
		)
			
		INSERT INTO @tbUser
		select u.* 
		from dbo.[fn_get_user_push](CAST(@UserId AS NVARCHAR(450)),@to_type,@to_level,@to_groups) u
			
		select	@Total					= count(*)
			FROM @tbUser a 

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

		select * 
		from @tbUser

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_notify_to_set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@tempId ' 
		set @valid = 0
		set @messages = error_message()

		exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'to_set', 'Set', @SessionID, @AddlInfo
	end catch

	select @valid as valid
	      ,@messages as [messages]

	end