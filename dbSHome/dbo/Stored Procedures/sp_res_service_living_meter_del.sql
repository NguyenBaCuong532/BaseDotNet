
CREATE PROCEDURE [dbo].[sp_res_service_living_meter_del]
    @userId NVARCHAR(450),
    @TrackingId BIGINT
AS
BEGIN TRY
    DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(200) = N'Có lỗi xảy ra';
    DECLARE @errmessage NVARCHAR(100);
    SET @errmessage = N'This Living_racking: ' + CAST(@TrackingId AS VARCHAR) + N' is Accrual!';
    IF NOT EXISTS
    (
        SELECT TrackingId
        FROM [MAS_Service_Living_Tracking]
        WHERE TrackingId = @TrackingId
              AND IsReceivable = 1
    )
       AND NOT EXISTS
    (
        SELECT *
        FROM MAS_Service_Receivable
        WHERE srcId = @TrackingId
              AND ServiceTypeId = 3
    )
    BEGIN
        UPDATE t
        SET AccrualToDt = a.FromDt,
            MeterLastDt = a.FromDt,
            MeterLastNum = a.FromNum
        FROM MAS_Apartment_Service_Living t
            JOIN [MAS_Service_Living_Tracking] a
                ON a.LivingId = t.LivingId
        WHERE TrackingId = @TrackingId
              AND IsReceivable = 0;


        DELETE t
        FROM MAS_Service_Living_CalSheet t
        WHERE TrackingId = @TrackingId;

        DELETE trg
        FROM [MAS_Service_Living_Tracking] trg
        WHERE TrackingId = @TrackingId;
        --
        SET @valid = 1;
        SET @messages = N'Xóa chỉ số công tơ thành công!';
    END;
    ELSE
    BEGIN
        SET @valid = 0;
        SET @messages = N'Chỉ số đo đã được tính dự thu, không thẻ xóa';
    --RAISERROR (@errmessage, -- Message text.
    --	   16, -- Severity.
    --	   1 -- State.
    --	   );
    END;

    SELECT @valid AS valid,
           @messages AS [messages];

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_service_living_meter_del' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = '';

    EXEC utl_Insert_ErrorLog @ErrorNum,
                             @ErrorMsg,
                             @ErrorProc,
                             'LivingTrack',
                             'DEL',
                             @SessionID,
                             @AddlInfo;
END CATCH;