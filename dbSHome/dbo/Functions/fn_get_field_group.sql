-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[fn_get_field_group]
(	
	@form nvarchar(200)
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT key_1 AS group_key,
			key_2 AS group_cd
		  ,par_desc AS group_name
		  ,value1 AS group_column
		  ,intOrder 
		  ,key_group
	FROM dbo.sys_config_data
	WHERE key_1 = @form and isUsed = 1
)