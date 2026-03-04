
CREATE procedure [dbo].[sp_res_notify_push_creates]
	@UserId			nvarchar(450),
	--@notiID			bigint	= 0,
	@n_id			uniqueidentifier = null,
	@notiusers	user_notify_type readonly
as
begin
	declare @valid bit = 1
	declare @messages nvarchar(300) = N'Cập nhật thành công'
	begin try	
		declare @notiID			bigint
		--if @notiID = 0 or @notiID is null
		--	set @notiID = (select top 1 notiID from NotifyInbox n where n.n_id = @n_id)
		--else
		--	set @n_id = (select top 1 n_id from NotifyInbox n where n.notiId = @notiID)
		--else
			set @notiID = (select top 1 notiID from NotifyInbox n where n.n_id = @n_id)
			
			--select 1
			INSERT INTO [dbo].NotifySent
				   ([NotiId]
				   ,[userId]
				   ,[custId]
				   ,[room]
				   ,[email]
				   ,[phone]
				   ,[fullName]
				   ,[push_st]
				   ,[sms_st]
				   ,[email_st]
				   ,[createId]
				   ,createDt
				   ,n_id
				   ,[GuidId])
			select @notiID
				  ,userId
				  ,custid
				  ,room
				  ,email 
				  ,phone 
				  ,fullName
				  ,case when isLinkApp = 1 then 0 else 4 end
				  ,case when phone is not null and phone <> '' and [dbo].[funcSDT](phone) = 1 then 0 else 4 end
				  ,case when email is not null and email <> '' and CHARINDEX('@',email,1) > 1  then 0 else 4 end
				  ,@UserId
				  ,getdate()
				  ,@n_id
				  ,NEWID()
			 from @notiusers a
				where not exists(select notiid from NotifySent t
				where t.n_id = @n_id 
					and t.custId = a.custId and ((t.room = a.room and a.room is not null) or a.room is null)
					and (a.userid is null or (a.userid is not null and t.userId = a.userid))
					)
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_notify_push_alters ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@User =' + @UserId + '@n_id' + cast(@n_id as varchar(50))
		set @valid = 0
		set @messages =  error_message()
		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'NotificationPushs', 'alter', @SessionID, @AddlInfo
	end catch

	select @valid as valid
	      ,@messages as [messages]

end