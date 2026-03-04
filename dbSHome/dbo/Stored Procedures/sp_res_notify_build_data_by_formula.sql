CREATE PROCEDURE [dbo].[sp_res_notify_build_data_by_formula]
(
      @formula      NVARCHAR(MAX),
      @projectCd    NVARCHAR(30) = NULL,
      @SourceTable  dbo.GuidList READONLY
)
AS
BEGIN
    SET NOCOUNT ON;

    -- YÊU CẦU: caller PHẢI tạo trước #NotifyData với schema:
    -- CREATE TABLE #NotifyData ( sourceId UNIQUEIDENTIFIER, custId BIGINT, dataJson NVARCHAR(MAX) );
    IF OBJECT_ID('tempdb..#NotifyData') IS NULL
    BEGIN
        RAISERROR(N'#NotifyData not found. Please create #NotifyData(sourceId UNIQUEIDENTIFIER, custId BIGINT, dataJson NVARCHAR(MAX)) before calling.', 16, 1);
        RETURN;
    END

    IF @formula IS NULL OR LTRIM(RTRIM(@formula)) = ''
    BEGIN
        RETURN;
    END

    -- 1) chuẩn bị #SourceIds
    IF OBJECT_ID('tempdb..#SourceIds') IS NOT NULL DROP TABLE #SourceIds;
    CREATE TABLE #SourceIds
    (
        sourceId UNIQUEIDENTIFIER NOT NULL PRIMARY KEY
    );

    INSERT INTO #SourceIds(sourceId)
    SELECT id FROM @SourceTable;

    -- 2) bảng chứa key/value raw (có custId)
    IF OBJECT_ID('tempdb..#KV') IS NOT NULL DROP TABLE #KV;
    CREATE TABLE #KV
    (
        sourceId UNIQUEIDENTIFIER NOT NULL,
        custId   NVARCHAR(50)           NULL,
        [key]    NVARCHAR(200)    NOT NULL,
        [value]  NVARCHAR(MAX)    NULL
    );

    -- 3) replace placeholder cơ bản trong formula
    SET @formula = REPLACE(@formula, '{projectCd}', ISNULL(@projectCd, ''));

    -- 4) chạy dynamic SQL: formula PHẢI trả về SELECT sourceId, custId, [key], [value]
    DECLARE @sql NVARCHAR(MAX) = N'
        INSERT INTO #KV(sourceId, custId, [key], [value])
        ' + @formula + N';
    ';

    BEGIN TRY
        EXEC sp_executesql @sql;
    END TRY
    BEGIN CATCH
        DECLARE @err NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(N'sp_res_notify_build_data_by_formula: error executing formula: %s',16,1,@err);
        RETURN;
    END CATCH

    -- 5) nếu không có dữ liệu thì dừng
    IF NOT EXISTS(SELECT 1 FROM #KV)
    BEGIN
        RETURN;
    END

    -- 6) Xóa trước những bản ghi cũ trong #NotifyData cùng keys (nếu có)
    -- (tránh duplicate nếu caller gọi nhiều lần)
    DELETE nd
    FROM #NotifyData nd
    JOIN (SELECT DISTINCT sourceId, custId FROM #KV) k
      ON nd.sourceId = k.sourceId
     AND ( (nd.custId = k.custId) OR (nd.custId IS NULL AND k.custId IS NULL));

    -- 7) Gom thành JSON object per (sourceId, custId)
    --    Dùng FOR XML PATH để tương thích SQL Server mọi version
    INSERT INTO #NotifyData(sourceId, custId, dataJson)
    SELECT
        k1.sourceId,
        k1.custId,
        '{' + 
        ISNULL(
            STUFF(
                (
                    SELECT
                        ',' + '"' + REPLACE(k2.[key], '"', '\"') + '":' +
                              '"' + REPLACE(ISNULL(k2.[value], ''), '"', '\"') + '"'
                    FROM #KV k2
                    WHERE k2.sourceId = k1.sourceId
                      AND ( (k2.custId = k1.custId) OR (k2.custId IS NULL AND k1.custId IS NULL) )
                    ORDER BY k2.[key]  -- optional stable order
                    FOR XML PATH(''), TYPE
                ).value('.', 'NVARCHAR(MAX)')
            , 1, 1, ''
            )
        , '') + '}'
    FROM (
        SELECT DISTINCT sourceId, custId FROM #KV
    ) k1;

    -- 8) Cleanup tạm (không xóa #NotifyData vì caller cần dùng)
    IF OBJECT_ID('tempdb..#SourceIds') IS NOT NULL DROP TABLE #SourceIds;
    IF OBJECT_ID('tempdb..#KV') IS NOT NULL DROP TABLE #KV;

    RETURN;
END