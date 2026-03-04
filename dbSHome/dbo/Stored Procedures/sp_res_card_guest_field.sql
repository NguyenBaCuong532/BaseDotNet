CREATE   PROCEDURE [dbo].[sp_res_card_guest_field]
    @UserId UNIQUEIDENTIFIER ,
    @cardid VARCHAR(50) = NULL,
    @partner_id nvarchar(50) = null,
    @AcceptLanguage nvarchar(50) = null,
    @cardType nvarchar(50) = null,
    @cardCode nvarchar(50) = null,
    @project_code nvarchar(50) = null
AS
BEGIN TRY
    DECLARE @group_key VARCHAR(50) = 'common_group'
    DECLARE @table_key VARCHAR(50) = 'MAS_Guest_Cards'
    --1 thong tin chung
    SELECT @cardid [key]
         ,[tableKey] = @table_key
         ,[groupKey] = @group_key

    --2- cac group
    SELECT *
    FROM DBO.fn_get_field_group_lang(@group_key, @AcceptLanguage) g
    order by g.intOrder
		---
--     drop table if exists #tempIn
-- 	
--     select cast(cardId as int) as cardId,CardCd,custId,ProjectCd,issueDate,expireDate,partner_id,CardTypeId,card_st
--     into #tempIn
--     from MAS_cards b
--     WHERE (b.CardCd = @cardid)
--     
--     if not exists(select 1 from #tempIn)
--     insert into #tempIn (cardId,CardCd,custId,ProjectCd,issueDate,expireDate,partner_id)
--     select @cardid,'','','',getdate(),null,@partner_id

    --field
    SELECT a.id
      ,a.[table_name]
      ,a.[field_name]
      ,a.[view_type]
      ,a.[data_type]
      ,a.[ordinal]
      ,a.[columnLabel]
      ,a.group_cd
      ,case [data_type] 
          when 'nvarchar' then convert(nvarchar(max), case [field_name] 
              when 'cardCd' then b.CardCd
              when 'custId' then b.custId
              when 'projectCd' then IIF(b.ProjectCd IS NULL OR TRIM(b.ProjectCd) = '', @project_code, b.ProjectCd)
              when 'custName' then c.FullName 
              when 'custPhone' then c.Phone
              when 'partner_name' then p.partner_name
          end)
          when 'datetime' then case [field_name] 
              when 'issueDate' then format(ISNULL(b.issueDate, GETDATE()),'dd/MM/yyyy')
              when 'expireDate' then  format(b.[expireDate],'dd/MM/yyyy')
          END
          WHEN 'int' THEN CONVERT(NVARCHAR(50), CASE [field_name] 
              WHEN 'partner_id' THEN (CAST(ISNULL(b.partner_id,0) AS VARCHAR(50))) 
              WHEN 'CardTypeId' THEN b.CardTypeId
          END)
          ELSE columnDefault
      END AS columnValue
      ,[columnClass]
      ,[columnType]
      ,[columnObject] = case
                            when field_name in ('partner_id') then replace([columnObject],'projectCd=','projectCd='+b.ProjectCd)
                            when field_name in ('cardCd') then CONCAT([columnObject], '?projectCd=', b.ProjectCd, '&filter=', b.CardCd)
                            else [columnObject]
                        end
      ,[isSpecial]
      ,[isRequire] 
      ,[isDisable]
      ,[IsVisiable]
      ,a.[IsEmpty]
      ,isnull(a.columnTooltip,a.[columnLabel]) as columnTooltip
      ,a.columnDisplay
      ,a.isIgnore
    FROM
        fn_config_form_gets(@table_key, @AcceptLanguage) a
        OUTER APPLY(select * from MAS_cards b WHERE b.CardCd = @cardCode) b
        left join MAS_Customers c on b.CustId = c.CustId 
        LEFT JOIN dbo.MAS_CardPartner p ON p.partner_id = b.partner_id
    --WHERE (isvisiable = 1 or isRequire = 1)
    order by a.ordinal
	

END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_card_guest_field' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'MAS_Cards'
        , 'GetInfo'
        , @SessionID
        , @AddlInfo;
END CATCH;