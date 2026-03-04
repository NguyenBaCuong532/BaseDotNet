CREATE TABLE [dbo].[LogMasVehicle] (
    [CardVehicleId] BIGINT           NULL,
    [SysDt]         DATETIME         CONSTRAINT [DF_LogMasVehicle_SysDt] DEFAULT (getdate()) NULL,
    [Status]        INT              NULL,
    [CardId]        BIGINT           NULL,
    [CreatedBy]     NVARCHAR (50)    NULL,
    [oid]           UNIQUEIDENTIFIER CONSTRAINT [DF_LogMasVehicle_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    [cardOid]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_LogMasVehicle_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

