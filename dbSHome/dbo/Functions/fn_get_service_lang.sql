-- =============================================
-- Author:      System
-- Create date: 2026-02-06
-- Description: Get service data with language translation support
-- =============================================
CREATE FUNCTION [dbo].[fn_get_service_lang]
(
    @langkey NVARCHAR(10) = 'vi-VN'
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        s.id,
        service_name = COALESCE(sl.name, s.name),
        service_description = COALESCE(sl.description, s.description),
        s.icon_url,
        s.ordinal,
        s.is_active,
        s.has_extra,
        s.service_type_id,
        s.created_dt,
        s.created_by,
        s.updated_dt,
        s.updated_by,
        s.tenant_oid
    FROM dbo.service s
    LEFT JOIN dbo.service_lang sl ON s.id = sl.id AND sl.langkey = @langkey
);