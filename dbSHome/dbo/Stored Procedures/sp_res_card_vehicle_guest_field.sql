CREATE PROCEDURE [dbo].[sp_res_card_vehicle_guest_field] 
     @userid UNIQUEIDENTIFIER = NULL
    , @id BIGINT = NULL
    , @cardVehicleOid UNIQUEIDENTIFIER = NULL
	, @AcceptLanguage nvarchar(50) = null
AS
BEGIN TRY
    IF @cardVehicleOid IS NOT NULL
        SET @id = (SELECT CardVehicleId FROM MAS_CardVehicle WHERE oid = @cardVehicleOid);
    DECLARE @group_key VARCHAR(50) = 'common_group'
    DECLARE @table_key VARCHAR(50) = 'MAS_CardVehicle'

    SELECT [key] = @id
        , tableKey = @table_key
        , groupKey = @group_key;

    SELECT *
    FROM [dbo].[fn_get_field_group](@group_key)
    ORDER BY intOrder;
    --  DECLARE @ReceiptId int = 116455
    --3 tung o trong group
    EXEC sp_get_data_fields @id = @id
        , @tablename = 'MAS_CardVehicle'
        , @keyname = 'CardVehicleId'
        , @subQuery = N'SELECT  c.FullName
                        , b.VehicleNo
                        , b.VehicleName
                        , c.Phone
                        , convert(NVARCHAR(10), b.StartTime, 103) AS StartTime
                        , convert(NVARCHAR(10), b.EndTime, 103) AS EndTime
                        , a.cardCd
                        , a.CustId
                        , b.[Status]
                        , b.AssignDate
                        , b.VehicleTypeId
                        , projectCd = ISNULL(b.ProjectCd, a.ProjectCd)
                        ,b.CardVehicleId
                    FROM MAS_CardVehicle b
                    LEFT JOIN [dbo].[MAS_Cards] a
                        ON a.CardId = b.CardId
                    JOIN MAS_Customers c
                        ON b.CustId = c.CustId
                    JOIN MAS_VehicleTypes d
                        ON b.VehicleTypeId = d.VehicleTypeId
                    WHERE b.CardVehicleId = @id'
        , @formname = 'MAS_CardVehicle_Guest'


END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_card_partner_field' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'MAS_CardPartner'
        , 'GetInfo'
        , @SessionID
        , @AddlInfo;
END CATCH;