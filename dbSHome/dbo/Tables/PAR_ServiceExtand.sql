CREATE TABLE [dbo].[PAR_ServiceExtand] (
    [ServiceExtandId] INT              IDENTITY (1, 1) NOT NULL,
    [ServiceId]       INT              NULL,
    [Amount]          DECIMAL (18)     NULL,
    [IsFree]          BIT              NULL,
    [CalculateType]   INT              NULL,
    [oid]             UNIQUEIDENTIFIER CONSTRAINT [DF_PAR_ServiceExtand_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]      UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_PAR_ServiceExtand] PRIMARY KEY CLUSTERED ([ServiceExtandId] ASC),
    CONSTRAINT [FK_PAR_ServiceExtand_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

