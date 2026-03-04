
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[fn_Exists_CustCategory] 
(	
	@UserId nvarchar(450),
	@CustId nvarchar(50)
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT cc.CustId, cc.CategoryCd 
		FROM MAS_Category_Customer cc  
		WHere cc.CustId like isnull(@CustId,'') + '%' and
	  (exists(select userid from [MAS_Category_User] a
		where a.UserId = @UserId and a.CategoryCd = cc.CategoryCd)
	 or exists(select userid from [MAS_Category_User] a 
		inner join MAS_Category b on a.CategoryCd = b.ParentCd 
		where a.UserId = @UserId and b.CategoryCd = cc.CategoryCd)
	 ) 
)