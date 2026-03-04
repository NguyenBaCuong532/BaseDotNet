
CREATE procedure [dbo].[sp_Hom_Card_LogRead_ByCardCd]
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

		select	@Total					= count(a.LogId)
			FROM TRS_LogReader a 
				Inner Join MAS_Cards e On a.CardId = e.CardId
			WHERE e.CardCd = @CardCd

		set	@TotalFiltered = @Total

		if @PageSize < 0
		begin
			set	@PageSize				= 5
		end

		SELECT a.LogId
			  ,e.CardCd
			  ,b.StationName 
			  ,c.ServiceName
			  ,[dbo].[fn_Get_TimeAgo] (a.LogDt,getdate()) as LogDate
			  ,c.ServiceId

	  FROM TRS_LogReader a 
		INNER JOIN MAS_StationReader b On a.StationId = b.StationId 
		INNER JOIN MAS_Services c ON b.ServiceId = c.ServiceId 
		INNER JOIN MAS_ServiceTypes d ON c.ServiceTypeId = d.ServiceTypeId 
		INNER JOIN MAS_Cards e On a.CardId = e.CardId
	  WHERE e.CardCd = @CardCd
	ORDER BY  LogDt DESC
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
		set @ErrorMsg					= 'sp_Get_CardLogs_ByCardCd ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserId ' +@UserId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Logs', 'GET', @SessionID, @AddlInfo
	end catch