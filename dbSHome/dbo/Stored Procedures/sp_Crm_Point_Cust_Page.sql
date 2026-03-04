





CREATE procedure [dbo].[sp_Crm_Point_Cust_Page]
	@userId	nvarchar(450),
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@CustId	nvarchar(50),  
	@Filter nvarchar(50),
	@gridWidth			int				= 0,
	@Total				int out,
	@TotalFiltered		int out
	,@gridKey			nvarchar(200) out

as
	begin try
		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0) 
		set		@CustId					= isnull(@CustId,'')

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		select 
			@Total					= count(mp.PointCd)
			 from MAS_Points mp
				--join CRM_TransactionType crm on crm.TransTypeId = @TransTypeId
				--join [WAL_PointOrder] wa on mp.PointCd = wa.PointCd
			where mp.CustId like @CustId

		set	@TotalFiltered = @Total 
		if @PageSize < 0
		begin
			set	@PageSize				= 10
		end


	--1
		SELECT [PointCd]
			  ,[PointType]
			  ,p.[CustId]
			  ,[CurrPoint] as CurrentPoint
			  ,[LastDt] as LastDate
			  ,'Platinum' as [Priority]
			  ,(select sum(OrderAmount) from WAL_PointOrder where PointCd = p.PointCd) as sumOrderAmt
			  ,(select sum(CreditPoint) from WAL_PointOrder where PointCd = p.PointCd) as sumCreditPoint
			  ,(select sum(Point) from WAL_PointOrder where PointCd = p.PointCd) as sumDebitPoint
			  ,c.FullName 
			  ,'*****' + right(c.Phone ,4) as Phone
			  ,c.Email
		  FROM MAS_Points p 
			join MAS_Customers c on p.CustId = c.CustId
		  WHERE p.CustId like @custId 
		  ORDER BY [PointCd] desc
				  offset @Offset rows	
					fetch next @PageSize rows only
	  --2
	
	
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Cor_Get_Point_Total ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@custId ' + @custId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Customer', 'GET', @SessionID, @AddlInfo
	end catch