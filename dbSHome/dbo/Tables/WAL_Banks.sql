CREATE TABLE [dbo].[WAL_Banks] (
    [SourceCd]   NVARCHAR (20)    NOT NULL,
    [ShortName]  NVARCHAR (100)   NOT NULL,
    [SourceName] NVARCHAR (200)   NOT NULL,
    [LogoUrl]    NVARCHAR (250)   NULL,
    [IsBank]     BIT              NULL,
    [isIntCard]  BIT              NULL,
    [Brand]      NVARCHAR (50)    NULL,
    [SysDate]    DATETIME         CONSTRAINT [DF_MAS_Banks_SysDate] DEFAULT (getdate()) NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_WAL_Banks_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Banks] PRIMARY KEY CLUSTERED ([SourceCd] ASC),
    CONSTRAINT [FK_WAL_Banks_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);




GO
CREATE NONCLUSTERED INDEX [IX_WAL_Banks_SourceCd]
    ON [dbo].[WAL_Banks]([SourceCd] ASC)
    INCLUDE([ShortName], [SourceName], [LogoUrl]);

