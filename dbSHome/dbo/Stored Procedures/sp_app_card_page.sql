
-- =============================================
-- Author: ANHTT
-- Create date: 2025-09-05 12:38:38
-- Description:	page of card
-- Output: card page
-- =============================================
CREATE PROCEDURE [dbo].[sp_app_card_page]
      @userId UNIQUEIDENTIFIER = NULL
    , @ApartmentId BIGINT = NULL
    , @isOwn BIT = 0
    , @isVehicle BIT = 0
    , @filter NVARCHAR(100)
    , @gridWidth INT = 0
    , @Offset INT = 0
    , @PageSize INT = 10
    , @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    DECLARE @Total BIGINT
    DECLARE @GridKey NVARCHAR(100) = 'view_app_card_page'
    DECLARE @is_host BIT

    SET @Offset = isnull(@Offset, 0)
    SET @PageSize = isnull(@PageSize, 10)
    SET @Total = isnull(@Total, 0)
    SET @filter = isnull(@filter, '')

    IF @PageSize = 0
        SET @PageSize = 10

    IF @Offset < 0
        SET @Offset = 0

    DECLARE @customerId UNIQUEIDENTIFIER
    DECLARE @userLogin NVARCHAR(100)

    SELECT @customerId = custId
        , @userLogin = loginName
    FROM UserInfo
    WHERE userId = @userId

    IF EXISTS (
            SELECT TOP 1 1
            FROM MAS_Apartments
            WHERE ApartmentId = @ApartmentId
                AND UserLogin = @userLogin
            )
        OR EXISTS (
            SELECT TOP 1 1
            FROM MAS_Apartment_Member
            WHERE ApartmentId = @ApartmentId
                AND CustId = @customerId
                AND RelationId = 0
            )
        SET @is_host = 1

    SELECT @Total = COUNT_BIG(1)
    FROM MAS_Cards a
    WHERE ApartmentId = @ApartmentId
        AND (
            @is_host = 1
            OR a.CustId = @customerId
            )

    --root	
    SELECT recordsTotal = @Total
        , recordsFiltered = @Total
        , gridKey = @GridKey
        , valid = 1

    IF @Offset = 0
    BEGIN
        SELECT *
        FROM [dbo].fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
        ORDER BY [ordinal];
    END
            -- IF @isOwn = 1
            -- BEGIN
            ;

    WITH cte
    AS (
        SELECT a.[CardCd]
            , a.ApartmentId
            , a.CustId
            , a.CardTypeId
            , a.Card_St
            , a.selfLock
            , a.isLost
            , [CardCount] = c.cardCount
        FROM [MAS_Cards] a
        OUTER APPLY (
            SELECT cardCount = COUNT(1)
            FROM MAS_Cards sa
            WHERE sa.ApartmentId = @ApartmentId
                AND sa.CustId = a.CustId
            ) c
        WHERE ApartmentId = @ApartmentId
            AND (
                @is_host = 1
                OR a.CustId = @customerId
                )
        )
    SELECT a.CardCd
        , pp.cardTypeName
        , pp.cardTypeNameEn
        , pp.CardTypeImg AS [ImageUrl]
        , b.fullName
        , CardStatus = a.Card_St
        , a.selfLock
        , a.isLost
        , [status] = a.Card_St
        , s.statusName
        , r.RelationName
        , a.CardCount
    FROM cte a
    INNER JOIN MAS_Apartment_Member m
        ON a.ApartmentId = m.ApartmentId
            AND a.CustId = m.CustId
    LEFT JOIN MAS_Customer_Relation r
        ON r.RelationId = m.RelationId
    LEFT JOIN MAS_Customers b
        ON a.CustId = b.CustId
    INNER JOIN MAS_CardStatus s
        ON a.Card_St = s.StatusId
    INNER JOIN MAS_CardTypes pp
        ON a.[CardTypeId] = pp.[CardTypeId]
    WHERE a.ApartmentId = @ApartmentId
        AND (
            @is_host = 1
            OR a.CustId = @customerId
            )
    ORDER BY m.RelationId OFFSET @offset ROW

    FETCH NEXT @pageSize ROW ONLY
        -- END
        -- ELSE
        -- BEGIN
        --      SELECT a.[CardCd]
        --         , convert(NVARCHAR(10), a.[IssueDate], 103) [IssueDate]
        --         , convert(NVARCHAR(10), a.[ExpireDate], 103) [ExpireDate]
        --         , a.CustId AS CifNo
        --         , a.[CardTypeId]
        --         , pp.CardTypeName
        --         , isnull(p.CurrPoint, 0) AS [CurrentPoint]
        --         , pp.CardTypeImg AS [ImageUrl]
        --         , b.FullName
        --         , a.Card_St AS [Status]
        --         , s.StatusName
        --         , b.CustId
        --         , p.CurrPoint AS CurrentPoint
        --         , m.RelationId
        --         , r.RelationName
        --         , [CardCount] = 1
        --     FROM [MAS_Cards] a
        --     INNER JOIN MAS_Apartment_Member m
        --         ON a.ApartmentId = m.ApartmentId
        --             AND a.CustId = m.CustId
        --     LEFT JOIN MAS_Customer_Relation r
        --         ON r.RelationId = m.RelationId
        --     LEFT JOIN MAS_Customers b
        --         ON a.CustId = b.CustId
        --     INNER JOIN MAS_CardStatus s
        --         ON a.Card_St = s.StatusId
        --     INNER JOIN MAS_CardTypes pp
        --         ON a.[CardTypeId] = pp.[CardTypeId]
        --     LEFT JOIN MAS_Points p
        --         ON b.CustId = p.CustId
        --     WHERE a.ApartmentId = @ApartmentId
        --         AND (
        --             @is_host = 1
        --             OR a.CustId = @customerId
        --             )
        -- END
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