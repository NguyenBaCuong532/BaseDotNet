

CREATE procedure [dbo].[sp_Hom_Card_Types]
as
	begin try		

		SELECT [CardTypeId]
			  ,[CardTypeName]
			  ,[CardTypeName] as name
			  ,[CardTypeId] as value
		  FROM [MAS_CardTypes]

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Get_CardTypes ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardTypes', 'GET', @SessionID, @AddlInfo
	end catch