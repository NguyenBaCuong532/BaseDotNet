CREATE FUNCTION [dbo].[SplitString] 
(
    -- Add the parameters for the function here
    @myString nvarchar(max),
    @deliminator nvarchar(10)
)
RETURNS 
@ReturnTable TABLE 
(
    -- Add the column definitions for the TABLE variable here
    [id] [int] IDENTITY(1,1) NOT NULL,
    [part] [nvarchar](500) NULL
)
AS
BEGIN
        Declare @iSpaces int
        Declare @part varchar(200)

		--if len(@myString) > 0
		--	begin
		--		Insert Into @ReturnTable(part)
		--		select [value]
		--		from STRING_SPLIT(@myString, @deliminator)
		--	end

        --initialize spaces
        Select @iSpaces = charindex(@deliminator,@myString,0)
        While @iSpaces > 0

        Begin
            Select @part = substring(@myString,0,charindex(@deliminator,@myString,0))

            Insert Into @ReturnTable(part)
            Select @part

		Select @myString = substring(@mystring,charindex(@deliminator,@myString,0)+ len(@deliminator),len(@myString) - charindex(' ',@myString,0))


            Select @iSpaces = charindex(@deliminator,@myString,0)
        end

        If len(@myString) > 0
            Insert Into @ReturnTable
            Select @myString

    RETURN 
END