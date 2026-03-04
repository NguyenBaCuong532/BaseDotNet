CREATE TABLE [dbo].[mas_payment_priority_configs] (
    [oid]                UNIQUEIDENTIFIER CONSTRAINT [DF_mas_payment_priority_configs_oid] DEFAULT (newid()) NOT NULL,
    [project_code]       NVARCHAR (50)    NOT NULL,
    [ServiceTypeId]      INT              NOT NULL,
    [is_collect_fee]     BIT              CONSTRAINT [DF_mas_payment_priority_configs_is_collect_fee] DEFAULT ((1)) NOT NULL,
    [priority_order]     INT              NOT NULL,
    [created_by]         UNIQUEIDENTIFIER NULL,
    [created_time]       DATETIME         CONSTRAINT [DF_mas_payment_priority_configs_created_time] DEFAULT (getdate()) NOT NULL,
    [last_modified_by]   UNIQUEIDENTIFIER NULL,
    [last_modified_time] DATETIME         CONSTRAINT [DF_mas_payment_priority_configs_last_modified_time] DEFAULT (getdate()) NOT NULL,
    [tenant_oid]         UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_mas_payment_priority_configs] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_mas_payment_priority_configs_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);








GO



GO



GO



GO
