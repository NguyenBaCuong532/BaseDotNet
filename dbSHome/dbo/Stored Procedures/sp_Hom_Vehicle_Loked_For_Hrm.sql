



create procedure [dbo].[sp_Hom_Vehicle_Loked_For_Hrm]
	@UserID	nvarchar(450),
	@CardVehicleId int,
	@Status int = 1
as
	begin try	
		declare @valid bit = 0
		declare @messages nvarchar(200) = ''
		set @Status = isnull(@Status,1)
		DECLARE @VehicleTypeId NVARCHAR(450) = (
				SELECT TOP 1 VehicleTypeId
				FROM [MAS_CardVehicle]
				WHERE CardVehicleId = @CardVehicleId
				)

		DECLARE @CardId NVARCHAR(450) = (
				SELECT TOP 1 CardId
				FROM [MAS_CardVehicle]
				WHERE CardVehicleId = @CardVehicleId
				)
		if @Status = 1
		begin
		     -- chi khoa xe khong khoa the
			 --UPDATE t1
				--SET Card_St = 3
			 --FROM MAS_Cards t1 join MAS_CardVehicle t2 on t1.CardId = t2.CardId 
			 --WHERE CardVehicleId = @CardVehicleId

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
				  ,'Locked'
				  ,getdate()
				  ,@UserId
			  FROM [dbSHome].[dbo].[MAS_CardVehicle]
			  WHERE cardVehicleId = @cardVehicleId 

			UPDATE t1
				SET [Status] = 3
				   ,locked_dt = getdate()
			FROM MAS_CardVehicle t1 --INNER JOIN MAS_Cards t2 on t1.CardId = t2.CardId 
			WHERE CardVehicleId = @CardVehicleId

			UPDATE t
			   SET [VehicleNum] = t.VehicleNum - 1
			FROM [dbo].[MAS_CardVehicle] t join [dbo].[MAS_CardVehicle] a on t.ApartmentId = a.ApartmentId and t.VehicleTypeId = a.VehicleTypeId 
			  and t.VehicleNum > a.VehicleNum 
				WHERE t.[Status] = 1
					and a.CardVehicleId = @CardVehicleId
			SET @valid = 1
			SET @messages = N'Khóa thẻ thành công!'
		end
		else
		begin
			IF EXISTS (
					SELECT 1
					FROM [mas_CardVehicle]
					WHERE VehicleTypeId = @VehicleTypeId
						AND ([Status] = 1 OR Status = 0)
						AND CardId = @CardId
					)
			BEGIN

				SET @valid = 0
				SET @messages = N'Không thể mở khóa, khi có cùng 1 loại xe đang hoạt động!'
				GOTO FINAL
			END
				 
			UPDATE t1
				SET Card_St = 1
			 FROM MAS_Cards t1 
				join MAS_CardVehicle t2 on t1.CardId = t2.CardId 
			 WHERE CardVehicleId = @CardVehicleId

			UPDATE t1
				SET [Status] = 1
				   ,locked_dt = null
			FROM MAS_CardVehicle t1 
			WHERE CardVehicleId = @CardVehicleId

			UPDATE t
			   SET [VehicleNum] = t.VehicleNum + 1
			FROM [dbo].[MAS_CardVehicle] t join [dbo].[MAS_CardVehicle] a on t.ApartmentId = a.ApartmentId and t.VehicleTypeId = a.VehicleTypeId 
			  and t.VehicleNum >= a.VehicleNum 
				WHERE t.[Status] = 1
					and a.CardVehicleId = @CardVehicleId
					and t.CardVehicleId <> @CardVehicleId
			SET @valid = 1
			SET @messages = N' Mở khóa thẻ thành công!'

		end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Update_VehicleLoked ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'VehicleLoked', 'Update', @SessionID, @AddlInfo
	end catch
	FINAL:
	select @valid as valid
		  ,@messages as [messages]