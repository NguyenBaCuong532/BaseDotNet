
-- Author:		Duongpx 
-- Create date: 10/24/2024 12:40:18 PM
-- Description:	thông tin file ảnh
CREATE PROCEDURE [dbo].[sp_meta_info_get]
	 @UserId		NVARCHAR(50)
	,@Oid			uniqueidentifier = null
	,@parentOid		uniqueidentifier = null
	,@acceptLanguage nvarchar(50) = 'vi-VN'
AS
BEGIN TRY

	SELECT Oid				= (b.Oid)
		  ,[FileName]		= b.file_name
		  ,[Size]			= b.file_size
		  ,[ContentType]	= b.file_type
		  ,[FilePath]		= b.file_url
		  ,[Url]			= b.file_url
		  ,[LastModified]	= b.created
		  ,groupFileId		= b.sourceOid
		  ,b.objectName
		  ,b.bucket
		  ,b.source_type
	FROM meta_info b
	WHERE Oid = @Oid
		or sourceOid = @parentOid;
	
END TRY
BEGIN CATCH
	DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
	SET @ErrorNum = error_number()
	SET @ErrorMsg = 'sp_meta_get' + error_message()
	SET @ErrorProc = error_procedure()
	SET @AddlInfo = 'UserId ' + @UserId
	EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '', '', @SessionID, @AddlInfo 
END CATCH