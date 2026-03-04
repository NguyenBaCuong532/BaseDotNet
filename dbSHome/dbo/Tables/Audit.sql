CREATE TABLE [dbo].[Audit] (
    [AuditID]       INT              IDENTITY (1, 1) NOT NULL,
    [TableName]     [sysname]        NOT NULL,
    [ActionType]    VARCHAR (10)     NULL,
    [LoginName]     NVARCHAR (200)   NULL,
    [HostName]      NVARCHAR (200)   NULL,
    [AppName]       NVARCHAR (200)   NULL,
    [SqlText]       NVARCHAR (MAX)   NULL,
    [ProcedureName] NVARCHAR (200)   NULL,
    [OldValue]      NVARCHAR (MAX)   NULL,
    [NewValue]      NVARCHAR (MAX)   NULL,
    [ChangedAt]     DATETIME2 (7)    DEFAULT (sysdatetime()) NULL,
    [oid]           UNIQUEIDENTIFIER CONSTRAINT [DF_Audit_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    PRIMARY KEY CLUSTERED ([AuditID] ASC),
    CONSTRAINT [FK_Audit_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

