
CREATE PROCEDURE [dbo].[sp_res_card_guest_draft]
	  @UserId UNIQUEIDENTIFIER
    , @CardId NVARCHAR(50)
	, @CustId NVARCHAR(50)
    , @CustPhone NVARCHAR(20)
    , @CustName NVARCHAR(100)
    , @CardCd NVARCHAR(50)
    , @IssueDate NVARCHAR(20)
    , @ExpireDate NVARCHAR(20)
    , @ProjectCd NVARCHAR(30)
    , @partner_id INT = 0
    , @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    DECLARE @group_key VARCHAR(50) = 'common_group'
    DECLARE @table_key VARCHAR(50) = 'MAS_Guest_Cards'
    --1 thong tin chung
    SELECT @CardId as id
         ,[tableKey] = @table_key
         ,[groupKey] = @group_key

    --2- cac group
    SELECT *
    FROM DBO.fn_get_field_group_lang(@group_key, @acceptLanguage) g
	order by g.intOrder
		---
	drop table if exists #tempIn
	
	select b.*
	into #tempIn
	from MAS_cards b
	WHERE 0=1--(b.CardCd = @cardCode)
	
	if not exists(select 1 from #tempIn)
	insert into #tempIn (cardId,CardCd,custId,ProjectCd,issueDate,expireDate,partner_id)
	select 0,@CardCd,@custId,@ProjectCd,getdate(),null,@partner_id

	--field
	SELECT [id]
		,[table_name]
		,[field_name]
		,[view_type]
		,[data_type]
		,[ordinal]
		,[columnLabel]
		,group_cd
		,case [data_type] 
			when 'nvarchar' then convert(nvarchar(max), case [field_name] 
				when 'cardCd' then b.CardCd
				when 'custId' then b.custId
				when 'projectCd' then b.ProjectCd						
				when 'custName' then c.FullName 
				when 'custPhone' then c.Phone
				when 'partner_name' then p.partner_name
				end) 				
			when 'datetime' then case [field_name] 
				when 'issueDate' then @IssueDate--format(b.issueDate,'dd/MM/yyyy')
				when 'expireDate' then @ExpireDate-- format(b.[expireDate],'dd/MM/yyyy')
				END
			WHEN 'int' THEN CONVERT(NVARCHAR(50), CASE [field_name] 
				WHEN 'partner_id' THEN (CAST(ISNULL(b.partner_id,0) AS VARCHAR(50))) 
				--WHEN 'cardtypeId' THEN @cardType
			END)
			else 
			columnDefault END AS columnValue
		,[columnClass]
		,[columnType]
		,[columnObject] = case when field_name in ('partner_id','cardCd') then replace([columnObject],'projectCd=','projectCd='+b.ProjectCd)
							else [columnObject] end
		,[isSpecial]
		,[isRequire] 
		,[isDisable]
		,[IsVisiable]
		,[IsEmpty]
		,isnull(a.columnTooltip,a.[columnLabel]) as columnTooltip
		,columnDisplay
		,isIgnore
	FROM fn_config_form_gets(@table_key, @acceptLanguage) a
	,#tempIn b
	left join MAS_Customers c on b.CustId = c.CustId 
	LEFT JOIN dbo.MAS_CardPartner p ON p.partner_id = b.partner_id
	--WHERE (isvisiable = 1 or isRequire = 1)
	--and b.cardCd = @cardCode
	order by ordinal
	

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