






CREATE procedure [dbo].[sp_COR_User_Profile_Meta_List]
	@userId	nvarchar(450),
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
			  --,c.objName as [doc_sub_type_name]
		  FROM UserMeta t 
			join UserInfo a on t.reg_userId = a.reg_userId
			--join [dbo].[fn_ca804pb_gets] ('core_doc_sub_type' + cast(0 as varchar)) c on c.objValue = t.doc_sub_type
		  WHERE a.userId = @userId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_COR_User_Profile_Meta_List ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@User ' 

		exec utl_ErrorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'UserMeta', 'Update', @SessionID, @AddlInfo
	end catch