CREATE TABLE [dbo].[Hrm_Departments] (
    [departmentCd]   NVARCHAR (50)    NOT NULL,
    [departmentName] NVARCHAR (150)   NULL,
    [emailOwn]       NVARCHAR (150)   NULL,
    [emailList]      NVARCHAR (150)   NULL,
    [note]           NVARCHAR (150)   NULL,
    [intOrder]       INT              NULL,
    [parentCd]       NVARCHAR (50)    NULL,
    [userId]         NVARCHAR (50)    NULL,
    [organizationCd] NVARCHAR (20)    NULL,
    [sysDt]          DATETIME         CONSTRAINT [DF_MAS_Departments_sysDt] DEFAULT (getdate()) NULL,
    [oid]            UNIQUEIDENTIFIER CONSTRAINT [DF_Hrm_Departments_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Departments] PRIMARY KEY CLUSTERED ([departmentCd] ASC),
    CONSTRAINT [FK_Hrm_Departments_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE NONCLUSTERED INDEX [idx_MAS_Departments_DepartmentCd]
    ON [dbo].[Hrm_Departments]([departmentCd] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Departments_intOrder]
    ON [dbo].[Hrm_Departments]([intOrder] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Departments_OrganizationCd]
    ON [dbo].[Hrm_Departments]([organizationCd] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Departments_DepartmentName]
    ON [dbo].[Hrm_Departments]([departmentName] ASC);

