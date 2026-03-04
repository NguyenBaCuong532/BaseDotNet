

-- =============================================
-- Author:		duongpx
-- Create date: 11/7/2024 11:55:41 AM
-- Description:	Cập nhật thông tin hồ sơ cá nhân từng field
-- =============================================
CREATE procedure [dbo].[sp_app_user_profile_field_set]
	@UserID	nvarchar(450),
	@acceptLanguage nvarchar(50) = null,
	@FieldName	nvarchar(100),
	@ColumnType	nvarchar(50),
	@FieldValue	nvarchar(350)
	--@loginName nvarchar(100)
as
	begin try		
	declare @sql nvarchar(max) = ''
	declare @value nvarchar(500)

	if @ColumnType = 'nvarchar'
		set @value = 'N''' + @FieldValue + ''''
	else if @ColumnType = 'datetime'
		set @value = 'convert(datetime,''' + @FieldValue + ''',103)'
	else if @ColumnType = 'bit'
		set @value = 'convert(bit,''' + @FieldValue + ''')'
	else if @ColumnType = 'int'
		set @value =  @FieldValue 
	else
		set @value = 'N''' + @FieldValue + ''''

	--if @loginName is not null
	--	set @UserId = (select top 1 UserId From UserInfo where loginName = @loginName)
			
		set @sql =	'UPDATE t
			   SET '+ @FieldName + ' = '+ @value +'
			FROM [dbo].[UserInfo] t				
			 WHERE t.UserId = ''' + @UserId + ''''

	if @sql <> '' and @FieldName not like '%idcard%' 
		EXECUTE sp_executesql @sql

	
	if @FieldName like 'fullName' or @FieldName like 'email' or @FieldName like '%bank%'
		update UserInfo
			set work_st = 0
			,modified_dt = getdate()
		where userId = @UserID 

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_user_profile_field_set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' - @userId '

		EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'UserInfo', 'Insert', @SessionID, @AddlInfo
	end catch