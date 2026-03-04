

CREATE PROCEDURE [dbo].[sp_res_service_expected_fee_page]
    @UserId UNIQUEIDENTIFIER = null,
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
    FROM [MAS_Service_Receivable] a
        JOIN MAS_Apartments b
            ON a.srcId = b.ApartmentId
    --join MAS_VehicleTypes c on b.VehicleTypeId = c.VehicleTypeId
    --left join MAS_Cards d on b.CardId = d.CardId 
    WHERE a.ReceiveId = @receiveId
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

    --SELECT [ReceivableId],
    --       [ReceiveId],
    --       [ServiceObject],
    --       a.Quantity,
    --       a.Price,
    --       [Amount],
    --       [VatAmt],
    --       [TotalAmt],
    --       b.ApartmentId,
    --       b.WaterwayArea,
    --       CONVERT(NVARCHAR(10), a.fromDt, 103) AS fromDt,
    --       CONVERT(NVARCHAR(10), a.ToDt, 103) AS toDt,
    --       b.RoomCode
    --FROM [MAS_Service_Receivable] a
    --    JOIN MAS_Apartments b
    --        ON a.srcId = b.ApartmentId
    ----join MAS_VehicleTypes c on b.VehicleTypeId = c.VehicleTypeId
    ----left join MAS_Cards d on b.CardId = d.CardId 
    --WHERE a.ReceiveId = @receiveId
    --      AND ServiceTypeId = 1;
	SELECT 
		ReceivableId =  a.RoomCode,
		ServiceObject = pc.[service_name],
		fromDt =  FORMAT(pc.effective_date, 'dd/MM/yyyy'),
		toDt = FORMAT(pc.expiry_date, 'dd/MM/yyyy'),
		WaterwayArea = a.WaterwayArea,
		Price = pc.value,
		TotalAmt = CASE 
						WHEN a.IsFree = 0 AND a.FreeToDt > msr.ToDt THEN 0
						ELSE ISNULL(a.WaterwayArea, 0) * ISNULL(pc.value, 0) *
						(
							1.0 * (
										DATEDIFF(
											DAY,
											CASE 
												WHEN a.FreeToDt IS NOT NULL 
													  AND a.FreeToDt BETWEEN pc.effective_date AND ISNULL(pc.expiry_date, msr.ToDt)
													THEN a.FreeToDt
												WHEN pc.effective_date < DATEFROMPARTS(YEAR(msr.ToDt), MONTH(msr.ToDt), 1) 
													 THEN DATEFROMPARTS(YEAR(msr.ToDt), MONTH(msr.ToDt), 1) 
												ELSE pc.effective_date 
											END,
											CASE 
											WHEN ISNULL(pc.expiry_date,  msr.ToDt) >  msr.ToDt 
												THEN  msr.ToDt 
											ELSE ISNULL(pc.expiry_date,  msr.ToDt) 
										END
										) + 1
							) / NULLIF(DAY(EOMONTH(msr.ToDt)),0)
						)
					END,
		  FeeNoVatAmt = f.TotalAmt,
		  FeeVatAmt = f.TotalAmt/11
	 FROM MAS_Service_ReceiveEntry msr
		JOIN MAS_Apartments a  ON msr.ApartmentId = a.ApartmentId    
		LEFT JOIN MAS_Service_Receivable f on f.srcId = msr.ApartmentId and f.ReceiveId = msr.ReceiveId and f.ServiceTypeId = 1
		JOIN par_common pc ON pc.project_code =a.ProjectCd AND pc.is_active = 1
		   AND pc.value > 0
		   AND pc.effective_date <= msr.ToDt
		   AND (pc.expiry_date IS NULL OR pc.expiry_date >= DATEFROMPARTS(YEAR(msr.ToDt), MONTH(msr.ToDt), 1))
	 WHERE msr.ReceiveId = @receiveId
	 AND pc.is_active = 1
	 ORDER BY msr.ApartmentId, pc.effective_date;
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