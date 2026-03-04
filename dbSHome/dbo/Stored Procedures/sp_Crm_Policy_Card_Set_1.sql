








CREATE procedure [dbo].[sp_Crm_Policy_Card_Set]
	@UserId	nvarchar(450),
	@PolicyId int,
	@CardTypeId   int,
	@MinPoint int,
	@Discount float, 
	@IsVip bit,
	@PolicyName nvarchar(255),
	@FromDate nvarchar(50),
	@ToDate  nvarchar(50)
	as 

	begin try 
		IF NOT EXISTS (Select * FROM CRM_CardPolicy where PolicyId = @PolicyId)
			INSERT INTO [dbo].[CRM_CardPolicy]
					([CardTypeId]
					,[MinPoint]
					,[Discount]
					,[IsVip]
					,[PolicyName]
					,[FromDate]
					,[ToDate])
				VALUES
					(@CardTypeId
					,@MinPoint 
					,@Discount
					,@IsVip
					,@PolicyName
					,convert(datetime,@FromDate,103)
					,convert(datetime,@ToDate,103)
					)
		ELSE
			UPDATE [dbo].[CRM_CardPolicy]
			   SET [CardTypeId] = @CardTypeId
				  ,[MinPoint] = @MinPoint
				  ,[Discount] = @Discount
				  ,[IsVip] = @IsVip
				  ,[PolicyName] = @PolicyName
				  ,[FromDate] = convert(datetime,@FromDate,103)
				  ,[ToDate] = convert(datetime,@ToDate,103)
			 WHERE PolicyId = @PolicyId
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= '[sp_Crm_Insert_Card_Policy] ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@PolicyName ' + cast(@PolicyName as nvarchar)

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Card', 'Insert', @SessionID, @AddlInfo
	end catch