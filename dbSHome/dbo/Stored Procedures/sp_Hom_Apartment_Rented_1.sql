


CREATE procedure [dbo].[sp_Hom_Apartment_Rented]
	@UserID	nvarchar(450),
	@ApartmentId int,
	@Status bit
as
	begin try		
		
		 UPDATE t1
		   SET IsRent = @Status
				--ReceiveDt = getdate()
		 FROM MAS_Apartments t1
		 WHERE t1.ApartmentId = @ApartmentId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Update_Apartment_Rented ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Apartment', 'Update', @SessionID, @AddlInfo
	end catch