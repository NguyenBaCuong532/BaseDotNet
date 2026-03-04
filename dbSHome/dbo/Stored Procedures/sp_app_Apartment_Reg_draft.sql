

-- =============================================
-- Author: ANHTT
-- Create date: 2025-09-05 12:38:38
-- Description:	create or update MAS_Apartment_Reg
-- Output: status & messages
-- =============================================
CREATE   PROCEDURE [dbo].[sp_app_apartment_reg_draft] 
	  @userId uniqueidentifier = NULL
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
    , @id BIGINT = NULL
    , @projectCd NVARCHAR(50) = NULL
    , @buildingCd NVARCHAR(50) = NULL
    , @roomCode NVARCHAR(50) = NULL
    , @contractNo NVARCHAR(200) = NULL
    , @relationId INT = NULL
AS
BEGIN TRY
    DECLARE @tableKey VARCHAR(50) = 'app_MAS_Apartment_Reg'
    DECLARE @groupKey VARCHAR(50) = 'common_group'

    --begin
    --1 thong tin chung
    SELECT @Id Id
        , tableKey = @tableKey
        , groupKey = @groupKey

    --2- cac group
     SELECT *
    FROM [dbo].[fn_get_field_group_lang](@groupKey, @acceptLanguage)
    ORDER BY intOrder

    --data
    SELECT [a].[Id]
        , [a].[userId]
        , [a].[roomCode]
        , [a].[contractNo]
        , [a].[relationId]
        , [a].[reg_dt]
        , [a].[reg_st]
        , [a].[auth_dt]
        , b.BuildingCd
        , p.projectCd
    INTO #MAS_Apartment_Reg
    FROM MAS_Apartment_Reg a
    INNER JOIN MAS_Apartments ap ON ap.RoomCode = a.roomCode
    INNER JOIN MAS_Buildings b ON ap.buildingOid = b.oid
    INNER JOIN MAS_Projects p ON p.oid = b.tenant_oid
    WHERE 1 = 0

    -- IF NOT EXISTS (
    --         SELECT 1
    --         FROM #MAS_Apartment_Reg
    --         )
    -- BEGIN
    --     INSERT INTO #MAS_Apartment_Reg (
    --         projectCd
    --         , BuildingCd
    --         , roomCode
    --         )
    --     VALUES (
    --         @projectCd
    --         , @buildingCd
    --         , @roomCode
    --         )
    -- END

    SELECT s.[Id]
        , [table_name]
        , [field_name]
        , [view_type]
        , [data_type]
        , [ordinal]
        , [columnLabel]
        , [group_cd]
        , columnValue = ISNULL(CASE [data_type]
                WHEN 'datetime'
                    THEN CONVERT(NVARCHAR(10), CASE field_name
                                WHEN 'auth_dt'
                                    THEN 1
                                WHEN 'reg_dt'
                                    THEN 1
                                END, 103)
                WHEN 'uniqueidentifier'
                    THEN LOWER(CASE field_name
                                WHEN '1'
                                    THEN 1
                                END)
                WHEN 'bit'
                    THEN IIF(CASE field_name
                                WHEN '1'
                                    THEN 1
                                END = 1, 'True', 'False')
                ELSE CASE field_name
                        WHEN 'contractNo'
                            THEN 1
                        WHEN 'reg_st'
                            THEN 1
                        WHEN 'relationId'
                            THEN 1
                        WHEN 'roomCode'
                            THEN 1
                        END
                END, columnDefault)
        , [columnClass]
        , [columnType]
        , [columnObject] = CONCAT(columnObject,CASE field_name 
                                                    WHEN 'buildingCd' THEN 'projectCd=' + @projectCd 
                                                    WHEN 'roomCode' THEN 'buildingCd=' + @buildingCd 
                                                ELSE '' END)
        , [isSpecial]
        , [isRequire]
        , [isDisable]
        , [isVisiable]
        , s.[isIgnore]
        , NULL AS [IsEmpty]
        , columnTooltip = ISNULL(s.columnTooltip, s.[columnLabel])
        , s.[columnDisplay]
    FROM fn_config_form_gets(@tableKey, @acceptLanguage) s
    --LEFT JOIN #MAS_Apartment_Reg b ON 1 = 1
    ORDER BY s.ordinal

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
    SET @AddlInfo = '@Userid' --+ @userId;

    EXEC utl_ErrorLog_Set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'sp_app_Apartment_Reg_set_draft'
        , 'SET'
        , @SessionID
        , @AddlInfo;
END CATCH;