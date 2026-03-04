





CREATE procedure [dbo].[sp_Pay_Get_Inter_Cards]
	@userId nvarchar(450),
	@isInternal int
as
	begin try		
	if @isInternal = 1
		SELECT SourceCd
			  ,[ShortName]
			  ,SourceName
			  ,[LogoUrl]
		  FROM WAL_Banks
		  WHERE IsBank = 1
	else
		SELECT SourceCd
			  ,[ShortName]
			  ,SourceName
			  ,[LogoUrl]
		  FROM WAL_Banks
		  WHERE isIntCard = 1

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Get_Inter_Cards ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'InterCard', 'GET', @SessionID, @AddlInfo
	end catch