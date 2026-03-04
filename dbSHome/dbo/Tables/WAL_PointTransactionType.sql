CREATE TABLE [dbo].[WAL_PointTransactionType] (
    [TranTypeId]   NVARCHAR (30)    NOT NULL,
    [TranTypeName] NVARCHAR (50)    NOT NULL,
    [CreateDt]     DATETIME         CONSTRAINT [DF_WAL_PointTransactionType_CreateDt] DEFAULT (getdate()) NULL,
    [oid]          UNIQUEIDENTIFIER CONSTRAINT [DF_WAL_PointTransactionType_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]   UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_WAL_PointTransactionType] PRIMARY KEY CLUSTERED ([TranTypeId] ASC),
    CONSTRAINT [FK_WAL_PointTransactionType_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

