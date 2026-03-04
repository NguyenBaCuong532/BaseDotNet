CREATE PROCEDURE [dbo].[sp_res_service_expected_vehicle_page]
    @UserId UNIQUEIDENTIFIER = null,
    @ProjectCd int =null,
    @ReceiveId INT = 150651,
    @filter NVARCHAR(30) = NULL,
    @gridWidth INT = 0,
    @Offset INT = 0,
    @PageSize INT = 10,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
 --   @Total INT = 0 OUT,
 --   @TotalFiltered INT = 0 OUT,
	--@GridKey		nvarchar(100) out
AS
BEGIN TRY
	declare @Total		bigint
	declare @GridKey	nvarchar(100) = 'view_service_expected_vehicle_page'

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
        join MAS_CardVehicle b on a.srcId = b.CardVehicleId
        join MAS_VehicleTypes c on b.VehicleTypeId = c.VehicleTypeId
        left join MAS_Cards d on b.CardId = d.CardId 
	  WHERE
        a.ReceiveId = @ReceiveId
        and ServiceTypeId = 2

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

    SELECT [ReceivableId]
		  --,[ReceiveId]
		  ,[ServiceObject] 
		  ,a.Quantity
		  ,a.Price
		  ,[Amount]
		  ,[VATAmt]
		  ,[TotalAmt]
		  ,[srcId] as CardVehicleId
		  ,c.VehicleTypeName
		  ,b.VehicleName
		  ,b.VehicleNo
		  ,1 as VehicleNum
		  --,b.Is_ElectricCharge
		  ,cd.value1 AS Is_ElectricChargeText
		  ,d.CardCd
		  ,convert(nvarchar(10),a.fromDt,103) as fromDt
		  ,convert(nvarchar(10),a.ToDt,103) as toDt
	  FROM
        [MAS_Service_Receivable] a
        join MAS_CardVehicle b on a.srcId = b.CardVehicleId
        join MAS_VehicleTypes c on b.VehicleTypeId = c.VehicleTypeId
        LEFT JOIN dbo.sys_config_data cd ON cd.key_1 = 'isElectricCharge' AND cd.key_2 = ISNULL(b.Is_ElectricCharge,0)
        left join MAS_Cards d on b.CardId = d.CardId 
	  WHERE
        a.ReceiveId = @ReceiveId
        and ServiceTypeId = 2

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_service_expected_vehicle_get ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = ' ';

    EXEC utl_Insert_ErrorLog @ErrorNum,
                             @ErrorMsg,
                             @ErrorProc,
                             'ServiceExpecteVehicle',
                             'GET',
                             @SessionID,
                             @AddlInfo;
END CATCH;