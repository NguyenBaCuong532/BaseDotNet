CREATE PROCEDURE [dbo].[sp_res_invoices_create]
    @userId NVARCHAR(50)
    , @project_code VARCHAR(50) = NULL
    , @periods_oid VARCHAR(50) = NULL
    , @oid uniqueidentifier = NULL
    , @receiveIds NVARCHAR(max) = NULL
    , @ProjectCd NVARCHAR(30) = NULL
    , @IsAllProject BIT = NULL,
    
    @BuildingCd NVARCHAR(100) = NULL,
    @FloorNo NVARCHAR(100) = NULL,
    @ApartmentCd NVARCHAR(100) = NULL
AS
BEGIN TRY
    IF @receiveIds IS NULL OR @receiveIds = ''
    BEGIN
        UPDATE t
        SET
            IsBill = 0
            ,bill_st = 0
        FROM
            MAS_Service_ReceiveEntry t
            JOIN MAS_Apartments ma ON t.ApartmentId = ma.ApartmentId
            LEFT JOIN MAS_Buildings c ON ma.buildingOid = c.oid
        WHERE
            IsPayed = 0
            AND isExpected = 1
            AND t.ProjectCd = @ProjectCd
            AND (@periods_oid IS NULL OR @periods_oid = '' OR t.periods_oid = @periods_oid)
            AND (@BuildingCd IS NULL OR @BuildingCd = '' OR c.BuildingCd = @BuildingCd)
            AND (@FloorNo IS NULL OR @FloorNo = '' OR ma.floorNo = @FloorNo)
            AND (@ApartmentCd IS NULL OR @ApartmentCd = '' OR t.ApartmentId IN(SELECT part FROM [dbo].[SplitString](@ApartmentCd, ',')))
    END
    ELSE
    BEGIN
        UPDATE t
        SET
            IsBill = 0
            , bill_st = 1
        FROM
            MAS_Service_ReceiveEntry t
            JOIN MAS_Apartments ma ON t.ApartmentId = ma.ApartmentId
            LEFT JOIN MAS_Buildings c ON ma.buildingOid = c.oid
        WHERE
            isExpected = 1
            --and IsPayed = 0 
            AND t.ReceiveId IN (SELECT part FROM [dbo].[SplitString](@receiveIds, ','))
    END
    
    SELECT
        valid = 1,
        messages = N'Tạo hoá đơn thành công'
    
    SELECT
        t.ReceiveId
        , 0 AS receiveBillStatus
    FROM
        MAS_Service_ReceiveEntry t
        JOIN MAS_Apartments ma ON t.ApartmentId = ma.ApartmentId
        LEFT JOIN MAS_Buildings c ON ma.buildingOid = c.oid
    WHERE
        IsPayed = 0
        AND isExpected = 1
        AND t.ProjectCd = @ProjectCd

END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_res_invoices_create' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = ''

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'Receivable'
        , 'Bill'
        , @SessionID
        , @AddlInfo
END CATCH