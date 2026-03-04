CREATE TABLE [dbo].[MAS_CardPartnerBuilding] (
    [partner_building_id] INT              IDENTITY (1, 1) NOT NULL,
    [partner_id]          INT              NOT NULL,
    [building_id]         INT              NOT NULL,
    [contract_start_date] DATE             NULL,
    [contract_end_date]   DATE             NULL,
    [monthly_cost]        DECIMAL (18, 2)  NULL,
    [service_scope]       NVARCHAR (500)   NULL,
    [create_dt]           DATETIME         NULL,
    [create_by]           UNIQUEIDENTIFIER NULL,
    [tenant_oid]          UNIQUEIDENTIFIER NULL,
    PRIMARY KEY CLUSTERED ([partner_building_id] ASC),
    CONSTRAINT [FK_MAS_CardPartnerBuilding_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);


GO
CREATE NONCLUSTERED INDEX [IX_MAS_CardPartnerBuilding_partner]
    ON [dbo].[MAS_CardPartnerBuilding]([partner_id] ASC);

