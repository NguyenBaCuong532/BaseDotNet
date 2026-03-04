CREATE TABLE [dbo].[MAS_Card_Sync] (
    [CardId]     INT              NOT NULL,
    [IsLift]     BIT              NULL,
    [isLobby]    BIT              NULL,
    [sysdate]    DATETIME         CONSTRAINT [DF_MAS_Card_Sync_sysdate] DEFAULT (getdate()) NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Card_Sync_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    [cardOid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Card_Sync] PRIMARY KEY CLUSTERED ([CardId] ASC),
    CONSTRAINT [FK_MAS_Card_Sync_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

