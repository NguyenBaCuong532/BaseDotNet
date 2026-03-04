


CREATE procedure [dbo].[sp_Crm_Opportunity_Page]
	@UserId		nvarchar(450), 
	@clientId	nvarchar(30) = null,
	@ProjectCd	nvarchar(200),	
	@Status int,
	@Filter nvarchar(50),
	@gridWidth			int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out
	,@gridKey			nvarchar(200) out
as
	begin try 
		declare @ToDt datetime
		declare @webId nvarchar(50) 
		declare @tbCats TABLE 
		(
			categoryCd [nvarchar](50) not null INDEX IX1_category NONCLUSTERED
		)
		declare @tbUsers TABLE 
		(
			userId [nvarchar](100) not null INDEX IX2_user NONCLUSTERED
		)
		INSERT INTO @tbCats
		select u.categoryCd from [MAS_Category_User] u 
			where u.UserId = @UserId and u.webId = @webId and u.isAll = 0 
			and not exists(select CategoryCd from @tbCats where categoryCd = u.CategoryCd)
		INSERT INTO @tbCats
		select n.categoryCd from [MAS_Category_User] u join MAS_Category n on n.base_type = u.base_type 
			where u.UserId = @UserId and u.webId = @webId and u.isAll = 1
			and not exists(select CategoryCd from @tbCats where categoryCd = n.CategoryCd)
		
		

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@ProjectCd				= isnull(@ProjectCd,'')
		set		@filter					= isnull(@filter,'')
		set		@Status					= isnull(@Status,-1)

		if		@PageSize	<= 0		set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		
		
		select	@Total					= count(a.id)
			from CRM_Opportunity a 
			where exists(select categoryCd from @tbCats c where categoryCd = a.projectCd and (@ProjectCd = '' or c.categoryCd = @projectCd))
				and (@Status = -1 or a.opp_st = @Status)
					and (exists(select * from @tbUsers where userId = a.create_by) or exists(select userid from CRM_Opportunity_Assign s where opp_Id = a.id and s.userId = @UserId))
					and (a.Phone like @filter + '%' or a.Email like @filter + '%' or a.FullName like @filter + '%')
					

			set	@TotalFiltered = @Total

			if @Offset = 0
			begin
				SELECT * FROM [dbo].[fn_config_list_gets] ('view_Crm_Opportunity_Page', @gridWidth) 
				ORDER BY [ordinal]
			
				
				SELECT -1 as [statusId]
					  ,N'Tất cả' as [statusName]
					  ,isnull(aa.id_count,0) as statusCount
					  ,null [color]
				FROM (select count(id) as id_count 
						from [CRM_Opportunity] a
						where exists(select categoryCd from @tbCats c where categoryCd = a.projectCd and (@ProjectCd = '' or c.categoryCd = @projectCd))
							and (exists(select * from @tbUsers where userId = a.create_by) or exists(select userid from CRM_Opportunity_Assign s where opp_Id = a.id and s.userId = @UserId))
						) aa
				union all
				SELECT [statusId]
					  ,[statusName]
					  ,isnull(aa.id_count,0) as statusCount
					  ,[color]
				  FROM [CRM_Status] st
					left join (select count(id) as id_count, opp_st 
						from [CRM_Opportunity] a
						where exists(select categoryCd from @tbCats c where categoryCd = a.projectCd and (@ProjectCd = '' or c.categoryCd = @projectCd))
							and (exists(select * from @tbUsers where userId = a.create_by) or exists(select userid from CRM_Opportunity_Assign s where opp_Id = a.id and s.userId = @UserId))
						group by opp_st) aa on st.statusId = aa.opp_st
				  WHERE [statusKey] = 'Opportunity'
				  ORDER BY [statusId]
			
			end
	
		  --1
		   SELECT  a.[id]
				  ,a.[opp_cd]
				  ,a.[projectCd]
				  ,a.[fullName]
				  ,case when (a.create_by = @UserId or exists(select userid from CRM_Opportunity_Assign s where opp_Id = a.id and s.userId = @UserId)) 
						then a.Phone else left(a.Phone,3) + '*****' + right(a.Phone,2) end as Phone 
				  ,a.[email]
				  ,a.[address]
				  ,bd.objName as [birthday]
				  ,gt.objName as [sexname]
				  ,a.need_finacial
				  ,neo.objName as need_offer
				  ,nep.objName as need_prod
				  ,sou.objName as [source]
				  ,pot.objName as potenial_level_name
				  ,a.[opp_st]
				  ,a.[opp_lst]
				  ,a.[create_by]
				  ,a.[create_dt]
				  ,b.projectName
			  FROM [dbo].[CRM_Opportunity] a
				left join MAS_Projects b on a.projectCd = b.projectCd 
				left join [dbo].[fn_config_data_gets] ('opportunity_birthday') bd on bd.objValue = a.[birthday]
				left join [dbo].[fn_config_data_gets] ('cust_sex') gt on gt.objValue = a.sex
				left join [dbo].[fn_config_data_gets] ('opportunity_need_offer') neo on neo.objValue1 = a.need_offer
				left join [dbo].[fn_config_data_gets] ('opportunity_need_prod') nep on nep.objValue = a.need_prod
				left join [dbo].[fn_config_data_gets] ('opportunity_need_prod') sou on sou.objValue = a.[source]
				left join [dbo].[fn_config_data_gets] ('opportunity_need_prod') pot on pot.objValue = a.[potenial_level]
				where exists(select categoryCd from @tbCats c where categoryCd = a.projectCd and (@ProjectCd = '' or c.categoryCd = @projectCd))
					and (@Status = -1 or a.opp_st = @Status)
					and (exists(select * from @tbUsers where userId = a.create_by) or exists(select userid from CRM_Opportunity_Assign s where opp_Id = a.id and s.userId = @UserId))
					and (a.Phone like @filter + '%' or a.Email like @filter + '%' or a.FullName like @filter + '%')
					
		ORDER BY a.[create_dt] DESC
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
		set @ErrorMsg					= 'sp_Crm_Opportunity_Page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Opportunity', 'GET', @SessionID, @AddlInfo
	end catch