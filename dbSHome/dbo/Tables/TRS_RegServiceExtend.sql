CREATE TABLE [dbo].[TRS_RegServiceExtend] (
    [Id]         INT              IDENTITY (1, 1) NOT NULL,
    [CardId]     INT              NULL,
    [ServiceId]  INT              NOT NULL,
    [RegDt]      DATETIME         NULL,
    [ExpireDt]   DATETIME         NULL,
    [Amount]     FLOAT (53)       NULL,
    [IsFree]     BIT              NULL,
    [Status]     INT              NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_TRS_RegServiceExtend_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    [cardOid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_TRS_RegService] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_TRS_RegServiceExtend_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

