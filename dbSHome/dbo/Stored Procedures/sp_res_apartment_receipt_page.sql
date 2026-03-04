
CREATE PROCEDURE [dbo].[sp_res_apartment_receipt_page]
    @userId UNIQUEIDENTIFIER = NULL,
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

    IF @PageSize = 0
        SET @PageSize = 10;
    IF @Offset < 0
        SET @Offset = 0;

    SELECT @Total = COUNT(a.ReceiptId)
	  FROM MAS_Service_Receipts a 
				join MAS_Service_ReceiveEntry d on a.ReceiveId = d.ReceiveId 
			WHERE d.ApartmentId = @ApartmentId

    SET @TotalFiltered = @Total;

    IF @PageSize < 0
    BEGIN
        SET @PageSize = 10;
    END;
    IF @Offset = 0
    BEGIN
        SELECT *
        FROM [dbo].fn_config_list_gets_lang('view_apartment_receipt_page', 0, @acceptLanguage)
        ORDER BY [ordinal];

    END;
    -- Data
    SELECT [ReceiptId]
			  ,[ReceiptNo]
			  ,convert(nvarchar(10),[ReceiptDt],103) as [ReceiptDate]
			  ,a.[ApartmentId]
			  ,a.ReceiveId
			  ,[TranferCd]
			  ,isnull([Object],c.fullName) as [Object]
			  ,a.[Pass_No] as PassNo
			  ,a.[Address]
			  ,[Contents]
			  ,[Attach]
			  ,case when [IsDBCR] = 1 then N'Phiếu thu' else N'Phiếu chi' end as DBCR
			  ,[Amount]
			  ,u.loginName as [CreatorCd]
			  ,format([CreateDate], 'dd/MM/yyyy hh:mm:ss') as [CreateDate]
			  ,[AccountLeft]
			  ,[AccountRight]
			  ,a.[ProjectCd]
			  ,RoomCode 
			  ,c.FullName
	  FROM [dbo].MAS_Service_Receipts a 
		join MAS_Service_ReceiveEntry d on a.ReceiveId = d.ReceiveId 
		join  MAS_Apartments b on d.ApartmentId = b.ApartmentId 
		left join MAS_Customers c on a.CustId = c.CustId
		left join Users u on a.CreatorCd = u.UserId 
		WHERE b.ApartmentId = @ApartmentId
			ORDER BY  a.[ReceiptDt] DESC 
				  offset @Offset rows	
					fetch next @PageSize rows only
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_receipt_page' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_ErrorLog_Set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'apartment_receipt',
                          'GET',
                          @SessionID,
                          @AddlInfo;
END CATCH;