CREATE TABLE [dbo].[MAS_Request_Process] (
    [processId]    INT              IDENTITY (1, 1) NOT NULL,
    [requestId]    INT              NOT NULL,
    [comment]      NVARCHAR (MAX)   NULL,
    [EmployeeName] NVARCHAR (150)   NULL,
    [processDt]    DATETIME         NULL,
    [userId]       NVARCHAR (50)    NULL,
    [Status]       INT              NULL,
    [oid]          UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Request_Process_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]   UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_TRS_RequestProcess] PRIMARY KEY CLUSTERED ([processId] ASC),
    CONSTRAINT [FK_MAS_Request_Process_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

