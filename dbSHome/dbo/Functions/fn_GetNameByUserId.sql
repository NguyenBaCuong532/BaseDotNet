

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[fn_GetNameByUserId](
	@UserId nvarchar(50)
)
RETURNS nvarchar(100)
AS 
BEGIN
    declare @name nvarchar(100)
	set @name = (select top 1 c.loginName
		from MAS_Customers b 
			inner join UserInfo c on b.CustId = c.CustId
		where c.UserId = @UserId)
    RETURN (@name)
END;