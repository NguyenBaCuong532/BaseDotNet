







CREATE procedure [dbo].[sp_Hom_Card_LogReader_Set]
	@StationId int,
	@CardCd nvarchar(50),
	@userId nvarchar(50) = null
	--@cardId bigint = 0
	
as
	begin try	
		if @StationId is not null
			INSERT INTO [dbo].[TRS_LogReader]
				   ([StationId]
				   ,[CardId]
				   ,[LogDt]
				   ,UserId)
			 SELECT
				    @StationId
				   ,CardId
				   ,getdate()
				   ,@userId
			FROM MAS_Cards 
			WHERE CardCd = @CardCd 

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Card_LogReader_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@CardCd ' + @CardCd + ' @StationId: ' + cast(isnull(@StationId,0) as varchar)

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'LogReader', 'Set', @SessionID, @AddlInfo
	end catch