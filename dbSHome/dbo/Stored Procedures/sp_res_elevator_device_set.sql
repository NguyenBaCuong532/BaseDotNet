

-- =============================================
-- Author:		hoanpv@sunshinegroup.vn
-- Description:	Them moi hoac sua thong tin MAS_Elevator_Device
-- =============================================
CREATE procedure [dbo].[sp_res_elevator_device_set]
	 @UserId UNIQUEIDENTIFIER = NULL
	,@Id int
	,@HardwareId nvarchar(50)
	,@FloorNumber int
	,@FloorName nvarchar(50)
	,@ElevatorBank int
	,@ElevatorShaftName nvarchar(30)
	,@ElevatorShaftNumber int
	,@ProjectCd nvarchar(30)
	,@buildingCd nvarchar(30)
	,@areaCd nvarchar(50)
	,@BuildZone nvarchar(50)
	,@IsActived bit
	,@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
begin
	begin try
	DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(250);
	set @HardwareId = LOWER(@HardwareId)

	if exists (select Id from [dbo].[MAS_Elevator_Device] where Id = @Id)
		begin
			if exists(select 1 from [MAS_Elevator_Device] where [HardwareId] = @HardwareId and id <> @Id)
			begin
				set @valid = 0
				set @messages = N'Đã tồn tại mã thiết bị không thể sửa'
				goto FINAL
			end

			update	   [dbo].[MAS_Elevator_Device]
		    set        [HardwareId] = @HardwareId
					  ,[FloorNumber] = @FloorNumber
					  ,[FloorName] = ISNULL((
							SELECT TOP(1) FloorName
							FROM MAS_Elevator_Floor f
							WHERE f.ProjectCd = @projectCd  And f.AreaCd = @areaCd and FloorNumber = ISNULL(@FloorNumber, 0)
						), '')
					  ,[ElevatorBank] =@ElevatorBank
					  ,[ElevatorShaftName] = @ElevatorShaftName
					  ,[ElevatorShaftNumber] = @ElevatorShaftNumber
					  ,[ProjectCd] = @ProjectCd
					  ,[buildingCd] = @buildingCd
					  ,[BuildZone] = @BuildZone
					  ,[areaCd] = @areaCd
					  ,[IsActived] = @IsActived
					  ,created_at = getdate()
			 where Id = @Id
		end
	else
		begin
			if exists(select 1 from [MAS_Elevator_Device] where [HardwareId] = @HardwareId)
			begin
				set @valid = 0
				set @messages = N'Đã tồn tại mã thiết bị không thể thêm'
				goto FINAL
			end

			insert into [dbo].[MAS_Elevator_Device]
					   ([HardwareId]
					   ,[FloorNumber]
					   ,[FloorName]
					   ,[ElevatorBank]
					   ,[ElevatorShaftName]
					   ,[ElevatorShaftNumber]
					   ,[ProjectCd]
					   ,[buildingCd]
					   ,[areaCd]
					   ,[BuildZone]
					   ,[IsActived]
					   ,created_at)
			values	   (@HardwareId
					   ,@FloorNumber
					   ,ISNULL((
							SELECT TOP(1) FloorName
							FROM MAS_Elevator_Floor f
							WHERE f.ProjectCd = @projectCd  And f.AreaCd = @areaCd and FloorNumber = ISNULL(@FloorNumber, 0)
						), '')
					   ,@ElevatorBank
					   ,@ElevatorShaftName
					   ,@ElevatorShaftNumber
					   ,@ProjectCd
					   ,@buildingCd
					   ,@areaCd
					   ,@BuildZone
					   ,@IsActived
					   ,getdate()
						)
			
			set @Id = @@IDENTITY
		end

		set @valid = 1
		set @messages = N'Thành công!'

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_MAS_Elevator_Device_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '
		set @valid = 0
		set @messages = error_message()

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'MAS_Elevator_Device', 'set', @SessionID, @AddlInfo
	end catch
	FINAL:
    SELECT @valid AS valid
        , @messages AS [messages];
end