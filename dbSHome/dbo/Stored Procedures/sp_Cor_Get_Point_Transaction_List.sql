








CREATE procedure [dbo].[sp_Cor_Get_Point_Transaction_List]
	@UserId	nvarchar(450), 
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@CustId	nvarchar(50),  
	@TransTypeId int, 
	@Total				int out,
	@TotalFiltered		int out
as
declare @PosCd varchar(30);
declare @ServiceKey varchar(30);

	begin try 
		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0) 

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		
		if @CustId is null or @CustId = ''
			set @CustId = (select top 1 custId from UserInfo where UserId = @UserId)

		if(@TransTypeId = 3 or @TransTypeId = 0 or @TransTypeId = -1) 
		begin
			set @PosCd  = 'PC8613035583';
			set @ServiceKey = 'SK702831';
		end
		select 
			@Total					= count(wa.TransNo)
			 from MAS_Points mp
				--join CRM_TransactionType crm on crm.TransTypeId = @TransTypeId
				join [WAL_PointOrder] wa on mp.PointCd = wa.PointCd
			where mp.CustId = @CustId
			--and PosCd = @PosCd -- 'PC8613035583'
			--and ServiceKey = @ServiceKey -- 'SK702831';
		
		set	@TotalFiltered = @Total 
		if @PageSize < 0
		begin
			set	@PageSize				= 10
		end
	
		--1
		  select Ref_No as TranNo
				,OrderAmount as TranAmount
				,Point
				,CreditPoint
				,OrderInfo as TranInfo
				,TranDt
				,wa.TransNo as CardCd
				,s.ServiceName
		from MAS_Points mp
				--join CRM_TransactionType crm on crm.TransTypeId = @TransTypeId -- 3
				join [WAL_PointOrder] wa on mp.PointCd = wa.PointCd
				left join WAL_Services s on wa.ServiceKey = s.ServiceKey
		where mp.CustId = @CustId
				--and wa.PosCd = @PosCd -- 'PC8613035583'
				--and wa.ServiceKey = @ServiceKey -- 'SK702831'; 
			ORDER BY Ref_No desc
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
		set @ErrorMsg					= '[sp_Crm_Get_Transaction_List] ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Transaction', 'GET', @SessionID, @AddlInfo
	end catch