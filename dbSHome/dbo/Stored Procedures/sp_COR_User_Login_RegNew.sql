



CREATE procedure [dbo].[sp_COR_User_Login_RegNew]
	@fullName	nvarchar(250),
	@phone		nvarchar(20),
	@email		nvarchar(250),	
	@loginName	nvarchar(50),
	@verifyType	int,
	@referral_by	nvarchar(20),
	@userType	int

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
			if len(@phone) <> 10
			begin
				set @valid = 0
				set @mess = N'Số điện thại không đúng, phải đăng ký lại'
				exec utl_ErrorLog_Set 1, 'Invalid phone', 'sp_COR_User_Login_Reg', 'UserReg', 'Set', 0, @phone
				goto FINAL
			end
		end
		else if len(@email) is null or @email = '' or CHARINDEX('@', @email) = 0
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

		else if Exists(SELECT reg_userId FROM UserInfo u join MAS_Customers g on u.custId = g.custId WHERE loginName = @loginName and last_St = 1)
		begin
			set @valid = 0
			set @mess = N'Tên đăng nhập đã tồn tại. Vui lòng sử dụng tên khác!'
			goto FINAL
		end

		if @loginName like '% %'
		begin
			set @valid = 0
			set @mess = N'Tên đăng nhập khống chữa khoảng trỗng. Vui lòng kiểm tra và thử lại!'
			goto FINAL
		end

		if Exists(SELECT reg_userId FROM UserInfo u join MAS_Customers g on u.custId = g.custId WHERE u.email = @email and loginName = @loginName and last_St = 1) and @email <> ''
		begin
			set @valid = 0
			set @mess = N'Địa chỉ email đã tồn tại. Vui lòng kiểm tra và thử lại!'
			goto FINAL
		end
		else if Exists(SELECT reg_userId FROM UserInfo u join MAS_Customers g on u.custId = g.custId WHERE u.phone = @phone and loginName = @loginName and last_St = 1)
		begin
			set @valid = 0
			set @mess = N'Số điện thoại đã tồn tại. Vui lòng kiểm tra và thử lại!'
			goto FINAL
		end
		
		

		if @fullName = 'string' set @fullName = ''

		--if @referral_by is not null and @referral_by <> '' and not Exists(SELECT reg_userId FROM UserInfo WHERE referralCd = @referral_by) 
		--	and not Exists(SELECT saler_id FROM agency_saler_mb WHERE refCode = @referral_by and saler_st = 1) 
		--begin
		--	set @valid = 0
		--	set @mess = N'Mã giới thiệu không tồn tại, vui lòng kiểm tra lại!'
		--	goto FINAL
		--end

		if  len(@phoneF) > 3 and substring(@phoneF,1,1) = '+'
			set @cntry_Reg = substring(@phoneF,1,3)	
	
		--if @phone like '%***%' 
		--begin
		--	set @valid = 0
		--	exec utl_ErrorLog_Set 1, 'Invalid phone', 'sp_COR_User_Login_RegNew', 'UserReg', 'Set', 0, @phone
		--	goto FINAL
		--end

		--if (@email is not null and @email <> '' and @email like '%***%')
		--begin
		--	set @valid = 0
		--	exec utl_ErrorLog_Set 1, 'Invalid Email', 'sp_COR_User_Login_RegNew', 'UserReg', 'Set', 0, @email
		--	goto FINAL
		--end

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
				   )
			 VALUES
				   (@loginName
				   ,0
				   ,case when @fullName = 'string' then null else @fullName end
				   ,@cntry_Reg
				   ,@phoneF
				   ,@phone
				   ,@email
				   ,getdate()
				   ,0
				   ,1
				   ,0
				   ,0
				   ,@userType
				   ,@verifyType
				   ,0
				   ,@referral_by
				   )
		ELSE
		BEGIN
			UPDATE [dbo].[UserInfo]
			   SET [last_St] = 0
				  ,[fullName] = case when @fullName = 'string' then null else @fullName end
				  ,phone = @phone
				  ,phoneF = @phoneF
				  ,[cntry_Reg] = @cntry_Reg
				  ,userType = @userType
				  ,email = @email
				  ,verifyType = @verifyType
				  ,verifyOtp = case when @verifyType = 0 and phone = @phone then verifyOtp else 0 end
				  ,[created_Dt] = case when @verifyType = 0 and phone = @phone then [created_Dt] else getdate() end
				  ,modified_dt = getdate()
				  --,userType = @userType
			 WHERE [loginName] = @loginName
		END

		  -- profile
		  select [reg_UserId] as reg_id
				,[loginName]
				,[FullName]
				,[Phone]
				,[Email]
				,[verifyType]
				,@valid as valid
				,@mess as [messages]
				,userId
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
		set @ErrorMsg					= 'sp_COR_User_Login_RegNew ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserLogin ' + @loginName 
		set @valid = 0
		set @mess = error_message()

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'UserRegNew', 'Set', @SessionID, @AddlInfo
	end catch

	FINAL:
	select @valid as valid
		  ,@mess as [messages]


end