-- =============================================
-- Author:		<Author,,Nguyen Trung Tai>
-- Create date: <Create Date, ,02/05/2016>
-- Description:	<Description, ,>
-- =============================================
create FUNCTION [dbo].[ufn_Get_Root_Element_Name]
(
	-- Add the parameters for the function here
	@XML NVARCHAR(MAX)
)
RETURNS VARCHAR(100)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result VARCHAR(100),
			@FirstIndex INT,
			@Length INT;

	-- Add the T-SQL statements to compute the return value here
	
	SET @FirstIndex = CHARINDEX('<', @XML) + 1
	SET @Length  = CHARINDEX('>', @XML) - @FirstIndex

	SET @Result = REPLACE(SUBSTRING(@XML, @FirstIndex, @Length), ' ', '')

	-- Return the result of the function
	RETURN @Result

END