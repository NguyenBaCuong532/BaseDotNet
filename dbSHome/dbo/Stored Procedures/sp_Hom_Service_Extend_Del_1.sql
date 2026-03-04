



CREATE procedure [dbo].[sp_Hom_Service_Extend_Del]
	@userId	nvarchar(450),	
	@extendId	int	
as
	begin try
		declare @valid bit = 1
		declare @messages nvarchar(200)

			delete	trg
			from	MAS_Apartment_Service_Extend trg
			where ExtendId = @extendId
		
		select @valid as valid
		      ,@messages as [messages]

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Delete_Service_Extend_ById' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= 'Id' + cast(@extendId as varchar)

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Service_Extend', 'DEL', @SessionID, @AddlInfo
	end catch