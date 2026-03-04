
-- =============================================
-- Author:		duongpx
-- Create date: 10/5/2024 10:00:05 AM
-- Description:	xoa meta
-- =============================================
CREATE procedure [dbo].[sp_meta_info_del]
	 @UserId nvarchar(450)
	,@Oids nvarchar(50)
	,@acceptLanguage nvarchar(50) = 'vi-VN'
as
begin
	declare @message nvarchar(100) = N'Xóa thành công'
	 declare @valid int = 1
	begin try

		--1 profile
		DELETE m
		  FROM meta_info m
		WHERE exists(select 1 from dbo.fn_split_string(@Oids,',') x 
			where x.part = m.Oid)
				

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_meta_info_del ' + error_message()
		set @ErrorProc					= error_procedure()
		set @AddlInfo					= ' '
		set @valid = 0
		set @message =  error_message()
		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'image', 'Del', @SessionID, @AddlInfo
	
	end catch
	
	FINAL:
	select @valid as valid, @message as messages
	   
	end