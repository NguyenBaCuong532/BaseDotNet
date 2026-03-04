CREATE TABLE [dbo].[WAL_TransactionType] (
    [TransTypeId]   INT              NOT NULL,
    [TransTypeName] NVARCHAR (50)    NOT NULL,
    [CreateDt]      DATETIME         CONSTRAINT [DF_WAL_TransactionType_CreateDt] DEFAULT (getdate()) NULL,
    [oid]           UNIQUEIDENTIFIER CONSTRAINT [DF_WAL_TransactionType_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_WAL_TransactionType] PRIMARY KEY CLUSTERED ([TransTypeId] ASC),
    CONSTRAINT [FK_WAL_TransactionType_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

