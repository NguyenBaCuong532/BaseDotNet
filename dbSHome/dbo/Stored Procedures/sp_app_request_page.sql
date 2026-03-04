
-- =============================================
-- Author: duongpx
-- Create date: 2025-09-18 08:26:36
-- Description: Grid phân trang cho bảng MAS_Requests
-- =============================================
CREATE   PROCEDURE [dbo].[sp_app_request_page]
      @userId         UNIQUEIDENTIFIER = NULL
    , @apartmentOid UNIQUEIDENTIFIER = NULL
    , @filter         NVARCHAR(30)     = NULL
    , @Offset         INT              = 0
    , @PageSize       INT              = 10
    , @gridWidth      INT              = 0
    , @acceptLanguage NVARCHAR(50)     = N'vi-VN'
	, @ApartmentId	 int = NULL
AS
BEGIN TRY
    SET NOCOUNT ON;
    
    -- Khai báo biến
    DECLARE @Total BIGINT;
    DECLARE @GridKey NVARCHAR(100) = N'view_app_request_page';
	declare @requestKey nvarchar(50) = 'RequestFix' --yêu cầu hỗ trợ sửa chữa
    -- =============================================
    -- VALIDATION - Kiểm tra và validate parameters
    -- =============================================
    SET @Offset   = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @filter   = ISNULL(@filter, N'');
    
    IF @PageSize <= 0 SET @PageSize = 10;
    IF @Offset  <  0 SET @Offset  = 0;

    -- =============================================
    -- COUNT - Đếm tổng số bản ghi
    -- =============================================
    SELECT @Total = COUNT(1) 
	FROM MAS_Requests a
	where a.requestKey = @requestKey
		and a.requestUserId = @userId;

    -- =============================================
    -- RESULT SET 1: METADATA - Thông tin phân trang
    -- =============================================
    SELECT recordsTotal    = @Total,
           recordsFiltered = @Total,
           gridKey         = @GridKey,
           valid           = 1;

    -- =============================================
    -- RESULT SET 2: HEADER - Cấu hình cột (chỉ lầu đầu)
    -- =============================================
    IF @Offset = 0
    BEGIN
        SELECT *
        FROM dbo.fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
        ORDER BY ordinal;
    END

    -- =============================================
    -- RESULT SET 3: DATA - Dữ liệu với phân trang
    -- =============================================
    SELECT a.Oid
		  ,'[' + isnull(a.thread_id,'RQ') + '] ' + b.requestTypeName as requestTypeName
		  ,a.thread_id as requestCode
		  ,a.comment
		  ,a.status as statusId
		  ,a.rating 
		  ,a.requestDt 
		  ,st.objName as statusName
		  ,st.objGroup as statusColor
		  ,ap.RoomCode 
		  ,u.fullName
    FROM MAS_Requests a
	join MAS_Request_Types b on a.requestTypeId = b.requestTypeId
	join MAS_Apartments ap on a.apartmentId = ap.ApartmentId 
	join UserInfo u on a.requestUserId = u.userId 
	left join [dbo].fn_config_data_gets ('request_st') st on a.status = st.objValue 
	where a.requestKey = @requestKey
		and a.requestUserId = @userId
    ORDER BY a.requestDt DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50),
            @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = ERROR_MESSAGE();
    SET @ErrorProc= ERROR_PROCEDURE();
    SET @AddlInfo = N'@Userid: ' + ISNULL(cast(@userId as varchar(50)), N'NULL') + N', @filter: ' + ISNULL(@filter, N'NULL');
    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, N'MAS_Requests', N'Page', @SessionID, @AddlInfo;
    
    -- Trả về lỗi
    SELECT 
        0 AS valid, 
        N'Lỗi: ' + ERROR_MESSAGE() AS [messages];
END CATCH