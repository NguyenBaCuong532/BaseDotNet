
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fn_try_cast_excel_to_sql_date]
(
	@serialnumberdate varchar(50), @serial_is bit
)
RETURNS smalldatetime
AS
BEGIN
	if @serial_is = 0
		RETURN CAST(convert(datetime,@serialnumberdate,103) as smalldatetime)

	IF @serialnumberdate = null OR @serialnumberdate = '' OR ISNUMERIC(@serialnumberdate) = 0 OR @serialnumberdate = '0'
		RETURN NULL
	
		RETURN CAST(CAST(@serialnumberdate AS FLOAT) - 2 as smalldatetime)
	
END