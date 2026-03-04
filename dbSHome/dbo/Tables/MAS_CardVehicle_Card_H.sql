CREATE TABLE [dbo].[MAS_CardVehicle_Card_H] (
    [CardHistoryId]   BIGINT           IDENTITY (1, 1) NOT NULL,
    [ActionType]      INT              NOT NULL,
    [ActionTypeName]  NVARCHAR (100)   NULL,
    [CardId]          INT              NULL,
    [CardVehicleId]   INT              NULL,
    [FromDate]        DATE             NULL,
    [ToDate]          DATE             NULL,
    [VehicleTypeId]   INT              NULL,
    [VehicleTypeName] NVARCHAR (100)   NULL,
    [OldCardCode]     NVARCHAR (50)    NULL,
    [NewCardCode]     NVARCHAR (50)    NULL,
    [OldOwner]        NVARCHAR (200)   NULL,
    [NewOwner]        NVARCHAR (200)   NULL,
    [OldOwnerCustId]  NVARCHAR (50)    NULL,
    [NewOwnerCustId]  NVARCHAR (50)    NULL,
    [VehicleNo]       NVARCHAR (16)    NULL,
    [Operator]        NVARCHAR (100)   NULL,
    [ActionTime]      DATETIME         NOT NULL,
    [Notes]           NVARCHAR (500)   NULL,
    [ProjectCd]       NVARCHAR (30)    NULL,
    [CreatedDate]     DATETIME         CONSTRAINT [DF_MAS_CardVehicle_Card_H_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [oid]             UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_CardVehicle_Card_H_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]      UNIQUEIDENTIFIER NULL,
    [cardOid]         UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_CardVehicle_Card_H] PRIMARY KEY CLUSTERED ([CardHistoryId] ASC),
    CONSTRAINT [FK_MAS_CardVehicle_Card_H_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_Card_H_NewOwnerCustId]
    ON [dbo].[MAS_CardVehicle_Card_H]([NewOwnerCustId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_Card_H_ProjectCd]
    ON [dbo].[MAS_CardVehicle_Card_H]([ProjectCd] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_Card_H_VehicleNo]
    ON [dbo].[MAS_CardVehicle_Card_H]([VehicleNo] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_Card_H_ActionTime]
    ON [dbo].[MAS_CardVehicle_Card_H]([ActionTime] DESC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_Card_H_CardVehicleId]
    ON [dbo].[MAS_CardVehicle_Card_H]([CardVehicleId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_Card_H_CardId]
    ON [dbo].[MAS_CardVehicle_Card_H]([CardId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_Card_H_ActionType]
    ON [dbo].[MAS_CardVehicle_Card_H]([ActionType] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ghi chú: Lưu lại lí do của hành động do người dùng nhập (Đổi mã thẻ: Đổi thẻ do hỏng, mất; Đổi chủ sở hữu: Thay đổi người ở (bán/chuyển nhượng), đổi thẻ giữa các thành viên trong căn hộ; Khóa xe: Mất thẻ, nợ phí, vi phạm quy định; Hủy xe: Không còn nhu cầu sử dụng, đổi xe)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle_Card_H', @level2type = N'COLUMN', @level2name = N'Notes';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Thời gian thực hiện: Lưu lại timestamp mà hệ thống ghi nhận hành động thay đổi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle_Card_H', @level2type = N'COLUMN', @level2name = N'ActionTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Người thao tác: Lưu lại username của Cư dân thực hiện hành động qua app hoặc Ban quản lý thực hiện hành động qua CMS', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle_Card_H', @level2type = N'COLUMN', @level2name = N'Operator';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Chủ sở hữu mới: Tên cư dân sở hữu phương tiện sau khi đổi (chỉ có ở hành động Đổi chủ sở hữu)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle_Card_H', @level2type = N'COLUMN', @level2name = N'NewOwner';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Chủ sở hữu cũ: Tên cư dân sở hữu phương tiện trước đây (chỉ có ở hành động Đổi chủ sở hữu)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle_Card_H', @level2type = N'COLUMN', @level2name = N'OldOwner';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Mã thẻ mới: Là mã thẻ mới được gắn với phương tiện hai bánh (chỉ có ở hành động Đổi mã thẻ)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle_Card_H', @level2type = N'COLUMN', @level2name = N'NewCardCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Mã thẻ cũ: Là mã thẻ cũ được gắn với phương tiện hai bánh (chỉ có ở hành động Đổi mã thẻ)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle_Card_H', @level2type = N'COLUMN', @level2name = N'OldCardCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Đến ngày: Ngày kết thúc gắn xe với mã thẻ / Ngày kết thúc sử dụng thẻ của chủ sở hữu cũ / Ngày mở khoá xe / Ngày mở khoá thẻ / Ngày kết thúc sử dụng xe', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle_Card_H', @level2type = N'COLUMN', @level2name = N'ToDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Từ ngày: Ngày bắt đầu gắn xe với mã thẻ / Ngày bắt đầu sử dụng thẻ của chủ sở hữu cũ / Ngày có hiệu lực khoá xe / Ngày có hiệu lực khoá thẻ / Ngày bắt đầu sử dụng xe', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle_Card_H', @level2type = N'COLUMN', @level2name = N'FromDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Loại hành động: 1 = Đổi mã thẻ, 2 = Đổi chủ sở hữu, 3 = Khóa xe, 4 = Khóa thẻ, 5 = Hủy xe', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle_Card_H', @level2type = N'COLUMN', @level2name = N'ActionType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Lịch sử thẻ xe', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle_Card_H';

