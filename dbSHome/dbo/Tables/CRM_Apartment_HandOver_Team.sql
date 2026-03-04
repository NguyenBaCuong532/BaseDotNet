CREATE TABLE [dbo].[CRM_Apartment_HandOver_Team] (
    [HandOverTeamId] BIGINT           IDENTITY (1, 1) NOT NULL,
    [DepartmentCd]   NVARCHAR (50)    NULL,
    [DepartmentName] NVARCHAR (500)   NULL,
    [Type]           INT              NULL,
    [oid]            UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_Apartment_HandOver_Team_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_CRM_Apartment_HandOver_Team] PRIMARY KEY CLUSTERED ([HandOverTeamId] ASC),
    CONSTRAINT [FK_CRM_Apartment_HandOver_Team_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

