CREATE TABLE [dbo].[mas_employee] (
    [empId]            UNIQUEIDENTIFIER NOT NULL,
    [code]             NVARCHAR (20)    NULL,
    [custId]           NVARCHAR (50)    NOT NULL,
    [userId]           NVARCHAR (100)   NULL,
    [fullName]         NVARCHAR (250)   NULL,
    [email]            NVARCHAR (250)   NULL,
    [phone]            NVARCHAR (50)    NULL,
    [idcard_no]        NVARCHAR (20)    NULL,
    [departmentName]   NVARCHAR (200)   NULL,
    [orgName]          NVARCHAR (200)   NULL,
    [companyName]      NVARCHAR (200)   NULL,
    [positionTypeName] NVARCHAR (200)   NULL,
    [created_at]       DATETIME         NULL,
    [updated_at]       DATETIME         NULL,
    [emp_st]           BIT              NULL,
    [oid]              UNIQUEIDENTIFIER CONSTRAINT [DF_mas_employee_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_mas_employee_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

