










CREATE procedure [dbo].[sp_Pay_ServicePOS_List]
	@UserId	nvarchar(450),
	@serviceKey nvarchar(50),
	@filter nvarchar(50)
as
	begin try
		set @filter = isnull(@filter,'')
	
		--2
		SELECT [PosCd]
			  ,[ServiceKey]
			  ,[PosName]
			  ,[Address]
			  ,[PosName] as name
			  ,[PosCd] as value
		  FROM [dbo].[WAL_ServicePOS]
		  WHERE [ServiceKey] = @serviceKey
			and [IsActive] = 1
			and PosName like @filter + '%'
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_ServicePOS_List ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'WalService', 'GET', @SessionID, @AddlInfo
	end catch