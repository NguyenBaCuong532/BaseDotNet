

CREATE procedure [dbo].[sp_Hom_Card_LogPayment_ByCardCd]
	@UserId	nvarchar(450),
	@CardCd nvarchar(50),
	@Offset				int				= 0,
	@PageSize			int				= 5,
	@Total				int out,
	@TotalFiltered		int out
as
	begin try	

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 5)
		set		@Total					= isnull(@Total, 0)

		if		@PageSize	= 0			set @PageSize	= 5
		if		@Offset		< 0			set @Offset		=  0

		select	@Total					= count(a.PointTranId)
			FROM WAL_PointOrder a 
				--INNER JOIN MAS_Cards e On a.CardId = e.CardId
			WHERE a.TransNo = @CardCd

		set	@TotalFiltered = @Total

		if @PageSize < 0
		begin
			set	@PageSize				= 5
		end

		SELECT a.TransNo as CardCd
			  ,b.PosName StationName 
			  ,c.ServiceName
			  ,[dbo].[fn_Get_TimeAgo] (a.TranDt,getdate()) as LogDate
			  --,a.Id
			  ,a.OrderAmount Amount 
			  ,a.Point
	  FROM WAL_PointOrder a 
		INNER JOIN WAL_ServicePOS b On a.PosCd = b.PosCd 
		INNER JOIN WAL_Services c ON b.ServiceKey = c.ServiceKey 
		--INNER JOIN MAS_ServiceTypes d ON c.ServiceTypeId = d.ServiceTypeId 
		--INNER JOIN MAS_Cards e On a.CardId = e.CardId
	  WHERE a.TransNo = @CardCd
		ORDER BY  TranDt DESC
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
		set @ErrorMsg					= 'sp_Get_CardPayments_ByCardCd ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserId ' +@UserId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Payment', 'GET', @SessionID, @AddlInfo
	end catch