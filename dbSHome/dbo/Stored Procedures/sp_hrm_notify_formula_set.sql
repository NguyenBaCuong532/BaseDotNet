

-- =============================================
-- Author:		duongpx
-- Create date: 7/13/2024 9:55:31 PM
-- Description:	Lưu công thức thông báo và tự động tạo các field từ formula
-- Updated: 2025-01-XX - Thêm logic parse formula và tạo NotifyField
-- =============================================
CREATE      PROCEDURE [dbo].[sp_hrm_notify_formula_set]
	@userId			nvarchar(450),
	@formulaId				uniqueidentifier,
	@formula		nvarchar(max),
	@note			nvarchar(500),
	@name			nvarchar(200),
	--@parentId		uniqueidentifier,
	@to_type		int = 0,
	@app_st			int

as
begin
	declare @valid bit = 1
	declare @messages nvarchar(300) = N'Thành công'
	declare @actualFormulaId uniqueidentifier = @formulaId
	begin try	

	IF EXISTS(SELECT formulaId FROM NotifyFormula WHERE formulaId = @formulaId)
	begin

		UPDATE [dbo].[NotifyFormula]
		   SET [formula] = @formula
			  ,[name] = @name
			  ,[app_st] = @app_st
			  ,note	= @note
			  ,to_type = @to_type
			  ,updated_by = @userId
			  ,updated_at = getdate()
		 WHERE formulaId = @formulaId
		
		SET @actualFormulaId = @formulaId

	end
	else
	begin
		SET @actualFormulaId = newid()
		INSERT INTO [dbo].[NotifyFormula]
			   ([formulaId]
			   ,[formula] 
			   ,[name] 
			   ,[app_st]
			   ,[created_by]
			   ,[created_at]
			   ,note
			   ,to_type
			   )
		 VALUES
			   (@actualFormulaId
			   ,@formula
			   ,@name
			   ,@app_st
			   ,@UserID
			   ,getdate()
			   ,@note
			   ,@to_type
			   )
	end
	
	-- Execute formula với tham số NULL để tạo bảng tạm và lấy metadata
	-- Thay thế các placeholder trong formula bằng NULL tùy theo to_type
	DECLARE @execFormula NVARCHAR(MAX) = @formula;
	
	-- Thay thế các placeholder dựa trên to_type
	IF @to_type = 0 -- empId
	BEGIN
		SET @execFormula = REPLACE(@execFormula, '{empId}', 'NULL');
		SET @execFormula = REPLACE(@execFormula, '{n_id}', 'NULL');
		SET @execFormula = REPLACE(@execFormula, '{sourceId}', 'NULL');
		SET @execFormula = REPLACE(@execFormula, '{organizeId}', 'NULL');
	END
	ELSE IF @to_type = 1 -- canId
	BEGIN
		SET @execFormula = REPLACE(@execFormula, '{canId}', 'NULL');
		SET @execFormula = REPLACE(@execFormula, '{sourceId}', 'NULL');
	END
	ELSE IF @to_type = 2 -- custId
	BEGIN
		SET @execFormula = REPLACE(@execFormula, '{custId}', 'NULL');
		SET @execFormula = REPLACE(@execFormula, '{sourceId}', 'NULL');
	END
	
	-- Tạo bảng tạm để lưu kết quả và metadata
	-- Sử dụng bảng tạm local với tên cố định (SQL Server sẽ tự thêm suffix session ID)
	DECLARE @tempTablePrefix NVARCHAR(100) = '#NotifyFormula_' + REPLACE(REPLACE(REPLACE(CAST(NEWID() AS NVARCHAR(36)), '-', ''), '{', ''), '}', '');
	DECLARE @sqlCreateTemp NVARCHAR(MAX);
	DECLARE @sqlGetMetadata NVARCHAR(MAX);
	DECLARE @actualTempTableName NVARCHAR(200);
	
	-- Tạo bảng tạm từ kết quả của formula
	-- Sử dụng SELECT INTO để tạo bảng tạm với cấu trúc
	BEGIN TRY
		-- Tạo bảng tạm với cấu trúc từ formula (TOP 0 để chỉ lấy cấu trúc, không lấy dữ liệu)
		SET @sqlCreateTemp = 'SELECT TOP 0 * INTO ' + @tempTablePrefix + ' FROM (' + @execFormula + ') AS t';
		EXEC sp_executesql @sqlCreateTemp;
		
		-- Tìm tên bảng tạm thực tế (có suffix session ID) từ tempdb
		SELECT TOP 1 @actualTempTableName = t.name
		FROM tempdb.sys.tables t
		WHERE t.name LIKE @tempTablePrefix + '%'
		ORDER BY t.create_date DESC;
		
		IF @actualTempTableName IS NULL
		BEGIN
			-- Nếu không tìm thấy, thử tìm bảng mới nhất có pattern
			SELECT TOP 1 @actualTempTableName = t.name
			FROM tempdb.sys.tables t
			WHERE t.name LIKE '#NotifyFormula_%'
			ORDER BY t.create_date DESC;
		END
		
		-- Lấy metadata (column name và data type) từ bảng tạm
		DECLARE @columnName NVARCHAR(128);
		DECLARE @dataType NVARCHAR(128);
		DECLARE @fieldName NVARCHAR(100);
		DECLARE @fieldId UNIQUEIDENTIFIER;
		DECLARE @fieldType NVARCHAR(50);
		DECLARE @tableName NVARCHAR(100);
		
		-- Query metadata từ tempdb với tên bảng thực tế
		SET @sqlGetMetadata = N'
		SELECT 
			c.COLUMN_NAME,
			c.DATA_TYPE,
			c.TABLE_NAME
		FROM tempdb.INFORMATION_SCHEMA.COLUMNS c
		WHERE c.TABLE_NAME = ''' + @actualTempTableName + '''
		ORDER BY c.ORDINAL_POSITION';
		
		-- Tạo bảng tạm để lưu metadata
		DECLARE @metadata TABLE (
			COLUMN_NAME NVARCHAR(128),
			DATA_TYPE NVARCHAR(128),
			TABLE_NAME NVARCHAR(128)
		);
		
		INSERT INTO @metadata
		EXEC sp_executesql @sqlGetMetadata;
		
		-- Duyệt qua từng cột và tạo/update NotifyField
		DECLARE metadata_cursor CURSOR FOR
		SELECT COLUMN_NAME, DATA_TYPE, TABLE_NAME
		FROM @metadata;
		
		OPEN metadata_cursor;
		FETCH NEXT FROM metadata_cursor INTO @columnName, @dataType, @tableName;
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @fieldName = @columnName;
			
			-- Map data type sang field_type
			SET @fieldType = CASE 
				WHEN @dataType IN ('date', 'datetime', 'datetime2', 'smalldatetime') THEN 'date'
				WHEN @dataType IN ('time') THEN 'time'
				WHEN @dataType IN ('int', 'bigint', 'smallint', 'tinyint') THEN 'number'
				WHEN @dataType IN ('decimal', 'numeric', 'float', 'real', 'money', 'smallmoney') THEN 'currency'
				WHEN @dataType IN ('bit') THEN 'boolean'
				ELSE 'text'
			END;
			
			-- Kiểm tra field đã tồn tại chưa
			SELECT @fieldId = fieldId
			FROM NotifyField
			WHERE fieldName = @fieldName AND app_st = 1;
			
			IF @fieldId IS NULL
			BEGIN
				-- Tạo field mới
				SET @fieldId = NEWID();
				INSERT INTO NotifyField
				(
					fieldId,
					fieldName,
					fieldLabel,
					formulaId,
					field_type,
					app_st,
					created_by,
					created_at
				)
				VALUES
				(
					@fieldId,
					@fieldName,
					@fieldName, -- Mặc định label = name
					@formulaId,
					@fieldType,
					1,
					@userId,
					GETDATE()
				);
			END
			ELSE
			BEGIN
				-- Update field hiện có (chỉ update nếu cần)
				UPDATE NotifyField
				SET field_type = ISNULL(field_type, @fieldType),
					updated_by = @userId,
					updated_at = GETDATE()
				WHERE fieldId = @fieldId;
			END
			
			FETCH NEXT FROM metadata_cursor INTO @columnName, @dataType, @tableName;
		END
		
		CLOSE metadata_cursor;
		DEALLOCATE metadata_cursor;
		
		-- Xóa bảng tạm (bảng tạm local sẽ tự động xóa khi kết thúc session, nhưng xóa sớm để tránh conflict)
		IF @actualTempTableName IS NOT NULL
		BEGIN
			SET @sqlCreateTemp = 'DROP TABLE ' + @actualTempTableName;
			EXEC sp_executesql @sqlCreateTemp;
		END
		
	END TRY
	BEGIN CATCH
		-- Nếu có lỗi khi execute formula, bỏ qua việc tạo field
		-- Không ảnh hưởng đến việc lưu formula
		DECLARE @parseError NVARCHAR(MAX) = ERROR_MESSAGE();
		-- Có thể log lỗi nếu cần
		-- PRINT 'Lỗi khi parse formula: ' + @parseError;
		
		-- Xóa bảng tạm nếu có
		IF @actualTempTableName IS NOT NULL
		BEGIN
			SET @sqlCreateTemp = 'DROP TABLE ' + @actualTempTableName;
			EXEC sp_executesql @sqlCreateTemp;
		END
	END CATCH
			   	
		

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_hrm_notify_formula_set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@ ' + cast(0  as varchar)
		set @valid = 0
		set @messages = error_message()

		exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'NotifyFormula', 'Set', @SessionID, @AddlInfo
	end catch

	select @valid as valid
	      ,@messages as [messages]
	      ,@actualFormulaId as formulaId

	end