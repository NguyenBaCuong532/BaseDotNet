CREATE TABLE [dbo].[TRS_Request_Fixs] (
    [RequestId]  INT              NOT NULL,
    [Comment]    NVARCHAR (MAX)   NOT NULL,
    [BrokenUrl1] NVARCHAR (250)   NULL,
    [BrokenUrl2] NVARCHAR (250)   NULL,
    [BrokenUrl3] NVARCHAR (250)   NULL,
    [IsNow]      BIT              NULL,
    [AtTime]     DATETIME         NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_TRS_Request_Fixs_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_TRS_Request_Fixs] PRIMARY KEY CLUSTERED ([RequestId] ASC),
    CONSTRAINT [FK_TRS_Request_Fixs_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

