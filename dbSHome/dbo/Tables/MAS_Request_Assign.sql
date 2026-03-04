CREATE TABLE [dbo].[MAS_Request_Assign] (
    [id]         INT              IDENTITY (1, 1) NOT NULL,
    [requestId]  BIGINT           NOT NULL,
    [userId]     NVARCHAR (100)   NOT NULL,
    [assignRole] INT              NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Request_Assign_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_TRS_RequestEmpoyee] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_MAS_Request_Assign_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE UNIQUE NONCLUSTERED INDEX [index_MAS_Request_Assign_requestId_userId]
    ON [dbo].[MAS_Request_Assign]([requestId] ASC, [userId] ASC);

