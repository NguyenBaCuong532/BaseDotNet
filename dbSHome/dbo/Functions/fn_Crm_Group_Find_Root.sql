
CREATE FUNCTION [dbo].[fn_Crm_Group_Find_Root](@id int)
RETURNS int
AS
BEGIN
  DECLARE @parentID int
  SELECT @parentID = ParentId
  FROM [dbo].CRM_Group
  WHERE GroupId = @id
  WHILE @parentID != 0
    BEGIN
      SELECT @id = @parentID
      SELECT @parentID = ParentId
      FROM [dbo].CRM_Group
      WHERE GroupId = @id
    END
  RETURN @id 
END