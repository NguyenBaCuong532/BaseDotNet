


-- =============================================
-- Author:		duongpx
-- Create date: 11/7/2024 11:42:02 AM 
-- Description:	lấy các trường của cá nhân
-- =============================================
CREATE   procedure [dbo].[sp_app_user_profile_field_get]
	@userId uniqueidentifier,
	@acceptLanguage nvarchar(50) = N'vi-VN',
	@ProfileType int = 0,
	@loginName nvarchar(50) = null

as
	begin try
	--1
	if @loginName is not null
		set @UserId = (select top 1 UserId From UserInfo where loginName = @loginName)

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
			  ,[isVisiable]
			  --,[isEmpty]
			  ,isnull(a.columnTooltip,a.[columnLabel]) as columnTooltip
			  ,a.[columnDisplay]
			  ,a.[isIgnore]
		  FROM fn_config_form_gets('UserInfo', @acceptLanguage) a
			,(select * from UserInfo b
		  			where b.UserId = @UserId) b
		  WHERE a.isvisiable = 1 
				and a.view_type = 0
		  order by a.ordinal

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_user_profile_fields ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' - @userId '

		EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'UserInfo', 'Insert', @SessionID, @AddlInfo
	end catch