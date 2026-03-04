--select * from MAS_Apartments where RoomCode ='PH-2601'

-- =============================================
-- Author:		
-- Create date: 
-- Description:	import điện nước
-- =============================================
CREATE procedure [dbo].[sp_res_service_living_imports] 
    @UserId NVARCHAR(50)
    ,@project_code NVARCHAR(10) = NULL
    ,@periods_oid NVARCHAR(50) = NULL
    ,@livingImport LivingImportType readonly
    ,@accept BIT = 0
    ,@check BIT = 0 --- check = 0 thì là Import, check = 1 là Kiểm tra
    ,@livingTypeId int = 1
    ,@is_flexible int = 0
    ,@impId			uniqueidentifier = null
    ,@fileName		nvarchar(200) = null
    ,@fileType		nvarchar(100) = null
    ,@fileSize		bigint	= null
    ,@fileUrl		nvarchar(400) = null
    ,@acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN 
BEGIN TRY
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @valid BIT = 1
    DECLARE @messages NVARCHAR(MAX)
    DECLARE @recordsAccepted BIGINT

    IF NOT EXISTS(SELECT 1 FROM @livingImport)
    BEGIN
        SET @valid = 0
        SET @messages = N'File không có dữ liệu!'
        GOTO FINAL
    END
	
    DECLARE @checkTieuDe NVARCHAR(MAX)
    SELECT TOP 1 @checkTieuDe = ISNULL(room_code,'')+ISNULL(period_month,'')+ISNULL(period_year,'')+ISNULL(from_dt,'')+ISNULL(to_dt,'')+ISNULL(from_num,'')+ISNULL(to_num,0) FROM @livingImport

    --IF ((SELECT TOP(1) CONCAT_WS(' ',room_code,period_month,period_year,from_dt,to_dt,from_num,to_num) FROM @livingImport)= N'Mã căn(*)Tháng(*)Năm(*)Từ ngày(*)Đến ngày(*)Từ số(*)Đến số(*)')
    IF @checkTieuDe <> N'Mã căn(*)Tháng(*)Năm(*)Từ ngày(*)Đến ngày(*)Từ số(*)Đến số(*)' AND @check = 0
    BEGIN
				SET @valid = 0
				SET @messages = N'File mẫu không đúng'
				GOTO FINAL
    END
	
    CREATE TABLE #livingImport(
       room_code			 nvarchar(MAX) 
      ,period_month		 nvarchar(MAX) 
      ,period_year		 nvarchar(MAX) 
      ,from_dt			 nvarchar(MAX) 
      ,to_dt				 nvarchar(MAX) 
      ,from_num			 nvarchar(MAX) 
      ,to_num				 nvarchar(MAX) 
      ,errors			 nvarchar(max) 
    )
	

    INSERT INTO #livingImport
    (
        room_code,
        period_month,
        period_year,
        from_dt,
        to_dt,
        from_num,
        to_num
    )
    
    SELECT *
    FROM @livingImport

    DELETE TOP(1) FROM #livingImport WHERE @check = 0

    SELECT DISTINCT
        wi.room_code
        ,wi.period_month
        ,wi.period_year
        ,wi.from_dt
        ,wi.to_dt
        ,wi.from_num
        ,wi.to_num
        ,b.ApartmentId
        ,CASE WHEN ISNULL(wi.room_code, '') = '' THEN N'Mã căn hộ không được để trống.' ELSE '' END	
            + CASE WHEN b.ApartmentId IS NULL THEN N'Mã căn hộ không tồn tại trong cơ sở dữ liệu.' ELSE '' END	
            + CASE WHEN ISNULL(wi.period_month, '') = '' THEN N'Dữ liệu tháng không được để trống.' ELSE '' END	
            + CASE WHEN ISNULL(wi.period_year, '') = '' THEN N'Dữ liệu năm không được để trống.' ELSE '' END	
            + CASE WHEN ISNULL(wi.from_dt, '') = '' THEN N'Ngày bắt đầu không được để trống.' ELSE '' END	
            + CASE WHEN ISNULL(wi.to_dt, '') = '' THEN N'Ngày kết thúc không được để trống.' ELSE '' END
            + CASE WHEN ISNULL(wi.from_num, '') = '' THEN N'Số bắt đầu không được để trống.' ELSE '' END
            + CASE WHEN ISNULL(wi.to_num, '') = '' THEN N'Số kết thúc không được để trống.' ELSE '' END
            + CASE WHEN try_convert(datetime,wi.from_dt,103) is NULL THEN N'; Ngày bắt đầu không hợp lệ' ELSE '' END
            + CASE WHEN try_convert(datetime,wi.to_dt,103) is NULL THEN N'; Ngày kết thúc không hợp lệ' ELSE '' END
            + CASE WHEN TRY_CONVERT(INT, wi.from_num) > TRY_CONVERT(INT, wi.to_num) THEN N'Từ số phải nhỏ hơn đến số' ELSE '' END
            + CASE WHEN r.IsBill = 1 THEN N'; Kỳ này đã xuất hóa đơn, không sửa được chỉ số' ELSE '' END
        AS errors
    INTO #LivingImportType_Import
    FROM #livingImport wi		
        OUTER APPLY (
            SELECT TOP 1 ApartmentId, RoomCode, projectCd
            FROM MAS_Apartments 
            WHERE (RoomCode = wi.room_code OR REPLACE(REPLACE(RoomCode,'-',''),'.','') = REPLACE(REPLACE(wi.room_code,'-',''),'.',''))
              AND (projectCd = @project_code OR @project_code IS NULL)
            ORDER BY CASE WHEN RoomCode = wi.room_code THEN 0 ELSE 1 END, ApartmentId
        ) b
        OUTER APPLY (
            SELECT TOP 1 IsBill 
            FROM MAS_Service_ReceiveEntry r1 
            WHERE r1.ApartmentId = b.ApartmentId 
              AND MONTH(r1.ToDt) = TRY_CONVERT(INT, wi.period_month)
              AND YEAR(r1.ToDt)  = TRY_CONVERT(INT, wi.period_year)
            ORDER BY r1.ReceiveId DESC
        ) r

    UPDATE a SET a.errors = a.errors + N'Không có dữ liệu hợp đồng điện hoặc nước'
    FROM #LivingImportType_Import a
    WHERE a.ApartmentId IS NOT NULL 
      AND NOT EXISTS (select 1 from MAS_Apartment_Service_Living k where k.ApartmentId = a.ApartmentId and k.LivingTypeId = @livingTypeId)

    if @impId is null or not exists(select 1 from ImportFiles where impId = @impId) and @fileName is not null
    begin
		    set @impId = newid()
		    INSERT INTO [dbo].[ImportFiles]
			        ([impId]
			        ,[import_type]
			        ,[upload_file_name]
			        ,[upload_file_type]
			        ,[upload_file_url]
			        ,[upload_file_size]
			        ,[created_by]
			        ,[created_dt]
			        ,[row_count]
			        --,[row_new]
			        --,[row_update]
			        --,[row_fail]
			        ,[updated_st])
		        VALUES
			        (@impId
			        ,'living_import'
			        ,@fileName
			        ,@fileType
			        ,@fileUrl
			        ,@fileSize
			        ,@UserId
			        ,getdate()
			        ,(select count(*) from #LivingImportType_Import)
			        --,0
			        --,0
			        --,0
			        ,0
			        )
    END

    IF(@accept = 1)
    BEGIN
        -- kiem tra ton tai nhieu ban ghi trong 1 thang thi xoa 
        Delete t  
        from MAS_Service_Living_Tracking t
            inner join #LivingImportType_Import c on t.ApartmentId = c.ApartmentId
                AND t.PeriodMonth = CONVERT(INT,c.period_month) and t.PeriodYear = CONVERT(INT,c.period_year)
                and t.LivingTypeId = @livingTypeId

        update t
        set t.FromDt = convert(datetime,c.from_dt,103)
            ,t.ToDt = convert(datetime,c.to_dt,103)
            ,t.FromNum = CONVERT(INT,c.from_num)
            ,t.ToNum = CONVERT(INT,c.to_num)
            ,TotalNum = CONVERT(INT,c.to_num) - CONVERT(INT,c.from_num)
        from MAS_Service_Living_Tracking t
            inner join #LivingImportType_Import c on t.ApartmentId = c.ApartmentId
                AND t.PeriodMonth = CONVERT(INT,c.period_month) and t.PeriodYear = CONVERT(INT,c.period_year)
                and t.LivingTypeId = @livingTypeId

        insert into MAS_Service_Living_Tracking
            ([ProjectCd]
            ,periods_oid
            ,[ApartmentId]
            ,[PeriodMonth]
            ,[PeriodYear]
            ,[LivingId]
            ,[FromDt]
            ,[ToDt]
            ,[LivingTypeId]
            ,[FromNum]
            ,[ToNum]
            ,[TotalNum]
            ,[Amount]
            ,[lastReceivable]
            ,[InputType]
            ,[InputId]
            ,[Calculate]
            ,[IsCalculate]
            ,[IsBill]
            ,[IsReceivable]
            ,[trackingSt]
            ,[trackingDt]
            ,[SysDt])
        select
            b.ProjectCd,
            @periods_oid,
            b.ApartmentId,  
            CONVERT(INT,a.period_month),
            CONVERT(INT,a.period_year),
            isnull((select top 1 LivingId from MAS_Apartment_Service_Living k where k.ProjectCd = b.ProjectCd and k.ApartmentId = b.ApartmentId and k.LivingTypeId = @livingTypeId),999999),
            convert(datetime,a.from_Dt,103),
            convert(datetime,a.to_Dt,103),
            @livingTypeId,
            CONVERT(INT,a.from_num),
            CONVERT(INT,a.to_num),
            CONVERT(INT,a.to_num) - CONVERT(INT,a.from_num),
            null,
            null,
            N'Import excel ngày :' + convert(nvarchar(50),GETDATE(),103),
            null,
            null,
            0,
            0,
            0,
            0,
            null,
            getdate()
				from #LivingImportType_Import a
            inner join MAS_Apartments b on b.ApartmentId = a.ApartmentId
				where not exists (select t.TrackingId from MAS_Service_Living_Tracking t where t.ApartmentId = b.ApartmentId  AND t.PeriodMonth = CONVERT(INT,a.period_month) and t.PeriodYear = CONVERT(INT,a.period_year) and t.LivingTypeId = @livingTypeId)  

                       
    END	
    SET @recordsAccepted = (SELECT count(*) FROM #LivingImportType_Import WHERE errors = '')

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK
        
    DECLARE @ErrorNum INT
            ,@ErrorMsg VARCHAR(200)
            ,@ErrorProc VARCHAR(50)
            ,@SessionID INT
            ,@AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_res_service_living_imports ' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = '@UserId ' + @UserId
    SET @valid = 0
    SET @messages = error_message()

    EXEC utl_ErrorLog_Set @ErrorNum
      ,@ErrorMsg
      ,@ErrorProc
      ,'sp_res_service_living_imports'
      ,'Set'
      ,@SessionID
      ,@AddlInfo   
END CATCH
    FINAL:
        IF @valid = 0
        BEGIN
            SELECT @valid as valid
                ,@messages as messages
                ,'view_service_living_import_page' as GridKey
                ,recordsTotal = 0
                ,recordsFail = 0
                ,recordsAccepted = case when @accept = 1 then @recordsAccepted else 0 end
                ,accept = case when @recordsAccepted > 0 then 1 else 0 END

            SELECT * FROM dbo.fn_config_list_gets_lang('view_service_living_import_page', 500, @acceptLanguage)
	
            SELECT NULL

            select impId = @impId, fileName = @fileName, fileType = @fileType, fileSize = @fileSize, fileUrl = @fileUrl

            GOTO FINAL2
        END

        SELECT @valid as valid
              ,@messages as messages
              ,'view_service_living_import_page' as GridKey
              ,recordsTotal = (select count(*) from #LivingImportType_Import)
              ,recordsFail = (select count(*) from #LivingImportType_Import) - @recordsAccepted
              ,recordsAccepted = case when @accept = 1 then @recordsAccepted else 0 end
              ,accept = case when @recordsAccepted > 0 then 1 else 0 end

        SELECT * FROM dbo.fn_config_list_gets_lang('view_service_living_import_page', 500, @acceptLanguage)
      
        SELECT
            room_code
            ,period_month
            ,period_year
            ,from_dt
            ,to_dt
            ,from_num
            ,to_num
            ,apccept = @accept
            ,CASE 
              WHEN errors = ''
                THEN
                  case when @valid = 1 and @accept = 1 then N'<span class="' + 'bg-success' + ' noti-number ml5">' + 'Done' + '</span>'
                    when @valid = 0 and @accept = 1 then N'<span class="' + 'bg-warning' + ' noti-number ml5">' + 'Error' + '</span>'
                    else N'<span class="' + 'bg-success' + ' noti-number ml5">' + 'OK' + '</span>' end
                --ELSE N'<span class="' + 'bg-danger' + ' noti-number ml5">' + STUFF(errors, 1, 2, '') + '</span>'
                ELSE N'<span class="' + 'bg-danger' + ' noti-number ml5">' + errors + '</span>'  
            END errors
        FROM #LivingImportType_Import
        order by errors
        
        select impId = @impId, fileName = @fileName, fileType = @fileType, fileSize = @fileSize, fileUrl = @fileUrl 
    END
FINAL2:



--select * from utl_Error_Log where TableName ='sp_res_service_living_imports'