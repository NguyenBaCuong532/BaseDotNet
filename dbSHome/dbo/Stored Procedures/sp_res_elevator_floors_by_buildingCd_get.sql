-- Oid = mã chính; BuildCd = phụ (tương thích ngược, bỏ sau migrate).
CREATE procedure [dbo].[sp_res_elevator_floors_by_buildingCd_get]
	@UserId	UNIQUEIDENTIFIER = NULL,
	@FloorId int = null,
	@BuildCd nvarchar(50)='A1',
	@buildingOid UNIQUEIDENTIFIER = NULL,
	@ProjectCd nvarchar(50),
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
	begin try
		-- Ưu tiên oid (mã chính); khi có buildingOid thì resolve BuildCd từ bảng
		IF @buildingOid IS NOT NULL AND @BuildCd IS NULL
			SELECT @BuildCd = BuildingCd FROM MAS_Buildings WHERE oid = @buildingOid;
	begin tran t1
		IF @FloorId IS NULL
		BEGIN
			SELECT
				  EL.Id
				 ,EL.FloorName
				 ,EL.FloorNumber
				 ,EL.SysDate
				 ,EL.CreatedBy
			FROM 
			ELE_Floor AS EL 
			WHERE  EL.BuildCd = @BuildCd and el.ProjectCd = @ProjectCd
			order by EL.FloorNumber
			END
		ELSE
			BEGIN
				SELECT
				  EL.Id
				 ,EL.FloorName
				 ,EL.FloorNumber
				 ,EL.SysDate
				 ,EL.CreatedBy
			FROM 
			ELE_Floor AS EL 
			WHERE  EL.id = @FloorId
			order by EL.FloorNumber
			
		END
		commit tran t1
	end try
	begin catch
			declare	@ErrorNum				int,
					@ErrorMsg				varchar(200),
					@ErrorProc				varchar(50),

					@SessionID				int,
					@AddlInfo				varchar(max)

			set @ErrorNum					= error_number()
			set @ErrorMsg					= 'sp_Hom_Get_Elevator_Floor_ById ' + error_message()
			set @ErrorProc					= error_procedure()

			set @AddlInfo					= '@UserID ' + cast(@UserID as varchar(50))

			exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Elevator_Floor', 'GET', @SessionID, @AddlInfo
		end catch


		--EXEC sp_Hom_Get_Elevator_Floor '1', null, 'R1'