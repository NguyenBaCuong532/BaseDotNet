





CREATE procedure [dbo].[sp_Crm_Group_fields]
	 @userID	nvarchar(450)
	,@groupId	int
	,@parentId	int = null
	
as 

begin try
	
	select @groupId id
		  ,tableKey = 'CRM_Group' 
		  ,groupKey = 'common_group'
	--2- cac group
	select * from DBO.fn_get_field_group('common_group')
	--2 tung o trong group
	if OBJECT_ID('tempdb..#temp') is not null drop table #temp
	-- data
	if not exists(select 1 from CRM_Group where GroupId = @groupId)
	SELECT [id]
		,[table_name]
		,[field_name]
		,[view_type]
		,[data_type]
		,[ordinal]
		,[columnLabel]
		,1 as [group_cd]
		,[columnDefault] as [columnValue]
		,[columnClass]
		,[columnType]
		,[columnObject]
		,[isSpecial]
		,[isRequire]
		,[isDisable]
		,[isVisiable]
		,[IsEmpty]
		,isnull(a.columnTooltip,[columnLabel]) as columnTooltip
	FROM (select * from sys_config_form
	where table_name = 'CRM_Group' 
		and (isVisiable = 1 or isRequire =1)) a
	order by ordinal
	else
				SELECT a.id
					  ,table_name
					  ,field_name
					  ,view_type
					  ,data_type
					  ,ordinal
					  ,columnLabel
					  ,1 as group_cd
					   ,case data_type when 'nvarchar' then convert(nvarchar(350), case field_name 
							when 'GroupName' then b.GroupName
							when 'GroupMail' then b.GroupMail
							when 'Categories' then STUFF((
									  SELECT ',' +  m.categoryCd
									  FROM MAS_Category_CustGroup m 
										WHERE m.groupId = b.groupId 
									  FOR XML PATH('')), 1, 1, '')
						  end
						  ) 
					  when 'datetime' then convert(nvarchar(10), case field_name 
						  when 'CreatedTime' then b.CreatedTime
						  end,103)
				     when 'int' then convert(nvarchar(10), case field_name 
						  when 'groupId' then b.groupId
						  when 'ParentId' then b.ParentId
						  end)
					  else convert(nvarchar(50), case field_name 
						  when 'IsActive' then b.IsActive 
						    end)
						end as columnValue
					  ,columnClass
					  ,columnType
					  ,columnObject
					  ,isSpecial
					  ,isRequire
					  ,isDisable
					  ,isVisiable
					  ,[IsEmpty]
					  ,isnull(a.columnTooltip,[columnLabel]) as columnTooltip
				  FROM (select * from sys_config_form
					where table_name = 'CRM_Group' 
						and (isVisiable = 1 or isRequire =1)) a
					,CRM_Group b						
				  where (b.GroupId = @GroupId)
				  order by ordinal

end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= '[sp_Crm_Group_fields] ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@groupId ' 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'group', 'GET', @SessionID, @AddlInfo
	end catch