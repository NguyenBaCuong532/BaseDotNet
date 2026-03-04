--EXEC sp_res_receivable_bill_get @userId = 'dea0d445-d934-4769-902f-843a517ebcc1',@apartmentId = 5565,@GridKey = 'view_receivable_bill_page'
-- Lịch sử hóa đơn
CREATE PROCEDURE [dbo].[sp_res_receivable_bill_get]
    @userId UNIQUEIDENTIFIER,
    @filter NVARCHAR(30) = NULL,
	@apartmentId INT ,
	@ToDate			nvarchar(20) = NULL,

    @Offset INT = 0,
    @PageSize INT = 10,
    @Total INT = 0 OUT,
    @TotalFiltered INT = 0 OUT,
	@GridKey		nvarchar(100) out,
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY

    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @Total = ISNULL(@Total, 0);
    SET @filter = ISNULL(@filter, '');
	set		@GridKey				= 'view_receivable_bill_page'

	if @ApartmentId is null or @ApartmentId = 0
		set @ApartmentId = (SELECT top 1 c.ApartmentId FROM MAS_Users a inner join MAS_Apartments c on a.UserLogin = c.UserLogin 
		 WHERE a.UserId = @UserID)

	if @ApartmentId is null
			set @ApartmentId = (SELECT top 1 ApartmentId FROM MAS_Apartment_Member a 
			inner join MAS_Users b on a.CustId=b.CustId WHERE 
				exists(select userid from MAS_Users where CustId = b.CustId and UserId = @UserId)
				)

    IF @PageSize = 0
        SET @PageSize = 10;
    IF @Offset < 0
        SET @Offset = 0;

    SELECT @Total			= count(a.ReceiveId)
	FROM [dbo].MAS_Service_ReceiveEntry a 
	INNER JOIN MAS_Apartments b ON a.ApartmentId = b.ApartmentId
	left join MAS_Service_Receipts c on a.ReceiveId = c.ReceiveId 
	WHERE a.isExpected = 1 
		and (a.IsPayed = 0 or a.TotalAmt - a.PaidAmt > 0)
		and b.ApartmentId = @ApartmentId 


    SET @TotalFiltered = @Total;

    IF @PageSize < 0
    BEGIN
        SET @PageSize = 10;
    END;
    IF @Offset = 0
    BEGIN
        SELECT *
        FROM [dbo].fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
        ORDER BY [ordinal];

    END;
    -- Data
    SELECT a.ReceiveId
			  --,cast(month(a.ToDt) as varchar) [PeriodMonth]
			  --,cast(year(a.ToDt) as varchar) [PeriodYear]
			  ,format(a.ToDt,'MM/yyyy') as PeriodMonth
			  ,convert(nvarchar(10),a.ReceiveDt,103) as ReceivableDate
			  ,format(a.PaidAmt,'###,###,###') as PaidAmt
			  ,format(TotalAmt,'###,###,###') as [TotalAmt]
			  ,convert(nvarchar(10),a.[ExpireDate],103) as [ExpireDate]
			  ,a.[IsPayed]
			  ,convert(nvarchar(10),a.ToDt,103) as toDate
			  , case when a.TotalAmt - a.PaidAmt = 0 then N'Đã thanh toán đủ' else ( case when a.IsPayed = 1 then N'Dư nợ :' + convert(nvarchar(10),format(a.TotalAmt - a.PaidAmt,'###,###,###')) + N'(Chuyển nợ)' end) end StatusPayed
			  --,case when a.IsPayed = 0 then N'Chờ thanh toán' else case when (a.TotalAmt - a.PaidAmt) > 0 then N'Còn nợ: '+ cast(format((a.TotalAmt - a.PaidAmt),'###,###,###') as nvarchar(15)) else N'Đã thanh toán đủ' end end as StatusPayed
			  ,N'Hóa đơn tháng ' + cast(month(a.ToDt) as varchar) + N'/' + cast(year(a.ToDt) as varchar) as Remark 
			  ,b.RoomCode
			  ,b.projectCd as ProjectCd
			  ,'' as FullName
	  FROM [dbo].MAS_Service_ReceiveEntry a 
			JOIN MAS_Apartments b ON a.ApartmentId = b.ApartmentId
			--left join MAS_Service_Receipts c on a.ReceiveId = c.ReceiveId 
			  WHERE a.isExpected = 1 
				and (a.IsPayed = 0 or a.TotalAmt - a.PaidAmt > 0)
				and b.ApartmentId = @apartmentId 
    ORDER BY a.ReceiveDt desc OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_receivable_bill_get' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_ErrorLog_Set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'MAS_Service_ReceiveEntry',
                          'GET',
                          @SessionID,
                          @AddlInfo;
END CATCH;