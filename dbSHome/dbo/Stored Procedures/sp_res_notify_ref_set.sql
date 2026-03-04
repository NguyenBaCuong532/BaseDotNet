CREATE procedure [dbo].[sp_res_notify_ref_set]
	@userId			nvarchar(450),
	@external_key	nvarchar(50),
	@id				uniqueidentifier,
	@refKey			nvarchar(200),
	@refIcon		nvarchar(350) = NULL,
	@refName		nvarchar(50),
	@ref_st			nvarchar(50)

as
begin
	declare @valid bit = 1
	declare @messages nvarchar(300) = N'Thành công'
	begin try
  
  IF EXISTS(SELECT source_ref FROM NotifyRef WHERE @refKey = refKey AND ((@id IS NULL) OR (@id IS NOT NULL AND @id <> source_ref)))
  BEGIN
      SET @valid = 0;
      SET @messages = N'Mã thông báo đã tồn tại. Vui lòng kiểm tra lại.';
      GOTO FINALLY;
  END

	IF EXISTS(SELECT source_ref FROM NotifyRef WHERE source_ref = @id)
	begin

		UPDATE [dbo].[NotifyRef]
		   SET [refKey] = @refKey
			  ,[refName] = @refName
			  ,[ref_st] = @ref_st
			  ,refIcon	= @refIcon
			  ,created_by = @userId
			  ,external_key = @external_key
		 WHERE source_ref = @id
			

	end
	else
		INSERT INTO [dbo].[NotifyRef]
			   ([source_ref]
			   ,[refKey] 
			   ,[refName] 
			   ,external_key
			   ,[ref_st]
			   ,[created_by]
			   ,[created_dt]
			   ,refIcon
			   )
		 VALUES
			   (newid()
			   ,@refKey
			   ,@refName
			   ,@external_key
			   ,@ref_st
			   ,@UserID
			   ,getutcdate()
			   ,@refIcon
			   )
			   	
		

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_notify_ref_set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@n_id ' + cast(0  as varchar)
		set @valid = 0
		set @messages = error_message()

		exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'notify_ref', 'Set', @SessionID, @AddlInfo
	end catch
end

FINALLY:
    select
        @valid as valid
	      ,@messages as [messages]