CREATE FUNCTION [dbo].[fn_CalculatePeriod]
(
    @TotalNum INT,
    @NumPersonWater INT,
    @SortOrder INT,
    @LivingTypeId INT,
    @CaculateWaterType INT,
    @StartValue INT,
    @EndValue INT,
    @UnitPrice DECIMAL(18,2),
    @EffectiveDate DATE,
    @ExpiryDate DATE
)
RETURNS TABLE
AS
RETURN
(
    WITH CTE AS (SELECT
                    DaysInPeriod = DATEDIFF(DAY, @EffectiveDate, ISNULL(@ExpiryDate, EOMONTH(@EffectiveDate))) + 1,
                    DaysInMonth = DATEDIFF(DAY, DATEFROMPARTS(YEAR(@EffectiveDate), MONTH(@EffectiveDate), 1), EOMONTH(@EffectiveDate)) + 1
                )
    SELECT
        TotalNum_Period = ROUND(@TotalNum * 1.0 * DaysInPeriod / DaysInMonth, 0),
        Quantity = dbo.fn_CalculateQuantity_New(ROUND(@TotalNum * 1.0 * DaysInPeriod / DaysInMonth, 0),
                                                @NumPersonWater,
                                                @SortOrder,
                                                @LivingTypeId,
                                                @CaculateWaterType,
                                                @StartValue,
                                                @EndValue),
        Price = @UnitPrice,
        Amount =  @UnitPrice * dbo.fn_CalculateQuantity_New(ROUND(@TotalNum * 1.0 * DaysInPeriod / DaysInMonth, 0),
                                                            @NumPersonWater,
                                                            @SortOrder,
                                                            @LivingTypeId,
                                                            @CaculateWaterType,
                                                            @StartValue,
                                                            @EndValue)
    FROM CTE
);