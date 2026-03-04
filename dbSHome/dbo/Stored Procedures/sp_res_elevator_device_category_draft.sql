CREATE PROCEDURE [dbo].[sp_res_elevator_device_category_draft] @UserId UNIQUEIDENTIFIER = NULL
    , @Id INT
    , @HardwareId NVARCHAR(50)
    , @ElevatorBank INT
    , @ElevatorShaftName NVARCHAR(30)
    , @ElevatorShaftNumber INT
    , @ProjectCd NVARCHAR(30)
    , @buildingCd NVARCHAR(30)
    , @IsActived BIT
    , @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    DECLARE @group_key VARCHAR(50) = 'common_group'
    DECLARE @table_key VARCHAR(50) = 'MAS_Elevator_Device_Category'

    SELECT id = @id
        , tableKey = @table_key
        , groupKey = @group_key;

    SELECT *
    FROM [dbo].[fn_get_field_group_lang](@group_key, @acceptLanguage)
    ORDER BY intOrder;

    DROP TABLE

    IF EXISTS #tempIn
        SELECT b.*
        INTO #tempIn
        FROM MAS_Elevator_Device_Category b
        WHERE 0 = 1
        

    IF NOT EXISTS (
            SELECT 1
            FROM #tempIn
            )
        INSERT INTO #tempIn (
            HardwareId
            , ElevatorBank
            , ElevatorShaftName
            , ElevatorShaftNumber
            , ProjectCd
            , buildingCd
            , IsActived
            , created_at
            , id
            , oid
            )
        SELECT @HardwareId
            , ISNULL(@ElevatorBank, 0)
            , ISNULL(@ElevatorShaftName, '')
            , ISNULL(@ElevatorShaftNumber, 0)
            , ISNULL(@ProjectCd, '')
            , ISNULL(@buildingCd, '')
            , @IsActived
            , getdate()
            , ISNULL(@id, ISNULL((SELECT MAX(Id) FROM MAS_Elevator_Device_Category), 0) + 1)
            , newid()
    SELECT a.id
        , table_name
        , field_name
        , view_type
        , data_type
        , ordinal
        , columnLabel
        , group_cd
        , CASE data_type
            WHEN 'nvarchar'
                THEN convert(NVARCHAR(350), CASE field_name
                            WHEN 'HardwareId'
                                THEN b.HardwareId
                            WHEN 'ElevatorShaftName'
                                THEN b.ElevatorShaftName
                            WHEN 'buildingCd'
                                THEN b.buildingCd
                            WHEN 'ProjectCd'
                                THEN b.ProjectCd
                            END)
            WHEN 'datetime'
                THEN convert(NVARCHAR(50), CASE field_name
                            WHEN 'created_at'
                                THEN format(b.created_at, 'dd/MM/yyyy HH:mm:ss')
                            END)
            WHEN 'bit'
                THEN CASE field_name
                        WHEN 'IsActived'
                            THEN --cast(b.IsActived as bit)
                                CASE 
                                    WHEN b.IsActived = '0'
                                        THEN 'false'
                                    ELSE 'true'
                                    END
                        END
            ELSE convert(NVARCHAR(50), CASE field_name
                        WHEN 'ElevatorBank'
                            THEN b.ElevatorBank
                        WHEN 'ElevatorShaftNumber'
                            THEN b.ElevatorShaftNumber
                                --when 'IsActived' then CASE WHEN b.IsActived = '0' THEN 'false' ELSE 'true' END
                                --when 'IsActived' then --CAST(CASE WHEN b.IsActived = '0' THEN 0 ELSE 1 END AS bit)
                                --CASE WHEN b.IsActived = 'true' THEN 1 ELSE 0 END
                        END)
            END AS columnValue
        , columnClass
        , columnType
        , columnObject = CASE 
            WHEN a.field_name = 'buildingCd'
                THEN columnObject + b.ProjectCd
            ELSE columnObject
            END
        , isSpecial
        , isRequire
        , isDisable /*= case when b.CardRole = 2 and a.field_name in ('buildingCd','AreaCd','FloorNumber') then 1 
									when b.CardRole = 3 and a.field_name in ('AreaCd','FloorNumber') then 1
									when b.CardRole = 1 and a.field_name in ('FloorNumber') then 1
								else isDisable end*/
        , isVisiable
        , isnull(a.columnTooltip, [columnLabel]) AS columnTooltip
        , isIgnore
    FROM dbo.fn_config_form_gets(@table_key, @acceptLanguage) a
        CROSS JOIN #tempIn b
    WHERE a.table_name = @table_key
        AND (
            a.isVisiable = 1
            OR a.isRequire = 1
            )
    ORDER BY ordinal
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_res_elevator_device_category_draft' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = ' '

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'elevator'
        , 'SET'
        , @SessionID
        , @AddlInfo
END CATCH