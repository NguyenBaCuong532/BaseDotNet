CREATE PROCEDURE [dbo].[sp_res_apartment_fee_field_draft]
    @userId UNIQUEIDENTIFIER = NULL,
    @ApartmentId INT = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN',
    @par_residence_type_oid uniqueidentifier,
    @IsReceived int,
    @ReceiveDate NVARCHAR(450) = NULL,
    @isFeeStart int,
    @IsFree int,
    @FeeStart NVARCHAR(450) = NULL,
    @FreeMonth int = NULL,
    @FreeToDate NVARCHAR(450) = NULL,
    @FeeNote NVARCHAR(450) = NULL,
    @DebitAmt NVARCHAR(450) = NULL,
	@IsRent int
AS
BEGIN TRY
    --1 thong tin chung
    SELECT @ApartmentId id,[tableKey] = 'apartment_fee';
    --2- cac group
    select * from DBO.fn_get_field_group_lang('common_group', @acceptLanguage)
		   order by intOrder
    --3 tung o trong group
    SELECT s.id,
           s.[table_name],
           s.[field_name],
           s.[view_type],
           s.[data_type],
           s.[ordinal],
           s.[columnLabel],
           s.[group_cd]
           ,case [data_type] 
              when 'nvarchar' then convert(nvarchar(350), case [field_name] 
                  when 'FeeNote' THEN @FeeNote  
                  when 'DebitAmt' then @DebitAmt	
              end)
              when 'int' then convert(nvarchar(350), case [field_name] 
                  when 'FreeMonth' then @FreeMonth
                  when 'IsReceived' THEN @IsReceived
                  when 'isFeeStart' then @isFeeStart
                  when 'IsFree' then @IsFree
                  when 'IsRent' then @IsRent
                  WHEN 'ApartmentId' THEN @ApartmentId
              END)
              when 'date' then convert(nvarchar(50), case [field_name] 
                  when 'ReceiveDate' THEN convert(NVARCHAR(10), @ReceiveDate, 103)
                  when 'FeeStart' THEN convert(NVARCHAR(10), @FeeStart, 103)
                  when 'FreeToDate' then convert(NVARCHAR(10), @FreeToDate, 103)
              end)
              when 'uniqueidentifier' then convert(nvarchar(50), case [field_name] 
                  when 'par_residence_type_oid' THEN @par_residence_type_oid
              end)
            --when 'bit' then convert(nvarchar(50), case [field_name] 
            --	  when 'IsReceived' THEN @IsReceived
            --	  --(CAST(CASE WHEN @IsReceived = 1 THEN 'true' ELSE 'false' END  AS VARCHAR(50))) 
            --	  when 'isFeeStart' then @isFeeStart
            --	  --(CAST(CASE WHEN @isFeeStart = 1 THEN 'true' ELSE 'false' END  AS VARCHAR(50)))
            --	  when 'IsFree' then @IsFree
            --	  --(CAST(CASE WHEN @IsFree = 1 THEN 'true' ELSE 'false' END  AS VARCHAR(50)))
            --	  WHEN 'ApartmentId' THEN @ApartmentId
            --	  end) 
            END 
            as columnValue,
               [columnClass],
               [columnType],
               [columnObject],
               [isSpecial],
               [isRequire],
               [isDisable] = CASE
                  -- đối với trường "Phí dịch vụ" và "Miến phí"
                  WHEN @isFeeStart = 0 AND field_name IN('IsFree','FeeStart','FreeMonth','FreeToDate','FeeNote')
                  THEN 1 
                  WHEN @isFeeStart =1 AND  @IsFree = 0 AND field_name IN('FeeStart','FreeMonth','FreeToDate')
                  THEN 1
                  WHEN @isFeeStart = 1 AND  @IsFree = 1 AND field_name IN('FreeToDate')
                  THEN 1
                  WHEN @IsReceived = 0  AND field_name IN('FeeNote','DebitAmt','FreeMonth','isFeeStart','IsFree','IsRent','ApartmentId','ReceiveDate','FeeStart','FreeToDate')
                  THEN 1
                  ELSE [s].[isDisable] END,
               [isVisiable],
               NULL AS [IsEmpty],
               ISNULL(s.columnTooltip, s.[columnLabel]) AS columnTooltip
               ,s.columnDisplay
               ,s.isIgnore
        FROM fn_config_form_gets('apartment_fee', @acceptLanguage) s
      --WHERE s.isVisiable = 1
        ORDER BY ordinal;
    
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_fee_field' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'apartment_fee',
                          'GetInfo',
                          @SessionID,
                          @AddlInfo;
END CATCH;