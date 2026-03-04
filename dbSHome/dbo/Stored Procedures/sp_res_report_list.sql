-- =============================================
-- Author:		vutc
-- Create date: 11/03/2025 9:09:10 PM
-- Description:	danh sách báo cáo
-- =============================================
CREATE procedure [dbo].[sp_res_report_list]
	@UserId	UNIQUEIDENTIFIER = NULL
	,@AcceptLanguage VARCHAR(20) = 'vi-VN'
	,@report_type int = 1
	
as
	begin try
		drop table if exists #tempReport
		
		-- lấy ngày đầu tháng hiện tại
		DECLARE @FromDayOfLastMonth NVARCHAR(2)
		SET @FromDayOfLastMonth = 1;

		DECLARE @dayOfLastMonth DATETIME = DATEADD(DAY, CONVERT(INT, @FromDayOfLastMonth),
                                                       EOMONTH(DATEADD(MONTH, -1, GETDATE())))
        DECLARE @dayOfThisMonth DATETIME = DATEADD(DAY, CONVERT(INT, @FromDayOfLastMonth), EOMONTH(GETDATE()))
        SET @dayOfThisMonth = DATEADD(SECOND, -1, @dayOfThisMonth)
		DECLARE @defaultFromDate DATETIME, @defaultToDate DATETIME

        SET @defaultFromDate = @dayOfLastMonth
 		--set @defaultFromDate = '20240101'
        SET @defaultToDate = @dayOfThisMonth
		DECLARE @strDefaultFromDate NVARCHAR(50), @strDefaultToDate NVARCHAR(50), @strDefaultDate NVARCHAR(50)
    
	SET @strDefaultFromDate = FORMAT(@defaultFromDate, 'dd/MM/yyyy')
    SET @strDefaultToDate = FORMAT(@defaultToDate, 'dd/MM/yyyy')
    --SET @strDefaultDate = FORMAT(@defaultDate, 'dd/MM/yyyy')

		SELECT cast([report_id] as int) as tableKey
			  ,[int_order]
			  ,[report_type]
			  ,[report_group]
			  ,[report_name] = [report_name]
			  ,[api_url_view]
			  ,[groupKey]
			  ,[api_url_dowload]
		  into #tempReport
		  FROM [dbo].[ReportInfo] a
		where a.active = 1 and (@report_type = -1 or report_type = @report_type)
			and exists(select 1 from userReport r where r.reportId = a.reportId and r.userId = @UserId)

		if not exists(select 1 from #tempReport)
		insert into #tempReport
		SELECT cast([report_id] as int) as tableKey
			  ,[int_order]
			  ,[report_type]
			  ,[report_group]
			  ,[report_name] = [report_name]
			  ,[api_url_view]
			  ,[groupKey]
			  ,[api_url_dowload]
		  FROM [dbo].[ReportInfo] a
		where a.active = 1 and (@report_type = -1 or report_type = @report_type)

		select * 
		from #tempReport
		order by int_order

		select g.group_key
			  ,g.group_cd
			  ,g.group_column
			  ,g.group_name
			  ,a.report_id as group_table
		from [dbo].[ReportInfo] a
		cross apply DBO.fn_get_field_group_lang(a.[groupKey], @AcceptLanguage) g
		where a.active = 1 and (@report_type = -1 or report_type = @report_type)

		SELECT [id]
			  ,[table_name]
			  ,[field_name]
			  ,[view_type]
			  ,[data_type]
			  ,[ordinal]
			  ,[group_cd]
			  ,[columnLabel]
			  ,[columnTooltip]
			  ,[columnValue] =  CASE when field_name = 'fromDate' then @strDefaultFromDate
								  when field_name = 'toDate' then @strDefaultToDate
								else columnDefault end  
			  ,[columnClass]
			  ,[columnType]
			  ,[columnObject]
			  ,[isVisiable]
			  ,[isSpecial]
			  ,[isRequire]
			  ,[isDisable]
			  ,[isEmpty]
			  ,[columnDisplay]
			  ,[isIgnore]
		  FROM [dbo].[ReportInfo] a
		  CROSS APPLY dbo.fn_config_form_gets(cast(a.report_id as varchar(50)), @AcceptLanguage) p
		  where a.active = 1 
				and (@report_type = -1 or report_type = @report_type)
			order by p.ordinal

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_report_list ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'Scheme', 'GET', @SessionID, @AddlInfo
	end catch