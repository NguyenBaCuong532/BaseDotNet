CREATE TABLE [dbo].[MAS_Buildings] (
    [Id]           INT              NOT NULL,
    [BuildingCd]   NVARCHAR (50)    NOT NULL,
    [ProjectCd]    NVARCHAR (20)    NOT NULL,
    [BuildingName] NVARCHAR (50)    NULL,
    [ProjectName]  NVARCHAR (150)   NULL,
    [intOrder]     INT              NULL,
    [rowguid]      UNIQUEIDENTIFIER CONSTRAINT [MSmerge_df_rowguid_46E2E347ABFD4CC6A6F7A9CFC75A0CBC] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [created_at]   DATETIME         NULL,
    [created_by]   UNIQUEIDENTIFIER NULL,
    [oid]          UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Buildings_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]   UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Buildings] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_MAS_Buildings_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);










GO
CREATE NONCLUSTERED INDEX [idx_MAS_Buildings_ProjectCd]
    ON [dbo].[MAS_Buildings]([ProjectCd] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_MAS_Buildings_BuildingCd]
    ON [dbo].[MAS_Buildings]([BuildingCd] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Buildings_Building]
    ON [dbo].[MAS_Buildings]([BuildingCd] ASC, [ProjectCd] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_MAS_Buildings_BuildingCd]
    ON [dbo].[MAS_Buildings]([BuildingCd] ASC)
    INCLUDE([ProjectName], [ProjectCd]);

