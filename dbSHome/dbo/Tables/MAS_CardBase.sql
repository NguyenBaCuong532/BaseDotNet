CREATE TABLE [dbo].[MAS_CardBase] (
    [Guid_Cd]        UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_CardBase_Guid_Cd] DEFAULT (newid()) NOT NULL,
    [Card_Num]       NVARCHAR (20)    NOT NULL,
    [Card_Hex]       NVARCHAR (50)    NULL,
    [Code]           NVARCHAR (20)    NOT NULL,
    [IsUsed]         BIT              NULL,
    [SysDate]        DATETIME         CONSTRAINT [DF_MAS_CardBase_SysDate] DEFAULT (getdate()) NOT NULL,
    [ProjectCode]    NVARCHAR (50)    NULL,
    [SubProjectCode] NVARCHAR (50)    NULL,
    [Type]           INT              NULL,
    [rowguid]        UNIQUEIDENTIFIER CONSTRAINT [MSmerge_df_rowguid_FDAA7E17EC7B48DBB82375D71F4094B1] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [LotNumber]      NVARCHAR (50)    NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_CardBase] PRIMARY KEY CLUSTERED ([Card_Num] ASC),
    CONSTRAINT [FK_MAS_CardBase_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid]),
    CONSTRAINT [Constraint_CardBase_Code] UNIQUE NONCLUSTERED ([Code] ASC)
);














GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardBase_IsUsed]
    ON [dbo].[MAS_CardBase]([IsUsed] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_MAS_CardBase_ProjectCode_Code_INCL]
    ON [dbo].[MAS_CardBase]([ProjectCode] ASC, [Code] ASC)
    INCLUDE([Guid_Cd], [Card_Num], [Card_Hex], [IsUsed], [SysDate]);




GO
CREATE NONCLUSTERED INDEX [IX_CardBase_Code]
    ON [dbo].[MAS_CardBase]([Code] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_MAS_CardBase_Card_Num]
    ON [dbo].[MAS_CardBase]([Card_Num] ASC);

