CREATE TABLE [dbo].[MAS_Customer_Image] (
    [ImageId]    INT              IDENTITY (1, 1) NOT NULL,
    [FaceId]     NVARCHAR (200)   NULL,
    [CustId]     NVARCHAR (50)    NOT NULL,
    [ImageUrl]   NVARCHAR (350)   NULL,
    [ImageType]  INT              NULL,
    [ImageNote]  NVARCHAR (50)    NULL,
    [IsFace]     BIT              NULL,
    [sysDate]    DATETIME         NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Customer_Image_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Customer_Image] PRIMARY KEY CLUSTERED ([ImageId] ASC),
    CONSTRAINT [FK_MAS_Customer_Image_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

