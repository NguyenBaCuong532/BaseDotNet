

-- =============================================
-- Author:		duongpx
-- Create date: 7/13/2024 9:55:31 PM
-- Description:	Chi tiết loại thông báo
-- =============================================
CREATE     PROCEDURE [dbo].[sp_hrm_notify_formula_field]
	@UserId			nvarchar(450),
	@acceptLanguage nvarchar(50) = 'vi-VN',
	@formulaId		uniqueidentifier
as
	begin try
	declare @tableKey nvarchar(200) = N'NotifyFormula'
		   ,@groupKey nvarchar(200) = N'common_group'
	declare @orgId uniqueidentifier = (select top 1 orgId from Users where userId = @userId)
	if not exists(select 1 from NotifyFormula where formulaId = @formulaId) set @formulaId = newid()
	--1
	select id = @formulaId 
		  ,tableKey = @tableKey
		  ,groupKey = @groupKey

	SELECT *
		FROM dbo.fn_get_field_group (@groupKey) 
			order by intOrder

	select b.*
	into #tempIn
	from NotifyFormula b
	WHERE (b.formulaId = @formulaId)
	
	if not exists(select 1 from #tempIn)
	insert into #tempIn (formulaId,name,app_st,created_at)
	values(@formulaId,'',1,getdate())
	-- data
	exec dbo.sp_config_data_fields_v2 @formulaId, 'formulaId', @tableKey, '#tempIn', @acceptLanguage
	
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_hrm_notify_formula_field ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'NotifyFormula', 'GET', @SessionID, @AddlInfo
	end catch