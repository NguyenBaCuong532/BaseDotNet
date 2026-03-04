CREATE TABLE [dbo].[CRM_Card] (
    [CardId]      INT              IDENTITY (1, 1) NOT NULL,
    [CardCd]      NVARCHAR (50)    NOT NULL,
    [CustId]      NVARCHAR (100)   NULL,
    [CreatedTime] DATETIME         NULL,
    [CreatedBy]   NCHAR (450)      NULL,
    [UpdatedTime] DATETIME         NULL,
    [UpdatedBy]   NVARCHAR (255)   NULL,
    [ExpireDate]  DATE             NULL,
    [CardTypeId]  INT              NULL,
    [IssueDate]   DATE             NULL,
    [Status]      NVARCHAR (50)    NULL,
    [CardName]    NVARCHAR (255)   NULL,
    [IsVip]       BIT              NULL,
    [oid]         UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_Card_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_CRM_Card_Closeness] PRIMARY KEY CLUSTERED ([CardCd] ASC),
    CONSTRAINT [FK_CRM_Card_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE NONCLUSTERED INDEX [idx_CRM_Card_Status]
    ON [dbo].[CRM_Card]([Status] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_CRM_Card_CardTypeId]
    ON [dbo].[CRM_Card]([CardTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_CRM_Card_CardCd]
    ON [dbo].[CRM_Card]([CardCd] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_CRM_Card_CustId]
    ON [dbo].[CRM_Card]([CustId] ASC);

