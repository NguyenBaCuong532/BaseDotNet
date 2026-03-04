CREATE TABLE [dbo].[mas_invoice_periods] (
    [oid]                 UNIQUEIDENTIFIER CONSTRAINT [DF_mas_invoice_periods_oid] DEFAULT (newid()) NOT NULL,
    [revenue_periods_oid] UNIQUEIDENTIFIER NOT NULL,
    [name]                NVARCHAR (150)   NOT NULL,
    [created_by]          UNIQUEIDENTIFIER NULL,
    [created_date]        DATETIME         CONSTRAINT [DF_mas_invoice_periods_created_date] DEFAULT (sysdatetime()) NOT NULL,
    [last_updated_by]     UNIQUEIDENTIFIER NULL,
    [last_updated_date]   DATETIME         CONSTRAINT [DF_mas_invoice_periods_last_updated_date] DEFAULT (sysdatetime()) NOT NULL,
    [tenant_oid]          UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_mas_invoice_periods] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_mas_invoice_periods_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tên kỳ hóa đơn', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'mas_invoice_periods', @level2type = N'COLUMN', @level2name = N'name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID kỳ dự thu', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'mas_invoice_periods', @level2type = N'COLUMN', @level2name = N'revenue_periods_oid';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kỳ hóa đơn', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'mas_invoice_periods';

