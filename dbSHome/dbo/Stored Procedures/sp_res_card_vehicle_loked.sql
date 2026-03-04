CREATE PROCEDURE [dbo].[sp_res_card_vehicle_loked]
	@UserID	nvarchar(450) = NULL,
	@CardVehicleId int,
	@Status int = 1,
	@cardVehicleOid UNIQUEIDENTIFIER = NULL
AS
BEGIN TRY
    IF @cardVehicleOid IS NOT NULL
        SET @CardVehicleId = (SELECT CardVehicleId FROM MAS_CardVehicle WHERE oid = @cardVehicleOid);
    declare @valid bit = 0, @messages nvarchar(250)
    set @Status = isnull(@Status, 1);
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
          SET
              [Status] = 3
             ,locked_dt = getdate()
          FROM MAS_CardVehicle t1 --INNER JOIN MAS_Cards t2 on t1.CardId = t2.CardId 
          WHERE CardVehicleId = @CardVehicleId

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
    set @ErrorMsg = 'sp_res_vehicle_card_loked' + error_message()
    set @ErrorProc = error_procedure()
    set @AddlInfo = '@Userid'  + @UserId
    exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'vehicle', 'SET', @SessionID, @AddlInfo
end catch