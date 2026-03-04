CREATE procedure [dbo].[sp_sys_object_group_get]
	@UserID	nvarchar(450),
	@isAll BIT = null,
	@objKey nvarchar(50)
as
	begin try		
		SELECT objName as name
		      ,objValue as value
		INTO #items
		 FROM [dbo].fn_config_data_gets (@objKey) 
		order by intOrder

		IF @isAll = 1
        INSERT INTO #items
        VALUES (
            N'Tất cả',
			'-1'
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
		set @ErrorMsg					= 'sp_sys_object_group_get ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_sys_object_group_get', 'Get', @SessionID, @AddlInfo
	end catch