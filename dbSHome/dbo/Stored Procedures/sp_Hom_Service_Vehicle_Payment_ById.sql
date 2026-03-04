







CREATE procedure [dbo].[sp_Hom_Service_Vehicle_Payment_ById]
	@userId	nvarchar(50),
	@cardVehicleId bigint,
	--@Statuses int = null,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out
as
	begin try

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		--set		@filter					= isnull(@filter,'')
		--set		@departmentCd			= isnull(@departmentCd,'')

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		select	@Total					= count(a.ReceivableId)
			FROM MAS_Service_Receivable a 
				join MAS_CardVehicle c on a.srcId = c.CardVehicleId
			WHERE a.ServiceTypeId = 2 
				and a.srcId = @cardVehicleId 

		set	@TotalFiltered = @Total

		if @PageSize < 0
		begin
			set	@PageSize				= 10
		end
	
	--1
		SELECT a.[ReceivableId]
			  ,a.[ReceiveId]
			  ,a.[ServiceTypeId]
			  
			  ,a.[Quantity]
			  ,a.[Price]
			  --,a.[Amount]
			  --,a.[VatAmt]
			  --,a.[NtshAmt]
			  ,a.[TotalAmt] as [Amount]
			  ,convert(nvarchar(10),a.[fromDt],103) as StartDate
			  ,convert(nvarchar(10),a.[ToDt],103) as EndDate
			  ,s.IsPayed
			  ,s.PayedDt as PayedDate
			  ,c.VehicleNum as VehNum
			  ,c.CardVehicleId 
			  ,e.Contents as Remart
			  ,e.ReceiptId as VehiclePayId
			  ,e.[Object] as CustomerName
	  FROM [dbo].MAS_Service_Receivable a 
			join MAS_CardVehicle c on a.srcId = c.CardVehicleId
			inner join MAS_Service_ReceiveEntry s on a.ReceiveId = s.ReceiveId
			left join MAS_Service_Receipts e on a.[ReceiveId] = e.[ReceiveId]
		WHERE a.ServiceTypeId = 2 
			and a.srcId = @cardVehicleId 
		ORDER BY a.srcId, a.fromDt DESC
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
		set @ErrorMsg					= 'sp_Hom_Service_Vehicle_Payment_ById ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'VehiclePayment', 'GET', @SessionID, @AddlInfo
	end catch