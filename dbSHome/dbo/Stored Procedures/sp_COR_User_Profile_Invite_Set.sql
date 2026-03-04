








CREATE procedure [dbo].[sp_COR_User_Profile_Invite_Set]
	@UserId nvarchar(450),
	@referralCd nvarchar(30),
	@invited_by nvarchar(100)

as
begin
	declare @valid bit = 1
	declare @mess nvarchar(100) = N'Đăng ký người dùng thành công'

	begin try	
	declare @support_userid nvarchar(100)

	if @referralCd is null or @referralCd = ''
		begin
			set @valid = 0
			set @mess = N'Bạn chưa nhận mã giới thiệu, vui lòng kiểm tra lại!'
			goto FINAL
		end

	if not Exists(SELECT reg_userId FROM UserInfo WHERE referralCd = @referralCd) 
		begin
			set @valid = 0
			set @mess = N'Mã giới thiệu chưa có trong hệ thống, vui lòng kiểm tra lại!'
			goto FINAL
		end

	IF Exists(SELECT Reg_UserId FROM UserInfo WHERE userId = @UserId and referralCd = @referralCd)
		begin
			set @valid = 0
			set @mess = N'Mã giới thiệu là của bạn, không đăng ký người giới thiệu là mã của bạn!'
			goto FINAL
		end

	IF Exists(SELECT a.Reg_UserId FROM UserInfo a join UserInfo i on a.invited_by = i.referralCd  WHERE a.userId = @UserId)
		begin
			set @valid = 0
			set @mess = N'Bạn đã đăng ký người giới thiệu, Hệ thống chưa hỗ trợ đổi!'
			goto FINAL
		end

		UPDATE [dbo].[UserInfo]
			SET invited_by = @referralCd
				,invited_at = getdate()
			WHERE [userId] = @userId 

	
	
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_User_Profile_Invited ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserId ' + @UserId 
		set @valid = 0
		set @mess = error_message()

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'UserInvited', 'Set', @SessionID, @AddlInfo
	end catch

	FINAL:
	select @valid as valid
		  ,@mess as [messages]


end