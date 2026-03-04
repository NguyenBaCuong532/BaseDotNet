
CREATE PROCEDURE [dbo].[sp_res_card_lock_field] 
    @CardCd NVARCHAR(450) = NULL,
    @UserId UNIQUEIDENTIFIER = NULL,
    @HostUrl NVARCHAR(150) = NULL,
    @AcceptLanguage NVARCHAR(50) = N'vi-VN',
    @cardOid UNIQUEIDENTIFIER = NULL
AS
BEGIN TRY
    SET NOCOUNT ON;
    IF @cardOid IS NOT NULL
        SET @CardCd = (SELECT CardCd FROM MAS_Cards WHERE oid = @cardOid);

    -- Khai báo biến
    DECLARE @group_key VARCHAR(50) = 'common_group';
    DECLARE @table_key VARCHAR(50) = 'card_lock';

    -- =============================================
    -- RESULT SET 1: INFO - Thông tin cơ bản
    -- =============================================
    SELECT 
        CardCd = @CardCd,
        tableKey = @table_key,
        groupKey = @group_key;

    -- =============================================
    -- RESULT SET 2: GROUPS - Nhóm field
    -- =============================================
    SELECT *
    FROM [dbo].[fn_get_field_group_lang](@group_key, @AcceptLanguage)
    ORDER BY intOrder;

    -- Lấy ra từng ô trong group
    IF EXISTS (
            SELECT 1
            FROM dbo.MAS_Cards
            WHERE CardCd = @CardCd
            )
    BEGIN
        SELECT 
            s.id
            , s.table_name
            , s.field_name
            , s.view_type
            , s.data_type
            , s.ordinal
            , s.columnLabel
            , s.group_cd
            , columnValue = ISNULL(CASE s.field_name
                    WHEN 'CardCd' THEN a.CardCd
                    WHEN 'IssueDate' THEN CONVERT(NVARCHAR(10), a.[IssueDate], 103)
                    WHEN 'ExpireDate' THEN CONVERT(NVARCHAR(10), a.[ExpireDate], 103)
                    WHEN 'CardTypeId' THEN CONVERT(NVARCHAR(10), a.CardTypeId)
                    WHEN 'CurrentPoint' THEN CONVERT(NVARCHAR(500), ISNULL(p.CurrPoint, 0))
                    WHEN 'StatusName' THEN cs.StatusName
                    WHEN 'CustId' THEN b.CustId
                    WHEN 'fullname' THEN b.FullName
                    WHEN 'RoomCode' THEN d.RoomCode
                    WHEN 'CardTypeName' THEN c.CardTypeName
                    WHEN 'ImageUrl' THEN CASE 
                            WHEN a.[CardTypeId] = 3 THEN 'http://data.sunshinegroup.vn/shome/card/card_cre.jpg'
                            ELSE CASE 
                                WHEN a.[CardTypeId] = 2 THEN 'http://data.sunshinegroup.vn/shome/card/card_veh_plc.jpg'
                                ELSE CONCAT(@HostUrl, '/images/card/card.png')
                            END
                        END
                    WHEN 'ApartmentId' THEN CONVERT(NVARCHAR(500), a.ApartmentId)
                    WHEN 'CardStatus' THEN CONVERT(NVARCHAR(20), a.Card_St)
                END, s.columnDefault)
            , s.columnClass
            , s.columnType
            , s.columnObject
            , s.isSpecial
            , s.isRequire
            , s.isDisable
            , s.IsVisiable
            , s.isEmpty
            , columnTooltip = ISNULL(s.columnTooltip, s.columnLabel)
            , s.columnDisplay
            , s.isIgnore
        FROM dbo.fn_config_form_gets(@table_key, @AcceptLanguage) s
        LEFT JOIN dbo.MAS_Cards a ON a.CardCd = @CardCd
        INNER JOIN MAS_Customers b ON a.CustId = b.CustId
        INNER JOIN MAS_CardTypes c ON a.CardTypeId = c.CardTypeId
        INNER JOIN MAS_Apartments d ON a.ApartmentId = d.ApartmentId
        LEFT JOIN MAS_Points p ON p.CustId = b.CustId
        INNER JOIN MAS_CardStatus cs ON a.Card_St = cs.StatusId
        WHERE (s.IsVisiable = 1 OR s.isRequire = 1)
        ORDER BY s.ordinal;
    END
    ELSE
    BEGIN
        SELECT 
            a.id
            , a.table_name
            , a.field_name
            , a.view_type
            , a.data_type
            , a.ordinal
            , a.columnLabel
            , a.group_cd
            , a.columnDefault AS columnValue
            , a.columnClass
            , a.columnType
            , a.columnObject
            , a.isSpecial
            , a.isRequire
            , a.isDisable
            , a.IsVisiable
            , a.isEmpty
            , columnTooltip = ISNULL(a.columnTooltip, a.columnLabel)
            , a.columnDisplay
            , a.isIgnore
        FROM dbo.fn_config_form_gets(@table_key, @AcceptLanguage) a
        WHERE (a.IsVisiable = 1 OR a.isRequire = 1)
        ORDER BY a.ordinal;
    END
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_card_lock_field' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'card_lock'
        , 'GetInfo'
        , @SessionID
        , @AddlInfo;
END CATCH;