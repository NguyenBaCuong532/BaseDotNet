CREATE FUNCTION [dbo].[fn_get_invoice_status] (
    @isPayed BIT
    , @totalAmount DECIMAL
    , @paidAmount DECIMAL
    , @invoice_date DATE
    , @isDebit BIT
    )
RETURNS INT
AS
BEGIN
    DECLARE @current_period DATE = GETDATE()
    DECLARE @check_date DATE

    SET @check_date = EOMONTH(@current_period, - 2)

    RETURN CASE 
            WHEN @isDebit = 1 THEN 4
            WHEN @isPayed = 1
                OR @paidAmount >= @totalAmount
                THEN 2
            WHEN @paidAmount > 0
                THEN 0
            ELSE IIF(@invoice_date <= @check_date, 3, 1)
            END
END