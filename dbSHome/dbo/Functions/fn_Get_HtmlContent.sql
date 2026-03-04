
CREATE FUNCTION [dbo].[fn_Get_HtmlContent](@value nvarchar(4000))
RETURNS nVarchar(4000)
AS
BEGIN
  DECLARE @content as nVarchar(4000)
  set @content = 
  '<!DOCTYPE html>
<html>
<head>

<style>
img{
 width: 100%;
}
</style>

</head>

<body>
'
+ @value +
'</body>
</html>'

  RETURN @content
END