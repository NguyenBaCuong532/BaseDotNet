CREATE TABLE [dbo].[MAS_Service_ReceiptAlloc] (
    [AllocId]      BIGINT         IDENTITY (1, 1) NOT NULL,
    [ReceiptId]    INT            NOT NULL,
    [ReceivableId] BIGINT         NOT NULL,
    [AppliedAmt]   DECIMAL (18)   NOT NULL,
    [CreateDate]   DATETIME       DEFAULT (getdate()) NOT NULL,
    [Note]         NVARCHAR (200) NULL,
    PRIMARY KEY CLUSTERED ([AllocId] ASC),
    CONSTRAINT [FK_Alloc_Receipt] FOREIGN KEY ([ReceiptId]) REFERENCES [dbo].[MAS_Service_Receipts] ([ReceiptId]),
    CONSTRAINT [FK_Alloc_Receivable] FOREIGN KEY ([ReceivableId]) REFERENCES [dbo].[MAS_Service_Receivable] ([ReceivableId])
);


GO
CREATE NONCLUSTERED INDEX [IX_Alloc_Receipt]
    ON [dbo].[MAS_Service_ReceiptAlloc]([ReceiptId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Alloc_Receivable]
    ON [dbo].[MAS_Service_ReceiptAlloc]([ReceivableId] ASC);

