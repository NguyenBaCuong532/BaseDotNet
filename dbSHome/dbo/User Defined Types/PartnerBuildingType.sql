CREATE TYPE [dbo].[PartnerBuildingType] AS TABLE (
    [building_id]         INT             NOT NULL,
    [contract_start_date] DATE            NULL,
    [contract_end_date]   DATE            NULL,
    [monthly_cost]        DECIMAL (18, 2) NULL,
    [service_scope]       NVARCHAR (500)  NULL);

