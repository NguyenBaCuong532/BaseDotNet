

CREATE procedure [dbo].[sp_COR_User_Profile_Idcard_Set]
	@userId			nvarchar(450),	
	@idcard_type	int,
	@idcard_No		nvarchar(50),
	@idcard_Issue_Dt nvarchar(10),
	@idcard_Issue_Plc nvarchar(200),
	@idcard_Expire_Dt nvarchar(10),
	@res_cntry		nvarchar(10),
	@origin_add		nvarchar(300),
	@res_add		nvarchar(300),
	@birthday		nvarchar(20),
	@sex			bit,
	@fullName		nvarchar(200),
	@recognition_rt	float
as
begin
	declare @valid bit = 1
	declare @messages nvarchar(400) = N'Cập nhật thành công'

	begin try	
	declare @custId nvarchar(100)
	declare @idcard_Expire_Date datetime

		set @idcard_Issue_Dt = REPLACE(@idcard_Issue_Dt,'-','/')
		set @idcard_Expire_Dt = REPLACE(@idcard_Expire_Dt,'-','/')

		--kiem tra so
		if @idcard_no is null or @idcard_no = ''
		begin
			set @valid = 0
			set @messages = N'Yêu cầu nhập thông tin mã số!'
			goto FINAL
		end

		if @idcard_type = 1
		begin
			if len(@idcard_no) <> 9 and len(@idcard_no) = 12
			begin
				set @valid = 0
				set @messages = N'Chọn sai kiểu giấy tờ'
				goto FINAL
			end
			else if len(@idcard_no) <> 9
			begin
				set @valid = 0
				set @messages = N'Số CMT bị sai'
				goto FINAL
			end
		end

		if @idcard_type = 2
		begin
			if len(@idcard_no) <> 12 and len(@idcard_no) = 9
			begin
				set @valid = 0
				set @messages = N'Chọn sai kiểu giấy tờ'
				goto FINAL
			end
			else if len(@idcard_no) <> 12
			begin
				set @valid = 0
				set @messages = N'Sai số CCCD'
				goto FINAL
			end
		end

		if @idcard_no like '%[^0-9]%' and (@idcard_type = 1 or @idcard_type = 2)
		begin
			set @valid = 0
			set @messages = N'Yêu cầu số CMT/CCCD ở dạng số!'
			goto FINAL
		end
		
		--kt ngay cap
		if @idcard_Issue_Dt is null or @idcard_Issue_Dt = ''
		begin			
			set @valid = 0
			set @messages = N'Chưa có ngày cấp!'
			goto FINAL
		end
		if @idcard_Issue_Dt not LIKE '[0-3][0-9]/[0-1][0-9]/[1-2][0-9][0-9][0-9]'
		begin
			set @valid = 0
			set @messages = N'Định dạng ngày cấp không hợp lệ!'
			goto FINAL
		end
		
		--kiem tra noi cap
		if @idcard_Issue_Plc is null or @idcard_Issue_Plc = ''
		begin
			set @valid = 0
			set @messages = N'Chưa có nơi cấp'
			goto FINAL
		end

		--kiem tra ngay het han
		if @idcard_expire_dt is null or @idcard_expire_dt = ''
		begin
			set @idcard_Expire_Date = dateadd(year,case when @idcard_type <3 then 15 else 5 end,convert(datetime,@idcard_Issue_Dt,103))
			--set @valid = 0
			--set @messages = N'Chưa có ngày hết hạn!'
			--goto FINAL
		end
		else if @idcard_expire_dt not LIKE '[0-3][0-9]/[0-1][0-9]/[1-2][0-9][0-9][0-9]'
		begin
			set @valid = 0
			set @messages = N'Định dạng ngày hết hạn không hợp lệ!'
			goto FINAL
		end
		else
		begin
			set @idcard_Expire_Date = convert(datetime,@idcard_Expire_Dt,103)
		end

		if @idcard_Expire_Date < getdate()
		begin
			set @valid = 0
			set @messages = N'Ngày hết hạn đã bị quá hạn!'
			goto FINAL
		end
		
		if len(@birthday) = 4 
			set @birthday = '01/01/' + @birthday

		--kiem tra ngay het han
		if @birthday is null or @birthday = ''
		begin
			set @valid = 0
			set @messages = N'Chưa có ngày sinh!'
			goto FINAL
		end
		if @birthday not LIKE '[0-3][0-9]/[0-1][0-9]/[1-2][0-9][0-9][0-9]'
		begin
			set @valid = 0
			set @messages = N'Định dạng ngày sinh không hợp lệ!'
			goto FINAL
		end
		
		if @res_cntry = N'Việt Nam' or @res_cntry = ''
			set @res_cntry = 'VN'
					
		begin
			if exists(select a.userId From UserInfo a 
						join UserInfo b on a.idcard_No = b.idcard_No and a.idcard_type = b.idcard_type and a.userType = b.userType and b.idcard_Verified = 1
						where b.userId = @userId and a.userType = 2 and a.reg_userId <> b.reg_userId)
				begin
					set @valid = 0
					set @messages = N'Số '+ case @idcard_type when 1 then 'CMT' when 2 then 'CCCD' else N'Hộ chiếu' end +' đã được đăng ký bởi người khác'
					goto FINAL
				end

				UPDATE [dbo].UserInfo
				   SET idcard_type			= @idcard_type
					  ,[idcard_No]			= @idcard_No
					  ,[idcard_Issue_Dt]	= convert(datetime,@idcard_Issue_Dt,103)
					  ,[idcard_Issue_Plc]	= @idcard_Issue_Plc
					  ,idcard_Expire_Dt		= @idcard_Expire_Date
					  ,res_Cntry			= isnull(@res_Cntry,'VN')
					  ,[idcard_Verified]	= case when @recognition_rt > 0.8 then 1 else 0 end
					  ,origin_add			= @origin_add
					  ,res_add				= @res_add
					  ,birthday				= convert(datetime,@birthday,103)
					  ,sex					= @sex
					  ,fullName				= @fullName
					  ,recognition_rt		= @recognition_rt
					  ,modified_dt = getdate()
				 WHERE userId = @userId
			
		end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_COR_User_Profile_idcard_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@:' + @UserId + ' @Issue_Dt:' + @idcard_Issue_Dt

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'Profile_Set', 'Insert', @SessionID, @AddlInfo
	end catch


	FINAL:
	select @valid as [valid]
		  ,@messages as [messages]
end