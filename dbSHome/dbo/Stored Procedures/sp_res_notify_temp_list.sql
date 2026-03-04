


CREATE procedure [dbo].[sp_res_notify_temp_list]
	@UserID			nvarchar(450),
	@external_key		nvarchar(50) = null,
	@projectcode		varchar(5) = null
	--@can_st			int = null
	--
as
begin
	begin try	
		declare @tempIds		nvarchar(max) = null
		declare @source_key nvarchar(50) = null
		DECLARE @orgId uniqueidentifier = (SELECT TOP 1 orgId from Users where userid = @UserId)
		declare @tbTems TABLE 
		(
			tempId uniqueidentifier null
		)
		set @source_key = isnull(@source_key,'common')
		
		SELECT lower(cast(tempId as varchar(100))) as value
			  ,isnull(tempCd,'') + '-' + tempName as name
		  FROM [dbo].[NotifyTemplate] a
			--join Users u on a.orgId = u.orgId
		WHERE a.external_key = @external_key 
			and (@source_key is null or a.source_key = @source_key)
			and a.app_st = 1
			and a.projectCd = @projectcode
			
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_notify_temp_list ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@ ' + cast(0  as varchar)

		exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'NotificationApp', 'Set', @SessionID, @AddlInfo
	end catch


	end