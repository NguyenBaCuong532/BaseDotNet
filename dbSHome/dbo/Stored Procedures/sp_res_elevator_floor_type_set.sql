-- =============================================
-- Author:		hoanpv@sunshinegroup.vn
-- Description:	Them moi hoac sua thong tin ELE_FloorType
-- =============================================
CREATE procedure [dbo].[sp_res_elevator_floor_type_set]
	@UserId UNIQUEIDENTIFIER = NULL
	,@Id int
	,@BuildCd nvarchar(50)
	,@FloorTypeName nvarchar(200)
	,@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
	begin try
			if exists (select Id from [dbo].[ELE_FloorType] where Id = @Id)
				begin
			
					update [dbo].[ELE_FloorType]
						set BuildCd = @BuildCd
						  ,FloorTypeName = @FloorTypeName
						  ,[SysDate] = getdate()
						  ,[CreatedBy] = CAST(@UserId AS NVARCHAR(50))
					 where Id = @Id
				end
			else
				begin
					insert into [dbo].[ELE_FloorType]
							   ([BuildCd]
							   ,FloorTypeName
							   ,[SysDate]
							   ,[CreatedBy])
					values	   (@BuildCd
							   ,@FloorTypeName
							   ,getdate()
							   ,CAST(@UserId AS NVARCHAR(50)))
					set @Id = @@IDENTITY
				end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_ELE_FloorType_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ELE_FloorType', 'POST,PUT', @SessionID, @AddlInfo
	end catch