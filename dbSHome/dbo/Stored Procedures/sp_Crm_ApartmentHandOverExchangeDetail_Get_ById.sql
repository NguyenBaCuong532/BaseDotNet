

create procedure [dbo].[sp_Crm_ApartmentHandOverExchangeDetail_Get_ById]
	@UserId nvarchar(450)=null,
	@ExchangeDetailId bigint
as
	begin try		
		 SELECT [ExchangeDetailId]
			  ,[ExchangeId]
			  ,[Content]
			  ,[UserTags]
			  ,[Created]
			  ,[CreatedBy]
			  ,[Modified]
			  ,[ModifiedBy]
		  FROM [dbo].[CRM_Apartment_HandOver_Exchange_Detail]
		  where ExchangeDetailId = @ExchangeDetailId

		SELECT [AttachId]
			  ,[AttachName]
			  ,[AttachSize]
			  ,[AttachLink]
			  ,[ExchangeId]
			  ,[ExchangeDetailId]
			  ,[Type]
			  ,[Created]
			  ,[CreatedBy]
			  ,[Modified]
			  ,[ModifiedBy]
		  FROM [dbo].[CRM_Apartment_HandOver_Attach]
		  WHERE ExchangeDetailId = @ExchangeDetailId

		

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Get_ApartmentHandOverExchangeDetail_ById ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CRM_Apartment_HandOver_Attach,CRM_Apartment_HandOver_Detail', 'GET', @SessionID, @AddlInfo
	end catch