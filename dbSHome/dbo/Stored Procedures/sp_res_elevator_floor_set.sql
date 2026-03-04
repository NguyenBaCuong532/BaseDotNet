

-- =============================================
-- Author:		hoanpv@sunshinegroup.vn
-- Description:	Them moi hoac sua thong tin MAS_Elevator_Floor
-- =============================================
CREATE procedure [dbo].[sp_res_elevator_floor_set]
	 @UserId UNIQUEIDENTIFIER = NULL
	,@Id int
	,@ProjectCd nvarchar(30)
	,@buildingCd nvarchar(50)
	,@BuildZone nvarchar(50)
	,@FloorName nvarchar(50)
	,@FloorType nvarchar(50)
	,@FloorNumber int
	,@AreaCd nvarchar(30)
	,@acceptLanguage nvarchar(50) = 'vi-VN'
	,@SysDate nvarchar(50)
as
begin
	begin try
	DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(250);

	if exists (select Id from [dbo].[MAS_Elevator_Floor] where Id = @Id)
		begin
			
			update	[dbo].[MAS_Elevator_Floor]
				SET [ProjectCd] = @ProjectCd
				  ,[buildingCd] = @buildingCd
				  ,[AreaCd] = @AreaCd
				  ,[BuildZone] = @BuildZone
				  ,[FloorName] = @FloorName
				  ,[FloorType] = @FloorType
				  ,[FloorNumber] =@FloorNumber
				  ,created_at = getdate()
			 where Id = @Id
		end
	else
		begin
			insert into [dbo].[MAS_Elevator_Floor]
					   ([ProjectCd]
					   ,[buildingCd]
					   ,[AreaCd]
					   ,[BuildZone]
					   ,[FloorName]
					   ,[FloorType]
					   ,[FloorNumber]
					   ,created_at)
			values	   (@ProjectCd
					   ,@buildingCd
					   ,@AreaCd
					   ,@BuildZone
					   ,@FloorName
					   ,@FloorType
					   ,@FloorNumber
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
		set @ErrorMsg					= 'sp_Hom_MAS_Elevator_Floor_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '
		set @valid = 0
		set @messages = error_message()
		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'MAS_Elevator_Floor', 'POST,PUT', @SessionID, @AddlInfo
	end catch
	FINAL:
    SELECT @valid AS valid
        , @messages AS [messages];
end