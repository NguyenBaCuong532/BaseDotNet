



CREATE PROCEDURE [dbo].[sp_hom_cards_imports] 
	 @UserId NVARCHAR(450)
	,@cards CardsImportType readonly
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
		cardType nvarchar(450),
		projectCd nvarchar(450),
		cardCd nvarchar(450),
		orgId nvarchar(450),
		fullName nvarchar(450),
		code nvarchar(450),
		email nvarchar(450),
		endDate nvarchar(450),
		custId nvarchar(450),
		errors nvarchar(max) default('')
	)

BEGIN TRY
	
	INSERT INTO #cards_import
		(cardType,
		projectCd ,
		cardCd,
		orgId,
		fullName ,
		code ,
		email ,
		endDate,
		custId
		)
	SELECT cardType,
		projectCd ,
		cardCd,
		orgId,
		fullName ,
		code ,
		email ,
		endDate,
		custId
	FROM @cards
	where cardCd is not null
		and code is not null
		--and fullname is not null
		--and ISNUMERIC(rowId) = 1
	--
		
		UPDATE #cards_import
		SET errors = errors + N'; Mã thẻ không được trống'
		WHERE cardCd IS NULL or cardCd = ''

		UPDATE #cards_import
		SET errors = errors + N'; Loại thẻ không được trống'
		WHERE cardType IS NULL or cardType = ''

		UPDATE #cards_import
		SET errors = errors + N'; Tổ chức không được trống'
		WHERE orgId IS NULL or orgId = ''

		UPDATE #cards_import
		SET errors = errors + N'; Tên nhân viên không được trống'
		WHERE fullName IS NULL or fullName = ''

		UPDATE #cards_import
		SET errors = errors + N'; Mã nhân viên không được trống'
		WHERE code IS NULL or code = ''
		

		UPDATE i
		SET errors = errors + N'; Không tìm thấy thông tin mã thẻ [' + i.cardCd + N'] trong kho số!' 
		FROM #cards_import i
		WHERE NOT EXISTS(select * from MAS_CardBase where Code = i.cardCd)
		
		UPDATE i
		SET errors = errors + N'; Số thẻ [' + i.cardCd + N'] đã tồn tại!' 
		FROM #cards_import i
		WHERE EXISTS(select 1 from MAS_Cards where CardCd = i.cardCd)



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
            , 'cards'
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
		DECLARE @CardTypeId int
		SET @CardTypeId = 2
		begin
			INSERT INTO [dbo].[mas_Cards]
			   ([CardCd]
				--,CardId
				,[IssueDate]
				,[ExpireDate]
				,[Card_St]
				--,[IsClose]
				,IsDaily
				--,[IsVip]
				,CustId
				,CardTypeId
				,CardName
				,ProjectCd
				,created_by 
			   )
			SELECT  i.cardCd
				--,@cardIdToRes
				,getdate()
				--,isnull(convert(datetime,@ExpireDate,103),CONVERT(datetime, '28/02/2030', 103))
				,case when (i.endDate = '' or i.endDate is null) then null else CONVERT(datetime,i.endDate,103) end
				,1
				--,0
				,0
				--,1
				,i.custId
				,@CardTypeId
				,i.cardType
				,'0'+ cast(i.projectCd as nvarchar(10))
				,@UserID
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
	SET @ErrorMsg = 'sp_hrm_cards_imports ' + error_message()
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
		  ,'view_import_cards' as GridKey
		  ,recordsTotal = (select count(*) from #cards_import)
		  ,recordsFail = (select count(*) from #cards_import) - @recordsAccepted
		  ,recordsAccepted = case when @accept = 1 then @recordsAccepted else 0 end
		  ,accept = case when @recordsAccepted > 0 then 1 else 0 end
	select * from fn_config_list_gets('view_import_cards',0) 
	
	SELECT i.*,c.cardId 
	FROM #cards_import i
	left join MAS_Cards c on c.cardCd = i.cardCd and c.custId = i.custId
	
	select impId = @impId, fileName = @fileName, fileType = @fileType, fileSize = @fileSize, fileUrl = @fileUrl 
end