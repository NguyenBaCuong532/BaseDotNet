CREATE TABLE [dbo].[MAS_Service_ReceiveEntry] (
    [ReceiveId]         BIGINT           IDENTITY (1, 1) NOT NULL,
    [periods_oid]       UNIQUEIDENTIFIER NULL,
    [ProjectCd]         NVARCHAR (30)    NULL,
    [ApartmentId]       BIGINT           NULL,
    [ReceiveDt]         DATETIME         NULL,
    [ToDt]              DATETIME         NULL,
    [CommonFee]         DECIMAL (18)     NULL,
    [VehicleAmt]        DECIMAL (18)     NULL,
    [LivingAmt]         DECIMAL (18)     NULL,
    [ExtendAmt]         DECIMAL (18)     NULL,
    [DebitAmt]          DECIMAL (18)     NULL,
    [CreditAmt]         DECIMAL (18)     NULL,
    [RefundAmt]         DECIMAL (18)     NULL,
    [TotalAmt]          DECIMAL (18)     NULL,
    [DiscountAmt]       DECIMAL (18)     NULL,
    [ExpireDate]        DATETIME         NULL,
    [IsPayed]           BIT              NULL,
    [PayedDt]           DATETIME         NULL,
    [PaidAmt]           DECIMAL (18)     NULL,
    [Remart]            NVARCHAR (150)   NULL,
    [IsBill]            BIT              NULL,
    [BillUrl]           NVARCHAR (350)   NULL,
    [BillViewUrl]       NVARCHAR (350)   NULL,
    [BillDt]            DATETIME         NULL,
    [bill_st]           INT              NULL,
    [SysDate]           DATETIME         CONSTRAINT [DF_MAS_Service_ReceiveEntry_SysDate] DEFAULT (getdate()) NULL,
    [isExpected]        BIT              CONSTRAINT [DF_MAS_Service_ReceiveEntry_isExpected] DEFAULT ((0)) NULL,
    [isPush]            BIT              NULL,
    [push_dt]           DATETIME         NULL,
    [push_count]        INT              NULL,
    [createId]          NVARCHAR (100)   NULL,
    [updateId]          NVARCHAR (100)   NULL,
    [reminded]          INT              NULL,
    [remind_dt]         DATETIME         NULL,
    [sendDate]          DATETIME         CONSTRAINT [DF_MAS_Service_ReceiveEntry_sendDate] DEFAULT (getdate()) NULL,
    [entryId]           UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Service_ReceiveEntry_entryId] DEFAULT (newid()) NULL,
    [IsDebt]            BIT              NULL,
    [LivingElectricAmt] DECIMAL (18)     NULL,
    [LivingWaterAmt]    DECIMAL (18)     NULL,
    [oid]               UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Service_ReceiveEntry_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]        UNIQUEIDENTIFIER NULL,
    [apartOid]          UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Service_ReceiveEntry] PRIMARY KEY CLUSTERED ([ReceiveId] ASC),
    CONSTRAINT [FK_MAS_Service_ReceiveEntry_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);
















GO
CREATE NONCLUSTERED INDEX [idx_MAS_Service_ReceiveEntry_bill_st]
    ON [dbo].[MAS_Service_ReceiveEntry]([bill_st] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Service_ReceiveEntry_IsBill]
    ON [dbo].[MAS_Service_ReceiveEntry]([IsBill] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Service_ReceiveEntry_isExpected]
    ON [dbo].[MAS_Service_ReceiveEntry]([isExpected] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Service_ReceiveEntry_ApartmentId]
    ON [dbo].[MAS_Service_ReceiveEntry]([ApartmentId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID Kỳ dự thu (dự thu thuộc kỳ nào)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_Service_ReceiveEntry', @level2type = N'COLUMN', @level2name = N'ProjectCd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Thông tin xuất hóa đơn theo dự thu của căn hộ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_Service_ReceiveEntry';

