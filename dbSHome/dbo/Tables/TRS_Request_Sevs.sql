CREATE TABLE [dbo].[TRS_Request_Sevs] (
    [RequestId]  INT              NOT NULL,
    [Comment]    NVARCHAR (MAX)   NOT NULL,
    [IsNow]      BIT              NULL,
    [AtTime]     DATETIME         NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_TRS_Request_Sevs_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_TRS_Request_Sevs] PRIMARY KEY CLUSTERED ([RequestId] ASC),
    CONSTRAINT [FK_TRS_Request_Sevs_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

