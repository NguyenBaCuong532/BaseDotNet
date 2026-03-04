

CREATE FUNCTION [dbo].[fn_is_supper_admin] (@userId NVARCHAR(450))
RETURNS BIT
AS
BEGIN
	--
	DECLARE @rs BIT = 0

	--if exists (select top 1 1 from user_roles a inner join roles b on a.role_id = b.id where a.user_id = @userId and is_supper_admin = 1) set @rs = 1		
	IF EXISTS (
			SELECT TOP 1 1 FROM UserRoles a
			JOIN sys_config_roles b ON a.roleId = b.id
			JOIN dbo.[User] c ON a.userId = c.userId
			WHERE b.roleType = 1
				AND c.userId = @userId
			)
		SET @rs = 1

	--
	RETURN @rs
END