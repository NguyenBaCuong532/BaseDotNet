

CREATE procedure [dbo].[sp_User_Get_User_ByCustId]
	@CustId nvarchar(450)

as
	begin try
	--1
	 SELECT c.CustId
		  ,isnull(c.AvatarUrl, b.[AvatarUrl]) as AvatarUrl
		  ,c.UserId
		  ,UserLogin = loginName
		  ,0 as IsAdmin 
		  ,IsLock	= lock_st
		  ,case when isnull(c.lock_st,0) = 0 then N'Đang hoạt động' else N'Đã bị khóa' end as LockName
		  ,convert(nvarchar(10),c.created_dt,103) as StartDate
		  ,b.FullName
		  ,c.userType
		  ,case c.userType 
			when 1 then 'mysunshine'
			when 2 then 'superapp'
			when 3 then 'resortapp'
			when 4 then 'cabapp'
			else 'webmanager' end as app_user
	  FROM UserInfo c 
		inner join MAS_Customers b on c.CustId = b.CustId 
		WHERE c.CustId = @CustId 

	

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_User_Get_User_ByCustId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Users', 'GET', @SessionID, @AddlInfo
	end catch