CREATE TABLE [dbo].[service_request_extra] (
    [id]                 UNIQUEIDENTIFIER CONSTRAINT [DF_service_request_extra_id] DEFAULT (newid()) NOT NULL,
    [service_request_id] UNIQUEIDENTIFIER NULL,
    [service_package_id] UNIQUEIDENTIFIER NULL,
    [price]              DECIMAL (18)     NULL,
    [tenant_oid]         UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_service_request_extra] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_service_request_extra_service_package] FOREIGN KEY ([service_package_id]) REFERENCES [dbo].[service_package] ([id]),
    CONSTRAINT [FK_service_request_extra_service_request] FOREIGN KEY ([service_request_id]) REFERENCES [dbo].[service_request] ([id]),
    CONSTRAINT [FK_service_request_extra_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

