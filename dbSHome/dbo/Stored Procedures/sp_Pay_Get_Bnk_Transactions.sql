





CREATE procedure [dbo].[sp_Pay_Get_Bnk_Transactions]
as
	begin try		

		/****** Script for SelectTopNRows command from SSMS  ******/
	SELECT [BkTransactionId]
		  ,[CustomerID]
		  ,[DestinationAccountNumber]
		  ,[Period]
		  ,[Amount]
		  ,[PaymentDt]
		  ,[Description]
		  ,[PaymentTypeID]
		  --,[BankSource]
		  ,[IsTrans]
	  FROM [dbSHome].[dbo].WAL_BkTransaction 
	  WHERE [IsTrans] = 0
	  

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Get_Bank_Transactions ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Transactions', 'GET', @SessionID, @AddlInfo
	end catch