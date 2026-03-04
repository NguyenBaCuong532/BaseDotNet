CREATE PROCEDURE [dbo].[sp_res_card_vehicle_field_draft] 
     @acceptLanguage NVARCHAR(50) = N'vi-VN',
	 @userId UNIQUEIDENTIFIER,
     @CardVehicleId    int = null,                  
     @AssignDate        nvarchar(50) = null,                 
     @VehicleNo        nvarchar(50) = null,        
     @VehicleTypeID    int = null,                
     @VehicleTypeName  nvarchar(50) = null,              
     @VehicleName      nvarchar(50) = null,        
     @StartTime         nvarchar(50) = null,     
     @EndTime           nvarchar(50) = null, 
     @ServiceId        int = null,   
     @ServiceName      nvarchar(50) = null,    
     @Status           int = null,
     @VehicleStatusName nvarchar(50) = null,          
     @CardCd           nvarchar(50) = null,
     @AuthName         nvarchar(50) = null,
     @AuthDate          nvarchar(50) = null, 	
     @VehicleColor     nvarchar(50) = null,
	 @VehicleCardStatusName nvarchar(50) = null
	 ,@RadioButton bit
	 ,@RadioButton1 bit
	 ,@DueDate  nvarchar(50) 

AS
BEGIN
BEGIN TRY
	
	IF @RadioButton = 1 SET @DueDate = null
	IF (@RadioButton = 1 and @RadioButton1 = 1) Set @RadioButton = 0
	IF (@RadioButton = 0 and @RadioButton1 = 0) Set @RadioButton = 1
	

	-- 1: header info
    SELECT 
        ISNULL( @CardVehicleId, '') AS CardVehicleId,
        'apartment_vehicle_card' AS tableKey;

    -- 2: groups
    SELECT * 
    FROM dbo.fn_get_field_group_lang('common_group', @acceptLanguage)
    ORDER BY intOrder;

    -- 3: fields
    SELECT 
        s.id,
        s.[table_name],
        s.[field_name],
        s.[view_type],
        s.[data_type],
        s.[ordinal],
        s.[columnLabel],
        s.[group_cd],

        CASE s.[data_type]
            WHEN 'nvarchar' THEN
                CONVERT(nvarchar(350),
                    CASE s.[field_name]
                        WHEN 'VehicleNo' THEN ISNULL(@VehicleNo, '')
                        WHEN 'VehicleTypeName' THEN ISNULL(@VehicleTypeName, '')
                        WHEN 'VehicleName' THEN ISNULL(@VehicleName, '')
                        WHEN 'ServiceName' THEN ISNULL(@ServiceName, '')
                        WHEN 'VehicleStatusName' THEN ISNULL(@VehicleStatusName, '')
                        WHEN 'CardCd' THEN ISNULL(@CardCd, '')
                        WHEN 'AuthName' THEN ISNULL(@AuthName, '')
                        WHEN 'VehicleColor' THEN ISNULL(@VehicleColor, '')
                        ELSE ISNULL(s.columnDefault, '')
                    END)
            WHEN 'int' THEN
                CONVERT(nvarchar(50),
                    CASE s.[field_name]
                        WHEN 'CardVehicleId' THEN ISNULL(CONVERT(nvarchar(50), @CardVehicleId), '')
                        WHEN 'VehicleTypeID' THEN ISNULL(CONVERT(nvarchar(50), @VehicleTypeID), '')
                        WHEN 'ServiceId' THEN ISNULL(CONVERT(nvarchar(50), @ServiceId), '')
                        WHEN 'Status' THEN ISNULL(CONVERT(nvarchar(50), @Status), '')
                        ELSE ISNULL(s.columnDefault, '')
                    END)
            WHEN 'date' THEN
                -- trả về dạng dd/MM/yyyy nếu có giá trị, ngược lại trả rỗng
                CASE s.[field_name]
                    WHEN 'AssignDate' THEN COALESCE(CONVERT(nvarchar(10), @AssignDate, 103), '')
                    WHEN 'StartTime'  THEN COALESCE(CONVERT(nvarchar(10), @StartTime, 103), '')
                    WHEN 'EndTime'    THEN COALESCE(CONVERT(nvarchar(10), @EndTime, 103), '')
                    WHEN 'AuthDate'   THEN COALESCE(CONVERT(nvarchar(10), @AuthDate, 103), '')
                    ELSE COALESCE(s.columnDefault, '')
                END
			WHEN 'bit' THEN 
				CASE s.field_name
					WHEN 'RadioButton' THEN  IIF(@RadioButton = 1, 'true', 'false')
											--IIF(@RadioButton1 IS NULL OR LTRIM(RTRIM(@RadioButton1)) = '', 'false' , 'true')				
					WHEN 'RadioButton1' THEN  IIF(@RadioButton1 = 1, 'true', 'false')
											--IIF(@RadioButton IS NULL OR LTRIM(RTRIM(@RadioButton)) = '','false' , 'true')
					ELSE  ISNULL(s.columnDefault, 'false')
				END
			WHEN 'datetime' THEN
                -- trả về dạng dd/MM/yyyy nếu có giá trị, ngược lại trả rỗng
                CASE s.[field_name]
					WHEN 'DueDate' THEN IIF(@RadioButton IS NULL OR LTRIM(RTRIM(@RadioButton)) = '',null , @DueDate)
				END
        END AS columnValue,

        s.[columnClass],
        s.[columnType],
        s.[columnObject],
        s.[isSpecial],
        s.[isRequire],
        CASE s.field_name
			WHEN 'DueDate' THEN
				CASE 
					WHEN @RadioButton1 = 0
						THEN 'true'
					ELSE 'false'
				END
			ELSE s.isDisable
		END as isDisable
		,
		 CASE s.field_name
			WHEN 'RadioButton' THEN
				CASE 
					WHEN @RadioButton1 = 1
						THEN 'false'
					ELSE 'true'
				END
			ELSE isVisiable
		END as isVisiable
        ,
        s.[IsEmpty],
        ISNULL(s.columnTooltip, s.[columnLabel]) AS columnTooltip
        , s.columnDisplay
        , s.isIgnore
    FROM fn_config_form_gets('apartment_vehicle_card', @acceptLanguage) s
    ORDER BY s.ordinal;
END TRY
BEGIN CATCH
    DECLARE 
        @ErrorNum INT = ERROR_NUMBER(),
        @ErrorMsg VARCHAR(200) = 'sp_res_card_vehicle_field_draft ' + ERROR_MESSAGE(),
        @ErrorProc VARCHAR(50) = ERROR_PROCEDURE(),
        @SessionID INT = NULL,
        @AddlInfo VARCHAR(MAX) = ' ';

    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'apartment_vehicle_card', 'GetInfo', @SessionID, @AddlInfo;
END CATCH;
END;