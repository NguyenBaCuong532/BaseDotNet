-- =============================================
-- Author:		NamHM
-- Create date: 24/06/2025
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_log_transaction_bank_set] 
	-- Add the parameters for the stored procedure here
	@userId nvarchar(50) = null,
	@Type varchar(MAX) = NULL, 
	@HeaderRequest varchar(MAX) = NULL,
	@Request varchar(MAX) = NULL,
	@CreatedAt datetime = NULL
AS
	begin try
        declare @valid bit = 1
        declare @messages nvarchar(100) = N'Lưu thành công!' 

 SET @CreatedAt = ISNULL(@CreatedAt, GETDATE());
				INSERT INTO [dbo].[Log_transaction_bank]
						   ([Type]
						   ,[HeaderRequest]
						   ,[Request]
						   ,[createDt])
					 VALUES
						   (@Type
						   ,@HeaderRequest
						   ,@Request
						   ,@CreatedAt)
	

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_log_transaction_bank_set' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' - @userId '

		EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'agency_chat_room', 'Insert', @SessionID, @AddlInfo
	end catch
    FINAL:
	    select @valid as valid
		       ,@messages as [messages]