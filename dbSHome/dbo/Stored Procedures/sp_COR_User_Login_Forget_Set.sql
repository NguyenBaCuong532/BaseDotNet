

CREATE procedure [dbo].[sp_COR_User_Login_Forget_Set]
	@clientId	nvarchar(100),
	@loginName	nvarchar(100),
	@phone	nvarchar(20),
	@birthday	nvarchar(10),
	@verifyType	int,
	@udid		nvarchar(100) = null
as
begin
	declare @valid bit
	declare @messages nvarchar(300)

	begin try	
		if not exists(select 1 from UserInfo where loginName = @loginName)
		begin
			set @valid = 0
			set @messages = N'Không tin thấy thông tin đăng nhập, vui lòng kiểm tra lại!'
			goto FINAL
		end

		

		if @udid is null or @udid = '' 
			or not exists(select 1 FROM UserDevice t join UserInfo u on t.userId = u.userId
				WHERE udid = @udid and u.loginName = @loginName and [clientId] = @clientId and etokenDevice = 1)
		begin
				if not exists(select 1 from UserInfo u 
				--join MAS_Customers g on u.custId = g.custId 
				where loginName = @loginName and (u.Phone = @phone))
				begin
					set @valid = 0
					set @messages = N'Số điện thoại không đúng. Vui lòng kiểm tra lại!'
					goto FINAL
				end

				--if not exists(select 1 from UserInfo u join MAS_Customers g on u.custId = g.custId where loginName = @loginName and (g.Pass_No = @idcard_no))
				--begin
				--	set @valid = 0
				--	set @messages = N'Số giấy tờ tùy thân không đúng. Vui lòng kiểm tra lại!'
				--	goto FINAL
				--end
				
				----kiem tra ngay het han
				--if @birthday is null or @birthday = ''
				--begin
				--	set @valid = 0
				--	set @messages = N'Chưa có ngày sinh!'
				--	goto FINAL
				--end
				--if @birthday not LIKE '[0-3][0-9]/[0-1][0-9]/[1-2][0-9][0-9][0-9]'
				--begin
				--	set @valid = 0
				--	set @messages = N'Định dạng ngày sinh không hợp lệ!'
				--	goto FINAL
				--end

				--if not exists(select 1 from UserInfo u join MAS_Customers g on u.custId = g.custId where loginName = @loginName and (g.birthday = convert(datetime,@birthday,103)))
				--begin
				--	set @valid = 0
				--	set @messages = N'Ngày sinh không đúng. Vui lòng kiểm tra lại!'
				--	goto FINAL
				--end
			end
		--end

		 UPDATE UserInfo
		   SET [verifyOtp] = case when last_dt < dateadd(hour,-1,getdate()) then 0 else isnull(verifyOtp,0) + 1 end
			  ,verifyType = @verifyType
			  ,last_dt = case when last_dt < dateadd(hour,-1,getdate()) or last_dt is null then getdate() else last_dt end
			  ,modified_dt = getdate()
		 WHERE [loginName] = @loginName

		  -- profile
		  SELECT [reg_UserId] as reg_id
				,[loginName]
				,u.[FullName]
				,[Phone]	= isnull(u.phone,g.phone)
				,[Email]	= isnull(u.email,g.email)
				,[verifyType]
				,case when [verifyOtp] <= 5 then 1 else 0 end as valid
				,case when [verifyOtp] <= 5 then '' else N'Đã quá số lần gửi OTP cho phép!' end as [messages]
				,userId
			FROM UserInfo u 
				left join MAS_Customers g on u.custId = g.custId
			 WHERE [loginName] = @loginName

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_COR_User_Login_Forget_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@loginName ' + @loginName + '@birthday' + @birthday
		set @valid = 0
		set @messages = error_message()

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'UserRegGet', 'Set', @SessionID, @AddlInfo
	end catch

	FINAL:
	select @valid as valid
	      ,@messages as [messages]


end