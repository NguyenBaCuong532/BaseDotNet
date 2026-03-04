
-- =============================================
-- Author:		duongpx
-- Create date: 11/7/2024 11:42:02 AM 
-- Description:	lấy thông tin cá nhân
-- =============================================
CREATE   procedure [dbo].[sp_app_user_profile_get]
	 @userId uniqueidentifier = null
	 ,@prifileUserId nvarchar(450) = null
	,@acceptLanguage nvarchar(50) = 'vi-VN'
	,@loginName nvarchar(50)	= null
	,@referralCd nvarchar(50)	= null
as
	begin try	

		declare @sUserId uniqueidentifier = @prifileUserId
		if @loginName is not null 
		set @sUserId = (SELECT top 1 [userId]
		  FROM UserInfo a			
		where a.loginName = @loginName)
		else
		if @referralCd is not null 
		set @sUserId = (SELECT top 1 [userId]
		  FROM UserInfo a			
		where a.referralCd = @referralCd)

		-- check neu @sUserId null thi set bang userId dang nhap
		if @sUserId is null
			set @sUserId = @userId

		--1
		SELECT distinct cast(regOid as nvarchar(50)) as reg_id
			  ,a.userId
			  ,a.referralCd
			  ,a.loginName
			  --,coverUrl = isnull(a.coverUrl ,[dbo].[fn_url_nobleapp_base]('/images/cover.png'))
			  ,avatarUrl = a.avatarUrl
			  ,a.[nickName]
			  ,RegisteredFace = dbo.fn_get_meta_file_url(face_id)
			  ,fullName = a.[fullName]
			  ,a.[phone]
			  ,a.[email]
			  ,[sex]			= case a.[sex] when 1 then N'Nam' when 0 then N'Nữ' else '' end 
			  ,[birthday]		= convert(nvarchar(10),a.[birthday],103) 
			  ,idcard_Verified 
			  ,ranking			= a.u_rank
			  ,idcard_no 
			  ,rank = ''
			  ,point = N'0 điểm'
			  ,commissionAmt = 0
			  ,bonusAmt = 0
			  ,isLiveApp = 1
		  FROM UserInfo a
		where a.userId = @sUserId



	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_user_profile_get_by_userId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' - @userId '

		EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'UserInfo', 'Insert', @SessionID, @AddlInfo
	end catch