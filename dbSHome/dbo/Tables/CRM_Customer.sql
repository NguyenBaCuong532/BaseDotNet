CREATE TABLE [dbo].[CRM_Customer] (
    [custId]     NVARCHAR (50)    NOT NULL,
    [group_id]   INT              NULL,
    [note]       NVARCHAR (255)   NULL,
    [cust_rank]  TINYINT          NULL,
    [create_by]  NVARCHAR (100)   NULL,
    [create_dt]  DATETIME         NULL,
    [modify_dt]  DATETIME         NULL,
    [clientId]   NVARCHAR (50)    NULL,
    [categoryCd] NVARCHAR (50)    NULL,
    [base_type]  INT              NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_Customer_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_CRM_Customer] PRIMARY KEY CLUSTERED ([custId] ASC),
    CONSTRAINT [FK_CRM_Customer_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE NONCLUSTERED INDEX [idx_CRM_Customer_clientId]
    ON [dbo].[CRM_Customer]([clientId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_CRM_Customer_group_id]
    ON [dbo].[CRM_Customer]([group_id] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_CRM_Customer_custId]
    ON [dbo].[CRM_Customer]([custId] ASC);

