
CREATE   PROCEDURE [dbo].[sp_res_card_vehicle_locked1]
	@UserID	nvarchar(450) = NULL,
	@CardVehicleId int,
	@Status int = 1,
	@reason nvarchar(450) = null,
	@isHardLock bit
AS
BEGIN TRY
    declare @valid bit = 0, @messages nvarchar(250)
    set @Status = isnull(@Status, 1);
	   
	----tham số @status truyền vào = 0 thì khóa, 1 thì mở
	----
	--ghi lịch sử thay đổi dữ liệu
 
		  --
		  --khóa thẻ
	----
		if @Status = 0
        begin
             -- chi khoa xe khong khoa the
           --UPDATE t1
            --SET Card_St = 3
           --FROM MAS_Cards t1 join MAS_CardVehicle t2 on t1.CardId = t2.CardId 
           --WHERE CardVehicleId = @CardVehicleId

		  --ghi lịch sử thay đổi dữ liệu
           INSERT INTO [dbo].[MAS_CardVehicle_Card_H]
           (
               [ActionType]
              ,[ActionTypeName]
              ,[CardId]
              ,[CardVehicleId]
              ,[VehicleTypeId]
              ,[VehicleNo]
              ,[Operator]
              ,[ActionTime]
              ,[Notes]
              ,[ProjectCd]
              ,[CreatedDate]
              ,[FromDate]
              ,[ToDate]
              ,[OldCardCode]
              ,[NewCardCode]
              ,[OldOwner]
              ,[NewOwner]
           )
          SELECT 
              3 -- Khóa xe
              ,N'Khóa xe'
              ,t.[CardId]
              ,t.[CardVehicleId]
              ,t.[VehicleTypeId]
              ,t.[VehicleNo]
              ,@UserId
              ,GETDATE()
              ,@reason
              ,t.[ProjectCd]
              ,GETDATE()
              ,GETDATE() -- FromDate
              ,NULL      -- ToDate
              ,c.CardCd  -- OldCardCode
              ,c.CardCd  -- NewCardCode
              ,cust.FullName -- OldOwner
              ,cust.FullName -- NewOwner
          FROM [dbSHome].[dbo].[MAS_CardVehicle] t
          INNER JOIN [dbo].[MAS_Cards] c ON t.CardId = c.CardId
          INNER JOIN [dbo].[MAS_Customers] cust ON t.CustId = cust.CustId
          WHERE t.CardVehicleId = @CardVehicleId
          UPDATE t1
          SET
              [Status] = 3
             ,locked_dt = getdate()
          FROM MAS_CardVehicle t1 --INNER JOIN MAS_Cards t2 on t1.CardId = t2.CardId 
          WHERE CardVehicleId = @CardVehicleId

		  --giảm giá trị vehicleNum tương ứng sau khi khóa
          UPDATE t
          SET [VehicleNum] = t.VehicleNum - 1
          FROM
              [dbo].[MAS_CardVehicle] t
              join [dbo].[MAS_CardVehicle] a on t.ApartmentId = a.ApartmentId and t.VehicleTypeId = a.VehicleTypeId  and t.VehicleNum > a.VehicleNum 
          WHERE
              t.[Status] = 1
              and a.CardVehicleId = @CardVehicleId
          --
          SET @valid = 1
          SET @messages = N'Khóa thẻ thành công'
        end
		else
        begin
            UPDATE t1
            SET Card_St = 1
            FROM
              MAS_Cards t1 
              join MAS_CardVehicle t2 on t1.CardId = t2.CardId 
            WHERE CardVehicleId = @CardVehicleId

            UPDATE t1
            SET
                [Status] = 1
                ,locked_dt = null
            FROM MAS_CardVehicle t1 
            WHERE CardVehicleId = @CardVehicleId

            UPDATE t
            SET [VehicleNum] = t.VehicleNum + 1
            FROM
                [dbo].[MAS_CardVehicle] t
                join [dbo].[MAS_CardVehicle] a on t.ApartmentId = a.ApartmentId and t.VehicleTypeId = a.VehicleTypeId  and t.VehicleNum >= a.VehicleNum 
            WHERE t.[Status] = 1
                and a.CardVehicleId = @CardVehicleId
                and t.CardVehicleId <> @CardVehicleId
            
             --ghi lịch sử thay đổi dữ liệu (Cập nhật ngày kết thúc khóa)
             UPDATE [dbo].[MAS_CardVehicle_Card_H]
             SET ToDate = GETDATE()
             WHERE CardVehicleId = @CardVehicleId
               AND ActionType = 3 -- Khóa xe
               AND ToDate IS NULL

            --
            SET @valid = 1
            SET @messages = N'Mở thẻ thành công'
        end
	
	--
	FINAL:
		SELECT
        @valid valid,
        @messages as [messages]
    
END TRY
BEGIN CATCH
    SELECT @messages AS [messages]
    DECLARE	@ErrorNum int, @ErrorMsg varchar(200), @ErrorProc varchar(50), @SessionID int, @AddlInfo varchar(max)

    set @ErrorNum = error_number()
    set @ErrorMsg = 'sp_res_vehicle_card_locked1' + error_message()
    set @ErrorProc = error_procedure()
    set @AddlInfo = '@Userid'  + @UserId
    exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'vehicle', 'SET', @SessionID, @AddlInfo
end catch