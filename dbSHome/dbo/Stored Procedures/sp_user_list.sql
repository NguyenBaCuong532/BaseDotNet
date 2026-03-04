CREATE procedure [dbo].[sp_user_list]
    @userId		nvarchar(450) = null
   ,@userIds	nvarchar(max) = null
   ,@filter		nvarchar(100) = null

as
	begin try
		
			--
			SELECT
          CONVERT(NVARCHAR(50), u.userId) AS value
				  ,u.fullName + '('+u.loginName+')' AS name
			into #users
			FROM dbo.Users u
			where exists(select 1 from dbo.SplitString(@userIds,',') where part = u.userId)

			insert into #users
			SELECT
          top 50 CONVERT(NVARCHAR(50), u.userId) AS value
				  ,u.fullName + '('+u.loginName+')' AS name
			FROM dbo.Users u
			where
          not exists(select 1 from dbo.SplitString(@userIds,',') where part = u.userId)
          and (u.loginName like '%'+@filter+'%' or u.fullName like '%'+@filter+'%')

			select * from #users

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_hrm_user_company_list ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'org', 'GET', @SessionID, @AddlInfo
	end catch