
-- =============================================
-- Author:		duongpx
-- Description:	Thêm khu vực cho tòa
-- =============================================
CREATE procedure [dbo].[sp_res_elevator_area_set]
	 @UserId UNIQUEIDENTIFIER = NULL
	,@Id int = null
	,@areaCd nvarchar(50)
	,@AreaName  nvarchar(255)
	,@ProjectCd nvarchar(30)
	,@BuildingCd nvarchar(30)
	,@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
begin
	begin try
	DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(250);

	if exists (select Id from [dbo].[ELE_BuildArea] where Id = @Id)
		begin
			if exists(select 1 from [ELE_BuildArea] where ProjectCd = @ProjectCd and [areaCd] = @areaCd and id <> @Id)
			begin
				set @valid = 0
				set @messages = N'Đã tồn tại không thể sửa trùng'
				goto FINAL
			end

			update [dbo].[ELE_BuildArea]
				set [areaCd] = @areaCd
				  ,[AreaName] = @AreaName
				  ,[ProjectCd] = @ProjectCd
				  ,[BuildingId] = @BuildingCd
				  ,[created_at] = getdate()
				  ,[created_by] = CAST(@UserId AS NVARCHAR(50))
			 where Id = @Id
		end
	else
		begin
			if exists(select 1 from [ELE_BuildArea] where ProjectCd = @ProjectCd and [areaCd] = @areaCd)
			begin
				set @valid = 0
				set @messages = N'Đã tồn tại không thể thêm'
				goto FINAL
			end

			insert into [dbo].[ELE_BuildArea]
					   ([areaCd]
					   ,[AreaName]
					   ,[ProjectCd]
					   ,[created_at]
					   ,[BuildingId]
					   ,[created_by])
			values	   (@areaCd
					   ,@AreaName
					   ,@ProjectCd
					   ,getdate()
					   ,@BuildingCd
					   ,CAST(@UserId AS NVARCHAR(50)))
			set @Id  = @@IDENTITY
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
		set @ErrorMsg					= 'sp_res_elevator_area_set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '
		set @valid = 0
		set @messages = error_message()
		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ELE_BuildArea', 'set', @SessionID, @AddlInfo
	end catch

	FINAL:
    SELECT @valid AS valid
        , @messages AS [messages];
end