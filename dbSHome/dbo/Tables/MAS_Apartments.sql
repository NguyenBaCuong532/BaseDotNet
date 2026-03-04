CREATE TABLE [dbo].[MAS_Apartments] (
    [ApartmentId]            INT              IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ApartmentType]          INT              NULL,
    [RoomCode]               NVARCHAR (50)    NOT NULL,
    [Cif_No]                 NVARCHAR (50)    NULL,
    [UserLogin]              NVARCHAR (50)    NULL,
    [FamilyImageUrl]         NVARCHAR (250)   NULL,
    [StartDt]                DATETIME         NULL,
    [EndDt]                  DATETIME         NULL,
    [IsClose]                BIT              NULL,
    [CloseDt]                DATETIME         NULL,
    [IsLock]                 BIT              NULL,
    [IsReceived]             BIT              NULL,
    [ReceiveDt]              DATE             NULL,
    [IsRent]                 BIT              NULL,
    [lastReceived]           DATETIME         NULL,
    [FeeStart]               DATETIME         NULL,
    [IsFree]                 BIT              NULL,
    [numFreeMonth]           INT              CONSTRAINT [DF_MAS_Apartments_numFreeMonth] DEFAULT ((0)) NULL,
    [FeeNote]                NVARCHAR (150)   NULL,
    [AccrualLastDt]          DATE             NULL,
    [PayLastDt]              DATE             NULL,
    [projectCd]              NVARCHAR (10)    NULL,
    [buildingCd]             NVARCHAR (10)    NULL,
    [isMain]                 BIT              NULL,
    [WaterwayArea]           FLOAT (53)       NULL,
    [isFeeStart]             BIT              NULL,
    [CurrBal]                DECIMAL (18)     NULL,
    [isLinkApp]              BIT              NULL,
    [DebitAmt]               DECIMAL (18)     CONSTRAINT [DF_MAS_Apartments_DebitAmt] DEFAULT ((0)) NULL,
    [FreeToDt]               DATETIME         NULL,
    [RefundAmt]              DECIMAL (18)     NULL,
    [sub_projectCd]          NVARCHAR (10)    NULL,
    [apartId]                UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Apartments_apartId] DEFAULT (newid()) NULL,
    [rowguid]                UNIQUEIDENTIFIER CONSTRAINT [MSmerge_df_rowguid_5E1714027C9648458FEFDEF48ADE143C] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [WallArea]               FLOAT (53)       NULL,
    [par_residence_type_oid] UNIQUEIDENTIFIER NULL,
    [oid]                    UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Apartments_id] DEFAULT (newid()) NOT NULL,
    [tenant_oid]             UNIQUEIDENTIFIER NULL,
    [created_by]             UNIQUEIDENTIFIER NULL,
    [created_at]             DATETIME         CONSTRAINT [DF_MAS_Apartments_created_at] DEFAULT (getdate()) NULL,
    [floorOid]               UNIQUEIDENTIFIER NULL,
    [buildingOid]            UNIQUEIDENTIFIER NULL,
    [Floor]                  DECIMAL (18, 2)  NULL,
    [floorNo]                NVARCHAR (50)    NULL,
    [RoomCodeView]           NVARCHAR (50)    NULL,
    CONSTRAINT [PK_MAS_Apartments] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_MAS_Apartments_buildingOid] FOREIGN KEY ([buildingOid]) REFERENCES [dbo].[MAS_Buildings] ([oid]),
    CONSTRAINT [FK_MAS_Apartments_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid]),
    CONSTRAINT [Constraint_MAS_Apartments_RoomCode] UNIQUE NONCLUSTERED ([RoomCode] ASC)
);
















GO
CREATE NONCLUSTERED INDEX [idx_MAS_Apartments_roomCode]
    ON [dbo].[MAS_Apartments]([RoomCode] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Apartments_IsReceived]
    ON [dbo].[MAS_Apartments]([IsReceived] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Apartments_projectCd]
    ON [dbo].[MAS_Apartments]([projectCd] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Apartments_userlogin]
    ON [dbo].[MAS_Apartments]([UserLogin] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Loại hình căn hộ (cho thuê, cứ dân, dịch vụ...)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_Apartments';


GO
CREATE NONCLUSTERED INDEX [IX_Apartments_ApartmentId]
    ON [dbo].[MAS_Apartments]([ApartmentId] ASC)
    INCLUDE([RoomCode]);


GO
CREATE NONCLUSTERED INDEX [IX_MAS_Apartments_UserLogin_Received]
    ON [dbo].[MAS_Apartments]([UserLogin] ASC, [IsReceived] ASC)
    INCLUDE([ApartmentId], [RoomCode], [FamilyImageUrl], [Cif_No]);


GO
CREATE NONCLUSTERED INDEX [IX_MAS_Apartments_Cif_Received]
    ON [dbo].[MAS_Apartments]([Cif_No] ASC) WHERE ([IsReceived]=(1));


GO
CREATE NONCLUSTERED INDEX [IX_MAS_Apartments_floorOid]
    ON [dbo].[MAS_Apartments]([floorOid] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_MAS_Apartments_buildingOid]
    ON [dbo].[MAS_Apartments]([buildingOid] ASC);

