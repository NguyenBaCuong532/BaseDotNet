CREATE FUNCTION [dbo].[fn_CalculateQuantity] (
    @TotalNum INT,
    @NumPersonWater INT,
    @Pos INT,
    @LivingTypeId INT,
    @CaculateWaterType INT,
    @NumFrom INT,
    @NumTo INT
)
RETURNS INT
AS
BEGIN
    DECLARE @Qty INT = 0

    IF @CaculateWaterType = 1 AND @LivingTypeId = 2
    BEGIN
        IF @Pos = 1
            SET @Qty = IIF(@TotalNum > ISNULL(@NumPersonWater, 1) * 4, ISNULL(@NumPersonWater, 1) * 4, @TotalNum)
        ELSE IF @Pos = 2
            SET @Qty = IIF(@TotalNum > ISNULL(@NumPersonWater, 1) * 6,
                           ISNULL(@NumPersonWater, 1) * 2,
                           @TotalNum - IIF(@TotalNum > ISNULL(@NumPersonWater, 1) * 4,
                                           ISNULL(@NumPersonWater, 1) * 4, @TotalNum))
        ELSE IF @Pos = 3
            SET @Qty = IIF(@TotalNum - ISNULL(@NumPersonWater, 1) * 6 < 0, 0,
                           @TotalNum - ISNULL(@NumPersonWater, 1) * 6)
    END
    ELSE
    BEGIN
        IF @TotalNum > @NumFrom
            SET @Qty = IIF(@NumTo IS NULL OR @TotalNum <= @NumTo,
                           @TotalNum - @NumFrom,
                           @NumTo - @NumFrom)
    END

    RETURN @Qty
END