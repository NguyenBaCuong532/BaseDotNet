CREATE TABLE [dbo].[mas_payment_services] (
    [oid]          UNIQUEIDENTIFIER CONSTRAINT [DF_mas_payment_services_oid] DEFAULT (newid()) NOT NULL,
    [service_code] NVARCHAR (50)    NOT NULL,
    [service_name] NVARCHAR (50)    NOT NULL,
    [description]  NVARCHAR (150)   NULL,
    [table_name]   NVARCHAR (50)    NULL,
    [sort_order]   INT              NULL,
    CONSTRAINT [PK_mas_payment_services] PRIMARY KEY CLUSTERED ([oid] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Danh sách các dịch vụ của căn hộ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'mas_payment_services';

