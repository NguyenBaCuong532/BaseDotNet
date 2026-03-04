-- 4. SP Page
CREATE    PROCEDURE [dbo].[sp_res_elevator_device_category_page]
	@UserId				UNIQUEIDENTIFIER, 
	@filter				nvarchar(200),
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@ProjectCd			nvarchar(30) = null,
	@buildingCd			nvarchar(50) = null,
	@BuildZone			nvarchar(50) = null,
	@gridWidth			int = 0,
	@FloorNumber		int = 0,
	@acceptLanguage		NVARCHAR(50) = N'vi-VN'
AS
BEGIN
	BEGIN TRY 
		DECLARE @Total		BIGINT
		DECLARE @GridKey	NVARCHAR(100) = 'view_elevator_device_category_page'

		SET @Offset = ISNULL(@Offset, 0)
		SET @PageSize = ISNULL(@PageSize, 10)
		SET @filter = ISNULL(@filter,'')

		IF @PageSize = 0 SET @PageSize = 10
		IF @Offset < 0 SET @Offset = 0
		IF @buildingCd = 'all' SET @buildingCd = NULL
		
		SELECT @Total = COUNT(a.Id)
		FROM MAS_Elevator_Device_Category a 
			LEFT JOIN mas_Projects b ON a.ProjectCd = b.ProjectCd
		WHERE (@ProjectCd IS NULL OR a.ProjectCd = @ProjectCd)
		  AND (@buildingCd IS NULL OR a.buildingCd = @buildingCd)
		  AND (@filter = '' OR HardwareId LIKE '%' + @filter + '%' OR ElevatorShaftName LIKE '%' + @filter + '%')

		-- root	
		SELECT recordsTotal = @Total
			  ,recordsFiltered = @Total
			  ,gridKey = @GridKey
			  ,valid = 1
		
		-- grid config
		IF @Offset = 0
		BEGIN
			SELECT *
			FROM [dbo].fn_config_list_gets_lang(@GridKey, @gridWidth, @acceptLanguage)
			ORDER BY [ordinal];
		END
	
		-- data
		SELECT a.[Id]
			  ,a.[projectCd]
			  ,buildingCd
			  ,b.projectName
			  ,a.hardwareId
			  ,a.elevatorBank
			  ,a.elevatorShaftName
			  ,a.elevatorShaftNumber
			  ,a.isActived
			  ,a.created_at
		FROM [dbo].[MAS_Elevator_Device_Category] a 
			LEFT JOIN mas_Projects b ON a.ProjectCd = b.ProjectCd
		WHERE (@ProjectCd IS NULL OR a.ProjectCd = @ProjectCd)
		  AND (@buildingCd IS NULL OR a.buildingCd = @buildingCd)
		  AND (@filter = '' OR HardwareId LIKE '%' + @filter + '%' OR ElevatorShaftName LIKE '%' + @filter + '%')
		ORDER BY a.created_at DESC
		OFFSET @Offset ROWS	
		FETCH NEXT @PageSize ROWS ONLY

	END TRY
	BEGIN CATCH
		DECLARE @ErrorNum int, @ErrorMsg varchar(200), @ErrorProc varchar(50), @SessionID int, @AddlInfo varchar(max)
		SET @ErrorNum = ERROR_NUMBER()
		SET @ErrorMsg = 'sp_res_elevator_device_category_page ' + ERROR_MESSAGE()
		SET @ErrorProc = ERROR_PROCEDURE()
		EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'MAS_Elevator_Device_Category', 'GET', @SessionID, ''
	END CATCH
END