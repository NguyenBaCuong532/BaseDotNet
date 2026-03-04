
-- =============================================
-- Author:		hoanpv@sunshinegroup.vn
-- Description:	Them moi hoac sua thong tin ELE_BuildZone
-- =============================================
create procedure [dbo].[sp_Hom_ELE_Access_Floor]
	 @UserId nvarchar(450)
	,@floorName  nvarchar(25)
as
	begin try
	declare @projectCd nvarchar(30)
	
	if len(@floorName) = 1
		set @floorName = '0' + @floorName
	else if len(@floorName) > 2
		set @floorName = left(@floorName,2)

	if exists (select Id from MAS_Elevator_User where userId = @UserId and floorName = @floorName)
		begin
			
			update [dbo].MAS_Elevator_User
				set sysDt = getdate()
				   --,floorNumber = null
			 where userId = @UserId and floorName = @floorName
		end
	else if @userId is not null
		begin
		
			INSERT INTO [dbo].[MAS_Elevator_User]
				   ([userId]
				   ,hardwareId
				   ,[floorName]
				   ,[floorNumber]
				   ,[sysDt])
			 VALUES
				   (@userId
				   ,null
				   ,@floorName
				   ,null
				   ,getdate())
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