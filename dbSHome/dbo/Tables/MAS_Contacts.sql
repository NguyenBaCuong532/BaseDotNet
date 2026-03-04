CREATE TABLE [dbo].[MAS_Contacts] (
    [Cif_No]     NVARCHAR (50)    NOT NULL,
    [CustId]     NVARCHAR (50)    NOT NULL,
    [Phone]      NVARCHAR (50)    NOT NULL,
    [Email]      NVARCHAR (150)   NULL,
    [RegDt]      DATETIME         NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Contacts_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Contacts] PRIMARY KEY CLUSTERED ([Cif_No] ASC),
    CONSTRAINT [FK_MAS_Contacts_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid]),
    CONSTRAINT [Constraint_MAS_Contacts_Phone] UNIQUE NONCLUSTERED ([Phone] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_MAS_Contacts_CustId]
    ON [dbo].[MAS_Contacts]([CustId] ASC)
    INCLUDE([Cif_No]);

