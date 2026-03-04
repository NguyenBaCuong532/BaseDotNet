-- =============================================
-- Author:		<Author,,Nguyen Trung Tai>
-- Create date: <Create Date, ,02/05/2016>
-- Description:	<Description, ,>
-- =============================================
create FUNCTION [dbo].[ufn_Get_Element_Level_2]
(
	-- Add the parameters for the function here
	@XML NVARCHAR(MAX)
)
RETURNS VARCHAR(100)
AS
BEGIN
	-- Declare the return variable here
	declare @RootName varchar(100),
			@FirstIndex int,
			@Length int,

			@FirstIndexCloseBraket int,
			@ChildName varchar(100),
			@SecondIndex int

	-- Add the T-SQL statements to compute the return value here
	set @FirstIndexCloseBraket = charindex('>', @XML)

	set @FirstIndex		= charindex('<', @XML) + 1
	set @Length			= @FirstIndexCloseBraket - @FirstIndex
	set @RootName		= replace(substring(@XML, @FirstIndex, @Length), ' ', '')

	set @SecondIndex	= charindex('<', @XML, @FirstIndexCloseBraket) + 1
	set @Length			= charindex('>', @XML, @FirstIndexCloseBraket + 1) - @SecondIndex 
	set @ChildName		= replace(substring(@XML, @SecondIndex, @Length), ' ', '')

	-- Return the result of the function
	return @RootName + '/' + @ChildName

END