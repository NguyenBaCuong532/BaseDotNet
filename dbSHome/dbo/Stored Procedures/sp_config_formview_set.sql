CREATE procedure [dbo].[sp_config_formview_set]
	 @UserId			nvarchar(450)
	,@id				bigint
	,@table_name		nvarchar(50)
	,@field_name		nvarchar(50)
	,@view_type			int
	,@data_type			nvarchar(50)
	,@ordinal			int
	,@group_cd			nvarchar(50)
	,@columnLabel		nvarchar(100)	
	,@columnTooltip		nvarchar(300)
	,@columnValue		nvarchar(300)
	,@columnDefault		nvarchar(300)
  ,@isPrivate BIT
  ,@languageName NVARCHAR(50)
  ,@customOid NVARCHAR(50)
	,@columnClass		nvarchar(50)
	,@columnType		nvarchar(50)
	,@columnObject		nvarchar(500)
	,@isVisiable		bit
	,@isSpecial			bit
	,@isRequire			bit
	,@isEmpty			bit
	,@isDisable			bit
	,@columnDisplay		nvarchar(100) =  null
	,@isIgnore			bit = null
	,@maxLength			int = null
	,@table_relation	nvarchar(100) = null
	,@columnLabelE		nvarchar(100) = null
	,@acceptLanguage	nvarchar(50) = 'vi-VN'
as
	begin try	
		if not exists (select id from sys_config_form where table_name = @table_name and field_name = @field_name and view_type = @view_type)
		begin

		INSERT INTO [dbo].sys_config_form
				   ([table_name]
				   ,[field_name]
				   ,[view_type]
				   ,[data_type]
				   ,[ordinal]
				   ,[group_cd]
				   ,[columnLabel]
				   ,[columnLabelE]
				   ,[columnTooltip]
				   ,[columnDefault]
				   ,[columnClass]
				   ,[columnType]
				   ,[columnObject]
				   ,[IsVisiable]
				   ,[isSpecial]
				   ,[isRequire]
				   ,[isEmpty]
				   ,[isDisable]
				   ,[columnDisplay]
				   ,[isIgnore]
				   )
			 VALUES
				   (@table_name
				   ,@field_name
				   ,@view_type
				   ,@data_type
				   ,@ordinal
				   ,@group_cd
				   ,@columnLabel
				   ,@columnLabelE
				   ,@columnTooltip
				   ,@columnDefault
				   ,@columnClass
				   ,@columnType
				   ,@columnObject
				   ,@IsVisiable
				   ,@isSpecial
				   ,@isRequire
				   ,@isEmpty
				   ,@isDisable
				   ,@columnDisplay
				   ,@isIgnore
				   )

			
			set @id = @@IDENTITY
		end
		else
			UPDATE [dbo].sys_config_form
			   SET [table_name] = @table_name
				  ,[field_name] = @field_name
				  ,[view_type] = @view_type
				  ,[data_type] = @data_type
				  ,[ordinal] = @ordinal
				  ,[group_cd] = @group_cd
				  ,[columnLabel] = @columnLabel
				  ,[columnLabelE] = @columnLabelE
				  ,[columnTooltip] = @columnTooltip
				  ,[columnDefault] = @columnDefault
				  ,[columnClass] = @columnClass
				  ,[columnType] = @columnType
				  ,[columnObject] = @columnObject
				  ,[IsVisiable] = @IsVisiable
				  ,[isSpecial] = @isSpecial
				  ,[isRequire] = @isRequire
				  ,[IsEmpty]	= @isEmpty
				  ,[isDisable] = @isDisable
				  ,[columnDisplay] = @columnDisplay
				  ,[isIgnore] = @isIgnore
			 WHERE table_name = @table_name and field_name = @field_name and view_type = @view_type

			
			select 1 as valid
				  ,'' as [messages]

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_config_formview_set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserId ' 

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'config_list', 'set', @SessionID, @AddlInfo
	end catch