







CREATE procedure [dbo].[sp_Pay_Get_Wallet_Recharge_Page]
@UserId	nvarchar(450)

as
	begin try
		--1
		SELECT [TranferCd]
		  ,[TranferName]
		  ,RateFee
		FROM [WAL_Tranfers] a
		WHERE Exists(select [TranferCd] from [WAL_BankLinked] where [TranferCd] = a.TranferCd) 
			and TranferCd = 'BANKLINK'
		ORDER BY intOrder

		--2
		SELECT b.SourceCd, b.ShortName, b.SourceName, b.LogoUrl, a.TranferCd
		FROM   WAL_BankLinked AS a INNER JOIN
               WAL_Banks AS b ON a.SourceCd = b.SourceCd
			WHERE a.TranferCd = 'BANKLINKED' 

		--3
		SELECT [TranferCd]
		  ,[TranferName]
		  ,RateFee
		  ,0 as cardScheme
		  --,N'Thẻ ATM từ các ngân hàng' as SourceName
		  --,N'Vietcombank, Sacombank, VPBank...' as [Description]
		FROM [WAL_Tranfers] a
		WHERE Exists(select [TranferCd] from [WAL_BankLinked] where [TranferCd] = a.TranferCd) 
			and TranferCd = 'ATM'

		SELECT a.LinkedID
			  ,a.[TranferCd]
			  ,a.[SourceCd]
			  ,a.[LinkedToken]
			  ,a.[IsLinked]
			  ,a.[LinkDt]
			  ,a.[card_Brand]
			  ,a.[card_NameOnCard]
			  ,a.[card_IssueDate]
			  ,a.[card_Number]
			  ,a.[card_Scheme]
			  ,c.ShortName 
			  ,c.SourceName
			  ,c.LogoUrl 
		  FROM [WAL_TranferLinked] a 
			inner join WAL_Profile w on a.WalletCd = w.WalletCd
			inner join MAS_Contacts d on w.BaseCif = d.Cif_No 
			inner join UserInfo u on u.CustId = d.CustId 
			left join WAL_Banks c on a.SourceCd = c.SourceCd 
		WHERE u.UserId = @UserId 
			and TranferCd = 'ATM'
			and a.[IsLinked] = 1

		--4
		SELECT [TranferCd]
		  ,[TranferName]
		  ,RateFee
		  ,1 as cardScheme
		  --,N'Thẻ thanh toán quốc tế' as SourceName
		  --,N'VISA, MasterCard...' as [Description]
		FROM [WAL_Tranfers] a
		WHERE Exists(select [TranferCd] from [WAL_BankLinked] where [TranferCd] = a.TranferCd) 
			and TranferCd = 'INT'

		SELECT a.LinkedID
			  ,a.[TranferCd]
			  ,a.[SourceCd]
			  ,a.[LinkedToken]
			  ,a.[IsLinked]
			  ,a.[LinkDt]
			  ,[card_Brand]
			  ,[card_NameOnCard]
			  ,[card_IssueDate]
			  ,[card_Number]
			  ,[card_Scheme]
			  ,c.ShortName 
			  ,c.SourceName
			  ,c.LogoUrl 
		  FROM [WAL_TranferLinked] a 
			inner join WAL_Profile w on a.WalletCd = w.WalletCd
			inner join MAS_Contacts d on w.BaseCif = d.Cif_No 
			inner join UserInfo u on u.CustId = d.CustId 
			left join WAL_Banks c on a.SourceCd = c.SourceCd 
		WHERE u.UserId = @UserId 
			and TranferCd = 'INT'
			and a.[IsLinked] = 1

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Get_Wallet_Recharge_Page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'RechargePage', 'GET', @SessionID, @AddlInfo
	end catch