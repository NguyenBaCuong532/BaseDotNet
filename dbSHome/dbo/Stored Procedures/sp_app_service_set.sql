

-- =============================================
-- Author: duongpx
-- Create date: 2025-09-18 09:05:37
-- Description: Tạo/Cập nhật bảng MAS_Requests
-- =============================================
CREATE   procedure [dbo].[sp_app_service_set]
     @userId uniqueidentifier = NULL
    ,@acceptLanguage NVARCHAR(50) = N'vi-VN'
    ,@id int = NULL

    ,@apartmentId int = NULL
    ,@requestKey nvarchar = NULL
    ,@requestDt datetime = NULL
    ,@requestTypeId int = NULL
    ,@comment nvarchar = NULL
    ,@isNow bit = NULL
    ,@atTime datetime = NULL
    ,@status int = NULL
    ,@projectCd nvarchar = NULL
    ,@requestUserId nvarchar = NULL
    ,@thread_id nvarchar = NULL
    ,@rating int = NULL
    ,@review_dt datetime = NULL
    ,@attachOid uniqueidentifier = NULL
    ,@Oid uniqueidentifier = NULL
    ,@review_comment nvarchar = NULL
    ,@close_dt datetime = NULL
    ,@close_by uniqueidentifier = NULL
AS
BEGIN TRY
    SET NOCOUNT ON;
    
    -- Khai báo biến
    DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(250);
    DECLARE @action NVARCHAR(20);

    -- =============================================
    -- VALIDATION - Kiểm tra dữ liệu đầu vào
    -- =============================================
    
    -- Kiểm tra INSERT hay UPDATE
    if exists (select 1 from [MAS_Requests] where [requestId] = @id)
    begin
        -- =============================================
        -- UPDATE - Cập nhật bản ghi
        -- =============================================
        SET @action = N'UPDATE';
        
        -- Thực hiện UPDATE
        UPDATE [dbo].[MAS_Requests]
        SET apartmentId = @apartmentId
	       ,requestKey = @requestKey
	       ,requestDt = @requestDt
	       ,requestTypeId = @requestTypeId
	       ,comment = @comment
	       ,isNow = @isNow
	       ,atTime = @atTime
	       ,status = @status
	       ,projectCd = @projectCd
	       ,requestUserId = @requestUserId
	       ,thread_id = @thread_id
	       ,rating = @rating
	       ,review_dt = @review_dt
	       ,attachOid = @attachOid
	       ,Oid = @Oid
	       ,review_comment = @review_comment
	       ,close_dt = @close_dt
	       ,close_by = @close_by
        WHERE [requestId] = @id;

        SET @valid = 1;
        SET @messages = N'Cập nhật thành công';
    end
    else
    begin
        -- =============================================
        -- INSERT - Thêm mới bản ghi
        -- =============================================
        SET @action = N'INSERT';
        
        -- Tạo ID mới nếu cần
        if @id IS NULL 
            set @id = lower(newid());

        -- Thực hiện INSERT
        INSERT INTO [dbo].[MAS_Requests]
			(apartmentId
	        ,requestKey
	        ,requestDt
	        ,requestTypeId
	        ,comment
	        ,isNow
	        ,atTime
	        ,status
	        ,projectCd
	        ,requestUserId
	        ,thread_id
	        ,rating
	        ,review_dt
	        ,attachOid
	        ,Oid
	        ,review_comment
	        ,close_dt
	        ,close_by
			)
        VALUES
			(@apartmentId
	        ,@requestKey
	        ,@requestDt
	        ,@requestTypeId
	        ,@comment
	        ,@isNow
	        ,@atTime
	        ,@status
	        ,@projectCd
	        ,@requestUserId
	        ,@thread_id
	        ,@rating
	        ,@review_dt
	        ,@attachOid
	        ,@Oid
	        ,@review_comment
	        ,@close_dt
	        ,@close_by
			);

        SET @valid = 1;
        SET @messages = N'Thêm mới thành công';
    end

    -- =============================================
    -- RESULT - Trả về kết quả
    -- =============================================
    SELECT 
        @valid AS valid, 
        @messages AS [messages],
        @id AS id,
        @action AS action;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50),
            @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = ERROR_MESSAGE();
    SET @ErrorProc= ERROR_PROCEDURE();
    SET @AddlInfo = N', @id: ' + ISNULL(CAST(@id AS NVARCHAR(50)), N'NULL');
    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, N'MAS_Requests', N'SET', @SessionID, @AddlInfo;
    
    -- Trả về lỗi
    SELECT 
        0 AS valid, 
        N'Lỗi: ' + ERROR_MESSAGE() AS [messages],
        @id AS id,
        N'ERROR' AS action;
END CATCH