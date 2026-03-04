




CREATE PROCEDURE [dbo].[sp_meta_info_list]
	 @UserId NVARCHAR(50)
	,@sourceOid  uniqueidentifier = null
	,@acceptLanguage nvarchar(50) = 'vi-VN'
AS
BEGIN TRY
	SELECT value = upper(b.Oid)
		  ,name = b.file_name
	FROM meta_info b
	WHERE sourceOid = @sourceOid;
	
END TRY
BEGIN CATCH
	DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
	SET @ErrorNum = error_number()
	SET @ErrorMsg = 'sp_meta_list' + error_message()
	SET @ErrorProc = error_procedure()
	SET @AddlInfo = 'UserId ' + @UserId
	EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '', '', @SessionID, @AddlInfo 
END CATCH