
-- =============================================
-- Author:		duongpx
-- Create date: 2/25/2025 11:48:08 PM
-- Description:	danh sách công thức thông báo
-- =============================================
CREATE     PROCEDURE [dbo].[sp_hrm_notify_formula_list]
	 @UserID		UNIQUEIDENTIFIER
	,@all		nvarchar(100) = null
	,@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
begin
	begin try	
		
		SELECT [name] = objName
			  ,[value] = null--
		from dbo.fn_config_data_gets_lang('common_all', @acceptLanguage)
		where @all is not null
		union all
		SELECT [name] = name
			  ,[value] = (cast(formulaId as varchar(50)))
		FROM [dbo].NotifyFormula a
		WHERE [app_st] = 1
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_hrm_notify_Formula_list ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@ ' + cast(0  as varchar)

		exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'NotifyFormula', 'Set', @SessionID, @AddlInfo
	end catch


	end