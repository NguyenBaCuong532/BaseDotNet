CREATE TABLE [dbo].[MAS_FirstMonthPaymentMethod] (
    [Code]       NVARCHAR (50)    NOT NULL,
    [Name]       NVARCHAR (200)   NOT NULL,
    [IsActive]   BIT              CONSTRAINT [DF_MAS_FirstMonthPaymentMethod_IsActive] DEFAULT ((1)) NOT NULL,
    [SortOrder]  INT              NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    PRIMARY KEY CLUSTERED ([Code] ASC),
    CONSTRAINT [FK_MAS_FirstMonthPaymentMethod_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

