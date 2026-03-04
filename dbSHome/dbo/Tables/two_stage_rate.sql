CREATE TABLE [dbo].[two_stage_rate] (
    [project_code]                NVARCHAR (50)    NOT NULL,
    [vehicle_type_id]             INT              NOT NULL,
    [first_block_minutes]         INT              NOT NULL,
    [first_block_amount_day]      MONEY            NOT NULL,
    [first_block_amount_night]    MONEY            NOT NULL,
    [next_block_minutes]          INT              NOT NULL,
    [next_block_amount_day]       MONEY            NOT NULL,
    [next_block_amount_night]     MONEY            NOT NULL,
    [entry_shift_for_first_block] VARCHAR (10)     NOT NULL,
    [rule_id]                     INT              NULL,
    [oid]                         UNIQUEIDENTIFIER CONSTRAINT [DF_two_stage_rate_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]                  UNIQUEIDENTIFIER NULL,
    CHECK ([entry_shift_for_first_block]='by_segment' OR [entry_shift_for_first_block]='by_entry'),
    CONSTRAINT [FK_ts_ruleid] FOREIGN KEY ([rule_id]) REFERENCES [dbo].[pricing_rule] ([rule_id]),
    CONSTRAINT [FK_two_stage_rate_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_two_stage_rule]
    ON [dbo].[two_stage_rate]([rule_id] ASC) WHERE ([rule_id] IS NOT NULL);

