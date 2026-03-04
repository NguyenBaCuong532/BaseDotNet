

CREATE procedure [dbo].[sp_COR_User_Profile_Meta_Set]
	@userId	nvarchar(450),
	@loginName nvarchar(50),
	@meta_code nvarchar(20)		= null,
	@meta_url nvarchar(350),
	@meta_name nvarchar(200)	= null,	
	@meta_note nvarchar(200)	= null,
	@doc_type nvarchar(50),
	@doc_sub_type nvarchar(50),
	@meta_type nvarchar(50)		= null

as
	begin try	
	--BEGIN TRAN sp_COR_U_Profile_Met_S_transtion	

		declare @meta_url_old nvarchar(450)
		declare @is_change bit 
		declare @Id uniqueidentifier
		declare @reg_userid bigint
		declare @idcard_type int

		declare @idtb table
		(
			Id uniqueidentifier
		)
		select top 1 @reg_userid = reg_userId, @idcard_type = idcard_type from UserInfo where loginName = @loginName

		--set @idcard_type = (select top 1 idcard_type from UserInfo where loginName = @loginName)
		
		if @idcard_type >= 1 and @idcard_type <= 3
			set @doc_type = 'identity' + cast(@idcard_type as varchar)
		else
			set @doc_type = 'identity2'
		
		if @idcard_type = 2
		begin
			if @doc_sub_type = 'identity2'
				set @doc_sub_type = 'identity4'
			else if @doc_sub_type = 'identity1'
				set @doc_sub_type = 'identity3'
		end
		else if @idcard_type = 3
			set @doc_sub_type = 'identity5'

		--xoa khac kiêu cùng số
		delete t from UserMeta t 
			where reg_userId = @reg_userid and meta_code = @meta_code
			and (doc_type <> @doc_type)

		if exists(select 1 from UserMeta t 
			where (reg_userId = @reg_userid and (doc_type = @doc_type and doc_sub_type = @doc_sub_type))) 
		begin
			insert into @idtb
			select id
				from UserMeta t 
				where (doc_type = @doc_type and doc_sub_type = @doc_sub_type and reg_userId = @reg_userid)

			set @Id = (select top 1 id
				from UserMeta t 
				where (doc_type = @doc_type and doc_sub_type = @doc_sub_type and reg_userId = @reg_userid)
				order by mkr_dt desc
				)
				
			if (select top 1 meta_url from UserMeta where id = @id order by mkr_dt) <> @meta_url
				set @is_change = 1
			else
				set @is_change = 0

			UPDATE t
			   SET [doc_type] = @doc_type
			      ,[doc_sub_type] = @doc_sub_type
				  ,[meta_url] = @meta_url
				  ,[meta_name] = @meta_name
				  ,[meta_note] = @meta_note
				  ,[meta_type] = @meta_type
				  ,meta_code = @meta_code
			 from UserMeta t 
				where (id = @Id)
				and @meta_url is not null 
				and @meta_url <> ''
			
			delete from @idtb where id = @id

			delete t from UserMeta t 
			where exists(select 1 from @idtb where id = t.id)

			
			if @is_change = 1
			 UPDATE [dbo].[UserInfo]
			   SET [idcard_Verified] = 0
			      ,work_st = 0
				  ,modified_dt = getdate()
			 WHERE reg_userId = @reg_userId
		end
		else
		begin
			delete from [dbo].[UserMeta] where reg_userId = @reg_userId and [meta_url] = @meta_url

			INSERT INTO [dbo].[UserMeta]
				   (id
				   ,[doc_type]
				   ,doc_sub_type
				   ,reg_userId
				   ,[meta_url]
				   ,[meta_name]
				   ,[meta_note]
				   ,[meta_type]
				   ,[mkr_id]
				   ,[mkr_dt]
				   ,[status]
				   ,[sysdate]
				   ,meta_code
				   )
			 SELECT newid()
				   ,@doc_type
				   ,@doc_sub_type
				   ,reg_userId
				   ,@meta_url
				   ,@meta_name
				   ,@meta_note
				   ,@meta_type
				   ,@userId
				   ,getdate()
				   ,'O'
				   ,getdate()
				   ,@meta_code			   
				FROM UserInfo
			WHERE reg_userId = @reg_userId 
				and @meta_url is not null 
				and @meta_url <> ''
				and @meta_code <> ''
				and @meta_code is not null

			UPDATE [dbo].[UserInfo]
			   SET [idcard_Verified] = 0
			      ,work_st = 0
			 WHERE reg_userId = @reg_userId 

		end

		--COMMIT TRAN sp_COR_U_Profile_Met_S_transtion
	end try
	begin catch
	--ROLLBACK TRAN sp_COR_U_Profile_Met_S_transtion

		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_User_Profile_Meta_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@User ' + cast(@reg_userId as varchar)

		exec utl_ErrorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_User_Profile_Meta_Set', 'Update', @SessionID, @AddlInfo
	end catch