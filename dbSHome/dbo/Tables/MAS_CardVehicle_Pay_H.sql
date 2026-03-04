CREATE TABLE [dbo].[MAS_CardVehicle_Pay_H] (
    [PayHistoryId]      BIGINT           IDENTITY (1, 1) NOT NULL,
    [PayId]             INT              NULL,
    [CardVehicleId]     INT              NOT NULL,
    [CardId]            INT              NULL,
    [CardCd]            NVARCHAR (50)    NULL,
    [VehicleNo]         NVARCHAR (16)    NULL,
    [VehicleTypeId]     INT              NULL,
    [VehicleTypeName]   NVARCHAR (100)   NULL,
    [Amount]            DECIMAL (18, 2)  NOT NULL,
    [PaymentDate]       DATETIME         NULL,
    [PaymentStatus]     INT              NOT NULL,
    [PaymentStatusName] NVARCHAR (50)    NULL,
    [StartDate]         DATE             NULL,
    [EndDate]           DATE             NULL,
    [PeriodName]        NVARCHAR (100)   NULL,
    [CreatedDate]       DATETIME         CONSTRAINT [DF_MAS_CardVehicle_Pay_H_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]         NVARCHAR (100)   NULL,
    [Remark]            NVARCHAR (500)   NULL,
    [ProjectCd]         NVARCHAR (30)    NULL,
    [oid]               UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_CardVehicle_Pay_H_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]        UNIQUEIDENTIFIER NULL,
    [cardOid]           UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_CardVehicle_Pay_H] PRIMARY KEY CLUSTERED ([PayHistoryId] ASC),
    CONSTRAINT [FK_MAS_CardVehicle_Pay_H_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_Pay_H_ProjectCd]
    ON [dbo].[MAS_CardVehicle_Pay_H]([ProjectCd] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_Pay_H_CreatedDate]
    ON [dbo].[MAS_CardVehicle_Pay_H]([CreatedDate] DESC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_Pay_H_PaymentStatus]
    ON [dbo].[MAS_CardVehicle_Pay_H]([PaymentStatus] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_Pay_H_PaymentDate]
    ON [dbo].[MAS_CardVehicle_Pay_H]([PaymentDate] DESC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_Pay_H_PayId]
    ON [dbo].[MAS_CardVehicle_Pay_H]([PayId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_Pay_H_CardVehicleId]
    ON [dbo].[MAS_CardVehicle_Pay_H]([CardVehicleId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Người thực hiện: User ID - User người thực hiện thay đổi trạng thái', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle_Pay_H', @level2type = N'COLUMN', @level2name = N'CreatedBy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kỳ dự thu: Tên kỳ dự thu từng tháng', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle_Pay_H', @level2type = N'COLUMN', @level2name = N'PeriodName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Trạng thái thanh toán: 0 = Chưa thanh toán, 1 = Đã thanh toán, 2 = Chờ hoàn tiền, 3 = Đã hoàn tiền', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle_Pay_H', @level2type = N'COLUMN', @level2name = N'PaymentStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ngày thanh toán: Ngày ghi nhận giao dịch đối với Trạng thái "Đã thanh toán" hoặc "Đã hoàn tiền"', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle_Pay_H', @level2type = N'COLUMN', @level2name = N'PaymentDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Số tiền: Phí gửi xe cần nộp mỗi kỳ thanh toán', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle_Pay_H', @level2type = N'COLUMN', @level2name = N'Amount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Mã giao dịch', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle_Pay_H', @level2type = N'COLUMN', @level2name = N'PayId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Lịch sử thanh toán thẻ xe', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle_Pay_H';

