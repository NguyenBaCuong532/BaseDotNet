CREATE   PROCEDURE [dbo].[sp_res_parcel_fields]
    @Oid UNIQUEIDENTIFIER = NULL,
    @userId UNIQUEIDENTIFIER = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    DECLARE @group_key VARCHAR(50) = 'parcel_form_group';
    DECLARE @table_key VARCHAR(50) = 'Parcel';

    -- Result 1: Root info
    SELECT @Oid AS [Oid],
           tableKey = @table_key,
           groupKey = @group_key;

    -- Result 2: Field groups
    SELECT *
    FROM [dbo].[fn_get_field_group_lang](@group_key, @acceptLanguage)
    ORDER BY intOrder;

    -- Result 3: Field values
    IF EXISTS (SELECT 1 FROM Parcel WHERE oid = @Oid)
    BEGIN
        SELECT s.[id],
               s.[table_name],
               s.[field_name],
               s.[view_type],
               s.[data_type],
               s.[ordinal],
               s.[columnLabel],
               s.[group_cd],
               ISNULL(CASE s.[field_name]
                   WHEN 'oid' THEN LOWER(CONVERT(NVARCHAR(100), p.oid))
                   WHEN 'apartment_id' THEN CONVERT(NVARCHAR(50), p.apartment_id)
                   WHEN 'parcel_code' THEN p.parcel_code
                   WHEN 'parcel_type' THEN p.parcel_type
                   WHEN 'tracking_code' THEN p.tracking_code -- New
                   WHEN 'receive_method' THEN CONVERT(NVARCHAR(10), p.receive_method) -- New
                   WHEN 'images' THEN p.images -- New
                   WHEN 'sender_name' THEN p.sender_name
                   -- Removed: sender_phone, sender_address
                   WHEN 'recipient_name' THEN p.recipient_name
                   WHEN 'recipient_phone' THEN p.recipient_phone
                   WHEN 'description' THEN p.[description]
                   WHEN 'note' THEN p.note
                   WHEN 'status' THEN CONVERT(NVARCHAR(10), p.status)
                   WHEN 'received_by' THEN p.received_by
                   WHEN 'received_date' THEN CONVERT(NVARCHAR(10), p.received_date, 103)
                   WHEN 'received_note' THEN p.received_note
                   WHEN 'return_reason' THEN p.return_reason
                   WHEN 'return_date' THEN CONVERT(NVARCHAR(10), p.return_date, 103)
                   WHEN 'storage_location' THEN p.storage_location
                   WHEN 'weight' THEN CONVERT(NVARCHAR(20), p.weight) -- Restored
                   WHEN 'create_at' THEN CONVERT(NVARCHAR(10), p.create_at, 103)
               END, s.[columnDefault]) AS columnValue,
               s.[columnClass],
               s.[columnType],
               s.[columnObject],
               s.[isSpecial],
               s.[isRequire],
               CASE 
                   WHEN s.field_name IN ('oid', 'create_at', 'status', 'received_by', 'received_date', 'return_reason', 'return_date') 
                   THEN 1 
                   ELSE s.[isDisable] 
               END AS [isDisable],
               s.[isVisiable],
               NULL AS [IsEmpty],
               ISNULL(s.columnTooltip, s.[columnLabel]) AS columnTooltip
               , s.[columnDisplay]
               , s.[isIgnore]
        FROM fn_config_form_gets(@table_key, @acceptLanguage) s
        CROSS JOIN Parcel p
        WHERE p.oid = @Oid
        ORDER BY s.ordinal;
    END
    ELSE
    BEGIN
        -- New record - return default values
        SELECT s.[id],
               s.[table_name],
               s.[field_name],
               s.[view_type],
               s.[data_type],
               s.[ordinal],
               s.[columnLabel],
               s.[group_cd],
               CASE 
                   WHEN s.field_name = 'status' THEN '0'
                   WHEN s.field_name = 'create_at' THEN CONVERT(NVARCHAR(10), GETDATE(), 103)
                   ELSE s.columnDefault
               END AS columnValue,
               s.[columnClass],
               s.[columnType],
               s.[columnObject],
               s.[isSpecial],
               s.[isRequire],
               s.[isDisable],
               s.[isVisiable],
               NULL AS [IsEmpty],
               ISNULL(s.columnTooltip, s.[columnLabel]) AS columnTooltip
               , s.[columnDisplay]
               , s.[isIgnore]
        FROM fn_config_form_gets(@table_key, @acceptLanguage) s
        ORDER BY s.ordinal;
    END

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_parcel_fields ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'Parcel',
                          'GetInfo',
                          @SessionID,
                          @AddlInfo;
END CATCH;