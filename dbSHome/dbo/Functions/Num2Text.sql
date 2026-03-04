CREATE FUNCTION [dbo].[Num2Text](@Number decimal)
RETURNS nvarchar(1000) AS 
BEGIN 

    DECLARE @sNumber nvarchar(1000)
    DECLARE @Return	nvarchar(1000)
    DECLARE @mLen int
    DECLARE @i int

    DECLARE @mDigit int
    DECLARE @mGroup int
    DECLARE @mTemp nvarchar(1000)
    DECLARE @mNumText nvarchar(1000)

    SELECT @sNumber=LTRIM(STR(@Number))
    SELECT @mLen = Len(@sNumber)

    SELECT @i=1
    SELECT @mTemp=''
    
    IF(SUBSTRING(@sNumber, @i, 1) = '-')
    BEGIN
        SELECT @mTemp=N'âm '
        SET @i = (@i + 1);
    END

    WHILE @i <= @mLen
    BEGIN
        SELECT @mDigit=SUBSTRING(@sNumber, @i, 1)

        IF @mDigit=0
            SELECT @mNumText=N'không'
        ELSE
        BEGIN
            IF @mDigit=1 SELECT @mNumText=N'một'
            ELSE IF @mDigit=2 SELECT @mNumText=N'hai'
            ELSE IF @mDigit=3 SELECT @mNumText=N'ba'
            ELSE IF @mDigit=4 SELECT @mNumText=N'bốn'
            ELSE IF @mDigit=5 SELECT @mNumText=N'năm'
            ELSE IF @mDigit=6 SELECT @mNumText=N'sáu'
            ELSE IF @mDigit=7 SELECT @mNumText=N'bảy'
            ELSE IF @mDigit=8 SELECT @mNumText=N'tám'
            ELSE IF @mDigit=9 SELECT @mNumText=N'chín'
        END

        SELECT @mTemp = @mTemp + ' ' + @mNumText

        IF (@mLen = @i)
            BREAK

        Select @mGroup=(@mLen - @i) % 9

        IF @mGroup=0
        BEGIN
            SELECT @mTemp = @mTemp + N' tỷ'

            If SUBSTRING(@sNumber, @i + 1, 3) = N'000' 
                SELECT @i = @i + 3

            If SUBSTRING(@sNumber, @i + 1, 3) = N'000' 
                SELECT @i = @i + 3

            If SUBSTRING(@sNumber, @i + 1, 3) = N'000' 
                SELECT @i = @i + 3
        END 
        ELSE IF @mGroup=6
        BEGIN
            SELECT @mTemp = @mTemp + N' triệu'

            If SUBSTRING(@sNumber, @i + 1, 3) = N'000' 
                SELECT @i = @i + 3

            If SUBSTRING(@sNumber, @i + 1, 3) = N'000' 
                SELECT @i = @i + 3
        END
        ELSE IF @mGroup=3
        BEGIN
            SELECT @mTemp = @mTemp + N' nghìn'

            If SUBSTRING(@sNumber, @i + 1, 3) = N'000' 
                SELECT @i = @i + 3

        END
        ELSE
        BEGIN
            Select @mGroup=(@mLen - @i) % 3

            IF @mGroup=2	
                SELECT @mTemp = @mTemp + N' trăm'
            ELSE IF @mGroup=1
                SELECT @mTemp = @mTemp + N' mươi'	
        END

        SELECT @i=@i+1
    END

    --'Loại bỏ trường hợp x00

    SELECT @mTemp = Replace(@mTemp, N'không mươi không', '')

    --'Loại bỏ trường hợp 00x

    SELECT @mTemp = Replace(@mTemp, N'không mươi ', N'linh ')

    --'Loại bỏ trường hợp x0, x>=2

    SELECT @mTemp = Replace(@mTemp, N'mươi không', N'mươi')

    --'Fix trường hợp 10

    SELECT @mTemp = Replace(@mTemp, N'một mươi', N'mười')

    --'Fix trường hợp x4, x>=2

    SELECT @mTemp = Replace(@mTemp, N'mươi bốn', N'mươi tư')

    --'Fix trường hợp x04 

    SELECT @mTemp = Replace(@mTemp, N'linh bốn', N'linh tư')

    --'Fix trường hợp x5, x>=2

    --SELECT @mTemp = Replace(@mTemp, N'mươi năm', N'mươi nhăm')

    --'Fix trường hợp x1, x>=2

    SELECT @mTemp = Replace(@mTemp, N'mươi một', N'mươi mốt')

    --'Fix trường hợp x15

    SELECT @mTemp = Replace(@mTemp, N'mười năm', N'mười lăm')

    --'Bỏ ký tự space

    SELECT @mTemp = LTrim(@mTemp)

    --'Ucase ký tự đầu tiên

    SELECT @Return=UPPER(Left(@mTemp, 1)) + SUBSTRING(@mTemp,2, 1000)

    RETURN @Return
END