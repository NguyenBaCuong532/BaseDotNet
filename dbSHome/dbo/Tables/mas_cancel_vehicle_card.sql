CREATE TABLE [dbo].[mas_cancel_vehicle_card] (
    [oid]                UNIQUEIDENTIFIER CONSTRAINT [DF_mas_cancel_vehicle_card_oid] DEFAULT (newid()) NOT NULL,
    [CardVehicleId]      INT              NOT NULL,
    [VehicleNo]          NVARCHAR (50)    NOT NULL,
    [VehicleTypeId]      INT              NOT NULL,
    [FullName]           NVARCHAR (150)   NOT NULL,
    [RegisterDate]       DATETIME         NOT NULL,
    [CancelDate]         DATETIME         NOT NULL,
    [Note]               NVARCHAR (2000)  NULL,
    [created_user]       UNIQUEIDENTIFIER NOT NULL,
    [created_date]       DATETIME         CONSTRAINT [DF_mas_cancel_vehicle_card_created_date] DEFAULT (getdate()) NOT NULL,
    [last_modified_by]   UNIQUEIDENTIFIER NOT NULL,
    [last_modified_date] DATETIME         CONSTRAINT [DF_mas_cancel_vehicle_card_last_modified_date] DEFAULT (getdate()) NOT NULL,
    [tenant_oid]         UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_mas_cancel_vehicle_card] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_mas_cancel_vehicle_card_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ghi chú/lý do hủy', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'mas_cancel_vehicle_card', @level2type = N'COLUMN', @level2name = N'Note';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ngày hủy thẻ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'mas_cancel_vehicle_card', @level2type = N'COLUMN', @level2name = N'CancelDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ngày đăng ký hủy thẻ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'mas_cancel_vehicle_card', @level2type = N'COLUMN', @level2name = N'RegisterDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Chủ thẻ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'mas_cancel_vehicle_card', @level2type = N'COLUMN', @level2name = N'FullName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Loại xe', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'mas_cancel_vehicle_card', @level2type = N'COLUMN', @level2name = N'VehicleTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Biển số xe', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'mas_cancel_vehicle_card', @level2type = N'COLUMN', @level2name = N'VehicleNo';

