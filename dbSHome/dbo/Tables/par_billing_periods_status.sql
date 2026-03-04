CREATE TABLE [dbo].[par_billing_periods_status] (
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_par_billing_periods_status_oid] DEFAULT (newid()) NOT NULL,
    [code]       INT              NOT NULL,
    [name]       NVARCHAR (50)    NOT NULL,
    [class_name] NVARCHAR (50)    NOT NULL,
    [sort_order] INT              CONSTRAINT [DF_par_billing_periods_status_sort_order] DEFAULT ((0)) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_par_billing_periods_status] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_par_billing_periods_status_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

