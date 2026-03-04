
CREATE procedure [dbo].[sp_res_notify_bySend] 
	@id nvarchar(100) = null,
	@UserId nvarchar(50) = null,
	@AcceptLanguage nvarchar(50) = null
as
	begin try
			SELECT CONVERT(VARCHAR(100),nj.id)as id,
                   nj.n_id,
                   ni.notiType,
                   ni.subject,
                   ni.content_notify,
                   ni.external_param,
                   ni.external_event,
				   ni.external_key
				   FROM dbo.NotifyJob nj
				   JOIN dbo.NotifyInbox ni ON ni.n_id = nj.n_id

			SELECT CONVERT(VARCHAR(100),nj.id)as id,
                   ns.n_id,
                   ns.userId,
                   ns.custId,
                   ns.email,
                   ns.phone,
                   ns.fullName,
                   ns.push_st AS push_status,
				   ns.NotiId
			FROM  dbo.NotifyJob nj
			JOIN dbo.NotifySent ns ON ns.id = nj.id
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_resident_notify_bySend ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'NotifySend', 'Get', @SessionID, @AddlInfo
	end catch