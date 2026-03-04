











CREATE procedure [dbo].[sp_Pay_Point_Trantype_List]
	@UserId	nvarchar(450),
	@filter nvarchar(50)
as
	begin try
		set @filter = isnull(@filter,'')
	--1
		SELECT [TranTypeId] 
			  ,[TranTypeName]
			  ,[TranTypeId] as value
			  ,[TranTypeName] as name
		  FROM [dbSHome].[dbo].[WAL_PointTransactionType]
		  ORDER BY [CreateDt]
		

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Point_Trantype_List ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'WalService', 'GET', @SessionID, @AddlInfo
	end catch