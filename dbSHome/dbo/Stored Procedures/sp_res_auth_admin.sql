-- =============================================
-- Author:		sonpt02
-- Create date: 29/11/2024
-- Description:	Authenticate user is admin
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_auth_admin]	
	@userId NVARCHAR(50)
AS
BEGIN
	SELECT admin_st
    FROM Users 
    WHERE UserId = @userId
END