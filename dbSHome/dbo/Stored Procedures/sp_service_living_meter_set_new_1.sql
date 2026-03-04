create PROCEDURE [dbo].[sp_service_living_meter_set_new]
    @UserID NVARCHAR(450),
    @TrackingId INT,
    @LivingId INT,
	@MeterSerial NVARCHAR(30),
    @FromDate NVARCHAR(10),
    @ToDate NVARCHAR(10),
    @FromNum INT,
    @ToNum INT,
	@TotalNum int
AS
BEGIN TRY
    DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(100) = N'Có lỗi xảy ra';

    IF NOT EXISTS
    (
        SELECT LivingId
        FROM MAS_Apartment_Service_Living
        WHERE LivingId = @LivingId
    )
    BEGIN
        SET @valid = 0;
        SET @messages = N'Không tìm thấy công tơ';
    END;
    ELSE IF CONVERT(DATETIME, @ToDate, 103) < CONVERT(DATETIME, @FromDate, 103)
    BEGIN
        SET @valid = 0;
        SET @messages = N'Nhập ngày bị sai';
    END;
    --ELSE IF @ToNum < @FromNum
    --BEGIN
    --    SET @valid = 0;
    --    SET @messages = N'Số công tơ không được bị âm';
    --END;
	-- Trên thực tế có thể đồng hồ điện nước bị hỏng nên sẽ thay mới, số công tơ thực tế sẽ nhỏ hơn số cũ.
	-- Nhìn vào từ số, đến số và tổng số để thấy
    ELSE IF NOT EXISTS
         (
             SELECT TrackingId
             FROM MAS_Service_Living_Tracking a
                 JOIN MAS_Apartments b
                     ON a.ApartmentId = b.ApartmentId
             WHERE TrackingId = @TrackingId
         )
    BEGIN
        IF NOT EXISTS
        (
            SELECT TrackingId
            FROM MAS_Service_Living_Tracking a
                JOIN MAS_Apartments b
                    ON a.ApartmentId = b.ApartmentId
            WHERE a.LivingId = @LivingId
                  AND a.ToDt = CONVERT(DATETIME, @ToDate, 103)
        )
		BEGIN
		    INSERT INTO [dbo].[MAS_Service_Living_Tracking]
            (
                [ProjectCd],
                [ApartmentId],
                [PeriodMonth],
                [PeriodYear],
                [LivingId],
                [FromDt],
                [ToDt],
                [LivingTypeId],
                [FromNum],
                [ToNum],
                [TotalNum],
                [Amount],
                [InputType],
                [IsCalculate],
                [IsBill],
                IsReceivable,
                SysDt
            )
            SELECT d.ProjectCd,
                   a.ApartmentId,
                   MONTH(CONVERT(DATETIME, @ToDate, 103)),
                   YEAR(CONVERT(DATETIME, @ToDate, 103)),
                   b.LivingId,
                   ISNULL(CONVERT(DATETIME, @FromDate, 103), b.MeterDate),
                   CONVERT(DATETIME, @ToDate, 103),
                   b.LivingTypeId,
                   ISNULL(@FromNum, b.MeterNum),
                   @ToNum,
                   --@ToNum - ISNULL(b.MeterLastNum, b.MeterNum),
				   @TotalNum,
                   0,
                   N'Nhập tay',
                   0,
                   0,
                   0,
                   GETDATE()
            FROM MAS_Apartments a
                JOIN MAS_Apartment_Service_Living b
                    ON a.ApartmentId = b.ApartmentId
                JOIN MAS_Rooms c
                    ON a.RoomCode = c.RoomCode
                JOIN MAS_Buildings d
                    ON c.BuildingCd = d.BuildingCd
            WHERE b.LivingId = @LivingId;
			--
			SET @valid = 1;
            SET @messages = N'Cập nhật thành công'
		END
            
        ELSE
        BEGIN
            SET @valid = 0;
            SET @messages = N'Đã tồn tại không thể thêm dữ liệu';
        END;
    END;
    ELSE
    BEGIN
        --IF EXISTS
        --(
        --    SELECT ReceiveId
        --    FROM MAS_Service_Receivable
        --    WHERE ServiceTypeId = 3
        --          AND srcId = @TrackingId
        --)
        --BEGIN
        --    SET @valid = 0;
        --    SET @messages = N'Đã dự thu không thể sửa';
        --END;
        --ELSE
		BEGIN
		    UPDATE a
            SET [FromDt] = CONVERT(DATETIME, @FromDate, 103),
                [ToDt] = CONVERT(DATETIME, @ToDate, 103),
                [FromNum] = @FromNum,
                ToNum = @ToNum,
                --TotalNum = @ToNum - @FromNum,
				TotalNum = @TotalNum,
                [InputType] = N'Nhập tay',
                IsCalculate = 0
            FROM [dbo].MAS_Service_Living_Tracking a
                JOIN MAS_Apartment_Service_Living c
                    ON a.LivingId = c.LivingId
                INNER JOIN MAS_Apartments b
                    ON c.ApartmentId = b.ApartmentId
            WHERE TrackingId = @TrackingId;
			--
			SET @valid = 1;
            SET @messages = N'Cập nhật thành công'
		END
            
    END;

    IF @valid = 1
    BEGIN
        UPDATE t
        SET MeterLastNum = @ToNum,
            MeterLastDt = CONVERT(DATETIME, @ToDate, 103)
        FROM MAS_Apartment_Service_Living t
            JOIN MAS_Service_Living_Tracking b
                ON t.LivingId = b.LivingId
            JOIN MAS_Apartments c
                ON t.ApartmentId = c.ApartmentId
        WHERE t.LivingId = @LivingId;
		--
			SET @valid = 1;
            SET @messages = N'Cập nhật thành công'
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
    SET @ErrorMsg = 'sp_service_living_meter_set ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = '@UserID ' + @UserID;

    EXEC utl_Insert_ErrorLog @ErrorNum,
                             @ErrorMsg,
                             @ErrorProc,
                             'ServiceLiving',
                             'Ins',
                             @SessionID,
                             @AddlInfo;
END CATCH;