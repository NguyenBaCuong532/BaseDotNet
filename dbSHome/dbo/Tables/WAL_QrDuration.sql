CREATE TABLE [dbo].[WAL_QrDuration] (
    [QrId]       BIGINT           IDENTITY (1, 1) NOT NULL,
    [QrKey]      NVARCHAR (50)    NOT NULL,
    [QrStatus]   INT              NULL,
    [WalletCd]   NVARCHAR (16)    NOT NULL,
    [PosCd]      NVARCHAR (50)    NULL,
    [CreateDt]   DATETIME         NULL,
    [CreateBy]   NVARCHAR (200)   NULL,
    [ExpireDt]   DATETIME         NOT NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_WAL_QrDuration_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_WAL_QrDuration] PRIMARY KEY CLUSTERED ([QrKey] ASC),
    CONSTRAINT [FK_WAL_QrDuration_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

