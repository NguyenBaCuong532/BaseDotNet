CREATE TABLE [dbo].[MAS_Rooms] (
    [RoomCode]     NVARCHAR (50)    NOT NULL,
    [Floor]        DECIMAL (18, 2)  NULL,
    [BuildingCd]   NVARCHAR (50)    NULL,
    [WallArea]     FLOAT (53)       NULL,
    [WaterwayArea] FLOAT (53)       NULL,
    [IsChange]     BIT              NULL,
    [floorNo]      NVARCHAR (50)    NULL,
    [SysDate]      DATETIME         CONSTRAINT [DF_MAS_Rooms_SysDate] DEFAULT (getdate()) NULL,
    [RoomCodeView] NVARCHAR (50)    NULL,
    [rowguid]      UNIQUEIDENTIFIER CONSTRAINT [MSmerge_df_rowguid_DC7B0F622DB249828ADBD8D19CE00157] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [oid]          UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Rooms_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]   UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Rooms] PRIMARY KEY CLUSTERED ([RoomCode] ASC),
    CONSTRAINT [FK_MAS_Rooms_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);








GO
CREATE NONCLUSTERED INDEX [idx_MAS_Rooms_BuildingCd]
    ON [dbo].[MAS_Rooms]([BuildingCd] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Rooms_RoomCode]
    ON [dbo].[MAS_Rooms]([RoomCode] ASC)
    INCLUDE([BuildingCd], [floorNo]);


GO
CREATE NONCLUSTERED INDEX [IX_MAS_Rooms_RoomCode]
    ON [dbo].[MAS_Rooms]([RoomCode] ASC)
    INCLUDE([Floor], [BuildingCd]);

