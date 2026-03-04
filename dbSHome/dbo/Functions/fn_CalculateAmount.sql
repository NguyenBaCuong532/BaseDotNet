CREATE FUNCTION fn_CalculateAmount (
    @Price DECIMAL(18,2),
    @Qty INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    RETURN @Qty * @Price
END