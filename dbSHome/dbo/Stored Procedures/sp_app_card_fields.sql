
-- =============================================
-- Author: ANHTT
-- Create date: 2025-09-05 12:38:38
-- Description:	details of card
-- Output: form configuration
-- =============================================
CREATE PROCEDURE [dbo].[sp_app_card_fields]
	  @userId UNIQUEIDENTIFIER = NULL
    , @id BIGINT = NULL
    , @cardCd NVARCHAR(50) = NULL
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @tableKey VARCHAR(50) = 'app_apartment_card'
    DECLARE @groupKey VARCHAR(50) = 'common_group'
    DECLARE @customerId UNIQUEIDENTIFIER = dbo.fn_get_customerid(@userId);
    --
    --begin
    --1 thong tin chung
    SELECT Id = @Id
        , CardCd = @cardCd
        , t.[CardTypeName]
        , t.[CardTypeNameEn]
        , FullName = a.FullName
        , b.SelfLock
        , [CardStatus] = b.Card_St
        , [statusName] = s.StatusNameLable
        , tableKey = @tableKey
        , groupKey = @groupKey
    FROM MAS_Customers a
    INNER JOIN MAS_Cards b
        ON a.CustId = b.CustId
    LEFT JOIN MAS_CardTypes t ON t.CardTypeId = b.CardTypeId
    LEFT JOIN MAS_CardStatus s ON s.StatusId = b.Card_St
    WHERE CardCd = @cardCd

    --2- cac group
    SELECT *
    FROM [dbo].[fn_get_field_group](@groupKey)
    ORDER BY intOrder

    --fields
    --TODO: check quyền
    SELECT TOP 1 a.[CardId]
        , a.[CardCd]
        , [ImageUrl] = (
            SELECT TOP 1 sa.CardTypeImg
            FROM MAS_CardTypes sa
            WHERE sa.CardTypeId = a.CardTypeId
            )
        , a.[IssueDate]
        , a.[ExpireDate]
        , CardStatus = a.[Card_St]
        , [status] = a.Card_St
        , a.[IsVip]
        , a.[CardName]
        , a.[IsDaily]
        , a.[IsClose]
        , a.[CloseDate]
        , a.[ApartmentId]
        , a.[ProjectCd]
        , a.[StarLevel]
        , a.[IsGuest]
        , a.[isVehicle]
        , a.[isCredit]
        , b.BuildingCd
        , Building = b.BuildingName
        , Project = ISNULL(p.projectName, a.ProjectCd)
        , c.FullName
        , ap.RoomCode
    INTO #temp
    FROM MAS_Cards a
    INNER JOIN MAS_Customers c
        ON c.CustId = a.CustId
    INNER JOIN MAS_Apartment_Card ac
        ON a.CardId = ac.CardId
    INNER JOIN MAS_Apartments ap
        ON a.ApartmentId = ap.ApartmentId
    LEFT JOIN (
        SELECT DISTINCT projectCd
            , projectName
        FROM MAS_Projects
        ) p
        ON p.projectCd = a.ProjectCd
    LEFT JOIN MAS_Buildings b
        ON b.BuildingCd = ap.buildingCd
    WHERE a.CardCd = @cardCd

    EXEC [sp_config_data_fields_v2] @id = @id
        , @key_name = 'id'
        , @table_name = 'app_apartment_card'
        , @dataTableName = '#temp'
        , @acceptLanguage = @acceptLanguage
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_ErrorLog_Set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , @tableKey
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH;