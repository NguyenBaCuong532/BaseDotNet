









CREATE procedure [dbo].[sp_User_Get_UserProfile]
	 @userLogin nvarchar(450)
	
as
	begin try	
	--1
	--else
		SELECT a.reg_userId
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
			  ,cast(a.verify_profile as int) as isVerify
			  ,a.[LoginType]
			  ,a.[LoginId]
			  --,a.[LastDt]
			  --,a.[EmailConfirm]
		  FROM UserInfo a
			left join MAS_Customers b on a.CustId = b.CustId 
		where a.loginName = @userLogin
	--2

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_RES_Get_UserProfile ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ResProfile', 'GET', @SessionID, @AddlInfo
	end catch