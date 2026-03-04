
-- =============================================
-- Author:		duongpx
-- Create date: 10/5/2024 10:00:05 AM
-- Description:	chi tiết mở đặt chỗ
-- =============================================
CREATE procedure [dbo].[sp_meta_info_set]
	 @UserId nvarchar(450)
	,@Oid uniqueidentifier	= null
	,@source_type nvarchar(50)= null
    ,@sourceOid uniqueidentifier = null
	,@typeOid uniqueidentifier = null
	,@meta_type int = null
	,@meta_title	nvarchar(400)= null
	,@meta_note	nvarchar(400) = null
	,@file_name nvarchar(250) = null
	,@file_url	nvarchar(400) = null
	,@file_size int = null
    ,@file_type	nvarchar(100) = null
	,@objectName nvarchar(250) = null
	,@bucket nvarchar(250) = null
	,@meta_links nvarchar(max) = null
	,@acceptLanguage nvarchar(50) = 'vi-VN'
	
as
begin
	 declare @message nvarchar(100) = N'Lưu thanh công'
	 declare @valid int = 1
	begin try
	if exists (select 1 from meta_info 
		where Oid = @Oid)
		begin
			UPDATE [dbo].[meta_info]
			   SET [meta_title] = @meta_title
				  ,[meta_note] = @meta_note
				  --,[meta_type] = @meta_type
				  --,[file_name] = @file_name
				  --,[file_size] = @file_size
				  --,[file_url] = @file_url
				  ,[updated] = getdate()
				  ,[updated_by] = @UserId
				  --,[file_type] = @file_type
				  --,[objectName] = @objectName
				  --,[bucket] = @bucket
				  ,typeOid = @typeOid
				  --,[source_type] = @source_type
			 WHERE Oid = @Oid
		end
	else
		begin
			set @sourceOid = isnull(@sourceOid, newId())
			set @Oid = newid()
			INSERT INTO [dbo].[meta_info]
				   ([Oid]
				   ,[sourceOid]
				   ,[source_type]
				   ,[meta_title]
				   ,[meta_note]
				   ,[meta_type]
				   ,[file_name]
				   ,[file_size]
				   ,[file_url]
				   ,[created]
				   ,[created_by]
				   ,[file_type]
				   ,[objectName]
				   ,[bucket]
				   ,typeOid
				   )
			 VALUES
				   (@Oid
				   ,@sourceOid
				   ,@source_type
				   ,@meta_title
				   ,@meta_note
				   ,@meta_type
				   ,@file_name
				   ,@file_size
				   ,@file_url
				   ,getdate()
				   ,@UserId
				   ,@file_type
				   ,@objectName
				   ,@bucket
				   ,@typeOid
				   )
			set @message = N'Thêm thành công'
		end

		--if @meta_links is null or @meta_links = ''
		--begin
		--	delete from image_link where imageOid = @Oid
		--end
		--else
		--begin
		--	delete from image_link 
		--	where imageOid = @Oid
		--	and sourceOid not in (select Oid from dbo.[fn_split_string](@meta_links,','))

		--	INSERT INTO [dbo].[meta_link]
		--		   ([metaOid]
		--		   ,[source_type]
		--		   ,[sourceOid]
		--		   ,[meta_type]
		--		   ,[created]
		--		   ,[created_by])
		--	 SELECT @Oid
		--		   ,@source_type
		--		   ,sourceOid = oid
		--		   ,@meta_type
		--		   ,getdate()
		--		   ,@UserId
		--	from dbo.[fn_split_string](@meta_links,',')
		--	where @sourceOid <> Oid

		--end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_meta_info_set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '
		set @valid = 0
		set @message =  error_message()

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'images', 'POST,PUT', @SessionID, @AddlInfo
	end catch

	select @valid as valid
		  ,@message as messages
		  ,@Oid as id


	end