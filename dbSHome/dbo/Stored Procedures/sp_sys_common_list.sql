CREATE PROCEDURE [dbo].[sp_sys_common_list] @UserID NVARCHAR(450) = NULL
    , @isFilter BIT = NULL
    , @TableName NVARCHAR(50) = 'district'
    , @columnName NVARCHAR(50) = NULL
    , @columnId NVARCHAR(50) = NULL
    , @columnParent NVARCHAR(50) = 'province_id'
    , @valueParent NVARCHAR(50) = '996AD2A3-E442-4D04-A4A8-98D6BE616765'
    , @All NVARCHAR(100) = NULL
    , @columnEqual	NVARCHAR(50) = NULL--Cột cần so sánh giá trị
    , @equalValue	NVARCHAR(50) = NULL--Giá trị cần so sánh để lấy ra theo điều kiện
    , @ColSortOrder	NVARCHAR(50) = NULL--Sắp xếp theo cột
AS
BEGIN TRY
    DECLARE @tSQL NVARCHAR(500)
        , @tParamDefinition AS NVARCHAR(200)

    SET @columnName = ISNULL(@columnName, 'name')
    SET @tSQL = 'SELECT LOWER(CONVERT(NVARCHAR(100),' + @columnId + ')) as Value
					  ,CONVERT(NVARCHAR(100),' + @columnName + ')  AS Name			  
						FROM ' + @TableName + '' + ' WHERE (' + @columnName + ' IS NOT NULL)';
    
    IF(@columnParent IS NOT NULL AND TRIM(@columnParent) <> '' AND @valueParent IS NOT NULL AND TRIM(@valueParent) <> '')
        SET @tSQL = @tSQL + ' AND ' + @columnParent + '= ''' + @valueParent + '''';
    
    IF(@columnEqual IS NOT NULL AND TRIM(@columnEqual) <> '' AND @equalValue IS NOT NULL AND TRIM(@equalValue) <> '')
        SET @tSQL = @tSQL + ' AND ' + @columnEqual + '= ''' + @equalValue + '''';
        
    IF(@ColSortOrder IS NOT NULL AND TRIM(@ColSortOrder) <> '')
        SET @tSQL = @tSQL + ' ORDER BY ' + @ColSortOrder;

    RAISERROR (
            @tSQL
            , 0
            , 1
            )
    WITH NOWAIT

    SET @tParamDefinition = '@TableName nvarchar(50)'

    --print @tSQL
    DECLARE @items TABLE (
        value NVARCHAR(100)
        , [name] NVARCHAR(100)
        )

    IF @isFilter = 1
        INSERT INTO @items
        VALUES (
            '-1'
            , N'Tất cả'
            )

    INSERT INTO @items
    EXEC sp_Executesql @tSQL
        , @tParamDefinition
        , @TableName

    SELECT *
    FROM @items
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_sys_common_list ' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = ''

    EXEC utl_ErrorLog_Set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , @TableName
        , 'Get'
        , @SessionID
        , @AddlInfo
END CATCH