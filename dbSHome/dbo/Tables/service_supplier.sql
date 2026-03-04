CREATE TABLE [dbo].[service_supplier] (
    [id]          UNIQUEIDENTIFIER CONSTRAINT [DF_service_supplier_id] DEFAULT (newid()) NOT NULL,
    [service_id]  UNIQUEIDENTIFIER NULL,
    [supplier_id] UNIQUEIDENTIFIER NULL,
    [is_active]   BIT              NULL,
    [tenant_oid]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_service_suppliers] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_service_supplier_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

