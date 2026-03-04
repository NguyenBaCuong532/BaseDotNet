-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fn_Get_New_EMPNO]
(
)
RETURNS nvarchar(50)
BEGIN
	
	-- Declare the return variable here
	DECLARE @empno nvarchar(50)

	---- Add the T-SQL statements to compute the return value here
	set @empno = right('000'+CAST(DATEDIFF(ss, '2016-01-01', GETUTCDATE()) as varchar),6)
    --(SELECT TOP 1 a.[EMP_No] FROM [COR_EMP] a WHERE IsUsed = 0 and NOT a.EMP_No IN (SELECT EmployeeCd FROM [Employees]) ORDER BY [gui_id])

	---- Return the result of the function
	RETURN isnull(@empno,'')

END