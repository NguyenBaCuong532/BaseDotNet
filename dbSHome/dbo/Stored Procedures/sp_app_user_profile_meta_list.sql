



CREATE procedure [dbo].[sp_app_user_profile_meta_list]
	@userId	uniqueidentifier,
	@acceptLanguage nvarchar(50) = null,
	@loginName nvarchar(50)
as
	begin try		

		if @loginName is not null
			set @UserId = (select top 1 UserId From UserInfo where loginName = @loginName)

		SELECT [id] as metaId
			  ,[doc_type] as doc_type
			  ,[doc_sub_type]
			  ,[meta_url] as metaUrl
			  ,[meta_name] as metaName
			  ,[meta_type] as metatype
			  ,[meta_note] as metaNote
		  FROM UserMeta t 
			join UserInfo a on t.regOid = a.regOid --and t.idCardOid = a.idCardOid	
		  WHERE a.userId = @userId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_app_user_profile_meta_list ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' - @userId '

		EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'UserInfo', 'Insert', @SessionID, @AddlInfo
	end catch