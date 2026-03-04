CREATE   PROCEDURE [dbo].[sp_res_apartment_service_cut_history_set]
    @UserID NVARCHAR(50),
    @Id NVARCHAR(50),
    @ApartmentId BIGINT,
    @CutType INT,
    @CutStartDate NVARCHAR(50),
    @CutEndDate NVARCHAR(50),
    @Reason NVARCHAR(1000)
AS
BEGIN TRY

    DECLARE @valid BIT = 0,
            @messages NVARCHAR(250) = N'Có lỗi xảy ra';
   -- Convert sang datetime để so sánh
    DECLARE @StartDate DATETIME = CONVERT(DATETIME, @CutStartDate, 103);
    DECLARE @EndDate   DATETIME = CONVERT(DATETIME, @CutEndDate, 103);

    -- ==============================
    --  CHECK NGÀY HỢP LỆ
    -- ==============================
    IF (@StartDate > @EndDate)
    BEGIN
        SET @messages = N'Ngày bắt đầu không được lớn hơn ngày kết thúc';
        SELECT 0 AS valid, @messages AS messages;
        RETURN;
    END

   -- ==============================
    --  CHECK TRÙNG NGÀY Y HỆT (chỉ so đến phút)
    -- ==============================
    DECLARE @StartDateTrim DATETIME = DATEADD(MINUTE, DATEDIFF(MINUTE, 0, @StartDate), 0);
    DECLARE @EndDateTrim   DATETIME = DATEADD(MINUTE, DATEDIFF(MINUTE, 0, @EndDate), 0);

    IF EXISTS (
        SELECT 1
        FROM MAS_Service_Cut_History
        WHERE CutType = @CutType
          AND ( @Id IS NULL OR Id <> @Id )     -- tránh chính nó lúc update
          AND DATEADD(MINUTE, DATEDIFF(MINUTE, 0, CutStartDate), 0) = @StartDateTrim
          AND DATEADD(MINUTE, DATEDIFF(MINUTE, 0, CutEndDate), 0)   = @EndDateTrim
          AND ApartmentId = @ApartmentId
    )
    BEGIN
        SET @messages = N'Lịch cắt điện nước đã tồn tại';
        SELECT 0 AS valid, @messages AS messages;
        RETURN;
    END;

    -- ==============================
    --  CHECK TRÙNG KHOẢNG THỜI GIAN (OVERLAP)
    -- ==============================
    IF EXISTS (
        SELECT 1
        FROM MAS_Service_Cut_History
        WHERE CutType = @CutType
          AND ( @Id IS NULL OR Id <> @Id )
          AND (
                @StartDateTrim <= DATEADD(MINUTE, DATEDIFF(MINUTE, 0, CutEndDate), 0)
            AND @EndDateTrim   >= DATEADD(MINUTE, DATEDIFF(MINUTE, 0, CutStartDate), 0)
          )
          AND ApartmentId = @ApartmentId
    )
    BEGIN
        SET @messages = N'Khoảng thời gian cắt đã trùng với lịch hiện tại';
        SELECT 0 AS valid, @messages AS messages;
        RETURN;
    END;

    BEGIN
        IF NOT EXISTS
        (
            SELECT 1
            FROM MAS_Service_Cut_History a
            WHERE id = @id
        )
        BEGIN		
            INSERT INTO [dbo].[MAS_Service_Cut_History]
            (
                Id,
                ApartmentId,
                CutType,
                CutStartDate,
                CutEndDate,
                Reason,
                SysDate
            )
            VALUES
            (
                newid(),
                @ApartmentId,
                @CutType,
                @StartDate,
                @EndDate,
                @Reason,
                GetDate()
            );
            SET @valid = 1;
            SET @messages = N'Thêm mới thành công';
        END;
        ELSE
        BEGIN
            UPDATE [dbo].[MAS_Service_Cut_History]
            SET ApartmentId = @ApartmentId,
                CutType = @CutType,
                CutStartDate = @StartDate, 
                CutEndDate = @EndDate,
                Reason = @Reason
            WHERE Id = @Id
            SET @valid = 1;
            SET @messages = N'Cập nhật thành công';
        END;

    END;
    FINAL:
    SELECT @valid valid,
           @messages AS [messages];

END TRY
BEGIN CATCH
    SELECT @messages AS [messages];
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_service_cut_history_set' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = '@userId' + @UserID;

    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'MAS_Service_Cut_History',
                          'Set',
                          @SessionID,
                          @AddlInfo;
END CATCH;