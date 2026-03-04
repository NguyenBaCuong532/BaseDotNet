
-- =============================================
-- Author:		System
-- Create date: 11/17/2025 2:10:52 PM
-- Description:	Lấy các thông báo đã đến lịch gửi (Schedule <= GETDATE() và chưa được gửi)
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_notify_scheduled_get]
    @UserId nvarchar(50) = null,
	@MaxRecords INT = 100
AS
BEGIN TRY
    SET @MaxRecords = ISNULL(@MaxRecords, 100)
    
    -- Lấy các thông báo trong NotifyInbox có Schedule <= GETDATE() và isPublish = 1
    SELECT TOP (@MaxRecords)
        ni.[n_id],
        ni.[actionlist] as [action],
        ni.[createDt]
    FROM [dbo].[NotifyInbox] ni
    WHERE ni.[Schedule] IS NOT NULL
        AND ni.[Schedule] <= GETDATE()
		AND ni.[Schedule] > dateadd(day,-1, GETDATE())
        AND isnull(ni.[send_st],0) <= 1
        AND NOT EXISTS (
            -- Kiểm tra xem đã có thông báo nào được gửi thành công chưa
            SELECT 1 
            FROM [dbo].[NotifySent] ns 
            WHERE ns.[n_id] = ni.[n_id]
                AND (
                    (ni.[is_act_push] = 1 AND ns.[push_st] = 2) OR
                    (ni.[is_act_sms] = 1 AND ns.[sms_st] = 2) OR
                    (ni.[is_act_email] = 1 AND ns.[email_st] = 2)
                )
        )
    ORDER BY ni.[Schedule] ASC

    -- Lấy danh sách người nhận (NotifySent) cho các thông báo trên
  --  SELECT 
  --      ns.[id],
  --      ns.[n_id],
  --  FROM [dbo].[NotifySent] ns
  --  INNER JOIN [dbo].[NotifyInbox] ni ON ns.[n_id] = ni.[n_id]
  --  WHERE ni.[Schedule] IS NOT NULL
  --      AND ni.[Schedule] <= GETDATE()
		--AND ni.[Schedule] > dateadd(day,-1, GETDATE())
  --      AND isnull(ni.[send_st],0) = 0
  --      AND (
  --          (ni.[is_act_push] = 1 AND ns.[push_st] = 1) OR
  --          (ni.[is_act_sms] = 1 AND ns.[sms_st] = 1) OR
  --          (ni.[is_act_email] = 1 AND ns.[email_st] = 1)
  --      )
  --      AND NOT EXISTS (
  --          -- Loại bỏ các thông báo đã được gửi thành công
  --          SELECT 1 
  --          FROM [dbo].[NotifySent] ns2 
  --          WHERE ns2.[n_id] = ni.[n_id]
  --              AND ns2.[id] = ns.[id]
  --              AND (
  --                  (ni.[is_act_push] = 1 AND ns2.[push_st] = 2) OR
  --                  (ni.[is_act_sms] = 1 AND ns2.[sms_st] = 2) OR
  --                  (ni.[is_act_email] = 1 AND ns2.[email_st] = 2)
  --              )
  --      )
  --  ORDER BY ns.[createDt] ASC

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
        @ErrorMsg VARCHAR(200),
        @ErrorProc VARCHAR(50),
        @SessionID INT,
        @AddlInfo VARCHAR(MAX)

    SET @ErrorNum = ERROR_NUMBER()
    SET @ErrorMsg = 'sp_res_notify_scheduled_get ' + ERROR_MESSAGE()
    SET @ErrorProc = ERROR_PROCEDURE()
    SET @AddlInfo = 'MaxRecords: ' + CAST(@MaxRecords AS VARCHAR(10))

    EXEC [dbo].[utl_Insert_ErrorLog] 
        @ErrorNum, 
        @ErrorMsg, 
        @ErrorProc, 
        'NotifyScheduled', 
        'GET', 
        @SessionID, 
        @AddlInfo
END CATCH