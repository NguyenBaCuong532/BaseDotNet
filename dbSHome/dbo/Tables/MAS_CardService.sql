CREATE TABLE [dbo].[MAS_CardService] (
    [Id]         INT              IDENTITY (1, 1) NOT NULL,
    [CardCd]     NVARCHAR (50)    NULL,
    [ServiceId]  INT              NOT NULL,
    [CardId]     INT              NOT NULL,
    [LinkDate]   DATETIME         NULL,
    [IsLock]     BIT              CONSTRAINT [DF_MAS_CardService_IsLock] DEFAULT ((0)) NULL,
    [LockDt]     DATETIME         NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_CardService_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    [cardOid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_CardService] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_MAS_CardService_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid]),
    CONSTRAINT [UQ_MAS_CardService_ServiceId_CardId] UNIQUE NONCLUSTERED ([ServiceId] ASC, [CardId] ASC)
);

