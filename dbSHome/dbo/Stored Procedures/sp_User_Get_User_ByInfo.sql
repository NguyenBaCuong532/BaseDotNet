






CREATE procedure [dbo].[sp_User_Get_User_ByInfo]
	@Phone nvarchar(20),
	@Email	nvarchar(100)

as
	begin try
	--1
		SELECT a.CustId
			  ,a.FullName
			  ,a.[IsSex]
			  ,case when a.IsSex = 1 then N'Nam' else N'Nữ' end as SexName
			  ,convert(nvarchar(10),a.birthday,103) as birthday
			  ,a.birthday as birthday_dt
			  ,b.[Phone]
			  ,b.[Email]
			  ,a.[AvatarUrl] as AvatarUrl
			  ,c.UserId
			  ,c.loginName UserLogin
			  ,c.admin_st as IsAdmin 
	  FROM [MAS_Customers] a 
			inner join MAS_Contacts b on a.CustId = b.CustId
			inner join Users c on a.CustId = c.CustId
		WHERE b.Phone = @Phone and b.Email = @Email


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Usr_Get_User_ByInfo ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Customer', 'GET', @SessionID, @AddlInfo
	end catch