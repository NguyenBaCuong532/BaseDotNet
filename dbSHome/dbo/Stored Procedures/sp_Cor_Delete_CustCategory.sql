







CREATE procedure [dbo].[sp_Cor_Delete_CustCategory]
	@CustId	nvarchar(50),
	@CategoryCd nvarchar(150)
as
	begin try		
	declare @errmessage nvarchar(100)
	declare @baseCif nvarchar(20)
	--set @errmessage = 'This Cust: ' + @FullName + ' is exists!'
	
	DELETE FROM MAS_Category_Customer
	WHERE CustId = @CategoryCd and CategoryCd = @CategoryCd 
			

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Cor_Delete_CustCategory ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@User ' 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CustomerCategory', 'DELETE', @SessionID, @AddlInfo
	end catch