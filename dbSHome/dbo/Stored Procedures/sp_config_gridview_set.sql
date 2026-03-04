CREATE procedure [dbo].[sp_config_gridview_set]
	 @UserId		nvarchar(450)
	
	,@id			bigint
	,@view_grid		nvarchar(100)
	,@view_type		int
	,@columnField	nvarchar(100)
	,@columnCaption nvarchar(100)
	
	,@columnWidth	int
	,@data_type		nvarchar(100)
	,@fieldType		nvarchar(100)
	,@cellClass		nvarchar(350)
	,@pinned		nvarchar(50)
	,@ordinal		int
	,@isUsed		bit
	,@isHide		bit
	,@isMasterDetail bit
	,@isStatusLable bit
	,@isFilter		bit
	,@columnCaptionE nvarchar(100) = null
	,@acceptLanguage nvarchar (50) = 'vi-VN'
  ,@columnObject NVARCHAR(100) = NULL
  ,@customOid NVARCHAR(100) = NULL
  ,@languageName NVARCHAR(100) = NULL
as
begin
	declare @valid bit = 1
	declare @messages nvarchar(300)
	begin try	
		if not exists (select id from [sys_config_list] where id = @id)-- view_grid = @view_grid and view_type = @view_type and columnField = @columnField)
		begin
			INSERT INTO [dbo].[sys_config_list]
					   ([view_grid]
					   ,[view_type]
					   ,[columnField]
					   ,[columnCaption]
					   ,[columnCaptionE]
					   ,[columnWidth]
					   ,[data_type]
					   ,[fieldType]
					   ,[cellClass]
					   ,[pinned]
					   ,[ordinal]
					   ,[isUsed]
					   ,[isHide]
					   ,[isMasterDetail]
					   ,[isStatusLable]
					   ,[isFilter]
					   )
				 VALUES
					   (@view_grid
					   ,@view_type
					   ,@columnField
					   ,@columnCaption
					   ,@columnCaptionE
					   ,@columnWidth
					   ,@data_type
					   ,@fieldType
					   ,@cellClass
					   ,@pinned
					   ,@ordinal
					   ,@isUsed
					   ,@isHide
					   ,@isMasterDetail
					   ,@isStatusLable
					   ,@isFilter
					   
					   )

			set @id = @@IDENTITY
			set @messages = N'Thêm mới thành công'
		end
		else
		begin
			UPDATE [dbo].[sys_config_list]
			   SET [view_grid] = @view_grid
				  ,[view_type] = @view_type
				  ,[columnField] = @columnField
				  ,[columnCaption] = @columnCaption
				  ,[columnCaptionE] = @columnCaptionE
				  ,[columnWidth] = @columnWidth
				  ,[data_type] = @data_type
				  ,[fieldType] = @fieldType
				  ,[cellClass] = @cellClass
				  ,[pinned] = @pinned
				  ,[ordinal] = @ordinal
				  ,[isUsed] = @isUsed
				  ,[isHide] = @isHide
				  ,[isMasterDetail] = @isMasterDetail
				  ,[isStatusLable] = @isStatusLable
				  ,[isFilter] = @isFilter				  
			 WHERE id = @id 

			set @messages = N'Cập nhật thành công'
		end

			
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_uinv_config_GridView_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserId ' 
		set @valid = 0
		set @messages = error_message()

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'ca830pb', 'set', @SessionID, @AddlInfo
	end catch

	select @valid as valid
		  ,@messages as [messages]

end