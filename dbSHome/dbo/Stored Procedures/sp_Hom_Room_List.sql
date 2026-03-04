


CREATE procedure [dbo].[sp_Hom_Room_List]
	@UserId	UNIQUEIDENTIFIER = null,
	@BuildingCd	nvarchar(40) = NULL,
	@buildingOid UNIQUEIDENTIFIER = NULL, -- Ưu tiên sử dụng
	@floorNo	nvarchar(20) = NULL,
	@floorOid UNIQUEIDENTIFIER = NULL -- Ưu tiên sử dụng
as
	begin try
		-- Xác định buildingCd từ buildingOid nếu có
		IF @buildingOid IS NOT NULL AND @BuildingCd IS NULL
		BEGIN
			SELECT @BuildingCd = BuildingCd
			FROM MAS_Buildings
			WHERE oid = @buildingOid;
		END

		set @floorNo = isnull(@floorNo,'')
		--1 
		SELECT ISNULL(a.RoomCodeView, a.RoomCode) as RoomCode
			  ,ISNULL(ef.FloorName, a.floorNo) as floorNo
			  ,a.WaterwayArea
		FROM MAS_Apartments a
		LEFT JOIN MAS_Elevator_Floor ef ON a.floorOid = ef.oid
		WHERE (@BuildingCd IS NULL OR a.buildingCd LIKE @BuildingCd 
			   OR (@buildingOid IS NOT NULL AND a.buildingOid = @buildingOid))
			and (@floorNo = '' AND @floorOid IS NULL
				 OR (@floorNo <> '' AND ISNULL(ef.FloorName, a.floorNo) LIKE @floorNo + '%')
				 OR (@floorOid IS NOT NULL AND a.floorOid = @floorOid))
		ORDER BY a.RoomCode

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Room_List ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Rooms', 'GET', @SessionID, @AddlInfo
	end catch