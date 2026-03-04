CREATE TABLE [dbo].[MAS_Customer_Household] (
    [ApartmentId] INT              NOT NULL,
    [CustId]      NVARCHAR (50)    NOT NULL,
    [IsResident]  BIT              NULL,
    [ResAdd1]     NVARCHAR (250)   NULL,
    [ContactAdd1] NVARCHAR (250)   NULL,
    [Pass_No]     NVARCHAR (50)    NULL,
    [Pass_I_Dt]   DATE             NULL,
    [Pass_I_Plc]  NVARCHAR (250)   NULL,
    [City]        NVARCHAR (100)   NULL,
    [RelationId]  INT              NULL,
    [sysDate]     DATETIME         NULL,
    [oid]         UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Customer_Household_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]  UNIQUEIDENTIFIER NULL,
    [apartOid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_CusHousehold] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_MAS_Customer_Household_apartOid] FOREIGN KEY ([apartOid]) REFERENCES [dbo].[MAS_Apartments] ([oid]),
    CONSTRAINT [FK_MAS_Customer_Household_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);










GO
CREATE NONCLUSTERED INDEX [IDX_MAS_Customer_Household_CustId]
    ON [dbo].[MAS_Customer_Household]([CustId] ASC);

