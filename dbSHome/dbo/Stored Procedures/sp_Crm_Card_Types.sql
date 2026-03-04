
CREATE procedure [dbo].[sp_Crm_Card_Types] 
	@Total				int out,
	@TotalFiltered		int out
as
	begin try 
		 
		 
		select	@Total					= count(mt.CardTypeId)
			FROM   MAS_CardTypes mt
			join CRM_CardType ct on mt.CardTypeId = ct.CardTypeId
 			
		set	@TotalFiltered = @Total
 
	--1
		select   mt.CardTypeId --as value
				,mt.CardTypeName --as name
				,ct.ImageUrl
				,[CardTypeName] as name
			    ,mt.[CardTypeId] as value
			FROM MAS_CardTypes mt
			join CRM_CardType ct on mt.CardTypeId = ct.CardTypeId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= '[sp_Crm_Get_Card_Type_List] ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Template', 'GET', @SessionID, @AddlInfo
	end catch