


-- =============================================
-- Author:		hoanpv - sp_COR_User_Login_RegNew
-- Create date: 20/09/2024
-- Description:	Đăng ký mới tài khoản app
-- =============================================
CREATE   procedure [dbo].[sp_app_user_login_regnew]
    @userId uniqueidentifier = null,
	@acceptLanguage nvarchar(50) = null,
	@fullName	nvarchar(250),
	@phone		nvarchar(20),
	@email		nvarchar(250),	
	@loginName	nvarchar(50),
	@verifyType	int,
	@referral_by	nvarchar(20)
	--@userType	int

as
begin
	declare @valid bit = 1
	declare @mess nvarchar(100) = N'Đăng ký người dùng thành công'
	begin try	

		declare @phoneF nvarchar(20)
		declare @cntry_Reg nvarchar(20)

		begin
			if substring(@phone,1,1) = '0' and len(@phone) = 10
			begin			
				set @phoneF = '+84'+ substring(@phone,2,9)
			end
			else if len(@phone) = 9
			begin
				set @phoneF = '+84'+ substring(@phone,1,9)
				set @phone = '0' + @phone
			end
		end

		if @verifyType = 0
		begin
			if [dbo].[fn_check_phone_vn](@phone) = 0
			begin
				set @valid = 0
				set @mess = N'Số điện thọai không đúng, phải đăng ký lại'
				exec utl_ErrorLog_Set 1, 'Invalid phone', 'sp_COR_User_Login_Reg', 'UserReg', 'Set', 0, @phone
				goto FINAL
			end
		end
		
		if @verifyType = 1 and [dbo].[fn_check_mail](@email) = 0
		begin
			set @valid = 0
			set @mess = N'Email đăng ký không hợp lệ'
			goto FINAL
		end

		if len(@loginName) < 6
		begin
			set @valid = 0
			set @mess = N'Yêu cầu tên đăng nhập gồm nhiều hơn 6 ký tự. Vui lòng kiểm tra và thử lại!'
			goto FINAL
		end
		
		if @loginName like '% %'
		begin
			set @valid = 0
			set @mess = N'Tên đăng nhập khống chữa khoảng trỗng. Vui lòng kiểm tra và thử lại!'
			goto FINAL
		end
        			
		if exists(SELECT reg_userId FROM UserInfo u  WHERE u.loginName = @phone)
		begin
			set @valid = 0
			set @mess = N'Số điện thoại đã tồn tại. Vui lòng kiểm tra và thử lại!'
			goto FINAL
		end

		if Exists(SELECT reg_userId FROM UserInfo u WHERE u.email = @email)
		begin
			set @valid = 0
			set @mess = N'Địa chỉ email đã tồn tại. Vui lòng kiểm tra và thử lại!'
			goto FINAL
		end

		
		--if  len(@phoneF) > 3 and substring(@phoneF,1,1) = '+'
		--	set @cntry_Reg = substring(@phoneF,1,3)	
	
		if not Exists(SELECT reg_userId FROM UserInfo WHERE loginName = @loginName)
			INSERT INTO [dbo].[UserInfo]
				   ([loginName]
				   ,[loginType]
				   ,[fullName]
				   ,[cntry_Reg]
				   ,[phoneF]
				   ,[phone]
				   ,[email]
				   ,[created_Dt]
				   ,[last_St]
				   ,gr_rank
				   ,u_rank
				   ,work_st 
				   ,userType
				   ,verifyType
				   ,verifyOtp
				   ,invited_by
				   --,phoneRight4
				   )
			 VALUES
				   (@loginName
				   ,0
				   ,@fullName
				   ,@cntry_Reg
				   ,@phoneF
				   ,@phone
				   ,@email
				   ,getdate()
				   ,0
				   ,1
				   ,0
				   ,0
				   ,0
				   ,@verifyType
				   ,0
				   ,@referral_by
				   --,right(@phone,4)
				   )
		ELSE
		BEGIN
			UPDATE [dbo].[UserInfo]
			   SET [last_St] = 0
				  ,[fullName] = @fullName
				  ,phone = @phone
				  ,phoneF = @phoneF
				  ,[cntry_Reg] = @cntry_Reg
				  ,userType = 0
				  ,email = @email
				  ,verifyType = @verifyType
				  ,verifyOtp = case when @verifyType = 0 and phone = @phone then verifyOtp else 0 end
				  ,[created_Dt] = case when @verifyType = 0 and phone = @phone then [created_Dt] else getdate() end
				  ,modified_dt = getdate()
				  --,phoneRight4 = right(@phone,4)
			 WHERE [loginName] = @loginName
		END

		  -- profile
		  select cast(regOid as nvarchar(50)) as reg_id
				,[loginName]
				,[FullName]
				,[Phone]
				,[Email]
				,[verifyType]
				,@valid as valid
				,@mess as [messages]
				,userId = userId
				,secret_cd = cast(regOid as nvarchar(50))
		  from [dbo].[UserInfo]
		  where loginName = @loginName
		  
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_user_login_regnew ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserLogin ' + @loginName 
		set @valid = 0
		set @mess = error_message()

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'UserInfo', 'Set', @SessionID, @AddlInfo
	end catch

	FINAL:
	select @valid as valid
		  ,@mess as [messages]


end