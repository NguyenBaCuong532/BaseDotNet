CREATE TABLE [dbo].[NotifyRef] (
    [source_ref]   UNIQUEIDENTIFIER CONSTRAINT [DF__NotifyRef__source__0BD1B136] DEFAULT (newid()) NOT NULL,
    [external_key] NVARCHAR (50)    NOT NULL,
    [refKey]       NVARCHAR (50)    NOT NULL,
    [refName]      NVARCHAR (200)   NOT NULL,
    [ref_st]       INT              NOT NULL,
    [created_dt]   DATETIME         CONSTRAINT [DF_NotifyRef_created_dt] DEFAULT (getdate()) NULL,
    [created_by]   NVARCHAR (100)   NULL,
    [refIcon]      NVARCHAR (350)   NULL,
    [tenant_oid]   UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_NotifyRef] PRIMARY KEY CLUSTERED ([source_ref] ASC),
    CONSTRAINT [FK_NotifyRef_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

