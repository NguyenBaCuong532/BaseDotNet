
CREATE   PROCEDURE [dbo].[sp_res_elevator_floor_list]
    @UserId UNIQUEIDENTIFIER = NULL,
    @projectCd  NVARCHAR(40) = NULL,
	@areaCd NVARCHAR(40) = NULL,
	@buildZone nvarchar(40) = null,
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY

	

    --1 
   SELECT distinct f.FloorName as name
			  ,f.FloorNumber as value
		 FROM MAS_Elevator_Floor f 
		  where f.ProjectCd = @projectCd 
				And f.AreaCd = @areaCd 
				--and f.BuildZone = @buildZone
			ORDER BY value

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_elevator_floor_list' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = ' ';

    EXEC utl_Insert_ErrorLog @ErrorNum,
                             @ErrorMsg,
                             @ErrorProc,
                             'Elevator_Floor',
                             'GET',
                             @SessionID,
                             @AddlInfo;
END CATCH;