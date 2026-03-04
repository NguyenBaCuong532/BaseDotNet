CREATE FUNCTION dbo.fn_CalculateFreeAmt (
    @FreeRate DECIMAL(18, 2),
    @Qty INT,
    @Price DECIMAL(18, 2)
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    RETURN ISNULL(@FreeRate, 0) * ISNULL(@Qty, 0) * ISNULL(@Price, 0);
END;