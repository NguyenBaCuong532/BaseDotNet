







CREATE procedure [dbo].[sp_Pay_Create_New_Account] 
	@CustID nvarchar(50),
	@BaseCif		nvarchar(16) out
	
as
	begin try
				
	IF NOT EXISTS(SELECT a.Cif_No FROM MAS_Contacts a WHERE CustId = @CustID)
	BEGIN 
		set @BaseCif = (SELECT TOP 1 a.[CIF_No] FROM [dbSCRM].[dbo].[COR_CIF] a WHERE IsUsed = 0)
     --Insert statements for trigger here
		INSERT INTO MAS_Contacts
           ([Cif_No]
           ,[Phone]
           ,[Email]
		   ,CustId
		   ,RegDt
           )
		SELECT @BaseCif--isnull([Cif_No],@BaseCif)
		  ,[Phone]
		  ,[Email]
		  ,CustId
		  ,getdate()
	  FROM MAS_Customers
	  WHERE CustId = @CustID

	  UPDATE t
	    SET [IsUsed] = 1
		  ,[SysDate] = getdate()
		FROM [dbSCRM].[dbo].[COR_CIF] t inner join MAS_Contacts t2 on t.CIF_No = t2.Cif_No
		WHERE t2.CustId = @CustID

	END
		

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Create_New_Account' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'account', 'cre', @SessionID, @AddlInfo
	end catch