CREATE TABLE [dbo].[MAS_Customer_Relation] (
    [RelationId]   INT              NOT NULL,
    [RelationName] NVARCHAR (100)   NOT NULL,
    [oid]          UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Customer_Relation_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]   UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_CusRelation] PRIMARY KEY CLUSTERED ([RelationId] ASC),
    CONSTRAINT [FK_MAS_Customer_Relation_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE NONCLUSTERED INDEX [IDX_MAS_Customer_Relation_RelationId]
    ON [dbo].[MAS_Customer_Relation]([RelationId] ASC);

