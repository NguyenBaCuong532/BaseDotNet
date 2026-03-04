








CREATE procedure [dbo].[sp_Crm_Template_Page]
	@UserId			nvarchar(450), 
	@Filter			nvarchar(30),
	@TransTypeId	int,
	@TemplateTypeId		int,
	@gridWidth			int			= 0,
	@Offset				int			= 0,
	@PageSize			int			= 10,
	@Total				int out,
	@TotalFiltered		int out
	,@gridKey			nvarchar(200) out
as
	begin try 
		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@Filter					= isnull(@Filter,'')

		if		@PageSize	<= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		
		 
		select	@Total					= count(t.TemplateId)
			FROM  [CRM_Template] t
				join  [CRM_TransactionType] r on t.TransTypeId = r.TransTypeId
				--left join  [CRM_TemplateType] y on t.TemplateTypeId = y.TemplateTypeId
			 where (r.TransTypeId = @TransTypeId)
				and (t.TemplateTypeId =  @TemplateTypeId or @TemplateTypeId = -1)
				and (t.TemplateName like '%'+@Filter+'%' or t.TemplateContent like '%'+@Filter+'%')
				and (t.CreatedBy = @UserId or t.isShared = 1)

		set	@TotalFiltered = @Total

		if @Offset = 0
		begin
			SELECT * FROM [dbo].[fn_config_list_gets] ('view_Crm_Template_Page', @gridWidth) 
			ORDER BY [ordinal]
		end
	
		--1
		SELECT t.[TemplateId]
			  ,t.[TemplateContent]
			  ,t.[TransTypeId]
			  ,r.TransTypeName
			  ,t.[TemplateTypeId]
			  ,y.[TemplateTypeName] 
			  ,t.[TemplateName]
			  ,t.TemplateUrl
			  ,t.isShared
			  ,t.thumbnailUrl
			  ,t.isHtml
	 FROM  [CRM_Template] t
		join  [CRM_TransactionType] r on t.TransTypeId = r.TransTypeId
		left join  [CRM_TemplateType] y on t.TemplateTypeId = y.TemplateTypeId
	  where (r.TransTypeId = @TransTypeId)
			and (t.TemplateTypeId =  @TemplateTypeId or @TemplateTypeId = -1)
			and (t.TemplateName like '%'+@Filter+'%' or t.TemplateContent like '%'+@Filter+'%')
			and (t.CreatedBy = @UserId or t.isShared = 1)
		ORDER BY t.[TemplateName]
				  offset @Offset rows	
					fetch next @PageSize rows only

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Template_Page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Template', 'GET', @SessionID, @AddlInfo
	end catch