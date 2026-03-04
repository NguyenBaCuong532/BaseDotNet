CREATE TABLE [dbo].[WAL_TranferLinked] (
    [LinkedID]        INT              IDENTITY (1, 1) NOT NULL,
    [WalletCd]        NVARCHAR (16)    NOT NULL,
    [TranferCd]       NVARCHAR (50)    NOT NULL,
    [SourceCd]        NVARCHAR (50)    NULL,
    [LinkedToken]     NVARCHAR (100)   NULL,
    [IsLinked]        BIT              NOT NULL,
    [LinkDt]          DATETIME         NULL,
    [card_Brand]      NVARCHAR (50)    NULL,
    [card_NameOnCard] NVARCHAR (50)    NULL,
    [card_IssueDate]  NVARCHAR (50)    NULL,
    [card_Number]     NVARCHAR (50)    NULL,
    [card_Scheme]     NVARCHAR (50)    NULL,
    [oid]             UNIQUEIDENTIFIER CONSTRAINT [DF_WAL_TranferLinked_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]      UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Wallet_ATMCard] PRIMARY KEY CLUSTERED ([LinkedID] ASC),
    CONSTRAINT [FK_WAL_TranferLinked_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);




GO
CREATE NONCLUSTERED INDEX [IX_WAL_TranferLinked_IsLinked_Wallet]
    ON [dbo].[WAL_TranferLinked]([IsLinked] ASC, [WalletCd] ASC, [LinkedID] ASC)
    INCLUDE([TranferCd], [SourceCd], [LinkedToken]);

