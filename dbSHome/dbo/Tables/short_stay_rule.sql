CREATE TABLE [dbo].[short_stay_rule] (
    [project_code]         NVARCHAR (50)    NOT NULL,
    [vehicle_type_id]      INT              NOT NULL,
    [enabled]              BIT              DEFAULT ((0)) NOT NULL,
    [short_window_minutes] INT              DEFAULT ((720)) NOT NULL,
    [exit_price_day]       MONEY            NULL,
    [exit_price_night]     MONEY            NULL,
    [rule_id]              INT              NULL,
    [oid]                  UNIQUEIDENTIFIER CONSTRAINT [DF_short_stay_rule_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]           UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_short_stay_rule_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid]),
    CONSTRAINT [FK_ss_ruleid] FOREIGN KEY ([rule_id]) REFERENCES [dbo].[pricing_rule] ([rule_id])
);






GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_short_stay_rule]
    ON [dbo].[short_stay_rule]([rule_id] ASC) WHERE ([rule_id] IS NOT NULL);

