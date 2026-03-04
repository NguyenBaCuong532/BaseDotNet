



CREATE PROCEDURE [dbo].[sp_hom_card_vehicle_imports] 
	 @UserId NVARCHAR(450)
	,@cards CardVehicleImportType readonly
	,@accept BIT = 0
	,@impId UNIQUEIDENTIFIER = NULL
    ,@fileName NVARCHAR(250) = NULL
    ,@fileType NVARCHAR(50) = NULL
    ,@fileSize INT = NULL
    ,@fileUrl NVARCHAR(4000) = NULL
AS
begin
	DECLARE @valid BIT = 1
	DECLARE @messages NVARCHAR(400)
	declare @recordsAccepted bigint
	CREATE TABLE #cards_import(
		ordId nvarchar(450),
		fullName nvarchar(450),
		code nvarchar(450),
		cardCd nvarchar(450),
		vehicle_type nvarchar(450),
		vehicle_no nvarchar(450),
		vehicle_name nvarchar(450),
		start_date nvarchar(450),
		end_date nvarchar(450),
		custId nvarchar(450),
		errors nvarchar(max) default('')
	)

BEGIN TRY
	
	INSERT INTO #cards_import
		(ordId,
		fullName ,
		code,
		cardCd,
		vehicle_type,
		vehicle_no ,
		vehicle_name ,
		start_date ,
		end_date ,
		custId
		)
	SELECT ordId,
		fullName ,
		code,
		cardCd,
		vehicle_type,
		vehicle_no ,
		vehicle_name ,
		start_date ,
		end_date ,
		custId
	FROM @cards
	where cardCd is not null
		--and fullname is not null
		--and ISNUMERIC(rowId) = 1
	--
		
		UPDATE #cards_import
		SET errors = errors + N'; Tổ chức không được trống'
		WHERE ordId IS NULL or ordId = ''

		UPDATE #cards_import
		SET errors = errors + N'; tên nhân viên không được trống'
		WHERE fullName IS NULL or fullName = ''

		UPDATE #cards_import
		SET errors = errors + N'; mã nhân viên không được trống'
		WHERE code IS NULL or code = ''

		UPDATE #cards_import
		SET errors = errors + N'; tên nhân viên không được trống'
		WHERE fullName IS NULL or fullName = ''

		UPDATE #cards_import
		SET errors = errors + N'; mã thẻ không được trống'
		WHERE cardCd IS NULL or cardCd = ''

		UPDATE i
		SET errors = errors + N'; ' + i.vehicle_no + N' đã được sử dụng'
		FROM #cards_import i
		WHERE exists(select 1 from [mas_CardVehicle] where VehicleNo like i.vehicle_no and [Status] < 3) 

	--------------------------------------
	IF @impId IS NULL  OR  NOT EXISTS (
            SELECT 1
            FROM ImportFiles
            WHERE impId = @impId
            )
        AND @fileName IS NOT NULL
	BEGIN
		SET @impId = NEWID()
        INSERT INTO ImportFiles (
            [impId]
            , [import_type]
            , [upload_file_name]
            , [upload_file_type]
            , [upload_file_url]
            , [upload_file_size]
			, [created_by]
			,[created_dt]
            , [row_count]
            
            )
        VALUES (
            @impId
            , 'vehicles'
            , @fileName
            , @fileType
            , @fileUrl
            , @fileSize
            , @userId
			,GETDATE()
			,(SELECT COUNT(*) FROM #cards_import)
            )
    END
	--
	if @accept = 1
	begin
	BEGIN TRAN
		begin
			INSERT INTO [dbo].[mas_CardVehicle]
			   ([AssignDate]
				,CustId
				,[VehicleNo]
				,[VehicleTypeId]
				,[VehicleName]
				,VehicleColor   -- Màu sắc
				,StartTime
				,EndTime
				,[Status]
				,[ServiceId]
				,monthlyType
				,ProjectCd
				,Reason
				,CardId
				,Mkr_Id 
				,Mkr_Dt 
				,note   --ghi chú
			   )
		SELECT  getdate()
				,i.custId
				,i.vehicle_no
				,(select top 1 VehicleTypeId from MAS_VehicleTypes where VehicleTypeName = i.vehicle_type)
				,i.vehicle_name
				,null 
				,convert(datetime,i.start_date,103)
				,convert(datetime,i.end_date,103)
				,0
				,0
				,0
				,null
				,null
				,(select top 1 CardId from MAS_Cards c where c.cardCd = i.cardCd)
				,@UserID 
				,getdate()
				,null
			FROM #cards_import i 

		end
	COMMIT TRAN
	
	end
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK
	DECLARE @ErrorNum INT
		,@ErrorMsg VARCHAR(200)
		,@ErrorProc VARCHAR(50)
		,@SessionID INT
		,@AddlInfo VARCHAR(max)

	SET @ErrorNum = error_number()
	SET @ErrorMsg = 'sp_hom_card_vehicle_imports ' + error_message()
	SET @ErrorProc = error_procedure()
	SET @AddlInfo = '@UserId ' + @UserId
	SET @valid = 0
	SET @messages = error_message()

	EXEC utl_ErrorLog_Set @ErrorNum
		,@ErrorMsg
		,@ErrorProc
		,'employees'
		,'Set'
		,@SessionID
		,@AddlInfo

END CATCH
	set @recordsAccepted = (select count(*) from #cards_import where errors = '')
	UPDATE #cards_import
		SET
		   errors = CASE 
			WHEN errors = ''
				THEN
					case when @valid = 1 and @accept = 1 then N'<span class="' + 'bg-success' + ' noti-number ml5">' + 'Done' + '</span>'
						when @valid = 0 and @accept = 1 then N'<span class="' + 'bg-warning' + ' noti-number ml5">' + 'Error' + '</span>'
						else N'<span class="' + 'bg-success' + ' noti-number ml5">' + 'OK' + '</span>' end
				ELSE N'<span class="' + 'bg-danger' + ' noti-number ml5">' + STUFF(errors, 1, 2, '') + '</span>'  
			END

	select @valid as valid
		  ,@messages as messages
		  ,'view_import_card_vehicle' as GridKey
		  ,recordsTotal = (select count(*) from #cards_import)
		  ,recordsFail = (select count(*) from #cards_import) - @recordsAccepted
		  ,recordsAccepted = case when @accept = 1 then @recordsAccepted else 0 end
		  ,accept = case when @recordsAccepted > 0 then 1 else 0 end
	
	select * from fn_config_list_gets('view_import_card_vehicle',0) 
	
	SELECT i.*--,v.cardvehicleId --= (select top 1 CardVehicleId from MAS_CardVehicle where cardCd = i.cardCd and custId = i.custId and VehicleTypeId = (select top 1 VehicleTypeId from MAS_VehicleTypes where VehicleTypeName = i.vehicle_type)) 
	FROM #cards_import i
	--left join MAS_CardVehicle v on v.cardCd = i.cardCd and v.custId = i.custId
	--left join MAS_VehicleTypes t on t.vehicleTypeName = i.vehicle_type and t.VehicleTypeId = v.VehicleTypeId
	
	select impId = @impId, fileName = @fileName, fileType = @fileType, fileSize = @fileSize, fileUrl = @fileUrl 
end