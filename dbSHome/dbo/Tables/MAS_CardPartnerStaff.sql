CREATE TABLE [dbo].[MAS_CardPartnerStaff] (
    [StaffId]    BIGINT           IDENTITY (1, 1) NOT NULL,
    [ProjectCd]  NVARCHAR (40)    NOT NULL,
    [PartnerId]  BIGINT           NOT NULL,
    [StaffCode]  NVARCHAR (20)    NOT NULL,
    [FullName]   NVARCHAR (255)   NOT NULL,
    [Department] NVARCHAR (255)   NULL,
    [JobTitle]   NVARCHAR (255)   NULL,
    [StaffType]  INT              NOT NULL,
    [Phone]      NVARCHAR (20)    NOT NULL,
    [IdNo]       NVARCHAR (20)    NULL,
    [CardCode]   NVARCHAR (50)    NULL,
    [Status]     INT              NOT NULL,
    [Create_dt]  DATETIME         CONSTRAINT [DF_MAS_CardPartnerStaff_CreateDt] DEFAULT (getdate()) NOT NULL,
    [Create_by]  UNIQUEIDENTIFIER NULL,
    [Update_dt]  DATETIME         NULL,
    [Update_by]  UNIQUEIDENTIFIER NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    PRIMARY KEY CLUSTERED ([StaffId] ASC),
    CONSTRAINT [FK_MAS_CardPartnerStaff_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);


GO
CREATE NONCLUSTERED INDEX [IX_MAS_CardPartnerStaff_Search]
    ON [dbo].[MAS_CardPartnerStaff]([ProjectCd] ASC, [PartnerId] ASC, [Status] ASC, [StaffType] ASC, [FullName] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_MAS_CardPartnerStaff]
    ON [dbo].[MAS_CardPartnerStaff]([ProjectCd] ASC, [PartnerId] ASC, [StaffCode] ASC);

