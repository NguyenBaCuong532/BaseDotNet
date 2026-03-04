CREATE FUNCTION fn_get_appid (@clientId NVARCHAR(50))
RETURNS BIGINT
AS
BEGIN
    DECLARE @default_client_id NVARCHAR(50) = 'swagger'
    IF @clientId IS NULL SET @clientId = @default_client_id
    RETURN (
            SELECT AppId
            FROM PAR_AppClient
            WHERE ClientId = @clientId
            )
END