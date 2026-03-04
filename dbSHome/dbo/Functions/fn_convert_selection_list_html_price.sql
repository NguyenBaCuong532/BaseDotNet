CREATE FUNCTION [dbo].[fn_convert_selection_list_html_price] (
    @title NVARCHAR(250)
    , @sub NVARCHAR(250)
    , @price NVARCHAR(20)
    )
RETURNS NVARCHAR(MAX)

BEGIN
    DECLARE @html_template NVARCHAR(250) = N'<span class="title">{{TITLE}}</span><span class="price">{{PRICE}}</span><br><span class="sub">{{SUB}}</span>'

    SET @html_template = REPLACE(@html_template, '{{TITLE}}', @title)
    SET @html_template = REPLACE(@html_template, '{{SUB}}', @sub)
    SET @html_template = REPLACE(@html_template, '{{PRICE}}', @price)

    RETURN @html_template
END