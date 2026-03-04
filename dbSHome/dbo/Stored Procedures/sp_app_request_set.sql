

-- =============================================
-- Author: duongpx
-- Create date: 2025-09-18 08:26:36
-- Description: Tạo/Cập nhật bảng MAS_Requests
-- =============================================
CREATE   procedure [dbo].[sp_app_request_set]
     @userId uniqueidentifier = NULL
    ,@acceptLanguage NVARCHAR(50) = N'vi-VN'
    ,@requestId uniqueidentifier = NULL

    ,@apartmentId int = NULL
    ,@requestKey nvarchar(50) = NULL
    ,@requestDt nvarchar(20) = NULL
    ,@requestTypeId int = NULL
    ,@comment nvarchar(max) = NULL
    ,@isNow bit = NULL
    ,@atTime nvarchar(20) = NULL
    --,@status int = NULL
    ,@projectCd nvarchar(50) = NULL
    ,@attachOid uniqueidentifier = NULL
    --,@rating int = NULL
    --,@review_dt datetime = NULL
AS
BEGIN TRY
    SET NOCOUNT ON;
    
    -- Khai báo biến
    DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(250);
    DECLARE @action NVARCHAR(20);
	declare @thread_id nvarchar(50);

	select top 1 @projectCd = a.projectCd, @apartmentId = a.ApartmentId
		from MAS_Apartment_Member ap 
		join MAS_Apartments a on ap.ApartmentId = a.ApartmentId
        JOIN UserInfo u ON ap.CustId = u.CustId
		where u.userId = @UserId and ap.main_st = 1
    -- =============================================
    -- VALIDATION - Kiểm tra dữ liệu đầu vào
    -- =============================================
    
    -- Kiểm tra INSERT hay UPDATE
    if exists (select 1 from [MAS_Requests] where Oid = @requestId)
    begin
        -- =============================================
        -- UPDATE - Cập nhật bản ghi
        -- =============================================
        SET @action = N'UPDATE';
        
        -- Thực hiện UPDATE
        UPDATE [dbo].[MAS_Requests]
        SET apartmentId = @apartmentId
	       ,requestKey = @requestKey
	       ,requestDt = convert(datetime,@requestDt,103)
	       ,requestTypeId = @requestTypeId
	       ,comment = @comment
	       ,isNow = @isNow
	       ,atTime = convert(datetime,@atTime,108)
	       --,status = @status
	       ,attachOid = @attachOid
	       ,requestUserId = @userId
	       --,thread_id = @thread_id
	       --,rating = @rating
	       --,review_dt = @review_dt
        WHERE Oid = @requestId;

        SET @valid = 1;
        SET @messages = N'Cập nhật thành công';
    end
    else
    begin
        -- =============================================
        -- INSERT - Thêm mới bản ghi
        -- =============================================
        SET @action = N'INSERT';
        set @thread_id = 'RQ-' + cast(DATEDIFF(second,'1970-01-01',getdate()) as varchar(50))
        -- Tạo ID mới nếu cần
        if @requestId IS NULL 
            set @requestId = lower(newid());

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
	        ,attachOid
	        ,thread_id
	        --,review_dt
			,Oid
			)
        VALUES
			(@apartmentId
	        ,@requestKey
	        ,convert(datetime,@requestDt,103)
	        ,@requestTypeId
	        ,@comment
	        ,@isNow
	        ,convert(datetime,@atTime,108)
	        ,0
	        ,@projectCd
	        ,@userId
	        ,@attachOid
	        ,@thread_id
	        --,@review_dt
			,@requestId
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
        @requestId AS id,
        @action AS action;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50),
            @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = ERROR_MESSAGE();
    SET @ErrorProc= ERROR_PROCEDURE();
    SET @AddlInfo = N'@Userid: ' 
    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, N'MAS_Requests', N'SET', @SessionID, @AddlInfo;
    
    -- Trả về lỗi
    SELECT 
        0 AS valid, 
        N'Lỗi: ' + ERROR_MESSAGE() AS [messages],
        @requestId AS id,
        N'ERROR' AS action;
END CATCH