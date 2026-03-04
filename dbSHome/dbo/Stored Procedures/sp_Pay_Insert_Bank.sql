





CREATE procedure [dbo].[sp_Pay_Insert_Bank]
		 @UserID	nvarchar(450)
		,@BankCd nvarchar(50)
		,@BankName nvarchar(150)
		,@BankShort nvarchar(100)
		,@LogoUrl nvarchar(250)
		,@IsInternal int
as
	begin try		
	declare @isbank bit
	declare @isintcard bit
	if @IsInternal = 0 
	begin
		set @isintcard = 1
		set @isbank = 0
	end
	else
	if @IsInternal = 1 
	begin
		set @isintcard = 0
		set @isbank = 1
	end
	else
	begin
		set @isintcard = 1
		set @isbank = 1
	end

	if not exists(select SourceCd from WAL_Banks where SourceCd = @BankCd)
		begin
			INSERT INTO [dbo].WAL_Banks
			   (SourceCd
			   ,SourceName
			   ,ShortName
			   ,LogoUrl
			   ,IsBank
			   ,isIntCard
			   ,SysDate
			   )
		 VALUES
			   (@BankCd
			   ,@BankName
			   ,@BankShort
			   ,@LogoUrl
			   ,@isbank
			   ,@isintcard
			   ,getdate()
			   )

		end
		ELSE
		begin
			UPDATE [dbo].WAL_Banks
			   SET SourceName = @BankName
				  ,ShortName = @BankShort
				  ,LogoUrl = @LogoUrl
				  ,IsBank = @isbank
				  ,isIntCard = @isintcard
				  ,SysDate  = Getdate()
			 WHERE SourceCd  = @BankCd
		end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Insert_Bank ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@User ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Bank', 'Insert', @SessionID, @AddlInfo
	end catch