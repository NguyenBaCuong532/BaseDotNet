-- =============================================
-- Author:		hoanpv@sunshinegroup.vn
-- Description:	Them moi hoac sua thong tin ELE_BuildZone
-- =============================================
CREATE procedure [dbo].[sp_res_elevator_build_zone_set]
	 @UserId UNIQUEIDENTIFIER = NULL
	,@Id int = null
	,@AreaCd nvarchar(50) = null
	,@BuildZone nvarchar(50) = null
	,@ProjectCd  nvarchar(255) = null
	,@buildingCd nvarchar(50) = null
	,@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
begin
	begin try
	DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(250);

	if exists (select Id from [dbo].[ELE_BuildZone] where Id = @Id)
		begin
			if exists(select 1 from [ELE_BuildZone] 
				where ProjectCd = @ProjectCd and [areaCd] = @areaCd and BuildZone = @BuildZone and id <> @Id)
			begin
				set @valid = 0
				set @messages = N'Đã tồn tại không thể sửa trùng'
				goto FINAL
			end

			update [dbo].[ELE_BuildZone]
				set [BuildZone] = @BuildZone
				  ,[AreaCd] = @AreaCd
				  ,[ProjectCd] = @ProjectCd
				  ,[created_at] = getdate()
				  ,[created_by] = CAST(@UserId AS NVARCHAR(50))
			 where Id = @Id
		end
	else
		begin
			if exists(select 1 from [ELE_BuildZone] where ProjectCd = @ProjectCd and [areaCd] = @areaCd and BuildZone = @BuildZone )
			begin
				set @valid = 0
				set @messages = N'Đã tồn tại không thể thêm'
				goto FINAL
			end

			insert into [dbo].[ELE_BuildZone]
					   ([BuildZone]
					   ,[AreaCd]
					   ,[ProjectCd]
					   ,[created_at]
					   ,[created_by])
			values	   (
						@BuildZone
					   ,@AreaCd
					   ,@ProjectCd
					   ,getdate()
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
		set @ErrorMsg					= 'sp_Hom_ELE_BuildZone_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '
		set @valid = 0
		set @messages = error_message()
		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ELE_BuildZone', 'POST,PUT', @SessionID, @AddlInfo
	end catch

	FINAL:
    SELECT @valid AS valid
        , @messages AS [messages];
end