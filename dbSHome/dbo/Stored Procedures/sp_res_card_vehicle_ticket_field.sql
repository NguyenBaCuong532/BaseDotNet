
CREATE PROCEDURE [dbo].[sp_res_card_vehicle_ticket_field] @userid UNIQUEIDENTIFIER = NULL
    , @id BIGINT = NULL
    , @cardCode VARCHAR(50) = NULL
    , @cardVehicleOid UNIQUEIDENTIFIER = NULL
AS
BEGIN TRY
    IF @cardVehicleOid IS NOT NULL
        SET @id = (SELECT CardVehicleId FROM MAS_CardVehicle WHERE oid = @cardVehicleOid);
    DECLARE @group_key VARCHAR(50) = 'common_group'
    DECLARE @table_key VARCHAR(50) = 'form_card_vehicle_ticket'

    --
    SELECT [key] = @id
        , tableKey = @table_key
        , groupKey = @group_key;

    --
    SELECT *
    FROM [dbo].[fn_get_field_group](@group_key)
    ORDER BY intOrder;

    --
    DECLARE @subQuery NVARCHAR(MAX) = N'SELECT b.CardVehicleId
                        , c.FullName
                        , b.VehicleNo
                        , b.VehicleName
                        , c.Phone
                        , b.StartTime
                        , a.cardCd
                        , a.CustId
                        , b.[Status]
                        , b.AssignDate
                        , b.VehicleTypeId
                        , b.projectCd
                    FROM MAS_CardVehicle b
                    LEFT JOIN [dbo].[MAS_Cards] a
                        ON a.CardId = b.CardId
                    JOIN MAS_Customers c
                        ON b.CustId = c.CustId
                    where b.CardVehicleId = @id'

    IF @id IS NULL
        OR @id = 0
        SET @subQuery = @subQuery + ' UNION ALL
                    SELECT cardVehicleId = @id
                        , c.FullName
                        , VehicleNo = NULL
                        , VehicleName = NULL
                        , c.Phone
                        , StartTime = CONVERT(DATE,GETDATE())
                        , a.cardCd
                        , a.CustId
                        , [Status] = 1
                        , AssignDate = GETDATE()
                        , VehicleTypeId = NULL
                        , projectCd
                    FROM [dbo].[MAS_Cards] a
                    JOIN MAS_Customers c
                        ON a.CustId = c.CustId
                    WHERE a.CardCd = ''' + @cardCode + ''''

    EXEC sp_get_data_fields @id = @id
        , @tablename = 'MAS_CardVehicle'
        , @keyname = 'CardVehicleId'
        , @subQuery = @subQuery
        , @formname = @table_key
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