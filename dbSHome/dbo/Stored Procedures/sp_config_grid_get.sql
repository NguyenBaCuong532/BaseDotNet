

-- Create the stored procedure in the specified schema
CREATE PROCEDURE [dbo].[sp_config_grid_get] 
	 @userId UNIQUEIDENTIFIER = NULL
    , @gridKey NVARCHAR(50)
AS
BEGIN
    SELECT *
    FROM [dbo].[fn_config_list_gets](@gridKey, 0)
    ORDER BY ordinal;
END