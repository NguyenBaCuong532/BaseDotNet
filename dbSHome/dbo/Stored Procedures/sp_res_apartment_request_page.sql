
CREATE PROCEDURE [dbo].[sp_res_apartment_request_page]
    @userId UNIQUEIDENTIFIER,
    @filter NVARCHAR(30) = NULL,
	@ApartmentId INT ,

    @Offset INT = 0,
    @PageSize INT = 10,
    @Total INT = 0 OUT,
    @TotalFiltered INT = 0 OUT,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY

    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @Total = ISNULL(@Total, 0);
    SET @filter = ISNULL(@filter, '');

	if @ApartmentId is null or @ApartmentId = 0
		set @ApartmentId = (SELECT top 1 c.ApartmentId 
		FROM UserInfo a inner join MAS_Apartments c on a.loginName = c.UserLogin 
		 WHERE a.UserId = @UserID)

    IF @PageSize = 0
        SET @PageSize = 10;
    IF @Offset < 0
        SET @Offset = 0;

    SELECT @Total = COUNT(a.RequestId)
	  FROM MAS_Requests a  
		JOIN MAS_Apartments b On a.ApartmentId = b.ApartmentId  
		JOIN MAS_Request_Types c ON a.RequestTypeId = c.RequestTypeId 
		left join CRM_Status s on a.status = s.statusId and s.statusKey = 'Request'
		WHERE c.Category in ('Fix','Ext','Sev')
				and b.ApartmentId  = @ApartmentId

    SET @TotalFiltered = @Total;

    IF @PageSize < 0
    BEGIN
        SET @PageSize = 10;
    END;
    IF @Offset = 0
    BEGIN
        SELECT *
        FROM [dbo].fn_config_list_gets_lang('view_apartment_request_page', 0, @acceptLanguage)
        ORDER BY [ordinal];

    END;
    -- Data
    SELECT a.RequestId
		  ,a.[ApartmentId]
		  ,a.[Comment]
		  ,convert(nvarchar(5),a.RequestDt,108) + ' - ' + convert(nvarchar(10),a.RequestDt,103) as RequestDate
		  ,a.RequestTypeId
		  ,isnull([Status],0) [Status]
		  --,case isnull([Status],0) when 0 then N'Tiếp nhận yêu cầu' when 1 then N'Đã phân công' when 2 then N'Đang xử lý' when 3 then N'Chờ phản hồi' else N'Hoàn thành' end [StatusName]
		  ,s.statusName
		  ,a.IsNow
		  ,a.AtTime
		  ,c.RequestTypeName
		  ,BrokenUrl1 = (select attachUrl from [MAS_Request_Attach] t where t.requestId = a.requestId and t.processId = 0 order by t.id OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY) --offset 0 fetch next 1 rows only)
		  ,BrokenUrl2 = (select attachUrl from [MAS_Request_Attach] t where t.requestId = a.requestId and t.processId = 0 order by t.id OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY)
		  ,BrokenUrl3 = (select attachUrl from [MAS_Request_Attach] t where t.requestId = a.requestId and t.processId = 0 order by t.id OFFSET 2 ROWS FETCH NEXT 1 ROWS ONLY)
		  ,RequestKey
		  ,a.rating
		  ,case when a.status = 4 then 1 else 0 end isFinished
	  FROM MAS_Requests a  
		JOIN MAS_Apartments b On a.ApartmentId = b.ApartmentId  
		JOIN MAS_Request_Types c ON a.RequestTypeId = c.RequestTypeId 
		left join CRM_Status s on a.status = s.statusId and s.statusKey = 'Request'
		WHERE c.Category in ('Fix','Ext','Sev')
				and b.ApartmentId  = @ApartmentId
    ORDER BY  RequestDt DESC OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_request_page' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_ErrorLog_Set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'apartment_request',
                          'GET',
                          @SessionID,
                          @AddlInfo;
END CATCH;