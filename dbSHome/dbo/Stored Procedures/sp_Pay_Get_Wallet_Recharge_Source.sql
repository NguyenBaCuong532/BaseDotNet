







CREATE procedure [dbo].[sp_Pay_Get_Wallet_Recharge_Source]
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
			WHERE a.TranferCd = 'BANKLINK'

		--3
		SELECT [TranferCd]
		  ,[TranferName]
		  ,RateFee
		  ,0 as cardScheme
		  ,N'Thẻ ATM từ các ngân hàng' as SourceName
		  ,N'Vietcombank, Sacombank, VPBank...' as [Description]
		FROM [WAL_Tranfers] a
		WHERE Exists(select [TranferCd] from [WAL_BankLinked] where [TranferCd] = a.TranferCd) 
			and TranferCd = 'ATM'

		--4
		SELECT [TranferCd]
		  ,[TranferName]
		  ,RateFee
		  ,1 as cardScheme
		  ,N'Thẻ thanh toán quốc tế' as SourceName
		  ,N'VISA, MasterCard...' as [Description]
		FROM [WAL_Tranfers] a
		WHERE Exists(select [TranferCd] from [WAL_BankLinked] where [TranferCd] = a.TranferCd) 
			and TranferCd = 'INT'

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Get_Wallet_RechargeSource_ByUserId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'RechargeSource', 'GET', @SessionID, @AddlInfo
	end catch