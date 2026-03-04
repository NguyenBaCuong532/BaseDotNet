

CREATE procedure [dbo].[sp_Crm_ApartmentHandOverExchangeDetail_GetList]
	@UserId nvarchar(450)=null,
	@ExchangeId bigint
as
	begin try		
		 SELECT [ExchangeDetailId]
			  ,[ExchangeId]
			  ,[Content]
			  ,[UserTags]
			  ,[UserTagNames]
			  ,[Created]
			  ,c.FullName as CreatedBy
			  ,[Modified]
			  ,[ModifiedBy]
		  FROM [dbo].[CRM_Apartment_HandOver_Exchange_Detail] a  left join MAS_Users b on a.CreatedBy = b.UserId
																 inner join MAS_Customers c on b.CustId = c.CustId
																 
		  WHERE ExchangeId = @ExchangeId
		  ORDER BY a.Created desc

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

		

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_ApartmentHandOver_GetList ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CRM_Apartment_HandOver,CRM_Apartment_HandOver_Detail', 'GET', @SessionID, @AddlInfo
	end catch