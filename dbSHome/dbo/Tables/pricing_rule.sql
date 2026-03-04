CREATE TABLE [dbo].[pricing_rule] (
    [project_code]       NVARCHAR (50)    NOT NULL,
    [vehicle_type_id]    INT              NOT NULL,
    [under24_enabled]    BIT              DEFAULT ((0)) NOT NULL,
    [under24_cap_amount] MONEY            NULL,
    [under24_apply_on]   VARCHAR (20)     NULL,
    [full24_enabled]     BIT              DEFAULT ((0)) NOT NULL,
    [full24_amount]      MONEY            NULL,
    [over24_mode]        VARCHAR (30)     DEFAULT ('cap_then_block') NOT NULL,
    [rate_over_per_hour] MONEY            NULL,
    [extra_per_24h]      MONEY            NULL,
    [rate_mode]          VARCHAR (30)     NOT NULL,
    [rule_id]            INT              IDENTITY (1, 1) NOT NULL,
    [valid_from]         DATETIME2 (0)    DEFAULT ('2000-01-01T00:00:00') NOT NULL,
    [valid_to]           DATETIME2 (0)    NULL,
    [is_active]          BIT              DEFAULT ((1)) NOT NULL,
    [oid]                UNIQUEIDENTIFIER CONSTRAINT [DF_pricing_rule_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]         UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_pricing_rule_rule_id] PRIMARY KEY CLUSTERED ([rule_id] ASC),
    CHECK ([over24_mode]='cap_then_block' OR [over24_mode]='block24_increment' OR [over24_mode]='full24_plus_per_hour' OR [over24_mode]='repeat_full24'),
    CHECK ([rate_mode]='exit_shift_short_stay' OR [rate_mode]='sum_segments' OR [rate_mode]='two_stage_block' OR [rate_mode]='block_uniform' OR [rate_mode]='visit_per_shift'),
    CONSTRAINT [FK_pricing_rule_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE NONCLUSTERED INDEX [IX_pricing_rule_site_vehicle_time]
    ON [dbo].[pricing_rule]([project_code] ASC, [vehicle_type_id] ASC, [valid_from] ASC, [valid_to] ASC)
    INCLUDE([rate_mode], [under24_enabled], [full24_enabled], [over24_mode], [under24_cap_amount], [full24_amount], [rate_over_per_hour], [extra_per_24h], [is_active]);

