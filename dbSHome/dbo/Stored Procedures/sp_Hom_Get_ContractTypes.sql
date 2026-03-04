






CREATE procedure [dbo].[sp_Hom_Get_ContractTypes]
	@UserId nvarchar(200)
as
	begin try		

	SELECT [ContractTypeId] as ExtendTypeId
		  ,[ContractTypeName] as ExtendTypeName
	FROM [dbo].[MAS_ContractTypes]
		ORDER BY ContractTypeId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Get_ContractTypes ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ContractTypes', 'GET', @SessionID, @AddlInfo
	end catch