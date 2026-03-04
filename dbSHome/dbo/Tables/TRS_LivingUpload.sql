CREATE TABLE [dbo].[TRS_LivingUpload] (
    [LivingUploadId] INT              IDENTITY (1, 1) NOT NULL,
    [ProjectCd]      NVARCHAR (30)    NULL,
    [FileName]       NVARCHAR (100)   NOT NULL,
    [Description]    NVARCHAR (100)   NULL,
    [PeriodMonth]    INT              NOT NULL,
    [PeriodYear]     INT              NOT NULL,
    [ServiceTypeId]  INT              NOT NULL,
    [FileUrl]        NVARCHAR (300)   NULL,
    [UploadDate]     DATETIME         NULL,
    [Status]         SMALLINT         NULL,
    [oid]            UNIQUEIDENTIFIER CONSTRAINT [DF_TRS_LivingUpload_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_TRS_LivingUpload] PRIMARY KEY CLUSTERED ([LivingUploadId] ASC),
    CONSTRAINT [FK_TRS_LivingUpload_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

