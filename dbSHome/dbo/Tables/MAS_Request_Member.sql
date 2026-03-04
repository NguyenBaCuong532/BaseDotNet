CREATE TABLE [dbo].[MAS_Request_Member] (
    [Id]                UNIQUEIDENTIFIER DEFAULT (newid()) NOT NULL,
    [requestCategoryId] INT              NOT NULL,
    [userId]            UNIQUEIDENTIFIER NOT NULL,
    [categoryCd]        NVARCHAR (30)    NOT NULL,
    [roleType]          INT              NULL,
    [tenant_oid]        UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Request_Member] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_MAS_Request_Member_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

