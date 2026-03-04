CREATE TABLE [dbo].[service_type] (
    [id]          UNIQUEIDENTIFIER CONSTRAINT [DF_service_type_id] DEFAULT (newid()) NOT NULL,
    [code]        NVARCHAR (50)    NOT NULL,
    [name]        NVARCHAR (250)   NOT NULL,
    [description] NVARCHAR (250)   NULL,
    [ordinal]     INT              NULL,
    [tenant_oid]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_service_type] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_service_type_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

