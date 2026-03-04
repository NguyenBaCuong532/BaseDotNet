






CREATE procedure [dbo].[sp_Hom_Apartment_Household_Country]
	@UserId	nvarchar(450)

as
	begin try
		
	SELECT [CountryCd]
		  ,[CountryName]
		  ,[Flag]
	  FROM [COR_Countries]
	  order by [CountryCd]
	
	

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Apartment_Household_Country ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Country', 'GET', @SessionID, @AddlInfo
	end catch