CREATE procedure [dbo].[sp_Hom_Card_vehicle_Resident_Set]
	@userId nvarchar(50)	= null
	,@CardCd nvarchar(50)
	,@CustId nvarchar(50) = null
	,@EmployeeId nvarchar(50) = null
	,@CardTypeId int 
	,@IssueDate nvarchar(20)
	,@ExpireDate nvarchar(20)
	,@CardName nvarchar(100)
	,@ProjectCd nvarchar(30)
	--verhicle
	--,@isCardVehicle bit = null
	--,@vehicleTypeId int = null
	--,@vehicleName nvarchar(250) = null
	--,@vehicleNo nvarchar(50) = null
	,@startTime nvarchar(50) = null
	,@endTime nvarchar(50) = null
	,@ServiceId int = 0
AS BEGIN
DECLARE @valid bit = 0, @messages nvarchar(250), @cardIdForHrm int , @CardId int
DECLARE @OutputTbl TABLE (ID INT)
BEGIN TRY
	IF @startTime IS NULL OR @startTime = '' SET @startTime = FORMAT(GETDATE(),'dd/MM/yyyy')
	IF @endTime IS NULL OR @endTime = '' SET @endTime = '01/02/2030'--FORMAT(GETDATE(),'dd/MM/yyyy')
	IF @ExpireDate IS NULL OR @ExpireDate = '' SET @ExpireDate = @endTime

	IF @CardCd IS NULL OR @CardCd = ''
	BEGIN
		SET @valid = 0
		SET @messages = N'Vui lòng nhập mã thẻ' 
		GOTO FINAL
	END
	IF NOT EXISTS(select * from MAS_CardBase where Code = @CardCd)	
	BEGIN
		SET @valid = 0
		SET @messages = N'Không tìm thấy thông tin mã thẻ [' + @CardCd + N'] trong kho số!' 
		GOTO FINAL
	END
	--IF EXISTS(select 1 from MAS_Cards where CardCd = @CardCd and Card_St < 3)
	--BEGIN
	--	SET @valid = 0
	--	set @Messages = N'Số thẻ [' + @CardCd + N'] đang được sử dụng, Cần phải khóa trước khi sử dụng!' 
	--	GOTO FINAL
	--END
	IF EXISTS(select 1 from MAS_Cards where CardCd = @CardCd)
	BEGIN
		SET @valid = 1
        update MAS_Cards
        set ProjectCd = @ProjectCd,
            [ExpireDate] = CONVERT(datetime,@ExpireDate,103)
        where CardCd = @CardCd

		SELECT @cardIdForHrm = CardId
            FROM [MAS_Cards] WHERE [CardCd] = @CardCd
		GOTO FINAL
	END
	IF NOT EXISTS(select * from [MAS_Cards] where [CardCd] = @CardCd)
	BEGIN
		--IF NOT EXISTS(SELECT 1 FROM Employees WHERE custId = @CustId AND departmentCd IS NOT NULL)
		--BEGIN
		--	set @Messages = N'Nhân sự chưa thuộc phòng ban nào.' 
		--	GOTO FINAL
		--END
		    BEGIN TRAN
			    SET @CardTypeId = 2 --the noi bo: s-service
			    IF @ServiceId IS NULL SET @ServiceId = 0
			    INSERT INTO [MAS_Cards]
				    ([CardCd]
				    ,[IssueDate]
				    ,[ExpireDate]
				    ,[Card_St]
				    --,[IsClose]
				    ,IsDaily
				    ,[IsVip]
				    ,CustId
				    ,CardTypeId
				    ,CardName
				    ,ProjectCd
				    ,created_by 
				    )
				    OUTPUT INSERTED.CardId INTO @OutputTbl
			    VALUES
				    (@CardCd
				    ,getdate()
				    --,isnull(convert(datetime,@ExpireDate,103),CONVERT(datetime, '28/02/2030', 103))
				    ,CONVERT(datetime,@ExpireDate,103)
				    ,1
				    ,0
				    ,0
				    --,1
				    ,@CustId
				    ,@CardTypeId
				    ,@CardName
				    ,'0'+ cast(@ProjectCd as nvarchar(10))
				    ,@UserID
				    )

				    COMMIT TRAN;
		
		    SET @valid = 1
		    SET @messages = N'Thêm mới thẻ thành công'
		    --set @cardIdForHrm = @@IDENTITY
		    select top(1) @cardIdForHrm = id
		    FROM @OutputTbl
		    GOTO FINAL
	    END
    ELSE
        BEGIN
            SELECT @cardIdForHrm = CardId
            FROM [MAS_Cards] WHERE [CardCd] = @CardCd
            GOTO FINAL
        END
	--
	SET @valid = 0
	SET @messages = N'Lỗi chưa xác định'
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK
	declare	@ErrorNum				int,
			@ErrorMsg				varchar(200),
			@ErrorProc				varchar(50),

			@SessionID				int,
			@AddlInfo				varchar(max)

	SET @ErrorNum					= error_number()
	SET @ErrorMsg					= 'sp_hrm_employee_card_set ' + error_message()
	SET @ErrorProc					= error_procedure()

	SET @AddlInfo					= ' @user: ' + @userId

	EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'MAS_Cards', 'GET', @SessionID, @AddlInfo

	SET @messages = @ErrorMsg
	SET @valid = 0
END CATCH
FINAL:
SELECT @valid [valid], @messages [messages], @cardIdForHrm as cardIdForHrm
END