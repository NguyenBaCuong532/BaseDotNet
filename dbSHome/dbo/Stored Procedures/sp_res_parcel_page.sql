CREATE   PROCEDURE [dbo].[sp_res_parcel_page]
    @userId UNIQUEIDENTIFIER,
    @filter NVARCHAR(100) = NULL,
    @clientId NVARCHAR(50) = NULL,
    @ApartmentId INT = NULL,
    @ApartmentOid UNIQUEIDENTIFIER = NULL,
    @Status INT = NULL,
    @ParcelType NVARCHAR(50) = NULL,
    @FromDate DATETIME = NULL,
    @ToDate DATETIME = NULL,
    @gridWidth INT = 0,
    @Offset INT = 0,
    @PageSize INT = 10,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @Total   BIGINT = 0;
    DECLARE @GridKey NVARCHAR(100) = 'view_parcel_page';

    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = CASE WHEN ISNULL(@PageSize, 0) > 0 THEN @PageSize ELSE 10 END;
    SET @filter = ISNULL(@filter, '');

    IF @PageSize = 0 SET @PageSize = 10;
    IF @Offset  < 0 SET @Offset  = 0;

    -- Resolve ApartmentId from ApartmentOid if provided
    IF @ApartmentOid IS NOT NULL AND @ApartmentId IS NULL
    BEGIN
        SELECT @ApartmentId = ApartmentId
        FROM MAS_Apartments WITH (NOLOCK)
        WHERE oid = @ApartmentOid;
    END

    ----------------------------------------------------------------
    -- Total
    ----------------------------------------------------------------
    SELECT @Total = COUNT(1)
    FROM Parcel p WITH (NOLOCK)
    LEFT JOIN MAS_Apartments a WITH (NOLOCK) ON p.apartment_id = a.ApartmentId
    WHERE (@ApartmentId IS NULL OR p.apartment_id = @ApartmentId)
      AND (@Status IS NULL OR p.status = @Status)
      AND (@ParcelType IS NULL OR p.parcel_type = @ParcelType)
      AND (@FromDate IS NULL OR p.create_at >= @FromDate)
      AND (@ToDate IS NULL OR p.create_at <= @ToDate)
      AND (@filter = '' 
           OR p.parcel_code LIKE N'%' + @filter + N'%'
           OR p.sender_name LIKE N'%' + @filter + N'%'
           OR p.recipient_name LIKE N'%' + @filter + N'%');

    -- Result 1: root
    SELECT  recordsTotal   = @Total,
            recordsFiltered= @Total,
            gridKey        = @GridKey,
            valid          = 1;

    ----------------------------------------------------------------
    -- Result 2: grid config
    ----------------------------------------------------------------
    IF @Offset = 0
    BEGIN
        SELECT *
        FROM [dbo].fn_config_list_gets_lang(@GridKey, @gridWidth, @acceptLanguage)
        ORDER BY [ordinal];
    END;

    ----------------------------------------------------------------
    -- Result 3: Data
    ----------------------------------------------------------------
    SELECT  p.oid AS Oid,
            p.apartment_id AS ApartmentId,
            a.RoomCode,
            p.parcel_code AS ParcelCode,
            p.parcel_type AS ParcelType,
            CASE p.parcel_type
                WHEN 'package' THEN N'Kiện hàng'
                WHEN 'letter' THEN N'Thư'
                WHEN 'document' THEN N'Tài liệu'
                WHEN 'food' THEN N'Thực phẩm'
                ELSE N'Khác'
            END AS ParcelTypeName,
            p.sender_name AS SenderName,
            --p.sender_phone AS SenderPhone,
            --p.sender_address AS SenderAddress,
            p.recipient_name AS RecipientName,
            p.recipient_phone AS RecipientPhone,
            p.[description] AS [Description],
            p.note AS Note,
            p.status AS Status,
            CASE p.status
                WHEN 0 THEN N'Chờ nhận'
                WHEN 1 THEN N'Đã nhận'
                WHEN 2 THEN N'Đã trả lại'
                ELSE N'Không xác định'
            END AS StatusName,
            CASE p.status
                WHEN 0 THEN 'warning'
                WHEN 1 THEN 'success'
                WHEN 2 THEN 'danger'
                ELSE 'secondary'
            END AS StatusSeverity,
            p.received_by AS ReceivedBy,
            CONVERT(NVARCHAR(10), p.received_date, 103) AS ReceivedDate,
            p.received_note AS ReceivedNote,
            p.return_reason AS ReturnReason,
            CONVERT(NVARCHAR(10), p.return_date, 103) AS ReturnDate,
            p.storage_location AS StorageLocation,
            p.weight AS Weight,
            p.create_by AS CreateBy,
            CONVERT(NVARCHAR(10), p.create_at, 103) AS CreateAt,
            CONVERT(NVARCHAR(16), p.create_at, 120) AS CreateAtFull,
            p.updated_by AS UpdatedBy,
            CONVERT(NVARCHAR(10), p.updated_at, 103) AS UpdatedAt
    FROM Parcel p WITH (NOLOCK)
    LEFT JOIN MAS_Apartments a WITH (NOLOCK) ON p.apartment_id = a.ApartmentId
    WHERE (@ApartmentId IS NULL OR p.apartment_id = @ApartmentId)
      AND (@Status IS NULL OR p.status = @Status)
      AND (@ParcelType IS NULL OR p.parcel_type = @ParcelType)
      AND (@FromDate IS NULL OR p.create_at >= @FromDate)
      AND (@ToDate IS NULL OR p.create_at <= @ToDate)
      AND (@filter = '' 
           OR p.parcel_code LIKE N'%' + @filter + N'%'
           OR p.sender_name LIKE N'%' + @filter + N'%'
           OR p.recipient_name LIKE N'%' + @filter + N'%')
    ORDER BY p.create_at DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum  INT,
            @ErrorMsg  VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo  VARCHAR(MAX);

    SET @ErrorNum  = ERROR_NUMBER();
    SET @ErrorMsg  = 'sp_res_parcel_page ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo  = '';

    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'Parcel', 'GET', @SessionID, @AddlInfo;
END CATCH;