CREATE TABLE [dbo].[MAS_Service_Receivable] (
    [ReceivableId]  BIGINT           IDENTITY (1, 1) NOT NULL,
    [ReceiveId]     BIGINT           NOT NULL,
    [ServiceTypeId] INT              NULL,
    [ServiceObject] NVARCHAR (100)   NULL,
    [Quantity]      DECIMAL (18, 2)  NULL,
    [Price]         DECIMAL (18)     NULL,
    [Amount]        DECIMAL (18)     NULL,
    [VatAmt]        DECIMAL (18)     NULL,
    [NtshAmt]       DECIMAL (18)     NULL,
    [TotalAmt]      DECIMAL (18)     NULL,
    [fromDt]        DATETIME         NULL,
    [ToDt]          DATETIME         NULL,
    [srcId]         BIGINT           NULL,
    [updateId]      NVARCHAR (100)   NULL,
    [sysDate]       DATETIME         CONSTRAINT [DF_MAS_Service_Receivable_sysDate] DEFAULT (getdate()) NULL,
    [IsPaid]        BIT              NULL,
    [PaymentDate]   DATETIME         NULL,
    [VehicleNum]    INT              NULL,
    [totalDays]     INT              NULL,
    [oid]           UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Service_Receivable_oid] DEFAULT (newid()) NOT NULL,
    [PayAmt]        DECIMAL (18)     NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Service_Receivable] PRIMARY KEY CLUSTERED ([ReceivableId] ASC),
    CONSTRAINT [FK_MAS_Service_Receivable_MAS_Service_ReceiveEntry] FOREIGN KEY ([ReceiveId]) REFERENCES [dbo].[MAS_Service_ReceiveEntry] ([ReceiveId]),
    CONSTRAINT [FK_MAS_Service_Receivable_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);












GO
CREATE NONCLUSTERED INDEX [idx_MAS_Service_Receivable_srcId]
    ON [dbo].[MAS_Service_Receivable]([srcId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Service_Receivable_ServiceTypeId]
    ON [dbo].[MAS_Service_Receivable]([ServiceTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Service_Receivable_ReceiveId]
    ON [dbo].[MAS_Service_Receivable]([ReceiveId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Chi tiết dự thu từng dịch vụ của căn hộ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_Service_Receivable';

