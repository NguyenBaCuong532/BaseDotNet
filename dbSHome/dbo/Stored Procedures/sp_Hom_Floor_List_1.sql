

CREATE   procedure [dbo].[sp_Hom_Floor_List]
	@UserId	nvarchar(40) = null,
	@BuildingCd	nvarchar(40) = NULL,
	@buildingOid UNIQUEIDENTIFIER = NULL -- Ưu tiên sử dụng
as
	begin try
		-- Xác định buildingCd từ buildingOid nếu có
		IF @buildingOid IS NOT NULL AND @BuildingCd IS NULL
		BEGIN
			SELECT @BuildingCd = BuildingCd
			FROM MAS_Buildings
			WHERE oid = @buildingOid;
		END

		--1 
		SELECT distinct 
			ISNULL(ef.FloorName, a.floorNo) as floorNo
			,ISNULL(ef.FloorNumber, a.[Floor]) as [Floor]
		FROM MAS_Apartments a
		LEFT JOIN MAS_Elevator_Floor ef ON a.floorOid = ef.oid
		WHERE (@BuildingCd IS NULL OR a.buildingCd LIKE @BuildingCd 
			   OR (@buildingOid IS NOT NULL AND a.buildingOid = @buildingOid))
		ORDER BY ISNULL(ef.FloorName, a.floorNo)

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Floor_List ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Floor', 'GET', @SessionID, @AddlInfo
	end catch