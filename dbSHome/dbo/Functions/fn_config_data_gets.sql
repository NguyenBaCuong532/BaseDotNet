





CREATE FUNCTION [dbo].[fn_config_data_gets]
(
	@fieldObject nvarchar(50)
	--@acceptLanguage nvarchar(50) = 'en'
)
RETURNS @tbl TABLE
(
	 [objKey] nvarchar(50)
	,[objCode] nvarchar(50)
	,[objName] nvarchar(200)
	,[objGroup] nvarchar(50)
	,[objValue] nvarchar(100)
	,[objValue1] nvarchar(100)
	,[objValue2] int	
	,[intOrder] int	
	,[objClass] nvarchar(200)
)
AS
BEGIN
--
	Insert into @tbl 
		SELECT [key_1]
			  ,[key_2]
			  ,[par_desc] = cc.par_desc--CASE WHEN @acceptLanguage = 'en' THEN isnull(par_desc_e,l.par_desc) ELSE isnull(l.par_desc,cc.par_desc) END
			  ,[key_group]
			  ,case when [type_value] = 1 then cast([value2] as nvarchar(100)) else [value1] end objvalue
			  ,[value1]
			  ,[value2]
			  ,intOrder
			  ,[objClass] = N'<span class="' + [value1] + ' noti-number ml5">' + cc.par_desc + '</span>'
	  FROM sys_config_data cc
		--left join sys_config_data_lang l on cc.id = l.id and l.langkey = @acceptLanguage 
	where [key_1] = @FieldObject and [IsUsed] = 1	
	return 
END