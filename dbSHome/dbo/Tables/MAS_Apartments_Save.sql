CREATE TABLE [dbo].[MAS_Apartments_Save] (
    [ApartmentId]    INT              NOT NULL,
    [RoomCode]       NVARCHAR (50)    NOT NULL,
    [Cif_No]         NVARCHAR (50)    NULL,
    [UserLogin]      NVARCHAR (50)    NULL,
    [FamilyImageUrl] NVARCHAR (250)   NULL,
    [StartDt]        DATETIME         NULL,
    [EndDt]          DATETIME         NULL,
    [IsClose]        BIT              NULL,
    [CloseDt]        DATETIME         NULL,
    [IsLock]         BIT              NULL,
    [IsReceived]     BIT              NULL,
    [ReceiveDt]      DATE             NULL,
    [IsRent]         BIT              NULL,
    [lastReceived]   DATETIME         NULL,
    [FeeStart]       DATETIME         NULL,
    [IsFree]         BIT              NULL,
    [FeeNote]        NVARCHAR (150)   NULL,
    [numFreeMonth]   INT              NULL,
    [AccrualLastDt]  DATE             NULL,
    [PayLastDt]      DATE             NULL,
    [projectCd]      NVARCHAR (10)    NULL,
    [buildingCd]     NVARCHAR (10)    NULL,
    [isMain]         BIT              NULL,
    [WaterwayArea]   FLOAT (53)       NULL,
    [isFeeStart]     BIT              NULL,
    [CurrBal]        DECIMAL (18)     NULL,
    [isLinkApp]      BIT              NULL,
    [DebitAmt]       DECIMAL (18)     NULL,
    [FreeToDt]       DATETIME         NULL,
    [ContractRemark] NVARCHAR (200)   NULL,
    [ContractDt]     DATE             NULL,
    [SaveDt]         DATETIME         NULL,
    [saveKey]        NVARCHAR (50)    NULL,
    [saveBy]         NVARCHAR (100)   NULL,
    [oid]            UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Apartments_Save_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    [apartOid]       UNIQUEIDENTIFIER NULL,
    [buildingOid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_MAS_Apartments_Save_buildingOid] FOREIGN KEY ([buildingOid]) REFERENCES [dbo].[MAS_Buildings] ([oid]),
    CONSTRAINT [FK_MAS_Apartments_Save_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);


GO
CREATE NONCLUSTERED INDEX [IX_MAS_Apartments_Save_buildingOid]
    ON [dbo].[MAS_Apartments_Save]([buildingOid] ASC);

