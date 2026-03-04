


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fn_Get_NewPoint]
(
@id bigint
)
RETURNS nvarchar(10)
BEGIN
	declare @tid nvarchar(50)
	set @tid = cast(@id as nvarchar(10))
	if len(@tid) <5
	begin
		set @tid = right('00000'+ @tid,5)
		set @tid = @tid + right(convert(nvarchar(50), SYSDATETIME()),5)
	end
	else
	begin
		set @tid = right('00000'+ @tid,5)
		set @tid = @tid + right(convert(nvarchar(50), SYSDATETIME()),5)
	end

	RETURN @tid

END