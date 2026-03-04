CREATE PROCEDURE [dbo].[sp_res_service_expected_extend_page]
    @UserId UNIQUEIDENTIFIER,
    @project_code NVARCHAR(50) = NULL,
    @receiveId INT = 0,
    @filter NVARCHAR(30) = NULL,
    @gridWidth INT = 0,
    @Offset INT = 0,
    @PageSize INT = 10,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
    --@Total INT = 0 OUT,
    --@TotalFiltered INT = 0 OUT
AS
BEGIN TRY
	declare @Total		bigint
	declare @GridKey	nvarchar(100) = 'view_service_expected_extend_page'

    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @Total = ISNULL(@Total, 0);
    SET @filter = ISNULL(@filter, '');

    IF @PageSize = 0
        SET @PageSize = 10;
    IF @Offset < 0
        SET @Offset = 0;

    
    SELECT @Total = COUNT(a.[ReceivableId])
    FROM [MAS_Service_Receivable] a
    WHERE a.ReceiveId = @receiveId
          AND ServiceTypeId = 8;

    --root	
	select recordsTotal = @Total
		  ,recordsFiltered = @Total
		  ,gridKey = @GridKey
		  ,valid = 1
    --grid config
    IF @Offset = 0
    BEGIN
        SELECT *
        FROM [dbo].fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
        ORDER BY [ordinal];
    END

    SELECT [ReceivableId],
           [ReceiveId],
           [ServiceTypeId],
           [ServiceObject],
           [Amount],
           [VatAmt],
           [TotalAmt],
           convert(nvarchar(10),[fromDt],103) as fromDt,
           convert(nvarchar(10),[ToDt],103) as ToDate,
           [srcId]
    FROM [MAS_Service_Receivable] a
    WHERE a.ReceiveId = @receiveId
          AND ServiceTypeId = 8;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_service_expected_extend_get ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = ' ';

    EXEC utl_Insert_ErrorLog @ErrorNum,
                             @ErrorMsg,
                             @ErrorProc,
                             'ServiceExpecteExtend',
                             'GET',
                             @SessionID,
                             @AddlInfo;
END CATCH;