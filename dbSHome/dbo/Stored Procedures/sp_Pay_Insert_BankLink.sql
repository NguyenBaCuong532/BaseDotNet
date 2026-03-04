






CREATE procedure [dbo].[sp_Pay_Insert_BankLink]
		 @UserID	nvarchar(450)
		,@LinkId int
		,@SourceCd nvarchar(50)
		,@TranferCd nvarchar(50)
		,@IsInternal int
	
as
	begin try		
	
	if not exists(select SourceCd from [WAL_BankLinked] where LinkId = @LinkId)
		begin
			INSERT INTO [dbo].[WAL_BankLinked]
				   ([TranferCd]
				   ,[SourceCd]
				   ,[LinkDt])
			 VALUES
				   (@TranferCd
				   ,@SourceCd
				   ,getdate()
				   )

		end
		ELSE
		begin
			UPDATE [dbo].[WAL_BankLinked]
			   SET [TranferCd] = @TranferCd
				  ,[SourceCd] = @SourceCd
			 WHERE LinkId  = @LinkId
		end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Insert_BankLink ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@User ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'BankLink', 'Insert', @SessionID, @AddlInfo
	end catch