CREATE PROCEDURE [dbo].[sp_res_service_living_meter_multi_del]
    @userId NVARCHAR(450) = NULL,
    @project_code NVARCHAR(450) = NULL,
    @TrackingIds VARCHAR(MAX)
AS
BEGIN TRY
    DECLARE @valid BIT = 1;
    DECLARE @messages NVARCHAR(500) = N'Có lỗi xảy ra';
    DECLARE @successCount INT = 0;
    DECLARE @failCount INT = 0;
    DECLARE @totalCount INT = 0;
    DECLARE @failedIds NVARCHAR(MAX) = '';
    
    -- Tạo bảng tạm để lưu danh sách TrackingId
    CREATE TABLE #TempTrackingIds (
        TrackingId BIGINT
    );
    
    -- Split chuỗi TrackingIds và insert vào bảng tạm
    INSERT INTO #TempTrackingIds (TrackingId)
    SELECT CAST(value AS BIGINT)
    FROM STRING_SPLIT(@TrackingIds, ',')
    WHERE LTRIM(RTRIM(value)) <> '';
    
    SELECT @totalCount = COUNT(*) FROM #TempTrackingIds;
    
    -- Kiểm tra các TrackingId hợp lệ (chưa dự thu)
    DECLARE @CurrentTrackingId BIGINT;
    
    DECLARE tracking_cursor CURSOR FOR
    SELECT TrackingId FROM #TempTrackingIds;
    
    OPEN tracking_cursor;
    FETCH NEXT FROM tracking_cursor INTO @CurrentTrackingId;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Kiểm tra điều kiện xóa
        IF NOT EXISTS
        (
            SELECT TrackingId
            FROM [MAS_Service_Living_Tracking]
            WHERE TrackingId = @CurrentTrackingId
                  AND IsReceivable = 1
        )
        AND NOT EXISTS
        (
            SELECT *
            FROM MAS_Service_Receivable
            WHERE srcId = @CurrentTrackingId
                  AND ServiceTypeId = 3
        )
        BEGIN
            -- Thực hiện xóa
            UPDATE t
            SET AccrualToDt = a.FromDt,
                MeterLastDt = a.FromDt,
                MeterLastNum = a.FromNum
            FROM MAS_Apartment_Service_Living t
                JOIN [MAS_Service_Living_Tracking] a
                    ON a.LivingId = t.LivingId
            WHERE a.TrackingId = @CurrentTrackingId
                  AND a.IsReceivable = 0;
            
            DELETE t
            FROM MAS_Service_Living_CalSheet t
            WHERE TrackingId = @CurrentTrackingId;
            
            DELETE trg
            FROM [MAS_Service_Living_Tracking] trg
            WHERE TrackingId = @CurrentTrackingId;
            
            SET @successCount = @successCount + 1;
        END
        ELSE
        BEGIN
            -- Tracking đã được tính dự thu, không thể xóa
            SET @failCount = @failCount + 1;
            SET @failedIds = @failedIds + CAST(@CurrentTrackingId AS VARCHAR) + ', ';
        END
        
        FETCH NEXT FROM tracking_cursor INTO @CurrentTrackingId;
    END
    
    CLOSE tracking_cursor;
    DEALLOCATE tracking_cursor;
    
    -- Xóa bảng tạm
    DROP TABLE #TempTrackingIds;
    
    -- Xây dựng thông báo kết quả
    IF @failCount = 0
    BEGIN
        SET @valid = 1;
        SET @messages = N'Xóa thành công ' + CAST(@successCount AS NVARCHAR) + N'/' + CAST(@totalCount AS NVARCHAR) + N' chỉ số công tơ!';
    END
    ELSE IF @successCount = 0
    BEGIN
        SET @valid = 0;
        SET @messages = N'Tất cả các chỉ số đã được tính dự thu, không thể xóa!';
    END
    ELSE
    BEGIN
        SET @valid = 1;
        SET @failedIds = LEFT(@failedIds, LEN(@failedIds) - 1); -- Bỏ dấu phày cuối
        SET @messages = N'Xóa thành công ' + CAST(@successCount AS NVARCHAR) + N'/' + CAST(@totalCount AS NVARCHAR) 
                       + N' chỉ số. ' + CAST(@failCount AS NVARCHAR) 
                       + N' chỉ số không thể xóa (đã dự thu): ' + @failedIds;
    END
    
    SELECT @valid AS valid,
           @messages AS [messages],
           @successCount AS successCount,
           @failCount AS failCount,
           @totalCount AS totalCount;
           
END TRY
BEGIN CATCH
    -- Đóng cursor nếu còn mở
    IF CURSOR_STATUS('global','tracking_cursor') >= -1
    BEGIN
        IF CURSOR_STATUS('global','tracking_cursor') > -1
        BEGIN
            CLOSE tracking_cursor;
        END
        DEALLOCATE tracking_cursor;
    END
    
    -- Xóa bảng tạm nếu tồn tại
    IF OBJECT_ID('tempdb..#TempTrackingIds') IS NOT NULL
        DROP TABLE #TempTrackingIds;
    
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(500),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_service_living_meter_multi_del: ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = 'TrackingIds: ' + @TrackingIds;
    
    EXEC utl_Insert_ErrorLog @ErrorNum,
                             @ErrorMsg,
                             @ErrorProc,
                             'LivingTrack',
                             'DEL',
                             @SessionID,
                             @AddlInfo;
                             
    SELECT 0 AS valid,
           N'Có lỗi xảy ra: ' + ERROR_MESSAGE() AS [messages];
END CATCH;