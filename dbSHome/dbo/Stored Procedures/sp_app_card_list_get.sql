
-- =============================================
-- Author: ANHTT
-- Create date: 2025-09-05 12:38:38
-- Description:	list of card
-- Output: card page
-- =============================================
CREATE
    

 PROCEDURE [dbo].[sp_app_card_list_get] @userId UNIQUEIDENTIFIER = NULL
    , @is_own BIT = 0
    , @is_vehicle BIT = 0
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @customerId UNIQUEIDENTIFIER = dbo.fn_get_customerid(@userId)

    IF @is_own = 1
    BEGIN
        SELECT [a].[CardId]
            , a.[CardCd]
            , a.[CardTypeId]
            , a.[ImageUrl]
            , a.[IssueDate]
            , a.[ExpireDate]
            , a.[CustId]
            , a.[Card_St]
            , a.[IsVip]
            , a.[CardName]
            , a.[IsDaily]
            , a.[IsClose]
            , a.[CloseDate]
            , a.[RequestId]
            , a.[ApartmentId]
            , a.[ProjectCd]
            , a.[VehicleTypeId]
            , a.[StarLevel]
            , a.[IsGuest]
            , a.[isVehicle]
            , a.[isCredit]
            , a.[partner_id]
            , a.[created_by]
            , a.[CloseBy]
            --, a.[rowguid]
            , a.[CardTypeId]
            , t.[CardTypeName]
            , t.[Post]
            , t.[CardTypeImg]
            , [status] = a.Card_St
            , [StatusName] = s.StatusName
        FROM MAS_Cards a
        INNER JOIN MAS_CardTypes t
            ON a.CardTypeId = t.CardTypeId
        INNER JOIN MAS_CardStatus s
            ON s.StatusId = a.Card_St
        WHERE a.CustId = @customerId
    END
    ELSE
    BEGIN
        SELECT TOP 5 [a].[CardId]
            , a.[CardCd]
            , a.[CardTypeId]
            , a.[IssueDate]
            , a.[ExpireDate]
            , a.[CustId]
            , a.[Card_St]
            , a.[IsVip]
            , a.[CardName]
            , a.[IsDaily]
            , a.[IsClose]
            , a.[CloseDate]
            , a.[RequestId]
            , a.[ApartmentId]
            , a.[ProjectCd]
            , a.[VehicleTypeId]
            , a.[StarLevel]
            , a.[IsGuest]
            , a.[isVehicle]
            , a.[isCredit]
            , a.[partner_id]
            , a.[created_by]
            , a.[CloseBy]
            --, a.[rowguid]
            , a.[CardTypeId]
            , t.[CardTypeName]
            , t.[Post]
            , [ImageUrl] = t.[CardTypeImg]
            , [status] = a.Card_St
            , [StatusName] = s.StatusName
        FROM MAS_Cards a
        INNER JOIN MAS_CardTypes t
            ON a.CardTypeId = t.CardTypeId
        INNER JOIN MAS_CardStatus s
            ON s.StatusId = a.Card_St
    END
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
        , ''
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH;