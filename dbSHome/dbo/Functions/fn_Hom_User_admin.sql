

CREATE FUNCTION [dbo].[fn_Hom_User_admin] 
(
	@userId nvarchar(450)
)
RETURNS bit
AS
BEGIN
	--
	DECLARE @rs bit = 0
	
	if exists(select a.userId FROM Users a
			WHERE a.userId = @UserID
				--AND a.admin_st = 1
			)	
			set @rs = 1	
	--
	RETURN @rs

END