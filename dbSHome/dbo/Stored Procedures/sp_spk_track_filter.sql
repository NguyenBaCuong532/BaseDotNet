CREATE procedure [dbo].[sp_spk_track_filter]
	 @UserId nvarchar(450) 
	,@tableKey nvarchar(200)
  ,@AcceptLanguage nvarchar(200) = 'vi'
as
	begin try
	declare @projectCd nvarchar(50)
		select top 1 @projectCd = projectCd 
		from UserProject x 
		where x.userId = @userId
		order by projectCd
		--1 root
		select id = null
			 ,tableKey = @tableKey
		     ,groupKey = 'common_group_info'
		
		--group
		SELECT *
		FROM [dbo].[fn_get_field_group] ('common_group_info') 
		   order by intOrder

		--2 file 
		SELECT a.[id]
			  ,[table_name]
			  ,[field_name]
			  ,[view_type]
			  ,[data_type]
			  ,[ordinal]
			  ,[columnLabel]
			  ,[group_cd]
			  ,columnValue		= isnull(l.columnValue, 
								case field_name when 'projectCd' then @projectCd
									when 'startDate' then format(dateadd(day,-1,getdate()),'dd/MM/yyyy')
									when 'endDate' then format(dateadd(day,0,getdate()),'dd/MM/yyyy')
									when 'month' then format(dateadd(day,-1,getdate()),'MM')
									when 'year' then format(dateadd(day,-1,getdate()),'yyyy')
									else a.[columnDefault] end)
			  ,[columnClass]
			  ,[columnType]
			  ,[columnObject]
			  ,[isSpecial]
			  ,[isRequire]
			  ,[isDisable]
			  ,[isVisiable]
			  ,[isEmpty]
			  ,columnTooltip	= isnull(a.columnTooltip,a.[columnLabel])
			  ,columnDisplay
			  ,isIgnore
		  FROM sys_config_form a
			left join sys_config_form_log l on a.id = l.id and l.userId = @userId
			where (isVisiable = 1 or isRequire =1)
				and a.table_name = @tableKey
		  order by ordinal
	
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_spk_track_filter ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'RoleCategory', 'GET', @SessionID, @AddlInfo
	end catch