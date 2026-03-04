
CREATE procedure [dbo].[sp_Hom_Service_Living_Detail]
	@UserID				nvarchar(450),
	@LivingPriceId		int = 0

as
	begin try		
		SELECT [LivingPriceId]
			  ,[ProjectCd]
			  ,[Step]
			  ,a.LivingTypeId as ServiceId
			  ,b.ServiceName 
			  ,[NumFrom]
			  ,[NumTo]
			  ,[Price]
			  ,[CalculateType]
			  ,[IsFree]
		  FROM [PAR_ServiceLivingPrice] a 
				inner join MAS_Services b on a.LivingTypeId = b.ServiceId 
		  where @LivingPriceId = 0 or LivingPriceId = @LivingPriceId
  	
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Service_Living_Detail ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID --+ ' date' + @ReceiveDate

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ApartmentProject', 'Update', @SessionID, @AddlInfo
	end catch