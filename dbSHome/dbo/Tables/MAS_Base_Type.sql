CREATE TABLE [dbo].[MAS_Base_Type] (
    [base_type]  INT              NOT NULL,
    [base_name]  NVARCHAR (100)   NOT NULL,
    [base_desc]  NVARCHAR (200)   NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Base_Type_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_CRM_Base_Type] PRIMARY KEY CLUSTERED ([base_type] ASC),
    CONSTRAINT [FK_MAS_Base_Type_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

