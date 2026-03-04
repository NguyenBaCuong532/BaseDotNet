
CREATE FUNCTION [dbo].[fn_config_list_gets] (
    @view_grid NVARCHAR(150)
    , @grid_width INT
    )
RETURNS @tbl TABLE (
    [columnField] NVARCHAR(50)
    , [columnCaption] NVARCHAR(50)
    , [columnWidth] INT
    , [fieldType] NVARCHAR(50)
    , [columnClass] NVARCHAR(300)
    , [columnCondition] NVARCHAR(400)
    , [Pinned] NVARCHAR(50)
    , [isMasterDetail] BIT
    , [isStatusLable] BIT
    , [isHide] BIT
    , [isFilter] BIT
    , [ordinal] INT INDEX idx CLUSTERED
    , [isUsed] BIT
    )
AS
BEGIN
    --
    DECLARE @total_width INT;
    DECLARE @rt FLOAT;
    
    -- Calculate width ratio
    SELECT @total_width = SUM(ISNULL(columnWidth, 100)) 
    FROM [dbo].sys_config_list WITH (NOLOCK)
    WHERE view_grid = @view_grid AND isHide = 0;
    
    IF @grid_width > @total_width
        SET @rt = CAST(@grid_width AS FLOAT) / @total_width;
    ELSE
        SET @rt = 1;
    
    -- Insert with optimized query
    INSERT INTO @tbl 
    SELECT [columnField],
           cc.[columnCaption],--ISNULL(l.[columnCaption], cc.[columnCaption]),
           @rt * ISNULL([columnWidth], 100) AS columnWidth,
           [fieldType],
           [cellClass] AS columnClass,
           [conditionClass] AS columnCondition,
           [Pinned],
           [isMasterDetail],
           [isStatusLable],
           [isHide],
           [isFilter],
           [ordinal],
           [isUsed]
    FROM [dbo].sys_config_list cc WITH (NOLOCK)
    --LEFT JOIN sys_config_list_lang l WITH (NOLOCK) ON cc.id = l.id AND l.langkey = @acceptLanguage
    WHERE isUsed = 1  
    AND view_grid = @view_grid 
    ORDER BY [ordinal];
    
    RETURN;
END