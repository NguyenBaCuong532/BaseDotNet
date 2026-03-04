



CREATE procedure [dbo].[sp_Hom_Card_Change]
	@UserID	nvarchar(450),
	@CardCd nvarchar(50),
	@CustId nvarchar(50)
as
	begin try	
		declare @valid bit = 1
		declare @messages nvarchar(100) = ''
			
		--declare @errmessage nvarchar(100)
		--set @errmessage = 'This CustId: ' + isnull(@CustId,'null') + ' is not exists '

		if not exists(select CustId From MAS_Customers where CustId = @CustId)
		begin
			set @Valid = 0
			set @Messages = N'Không tìm thấy thông tin khách hàng [' + @CustId + N']!' 
			RAISERROR (@Messages, -- Message text.
				   16, -- Severity.
				   1 -- State.
				   );
		end
		else
			 UPDATE t1
				SET CustId = @CustId
			 FROM MAS_Cards t1
			 WHERE t1.CardCd = @CardCd
			
			
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
		set @ErrorMsg					= 'sp_Hom_Card_Change ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Card', 'Update', @SessionID, @AddlInfo
	end catch