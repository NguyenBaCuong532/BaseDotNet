







CREATE procedure [dbo].[sp_Pay_Get_WalletProfile_ByPhone]
	@UserId nvarchar(450),
	@phone nvarchar(20)
as
	begin try		
	
		--1
		SELECT a.[WalletCd]
			  ,a.[BaseCif]
			  ,u.FullName
			  ,u.Phone
			  ,u.Email
			  ,u.loginName UserLogin
			  ,u.AvatarUrl
			  --,isnull(u.IsCreatePassword,0) as IsCreatePassword
		FROM MAS_Contacts c 
			inner join UserInfo u on c.CustId = u.CustId 
			inner join MAS_Customers d on c.CustId = d.CustId 
			inner join WAL_Profile a on a.BaseCif = c.Cif_No 
		WHERE u.loginName like 'spay_' + @phone


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Get_WalletProfile_ByPhone ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'WalletProfile', 'GET', @SessionID, @AddlInfo
	end catch