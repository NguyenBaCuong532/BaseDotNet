






CREATE procedure [dbo].[sp_Pay_Get_WalletHome_ByUserId]
	@userId nvarchar(450)
as
	begin try		
	
		UPDATE [dbo].UserInfo
		   SET last_dt = getdate()
		WHERE UserId = @UserId

		--1
		SELECT a.[WalletCd]
			  ,a.[BaseCif]
			  ,u.FullName
			  ,u.Phone
			  ,u.Email
			  ,u.loginName UserLogin
			  ,u.AvatarUrl
			  --,isnull(u.c,0) as IsCreatePassword
		FROM MAS_Contacts c 
			inner join UserInfo u on c.CustId = u.CustId 
			inner join MAS_Customers d on c.CustId = d.CustId 
			inner join WAL_Profile a on a.BaseCif = c.Cif_No 
		WHERE u.UserId = @userId

		--2
		SELECT a.ServiceKey
			  ,isnull([IconKey],[WalServiceCd]) as [IconKey]
			  ,[ServiceName]
			  ,[ServiceViewUrl]
			  ,[intOrder]
			  ,[IsFlage]
			  ,[Description]
			  ,b.PosCd
		FROM [WAL_Services] a
			LEFT JOIN (SELECT * FROM WAL_ServicePOS WHERE IsSPay = 1) b on a.ServiceKey = b.ServiceKey 
		WHERE IsInList = 1 and IsFlage = 1
		ORDER BY intOrder
	

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Get_WalletHome_ByUserId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'WalletHome', 'GET', @SessionID, @AddlInfo
	end catch