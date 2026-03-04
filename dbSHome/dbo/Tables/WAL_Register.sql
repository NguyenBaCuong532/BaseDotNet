CREATE TABLE [dbo].[WAL_Register] (
    [UserLogin]  NVARCHAR (50)    NOT NULL,
    [Password]   NVARCHAR (50)    NOT NULL,
    [Phone]      NVARCHAR (50)    NULL,
    [Email]      NVARCHAR (120)   NULL,
    [CreateDt]   DATETIME         NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_WAL_Register_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_WAL_Register] PRIMARY KEY CLUSTERED ([UserLogin] ASC),
    CONSTRAINT [FK_WAL_Register_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

