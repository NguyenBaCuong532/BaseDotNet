CREATE PROCEDURE [dbo].[sp_res_service_expected_fee_page_new]
    @UserId UNIQUEIDENTIFIER = null,
    @project_code NVARCHAR(50) = NULL,
    @receiveId INT = 141544,
    @filter NVARCHAR(30) = NULL,
    @gridWidth INT = 0,
    @Offset INT = 0,
    @PageSize INT = 10,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
    --@Total INT= 0 OUT ,
    --@TotalFiltered INT = 0 OUT
AS
BEGIN TRY
	declare @Total		bigint
	declare @GridKey	nvarchar(100) = 'view_service_expected_fee_page'

    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @Total = ISNULL(@Total, 0);
    SET @filter = ISNULL(@filter, '');

    IF @PageSize = 0
        SET @PageSize = 10;
    IF @Offset < 0
        SET @Offset = 0;

    
    SELECT @Total = COUNT(a.[ReceivableId])
    FROM
        [MAS_Service_Receivable] a
        JOIN MAS_Apartments b ON a.srcId = b.ApartmentId
    WHERE
        a.ReceiveId = @receiveId
        AND ServiceTypeId = 1;

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
    END;

    SELECT [ReceivableId],
           [ReceiveId],
           [ServiceObject],
           a.Quantity,
           a.Price,
           [Amount],
           [VatAmt],
           [TotalAmt],
           b.ApartmentId,
           b.WaterwayArea,
           CONVERT(NVARCHAR(10), a.fromDt, 103) AS fromDt,
           CONVERT(NVARCHAR(10), a.ToDt, 103) AS toDt,
           b.RoomCode
    FROM
        [MAS_Service_Receivable] a
        JOIN MAS_Apartments b ON a.srcId = b.ApartmentId
    WHERE
        a.ReceiveId = @receiveId
        AND ServiceTypeId = 1;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_service_expected_fee_get ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = ' ';

    EXEC utl_Insert_ErrorLog @ErrorNum,
                             @ErrorMsg,
                             @ErrorProc,
                             'ServiceExpectedFee',
                             'GET',
                             @SessionID,
                             @AddlInfo;
END CATCH;