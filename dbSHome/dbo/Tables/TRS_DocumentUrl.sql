CREATE TABLE [dbo].[TRS_DocumentUrl] (
    [DocId]         INT              IDENTITY (1, 1) NOT NULL,
    [DocumentTitle] NVARCHAR (250)   NULL,
    [DocumentUrl]   NVARCHAR (300)   NOT NULL,
    [InputDt]       DATETIME         NULL,
    [ProjectCd]     NVARCHAR (30)    NULL,
    [oid]           UNIQUEIDENTIFIER CONSTRAINT [DF_TRS_DocumentUrl_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_TRS_DocumentUrl] PRIMARY KEY CLUSTERED ([DocumentUrl] ASC),
    CONSTRAINT [FK_TRS_DocumentUrl_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

