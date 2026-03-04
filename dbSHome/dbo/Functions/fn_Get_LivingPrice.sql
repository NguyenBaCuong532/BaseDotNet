CREATE   FUNCTION dbo.fn_Get_LivingPrice
(
    @ProjectCd   nvarchar(30),
    @LivingTypeId int,
    @NumUsed     float
)
RETURNS decimal(18,2)
AS
BEGIN
    DECLARE @amount decimal(18,4) = 0;

    ;WITH tiers AS
    (
        SELECT NumFrom, NumTo, Price
        FROM dbo.PAR_ServiceLivingPrice WITH (NOLOCK)
        WHERE ProjectCd = @ProjectCd AND LivingTypeId = @LivingTypeId
        -- ORDER BY Pos  -- không cần ORDER BY trong set-based SUM
    )
    SELECT @amount =
        SUM(
            CAST(Price AS decimal(18,4))
            *
            CAST(
                CASE
                    WHEN @NumUsed > NumFrom THEN
                        (CASE
                             WHEN NumTo IS NULL THEN @NumUsed
                             WHEN @NumUsed < NumTo THEN @NumUsed
                             ELSE NumTo
                         END) - NumFrom
                    ELSE 0
                END
            AS decimal(18,4))
        )
    FROM tiers;

    RETURN @amount;
END