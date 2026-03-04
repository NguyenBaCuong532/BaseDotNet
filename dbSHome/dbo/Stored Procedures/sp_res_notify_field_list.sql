



CREATE procedure [dbo].[sp_res_notify_field_list]
	@UserID	nvarchar(450),
	@all	nvarchar(100) = NULL
as
	begin try		
		declare @objKey nvarchar(50) = 'notify_field'
		
		SELECT objName + ' - ' + objValue as name
		      ,objValue as value
			  ,intOrder
		 FROM [dbo].fn_config_data_gets (@objKey)
		 union all
		 select N'Tất cả' as [name]
				,@all as [value]
				,-1 as intOrder
			where @all is not null
		order by intOrder

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_notify_field_list ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'CustObj', 'Get', @SessionID, @AddlInfo
	end catch