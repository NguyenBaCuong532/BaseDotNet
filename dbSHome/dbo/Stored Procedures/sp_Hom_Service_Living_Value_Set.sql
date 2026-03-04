




CREATE procedure [dbo].[sp_Hom_Service_Living_Value_Set]
	@UserID		nvarchar(450),
	@TrackingId		int,
	@LivingId		int,	
	@FromDate	nvarchar(10),
	@ToDate		nvarchar(10),
	@FromNum	int,
	@ToNum		int

as
	begin try		
	declare @valid bit = 1
	declare @messages nvarchar(100) = 'Cập nhật thành công'	

	if not exists(select LivingId from MAS_Apartment_Service_Living where LivingId = @LivingId)
		begin 
			set @valid = 0
			set @messages = N'Không tìm thấy công tơ'
		end
	else if convert(datetime,@ToDate,103) < convert(datetime,@FromDate,103)
		begin 
			set @valid = 0
			set @messages = N'Nhập ngày bị sai'
		end
	else if @ToNum < @FromNum
		begin 
			set @valid = 0
			set @messages = N'Số công tơ không được bị âm'
		end
	else if not exists(SELECT TrackingId FROM MAS_Service_Living_Tracking a 
			 JOIN MAS_Apartments b ON a.ApartmentId = b.ApartmentId  
			WHERE TrackingId = @TrackingId)
	begin
		if not exists(SELECT TrackingId FROM MAS_Service_Living_Tracking a 
			 JOIN MAS_Apartments b ON a.ApartmentId = b.ApartmentId  
			WHERE a.LivingId = @LivingId and a.ToDt = convert(datetime,@toDate,103))
		
			INSERT INTO [dbo].[MAS_Service_Living_Tracking]
				   ([ProjectCd]
				   ,[ApartmentId]
				   ,[PeriodMonth]
				   ,[PeriodYear]
				   ,[LivingId]
				   ,[FromDt]
				   ,[ToDt]
				   ,[LivingTypeId]
				   ,[FromNum]
				   ,[ToNum]
				   ,[TotalNum]
				   ,[Amount]
				   ,[InputType]
				   ,[IsCalculate]
				   ,[IsBill]
				   ,IsReceivable
				   ,SysDt
				   )
			SELECT
					d.ProjectCd
				   ,a.ApartmentId
				   ,month(convert(datetime,@ToDate,103))
				   ,year(convert(datetime,@ToDate,103))
				   ,b.LivingId
				   ,isnull(convert(datetime,@FromDate,103),b.MeterDate)
				   ,convert(datetime,@ToDate,103)
				   ,b.LivingTypeId
				   ,isnull(@FromNum,b.MeterNum)
				   ,@ToNum
				   ,@ToNum-isnull(b.MeterLastNum,b.MeterNum)
				   ,0
				   ,N'Nhập tay'
				   ,0
				   ,0
				   ,0
				   ,getdate()
			FROM MAS_Apartments a 
				join MAS_Apartment_Service_Living b on a.ApartmentId = b.ApartmentId
				join MAS_Rooms c on a.RoomCode = c.RoomCode
				join MAS_Buildings d on c.BuildingCd = d.BuildingCd 
			WHERE b.LivingId = @LivingId
		else
		begin
			set @valid = 0
			set @messages = N'Đã tồn tại không thể thêm dữ liệu'
		end
	end	 
	else
	begin
		if exists(select receiveId from MAS_Service_Receivable where ServiceTypeId = 3 and srcId = @TrackingId)
		begin 
			set @valid = 0
			set @messages = N'Đã dự thu không thể sửa'
		end
		else
			UPDATE a
			   SET [FromDt] = convert(datetime,@FromDate,103)
				  ,[ToDt] = convert(datetime,@ToDate,103)
				  ,[FromNum] = @FromNum
				  ,ToNum = @ToNum
				  ,TotalNum = @ToNum - @FromNum
				  ,[InputType] = N'Nhập tay'
				  ,IsCalculate = 0
			FROM [dbo].MAS_Service_Living_Tracking a 
				join MAS_Apartment_Service_Living c on a.LivingId = c.LivingId
				INNER JOIN MAS_Apartments b On c.ApartmentId = b.ApartmentId 
			WHERE TrackingId = @TrackingId
	end
	
	if @valid = 1
	begin
		Update t
			set MeterLastNum = @ToNum
			   ,MeterLastDt = convert(datetime,@ToDate,103)
		 from MAS_Apartment_Service_Living t 
			join MAS_Service_Living_Tracking b on t.LivingId = b.LivingId
			join MAS_Apartments c on t.ApartmentId = c.ApartmentId
		 where t.LivingId = @LivingId
	end

	 select @valid as valid
		   ,@messages as [messages]

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Service_Living_Value_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ServiceLiving', 'Ins', @SessionID, @AddlInfo
	end catch