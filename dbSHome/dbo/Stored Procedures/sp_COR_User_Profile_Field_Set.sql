


CREATE procedure [dbo].[sp_COR_User_Profile_Field_Set]
	@UserID	nvarchar(450),
	@FieldName	nvarchar(100),
	@ColumnType	nvarchar(50),
	@FieldValue	nvarchar(350),
	@loginName nvarchar(100)
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

	if @loginName is not null
		set @UserId = (select top 1 UserId From UserInfo where loginName = @loginName)
			
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
		set @ErrorMsg					= 'sp_User_Field_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= @sql

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'UserField', 'Update', @SessionID, @AddlInfo
	end catch