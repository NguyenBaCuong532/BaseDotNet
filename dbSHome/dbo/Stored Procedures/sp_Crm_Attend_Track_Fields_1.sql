

CREATE procedure [dbo].[sp_Crm_Attend_Track_Fields]
	@userId nvarchar(450),
	@track_id nvarchar(100)
as
	begin try
		  select track_id
			from CRM_Attend_Track 
			where track_id = @track_id

		if exists(select track_id from CRM_Attend_Track where track_id = @track_id)
			begin
				
				--1
				SELECT *
					FROM [fn_get_field_group] ('Crm_Attend_Track_group') 
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
							when 'attend_cd' then b.attend_cd
							when 'contactName' then b.contactName
							when 'Phone' then b.Phone
							--when 'phone' then case when (b.create_by = @UserId or exists(select userid from CRM_Opportunity_Assign s where opp_Id = b.id and s.userId = @UserId)) 
							--		then b.Phone else left(b.Phone,3) + '*****' + right(b.Phone,2) end
							when 'email' then b.email
							when 'Note' then b.Note
							when 'child_name' then b.child_name
							when 'ReferralCode' then b.ReferralCode
							when 'qrcode_url' then b.qrcode_url
							when 'source' then b.source
							when 'arrived_id' then b.UserLogin
						  end
						  ) 
					 --when 'decimal' then cast(case [field_name] 
						--  when 'need_finacial' then b.need_finacial
						--	end as nvarchar(100)) 
					  when 'datetime' then convert(nvarchar(10), case field_name 
						  when 'Createdate' then format(b.Createdate,'dd/MM/yyyy HH:mm:ss')
						  when 'arrived_dt' then format(b.arrived_dt,'dd/MM/yyyy HH:mm:ss')
						  when 'child_birthday' then format(b.child_birthday,'dd/MM/yyyy')
						  end, 103)
					  else convert(nvarchar(50), case field_name 
						  when 'track_id' then b.track_id 
						  when 'num_of_attend' then b.num_of_attend 
						  when 'learned_maplebear' then b.learned_maplebear
						  when 'arrived_st' then b.arrived_st
						  --when 'birthday' then b.birthday
						    end)
						end as columnValue
					  ,columnClass
					  ,columnType
					  ,columnObject
					  ,isSpecial
					  ,isRequire
					  ,1 isDisable
					  ,isVisiable
					  ,[IsEmpty]
					  ,isnull(a.columnTooltip,[columnLabel]) as columnTooltip
				  FROM (select a.* from sys_config_form a
					where a.table_name = 'CRM_Attend_Track' 
				  and (isVisiable = 1 or isRequire =1)) a
				  ,(select b.*, c.UserLogin from CRM_Attend_Track b
					left join MAS_Users c on b.arrived_id = c.UserId
						where track_id = @track_id) b
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
		set @ErrorMsg					= 'sp_Crm_Attend_Track_Fields ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Opportunity_Fields', 'GET', @SessionID, @AddlInfo
	end catch