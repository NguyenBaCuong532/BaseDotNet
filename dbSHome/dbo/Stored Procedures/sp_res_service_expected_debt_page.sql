CREATE PROCEDURE [dbo].[sp_res_service_expected_debt_page]
    @UserId UNIQUEIDENTIFIER = null,
    @project_code NVARCHAR(50) = NULL,
    @ProjectCd int =null,
    @ReceiveId INT = 193813,
    @filter NVARCHAR(30) = NULL,
    @gridWidth INT = 0,
    @Offset INT = 0,
    @PageSize INT = 10,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    declare @Total		bigint
    declare @GridKey	nvarchar(100) = 'view_service_expected_debt_page'

    declare @ApartmentId int 

    set @ApartmentId = (select top 1 ApartmentId from MAS_Service_ReceiveEntry where ReceiveId = @receiveId)

    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @Total = ISNULL(@Total, 0);
    SET @filter = ISNULL(@filter, '');

    IF @PageSize = 0
        SET @PageSize = 10;
        
    IF @Offset < 0
        SET @Offset = 0;  
        
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

    SELECT 
        SUM(CASE WHEN a.ServiceTypeId = 1 THEN ISNULL(a.TotalAmt,0) ELSE 0 END) AS ServiceFee,
        SUM(CASE WHEN a.ServiceTypeId = 2 THEN ISNULL(a.TotalAmt,0) ELSE 0 END) AS ParkingFee,
        SUM(CASE WHEN a.ServiceTypeId = 3 THEN ISNULL(a.TotalAmt,0) ELSE 0 END) AS ElectricityFee,
        SUM(CASE WHEN a.ServiceTypeId = 4 THEN ISNULL(a.TotalAmt,0) ELSE 0 END) AS WaterFee,
        SUM(ISNULL(a.TotalAmt,0)) AS Total
    FROM MAS_Service_Receivable a
    WHERE
        a.ReceiveId IN (SELECT re.ReceiveId
                        FROM MAS_Service_ReceiveEntry re
                        WHERE
                            re.ApartmentId = @ApartmentId
                            AND re.IsDebt = 1)
        AND (a.IsPaid = 0 OR a.IsPaid IS NULL);

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_service_expected_debt_page ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = ' ';

    EXEC utl_Insert_ErrorLog @ErrorNum,
                             @ErrorMsg,
                             @ErrorProc,
                             'ServiceExpecteDebt',
                             'GET',
                             @SessionID,
                             @AddlInfo;
END CATCH;