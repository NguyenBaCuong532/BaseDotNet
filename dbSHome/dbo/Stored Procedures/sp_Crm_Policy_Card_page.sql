


CREATE procedure [dbo].[sp_Crm_Policy_Card_page]
	@UserId	nvarchar(450), 
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Filter nvarchar(30),	
	@gridWidth		int				= 0,
	@CardTypeId int ,
	@Total				int out,
	@TotalFiltered		int out
	,@gridKey			nvarchar(200) out
as
	begin try 
		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@Filter					= isnull(@Filter,'')

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		
		 set @gridKey = 'view_Crm_Policy_Card_Page'
		select	@Total					= count(cp.CardTypeId)
			FROM  [CRM_CardPolicy] cp
			  join CRM_CardType cc on cp.CardTypeId = cc.CardTypeId
			  join MAS_CardTypes mc on cc.CardTypeId = mc.CardTypeId
			  where 1=1
				and  (cp.policyName like '%'+@Filter+'%' )
				and (cp.CardTypeId = @CardTypeId or @CardTypeId = 0) 
		set	@TotalFiltered = @Total

		if @PageSize < 0
		begin
			set	@PageSize				= 10
		end
	
	if @Offset = 0
		begin
			SELECT * FROM [dbo].[fn_config_list_gets] (@gridKey, 0) 
			ORDER BY [ordinal]
		end
	--1
		select	
			cp.policyId
			,cp.cardTypeId
			,cp.discount
			,cp.isVip
			,cp.minPoint
			,cc.imageUrl
			,mc.cardTypeName
			,cp.policyName
			,convert(nvarchar(10),cp.[FromDate],103) as fromDate
			,convert(nvarchar(10),cp.[ToDate],103) as toDate
			FROM  [CRM_CardPolicy] cp
			  join CRM_CardType cc on cp.CardTypeId = cc.CardTypeId
			  join MAS_CardTypes mc on cc.CardTypeId = mc.CardTypeId
			  where 1=1
				and  (cp.policyName like '%'+@Filter+'%' )
				and (cp.CardTypeId = @CardTypeId or @CardTypeId = 0) 
	ORDER BY cc.Ordering
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
		set @ErrorMsg					= '[sp_Crm_Get_Card_Policy_List] ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Card', 'GET', @SessionID, @AddlInfo
	end catch