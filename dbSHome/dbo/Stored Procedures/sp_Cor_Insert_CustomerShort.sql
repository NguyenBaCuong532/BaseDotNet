





CREATE procedure [dbo].[sp_Cor_Insert_CustomerShort]
	@CustId	nvarchar(50),
	@FullName nvarchar(250),
	@AvatarUrl nvarchar(250),
	@Phone nvarchar(30),	
	@Email nvarchar(150),
	@IsAccount bit
as
	begin try		
	declare @errmessage nvarchar(100)
	declare @baseCif nvarchar(20)
	set @errmessage = 'This Cust: ' + @FullName + ' is exists!'

	if SUBSTRING(@phone,1,1) <> '0'
		set @phone = '0' + @phone

	if @IsAccount = 1
	begin
		if exists(select CustId from [MAS_Contacts] where Phone = @Phone)
			RAISERROR (@errmessage, -- Message text.
				   16, -- Severity.
				   1 -- State.
				   );

		if exists(select CustId from [MAS_Customers] where Phone = @Phone)
			set @CustId = (select CustId from [MAS_Customers] where Phone = @Phone)
		else
		begin
			set @custId = newid()
			INSERT INTO [dbo].[MAS_Customers]
				   (CustId
				   ,[FullName]
				   ,[Phone]
				   ,[Email]
				   ,[AvatarUrl]
				   ,[IsSex]
				   ,IsForeign
				   ,sysDate
				   )
				VALUES
				   (@custId
				   ,@FullName
				   ,@Phone
				   ,@Email
				   ,@AvatarUrl
				   ,1
				   ,0 
				   ,getdate()
				   )
		end
		--exec [dbo].[sp_Pay_Create_New_Account] @custId, @baseCif
	end
	else
	begin
	    if exists(select CustId from [MAS_Customers] where Phone = @Phone)
			set @CustId = (select CustId from [MAS_Customers] where Phone = @Phone)
		
		if @custId is null or @custId = '' or not exists(select CustId from [MAS_Customers] where CustId = @custId)
		begin
			set @custId = newid()
	
			INSERT INTO [dbo].[MAS_Customers]
				   (CustId
				   ,[FullName]
				   ,[Phone]
				   ,[Email]
				   ,[AvatarUrl]
				   ,[IsSex]
				   ,IsForeign
				   ,sysDate
				   )
			 VALUES
				   (@custId
				   ,@FullName
				   ,@Phone
				   ,@Email
				   ,@AvatarUrl
				   ,1
				   ,0 
				   ,getdate()
				   )
		end
		else
		begin
			UPDATE t 
			SET 
			    FullName = isnull(@FullName,FullName)
			   ,Phone = isnull(@Phone,Phone)
			   ,Email = isnull(@Email,Email)
			   ,AvatarUrl = isnull(@AvatarUrl,AvatarUrl)
			FROM [MAS_Customers] t 
			WHERE t.CustId  = @CustId 
		end
	end
	
	exec sp_Cor_Get_Customer_ByCustId null, @CustId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Cor_Insert_CustomerShort ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@CustId ' + isnull(@CustId,'') + ' @fullname ' + isnull(@FullName,'') + ' @phone ' + isnull(@Phone,'') + ' @email ' + isnull(@Email ,'')

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Customer', 'Insert', @SessionID, @AddlInfo
	end catch