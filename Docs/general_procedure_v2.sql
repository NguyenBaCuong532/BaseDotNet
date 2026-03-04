USE [dbParkingPro]
GO

/* =============================================
   TITLE: Generator thủ tục SQL Server chuẩn
   AUTHOR: AUTO GENERATOR
   CREATE DATE: 2024-12-07
   DESCRIPTION: Sinh sp_<name>_{page|field|set|del} cho danh sách bảng
   VERSION: 2.0 (Tối ưu hóa)
   ============================================= */

SET NOCOUNT ON;
GO

-- =============================================
-- 1. CẤU HÌNH BẢNG VÀ PROCEDURE
-- =============================================
DECLARE @tableNames NVARCHAR(MAX) = N'hr_person';
DECLARE @procNames  NVARCHAR(MAX) = N'core_person';

-- Thông tin metadata
DECLARE @author      NVARCHAR(100) = N'duongpx';
DECLARE @createdDate NVARCHAR(30)  = CONVERT(NVARCHAR(30), GETDATE(), 120);
DECLARE @outPint bit = 0 --1: print else exec
DECLARE @procType INT = 3 --0: all, 1: page, 2: field, 3: set, 4: del, 5: genform, 6: gengrid
-- Hướng dẫn sử dụng @procType:
-- 0 = Generate tất cả procedures (page, field, set, del)
-- 1 = Chỉ generate procedure _page
-- 2 = Chỉ generate procedure _field  
-- 3 = Chỉ generate procedure _set
-- 4 = Chỉ generate procedure _del
-- 5 = Chỉ chạy genform_cmd (tạo config form)
-- 6 = Chỉ chạy gengrid_cmd (tạo config grid)
-- =============================================
-- 2. GHÉP BẢNG VÀ PROCEDURE
-- =============================================
DROP TABLE IF EXISTS #targets;

;WITH table_names AS (
    SELECT TRIM(value) AS table_name, ROW_NUMBER() OVER (ORDER BY (SELECT 1)) rn
    FROM STRING_SPLIT(@tableNames, ',')
),
proc_names AS (
    SELECT TRIM(value) AS proc_name, ROW_NUMBER() OVER (ORDER BY (SELECT 1)) rn
    FROM STRING_SPLIT(@procNames, ',')
)
SELECT  t.object_id,
        t.name           AS table_name,
        pn.proc_name     AS proc_name,
        ROW_NUMBER() OVER (ORDER BY t.object_id) rn
INTO #targets
FROM sys.tables t
JOIN table_names tn ON tn.table_name = t.name
JOIN proc_names pn ON pn.rn = tn.rn;

DECLARE @N INT = (SELECT COUNT(*) FROM #targets);
DECLARE @i INT = 1;

-- =============================================
-- 3. TEMPLATES CHO CÁC PROCEDURE
-- =============================================

-- Template cho procedure _page
DECLARE @page_tpl NVARCHAR(MAX) = N'
-- =============================================
-- Author: <<AUTHOR>>
-- Create date: <<CREATEDDATE>>
-- Description: Grid phân trang cho bảng <<TABLENAME>>
-- =============================================
CREATE OR ALTER PROCEDURE [sp_<<PROCENAME>>_page]
      @UserId         UNIQUEIDENTIFIER = NULL
    , @filter         NVARCHAR(30)     = NULL
    , @Offset         INT              = 0
    , @PageSize       INT              = 10
    , @gridWidth      INT              = 0
    , @AcceptLanguage VARCHAR(20)      = 'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;
    
    -- Khai báo biến
    DECLARE @Total BIGINT;
    DECLARE @GridKey NVARCHAR(100) = N''view_<<PROCENAME>>_page'';

    -- =============================================
    -- VALIDATION - Kiểm tra và validate parameters
    -- =============================================
    SET @Offset   = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @filter   = ISNULL(@filter, N'''');
    
    IF @PageSize <= 0 SET @PageSize = 10;
    IF @Offset  <  0 SET @Offset  = 0;

    -- =============================================
    -- COUNT - Đếm tổng số bản ghi
    -- =============================================
    SELECT @Total = COUNT(1) FROM <<TABLENAME>>;

    -- =============================================
    -- RESULT SET 1: METADATA - Thông tin phân trang
    -- =============================================
    SELECT recordsTotal    = @Total,
           recordsFiltered = @Total,
           gridKey         = @GridKey,
           valid           = 1;

    -- =============================================
    -- RESULT SET 2: HEADER - Cấu hình cột (chỉ lầu đầu)
    -- =============================================
    IF @Offset = 0
    BEGIN
        SELECT *
        FROM dbo.fn_config_list_gets_lang(@GridKey, 0, @AcceptLanguage)
        ORDER BY ordinal;
    END

    -- =============================================
    -- RESULT SET 3: DATA - Dữ liệu với phân trang
    -- =============================================
    SELECT a.*
    FROM <<TABLENAME>> a
    ORDER BY <<ORDER_COL>>
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50),
            @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = ERROR_MESSAGE();
    SET @ErrorProc= ERROR_PROCEDURE();
    SET @AddlInfo = N'''';
    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, N''<<TABLENAME>>'', N''Page'', @SessionID, @AddlInfo;
    
END CATCH
';

-- Template cho procedure _field
DECLARE @field_tpl NVARCHAR(MAX) = N'
-- =============================================
-- Author: <<AUTHOR>>
-- Create date: <<CREATEDDATE>>
-- Description: Lấy thông tin field cho form <<TABLENAME>>
-- Output: 3 result sets (Info, Groups, Data)
-- =============================================
CREATE OR ALTER PROCEDURE [sp_<<PROCENAME>>_field]
    @UserId UNIQUEIDENTIFIER = NULL,
    @<<PKNAME>> <<PKTYPE>> = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    -- Khai báo biến
    DECLARE @tableKey NVARCHAR(100) = N''<<TABLENAME>>'';
    DECLARE @groupKey NVARCHAR(200) = N''common_group'';

    -- =============================================
    -- RESULT SET 1: INFO - Thông tin cơ bản
    -- =============================================
    SELECT 
        <<PKNAME>> = @<<PKNAME>>, 
        tableKey = @tableKey, 
        groupKey = @groupKey;

    -- =============================================
    -- RESULT SET 2: GROUPS - Nhóm field
    -- =============================================
    SELECT *
    FROM dbo.fn_get_field_group_lang(@groupKey, @AcceptLanguage)
    ORDER BY intOrder;

    -- =============================================
    -- RESULT SET 3: DATA - Dữ liệu field với columnValue động
    -- =============================================
    
    -- Tạo temp table để lưu dữ liệu
    IF OBJECT_ID(N''tempdb..#tempIn'') IS NOT NULL 
        DROP TABLE #tempIn;

    SELECT b.*
    INTO #tempIn
    FROM <<TABLENAME>> b
    WHERE b.<<PKQN>> = @<<PKNAME>>;

    -- Nếu không có dữ liệu, tạo record mới
    IF NOT EXISTS (SELECT 1 FROM #tempIn)
    BEGIN
		set @oid = newid()
        INSERT INTO #tempIn (<<PKQN>>) 
        VALUES (@<<PKNAME>>);
    END

    -- Trả về dữ liệu field với columnValue được format
    SELECT
          a.id
        , a.table_name
        , a.field_name
        , a.view_type
        , a.data_type
        , a.ordinal
        , a.columnLabel
        , a.group_cd
        , columnValue = <<COLUMNVALUE>>
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
    FROM dbo.fn_config_form_gets(@tableKey,@AcceptLanguage) a
    CROSS JOIN #tempIn b
    WHERE a.table_name = @tableKey
      AND (a.IsVisiable = 1 OR a.isRequire = 1)
    ORDER BY a.ordinal;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50),
            @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = N''sp_<<PROCENAME>>_field '' + ERROR_MESSAGE();
    SET @ErrorProc= ERROR_PROCEDURE();
    SET @AddlInfo = N'''';
    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, N''<<TABLENAME>>'', N''GET'', @SessionID, @AddlInfo;
END CATCH
';

-- Template cho procedure _set
DECLARE @set_tpl NVARCHAR(MAX) = N'
-- =============================================
-- Author: <<AUTHOR>>
-- Create date: <<CREATEDDATE>>
-- Description: Tạo/Cập nhật bảng <<TABLENAME>>
-- =============================================
CREATE OR ALTER PROCEDURE [sp_<<PROCENAME>>_set]
     @UserId UNIQUEIDENTIFIER = NULL
    ,@AcceptLanguage VARCHAR(20) = 'vi-VN'
    ,@oid <<PKTYPE>> = NULL
<<PARAMS>>
AS
BEGIN
BEGIN TRY
    SET NOCOUNT ON;
    
    -- Khai báo biến
    DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(250);
    DECLARE @action NVARCHAR(20);

    -- =============================================
    -- VALIDATION - Kiểm tra dữ liệu đầu vào
    -- =============================================
    
    -- Kiểm tra INSERT hay UPDATE
    if exists (select 1 from [<<TABLENAME>>] where <<PKQN>> = @oid)
    begin
        -- =============================================
        -- UPDATE - Cập nhật bản ghi
        -- =============================================
        SET @action = N''UPDATE'';
        
        -- Thực hiện UPDATE
        UPDATE [dbo].[<<TABLENAME>>]
        SET <<UPDATECOLS>>
        WHERE <<PKQN>> = @oid;

        SET @valid = 1;
        SET @messages = N''Cập nhật thành công'';
    end
    else
    begin
        -- =============================================
        -- INSERT - Thêm mới bản ghi
        -- =============================================
        SET @action = N''INSERT'';
        
        -- Tạo ID mới nếu cần
        if @oid IS NULL 
            set @oid = lower(newid());

        -- Thực hiện INSERT
        INSERT INTO [dbo].[<<TABLENAME>>]
			(<<INSERTCOLS>>
			)
        VALUES
			(<<INSERTVALS>>
			);

        SET @valid = 1;
        SET @messages = N''Thêm mới thành công'';
    end

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50),
            @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = ERROR_MESSAGE();
    SET @ErrorProc= ERROR_PROCEDURE();
    SET @AddlInfo = N'''';
    
	set @valid = 0
	set @messages = ERROR_MESSAGE()
	EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, N''<<TABLENAME>>'', N''SET'', @SessionID, @AddlInfo;
       
    
END CATCH

	-- =============================================
    -- RESULT - Trả về kết quả
    -- =============================================
    FINAL:
	SELECT 
        @valid AS valid, 
        @messages AS [messages],
        @oid AS id,
        @action AS action;
END
';

-- Template cho procedure _del
DECLARE @del_tpl NVARCHAR(MAX) = N'
-- =============================================
-- Author: <<AUTHOR>>
-- Create date: <<CREATEDDATE>>
-- Description: Xóa bản ghi từ bảng <<TABLENAME>>
-- =============================================
CREATE OR ALTER PROCEDURE [sp_<<PROCENAME>>_del]
    @UserId UNIQUEIDENTIFIER = NULL,
    @oid <<PKTYPE>>,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
BEGIN
BEGIN TRY
    SET NOCOUNT ON;
    
    -- Khai báo biến
    DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(250);

    -- =============================================
    -- VALIDATION - Kiểm tra dữ liệu đầu vào
    -- =============================================
    
    -- Kiểm tra bản ghi tồn tại
    IF NOT EXISTS(SELECT 1 FROM <<TABLENAME>> WHERE <<PKQN>> = @oid)
    BEGIN
        SET @messages = N''Bản ghi không tìm thấy'';
        SELECT 
            @valid AS valid, 
            @messages AS [messages],
            @oid AS id,
            N''NOT_FOUND'' AS action;
        GOTO FINAL;
    END

    -- =============================================
    -- DELETE - Thực hiện xóa
    -- =============================================
    
    -- Thực hiện xóa
    DELETE FROM <<TABLENAME>> 
    WHERE <<PKQN>> = @oid;

    SET @valid = 1;
    SET @messages = N''Xóa thành công'';

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50),
            @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = ERROR_MESSAGE();
    SET @ErrorProc= ERROR_PROCEDURE();
    SET @AddlInfo = N'''' ;
	SET @valid = 0;
	SET @messages = ERROR_MESSAGE();
    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, N''<<TABLENAME>>'', N''DEL'', @SessionID, @AddlInfo;
    
END CATCH
	-- =============================================
    -- RESULT - Trả về kết quả
    -- =============================================
    FINAL:
	SELECT 
        @valid AS valid, 
        @messages AS [messages]
END
';

DECLARE @gen_forms NVARCHAR(MAX) = N'
INSERT INTO [dbo].sys_config_form
           ([table_name]
           ,[field_name]
           ,[view_type]
           ,[data_type]
           ,[ordinal]
           ,[columnLabel]
           ,[columnTooltip]
           ,[columnDefault]
           ,[columnClass]
           ,[columnType]
           ,[columnObject]
           ,[isSpecial]
           ,[isRequire]
           ,[isDisable]
           ,[IsVisiable]
		   ,group_cd
           )
SELECT TABLE_NAME as table_name
	  ,COLUMN_NAME as field_name
	  ,0 as view_type
	  ,DATA_TYPE as data_type
	  ,ORDINAL_POSITION as ordinal
	  ,COLUMN_NAME as columnLabel
	  ,COLUMN_NAME as columnTooltip
	  ,null as columnDefault
	  ,case when DATA_TYPE = ''bit'' then ''col-2 checkbox'' else ''col-4'' end as columnClass
	  ,case DATA_TYPE when ''bit'' then ''checkbox'' when ''int'' then ''number'' when ''numeric'' then ''currency'' when ''datetime'' then ''datetime'' else ''input'' end as columnType
	  ,case when DATA_TYPE = ''bit'' then '''' else '''' end as columnObject
	  ,0  as isSpecial
	  ,case when IS_NULLABLE = ''YES'' then 0 else 1 end as isRequire
	  ,0 as isDisable
	  ,1 as IsVisiable
	  ,1
FROM INFORMATION_SCHEMA.COLUMNS a
WHERE TABLE_NAME = ''<<TABLENAME>>''
and not exists (select id from dbo.sys_config_form where [table_name] = a.TABLE_NAME and [field_name] = a.COLUMN_NAME)
and a.COLUMN_NAME not in (''created_dt'', ''created_at'', ''createdDate'', ''created_by'', ''CreatedBy'', ''CreateUser'', ''createdUser'')
and a.COLUMN_NAME not in (''updated_dt'', ''updated_at'', ''UpdatedDate'', ''LastUpdate'', ''updated_by'', ''UpdatedBy'', ''UpdatedUser'', ''LastUpdateUser'')
'
DECLARE @gen_grids NVARCHAR(MAX) = N'
INSERT INTO [dbo].sys_config_list
           ([view_grid]
           ,[view_type]
           ,[columnField]
           ,[columnCaption]
		   ,columnWidth
		   ,data_type
           ,[fieldType]
           ,[cellClass]
           ,[Pinned]
           ,[ordinal]
           ,[isMasterDetail]
           ,[isStatusLable]
		   ,isUsed 
           ,[isHide]
           ,[isFilter]
           )
	SELECT ''view_<<PROCENAME>>_page'' TABLE_NAME
			,0
			,COLUMN_NAME
			,null ascolumnCaption
			,100
			,DATA_TYPE
			,''text''
			,''border-right,d-flex,align-items-center''
			,'''' as Pinned
			,ORDINAL_POSITION
			,0 as isMasterDetail
			,0 as isStatusLable
			,1
			,0 as isHide
			,0 as isFilter
	FROM INFORMATION_SCHEMA.COLUMNS a
	WHERE TABLE_NAME = ''<<TABLENAME>>''
		and not exists (select id from [dbo].sys_config_list
			where [view_grid] = ''view_<<PROCENAME>>_page'' and [columnField] = a.COLUMN_NAME)
'
DECLARE @exclude_cols TABLE (name NVARCHAR(100))
INSERT INTO @exclude_cols 
VALUES ('created_dt')
, ('Created')
, ('created_at')
, ('created_by')
, ('CreatedBy')
, ('CreateUser')
, ('createdUser')

, ('updated_dt')
, ('updated')
, ('updated_at')
, ('LastUpdate')
, ('updated_by')
, ('UpdatedBy')
, ('UpdatedUser')
, ('LastUpdateUser')

--, ('created_dt')
--, ('create_by')
--, ('Oid')
, ('is_deleted')
-- =============================================
-- 4. GENERATE PROCEDURE CHO TỪNG BẢNG
-- =============================================
WHILE @i <= @N
BEGIN
    DECLARE @obj INT, @table SYSNAME, @proc SYSNAME;
    SELECT @obj = object_id, @table = table_name, @proc = proc_name
    FROM #targets WHERE rn = @i;

    -- =============================================
    -- 4.1. XÁC ĐỊNH PRIMARY KEY VÀ KIỂU DỮ LIỆU
    -- =============================================
    DECLARE @pk SYSNAME, @pkType SYSNAME;
    
    ;WITH pkc AS (
        SELECT TOP 1 c.name
        FROM sys.indexes i
        JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
        JOIN sys.columns c        ON c.object_id = ic.object_id AND c.column_id = ic.column_id
        WHERE i.object_id = @obj AND i.is_primary_key = 1
        ORDER BY ic.key_ordinal
    )
    SELECT @pk = name FROM pkc;
    
    IF @pk IS NULL 
        SELECT TOP 1 @pk = name FROM sys.columns WHERE object_id=@obj ORDER BY column_id;

    SELECT @pkType = t.name
    FROM sys.columns c 
    JOIN sys.types t ON c.user_type_id = t.user_type_id
    WHERE c.object_id = @obj AND c.name = @pk;

    -- =============================================
    -- 4.2. XÁC ĐỊNH CỘT SẮP XẾP CHO _page
    -- =============================================
    DECLARE @orderCol SYSNAME = CASE 
        WHEN EXISTS(SELECT 1 FROM sys.columns WHERE object_id=@obj AND name='created_at') 
        THEN 'created_at' 
        ELSE @pk 
    END;

    -- =============================================
    -- 4.3. LẤY DANH SÁCH field TỪ sys_config_form
    -- =============================================
    DECLARE @cols TABLE(
        name SYSNAME,
        type_name NVARCHAR(128),
        columnType NVARCHAR(64)
    );

     INSERT INTO @cols(name, type_name, columnType)
     SELECT a.field_name,
            LOWER(t.name),
            LOWER(ISNULL(a.columnType,''))
     FROM dbo.sys_config_form a
     JOIN sys.columns c ON c.object_id = @obj AND c.name = a.field_name
     JOIN sys.types   t ON t.user_type_id = c.user_type_id
     WHERE a.table_name = @table
       AND (a.IsVisiable = 1 OR a.isRequire = 1)
       --AND a.view_type = 0
       AND a.field_name NOT IN (SELECT name FROM @exclude_cols);

    -- =============================================
    -- 4.4. XÂY DỰNG EXPRESSION CHO TỪNG KIỂU DỮ LIỆU
    -- =============================================
    DECLARE @nl NVARCHAR(2) = CHAR(13)+CHAR(10);

    DECLARE @expr_nvarchar NVARCHAR(MAX), @expr_datetime NVARCHAR(MAX),
            @expr_guid NVARCHAR(MAX),     @expr_time NVARCHAR(MAX),
            @expr_bit NVARCHAR(MAX),      @expr_other NVARCHAR(MAX);

    -- NVARCHAR-like field
    SELECT @expr_nvarchar = STRING_AGG(N'            when ''' + name + N''' then b.' + QUOTENAME(name), CHAR(13) + CHAR(10))
    FROM @cols WHERE type_name IN (N'nvarchar',N'nchar',N'varchar',N'char',N'text',N'ntext');

    IF (@expr_nvarchar IS NULL OR @expr_nvarchar = N'')
        SET @expr_nvarchar = N'NULL';
    ELSE
        SET @expr_nvarchar = N'convert (nvarchar(451),' + CHAR(13) + CHAR(10) + 
                            N'        case [field_name]' + CHAR(13) + CHAR(10) + 
                            @expr_nvarchar + CHAR(13) + CHAR(10) + 
                            N'        end)';

    -- DATETIME-like field
    SELECT @expr_datetime = STRING_AGG(N'            when ''' + name + N''' then format(b.' + QUOTENAME(name) + N', ''dd/MM/yyyy HH:mm:ss'')', CHAR(13) + CHAR(10))
    FROM @cols WHERE type_name IN (N'date',N'datetime',N'smalldatetime',N'datetime2');

    IF (@expr_datetime IS NULL OR @expr_datetime = N'')
        SET @expr_datetime = N'NULL';
    ELSE
        SET @expr_datetime = N'case [field_name]' + CHAR(13) + CHAR(10) + 
                            @expr_datetime + CHAR(13) + CHAR(10) + 
                            N'        end';

    -- UNIQUEIDENTIFIER field
    SELECT @expr_guid = STRING_AGG(N'            when ''' + name + N''' then b.' + QUOTENAME(name), CHAR(13) + CHAR(10))
    FROM @cols WHERE type_name IN (N'uniqueidentifier');

    IF (@expr_guid IS NULL OR @expr_guid = N'')
        SET @expr_guid = N'NULL';
    ELSE
        SET @expr_guid = N'LOWER(CAST(case [field_name]' + CHAR(13) + CHAR(10) + 
                            @expr_guid + CHAR(13) + CHAR(10) + 
                            N'        END AS NVARCHAR(100)))';

    -- BIT field
    SELECT @expr_bit = STRING_AGG(N'            when ''' + name + N''' then case b.' + QUOTENAME(name) + N' when 1 then ''true'' else ''false'' end', CHAR(13) + CHAR(10))
    FROM @cols WHERE type_name IN (N'bit');

    IF (@expr_bit IS NULL OR @expr_bit = N'')
        SET @expr_bit = N'NULL';
    ELSE
        SET @expr_bit = N'CONVERT(NVARCHAR(50), case [field_name]' + CHAR(13) + CHAR(10) + 
                            @expr_bit + CHAR(13) + CHAR(10) + 
                            N'        END)';

    -- Other numeric field
    SELECT @expr_other = STRING_AGG(N'            when ''' + name + N''' then b.' + QUOTENAME(name), CHAR(13) + CHAR(10))
    FROM @cols WHERE type_name IN (N'int',N'bigint',N'smallint',N'tinyint',N'decimal',N'numeric',N'float',N'real',N'money',N'smallmoney');

    IF (@expr_other IS NULL OR @expr_other = N'')
        SET @expr_other = N'NULL';
    ELSE
        SET @expr_other = N'CONVERT(NVARCHAR(50), case [field_name]' + CHAR(13) + CHAR(10) + 
                            @expr_other + CHAR(13) + CHAR(10) + 
                            N'        END)';

    -- Build final columnValue expression
    DECLARE @columnValue NVARCHAR(MAX);
    SET @columnValue = N'isnull(case [data_type]' + CHAR(13) + CHAR(10) +
                       N'    when ''nvarchar'' then ' + @expr_nvarchar + CHAR(13) + CHAR(10) +
                       N'    when ''datetime'' then ' + @expr_datetime + CHAR(13) + CHAR(10) +
                       N'    when ''uniqueidentifier'' then ' + @expr_guid + CHAR(13) + CHAR(10) +
                       N'    when ''bit'' then ' + @expr_bit + CHAR(13) + CHAR(10) +
                       N'    else ' + @expr_other + CHAR(13) + CHAR(10) +
                       N'end,a.columnDefault)';

    -- =============================================
    -- 4.5. BUILD PARAMS/INSERT/UPDATE CHO _set
    -- =============================================
    DECLARE
      @params     NVARCHAR(MAX) = N'',
      @insertCols NVARCHAR(MAX) = N'',
      @insertVals NVARCHAR(MAX) = N'',
      @updateCols NVARCHAR(MAX) = N'';

          ;WITH all_columns AS (
        SELECT 
        c.name,
        t.name AS base_type,
        c.column_id,
        c.max_length,
        c.precision,
        c.scale,
        -- type đầy đủ (kèm độ dài/precision)
        type_name = CASE 
            WHEN t.name IN ('nvarchar','nchar')
                THEN t.name + '(' + CASE WHEN c.max_length = -1 
                                         THEN 'max' 
                                         ELSE CAST(c.max_length / 2 AS nvarchar(10)) END + ')'
            WHEN t.name IN ('varchar','char','varbinary','binary')
                THEN t.name + '(' + CASE WHEN c.max_length = -1 
                                         THEN 'max' 
                                         ELSE CAST(c.max_length AS nvarchar(10)) END + ')'
            WHEN t.name IN ('decimal','numeric')
                THEN t.name + '(' + CAST(c.precision AS nvarchar(10)) 
                                  + ',' + CAST(c.scale AS nvarchar(10)) + ')'
            -- sysname thực chất là nvarchar(128)
            WHEN t.name = 'sysname'
                THEN 'nvarchar(128)'
            ELSE t.name
        END,
        ROW_NUMBER() OVER (ORDER BY c.column_id) AS rn
        FROM sys.columns c 
        JOIN sys.types t ON c.user_type_id = t.user_type_id
        WHERE c.object_id = @obj
          AND c.name NOT IN (SELECT name FROM @exclude_cols)
      )
      SELECT
         @params     = STRING_AGG(N'    ,@' + name + N' ' + type_name + N' = NULL', CHAR(13)+CHAR(10)) WITHIN GROUP (ORDER BY column_id),
         @insertCols = STRING_AGG(CASE WHEN rn = 2 THEN N'' + name ELSE N'	        ,' + name END, CHAR(13)+CHAR(10)) WITHIN GROUP (ORDER BY column_id),
         @insertVals = STRING_AGG(CASE WHEN rn = 2 THEN N'@' + name ELSE N'	        ,@' + name END, CHAR(13)+CHAR(10)) WITHIN GROUP (ORDER BY column_id),
                  @updateCols = STRING_AGG(CASE WHEN rn = 2 THEN N'' + name + N' = @' + name ELSE N'	       ,' + name + N' = @' + name END, CHAR(13)+CHAR(10)) WITHIN GROUP (ORDER BY column_id)
      FROM all_columns
      WHERE name <> @pk;

    -- =============================================
    -- 4.6. GENERATE PROCEDURE _page
    -- =============================================
    DECLARE @page_sql NVARCHAR(MAX) = @page_tpl;
    SET @page_sql = REPLACE(@page_sql, N'<<AUTHOR>>',      @author);
    SET @page_sql = REPLACE(@page_sql, N'<<CREATEDDATE>>', @createdDate);
    SET @page_sql = REPLACE(@page_sql, N'<<TABLENAME>>',   @table);
    SET @page_sql = REPLACE(@page_sql, N'<<PROCENAME>>',   @proc);
    SET @page_sql = REPLACE(@page_sql, N'<<ORDER_COL>>',   QUOTENAME(@orderCol) + N' DESC');

    -- =============================================
    -- 4.7. GENERATE PROCEDURE _field
    -- =============================================
    DECLARE @field_sql NVARCHAR(MAX) = @field_tpl;
    SET @field_sql = REPLACE(@field_sql, N'<<AUTHOR>>',      @author);
    SET @field_sql = REPLACE(@field_sql, N'<<CREATEDDATE>>', @createdDate);
    SET @field_sql = REPLACE(@field_sql, N'<<TABLENAME>>',   @table);
    SET @field_sql = REPLACE(@field_sql, N'<<PROCENAME>>',   @proc);
    SET @field_sql = REPLACE(@field_sql, N'<<PKNAME>>',      @pk);
    SET @field_sql = REPLACE(@field_sql, N'<<PKTYPE>>',      @pkType);
    SET @field_sql = REPLACE(@field_sql, N'<<PKQN>>',        QUOTENAME(@pk));

    SET @field_sql = REPLACE(@field_sql, N'<<COLUMNVALUE>>', @columnValue);

    -- =============================================
    -- 4.8. GENERATE PROCEDURE _set
    -- =============================================
    DECLARE @set_sql NVARCHAR(MAX) = @set_tpl;
    SET @set_sql = REPLACE(@set_sql, N'<<AUTHOR>>',      @author);
    SET @set_sql = REPLACE(@set_sql, N'<<CREATEDDATE>>', @createdDate);
    SET @set_sql = REPLACE(@set_sql, N'<<TABLENAME>>',   @table);
    SET @set_sql = REPLACE(@set_sql, N'<<PROCENAME>>',   @proc);
    SET @set_sql = REPLACE(@set_sql, N'<<PKTYPE>>',      @pkType);
    SET @set_sql = REPLACE(@set_sql, N'<<PKQN>>',        QUOTENAME(@pk));
    SET @set_sql = REPLACE(@set_sql, N'<<PARAMS>>',      CASE WHEN LEN(ISNULL(@params,N''))>0 THEN CHAR(13)+CHAR(10)+@params ELSE N'' END);
    SET @set_sql = REPLACE(@set_sql, N'<<INSERTCOLS>>',  @insertCols);
    SET @set_sql = REPLACE(@set_sql, N'<<INSERTVALS>>',  @insertVals);
    SET @set_sql = REPLACE(@set_sql, N'<<UPDATECOLS>>',  @updateCols);

    -- =============================================
    -- 4.9. GENERATE PROCEDURE _del
    -- =============================================
    DECLARE @del_sql NVARCHAR(MAX) = @del_tpl;
    SET @del_sql = REPLACE(@del_sql, N'<<AUTHOR>>',      @author);
    SET @del_sql = REPLACE(@del_sql, N'<<CREATEDDATE>>', @createdDate);
    SET @del_sql = REPLACE(@del_sql, N'<<TABLENAME>>',   @table);
    SET @del_sql = REPLACE(@del_sql, N'<<PROCENAME>>',   @proc);
    SET @del_sql = REPLACE(@del_sql, N'<<PKTYPE>>',      @pkType);
    SET @del_sql = REPLACE(@del_sql, N'<<PKQN>>',        QUOTENAME(@pk));

	-- =============================================
    -- 4.10. OUTPUT VÀ TẠO PROCEDURE
    -- =============================================
	DECLARE @genform_cmd NVARCHAR(MAX) = REPLACE(@gen_forms,'<<TABLENAME>>',@table)
	DECLARE @gengrid_cmd NVARCHAR(MAX) = REPLACE(@gen_grids,'<<TABLENAME>>',@table)
    SET @gengrid_cmd = REPLACE(@gengrid_cmd, N'<<PROCENAME>>',   @proc);
	-- =============================================
    -- 4.11. OUTPUT VÀ TẠO PROCEDURE
    -- =============================================
    PRINT N'-- =============================================';
    PRINT N'-- GENERATING PROCEDURES FOR TABLE: ' + @table;
    PRINT N'-- PROC TYPE: ' + CASE @procType 
        WHEN 0 THEN 'ALL (page, field, set, del)'
        WHEN 1 THEN 'PAGE only'
        WHEN 2 THEN 'field only' 
        WHEN 3 THEN 'SET only'
        WHEN 4 THEN 'DEL only'
        WHEN 5 THEN 'GENFORM only (config form)'
        WHEN 6 THEN 'GENGRID only (config grid)'
        ELSE 'UNKNOWN'
    END;
    PRINT N'-- =============================================';
    	
    --select * from @exclude_cols

	if @outPint = 1
	begin
	-- Output các procedure theo @procType
     IF @procType = 0 OR @procType = 1
         PRINT @page_sql;
     IF @procType = 0 OR @procType = 2
         PRINT @field_sql;
     IF @procType = 0 OR @procType = 3
         PRINT @set_sql;
     IF @procType = 0 OR @procType = 4
         PRINT @del_sql;
     IF @procType = 5
         PRINT N'-- GENFORM CMD: ' + @genform_cmd;
     IF @procType = 6
         PRINT N'-- GENGRID CMD: ' + @gengrid_cmd;
    end
	else
	begin
    -- Thực sự tạo procedure theo @procType
     IF @procType = 0 OR @procType = 1
         EXEC(@page_sql);
     IF @procType = 0 OR @procType = 2
         EXEC(@field_sql);
     IF @procType = 0 OR @procType = 3
         EXEC(@set_sql);
     IF @procType = 0 OR @procType = 4
         EXEC(@del_sql);
	 
	 --gen config (chỉ khi tạo procedure hoặc chạy riêng)
	 IF @procType = 0 OR @procType = 5
	 BEGIN
         EXEC(@genform_cmd);
     END
     
     IF @procType = 0 OR @procType = 6
	 BEGIN
         EXEC(@gengrid_cmd);
     END

	end

    SET @i += 1;
END

-- =============================================
-- 5. HOÀN THÀNH
-- =============================================
PRINT N'-- =============================================';
PRINT N'-- GENERATION COMPLETED FOR ' + CAST(@N AS NVARCHAR(10)) + ' TABLES';
PRINT N'-- PROC TYPE: ' + CASE @procType 
    WHEN 0 THEN 'ALL (page, field, set, del)'
    WHEN 1 THEN 'PAGE only'
    WHEN 2 THEN 'field only' 
    WHEN 3 THEN 'SET only'
    WHEN 4 THEN 'DEL only'
    WHEN 5 THEN 'GENFORM only (config form)'
    WHEN 6 THEN 'GENGRID only (config grid)'
    ELSE 'UNKNOWN'
END;
PRINT N'-- =============================================';

-- =============================================
-- 6. DEMO - HIỂN THỊ KẾT QUẢ FORMAT
-- =============================================
PRINT N'';
PRINT N'-- =============================================';
PRINT N'-- DEMO: KẾT QUẢ FORMAT CỦA CÁC PROCEDURE';
PRINT N'-- =============================================';
PRINT N'-- 1. sp_<name>_page: Trả về 3 result sets';
PRINT N'--    - METADATA: recordsTotal, recordsFiltered, gridKey, valid';
PRINT N'--    - HEADER: Cấu hình cột từ fn_config_list_gets';
PRINT N'--    - DATA: Dữ liệu phân trang';
PRINT N'';
PRINT N'-- 2. sp_<name>_field: Trả về 3 result sets';
PRINT N'--    - INFO: PK, tableKey, groupKey';
PRINT N'--    - GROUPS: Nhóm field từ fn_get_field_group';
PRINT N'--    - DATA: field với columnValue được format theo data_type';
PRINT N'';
PRINT N'-- 3. sp_<name>_set: Trả về 1 result set';
PRINT N'--    - valid, messages, id, action (INSERT/UPDATE)';
PRINT N'';
PRINT N'-- 4. sp_<name>_del: Trả về 1 result set';
PRINT N'--    - valid, messages, id, action (DELETE/ERROR)';
PRINT N'-- =============================================';

GO
