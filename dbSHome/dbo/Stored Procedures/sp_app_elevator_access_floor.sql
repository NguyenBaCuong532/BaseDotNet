-- =============================================
-- Author:		duongpx
-- Create date: 8/26/2025 3:31:09 PM
-- Description:	chon tầng lưu vào lịch sử
-- =============================================
CREATE procedure [dbo].[sp_app_elevator_access_floor]
	 @UserId		UNIQUEIDENTIFIER
	,@floorName		nvarchar(25)
	,@id			nvarchar(50)
	, @acceptLanguage NVARCHAR(50) = 'vi-VN'
as
	begin try
	declare @HardwareId nvarchar(50)
	
	if @id is not null and @id <> ''
		select top 1 @floorName = ISNULL(ef.FloorName, ap.floorNo), @HardwareId = me.HardwareId
		from MAS_Apartments ap
		left join MAS_Elevator_Floor ef on ap.floorOid = ef.oid
		join MAS_Elevator_Device me on me.ProjectCd = ap.projectCd and me.FloorName = ISNULL(ef.FloorName, ap.floorNo)
		where (ap.ApartmentId = cast(@id as int) or (try_cast(@id as uniqueidentifier) is not null and ap.oid = cast(@id as uniqueidentifier)))
			and (ef.FloorName is not null or ap.floorNo is not null)
			AND me.IsActived = 1
		order by me.FloorNumber
	else
	begin
		if len(@floorName) = 1
			set @floorName = '0' + @floorName
		else if len(@floorName) > 2
			set @floorName = left(@floorName,2)
		
		;WITH LastLogs AS (
        SELECT TOP (1)
               d.ProjectCd,
               l.HardwareId
        FROM MAS_Elevator_Log AS l
		JOIN MAS_Elevator_Device d on l.HardwareId = d.HardwareId 
        WHERE l.UserId = @UserId
			AND d.IsActived = 1
		ORDER BY LogDt DESC)
		select top 1 @HardwareId = dd.HardwareId 
		FROM LastLogs ll
			JOIN MAS_Elevator_Device dd on ll.ProjectCd = dd.ProjectCd
		where dd.FloorName = @floorName
			AND dd.IsActived = 1
	end
	if exists (select Id from MAS_Elevator_User where userId = @UserId and floorName = @floorName)
		begin			
			update [dbo].MAS_Elevator_User
				set sysDt = getdate()
				   ,HardwareId = @HardwareId
			 where userId = @UserId and floorName = @floorName
		end
	else if @userId is not null
		begin
		
			INSERT INTO [dbo].[MAS_Elevator_User]
				   ([userId]
				   ,hardwareId
				   ,[floorName]
				   ,[floorNumber]
				   ,[sysDt]				   
				   )
			 VALUES
				   (@userId
				   ,@HardwareId
				   ,@floorName
				   ,null
				   ,getdate()				   
				   )
		end
				

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_ELE_Access_Floor ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ELE_Access', 'Set', @SessionID, @AddlInfo
	end catch