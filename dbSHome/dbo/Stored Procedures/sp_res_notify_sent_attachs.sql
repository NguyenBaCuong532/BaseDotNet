


-- =============================================
-- Author:		duongpx
-- Create date: 11/25/2024 4:41:11 PM
-- Description:	lấy danh sách file gửi mail
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_notify_sent_attachs]
	 @UserId NVARCHAR(50) = NULL
	,@groupFileId  uniqueidentifier = null
	,@acceptLanguage nvarchar(50) = 'vi-VN'
AS
BEGIN TRY
	SELECT Oid = (b.Oid)
		  ,filePath = dbo.fn_path_cdn_get(b.file_url)
		  ,fileName = b.file_name
		  ,groupFileId = b.sourceOid
	FROM meta_info b
	WHERE sourceOid = @groupFileId;
	
END TRY
BEGIN CATCH
	DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
	SET @ErrorNum = error_number()
	SET @ErrorMsg = 'sp_meta_list' + error_message()
	SET @ErrorProc = error_procedure()
	SET @AddlInfo = 'UserId ' + @UserId
	EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '', '', @SessionID, @AddlInfo 
END CATCH