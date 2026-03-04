CREATE PROCEDURE [dbo].[sp_res_card_base_del]
    @UserId UNIQUEIDENTIFIER = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
    , @id UNIQUEIDENTIFIER
    , @project_code NVARCHAR(50) = NULL
AS
BEGIN
    BEGIN TRY
        DECLARE @valid BIT = 0;
        DECLARE @messages NVARCHAR(250);

        --
        IF NOT EXISTS (SELECT TOP 1 1 FROM MAS_CardBase WHERE Guid_Cd = @id)
        BEGIN
            SET @messages = N'Thẻ không tồn tại'
            GOTO FINAL
        END

        IF EXISTS (SELECT TOP 1 1 FROM MAS_CardBase WHERE Guid_Cd = @id AND IsUsed = 1)
        BEGIN
            SET @messages = N'Thẻ đã được sử dụng. Không thể xóa'
            GOTO FINAL
        END
        
        SELECT
            b.ProjectCd,
            a.*
        INTO #MAS_CardBase
        FROM
            MAS_CardBase a
            INNER JOIN MAS_Cards b ON a.Code = b.CardCd
        WHERE a.Guid_Cd = @id
        
        IF EXISTS(SELECT TOP 1 1 FROM #MAS_CardBase)
        BEGIN
            DECLARE @ExistProjectName NVARCHAR(100) = (SELECT TOP 1 b.projectName
                                                        FROM
                                                            #MAS_CardBase a
                                                            INNER JOIN MAS_Projects b ON b.ProjectCd = a.ProjectCd);
            SET @messages = N'Thẻ đã được gán cho dự án "' + @ExistProjectName + N'". Không thể xóa'
            GOTO FINAL
        END

        --
        DELETE MAS_CardBase
        WHERE Guid_Cd = @id

        SET @valid = 1
        SET @messages = N'Xóa thẻ thành công'

        --
        FINAL:

        SELECT valid = @valid
            , messages = @messages
    END TRY

    BEGIN CATCH
        DECLARE @ErrorNum INT
            , @ErrorMsg VARCHAR(200)
            , @ErrorProc VARCHAR(50)
            , @SessionID INT
            , @AddlInfo VARCHAR(MAX);

        SET @ErrorNum = ERROR_NUMBER();
        SET @ErrorMsg = 'sp_res_card_base_del' + ERROR_MESSAGE();
        SET @ErrorProc = ERROR_PROCEDURE();
        SET @AddlInfo = '';
        SET @valid = 0;
        SET @messages = ERROR_MESSAGE();

        EXEC utl_Insert_ErrorLog @ErrorNum
            , @ErrorMsg
            , @ErrorProc
            , 'MAS_CardBase'
            , 'DEL'
            , @SessionID
            , @AddlInfo;
    END CATCH;

    SELECT @valid AS valid
        , @messages AS [messages];
END;