-- =============================================
-- Author:      System
-- Create date: 2026-02-06
-- Description: Get service package data with language translation support
-- =============================================
CREATE FUNCTION [dbo].[fn_get_service_package_lang]
(
    @langkey NVARCHAR(10) = 'vi-VN'
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        sp.id,
        package_name = COALESCE(spl.name, sp.name),
        sp.service_id,
        sp.price,
        sp.estimated_time,
        sp.has_extra,
        sp.is_extra,
        sp.ordinal,
        sp.is_active,
        sp.created_dt,
        sp.created_by,
        sp.updated_dt,
        sp.updated_by,
        sp.tenant_oid
    FROM dbo.service_package sp
    LEFT JOIN dbo.service_package_lang spl ON sp.id = spl.id AND spl.langkey = @langkey
);