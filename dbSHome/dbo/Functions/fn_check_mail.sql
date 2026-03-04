create FUNCTION [dbo].[fn_check_mail]
(
	@mail nvarchar(500)
)
RETURNS int
BEGIN
	declare @bitEmailVal int 
	SET @bitEmailVal = case when @mail = '' or @mail is null then 0
                          when @mail like '% %' then 0
                          when @mail like ('%["(),:;<>\]%') then 0
                          when substring(@mail,charindex('@',@mail),len(@mail)) like ('%[!#$%&*+/=?^`_{|]%') then 0
                          when (left(@mail,1) like ('[-_.+]') or right(@mail,1) like ('[-_.+]')) then 0                                                                                    
                          when (@mail like '%[%' or @mail like '%]%') then 0
                          when @mail LIKE '%@%@%' then 0
                          when @mail NOT LIKE '_%@_%._%' then 0
                          else 1 
                      end
  RETURN @bitEmailVal
END