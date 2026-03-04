CREATE FUNCTION [dbo].[fn_Get_CreateCardCd]
(
	-- Add the parameters for the function here
)
RETURNS nvarchar(50)
BEGIN
	-- Declare the return variable here
	DECLARE @CardCd nvarchar(50)

	-- Add the T-SQL statements to compute the return value here
	SET @CardCd = (SELECT TOP (1) Code
	  FROM MAS_CardBase a
	  WHERE NOT EXISTS(SELECT CardCd FROM MAS_Cards WHERE MAS_Cards.CardCd = a.Code)
	  ORDER BY [Guid_Cd])

	-- Return the result of the function
	RETURN @CardCd

END