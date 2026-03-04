









CREATE procedure [dbo].[sp_Hom_Apartment_Relation_List]
	@UserId	nvarchar(40)
as
	begin try
		--1 
		SELECT RelationId
			  ,RelationName
	  FROM MAS_Customer_Relation b 
		ORDER BY RelationId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Get_Apartment_Relation ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'BuildFloor', 'GET', @SessionID, @AddlInfo
	end catch