CREATE TABLE [dbo].[CRM_Apartment_HandOver_CheckList] (
    [CheckListId]      BIGINT           IDENTITY (1, 1) NOT NULL,
    [Item]             NVARCHAR (100)   NULL,
    [Note]             NVARCHAR (500)   NULL,
    [Manufactor]       NVARCHAR (100)   NULL,
    [ParentId]         BIGINT           NULL,
    [ProjectCd]        NVARCHAR (50)    NULL,
    [HandOverDetailId] BIGINT           NULL,
    [IsDuLieuMau]      BIT              NULL,
    [SapXep]           INT              NULL,
    [Chon]             BIT              NULL,
    [Created]          DATETIME         NULL,
    [CreatedBy]        NVARCHAR (50)    NULL,
    [Modified]         DATETIME         NULL,
    [ModifiedBy]       NVARCHAR (50)    NULL,
    [oid]              UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_Apartment_HandOver_CheckList_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_CRM_Apartment_HandOver_CheckList] PRIMARY KEY CLUSTERED ([CheckListId] ASC),
    CONSTRAINT [FK_CRM_Apartment_HandOver_CheckList_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

