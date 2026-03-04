






CREATE procedure [dbo].[sp_Pay_Get_Wallet_RechargeSource_ByUserId]
@UserId	nvarchar(450)

as
	begin try
	
	
		--1
		SELECT [TranferCd]
		  ,[TranferName]
		  ,RateFee
		FROM [WAL_Tranfers] a
		WHERE Exists(select [TranferCd] from [WAL_BankLinked] where [TranferCd] = a.TranferCd)
		ORDER BY intOrder

		--2
		SELECT b.SourceCd, b.ShortName, b.SourceName, b.LogoUrl, a.TranferCd
		FROM   WAL_BankLinked AS a INNER JOIN
               WAL_Banks AS b ON a.SourceCd = b.SourceCd

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