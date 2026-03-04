-- =============================================
-- Author:		<Author,,MinhDT>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_card_vehicle_history_change_page]		
	@UserId		UNIQUEIDENTIFIER = NULL,
	@filter		nvarchar(60),
	@CardId INT = 0,
	@cardOid UNIQUEIDENTIFIER = NULL,
	@gridWidth			int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@AcceptLanguage VARCHAR(20) = 'vi-VN'
	--@Total				int out,
	--@TotalFiltered		int out,
	--@GridKey		nvarchar(100) out

	
AS
BEGIN TRY
	IF @cardOid IS NOT NULL
		SET @CardId = ISNULL((SELECT CardId FROM MAS_Cards WHERE oid = @cardOid), 0);

	declare @Total		bigint
	declare @GridKey	nvarchar(100) = 'view_vehicle_history_change'

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)		
		set		@GridKey				= 'view_vehicle_history_change'

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		set		@Total					= isnull(@Total, 0)
		
	select	@Total					= count(a.userId)
		from Users a 

	set	@Total = @Total
		
	--root	
	select recordsTotal = @Total
		  ,recordsFiltered = @Total
		  ,gridKey = @GridKey
		  ,valid = 1
	
	if @Offset=0
		begin
			SELECT * FROM dbo.[fn_config_list_gets_lang] (@GridKey, 0, @AcceptLanguage) 
			ORDER BY [ordinal]
		end
   
   SELECT 
		[CardVehicleId]
		,[AssignDate]
		,[CardId]
		,[CustId]
		,[VehicleNo]
		,[VehicleTypeId]
		,[VehicleName]
		,[VehicleColor]
		,[StartTime]
		,[EndTime]
		,[Status]
		,[ServiceId]
		,[RegCardVehicleId]
		,[RequestId]
		,[isVehicleNone]
		,[monthlyType]
		,[VehicleNum]
		,[lastReceivable]
		,[Mkr_Id]
		,[Mkr_Dt]
		,[Auth_id]
		,[Auth_Dt]
		,[ProjectCd]
		,[ApartmentId]
		,[Reason]
		,[SaveDate]
		,[SaveId]
		,[endTime_Tmp]
		,[isCharginFee]
		,[SaveKey]
		,ProcName
    FROM MAS_CardVehicle_H
	WHERE  (@cardOid IS NOT NULL AND cardOid = @cardOid) OR (@cardOid IS NULL AND CardId = @CardId)
   ORDER BY AssignDate
	offset @Offset rows
	fetch next @PageSize rows only

END TRY

BEGIN CATCH
    -- Xử lý lỗi
    DECLARE 
        @ErrorNum INT,
        @ErrorMsg NVARCHAR(200),
        @ErrorProc NVARCHAR(50),
        @AddlInfo NVARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_GetUsersWithFilters ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = 'An error occurred during user filtering.';

    -- Lưu lỗi vào bảng log
    EXEC utl_Insert_ErrorLog 
        @ErrorNum, 
        @ErrorMsg, 
        @ErrorProc, 
        'userInfor', 
        'FILTER',
        NULL,
        @AddlInfo;
END CATCH