CREATE TABLE [dbo].[rocketchat_department] (
    [id]         NVARCHAR (50)    NOT NULL,
    [name]       NVARCHAR (250)   NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_rocketchat_department_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_rocketchat_department] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_rocketchat_department_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

