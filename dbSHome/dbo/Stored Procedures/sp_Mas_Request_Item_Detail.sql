
create procedure [dbo].[sp_Mas_Request_Item_Detail]
	@UserID			nvarchar(450),
	@PriceId		int = 0

as
	begin try		
		SELECT [PriceId]
			  ,[RequestTypeId]
			  ,[ItemName]
			  ,[IsFree]
			  ,[Price]
			  ,[Unit]
			  ,[Note]
			  ,[Post]
			  ,[isUsed]
		  FROM [dbSHome].[dbo].[PAR_RequestTypePrice]
          where [PriceId] = @PriceId

  	
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Mas_Request_Item_Detail ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID --+ ' date' + @ReceiveDate

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ApartmentProject', 'Update', @SessionID, @AddlInfo
	end catch