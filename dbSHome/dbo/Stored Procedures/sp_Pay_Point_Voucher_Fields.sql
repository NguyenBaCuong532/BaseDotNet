


CREATE procedure [dbo].[sp_Pay_Point_Voucher_Fields]
	@userId nvarchar(450),
	@id nvarchar(100),
	@custId nvarchar(50)
as
	begin try

		if exists(select PointTranId from WAL_PointOrder where PointTranId = @id)
			begin
				select PointTranId as id
					  --,issue_st
					  --,thread_id
					  --,custId
				from WAL_PointOrder 
				where PointTranId = @id
				--1
				SELECT objvalue as group_cd
					  ,objname as group_name 
					FROM [dbo].[fn_config_data_gets] ('issue_field_group') 
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
							when 'TransNo' then b.TransNo
							when 'PointCd' then b.PointCd
							when 'fullName' then c.fullName
							when 'phone' then c.phone
							when 'email' then c.email
							when 'address' then c.address
							when 'Ref_No' then b.Ref_No
							when 'ServiceKey' then b.ServiceKey
							when 'OrderInfo' then b.OrderInfo
							when 'PosCd' then b.PosCd
							when 'roomCode' then b.roomCode
							--when 'description' then b.description
							--when 'summary' then b.summary
							--when 'cPAction' then b.cPAction
							--when 'issueLevel' then b.issueLevel
							--when 'causeIssue' then b.causeIssue
							when 'custId' then c.custId
						  end
						  ) 
					  when 'datetime' then convert(nvarchar(10), case field_name 
						  when 'TranDt' then b.TranDt
						  --when 'dueCustDt' then b.dueCustDt
						  --when 'dueDt' then b.dueDt
						  end, 103)
					  else convert(nvarchar(50), case field_name 
						  when 'push_st' then b.push_st 
						  when 'isFinal' then b.isFinal 
						  --when 'issueId' then b.issueId
						  --when 'subStatus' then b.subStatus
						  --when 'priority' then b.priority
						  --when 'serverity' then b.serverity
						  --when 'subType' then b.subType
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
				  FROM (select a.* from sys_config_form a
					where a.table_name = 'WAL_PointOrder' 
				  and (isVisiable = 1 or isRequire =1)) a
				  ,(select b.* from WAL_PointOrder b 						
						where b.PointTranId = @id) b
						join MAS_Customers c on c.CustId = b.PointCd
				  order by ordinal
			--3
			
			end
		else
			begin
				select @id as issueId
				      ,0 as issue_st 
					  ,cast(newid() as nvarchar(150)) as thread_id
					  ,@custId as custId
					--1
				SELECT *
					FROM [dbo].[fn_get_field_group] ('issue_field_group') 
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
					  , case data_type when 'nvarchar' then convert(nvarchar(350), case field_name 
							when 'opp_cd' then ''
							when 'projectCd' then ''
							when 'fullName' then c.fullName
							when 'phone' then c.phone
							when 'email' then c.email
							when 'address' then c.address
							when 'longing' then ''
							when 'offer' then ''
							when 'feedback' then ''
							when 'source' then ''
							when 'solution' then ''
							when 'description' then ''
							when 'custId' then c.custId
						  end
						  ) 
					  when 'datetime' then convert(nvarchar(10), case field_name 
						  when 'startDt' then ''
						  when 'dueDt' then ''
						  end, 103)
					  else convert(nvarchar(50), case field_name 
						  when 'issueType' then ''
						  when 'securityLevel' then '' 
						  when 'issueId' then ''
						  when 'subStatus' then ''
						  when 'priority' then ''
						  when 'serverity' then ''
						  when 'subType' then ''
						    end)
						end as columnValue
					  ,[columnClass]
					  ,[columnType]
					  ,[columnObject]
					  ,[isSpecial]
					  ,[isRequire]
					  ,[isDisable]
					  ,[isVisiable]
					  ,[IsEmpty]
					  ,isnull(a.columnTooltip,[columnLabel]) as columnTooltip
				 FROM sys_config_form a,
					MAS_Customers c
				 where a.table_name = 'WAL_PointOrder'
				  and a.isvisiable = 1
				  and c.CustId = @custId
				 order by ordinal
			--3
			
		end
		
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Issue_Fields ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Issue_Fields', 'GET', @SessionID, @AddlInfo
	end catch