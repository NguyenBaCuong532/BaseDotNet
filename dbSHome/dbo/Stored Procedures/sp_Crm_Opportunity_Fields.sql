
CREATE procedure [dbo].[sp_Crm_Opportunity_Fields]
	@userId nvarchar(450),
	@id nvarchar(100)
as
	begin try

		if exists(select id from CRM_Opportunity where id = @id)
			begin
				select id as opp_id
					  ,opp_st
					  ,thread_id
				from CRM_Opportunity 
				where id = @id
				--1
				SELECT *
					FROM [dbo].[fn_get_field_group] ('opportunity_field_group') 
				   order by intOrder
				--2
				SELECT a.id
					  ,table_name
					  ,field_name
					  ,view_type
					  ,data_type
					  ,ordinal
					  ,columnLabel
					  ,a.group_cd
					   ,case data_type when 'nvarchar' then convert(nvarchar(350), case field_name 
							when 'opp_cd' then b.opp_cd
							when 'projectCd' then b.projectCd
							when 'fullName' then b.fullName
							when 'phone' then case when (b.create_by = @UserId or exists(select userid from CRM_Opportunity_Assign s where opp_Id = b.id and s.userId = @UserId)) 
									then b.Phone else left(b.Phone,3) + '*****' + right(b.Phone,2) end
							when 'email' then b.email
							when 'address' then b.address
							when 'reviews' then b.reviews
							when 'need_offer' then b.need_offer
							when 'need_prod' then b.need_prod
							when 'source' then b.source
						  end
						  ) 
					 when 'decimal' then cast(case [field_name] 
						  when 'need_finacial' then b.need_finacial
							end as nvarchar(100)) 
					  when 'datetime' then convert(nvarchar(10), case field_name 
						  when 'opp_lst' then b.opp_lst
						  end, 103)
					  else convert(nvarchar(50), case field_name 
						  when 'potenial_level' then b.potenial_level 
						  when 'sex' then b.sex 
						  when 'id' then b.id
						  when 'need_loan' then b.need_loan
						  when 'birthday' then b.birthday
						    end)
						end as columnValue
					  ,columnClass
					  ,columnType
					  ,columnObject
					  ,isSpecial
					  ,isRequire
					  ,case when (b.create_by = @UserId or exists(select userid from CRM_Opportunity_Assign s where opp_Id = b.id and s.userId = @UserId)) then isDisable else 1 end isDisable
					  ,isVisiable
					  ,[IsEmpty]
					  ,isnull(a.columnTooltip,[columnLabel]) as columnTooltip
				  FROM (select a.* from sys_config_form a
					where a.table_name = 'CRM_Opportunity' 
				  and (isVisiable = 1 or isRequire =1)) a
				  ,(select b.* from CRM_Opportunity b
						where b.id = @id) b
				  order by ordinal
			--3
			SELECT [assignRole]
				  ,[assignRoleName]
			  FROM [CRM_Assign_Role]
			--4
			SELECT a.[Id]
				  ,a.[opp_Id]
				  ,a.[userId]
				  ,a.[assignRole]
				  ,b.loginName as userName
				  ,1 as Used
				  ,b.fullName 
				  ,b.avatarUrl
				  ,b.phone 
				  ,b.email
			  FROM [CRM_Opportunity_Assign] a
			  join UserInfo b on a.userId = b.userId 
				WHERE a.opp_Id = @id

			end
		else
			begin
				select @id as opp_id
				      ,0 as opp_st 
					  ,cast(newid() as nvarchar(150)) as thread_id
					--1
				SELECT *
					FROM [dbo].[fn_get_field_group] ('opportunity_field_group') 
				   order by intOrder
				--2
				SELECT [id]
					  ,[table_name]
					  ,[field_name]
					  ,[view_type]
					  ,[data_type]
					  ,[ordinal]
					  ,[columnLabel]
					  ,[group_cd]
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
				 FROM sys_config_form a
				 where a.table_name = 'CRM_Opportunity'
				  and a.isvisiable = 1
				 order by ordinal
			--3
			SELECT [assignRole]
				  ,[assignRoleName]
			  FROM CRM_Assign_Role
			--4
			
		
		end
		
		SELECT [id]
			  ,[opp_Id]
			  ,[processId]
			  ,[attachUrl]
			  ,[attachType]
			  ,attachFileName
			  ,1 as used
			  ,[createDt]
		  FROM [dbSHome].[dbo].[CRM_Opportunity_Attach]
		  where opp_Id = @id and processId = 0

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Opportunity_Fields ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Opportunity_Fields', 'GET', @SessionID, @AddlInfo
	end catch