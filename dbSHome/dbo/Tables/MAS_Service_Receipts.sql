CREATE TABLE [dbo].[MAS_Service_Receipts] (
    [ReceiptId]          INT              IDENTITY (1, 1) NOT NULL,
    [ReceiptNo]          NVARCHAR (20)    NULL,
    [ReceiptDt]          DATETIME         NULL,
    [CustId]             NVARCHAR (50)    NULL,
    [ApartmentId]        BIGINT           NULL,
    [ReceiveId]          BIGINT           NULL,
    [TranferCd]          NVARCHAR (200)   NULL,
    [Object]             NVARCHAR (200)   NULL,
    [Pass_No]            NVARCHAR (50)    NULL,
    [Pass_dt]            DATETIME         NULL,
    [Pass_Plc]           NVARCHAR (200)   NULL,
    [Address]            NVARCHAR (200)   NULL,
    [Contents]           NVARCHAR (300)   NULL,
    [Attach]             NVARCHAR (30)    NULL,
    [IsDBCR]             BIT              NULL,
    [Amount]             DECIMAL (18)     NULL,
    [CreatorCd]          NVARCHAR (50)    NULL,
    [CreateDate]         DATETIME         NULL,
    [AccountLeft]        NVARCHAR (20)    NULL,
    [AccountRight]       NVARCHAR (20)    NULL,
    [ProjectCd]          NVARCHAR (30)    NULL,
    [ReceiptBillUrl]     NVARCHAR (350)   NULL,
    [ReceiptBillViewUrl] NVARCHAR (350)   NULL,
    [AmtSubtractPoint]   DECIMAL (18)     NULL,
    [Ref_No]             NVARCHAR (50)    NULL,
    [RefundAmt]          DECIMAL (18)     NULL,
    [id]                 UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Service_Receipts_id] DEFAULT (newid()) NOT NULL,
    [PaymentSection]     NVARCHAR (200)   NULL,
    [tenant_oid]         UNIQUEIDENTIFIER NULL,
    [apartOid]           UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Service_Receipts] PRIMARY KEY CLUSTERED ([ReceiptId] ASC),
    CONSTRAINT [FK_MAS_Service_Receipts_apartOid] FOREIGN KEY ([apartOid]) REFERENCES [dbo].[MAS_Apartments] ([oid]),
    CONSTRAINT [FK_MAS_Service_Receipts_MAS_Service_ReceiveEntry] FOREIGN KEY ([ReceiveId]) REFERENCES [dbo].[MAS_Service_ReceiveEntry] ([ReceiveId]),
    CONSTRAINT [FK_MAS_Service_Receipts_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);










GO
CREATE NONCLUSTERED INDEX [Index_ReceiveId]
    ON [dbo].[MAS_Service_Receipts]([ReceiveId] ASC);

