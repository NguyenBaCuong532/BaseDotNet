








CREATE procedure [dbo].[sp_Crm_Template_Set]
	@UserId	nvarchar(450), 
	@templateId	int,
	@TemplateName nvarchar(255),
	@TemplateContent nvarchar(MAX),
	@TransTypeId	int,
	@TemplateTypeId int,
	@TemplateUrl nvarchar(350),
	@isShared bit,
	@thumbnailUrl nvarchar(350),
	@isHtml bit
as
	--declare @templateId int;
	begin try 
	if exists(select TemplateId from [CRM_Template] where TemplateId = @templateId)
		Update [dbo].[CRM_Template] 
		 set [TemplateName] = @TemplateName
			,[TemplateContent] = case when @isHtml = 1 then null else @TemplateContent end
			,[UpdatedBy] = @UserId
			,[UpdatedTime] = SYSDATETIME()
			,[TemplateTypeId] = @TemplateTypeId
			,TemplateUrl = @TemplateUrl
			,isShared = @isShared
			,thumbnailUrl = @thumbnailUrl
			,isHtml = @isHtml
		where TemplateId = @TemplateId  
	else
	begin
		INSERT INTO [dbo].[CRM_Template] 
				([TemplateName]
			   ,[TemplateContent]
			   ,[TransTypeId]
			   ,[TemplateTypeId]
			   ,[CreatedBy]
			   ,[CreatedTime]
			   ,[UpdatedBy]
			   ,[UpdatedTime]
			   ,TemplateUrl
			   ,isShared
			   ,thumbnailUrl
			   ,isHtml
			   )
		 VALUES 
			   (@TemplateName
			   ,case when @isHtml = 1 then null else @TemplateContent end
			   ,@TransTypeId
			   ,@TemplateTypeId
			   ,@UserId
			   ,SYSDATETIME()
			   ,@UserId
			   ,SYSDATETIME()
			   ,@TemplateUrl
			   ,0
			   ,@thumbnailUrl
			   ,@isHtml
			   )
		
			set @templateId = @@IDENTITY
		end
		exec sp_Crm_Template_Get @UserId, @templateId
		
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Template_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@TemplateName ' + cast(@TemplateName as nvarchar)

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Template', 'Set', @SessionID, @AddlInfo
	end catch