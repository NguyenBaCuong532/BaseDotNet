CREATE TABLE [dbo].[visit_fee] (
    [project_code]    NVARCHAR (50)    NOT NULL,
    [vehicle_type_id] INT              NOT NULL,
    [shift_code]      VARCHAR (10)     NOT NULL,
    [amount]          MONEY            NOT NULL,
    [rule_id]         INT              NULL,
    [oid]             UNIQUEIDENTIFIER CONSTRAINT [DF_visit_fee_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]      UNIQUEIDENTIFIER NULL,
    CHECK ([shift_code]='night' OR [shift_code]='day'),
    CONSTRAINT [FK_vf_ruleid] FOREIGN KEY ([rule_id]) REFERENCES [dbo].[pricing_rule] ([rule_id]),
    CONSTRAINT [FK_visit_fee_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_visit_fee_rule_shift]
    ON [dbo].[visit_fee]([rule_id] ASC, [shift_code] ASC) WHERE ([rule_id] IS NOT NULL);

