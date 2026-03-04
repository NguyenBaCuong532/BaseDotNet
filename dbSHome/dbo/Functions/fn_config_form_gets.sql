
-- =============================================
-- Author:		duongpx
-- Create date: 10/5/2024 11:41:16 PM
-- Description:	filter dùng chung
-- =============================================
CREATE FUNCTION [dbo].[fn_config_form_gets] (
    @table_name NVARCHAR(200) = ''
    , @acceptLanguage NVARCHAR(50) = 'en'
    )
RETURNS @tbl TABLE (
    [id] [bigint] NOT NULL
    , [table_name] [nvarchar](100) NOT NULL
    , [field_name] [nvarchar](100) NOT NULL
    , [view_type] [int] NOT NULL
    , [data_type] [nvarchar](50) NOT NULL
    , [ordinal] [int] NULL
    , [group_cd] [nvarchar](150) NULL
    , [columnLabel] [nvarchar](max) NULL
    , [columnTooltip] [nvarchar](300) NULL
    , [columnDefault] [nvarchar](max) NULL
    , [columnClass] [nvarchar](500) NULL
    , [columnType] [nvarchar](50) NULL
    , [columnObject] [nvarchar](500) NULL
    , [isVisiable] [bit] NULL
    , [isSpecial] [bit] NULL
    , [isRequire] [bit] NULL
    , [isDisable] [bit] NULL
    , [isEmpty] [bit] NULL
    , [columnDisplay] [nvarchar](300) NULL
    , [isIgnore] [bit] NULL
    , [is_active] bit NULL
    --[maxLength] [nvarchar](50) NULL,
    --[table_relation] [nvarchar](150)
    )
AS
BEGIN
    --
    INSERT INTO @tbl
    SELECT cc.[id]
        , [table_name]
        , [field_name]
        , [view_type]
        , [data_type]
        , [ordinal]
        , [group_cd]
        , [columnLabel] = COALESCE(l.[columnLabel], cc.[columnLabel])
        , [columnTooltip]
        , [columnDefault]
        , [columnClass]
        , [columnType]
        , [columnObject]
        , [isVisiable]
        , [isSpecial]
        , [isRequire]
        , [isDisable]
        , [isEmpty]
        , [columnDisplay]
        , [isIgnore]
        , is_active
    FROM [sys_config_form] cc
    LEFT JOIN [sys_config_form_lang] l
        ON cc.id = l.id
            AND l.langkey = @acceptLanguage
    WHERE table_name = @table_name
        AND (
            isvisiable = 1
            OR isRequire = 1
            )

    RETURN
END