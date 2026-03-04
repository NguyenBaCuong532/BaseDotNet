CREATE TABLE [dbo].[PAR_BlockLiving] (
    [BlockLivingId] INT              IDENTITY (1, 1) NOT NULL,
    [ServiceId]     INT              NULL,
    [Pos]           INT              NULL,
    [Block]         INT              NULL,
    [Price]         DECIMAL (18)     NULL,
    [Price1]        DECIMAL (18)     NULL,
    [IsFree]        BIT              NULL,
    [oid]           UNIQUEIDENTIFIER CONSTRAINT [DF_PAR_BlockLiving_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_PAR_BlockLiving] PRIMARY KEY CLUSTERED ([BlockLivingId] ASC),
    CONSTRAINT [FK_PAR_BlockLiving_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

