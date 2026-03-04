CREATE FUNCTION [fn_invoice_period_name_format] (@date DATETIME)
RETURNS NVARCHAR(250)
AS
BEGIN
    RETURN CONCAT (
            N'Hóa đơn tháng '
            , MONTH(DATEADD(MONTH, 1, @date))
            , '-'
            , YEAR(DATEADD(MONTH, 1, @date))
            )
END