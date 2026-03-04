CREATE PROCEDURE sp_sys_config_data_get @key NVARCHAR(50)
AS
BEGIN
    SELECT Key1 = key_1
        , Key2 = key_2
        , KeyGroup = key_group
        , ValueType = type_value
        , Value1 = value1
        , value2 = value2
        , Description = par_desc
        , DescriptionEn = par_desc_e
        , Ordinal = intOrder
    FROM sys_config_data
    WHERE key_1 = @key
        AND isUsed = 1
END