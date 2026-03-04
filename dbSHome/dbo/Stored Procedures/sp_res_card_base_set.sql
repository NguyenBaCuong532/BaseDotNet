CREATE PROCEDURE [dbo].[sp_res_card_base_set]
    @UserId UNIQUEIDENTIFIER = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
    ,@ids Guidlist READONLY
    , @id VARCHAR(50) = NULL
    , @project_code NVARCHAR(50) = NULL
    ,@projectCode VARCHAR(50)
    ,@type INT
	--,@gd UNIQUEIDENTIFIER = null
AS
BEGIN TRY
    --
    DECLARE @valid BIT, @messages NVARCHAR(250);

    IF NOT EXISTS(SELECT 1 FROM MAS_CardBase cb INNER JOIN @ids i on cb.Guid_Cd = i.id )
    BEGIN
        SET @messages = N'Không tìm thấy bản ghi' 
        GOTO FINAL
    END

    SET NOCOUNT ON;
    DROP TABLE IF EXISTS #test;
    CREATE TABLE #test (#test NVARCHAR(30))
    
    INSERT INTO #test 
    select cb.Code
    from
        MAS_CardBase cb 
        INNER JOIN @ids ids ON cb.Guid_Cd = ids.Id 
    where cb.IsUsed = 1 and cb.ProjectCode is not null

    If (EXISTS (SELECT 1 FROM #test))
    BEGIN
        SET @messages = N'Thẻ đang được dùng, không thể sửa'
        GOTO FINAL
    END
      
    UPDATE cb
    SET
        ProjectCode = @projectCode
        ,[Type] = @type
    FROM
        MAS_CardBase cb
        INNER JOIN @ids ids ON  cb.Guid_Cd = ids.Id
        
    -- Cập nhật lại thông tin nếu thẻ đã được phân và sử dụng tại dự án
    UPDATE a
    SET
        ProjectCd = @projectCode,
        CardTypeId = @type
    FROM
        MAS_Cards a
        INNER JOIN MAS_CardBase cb ON cb.Code = a.CardCd
        INNER JOIN @ids ids ON cb.Guid_Cd = ids.Id

    SET @valid = 1
    SET @messages = N'Phân loại thẻ thành công'

    FINAL:
        SELECT valid = @valid, messages = @messages
        
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_card_classify_field' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'Receipt'
        , 'GetInfo'
        , @SessionID
        , @AddlInfo;
END CATCH;