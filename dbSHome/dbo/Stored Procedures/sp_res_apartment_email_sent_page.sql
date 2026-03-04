-- Lịch sử gửi email theo căn hộ
CREATE procedure [dbo].[sp_res_apartment_email_sent_page]
	@UserId	nvarchar(450) =NULL,
	@ApartmentId  int,

	@filter nvarchar(30) = NULL,
	@gridWidth			int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 10
	--@Total				bigint out,
	--@TotalFiltered		bigint OUT,
	--@GridKey		nvarchar(200) out
as
	begin try	
	declare @Total		bigint
	declare @GridKey	nvarchar(100) = 'view_emailSent_byApartment_page'

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')

		if		@PageSize	<= 0		set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		select CustId into #Tmp1
		from MAS_Apartment_Member 
		where ApartmentId = @ApartmentId
		and CustId is not NULL

		select	@Total					= count(s.id)
		FROM NotifyInbox a 
	  JOIN dbo.NotifySent s ON s.NotiId = a.notiId
	  --JOIN dbo.EmailSents b on a.n_id = b.sourceId and s.custId = b.custId
	  JOIN dbo.sys_config_data cd ON cd.key_1 = 'email_st' AND s.email_st = cd.key_2
	  join #Tmp1 d on s.custId = d.CustId
	  WHERE a.actionlist LIKE '%email%'
		
		--root	
	select recordsTotal = @Total
		  ,recordsFiltered = @Total
		  ,gridKey = @GridKey
		  ,valid = 1
    --grid config
		if @Offset = 0
		begin
			select * from [dbo].[fn_config_list_gets] (@GridKey, 0) 
					order by [ordinal]
		END

		SELECT (a.[NotiId])
			  ,s.id
			  ,s.email AS mailto
			  ,a.send_by
			  ,ISNULL(s.[subject], a.[subject]) AS [subject]
			  ,s.email_st 
			  ,status = cd.value1
			  ,createDt =  FORMAT(a.createDt,'dd/MM/yyy HH:mm:ss')
			  --,b.send
			  ,a.send_name
			  ,sendDate = FORMAT(s.createDt,'dd/MM/yyy HH:mm:ss')
			  --,b.isRead
			  --,b.readDt
			  --,createId = c.fullName--a.createId
			  ,ISNULL(s.content_email, a.content_email) AS content_email
			  ,s.custId
	  FROM NotifyInbox a 
	  JOIN dbo.NotifySent s ON s.NotiId = a.notiId
	  --JOIN dbo.EmailSents b on a.n_id = b.sourceId and s.custId = b.custId
	  JOIN dbo.sys_config_data cd ON cd.key_1 = 'email_st' AND s.email_st = cd.key_2
	  join #Tmp1 d on s.custId = d.CustId
	  WHERE a.actionlist LIKE '%email%'
	  ORDER BY a.createDt DESC, a.notiId desc
	  OFFSET @Offset rows	
	  FETCH next @PageSize rows only

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_email_sent_byApartment_page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserId ' + @UserId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'NotificationSent', 'GET', @SessionID, @AddlInfo
	end CATCH