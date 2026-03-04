CREATE TABLE [dbo].[PAR_RequestActionEmail] (
    [RequestTypeId] INT              NOT NULL,
    [Emails]        NVARCHAR (400)   NULL,
    [ProjectCd]     NVARCHAR (20)    NULL,
    [oid]           UNIQUEIDENTIFIER CONSTRAINT [DF_PAR_RequestActionEmail_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_PAR_RequestActionEmail] PRIMARY KEY CLUSTERED ([RequestTypeId] ASC),
    CONSTRAINT [FK_PAR_RequestActionEmail_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

