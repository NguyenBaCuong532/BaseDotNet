



CREATE procedure [dbo].[sp_Hom_Card_Loked]
	@UserID	nvarchar(450),
	@CardCd nvarchar(50),
	@Status int = 1
as
	begin try		
		set @Status = isnull(@Status,1)
		if @Status = 1
		begin
			 UPDATE t1
				SET  Card_St = 3
					,CloseDate	= getdate()
					,CloseBy	= @UserID
			 FROM MAS_Cards t1
			 WHERE t1.CardCd = @CardCd

			 UPDATE t1
				SET [Status] = 2
			FROM [MAS_Requests] t1 INNER JOIN MAS_Cards t2 on t1.RequestId = t2.RequestId 
			WHERE CardCd = @CardCd

			INSERT INTO [dbo].[MAS_CardVehicle_H]
				   ([CardVehicleId]
				   ,[AssignDate]
				   ,[CardId]
				   ,[CustId]
				   ,[VehicleNo]
				   ,[VehicleTypeId]
				   ,[VehicleName]
				   ,[VehicleColor]
				   ,[StartTime]
				   ,[EndTime]
				   ,[Status]
				   ,[ServiceId]
				   ,[RegCardVehicleId]
				   ,[RequestId]
				   ,[isVehicleNone]
				   ,[monthlyType]
				   ,[VehicleNum]
				   ,[lastReceivable]
				   ,[Mkr_Id]
				   ,[Mkr_Dt]
				   ,[Auth_id]
				   ,[Auth_Dt]
				   ,[ProjectCd]
				   ,[ApartmentId]
				   ,[Reason]
				   ,[SaveDate]
				   ,[SaveId])
			SELECT [CardVehicleId]
				  ,[AssignDate]
				  ,a.[CardId]
				  ,a.[CustId]
				  ,[VehicleNo]
				  ,a.[VehicleTypeId]
				  ,[VehicleName]
				  ,[VehicleColor]
				  ,[StartTime]
				  ,[EndTime]
				  ,[Status]
				  ,[ServiceId]
				  ,[RegCardVehicleId]
				  ,a.[RequestId]
				  ,[isVehicleNone]
				  ,[monthlyType]
				  ,[VehicleNum]
				  ,[lastReceivable]
				  ,[Mkr_Id]
				  ,[Mkr_Dt]
				  ,[Auth_id]
				  ,[Auth_Dt]
				  ,a.[ProjectCd]
				  ,a.[ApartmentId]
				  ,'Locked'
				  ,getdate()
				  ,@UserId
			  FROM [dbSHome].[dbo].[MAS_CardVehicle] a
				join MAS_Cards b on a.CardId = b.CardId
			  WHERE b.CardCd = @CardCd

			UPDATE t1
				SET [Status] = 3
				   ,locked_dt = getdate()
			FROM MAS_CardVehicle t1 INNER JOIN MAS_Cards t2 on t1.CardId = t2.CardId 
			WHERE CardCd = @CardCd

			UPDATE t
			   SET [VehicleNum] = t.VehicleNum - 1
			FROM [dbo].[MAS_CardVehicle] t join [dbo].[MAS_CardVehicle] a on t.ApartmentId = a.ApartmentId and t.VehicleTypeId = a.VehicleTypeId 
			  and t.VehicleNum > a.VehicleNum 
			WHERE t.[Status] = 1
				and exists(select cardId from MAS_Cards where CardCd = @CardCd and CardId = t.CardId) 

		end
		else
		begin 
			UPDATE t1
				SET Card_St = 1
			 FROM MAS_Cards t1
			 WHERE t1.CardCd = @CardCd

			 UPDATE t1
				SET [Status] = 1
			FROM [MAS_Requests] t1 INNER JOIN MAS_Cards t2 on t1.RequestId = t2.RequestId 
			WHERE CardCd = @CardCd

			UPDATE t1
				SET [Status] = 1
				   ,locked_dt = null
			FROM MAS_CardVehicle t1 INNER JOIN MAS_Cards t2 on t1.CardId = t2.CardId 
			WHERE CardCd = @CardCd

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

		set @AddlInfo					= '@UserID ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Card', 'Update', @SessionID, @AddlInfo
	end catch