





CREATE procedure [dbo].[sp_Crm_Issue_Del]
	@userId		nvarchar(450),
	@clientId	nvarchar(50),
	@Id			bigint	
	
as
	begin try	
		declare @valid bit = 1
		declare @messages nvarchar(100) = N'Xóa kiến nghị thành công'
		declare @roledel bit = 0
		if exists(select issueId from CRM_Issues where issueId = @id and createby = @userId)			
		begin
			set @roledel = 1
		end 
		--else if exists(select r.userRole 
		--	from [dbo].[ClientWebUsers] r 
		--	join [dbo].[ClientWebs] w on r.webId = w.id 
		--	join [dbo].[ClientWebUsers] o on r.orgId = o.orgId 
		--	join CRM_Issues i on o.userId = i.createBy 
		--	where (clientId = @clientId or clientIdDev = @clientId)
		--		and r.userId = @userId 
		--		and r.userRole = 1
		--		and i.issueId = @Id)
				set @roledel = 1

		if @roledel = 0
		begin
			set @valid = 0
			set @messages = N'Ban chưa được phân quyền xóa'
		end
		else
		begin
			delete from [CRM_Issue_Attach] 
			where issueId = @Id

			delete from CRM_Issue_Process
			where issueId = @Id

			delete from [dbo].CRM_Issues 
			where issueId = @id 
			--and createby = @userId
		end

		 select @valid as valid
			  ,@messages as [messages]

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		
		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Issue_Del' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Issue', 'DEL', @SessionID, @AddlInfo
	end catch