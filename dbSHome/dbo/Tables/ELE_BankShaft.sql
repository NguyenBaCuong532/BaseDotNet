CREATE TABLE [dbo].[ELE_BankShaft] (
    [Id]                  INT              IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ElevatorBank]        INT              NULL,
    [ElevatorShaftName]   NVARCHAR (50)    NULL,
    [ElevatorShaftNumber] INT              NULL,
    [ProjectCd]           NVARCHAR (50)    NULL,
    [BuildZone]           NVARCHAR (50)    NULL,
    [created_at]          DATETIME         NULL,
    [created_by]          NVARCHAR (255)   NULL,
    [oid]                 UNIQUEIDENTIFIER CONSTRAINT [DF_ELE_BankShaft_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]          UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_ELE_BankShaft] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_ELE_BankShaft_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE NONCLUSTERED INDEX [idx_ELE_BankShaft_ProjectCd]
    ON [dbo].[ELE_BankShaft]([ProjectCd] ASC);

