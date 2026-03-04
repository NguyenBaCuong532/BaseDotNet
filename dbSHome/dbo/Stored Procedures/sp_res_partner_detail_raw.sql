CREATE   PROCEDURE dbo.sp_res_partner_detail_raw
    @id BIGINT
AS
BEGIN
    SELECT TOP 1 *
    FROM dbo.MAS_CardPartner
    WHERE partner_id = @id;
END