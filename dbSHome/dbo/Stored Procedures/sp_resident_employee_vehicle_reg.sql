
CREATE procedure [dbo].[sp_resident_employee_vehicle_reg]
	@userId	nvarchar(450),
	@CardVehicleId int,
	@VehicleTypeId int = 0,
	@VehicleNo nvarchar(10) ,
	@VehicleName nvarchar(50),
	@VehicleColor nvarchar(50), 
	@isVehicleNone bit = null,
	@CustId nvarchar(50),
	@ProjectCd nvarchar(30) = '',
	@Reason nvarchar(250) = null,
	@CardCd nvarchar(20),
    @StartTime nvarchar(50)=null,
	@EndTime nvarchar(50)=null,
	@note nvarchar(250)=null
	,@ImageLinks VehicleImageType readonly

as
begin
	declare @valid bit = 0
	declare @messages nvarchar(100) = ''	
	declare @cardVehicleIdForHrm int
	DECLARE @OutputTbl TABLE (ID INT)


	begin try	
	declare @cardId int

	--if (@CustId is null or @CustId = '')
	--	set @CustId = (SELECT top 1 CustId FROM dbSHRM.dbo.Employees WHERE UserId = @UserID)

	--IF NOT EXISTS(SELECT top 1 1 FROM dbSHRM.dbo.Employees WHERE custId = @CustId)
	--BEGIN
	--	SET @messages = N'Nhân viên không tồn tại'
	--	SET @valid = 0
	--	GOTO FINAL
	--END

	set @cardId = ISNULL((SELECT top 1 CardId FROM MAS_Cards WHERE CustId = @CustId),0)
	IF @cardId = 0
	BEGIN
		SET @messages = N'Nhân viên chưa được cấp thẻ'
		SET @valid = 0
		GOTO FINAL
	END

	IF NOT EXISTS (SELECT 1 FROM @ImageLinks where Url != '')
	BEGIN
		SET @valid = 0
		SET @messages = N'Dữ liệu ảnh đang trống, không thể cấp thẻ xe!'
		GOTO FINAL
	END

	DECLARE @imageCount INT
	SET @imageCount = (SELECT COUNT(Url) FROM @ImageLinks where Url !='')
	IF @imageCount < 3
	BEGIN
		SET @valid = 0
		SET @messages = N'Chưa tải đủ ảnh, không thể cấp thẻ xe!'
		GOTO FINAL
	END
	
	if  @isVehicleNone = 1
		set @VehicleNo = ''

	set @ProjectCd = isnull(@ProjectCd,'')
	
		
	IF NOT EXISTS(SELECT CardVehicleId FROM MAS_CardVehicle WHERE CardVehicleId = @CardVehicleId)
	BEGIN
		if exists(select 1 from [MAS_CardVehicle] where VehicleNo like @VehicleNo and [Status] < 3) 
		begin
			SET @messages = @VehicleNo + N' đã được sử dụng'
			SET @valid = 0
			GOTO FINAL
		end
		IF EXISTS(SELECT 1 FROM [MAS_CardVehicle] WHERE VehicleTypeId = @VehicleTypeId AND CustId = @CustId AND Status = 1 and CardId = @CardCd)
		BEGIN
			--SET @messages = N'Mỗi thẻ chỉ được thêm 1 loại xe'
			SET @messages = N'Mỗi thẻ chỉ được thêm một xe trong cùng 1 loại xe'
			SET @valid = 0
			GOTO FINAL
		END
		--if not exists(select custid from HRM_Customers where custid = @CustId)
		--begin
		--	set @messages = 'This cust: ' + isnull(@CustId,'') + ' is not exists ! userid: ' + @UserID
		--	set @valid = 0
		--	goto FINAL
		--end
		if exists(select * from [MAS_CardVehicle] where CustId = @CustId and [Status] = 0) 
		begin
			set @messages = N'Bạn đang có hồ sơ đăng ký đang đợi duyệt!'
			set @valid = 0
			goto FINAL
		end
		if  @isVehicleNone = 0 and exists(select * from [MAS_CardVehicle] where VehicleNo like @VehicleNo and [Status] = 1) 
		begin
			set @messages = N'Biển số xe đang được sử dụng không được đăng ký trùng!'
			set @valid = 0
			goto FINAL
		end
		BEGIN TRAN
		------------SHOME----------
		INSERT INTO [MAS_CardVehicle]
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
				OUTPUT INSERTED.CardVehicleId INTO @OutputTbl
			VALUES
				(getdate()
				,@CustId
				,@VehicleNo
				,@VehicleTypeId
				,@VehicleName
				,@VehicleColor 
				,convert(datetime,@StartTime,103)
				,convert(datetime,@EndTime,103)
				,0
				,0
				,0
				,@ProjectCd
				,@Reason
				,@CardCd
				,@UserID 
				,getdate()
				,@note
				)
		
		
		--set @cardVehicleIdForHrm = @@IDENTITY
		select top(1) @cardVehicleIdForHrm = id
		FROM @OutputTbl

		INSERT INTO [MAS_CardVehicle_Image] (
			CardVehicleId
			,ImageLink
			,ImageType
			)
		SELECT @cardVehicleIdForHrm
			,[Url]
			,[type]
		FROM @ImageLinks
		-------------------------

		----HRM------
		--INSERT INTO [HRM_CardVehicle]
		--		([AssignDate]
		--		,CustId
		--		,[VehicleNo]
		--		,[VehicleTypeId]
		--		,[VehicleName]
		--		,VehicleColor   -- Màu sắc
		--		,StartTime
		--		,[Status]
		--		,[ServiceId]
		--		,monthlyType
		--		,ProjectCd
		--		,Reason
		--		,CardId
		--		,Mkr_Id 
		--		,Mkr_Dt 
		--		,note   --ghi chú
		--		)
		--	VALUES
		--		(getdate()
		--		,@CustId
		--		,@VehicleNo
		--		,@VehicleTypeId
		--		,@VehicleName
		--		,@VehicleColor 
		--		,getdate()
		--		,0
		--		,0
		--		,0
		--		,@ProjectCd
		--		,@Reason
		--		,@cardId
		--		,@UserID 
		--		,getdate()
		--		,@note
		--		)
		-------------------------------------
		COMMIT
		SET @valid = 1
		set @messages = N'Thêm mới thành công'
	END
	ELSE
	BEGIN
		IF EXISTS (
				SELECT *
				FROM [MAS_CardVehicle]
				WHERE [Status] = 1
					AND CardVehicleId = @CardVehicleId
				)
		BEGIN
			SET @valid = 0
			SET @messages = N'Phương tiện đang ở trạng thái hoạt động. Không thể sửa!'
			GOTO FINAL
		END

		if  @isVehicleNone = 0 and exists(select * from [MAS_CardVehicle] where VehicleNo like @VehicleNo and [Status] = 1 and CardVehicleId <> @CardVehicleId) 
		begin
			set @messages = N'Biển số xe đang được sử dụng không được đăng ký trùng!'
			set @valid = 0
			goto FINAL
		end
		BEGIN TRAN
		---------SHOME-----------
		UPDATE [MAS_CardVehicle]
			SET [VehicleNo] = @VehicleNo
				,[VehicleTypeId] = @VehicleTypeId
				,[VehicleName] = @VehicleName
				,VehicleColor = @VehicleColor 
				,Reason = @Reason 
				,isVehicleNone = @isVehicleNone 
				,[StartTime] = convert(datetime,@StartTime,103)
				,[EndTime] = convert(datetime,@EndTime,103)
				,Auth_id = @UserID 
				,Auth_Dt = getdate()
				,note = @note
			WHERE CardVehicleId = @CardVehicleId

		UPDATE a
		SET a.ImageLink = b.[Url]
		FROM MAS_CardVehicle_Image a
		INNER JOIN @ImageLinks b ON a.Id = b.Id

		INSERT INTO MAS_CardVehicle_Image
		(
			CardVehicleId
			,ImageLink
			,ImageType
		)
		SELECT 
			@CardVehicleId
			,[Url]
			,[Type]
		FROM @ImageLinks
		WHERE Id IS NULL

		-------------HRM---------------
		--UPDATE dbo.[HRM_CardVehicle]
		--	SET [VehicleNo] = @VehicleNo
		--		,[VehicleTypeId] = @VehicleTypeId
		--		,[VehicleName] = @VehicleName
		--		,VehicleColor = @VehicleColor 
		--		,Reason = @Reason 
		--		,isVehicleNone = @isVehicleNone 
		--		--,[StartTime] = convert(datetime,@StartTime,103)
		--		,[EndTime] = convert(datetime,@EndTime,103)
		--		,Auth_id = @UserID 
		--		,Auth_Dt = getdate()
		--		,note = @note
		--	WHERE CardVehicleId = @CardVehicleId
	---------------------------------------------------
	COMMIT
			SET @valid = 1
			SET @messages = N'Cập nhật thành công'
	END
				

	end try
	begin catch
		IF @@TRANCOUNT > 0 ROLLBACK
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hrm_Update_Employee_VehicleReg ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@Cif_no ' + @CustId 

		set @valid = 0
		set @messages = error_message()

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardVehicleEmp', 'Insert', @SessionID, @AddlInfo
	end catch
	FINAL:
	select @valid as valid
		  ,@messages as [messages]
		  ,@cardVehicleIdForHrm as cardVehIdForHrm
end