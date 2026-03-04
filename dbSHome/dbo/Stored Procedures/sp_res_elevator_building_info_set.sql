-- =============================================
-- Author:		hoanpv@sunshinegroup.vn
-- Description:	Them moi hoac sua thong tin toa
-- =============================================
CREATE procedure [dbo].[sp_res_elevator_building_info_set]
	 @UserId UNIQUEIDENTIFIER = NULL
	,@Id int
	,@BuildCd nvarchar(50)
	,@BuildName  nvarchar(255)
	,@ProjectCd nvarchar(30)
	,@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
	begin try
	if exists (select Id from [dbo].[ELE_BuildArea] where Id = @Id)
		begin
			
			update [dbo].[ELE_BuildArea]
				set AreaCd = @BuildCd
				  ,AreaName = @BuildName
				  ,[ProjectCd] = @ProjectCd
				  ,created_at = getdate()
				  ,created_by = CAST(@UserId AS NVARCHAR(50))
			 where Id = @Id
		end
	else
		begin
			insert into [dbo].[ELE_BuildArea]
					   (AreaCd
					   ,AreaName
					   ,[ProjectCd]
					   ,created_at
					   ,created_by)
			values	   (@BuildCd
					   ,@BuildName
					   ,@ProjectCd
					   ,getdate()
					   ,CAST(@UserId AS NVARCHAR(50)))
			set @Id  = @@IDENTITY
		end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_ELE_BuildArea_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ELE_BuildArea', 'POST,PUT', @SessionID, @AddlInfo
	end catch