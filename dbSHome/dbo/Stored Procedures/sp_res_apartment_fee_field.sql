CREATE PROCEDURE [dbo].[sp_res_apartment_fee_field]
    @userId UNIQUEIDENTIFIER = NULL,
    @ApartmentId INT = 84,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    --
    IF @ApartmentId IS NOT NULL
       AND NOT EXISTS
    (
        SELECT 1
        FROM dbo.MAS_Apartments
        WHERE ApartmentId = @ApartmentId
    )
        SET @ApartmentId = NULL;
    --begin
    --1 thong tin chung
    SELECT @ApartmentId id,[tableKey] = 'apartment_fee';
    --2- cac group
    SELECT 1 [group_cd],
           N'Thông tin chung' [group_name];
    --3 tung o trong group
    --exec sp_get_data_fields @cardVehicleId,'apartment_vehicle'
    SELECT s.[id],
           s.[table_name],
           s.[field_name],
           s.[view_type],
           s.[data_type],
           s.[ordinal],
           s.[columnLabel],
           s.[group_cd],
           ISNULL(   CASE [field_name]
                         WHEN 'ApartmentId' THEN
                            CONVERT(NVARCHAR(450), a.[ApartmentId])
                         WHEN 'IsReceived' THEN
                             CONVERT(NVARCHAR(500), ISNULL(a.IsReceived,0))
                         WHEN 'par_residence_type_oid' THEN
                             CONVERT(NVARCHAR(500), a.par_residence_type_oid)
                         WHEN 'ReceiveDate' THEN
                             CONVERT(NVARCHAR(10), a.ReceiveDt, 103)
                         WHEN 'IsRent' THEN
                             CONVERT(NVARCHAR(450), a.IsRent)
                         WHEN 'FeeStart' THEN
                             CONVERT(NVARCHAR(10), ISNULL(a.FeeStart, a.ReceiveDt), 103)
                         WHEN 'IsFree' THEN
                             CONVERT(NVARCHAR(450), ISNULL(a.IsFree,0))
                         WHEN 'FreeToDate' THEN
                             CONVERT(NVARCHAR(10), a.FreeToDt, 103)
                         WHEN 'FreeMonth' THEN
                             CONVERT(NVARCHAR(450), a.numFreeMonth)
                         WHEN 'FeeNote' THEN
                             a.FeeNote
                         WHEN 'isFeeStart' THEN
                             CONVERT(NVARCHAR(450), a.isFeeStart)
                         WHEN 'DebitAmt' THEN
                             CONVERT(NVARCHAR(450), a.DebitAmt)
                         WHEN 'isFeeStart' THEN
                             CONVERT(NVARCHAR(450), ISNULL(a.isFeeStart,0))
                     END,
                     [columnDefault]
                 ) AS columnValue,
           [columnClass],
           [columnType],
           [columnObject],
           [isSpecial],
           [isRequire],
           [isDisable]  = CASE WHEN a.isFeeStart = 'false' AND field_name IN('IsFree','FeeStart','FreeMonth','FreeToDate','FeeNote')
							THEN 1 
							WHEN a.isFeeStart = 'true' AND  a.IsFree = 'false' AND field_name IN('FeeStart','FreeMonth','FreeToDate')
							THEN 1
							WHEN a.isFeeStart = 'true' AND  a.IsFree = 'true' AND field_name IN('FreeToDate')
							THEN 1
							WHEN a.IsReceived = 'false' AND field_name IN('FeeNote','DebitAmt','FreeMonth','isFeeStart','IsFree','IsRent','ApartmentId','ReceiveDate','FeeStart','FreeToDate')
							THEN 1
							ELSE [s].[isDisable] END,
           s.[isVisiable],
           NULL AS [IsEmpty],
           ISNULL(s.columnTooltip, s.[columnLabel]) AS columnTooltip
           , s.[columnDisplay]
           , s.[isIgnore]
    FROM
        fn_config_form_gets('apartment_fee', @acceptLanguage) s
        JOIN [MAS_Apartments] a ON a.ApartmentId = @ApartmentId
    --WHERE s.isVisiable = 1
    ORDER BY s.ordinal;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_fee_field' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';
    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'apartment_vehicle', 'GetInfo', @SessionID, @AddlInfo;
END CATCH;