CREATE TABLE [dbo].[MAS_CardStatus] (
    [StatusId]        INT              NOT NULL,
    [StatusName]      NVARCHAR (50)    NOT NULL,
    [StatusNameLable] NVARCHAR (100)   NULL,
    [oid]             UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_CardStatus_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]      UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_MAS_CardStatus_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

