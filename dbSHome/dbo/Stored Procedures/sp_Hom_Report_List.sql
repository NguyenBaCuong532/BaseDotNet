
CREATE procedure [dbo].[sp_Hom_Report_List]
	@userId	nvarchar(450),
	@report_type int = -1
	
as
	begin try
		--
		SELECT [report_id]
			  ,[int_order]
			  ,[report_type]
			  ,[report_group]
			  ,[report_name]
			  ,[template_url]
			  ,[template_type]
			  ,[api_url]
			  ,[active]
			  ,[mkr_id]
			  ,[mkr_dt]
		  FROM [dbo].[MAS_report_info] a
			where @report_type = -1 AND [active] = 1 or report_type = @report_type AND [active] = 1
			ORDER BY a.[int_order]

		SELECT [id]
			  ,[report_id]
			  ,[param_cd]
			  ,[param_name]
			  ,[param_type]
			  ,[param_default]
			  ,[create_dt]
			  ,[param_object]
		  FROM [dbo].[MAS_report_param] p
		  where exists(select 1 FROM [dbo].[MAS_report_info] a
			where @report_type = -1 AND [active] = 1 or report_type = @report_type and a.report_id = p.report_id AND [active] = 1)

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Report_List ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_Hom_Report_List', 'POST,PUT', @SessionID, @AddlInfo
	end catch