
CREATE PROCEDURE [dbo].[sp_res_notify_set]
	 @Id NVARCHAR(100)
	,@n_id  NVARCHAR(100)
	,@UserId nvarchar(50) = null
	,@AcceptLanguage nvarchar(50) = null
AS
	BEGIN TRY	
		UPDATE t2
		   SET t2.push_st = 2 --2: gửi thành công
			  --,[sendDt] = getdate()
		 FROM [dbo].NotifySent t2
			JOIN dbo.NotifyJob nj ON t2.n_id = nj.n_id AND nj.id = t2.id
		 WHERE t2.id = @id
		 AND t2.n_id = @n_id

		 UPDATE t
			   SET t.push_count = ISNULL(push_count,0) + 1
		 FROM [dbo].NotifyInbox t
			JOIN [dbo].NotifySent t2 ON t2.n_id = t.n_id
			JOIN NotifyJob a ON t2.n_id = a.n_id AND t2.id = a.id
			 WHERE a.id = @id
			  AND a.n_id = @n_id

	 DELETE
		FROM NotifyJob
	  WHERE id = @Id AND  n_id = @n_id;

	END TRY
	BEGIN CATCH
		DECLARE	@ErrorNum				INT,
				@ErrorMsg				VARCHAR(200),
				@ErrorProc				VARCHAR(50),

				@SessionID				INT,
				@AddlInfo				VARCHAR(MAX)

		SET @ErrorNum					= ERROR_NUMBER()
		SET @ErrorMsg					= 'sp_resident_notify_set ' + ERROR_MESSAGE()
		SET @ErrorProc					= ERROR_PROCEDURE()

		SET @AddlInfo					= '@Id ' + @Id

		EXEC utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'notify', 'take', @SessionID, @AddlInfo
	END CATCH