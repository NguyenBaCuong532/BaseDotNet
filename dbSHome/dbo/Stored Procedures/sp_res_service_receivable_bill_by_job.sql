--SELECT * FROM dbo.MAS_Service_ReceiveEntry
--WHERE ReceiveId = 260901
--UPDATE dbo.MAS_Service_ReceiveEntry
--SET IsBill = 0, BillUrl = NULL, BillViewUrl = NULL,bill_st = 0
--WHERE ReceiveId = 260901
--select * from MAS_Service_ReceiveEntry where ReceiveId =329485
CREATE PROCEDURE [dbo].[sp_res_service_receivable_bill_by_job]
	@UserId nvarchar(50) = null
	,@AcceptLanguage nvarchar(50) = null
	,@receiveIds nvarchar(max) = null
AS
BEGIN TRY
-- Tạo bảng tạm trước
		CREATE TABLE #tmpId (
			Id NVARCHAR(50)
		);

		-- Insert dữ liệu từ hàm split string vào
		INSERT INTO #tmpId (Id)
		SELECT value
		FROM dbo.fn_SplitString(@receiveIds, ',');


    SELECT  s.ReceiveId
    FROM [MAS_Service_ReceiveEntry] s
	JOIN #tmpId t on s.ReceiveId = t.Id
    WHERE bill_st = 1
	and 
	(
              IsBill = 0
              OR IsBill IS NULL
          )
    ORDER BY s.SysDate;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_service_receivable_bill_by_job ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = '';

    EXEC utl_Insert_ErrorLog @ErrorNum,
                             @ErrorMsg,
                             @ErrorProc,
                             'Receivable_Bill',
                             'Get',
                             @SessionID,
                             @AddlInfo;
END CATCH;