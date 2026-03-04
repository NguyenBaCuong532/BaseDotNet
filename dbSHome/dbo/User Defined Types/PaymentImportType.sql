CREATE TYPE [dbo].[PaymentImportType] AS TABLE (
    [RoomCode]       NVARCHAR (100) NULL,
    [InvoiceCode]    NVARCHAR (100) NULL,
    [EndDate]        NVARCHAR (50)  NULL,
    [PaymentSection] NVARCHAR (200) NULL,
    [PaymentAmount]  NVARCHAR (50)  NULL,
    [PaymentContent] NVARCHAR (500) NULL,
    [PaymentDate]    NVARCHAR (50)  NULL,
    [Target]         NVARCHAR (200) NULL);

