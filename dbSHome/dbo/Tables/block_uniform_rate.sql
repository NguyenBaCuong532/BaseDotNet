CREATE TABLE [dbo].[block_uniform_rate] (
    [project_code]         NVARCHAR (50)    NOT NULL,
    [vehicle_type_id]      INT              NOT NULL,
    [block_unit_minutes]   INT              NOT NULL,
    [rate_per_block_day]   MONEY            NOT NULL,
    [rate_per_block_night] MONEY            NOT NULL,
    [block_boundary]       VARCHAR (20)     NOT NULL,
    [rule_id]              INT              NULL,
    [oid]                  UNIQUEIDENTIFIER CONSTRAINT [DF_block_uniform_rate_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]           UNIQUEIDENTIFIER NULL,
    CHECK ([block_boundary]='whole_period' OR [block_boundary]='per_shift'),
    CONSTRAINT [FK_block_uniform_rate_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid]),
    CONSTRAINT [FK_bu_ruleid] FOREIGN KEY ([rule_id]) REFERENCES [dbo].[pricing_rule] ([rule_id])
);






GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_block_uniform_rule]
    ON [dbo].[block_uniform_rate]([rule_id] ASC) WHERE ([rule_id] IS NOT NULL);

