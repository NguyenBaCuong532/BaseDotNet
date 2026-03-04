CREATE TABLE [dbo].[MAS_Service_Living_CalSheet] (
    [Id]         INT              IDENTITY (1, 1) NOT NULL,
    [TrackingId] INT              NOT NULL,
    [StepPos]    INT              NULL,
    [fromN]      INT              NOT NULL,
    [toN]        INT              NULL,
    [Quantity]   INT              NOT NULL,
    [Price]      INT              NOT NULL,
    [Amount]     DECIMAL (18)     NOT NULL,
    [FreeAmt]    DECIMAL (18)     NULL,
    [Calculate]  BIGINT           NULL,
    [VatAmt]     DECIMAL (18, 2)  NULL,
    [from_dt]    DATE             NULL,
    [to_dt]      DATE             NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Service_Living_CalSheet_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Service_Living_CalSheet] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_MAS_Service_Living_CalSheet_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);








GO
CREATE NONCLUSTERED INDEX [IX_CalSheet_TrackingId_StepPos]
    ON [dbo].[MAS_Service_Living_CalSheet]([TrackingId] ASC, [StepPos] ASC);

