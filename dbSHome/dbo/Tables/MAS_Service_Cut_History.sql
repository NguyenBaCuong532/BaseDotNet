CREATE TABLE [dbo].[MAS_Service_Cut_History] (
    [Id]           UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Service_Cut_History_Id] DEFAULT (newid()) NOT NULL,
    [ApartmentId]  INT              NULL,
    [CutType]      INT              CONSTRAINT [DF_MAS_Apartment_Service_Cust_History_cut_type] DEFAULT ((0)) NULL,
    [CutStartDate] DATETIME         NULL,
    [CutEndDate]   DATETIME         NULL,
    [Reason]       NVARCHAR (1000)  NULL,
    [SysDate]      DATE             CONSTRAINT [DF_MAS_Service_Cut_History_SysDate] DEFAULT (getdate()) NULL,
    [tenant_oid]   UNIQUEIDENTIFIER NULL,
    [apartOid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Service_Cut_History] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_MAS_Service_Cut_History_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);








GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0: electric, 1: water', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_Service_Cut_History', @level2type = N'COLUMN', @level2name = N'CutType';

