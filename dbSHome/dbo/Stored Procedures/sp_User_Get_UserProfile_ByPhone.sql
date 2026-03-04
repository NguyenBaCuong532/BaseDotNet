








-- exec sp_User_Get_UserProfile_ByPhone 

CREATE procedure [dbo].[sp_User_Get_UserProfile_ByPhone]
	 @userId nvarchar(450) = '9f7df795-66fe-420b-af0e-434f13c359db'
	,@phone nvarchar(50) = '0977189760'
as
	begin try	
	--1
	if @phone is null or @phone = ''
		SELECT a.reg_userId [regUserId]
			  ,a.[UserId]
			  ,a.[CustId]
			  ,isnull(a.[AvatarUrl],b.AvatarUrl) as AvatarUrl
			  ,a.loginName [UserLogin]
			  --,a.[UserPassword]
			  --,a.[IsManager]
			  --,a.[IsLock]
			  --,a.[StartDt]
			  --,a.[IsClose]
			  --,a.[CloseDt]
			  --,a.[AppKey]
			  --,a.[IsActived]
			  ,isnull(a.[FullName],b.FullName) as FullName
			  ,isnull(a.[Phone],b.Phone) as Phone
			  ,a.[Email]
			  --,cast(a.[isVerify] as int) as isVerify
			  ,a.[LoginType]
			  ,a.[LoginId]
			  --,a.[LastDt]
			  --,a.[EmailConfirm]
		  FROM [UserInfo] a
			left join MAS_Customers b on a.CustId = b.CustId 
		where a.UserId = @userId
	--2
	else
		SELECT a.reg_userId [regUserId]
			  ,a.[UserId]
			  ,a.[CustId]
			  ,isnull(a.[AvatarUrl],b.AvatarUrl) as AvatarUrl
			  ,a.loginName [UserLogin]
			  --,a.[UserPassword]
			  --,a.[IsManager]
			  --,a.[IsLock]
			  --,a.[StartDt]
			  --,a.[IsClose]
			  --,a.[CloseDt]
			  --,a.[AppKey]
			  --,a.[IsActived]
			  ,isnull(a.[FullName],b.FullName) as FullName
			  ,isnull(a.[Phone],b.Phone) as Phone
			  ,a.[Email]
			  --,cast(a.[isVerify] as int) as isVerify
			  ,a.[LoginType]
			  ,a.[LoginId]
			  --,a.[LastDt]
			  --,a.[EmailConfirm]
		  FROM [UserInfo] a
			left join MAS_Customers b on a.CustId = b.CustId 
		where a.Phone = @phone


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_User_Get_UserProfile_ByPhone ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'UserProfile', 'GET', @SessionID, @AddlInfo
	end catch