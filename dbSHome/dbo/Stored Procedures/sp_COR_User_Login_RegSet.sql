








CREATE procedure [dbo].[sp_COR_User_Login_RegSet]
	@reg_id bigint,
	@userId nvarchar(450),
	@code nvarchar(10)
as
	begin try	
		declare @last_st bit
		declare @verifyType int

		SELECT @last_st = last_st
			  ,@verifyType = verifyType
		FROM [dbo].[UserInfo]
		WHERE reg_userId = @reg_id

		UPDATE [dbo].UserInfo
		   SET last_st = 1
			  ,last_Dt = getdate()
			  ,userId = @userId
			  ,verifyOtp = 0
			  ,verifyCode = @code	
			  ,phone_confirmed = case when @verifyType = 0 then 1 else phone_confirmed end
			  ,email_confirmed = case when @verifyType = 1 then 1 else email_confirmed end
			  ,modified_dt = getdate()
		 WHERE reg_userId = @reg_id

		SELECT loginName
			  ,1 as IsCreatePassword
		FROM [dbo].[UserInfo]
		WHERE reg_userId = @reg_id

		select null
		where 0 = 1
		 --select t.[title] as [subject]		
			--	,replace(replace(t.email,'[EMAIL]',a.fullName),'[LOGIN_NAME]',isnull(a.loginName,'')) as content_email 
			--	,t.bodytype as bodytype
			--	,t.actions as [action_list] 
			--	,'new' as [status]
			--	,0 as notiType
			--	,t.external_event as external_event
			--	,'ks-finance' as external_key
			--	,'no-reply@sunshinemail.vn' as send_by
			--	,'KSF Group' as send_name
			--	,'KSFinance' as brand_name
			--FROM [template] t
			--	,UserInfo a
			--where t.tpl_no = 'CRM002' 
			--and a.reg_userId = @reg_id
			--	and userType = 3
			--	and @last_st = 0

			select userId
				  ,phone 
				  ,email 
				  ,avatarUrl as Avatar
				  ,fullName 
				  ,1 as app
		    from [dbo].[UserInfo]
			where reg_userId = @reg_id
				and userType = 3
				and @last_st = 0
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_COR_User_Login_RegSet ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserLogin ' + @userId 

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'UserLogin', 'Update', @SessionID, @AddlInfo
	end catch