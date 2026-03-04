CREATE   PROCEDURE dbo.sp_res_first_month_payment_method_list
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        N'Thanh toán ngay' AS [name],
        N'PAY_NOW' AS [value]
    UNION ALL
    SELECT
        N'Chuyển công nợ tháng sau',
        N'TRANSFER_DEBT_NEXT_MONTH';
END