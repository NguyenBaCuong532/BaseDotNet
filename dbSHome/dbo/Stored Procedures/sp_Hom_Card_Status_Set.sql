




CREATE procedure [dbo].[sp_Hom_Card_Status_Set]
	@UserId	nvarchar(450),
	@CardCd nvarchar(50),
	@ServiceId int,
	@Status int,
	@Id int = 0 

as
	begin try	
	set @Id = isnull(@Id,0)
		
	if @Status = 1
		UPDATE t
		   SET [IsLock] = 0
			  ,[LockDt] = getdate()
		FROM [dbo].[MAS_CardService] t 
			INNER JOIN MAS_Cards t2 ON t.CardId = t2.CardId
		 WHERE ServiceId = @ServiceId and t2.CardCd = @CardCd
	else
		UPDATE t
		   SET [IsLock] = 1
			  ,[LockDt] = getdate()
		FROM [dbo].[MAS_CardService] t 
			INNER JOIN MAS_Cards t2 ON t.CardId = t2.CardId
		 WHERE ServiceId = @ServiceId and t2.CardCd = @CardCd

	if @Id = 0 
	begin
		if @ServiceId = 5 or @ServiceId = 6 
		 UPDATE t1
			SET [Status] = @Status
			FROM MAS_CardVehicle t1 
				inner join MAS_Cards t2 on t1.CardId = t2.CardId 
			WHERE ServiceId = @ServiceId and t2.CardCd = @CardCd 
		else if @ServiceId = 14
			UPDATE t1
				SET [Status] = @Status
				FROM MAS_CardCredit t1 
					inner join MAS_Cards t2 on t1.CardId = t2.CardId 
				WHERE t2.CardCd = @CardCd
		else
			UPDATE t1
				SET [Status] = @Status
				FROM TRS_RegServiceExtend t1 
					inner join MAS_Cards t2 on t1.CardId = t2.CardId
				WHERE t2.CardCd = @CardCd and [ServiceId] = @ServiceId
	end
	else
	begin
		if @Status = 1
		begin
			if @ServiceId = 5 or @ServiceId = 6 
			 UPDATE t1
				SET [Status] = 1
				FROM MAS_CardVehicle t1 
				WHERE CardVehicleId = @Id
			else if @ServiceId = 14
				UPDATE t1
					SET [Status] = 1
					FROM MAS_CardCredit t1 
					WHERE Id = @Id
			else
				UPDATE t1
					SET [Status] = 1
					FROM TRS_RegServiceExtend t1 
					WHERE Id = @Id and [ServiceId] = @ServiceId
		end
		else
		begin
			if @ServiceId = 5 or @ServiceId = 6 
			 UPDATE t1
				SET [Status] = 3
				FROM MAS_CardVehicle t1 
				WHERE CardVehicleId = @Id
			else if @ServiceId = 14
				UPDATE t1
					SET [Status] = 3
					FROM MAS_CardCredit t1 
					WHERE Id = @Id
			else
				UPDATE t1
					SET [Status] = 3
					FROM TRS_RegServiceExtend t1 
					WHERE Id = @Id and [ServiceId] = @ServiceId

		end
	end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Update_CardLost ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID '  

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Card', 'Update', @SessionID, @AddlInfo
	end catch