







CREATE procedure [dbo].[sp_Hom_Service_LivingType_List]
	@UserId	nvarchar(450)
as
	begin try		
		
		SELECT [LivingTypeId]
			  ,[LivingTypeName]
		  FROM [MAS_LivingTypes]

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Service_LivingType_List ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'LivingTypes', 'GET', @SessionID, @AddlInfo
	end catch