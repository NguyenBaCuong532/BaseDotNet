CREATE TABLE [dbo].[WAL_BankLinked] (
    [LinkId]     INT              IDENTITY (1, 1) NOT NULL,
    [TranferCd]  NVARCHAR (20)    NOT NULL,
    [SourceCd]   NVARCHAR (50)    NOT NULL,
    [IsLinked]   BIT              NULL,
    [IsOn]       BIT              NULL,
    [LinkDt]     DATETIME         CONSTRAINT [DF_WAL_BankLinked_LinkDt] DEFAULT (getdate()) NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_WAL_BankLinked_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_WAL_BankLinked] PRIMARY KEY CLUSTERED ([TranferCd] ASC, [SourceCd] ASC),
    CONSTRAINT [FK_WAL_BankLinked_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

