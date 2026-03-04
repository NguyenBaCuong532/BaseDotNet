CREATE TABLE [dbo].[mas_billing_periods] (
    [oid]                UNIQUEIDENTIFIER CONSTRAINT [DF_mas_billing_periods_oid] DEFAULT (newid()) NOT NULL,
    [project_code]       NVARCHAR (50)    NULL,
    [reference_date]     DATE             NOT NULL,
    [period_code]        NVARCHAR (50)    NOT NULL,
    [period_name]        NVARCHAR (100)   NOT NULL,
    [start_date]         DATE             NOT NULL,
    [end_date]           DATE             NOT NULL,
    [status]             INT              NOT NULL,
    [note]               NVARCHAR (100)   NULL,
    [locked]             BIT              CONSTRAINT [DF_mas_billing_periods_locked] DEFAULT ((0)) NOT NULL,
    [created_user]       UNIQUEIDENTIFIER NOT NULL,
    [created_date]       DATETIME         CONSTRAINT [DF_mas_billing_periods_created_date] DEFAULT (getdate()) NOT NULL,
    [last_modified_by]   UNIQUEIDENTIFIER NOT NULL,
    [last_modified_date] DATETIME         CONSTRAINT [DF_mas_billing_periods_last_modified_date] DEFAULT (getdate()) NOT NULL,
    [tenant_oid]         UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_mas_billing_periods] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_mas_billing_periods_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kỳ thanh toán (dự thu/hóa đơn)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'mas_billing_periods';

