-- =============================================
-- Author:		vutc
-- Create date: 10/29/2025
-- Description:	danh sách báo cáo
-- =============================================
CREATE PROCEDURE [dbo].[sp_bzz_report_list]
    -- Add the parameters for the stored procedure here
     @userId NVARCHAR(450) = NULL
	,@acceptLanguage NVARCHAR(50) = 'vi-VN'
	,@report_type INT = 2
AS
BEGIN TRY

    declare @FromDayOfLastMonth nvarchar(2), @PayrollPeriod nvarchar(2)
    --select
    --    @FromDayOfLastMonth = CAST(FromDayOfLastMonth as nvarchar(2))
    --    --, @PayrollPeriod = CAST(PayrollPeriod as nvarchar(2))  -- thuclh comment k lấy mặc định @PayrollPeriod
    --from OrganizationEx
	SET @PayrollPeriod = 0 -- lấy ngày đầu tháng hiện tại
	SET @FromDayOfLastMonth = 1

    --IF (@report_type = 4 OR @report_type = 2) -- Y tế
	 --BEGIN
		-- SET @PayrollPeriod = 0 -- lấy ngày đầu tháng hiện tại
		-- SET @FromDayOfLastMonth = 1
	 --END
   -- IF (@report_type = 1 OR @report_type = 3) -- TH đặc biệt: BC Chấm công và lương tính từ nửa tháng trước đến đầu tháng sau. VD: tháng 3 tính từ 16/02/2024 đến 15/03/2024
   --     BEGIN
			--SELECT
			--	@FromDayOfLastMonth = CAST(FromDayOfLastMonth as nvarchar(2))
			--	, @PayrollPeriod = CAST(PayrollPeriod as nvarchar(2))
			--FROM OrganizationEx
   --     END

    DECLARE @defaultFromDate DATETIME, @defaultToDate DATETIME, @defaultMonth NVARCHAR(2), @defaultYear NVARCHAR(4), @defaultDate DATETIME, @defaultQuarter NVARCHAR(2),@defaultMonthYear NVARCHAR(7)

    -- first day of current month
    SET @defaultFromDate = DATEADD(DAY, 1, EOMONTH(GETDATE(), -1))
    -- end of current month with time 23:59:59
    SET @defaultToDate = DATEADD(DAY, +1, EOMONTH(GETDATE()))
    SET @defaultToDate = DATEADD(SECOND, -1, @defaultToDate)

    SET @defaultMonth = CAST(MONTH(GETDATE()) AS NVARCHAR(2))
    SET @defaultYear = CAST(YEAR(GETDATE()) AS NVARCHAR(4))
    SET @defaultMonthYear = CAST(MONTH(GETDATE()) AS NVARCHAR(2)) + '/' + CAST(YEAR(GETDATE()) AS NVARCHAR(4))

    -- current date with time is 23:59:59
    DECLARE @currentDate DATE = GETDATE()
    SET @currentDate = DATEADD(DAY, 1, @currentDate)
    SET @defaultDate = DATEADD(SECOND, -1, CONVERT(DATETIME, @currentDate))

    SET @defaultQuarter = CASE WHEN MONTH(GETDATE()) BETWEEN 1 AND 3
                                   THEN '1'
                               WHEN MONTH(GETDATE()) BETWEEN 4 AND 6
                                   THEN '2'
                               WHEN MONTH(GETDATE()) BETWEEN 7 AND 9
                                   THEN '3'
                               ELSE '4' END

    IF (ISNULL(@PayrollPeriod, 0) = 1) AND (ISNULL(@FromDayOfLastMonth, '') != '')
        BEGIN
            DECLARE @dayOfLastMonth DATETIME = DATEADD(DAY, CONVERT(INT, @FromDayOfLastMonth),
                                                       EOMONTH(DATEADD(MONTH, -1, GETDATE())))
            DECLARE @dayOfThisMonth DATETIME = DATEADD(DAY, CONVERT(INT, @FromDayOfLastMonth), EOMONTH(GETDATE()))
            SET @dayOfThisMonth = DATEADD(SECOND, -1, @dayOfThisMonth)

            SET @defaultFromDate = @dayOfLastMonth
 			--set @defaultFromDate = '20240101'
            SET @defaultToDate = @dayOfThisMonth
        END
		DECLARE @dayOfLastMonth2 DATETIME = DATEADD(DAY, CONVERT(INT, @FromDayOfLastMonth),									--Lấy theo cấu hình
                                                       EOMONTH(DATEADD(MONTH, -1, GETDATE())))								--Lấy theo cấu hình
            DECLARE @dayOfThisMonth2 DATETIME = DATEADD(DAY, CONVERT(INT, @FromDayOfLastMonth), EOMONTH(GETDATE()))			--Lấy theo cấu hình
            SET @dayOfThisMonth2 = DATEADD(SECOND, -1, @dayOfThisMonth2)													--Lấy theo cấu hình
        
    DECLARE @strDefaultFromDate NVARCHAR(50), @strDefaultToDate NVARCHAR(50), @strDefaultDate NVARCHAR(50)
    SET @strDefaultFromDate = FORMAT(@defaultFromDate, 'dd/MM/yyyy')
    SET @strDefaultToDate = FORMAT(@defaultToDate, 'dd/MM/yyyy')
    SET @strDefaultDate = FORMAT(@defaultDate, 'dd/MM/yyyy')

    DECLARE @ParameterDefaultOfTableFilter NVARCHAR(50)
    DECLARE @DefaultTableFilter NVARCHAR(50) = '24'
    SELECT
        @ParameterDefaultOfTableFilter = columnDefault
    FROM sys_config_form
    WHERE table_name = @DefaultTableFilter
      AND field_name = 'Parameter'
    SET @ParameterDefaultOfTableFilter = ISNULL(@ParameterDefaultOfTableFilter, 'FDTD')

	drop table if exists #tempReport
	--create role report
	 SELECT [report_id] AS tableKey
		   ,[int_order]
		   ,[report_type]
		   ,[report_group]
		   ,[report_name]	=  a.report_name
		   ,api_url_view	= iif(@report_type = 7, a.api_url_view, NULL) 
		   ,[groupKey]
		   ,[api_url_dowload]
		   ,report_id
		   ,active
		   ,ParameterDefault
    into #tempReport
	from [dbo].[ReportInfo] a
	/*	left join [sys_config_message] m on a.report_id = m.code and m.mod_cd = 'ReportInfo'
		left join [sys_config_message_lang] l on m.id = l.id and l.langkey = @acceptLanguage	*/
    where a.active = 1
		and (@report_type = -1 or report_type = @report_type)	  
	/*	and exists(select 1 from userReport r where r.reportId = a.Oid and r.userId = @userId)	*/

	if not exists(select 1 from #tempReport)
		insert into #tempReport
		 SELECT [report_id] AS tableKey
			   ,[int_order]
			   ,[report_type]
			   ,[report_group]
			   ,[report_name]	=  a.report_name
			   ,api_url_view	= iif(@report_type = 7, a.api_url_view, NULL) 
			   ,[groupKey]
			   ,[api_url_dowload]
			   ,report_id
			   ,active
		       ,ParameterDefault
		  FROM [dbo].[ReportInfo] a
	/*	  left join [sys_config_message] m on a.report_id = m.code and m.mod_cd = 'ReportInfo'
		  left join [sys_config_message_lang] l on m.id = l.id and l.langkey = @acceptLanguage	*/
		where a.active = 1 and (@report_type = -1 or report_type = @report_type)

	select * 
		from #tempReport
		order by int_order

    select g.group_key
        , g.group_cd
        , g.group_column
        , g.group_name
        , a.report_id as group_table
    from #tempReport a
             cross apply DBO.fn_get_field_group(a.[groupKey]) g	/*	*/
    where a.active = 1
      and (@report_type = -1 or a.report_type = @report_type)
    order by a.report_name

    select
        p.[id]
        , [table_name]
        , [field_name]
        , [view_type]
        , [data_type]
        , [ordinal]
        , [group_cd]
        , [columnLabel]  --	= isnull(l.[columnLabel],p.[columnLabel])
        , [columnTooltip]
        , columnValue    =
            case ParameterDefault
                when 'BYDATE'
                    then case field_name
							when 'date'
								then @strDefaultDate
							when 'Parameter'
								then 'BYDATE'
							else p.columnDefault
							end
                when 'MONTH'
                    then case field_name
                    when 'MONTH'
                        then @defaultMonth
                    when 'YEAR'
                        then @defaultYear
                    when 'Parameter'
                        then 'MONTH'
                    else p.columnDefault
                    end
                when 'YEAR'
                    then case field_name
                    when 'year'
                        then @defaultYear
                    when 'Parameter'
                        then 'YEAR'
                    else p.columnDefault end
                when 'FDTD'
                    then
                    case field_name
                        when 'fromDate' -- first day of current month
                            THEN CASE WHEN EXISTS(SELECT 1 FROM dbo.sys_config_form a1 WHERE a1.table_name = p.table_name AND a1.field_name = 'FromDayOfLastMonth' AND  a1.columnDefault  = '1' ) THEN FORMAT(@dayOfLastMonth2,'dd/MM/yyyy') ELSE  @strDefaultFromDate END
                        when 'toDate' -- last day of current month
                            THEN CASE WHEN EXISTS(SELECT 1 FROM dbo.sys_config_form a1 WHERE a1.table_name = p.table_name AND a1.field_name = 'FromDayOfLastMonth' AND a1.columnDefault  = '1' ) THEN FORMAT(@dayOfThisMonth2,'dd/MM/yyyy') ELSE  @strDefaultToDate END 
                        when 'Parameter'
                            then 'FDTD'
                        else p.columnDefault
                        END
				WHEN 'QUARTER'
                    then case field_name
                    when 'Quarter'
                        then @defaultQuarter
                    when 'year'
                        then @defaultYear
                    when 'Parameter'
                        then 'QUARTER'
                    else p.columnDefault end
                else
                    case when field_name = 'fromDate' and (((isnull(p.columnDefault, '') = '') and p.table_name not IN ('24')) or @report_type = 3) then @strDefaultFromDate
                         when field_name = 'toDate' and (((isnull(p.columnDefault, '') = '') and p.table_name not IN ('24')) OR @report_type = 3) then @strDefaultToDate
                         when field_name = 'month' and (((isnull(p.columnDefault, '') = '') and p.table_name not in ('24')) or @report_type = 3) AND @report_type <> 4 then @defaultMonth
                         when field_name = 'year' and (((isnull(p.columnDefault, '') = '') and p.table_name not in ('24')) or @report_type = 3) AND @report_type <> 4 then @defaultYear
                         when field_name = 'MonthYear' and @report_type = 3 then @defaultMonthYear
                        --WHEN field_name = 'FromDayOfLastMonth' THEN @FromDayOfLastMonth
                        --WHEN field_name = 'PayrollPeriod' THEN @PayrollPeriod
                         else p.columnDefault end
                end
        , [columnClass]
        , [columnType]
        , [columnObject] = REPLACE([columnObject], '$*#_YearFilterValue_#*$', @defaultYear)
        , [isVisiable]   = case ParameterDefault
            when 'BYDATE'
                then case when field_name = 'date'
                              then 1
                          else case when field_name in ('fromDate', 'toDate', 'Month', 'Year', 'Quarter')
                                        then 0
                                    else isVisiable
                              end
                end
            when 'FDTD'
                then case when field_name in ('fromDate', 'toDate')
                              then 1
                          else case when field_name in ('date', 'Month', 'Year', 'Quarter')
                                        then 0
                                    else isVisiable
                              end
                end
            when 'MONTH'
                then case when field_name in ('Month', 'Year')
                              then 1
                          else case when field_name in ('date', 'fromDate', 'toDate', 'Quarter')
                                        then 0
                                    else isVisiable
                              end
                end
            when 'YEAR'
                then case when field_name = 'Year'
                              then 1
                          else case when field_name in ('fromDate', 'toDate', 'Month', 'date', 'Quarter')
                                        then 0
                                    else isVisiable
                              end
                end
            when 'QUARTER'
                then case when field_name in ('Year', 'Quarter')
                              then 1
                          else case when field_name in ('fromDate', 'toDate', 'Month', 'date')
                                        then 0
                                    else isVisiable
                              end
                end
            else case when field_name = 'Oids'
                          then 0
                      else
                          [isVisiable] end
            end
        , [isSpecial]
        , isRequire      = case field_name when 'Oids' then 1 else [isRequire] end
        , [isDisable]
        , [isEmpty]
        , [columnDisplay]
        , [isIgnore]
    --FROM dbo.[fn_config_from_gets]('bzz_attendancerecord_filter',@acceptLanguage) p
    from sys_config_form p
	/*	left join [sys_config_form_lang] l  on p.id = l.id and l.langkey = @acceptLanguage		*/
             cross apply(select
                             a.report_id
                             , a.ParameterDefault
                         from #tempReport a
                         where a.active = 1
                           and cast(a.report_id as varchar(50)) = p.table_name
                           and (@report_type = -1 or report_type = @report_type)) t

    --union
    ---- nếu k đc cấu hình ở bảng sys_config_form thfi mặc định sẽ dùng form chung có table_name = 24
    --select
    --                      [id]
    --    ,                 r.[report_id] table_name
    --    ,                 [field_name]
    --    ,                 [view_type]
    --    ,                 [data_type]
    --    ,                 [ordinal]
    --    ,                 [group_cd]
    --    ,				  [columnLabel] 
    --    ,                 [columnTooltip]
    --    , columnValue   = case
    --                          when field_name = 'FromDayOfLastMonth'
    --                              then s.columnDefault
    --                          --when field_name = 'PayrollPeriod'
    --                          --    then @PayrollPeriod
    --                          when field_name = 'Parameter'
    --                              then case ParameterDefault
    --                              when 'BYDATE'
    --                                  then 'BYDATE'
    --                              when 'FDTD'
    --                                  then 'FDTD'
    --                              when 'MONTH'
    --                                  then 'MONTH'
    --                              when 'YEAR'
    --                                  then 'YEAR'
    --                              when 'QUARTER'
    --                                  then 'QUARTER'
    --                              else 'FDTD' end
    --                          when field_name = 'fromDate' and
    --                               (ParameterDefault = 'FDTD' )
    --                              then @strDefaultFromDate
    --                          when field_name = 'toDate' and
    --                               (ParameterDefault = 'FDTD' )
    --                              then @strDefaultToDate
    --                          when field_name = 'date' and
    --                               (ParameterDefault = 'BYDATE' )
    --                              then @strDefaultDate
    --                          when field_name = 'Month' and
    --                               (ParameterDefault = 'MONTH')
    --                              then @defaultMonth
    --                          when field_name = 'Year' and
    --                               (ParameterDefault in ('YEAR', 'MONTH', 'QUARTER') or
    --                                @ParameterDefaultOfTableFilter in ('YEAR', 'MONTH', 'QUARTER'))
    --                              then @defaultYear
    --                          when field_name = 'Quarter' and
    --                               (ParameterDefault = 'QUARTER' or @ParameterDefaultOfTableFilter = 'QUARTER')
    --                              then @defaultQuarter
    --                          when field_name = 'PayrollPeriod' and report_type = 4 then '0'
    --                          else s.columnDefault end
    --    ,                 [columnClass]
    --    ,                 [columnType]
    --    ,                 [columnObject]
    --    , [isVisiable]  = case ParameterDefault
    --                          when 'BYDATE'
    --                              then case when field_name = 'date'
    --                                            then 1
    --                                        else case when field_name in ('fromDate', 'toDate', 'Month', 'Year', 'Quarter')
    --                                                      then 0
    --                                                  else isVisiable
    --                                            end
    --                              end
    --                          when 'FDTD'
    --                              then case when field_name in ('fromDate', 'toDate')
    --                                            then 1
    --                                        else case when field_name in ('date', 'Month', 'Year', 'Quarter')
    --                                                      then 0
    --                                                  else isVisiable
    --                                            end
    --                              end
    --                          when 'MONTH'
    --                              then case when field_name in ('Month', 'Year')
    --                                            then 1
    --                                        else case when field_name in ('date', 'fromDate', 'toDate', 'Quarter')
    --                                                      then 0
    --                                                  else isVisiable
    --                                            end
    --                              end
    --                          when 'YEAR'
    --                              then case when field_name = 'Year'
    --                                            then 1
    --                                        else case when field_name in ('fromDate', 'toDate', 'Month', 'date', 'Quarter')
    --                                                      then 0
    --                                                  else isVisiable
    --                                            end
    --                              end
    --                          when 'QUARTER'
    --                              then case when field_name in ('Year', 'Quarter')
    --                                            then 1
    --                                        else case when field_name in ('fromDate', 'toDate', 'Month', 'date')
    --                                                      then 0
    --                                                  else isVisiable
    --                                            end
    --                              end
    --                          else case when field_name = 'Oids'
    --                                        then 0
    --                                    else
    --                                        [isVisiable] end
    --                          end
    --    ,                 [isSpecial]
    --    , isRequire     = case field_name when 'Oids' then 1 else [isRequire] end
    --    ,                 [isDisable]
    --    ,                 [isEmpty]
    --    ,                 [columnDisplay]
    --    ,                 [isIgnore]
    --from #tempReport r
/*             cross apply
    (select *
     from dbo.[fn_config_from_gets]('24',@acceptLanguage)
	 
     where table_name = @DefaultTableFilter
        --AND (isVisiable = 1 OR isRequire = 1)
    ) SELECT TOP 3* FROM */
    --where not exists (select top 1
    --                      1
    --                  from sys_config_form s1
    --                  where CAST(r.report_id as nvarchar(50)) = s1.table_name
    --    --AND s1.table_name != 'exportType'
    --)
    --  and r.active = 1
    --  and (@report_type = -1 or report_type = @report_type)
    --order by [ordinal]

end try
begin catch
    declare @ErrorNum int,
        @ErrorMsg varchar(200),
        @ErrorProc varchar(50),

        @SessionID int,
        @AddlInfo varchar(max)

    set @ErrorNum = error_number()
    set @ErrorMsg = 'sp_bzz_report_list ' + error_message()
    set @ErrorProc = error_procedure()

    set @AddlInfo = ' '

    exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'Scheme', 'GET', @SessionID, @AddlInfo
end catch