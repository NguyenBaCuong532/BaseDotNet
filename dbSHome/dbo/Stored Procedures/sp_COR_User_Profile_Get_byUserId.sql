


CREATE procedure [dbo].[sp_COR_User_Profile_Get_byUserId]
	 @userId nvarchar(450)
	,@loginName nvarchar(50)
as
	begin try	
	--1
	if @loginName is not null 
		set @userId = (SELECT top 1 [userId]
		  FROM UserInfo a			
		where a.loginName = @loginName)
		
		--1
		SELECT a.[reg_userId]
			  ,a.[userId]
			  ,[custId]
			  ,a.[cif_no]
			  ,[referralCd] --= case when @saler_st = 1 then a.[referralCd] else '' end
			  ,a.[avatarUrl] as avatarUrl
			  ,a.[loginName]
			  ,a.[loginType]
			  ,a.[LoginId]
			  ,a.[nickName]
			  ,a.[fullName]
			  ,a.[cntry_Reg]
			  ,a.[phoneF]
			  ,a.[phone]
			  ,a.[email]
			  ,case [sex] when 1 then N'Nam' when 0 then N'Nữ' else '' end [sex]
			  ,convert(nvarchar,[birthday],103) [birthday]
			  ,idcard_type 
			  ,'**** **** '+ RIGHT([idcard_No],4) [idcard_No]
			  ,convert(nvarchar,[idcard_Issue_Dt],103) [idcard_Issue_Dt]
			  ,convert(nvarchar,[idcard_expire_dt],103) [idcard_expire_dt]
			  ,[idcard_Issue_Plc]
			  ,origin_add as	[res_Add]
			  ,[res_City]
			  ,[res_Cntry]
			  ,[trad_Add]
			  ,[bank_code]
			  ,[bank_Acc_No]
			  ,[bank_Acc_Name]
			  ,[bank_Branch]
			  ,[email_Verified]
			  ,[idcard_Verified]	= isnull([idcard_Verified],0)
			  ,[agreed_St]
			  ,[agreed_Dt]
			  ,convert(nvarchar,[created_Dt],103) [created_Dt]
			  ,[last_St]
			  ,convert(nvarchar,[last_Dt],103) [last_Dt]
			  ,case when a.[cif_no] is null then 0 else 1 end as core_linked
			  ,fb_linked
			  ,fb_name
			  ,fb_id
			  ,fb_token
			  ,case when invited_by is null then 0 else 1 end as invited_st
			  ,tax_code
			  ,referral_by = case when exists(select 1 from UserInfo r where r.referralCd = a.invited_by) then a.invited_by else null end
			  ,verifyType
		  FROM UserInfo a
		where a.userId = @userId

		--2
		select 0 as cur_bal_point
			  ,datediff(second,{d '1970-01-01'}, getdate()) as last_dt
			  ,u_rank = 0
			  ,gr_rank  = 0
			  ,u.referralCd 
		from --[ca009mb] a
			--join 
			UserInfo u --on a.userid = u.userId 
		where u.userid = @userId

		--3
		SELECT [id]
			  ,[table_name]
			  ,[field_name]
			  ,[view_type]
			  ,[data_type]
			  ,[ordinal]
			  ,[columnLabel]
			  ,isnull(case [data_type] 
				  when 'nvarchar' then convert(nvarchar(350), 
					case [field_name] 
						when 'avatarUrl' then b.avatarUrl 
						when 'nickName' then b.nickName 
						when 'fullName' then b.fullName 
						when 'phone' then b.phone
					    when 'phoneF' then b.phoneF  
						when 'email' then b.email  
						when 'idcard_No' then b.idcard_No 
						when 'idcard_Issue_Plc' then b.idcard_Issue_Plc 
						when 'res_Add' then b.res_Add 
						when 'res_City' then b.res_City 
						when 'res_Cntry' then b.res_Cntry
						when 'trad_Add' then b.trad_Add 
						when 'bank_Acc_Name' then b.bank_Acc_Name 
						when 'bank_Acc_No' then b.bank_Acc_No  
						when 'bank_Branch' then b.bank_Branch 
						when 'bank_code' then b.bank_code 
						when 'referralCd' then b.referralCd 
						when 'cntry_Reg' then b.cntry_Reg 
						when 'tax_code' then b.tax_code
						when 'loginName' then b.loginName
					end) 
				  when 'datetime' then convert(nvarchar(10),
					case [field_name] 
						when 'birthday' then b.birthday 
						when 'idcard_Issue_Dt' then b.idcard_Issue_Dt 
					end ,103) 
				  else convert(nvarchar(50),
					case [field_name] 
						when 'sex' then b.sex
					    when 'idcard_type' then b.idcard_type  
						when 'idcard_Verified' then isnull(b.idcard_Verified,0)
						when 'agreed_St' then b.agreed_St 
						when 'u_rank' then b.[u_rank]
					end) end,[columnDefault])as columnValue
			  ,[columnClass]
			  ,[columnType]
			  ,[columnObject]
			  ,[isSpecial]
			  ,[isRequire]
			  ,[isDisable]
			  ,[IsVisiable]
			  ,[IsEmpty]
			  ,isnull(a.columnTooltip,a.[columnLabel]) as columnTooltip
		  FROM (select * from sys_config_form a
			where table_name = 'UserInfo' 
				and isvisiable = 1 
				and view_type = 0) a
			,(select * from UserInfo b
		  			where b.UserId = @UserId) b
		  order by ordinal

		--4
		SELECT [id] as metaId
			  ,[doc_type] as docType
			  ,[meta_url] as metaUrl
			  ,[meta_name] as metaName
			  ,[meta_note] as metaNote
			  ,meta_type as metatype
			  ,doc_sub_type
			  ,'' as doc_sub_type_name
		  FROM UserMeta t
			join UserInfo a	on t.reg_userId = a.reg_userId 
			--join [dbo].[fn_ca804pb_gets] ('core_doc_sub_type' + cast(0 as varchar)) c on c.objValue = t.doc_sub_type 
		  where a.userId = @userId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_User_Profile_Get_byUserId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'ResProfile', 'GET', @SessionID, @AddlInfo
	end catch