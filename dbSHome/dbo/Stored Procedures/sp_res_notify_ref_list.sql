


CREATE procedure [dbo].[sp_res_notify_ref_list]
	@UserID		nvarchar(450),
	@externalKey	nvarchar(50)
as
begin
	begin try	

		SELECT [name] = refName
			  ,[value] = lower(cast([source_ref] as varchar(100)))
		  FROM [dbo].[NotifyRef] a
			--join Users u on a.orgId = u.orgId
		WHERE a.external_key = @externalKey
			and [ref_st] = 1
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_notify_ref_list ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@ ' + cast(0  as varchar)

		exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'NotificationApp', 'Set', @SessionID, @AddlInfo
	end catch


	end