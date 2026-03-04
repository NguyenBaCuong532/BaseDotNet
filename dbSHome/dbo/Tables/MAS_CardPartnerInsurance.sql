CREATE TABLE [dbo].[MAS_CardPartnerInsurance] (
    [insurance_id]   INT              IDENTITY (1, 1) NOT NULL,
    [partner_id]     INT              NOT NULL,
    [provider_name]  NVARCHAR (200)   NULL,
    [policy_number]  NVARCHAR (100)   NULL,
    [start_date]     DATE             NULL,
    [end_date]       DATE             NULL,
    [coverage_scope] NVARCHAR (500)   NULL,
    [create_dt]      DATETIME         NULL,
    [create_by]      UNIQUEIDENTIFIER NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    PRIMARY KEY CLUSTERED ([insurance_id] ASC),
    CONSTRAINT [FK_MAS_CardPartnerInsurance_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);


GO
CREATE NONCLUSTERED INDEX [IX_MAS_CardPartnerInsurance_partner]
    ON [dbo].[MAS_CardPartnerInsurance]([partner_id] ASC);

