
-- =============================================
-- Author:		AnhTT
-- Create date: 
-- Description:	get empty form fields
-- =============================================
CREATE FUNCTION [dbo].[fn_config_form_gets_temp]()
RETURNS @tb TABLE 
(
[id] nvarchar(max),
[table_name] nvarchar(100),
[field_name] nvarchar(100),
[view_type] int,
[data_type] nvarchar(50),
[ordinal] int ,
[group_cd] nvarchar(50),
[columnLabel] nvarchar(250),
[columnTooltip] nvarchar(250),
[columnClass] nvarchar(250),
[columnType] nvarchar(50),
[columnObject] nvarchar(max),
[isVisiable] bit,
[isSpecial] bit,
[isRequire] bit,
[isDisable] bit,
[columnValue] nvarchar(max),
[columnDisplay] nvarchar(250),
[isIgnore] BIT
)
BEGIN
	return
END