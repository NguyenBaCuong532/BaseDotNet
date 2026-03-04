------------------
CREATE procedure dbo.[sp_res_elevator_floor_info_set]
	@UserId	UNIQUEIDENTIFIER = NULL,
	@FloorId int,
	@FloorName nvarchar(200),
	@FloorNumber nvarchar(50),
	@FloorTypeId nvarchar(50),
	@BuildCd nvarchar(50),
	@BuildZoneId nvarchar(50),
	@ProjectCd nvarchar(50)
	,@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
	begin try	
		IF not exists(SELECT Id FROM ELE_Floor WHERE Id = @FloorId)
			BEGIN
				INSERT INTO dbo.ELE_Floor
				( FloorName
				, FloorNumber
				, FloorTypeId
				, BuildCd
				, BuildZoneId
				, ProjectCd
				, SysDate
				,CreatedBy)
			VALUES
				(@FloorName
				,@FloorNumber
				,@FloorTypeId
				,@BuildCd
				,@BuildZoneId
				,@ProjectCd
				,GETDATE()
				,CAST(@UserId AS NVARCHAR(50)))
			END
		ELSE
			BEGIN
				UPDATE dbo.ELE_Floor
				SET FloorName = @FloorName
				, FloorNumber = @FloorNumber
				, FloorTypeId = @FloorTypeId
				, BuildCd = @BuildCd
				, BuildZoneId = @BuildZoneId
				, ProjectCd = @ProjectCd
				, SysDate = GETDATE()
				,CreatedBy = CAST(@UserId AS NVARCHAR(50))
				WHERE Id = @FloorId
			END
	end try
	begin catch
			declare	@ErrorNum				int,
					@ErrorMsg				varchar(200),
					@ErrorProc				varchar(50),

					@SessionID				int,
					@AddlInfo				varchar(max)

			set @ErrorNum					= error_number()
			set @ErrorMsg					= 'sp_Hom_Set_Elevator_CardRole ' + error_message()
			set @ErrorProc					= error_procedure()

			set @AddlInfo					= '@UserID ' + cast(@UserID as varchar(50))

			exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Elevator_Floor', 'SET', @SessionID, @AddlInfo
		end catch