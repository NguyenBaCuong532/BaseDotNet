CREATE PROCEDURE [dbo].[sp_res_service_expected_del]
    @userId NVARCHAR(450),
    @ReceivableId BIGINT
AS
BEGIN TRY
    DECLARE @valid BIT = 0;
	DECLARE @trackingid NVARCHAR(450); --duongvt
    DECLARE @messages NVARCHAR(200) = N'Có lỗi xảy ra';
    DECLARE @errmessage NVARCHAR(100);
    SET @errmessage = N'This Receivable: ' + CAST(@ReceivableId AS VARCHAR) + N' is Receipted!';
    DECLARE @ReceiveId BIGINT;
    SELECT @ReceiveId = ReceiveId
    FROM MAS_Service_Receivable
    WHERE ReceivableId = @ReceivableId;

	SELECT @trackingid = srcId FROM dbo.MAS_Service_Receivable WHERE ReceivableId = @ReceivableId
    IF EXISTS
    (
        SELECT ReceivableId
        FROM MAS_Service_Receivable
        WHERE ReceivableId = @ReceivableId
    )
       AND NOT EXISTS
    (
        SELECT *
        FROM MAS_Service_ReceiveEntry
        WHERE ReceiveId = @ReceiveId
              AND
              (
                  IsPayed = 1
                  --OR IsBill = 1
              )
    )
    BEGIN
        DELETE t
        FROM MAS_Service_Receivable t
        WHERE ReceivableId = @ReceivableId;

		--duongvt
		UPDATE dbo.MAS_Service_Living_Tracking
		SET IsReceivable='True'
		WHERE TrackingId= @trackingid

        UPDATE t
        SET 
			--CommonFee =
   --         (
   --             SELECT SUM(TotalAmt)
   --             FROM [MAS_Service_Receivable]
   --             WHERE [ReceiveId] = @ReceiveId
   --                   AND ServiceTypeId = 1
   --         ),
            t.VehicleAmt =
            (
                SELECT SUM(TotalAmt)
                FROM [MAS_Service_Receivable]
                WHERE [ReceiveId] = @ReceiveId
                      AND ServiceTypeId = 2
            ),
            t.LivingAmt =
            (
                SELECT SUM(TotalAmt)
                FROM [MAS_Service_Receivable]
                WHERE [ReceiveId] = @ReceiveId
                      AND
                      (
                          ServiceTypeId = 3
                          OR ServiceTypeId = 4
                      )
            ),
            --ExtendAmt =
            --(
            --    SELECT SUM(TotalAmt)
            --    FROM [MAS_Service_Receivable]
            --    WHERE [ReceiveId] = @ReceiveId
            --          AND ServiceTypeId = 8
            --),
            t.TotalAmt =  (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = @ReceiveId) + ISNULL(msr.DebitAmt,0)           
		FROM MAS_Service_ReceiveEntry t
		OUTER APPLY
				(
					SELECT TOP 1 a.DebitAmt
					FROM MAS_Service_ReceiveEntry e
					JOIN dbo.MAS_Apartments a ON a.ApartmentId = e.ApartmentId
					WHERE e.ReceiveId = @ReceiveId 
					  AND e.IsPayed = 0 
					  AND e.PaidAmt = 0
				) msr
        WHERE IsPayed = 0
              AND ReceiveId = @ReceiveId;

        SET @messages = N'Xóa dự thu thành công';
        SET @valid = 1;

    END;
    ELSE
    BEGIN
        SET @messages = N'Hóa đơn đã được thanh toán. Không được xóa ';
    --RAISERROR (@errmessage, -- Message text.
    --		   16, -- Severity.
    --		   1 -- State.
    --		   );
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
    SET @ErrorMsg = 'sp_res_service_expected_del' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = '';

    EXEC utl_Insert_ErrorLog @ErrorNum,
                             @ErrorMsg,
                             @ErrorProc,
                             'service_expected',
                             'DEL',
                             @SessionID,
                             @AddlInfo;
END CATCH;