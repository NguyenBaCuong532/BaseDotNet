



CREATE procedure [dbo].[sp_Hom_Card_Credit_Get]
@CardCd	nvarchar(50)
as
	begin try	
		
	  --1
	  SELECT a.[Id]
			,a.[CardId]
			,a.[Cif_No2]
			,b.FullName 
			,a.[CreditLimit]
			,a.[SalaryAvg]
			,a.[IsSalaryTranfer]
			,a.[ResidenProvince]
			,a.[AsignDate]
			,a.[Status]
	FROM [MAS_CardCredit] a 
		INNER JOIN [MAS_Cards] d on a.CardId = d.CardId
		LEFT JOIN MAS_Customers b on a.Cif_No2 = b.CustId 
	  WHERE EXISTS(SELECT CardCd FROM [MAS_Cards] WHERE CardCd = @CardCd and CardId = a.CardID)


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Get_Card_Extend_ByCd ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardCredit', 'GET', @SessionID, @AddlInfo
	end catch