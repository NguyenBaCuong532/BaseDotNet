
CREATE procedure [dbo].[sp_sys_config_group_get]
	@UserID		nvarchar(450),
	@all		nvarchar(250) = '-1',
	@objKey		nvarchar(250)
as
	begin try		
		SELECT objName as name
		      ,objValue as value
		INTO #items
		 FROM [dbo].fn_config_data_gets (@objKey) 
		order by intOrder

		IF @all is not null
        INSERT INTO #items
        VALUES (
            N'Tất cả',
			@all
            )

		SELECT * FROM #items
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_sys_config_group_get ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_sys_object_group_get', 'Get', @SessionID, @AddlInfo
	end catch