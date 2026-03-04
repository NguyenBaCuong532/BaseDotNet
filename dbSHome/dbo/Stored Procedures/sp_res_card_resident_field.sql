

CREATE PROCEDURE [dbo].[sp_res_card_resident_field] 
    @UserId UNIQUEIDENTIFIER = NULL,
    @AcceptLanguage NVARCHAR(50) = N'vi-VN',
    @cardid NVARCHAR(50) = NULL,
    @apartmentId INT = NULL,
    @apartOid UNIQUEIDENTIFIER = NULL,
    @cardOid UNIQUEIDENTIFIER = NULL
AS
BEGIN TRY
    SET NOCOUNT ON;
    IF @cardOid IS NOT NULL
        SET @cardid = (SELECT CardCd FROM MAS_Cards WHERE oid = @cardOid);
    IF @apartOid IS NOT NULL
        SET @apartmentId = (SELECT ApartmentId FROM MAS_Apartments WHERE oid = @apartOid);

    -- Khai báo biến
    DECLARE @group_key VARCHAR(50) = 'common_group';
    DECLARE @table_key VARCHAR(50) = 'apartment_card';

    -- =============================================
    -- RESULT SET 1: INFO - Thông tin cơ bản
    -- =============================================
    SELECT 
        id = @cardid,
        tableKey = @table_key,
        groupKey = @group_key;

    -- =============================================
    -- RESULT SET 2: GROUPS - Nhóm field
    -- =============================================
    SELECT *
    FROM [dbo].[fn_get_field_group_lang](@group_key, @AcceptLanguage)
    ORDER BY intOrder;

	drop table if exists #tempIn
	
	select cast(cardId as int) as cardId,CardCd,custId,ProjectCd,issueDate,expireDate,ApartmentId,CardTypeId,card_st
	into #tempIn
	from MAS_Cards b
	WHERE (b.CardCd = @cardid)

	if not exists(select 1 from #tempIn)
	insert into #tempIn (cardId,CardCd,custId,ProjectCd,issueDate,expireDate,ApartmentId,card_st,CardTypeId)
	select @cardid,'','',a.projectCd,getdate(),null,@apartmentId,0,1
	from MAS_Apartments a
	where a.ApartmentId = @apartmentId

    -- Lấy ra từng ô trong group
        SELECT 
            s.id
            , s.table_name
            , s.field_name
            , s.view_type
            , s.data_type
            , s.ordinal
            , s.columnLabel
            , s.group_cd
            , columnValue = CASE s.data_type WHEN 'nvarchar' THEN CONVERT(NVARCHAR(350), CASE s.field_name 
					WHEN 'CustId' THEN b.CustId
					WHEN 'CardCd' THEN a.cardCd
                    WHEN 'fullname' THEN b.FullName
                    WHEN 'RoomCode' THEN d.RoomCode
                    WHEN 'CardTypeName' THEN c.CardTypeName
                    WHEN 'ImageUrl'
                        THEN CASE 
                                WHEN a.[CardTypeId] = 3
                                    THEN 'http://data.sunshinegroup.vn/shome/card/card_cre.jpg'
                                ELSE CASE 
                                        WHEN a.[CardTypeId] = 2
                                            THEN 'http://data.sunshinegroup.vn/shome/card/card_veh_plc.jpg'
                                        ELSE 'http://data.sunshinegroup.vn/shome/card/card_com_plc.jpg'
                                        END
                                END
                END
            )
            WHEN 'datetime' THEN CONVERT(NVARCHAR(50), CASE s.field_name 
                WHEN 'IssueDate' THEN CONVERT(NVARCHAR(10), a.[IssueDate], 103)
                WHEN 'ExpireDate' THEN CONVERT(NVARCHAR(10), a.[ExpireDate], 103)
            END)
            ELSE CONVERT(NVARCHAR(50), CASE s.field_name 
                WHEN 'cardid' THEN CAST(a.cardid AS NVARCHAR(50))
                WHEN 'CardTypeId' THEN CONVERT(NVARCHAR(10), a.CardTypeId)
                WHEN 'ApartmentId' THEN CONVERT(NVARCHAR(500), a.ApartmentId)
                WHEN 'CardStatus' THEN CONVERT(NVARCHAR(20), a.card_St)
            END) 
        END
            , s.columnClass
            , s.columnType
            , columnObject = CASE 
                WHEN s.field_name = 'CustId' THEN s.columnObject + CAST(@apartmentId AS NVARCHAR(50))
                ELSE s.columnObject
            END
            , s.isSpecial
            , s.isRequire
            , s.isDisable
            , s.IsVisiable
            , s.isEmpty
            , columnTooltip = ISNULL(s.columnTooltip, s.columnLabel)
            , s.columnDisplay
            , s.isIgnore
        FROM dbo.fn_config_form_gets(@table_key, @AcceptLanguage) s
        CROSS JOIN #tempIn a
        LEFT JOIN MAS_Customers b ON a.CustId = b.CustId
        INNER JOIN MAS_CardTypes c ON a.CardTypeId = c.CardTypeId
        INNER JOIN MAS_Apartments d ON a.ApartmentId = d.ApartmentId
        LEFT JOIN MAS_Points p ON p.CustId = b.CustId
        WHERE (s.IsVisiable = 1 OR s.isRequire = 1)
        ORDER BY s.ordinal;
   
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_family_card_field' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'apartment_family_card'
        , 'GetInfo'
        , @SessionID
        , @AddlInfo;
END CATCH;