CREATE TABLE [dbo].[NotifyFormula] (
    [formulaId]  UNIQUEIDENTIFIER CONSTRAINT [DF_NotifyFormula_formulaId] DEFAULT (newid()) NOT NULL,
    [name]       NVARCHAR (200)   NOT NULL,
    [note]       NVARCHAR (500)   NULL,
    [formula]    NVARCHAR (MAX)   NOT NULL,
    [to_type]    INT              NULL,
    [table_name] NVARCHAR (100)   NULL,
    [app_st]     INT              CONSTRAINT [DF_NotifyFormula_app_st] DEFAULT ((1)) NULL,
    [created_by] UNIQUEIDENTIFIER NULL,
    [created_at] DATETIME         CONSTRAINT [DF_NotifyFormula_created_at] DEFAULT (getdate()) NOT NULL,
    [updated_by] UNIQUEIDENTIFIER NULL,
    [updated_at] DATETIME         NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_NotifyFormula] PRIMARY KEY CLUSTERED ([formulaId] ASC),
    CONSTRAINT [FK_NotifyFormula_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

