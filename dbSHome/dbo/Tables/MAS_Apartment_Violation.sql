CREATE TABLE [dbo].[MAS_Apartment_Violation] (
    [Id]            UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Apartment_Violation_Id] DEFAULT (newid()) NOT NULL,
    [ApartmentId]   INT              NULL,
    [Content]       NVARCHAR (2000)  NULL,
    [AttackFile]    NVARCHAR (1000)  NULL,
    [ViolationDate] DATETIME         NULL,
    [RegDt]         DATETIME         NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    [apartOid]      UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Apartment_Violation] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_MAS_Apartment_Violation_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

