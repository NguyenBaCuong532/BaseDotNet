CREATE TABLE [dbo].[MAS_CardVehicle_Swipe_H] (
    [SwipeHistoryId]  BIGINT           IDENTITY (1, 1) NOT NULL,
    [CardId]          INT              NOT NULL,
    [CardCd]          NVARCHAR (50)    NOT NULL,
    [CardVehicleId]   INT              NULL,
    [VehicleNo]       NVARCHAR (16)    NULL,
    [VehicleTypeId]   INT              NULL,
    [VehicleTypeName] NVARCHAR (100)   NULL,
    [SwipeTime]       DATETIME         NOT NULL,
    [Status]          INT              NOT NULL,
    [StatusName]      NVARCHAR (50)    NULL,
    [Notes]           NVARCHAR (500)   NULL,
    [StationId]       INT              NULL,
    [StationName]     NVARCHAR (200)   NULL,
    [ProjectCd]       NVARCHAR (30)    NULL,
    [CreatedDate]     DATETIME         CONSTRAINT [DF_MAS_CardVehicle_Swipe_H_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [oid]             UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_CardVehicle_Swipe_H_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]      UNIQUEIDENTIFIER NULL,
    [cardOid]         UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_CardVehicle_Swipe_H] PRIMARY KEY CLUSTERED ([SwipeHistoryId] ASC),
    CONSTRAINT [FK_MAS_CardVehicle_Swipe_H_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_Swipe_H_ProjectCd]
    ON [dbo].[MAS_CardVehicle_Swipe_H]([ProjectCd] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_Swipe_H_VehicleNo]
    ON [dbo].[MAS_CardVehicle_Swipe_H]([VehicleNo] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_Swipe_H_Status]
    ON [dbo].[MAS_CardVehicle_Swipe_H]([Status] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_Swipe_H_SwipeTime]
    ON [dbo].[MAS_CardVehicle_Swipe_H]([SwipeTime] DESC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_Swipe_H_CardVehicleId]
    ON [dbo].[MAS_CardVehicle_Swipe_H]([CardVehicleId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_Swipe_H_CardId]
    ON [dbo].[MAS_CardVehicle_Swipe_H]([CardId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ghi chú lỗi: Thẻ bị khóa, Sai biển số', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle_Swipe_H', @level2type = N'COLUMN', @level2name = N'Notes';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Trạng thái: 1 = Vào, 2 = Ra, 3 = Thất bại', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle_Swipe_H', @level2type = N'COLUMN', @level2name = N'Status';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Thời gian người dùng quẹt thẻ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle_Swipe_H', @level2type = N'COLUMN', @level2name = N'SwipeTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Loại xe', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle_Swipe_H', @level2type = N'COLUMN', @level2name = N'VehicleTypeName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Biển số xe', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle_Swipe_H', @level2type = N'COLUMN', @level2name = N'VehicleNo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Mã thẻ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle_Swipe_H', @level2type = N'COLUMN', @level2name = N'CardCd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Lịch sử quẹt thẻ xe ra/vào', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle_Swipe_H';

