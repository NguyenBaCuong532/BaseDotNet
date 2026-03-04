CREATE TABLE [dbo].[CRM_SharingNotes] (
    [NoteId]     VARCHAR (150)    NOT NULL,
    [UserId]     VARCHAR (150)    NOT NULL,
    [Status]     NVARCHAR (50)    NOT NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_CRM_SharingNotes_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_CRM_SharingNotes_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

