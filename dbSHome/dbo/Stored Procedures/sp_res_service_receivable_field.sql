CREATE PROCEDURE [dbo].[sp_res_service_receivable_field] 
      @userId UNIQUEIDENTIFIER = NULL
    , @receiveId INT = 0
    , @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    DECLARE @group_key NVARCHAR(50) = 'common_group'
    DECLARE @table_key NVARCHAR(50) = 'service_receivable_details'
    --
    SELECT receiveId = @receiveId
        , tableKey = @table_key
        , groupKey = @group_key;

    SELECT *
    FROM [dbo].[fn_get_field_group_lang](@group_key, @acceptLanguage)
    ORDER BY intOrder;

    --3 tung o trong group
    IF @receiveId IS NOT NULL
        AND EXISTS (
            SELECT 1
            FROM dbo.MAS_Service_ReceiveEntry
            WHERE ReceiveId = @receiveId
            )
    BEGIN
        SELECT DISTINCT cf.id
            , table_name
            , field_name
            , view_type
            , data_type
            , ordinal
            , columnLabel
            , group_cd
            , CASE data_type
                  WHEN 'nvarchar' THEN convert(NVARCHAR(350),
                      CASE field_name
                            WHEN 'IsPayedText' THEN CASE  WHEN a.IsPayed = 1 THEN N'Đã thanh toán' ELSE N'Chờ thanh toán' END
                            WHEN 'RoomCode' THEN b.RoomCode
--                             WHEN 'FullName' THEN c.FullName
                            WHEN 'FullName' THEN h.FullName
                            WHEN 'bank_code' THEN u.bank_code
                            WHEN 'ServiceFee' THEN 'Tháng' + cast((
                                                CASE 
                                                    WHEN month(a.ToDt) < 12
                                                        THEN month(a.ToDt) + 1
                                                    ELSE CASE 
                                                            WHEN month(a.ToDt) = 12
                                                                THEN 1
                                                            END
                                                    END
                                                ) AS VARCHAR) + '/' + cast(year(a.ToDt) AS VARCHAR)
                                END)
		WHEN 'decimal'
			THEN CASE field_name
					WHEN 'TotalAmt'
						THEN LTRIM(STR(a.TotalAmt, 18, 0))
					WHEN 'ExtendAmt'
						THEN LTRIM(STR((
										SELECT ISNULL(ExtendAmt, 0)
										FROM MAS_Service_Receivable
										WHERE ReceiveId = @receiveId
											AND ServiceTypeId = 8
									), 18, 0))
					WHEN 'RefundAmt'
						THEN LTRIM(STR(a.RefundAmt, 18, 0))
					WHEN 'DebitAmt'
						THEN LTRIM(STR(a.DebitAmt, 18, 0))
					WHEN 'DebitAmtAnother'
						THEN '0'
					WHEN 'WaterwayArea'
						THEN LTRIM(STR(b.WaterwayArea, 18, 2)) -- Giả sử có 2 số thập phân
					WHEN 'Amount'
						THEN LTRIM(STR((
										SELECT ISNULL([Amount], 0)
										FROM [MAS_Service_Receivable]
										WHERE ReceiveId = @ReceiveId
											AND ServiceTypeId = 1
									), 18, 0))
					WHEN 'FeeTotalAmt'
						THEN LTRIM(STR((
										SELECT ISNULL([TotalAmt], 0)
										FROM [MAS_Service_Receivable]
										WHERE ReceiveId = @ReceiveId
											AND ServiceTypeId = 1
									), 18, 0))
					WHEN 'vatAmt'
						THEN LTRIM(STR((
										SELECT ISNULL([VATAmt], 0)
										FROM [MAS_Service_Receivable]
										WHERE ReceiveId = @ReceiveId
											AND ServiceTypeId = 1
									), 18, 0))
				END
                WHEN 'int'
                    THEN cast(CASE field_name
                                WHEN 'IsPayed'
                                    THEN a.IsPayed
                                END AS NVARCHAR(100))
                WHEN 'date'
                    THEN convert(NVARCHAR(50), CASE field_name
                                WHEN 'ExpireDate'
                                    THEN convert(NVARCHAR(10), a.[ExpireDate], 103)
                                END)
                        --else convert(nvarchar(50),case field_name 
                        --	end) 
                END AS columnValue
            , columnClass
            , columnType
            , columnObject
            , isSpecial
            , isRequire
            , isDisable
            , isVisiable
            , [IsEmpty]
            , isnull(cf.columnTooltip, cf.[columnLabel]) AS columnTooltip
            , cf.[columnDisplay]
            , cf.[isIgnore]
        FROM
            fn_config_form_gets('service_receivable', @acceptLanguage) cf
            ,[dbo].MAS_Service_ReceiveEntry a
            JOIN MAS_Apartments b ON a.ApartmentId = b.ApartmentId
            LEFT JOIN UserInfo u ON b.UserLogin = u.loginName
            LEFT JOIN MAS_Customers c ON u.CustId = c.CustId
            OUTER APPLY (SELECT TOp(1) t1.*
                      FROM
                          MAS_Customers t1
                          join MAS_Apartment_Member b1 on t1.CustId = b1.CustId 
                          left join MAS_Customer_Relation d1 on b1.RelationId = d1.RelationId
                      WHERE b1.ApartmentId = b.ApartmentId and b1.RelationId = 0) h
        WHERE
            a.ReceiveId = @receiveId
        --AND (cf.isVisiable = 1 or cf.isRequire =1)
        ORDER BY cf.ordinal
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
            , [isDisable]
            , a.[isVisiable]
            , a.[columnDisplay]
            , a.[isIgnore]
            --,[IsEmpty]
            , ISNULL(a.columnTooltip, a.[columnLabel]) AS columnTooltip
        FROM fn_config_form_gets('service_receivable', @acceptLanguage) a
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
    SET @ErrorMsg = 'sp_res_service_receivable_field' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'Service_ReceiveEntry'
        , 'GetInfo'
        , @SessionID
        , @AddlInfo;
END CATCH;