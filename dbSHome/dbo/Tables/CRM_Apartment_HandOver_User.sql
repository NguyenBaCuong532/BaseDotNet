CREATE TABLE [dbo].[CRM_Apartment_HandOver_User] (
    [Id]         BIGINT           IDENTITY (1, 1) NOT NULL,
    [UserId]     NVARCHAR (50)    NULL,
    [Type]       INT              NULL,
    [ProjectCd]  NVARCHAR (100)   NULL,
    [SysDate]    DATETIME         CONSTRAINT [DF_CRM_Apartment_HandOver_User_SysDate] DEFAULT (getdate()) NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_Apartment_HandOver_User_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_CRM_Apartment_HandOver_User] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_CRM_Apartment_HandOver_User_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

