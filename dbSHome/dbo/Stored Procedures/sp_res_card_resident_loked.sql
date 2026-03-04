
CREATE procedure [dbo].[sp_res_card_resident_loked]
	@UserID	nvarchar(450),
	@CardVehicleId int,
	@Status int = 1
as
	begin try	
		declare @valid bit = 0
		declare @messages nvarchar(200) = ''
		set @Status = isnull(@Status,1)
		
        -- 1. Retrieve Info
        DECLARE @VehicleTypeId INT
        DECLARE @CardId INT
        DECLARE @CardCd NVARCHAR(50), @CustId NVARCHAR(50), @OwnerName NVARCHAR(200), @ProjectCd NVARCHAR(30)
        DECLARE @VehicleNo NVARCHAR(16), @VehicleTypeName NVARCHAR(100)

        SELECT TOP 1 
            @VehicleTypeId = cv.VehicleTypeId,
            @CardId = cv.CardId,
            @CardCd = c.CardCd,
            @CustId = cv.CustId,
            @OwnerName = cust.FullName,
            @ProjectCd = cv.ProjectCd,
            @VehicleNo = cv.VehicleNo,
            @VehicleTypeName = vt.VehicleTypeName
        FROM [MAS_CardVehicle] cv WITH (NOLOCK)
        INNER JOIN MAS_Cards c WITH (NOLOCK) ON cv.CardId = c.CardId
        LEFT JOIN MAS_Customers cust WITH (NOLOCK) ON cv.CustId = cust.CustId
        LEFT JOIN MAS_VehicleTypes vt WITH (NOLOCK) ON cv.VehicleTypeId = vt.VehicleTypeId
        WHERE cv.CardVehicleId = @CardVehicleId

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
			  FROM [dbo].[MAS_CardVehicle]
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

            -- New Insert for History (Lock Vehicle)
            INSERT INTO MAS_CardVehicle_Card_H (
                ActionType,
                ActionTypeName,
                CardId,
                CardVehicleId,
                FromDate,
                ToDate, 
                VehicleTypeId,
                VehicleTypeName,
                VehicleNo,
                OldCardCode,
                NewCardCode,
                OldOwner,
                NewOwner,
                OldOwnerCustId,
                NewOwnerCustId,
                Operator,
                ActionTime,
                Notes,
                ProjectCd,
                CreatedDate
            ) VALUES (
                3, -- ActionType: 3 = Khóa xe
                N'Khóa xe',
                @CardId,
                @CardVehicleId,
                GETDATE(),
                NULL,
                @VehicleTypeId,
                @VehicleTypeName,
                @VehicleNo,
                @CardCd,
                @CardCd,
                @OwnerName,
                @OwnerName,
                @CustId,
                @CustId,
                @UserId,
                GETDATE(),
                N'Khóa xe qua HRM',
                @ProjectCd,
                GETDATE()
            )

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

            -- Update History for Unlock (Close the vehicle lock interval)
            UPDATE MAS_CardVehicle_Card_H
            SET ToDate = GETDATE()
            WHERE CardVehicleId = @CardVehicleId 
              AND ActionType = 3 -- Khóa xe
              AND ToDate IS NULL

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