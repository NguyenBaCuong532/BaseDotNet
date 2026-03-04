-- =============================================
-- Author:		<Author,,Nguyen Trung Tai>
-- Create date: <Create Date, ,02/05/2016>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[ufn_Get_Element_Level_3]
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
			@SecondIndex int,

			@FirstIndexCloseBraket1 int,
			@ChildName1 varchar(100),
			@thirdIndex int

	-- Add the T-SQL statements to compute the return value here
	set @FirstIndexCloseBraket = charindex('>', @XML)

	set @FirstIndex		= charindex('<', @XML) + 1
	set @Length			= @FirstIndexCloseBraket - @FirstIndex
	set @RootName		= replace(substring(@XML, @FirstIndex, @Length), ' ', '')

	set @SecondIndex	= charindex('<', @XML, @FirstIndexCloseBraket) + 1
	set @Length			= charindex('>', @XML, @FirstIndexCloseBraket + 1) - @SecondIndex 
	set @ChildName		= replace(substring(@XML, @SecondIndex, @Length), ' ', '')

	set @thirdIndex	= charindex('<', @XML, @SecondIndex) + 1
	set @Length			= charindex('>', @XML, @FirstIndexCloseBraket + 1) - @thirdIndex 
	set @ChildName1		= replace(substring(@XML, @thirdIndex, @Length), ' ', '')

	-- Return the result of the function
	return @RootName + '/' + @ChildName + '/' + @ChildName1

END