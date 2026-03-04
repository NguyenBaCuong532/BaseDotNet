
CREATE   PROCEDURE [dbo].[sp_res_edit_card_family_field] 
    @CardCd NVARCHAR(450) = NULL,
    @UserId uniqueidentifier,
    @HostUrl nvarchar(150) = NULL,
    @AcceptLanguage nvarchar(50) = N'vi-VN',
    @cardOid UNIQUEIDENTIFIER = NULL
AS
BEGIN TRY
    IF @cardOid IS NOT NULL
        SET @CardCd = (SELECT CardCd FROM MAS_Cards WHERE oid = @cardOid);

    DECLARE @group_key VARCHAR(50) = 'common_group'
    DECLARE @table_key VARCHAR(50) = 'apartment_edit_card'

    SELECT @CardCd [CardCd]
        , tableKey = @table_key
        , groupKey = @group_key;

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
        SELECT [table_name]
            , [field_name]
            , [view_type]
            , [data_type]
            , [ordinal]
            , [columnLabel]
            , [group_cd]
            , ISNULL(CASE [field_name]
					WHEN 'ProjectCd'
                        THEN a.ProjectCd
                    WHEN 'CardCd'
                        THEN a.CardCd
                    WHEN 'IssueDate'
                        THEN CONVERT(NVARCHAR(10), a.[IssueDate], 103)
                    WHEN 'ExpireDate'
                        THEN CONVERT(NVARCHAR(10), a.[ExpireDate], 103)
                    WHEN 'CardTypeId'
                        THEN CONVERT(NVARCHAR(10), a.CardTypeId)
                    WHEN 'CurrentPoint'
                        THEN CONVERT(NVARCHAR(500), ISNULL(p.CurrPoint, 0))
                    WHEN 'StatusName'
                        THEN cs.StatusName
                    WHEN 'CustId'
                        THEN b.CustId
                    WHEN 'fullname'
                        THEN b.FullName
                    WHEN 'RoomCode'
                        THEN d.RoomCode
                    WHEN 'CardTypeName'
                        THEN c.CardTypeName
                    WHEN 'ImageUrl'
                        THEN CASE 
                                WHEN a.[CardTypeId] = 3
                                    THEN 'http://data.sunshinegroup.vn/shome/card/card_cre.jpg'
                                ELSE CASE 
                                        WHEN a.[CardTypeId] = 2
                                            THEN 'http://data.sunshinegroup.vn/shome/card/card_veh_plc.jpg'
                                            ELSE CONCAT(@HostUrl, '/images/card/card.png')
--                                             ELSE 'http://data.sunshinegroup.vn/shome/card/card_com_plc.jpg'
                                        END
                                END
                    WHEN 'ApartmentId'
                        THEN CONVERT(NVARCHAR(500), a.ApartmentId)
                    WHEN 'CardStatus'
                        THEN CONVERT(NVARCHAR(20), a.Card_St)
                    END, [columnDefault]) AS columnValue
            , [columnClass]
            , [columnType]
            , [columnObject]
            , [isSpecial]
            , [isRequire]
            , [isDisable]
            , [isVisiable]
            , NULL AS [IsEmpty]
            , ISNULL(s.columnTooltip, s.[columnLabel]) AS columnTooltip
        --,case when @action = 'edit' then 1 else 0 end as isChange
        FROM dbo.fn_config_form_gets('apartment_edit_card', @AcceptLanguage) s
        LEFT JOIN dbo.MAS_Cards a
            ON a.CardCd = @CardCd
        INNER JOIN MAS_Customers b
            ON a.CustId = b.CustId
        INNER JOIN MAS_CardTypes c
            ON a.CardTypeId = c.CardTypeId
        INNER JOIN MAS_Apartments d
            ON a.ApartmentId = d.ApartmentId
        LEFT JOIN MAS_Points p
            ON p.CustId = b.CustId
        INNER JOIN MAS_CardStatus cs
            ON a.Card_St = cs.StatusId
        ORDER BY s.ordinal;
    END
    ELSE
    BEGIN
        SELECT [id]
            , [table_name]
            , [field_name]
            , [view_type]
            , [data_type]
            , [ordinal]
            , [columnLabel]
            , group_cd
            , a.columnDefault AS columnValue
            , [columnClass]
            , [columnType]
            , [columnObject]
            , [isSpecial]
            , [isRequire]
            , [isDisable] = 0
            , [isVisiable]
            ,
            --,[IsEmpty]
            ISNULL(a.columnTooltip, a.[columnLabel]) AS columnTooltip
        FROM dbo.fn_config_form_gets('apartment_edit_card', @AcceptLanguage) a
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
    SET @ErrorMsg = 'sp_res_family_edit_card_field' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'apartment_family_edit_card'
        , 'GetInfo'
        , @SessionID
        , @AddlInfo;
END CATCH;