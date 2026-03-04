CREATE PROCEDURE [dbo].[sp_res_apartment_family_member_field_draft]
    @userId UNIQUEIDENTIFIER = NULL,
	@ApartmentId INT = NULL,
    @CustId NVARCHAR(50),
    @acceptLanguage NVARCHAR(50) = N'vi-VN',
    @avatarUrl NVARCHAR(250) = NULL,
    @birthday NVARCHAR(250),
    @cifNo NVARCHAR(250),
    @countryCd NVARCHAR(450) = NULL,
    @email NVARCHAR(450) = NULL,
    @fullName NVARCHAR(450) = NULL,
    @isForeign INT = 0,
	@isNotification  INT = 0,
	@isSex  INT = 0,
	@phone NVARCHAR(450)
    , @relationId INT = 0
    ,@EffectiveDate NVARCHAR(150) = NULL
    ,@note NVARCHAR(max) = NULL
    ,@householdHead NVARCHAR(150) = NULL
    ,@EffectiveDateEnd NVARCHAR(150) = NULL

AS
BEGIN TRY
    --1 thong tin chung
    SELECT convert(nvarchar(50),@ApartmentId) id,[tableKey] = 'MAS_Apartment_Family_Member';
    --2- cac group
    select * from DBO.fn_get_field_group_lang('common_group', @acceptLanguage)
		   order by intOrder
	--
    --3 tung o trong group
    SELECT s.id, [table_name]
			, [field_name]
			, [view_type]
			, [data_type]
			, [ordinal]
			, [columnLabel]
			, [group_cd]
			, CASE [data_type] 
              WHEN 'nvarchar' THEN convert(nvarchar(350), CASE [field_name]			
					WHEN 'avatarUrl'
						THEN @avatarUrl
					WHEN 'cifNo'
						THEN NULL
					WHEN 'countryCd'
						THEN @countryCd
					WHEN 'custId'
						THEN @CustId
					WHEN 'email'
						THEN @email
					WHEN 'fullName'
						THEN @fullName
					WHEN 'phone'
						THEN @phone
					WHEN 'householdHead'
						THEN @householdHead
						END)
				WHEN 'int' THEN convert(nvarchar(350), CASE [field_name] 
					WHEN 'isForeign'
						THEN CASE WHEN ISNULL(@isForeign, 0)  = 1 THEN N'1' ELSE N'0' END
				    WHEN 'ApartmentId' THEN  @ApartmentId
					WHEN 'isNotification'
						THEN CASE WHEN @isNotification = 1 THEN N'1'
								  WHEN @isNotification = 0 THEN  N'0' END
					WHEN 'isSex'
						THEN CASE WHEN @isSex = 1 THEN N'1' 
						          WHEN @isSex = 0 THEN N'0'  END
					WHEN 'relationId'
						THEN CONVERT(NVARCHAR(500), @relationId)
              END)
			  when 'date' then convert(nvarchar(50), case [field_name] 
               WHEN 'birthday'
						THEN CONVERT(NVARCHAR(50),@birthday,103)
					WHEN 'effectiveDate'
					THEN	CONVERT(NVARCHAR(50), @EffectiveDate,103)
              end)
					  when 'uniqueidentifier' then convert(nvarchar(50), case [field_name] 
                  when 'custId' THEN @CustId
              end)

					END  
            as columnValue
			, [columnClass]
			, [columnType]
			, [columnObject]
			, [isSpecial]
			, [isRequire]
			, [isDisable]
			, [isVisiable] = CASE
							WHEN @IsForeign = 1 AND field_name IN('countryCd')
							THEN 1 
							WHEN @IsForeign = 0 AND field_name IN('countryCd')
							THEN 0
							ELSE [s].[isVisiable] END
			, NULL AS [IsEmpty]
			, ISNULL(s.columnTooltip, s.[columnLabel]) AS columnTooltip
           ,s.columnDisplay
           ,s.isIgnore
    FROM fn_config_form_gets('MAS_Apartment_Family_Member', @acceptLanguage) s
    --WHERE s.table_name = 'MAS_Apartment_Family_Member'
	--AND s.isVisiable = 1
    ORDER BY ordinal;
    
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_family_member_field_draft' + ERROR_MESSAGE();
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