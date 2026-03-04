








CREATE procedure [dbo].[sp_Hom_Insert_SationReader]
	@StationId int,
	@StationCd nvarchar(50),
	@StationName nvarchar(100),
	@ServiceId int
as
	begin try		
		
		IF @StationId is null OR @StationId = 0 
			INSERT INTO [dbo].[MAS_StationReader]
				   ([StationCd]
				   ,[StationName]
				   ,[ServiceId]
				   ,[StartDate]
				   ,[Status])
			 VALUES
				   (@StationCd
				   ,@StationName
				   ,@ServiceId
				   ,getdate()
				   ,1)
		ELSE
			UPDATE [dbo].[MAS_StationReader]
			SET [StationCd] = @StationCd
			  ,[StationName] = @StationName
			  ,[ServiceId] = @ServiceId
			  ,[StartDate] = getdate()
			  --,[Status] = @Status
			WHERE StationId = @StationId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Insert_RequestFix ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@NotiId ' 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'RequestFix', 'Insert', @SessionID, @AddlInfo
	end catch