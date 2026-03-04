CREATE procedure [dbo].[sp_Crm_Loyal_Fields]
	@userId nvarchar(450),
	@custId nvarchar(50)
as
	begin try
		declare @disable bit = 1
		declare @resident nvarchar(200)

		if exists(select custId from CRM_Customer where custId = @custId)
			set @disable = 0

		if exists(select custId from MAS_Customers where custId = @custId)
			begin
				
				--0
				select custId 
					  ,Phone 
					  ,Email 
					  ,FullName 
					  ,AvatarUrl
				from MAS_Customers 
					where custId = @custId
				
				--1
				SELECT *
				FROM dbo.fn_get_field_group ('common_group') 
			   order by intOrder
				--2
				SELECT a.id
					  ,table_name
					  ,field_name
					  ,view_type
					  ,data_type
					  ,ordinal
					  ,columnLabel
					  ,1 as group_cd
					   ,case data_type when 'nvarchar' then convert(nvarchar(350), case field_name 
							when 'fullName' then b.FullName
							when 'phone' then b.Phone
							when 'email' then b.Email
							when 'address' then STUFF((
									  SELECT ',' +  a.RoomCode + ' - '+ mb.ProjectName
									  FROM MAS_Apartments a 
										join MAS_Apartment_Member m on a.ApartmentId = m.ApartmentId
										join MAS_Rooms r on a.RoomCode = r.RoomCode 
										join MAS_Buildings mb on r.BuildingCd = mb.BuildingCd 
										WHERE m.CustId = b.CustId 
									  FOR XML PATH('')), 1, 1, '') + isnull(b.[Address],'')
							when 'pass_No' then b.Pass_No
							when 'pass_Plc' then b.Pass_Plc
							when 'avatarUrl' then b.AvatarUrl
							when 'countryCd' then b.CountryCd
							when 'provinceCd' then b.ProvinceCd
							when 'note' then c.note
							when 'categoryCd' then c.categoryCd
							when 'custId' then b.CustId
							when 'avatarUrl' then b.AvatarUrl
						  end
						  ) 
					  when 'datetime' then convert(nvarchar(10), case field_name 
						  when 'pass_Dt' then b.Pass_Dt
						  when 'birthday' then b.Birthday
						  end,103)
				     when 'int' then convert(nvarchar(10), case field_name 
						  when 'group_id' then c.group_id
						  end)
					  else convert(nvarchar(50), case field_name 
						  when 'isSex' then b.IsSex 
						  when 'group_id' then c.group_id 
						  when 'isForeign' then case when isnull(b.CountryCd,'VN') <> 'VN' then 1 else 0 end 
						  when 'base_type' then c.base_type
						    end)
						end as columnValue
					  ,columnClass
					  ,columnType
					  ,columnObject
					  ,isSpecial
					  ,isRequire
					  ,case when @disable =1 then 1 else isDisable end as isDisable
					  ,isVisiable
					  ,[IsEmpty]
					  ,isnull(a.columnTooltip,[columnLabel]) as columnTooltip
				  FROM (select * from sys_config_form
					where table_name = 'MAS_Customers' 
						and (isVisiable = 1 or isRequire =1)) a
					,MAS_Customers b
						left join CRM_Customer c on b.CustId = c.CustId 
				  where (b.custId = @custId)
				  order by ordinal

			end
		else
			begin
				select convert(nvarchar(50),NEWID()) custId 
				
				--1
				SELECT *
				FROM dbo.fn_get_field_group ('common_group') 
			   order by intOrder
				--2
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
					where table_name = 'MAS_Customers' 
						and (isVisiable = 1 or isRequire =1)) a
				 order by ordinal
			
		end
		
		  select sum(isnull(a.OrderAmount,0)) as sumOrderAmt
				,sum(isnull(case when a.TranType = 'voucher' then a.Point else 0 end,0)) as sumVoucher
				,sum(isnull(a.CreditPoint,0)) as sumCreditPoint
				,sum(isnull(case when a.TranType = 'smember' then a.Point else 0 end,0)) as sumDebitPoint
				,sum(case when a.PointTranId is not null then 1 else 0 end) as countTrans
				,p.PointCd
				,p.PointType 
				,p.CurrPoint as currentPoint
				,p.LastDt as lastDate
				,case when @disable = 0 then 'Silver' else 'Gold' end as [priority]
			from MAS_Points p 
				left join WAL_PointOrder a on p.PointCd = a.PointCd
			where p.CustId = @custId
			group by p.PointCd
					,p.PointType 
					,p.CurrPoint 
					,p.LastDt 

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Get_Loyal_Info ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Get_Loyal_Info', 'GET', @SessionID, @AddlInfo
	end catch