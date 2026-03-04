






CREATE procedure [dbo].[sp_Cor_Insert_CustCategory]
	@CustId	nvarchar(50),
	@CategoryCd nvarchar(150)
as
	begin try		
	declare @errmessage nvarchar(100)
	declare @baseCif nvarchar(20)
	--set @errmessage = 'This Cust: ' + @FullName + ' is exists!'
	
		if not exists(select CustId from MAS_Category_Customer where CustId = @CustId and CategoryCd = @CategoryCd)
		begin
	
			INSERT INTO [dbo].MAS_Category_Customer
				   (CustId
				   ,CategoryCd
				   )
			 VALUES
				   (@CustId
				   ,@CategoryCd
				   )
		end
		

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Cor_Insert_CustCategory ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@User ' 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CustomerCategory', 'Insert', @SessionID, @AddlInfo
	end catch