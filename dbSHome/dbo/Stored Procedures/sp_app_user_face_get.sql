

-- Author:		Duongpx 
-- Create date: 10/24/2024 12:40:18 PM
-- Description:	thông tin file ảnh face
CREATE PROCEDURE [dbo].[sp_app_user_face_get] 
	  @UserId NVARCHAR(50)
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @face_id UNIQUEIDENTIFIER
    SELECT @face_id = face_id FROM userInfo
    WHERE userId = @UserId
    
    ;WITH cte AS(
    SELECT [FileName] = b.file_name
        , [Size] = b.file_size
        , [ContentType] = b.file_type
        , [FilePath] = [dbo].[fn_url_absolute](b.file_url)
        , [Url] = [dbo].[fn_url_absolute](b.file_url)
        , [LastModified] = b.created
        , groupFileId = b.sourceOid
        , b.Oid
        , b.objectName
        , b.bucket
        , b.source_type
        , rn = ROW_NUMBER() OVER(PARTITION BY b.source_type ORDER BY created DESC)
    FROM meta_info b
    WHERE b.sourceOid = @face_id
    )SELECT * FROM cte WHERE rn = 1
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_app_user_face_get' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = 'UserId ' + @UserId

    EXEC utl_ErrorLog_Set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , ''
        , ''
        , @SessionID
        , @AddlInfo
END CATCH