

CREATE procedure [dbo].[sp_config_group_set]
	@UserId		nvarchar(450),	
	@id			bigint,
	@mod_cd		nvarchar(50),
	@key_1		nvarchar(150),
	@key_2		nvarchar(150),
	@key_group	nvarchar(50),
	@type_value int,
	@par_desc	nvarchar(350),
	@par_desc_e	nvarchar(350),
	@value1		nvarchar(200),
	@value2		int,
	@intOrder	int,
	@isUsed		bit,
	@acceptLanguage nvarchar (50) = 'vi-VN'

as

begin
	declare @valid bit = 1
	declare @messages nvarchar(300)

	begin try	
	
	IF not Exists(SELECT id FROM sys_config_data WHERE id = @id)
	BEGIN		
	
		INSERT INTO [dbo].[sys_config_data]
			   ([mod_cd]
			   ,[key_1]
			   ,[key_2]
			   ,key_group
			   ,[type_value]
			   ,[par_desc]
			   ,[par_desc_e]
			   ,[value1]
			   ,[value2]
			   ,[intOrder]
			   ,[IsUsed]
			   ,[sys_dt])
		 VALUES
			   (@mod_cd
			   ,@key_1
			   ,@key_2
			   ,@key_group
			   ,@type_value
			   ,@par_desc
			   ,@par_desc_e
			   ,@value1
			   ,@value2
			   ,@intOrder
			   ,@IsUsed
			   ,getdate()
			   )
		set @messages = N'Thêm thành công'
	END
	else
	BEGIN

		UPDATE [dbo].[sys_config_data]
		   SET [type_value] = @type_value
			  ,[par_desc] = @par_desc
			  ,[par_desc_e] = @par_desc_e
			  ,[value1] = @value1
			  ,[value2] = @value2
			  ,[intOrder] = @intOrder
			  ,[IsUsed] = @IsUsed
		 WHERE id = @id

		set @messages = N'Sửa thành công'
	END


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_config_parameter_set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserId ' + @UserId 
		set @valid = 0
		set @messages =  error_message()

		exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'Parameter', 'Set', @SessionID, @AddlInfo
	end catch

	select @valid as valid
		  ,@messages as [messages]


end