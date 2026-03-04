-- =============================================
-- Author:		Namhm
-- Create date: 25/09/2025
-- Description:	Trang lịch sử sử dụng thang máy
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_elevator_usage_history_page] 
	-- Add the parameters for the stored procedure here
	@userId UNIQUEIDENTIFIER = null,
	@clientId nvarchar(50) = null,
	@projectCd	nvarchar(40),
	@filter nvarchar(100) = '',
	@gridWidth			int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@acceptLanguage		NVARCHAR(50) = N'vi-VN'
AS
begin try
		declare @Total		bigint
		declare @GridKey	nvarchar(100) = 'view_elevator_usage_history_page'

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')
		--set		@projectCd				= isnull(@projectCd,'')

		if @PageSize	= 0
        set @PageSize	= 10
		if @Offset < 0
        set @Offset = 0

		select	@Total  = 1000
		--select	@Total  = COUNT(t.LogId)
		--FROM TRS_LogReader t
	 --   JOIN MAS_Cards c on t.CardId = c.CardId and c.ProjectCd = @projectCd
		--LEFT JOIN MAS_Customers cus on cus.CustId = c.CustId OR t.UserId = cus.CustId
		--LEFT JOIN MAS_Apartments a ON c.ApartmentId = a.ApartmentId
		--LEFT JOIN MAS_Elevator_Device ed on t.StationId = ed.Id
		--WHERE 
		--a.RoomCode like '%' + @filter + '%' 
		--or cus.FullName like '%' + @filter +'%'
		--or @filter = '' 

				
		--root	
		select
        recordsTotal = @Total
			  ,recordsFiltered = @Total
			  ,gridKey = @GridKey
			  ,valid = 1
		
    --grid config
		if @Offset = 0
		begin
        SELECT *
        FROM [dbo].fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
        ORDER BY [ordinal];
		end
		
		--SELECT @TotalFiltered
	--1 list
		SELECT t.StationId,
				c.CardCd,
				cus.CustId,
				cus.FullName,
				a.RoomCode,
				ed.AreaCd,
				ed.ElevatorShaftName,
				ed.FloorName,
				t.LogDt
		FROM TRS_LogReader t
	    JOIN MAS_Cards c on t.CardId = c.CardId and c.ProjectCd = @projectCd
		LEFT JOIN MAS_Customers cus on cus.CustId = c.CustId OR t.UserId = cus.CustId
		LEFT JOIN MAS_Apartments a ON c.ApartmentId = a.ApartmentId
		LEFT JOIN MAS_Elevator_Device ed on t.StationId = ed.Id
		WHERE 
		a.RoomCode like '%' + @filter + '%' 
		or cus.FullName like '%' + @filter +'%'
		or c.CardCd like '%' + @filter +'%'
		or @filter = '' 
		ORDER BY  t.LogDt DESC
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
		set @ErrorMsg					= 'sp_res_elevator_usage_history_page' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'elevator_usage', 'GET', @SessionID, @AddlInfo
	end catch