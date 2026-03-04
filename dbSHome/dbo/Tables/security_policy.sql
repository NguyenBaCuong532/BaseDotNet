CREATE TABLE [dbo].[security_policy] (
    [Oid]        UNIQUEIDENTIFIER NOT NULL,
    [code]       NVARCHAR (50)    NULL,
    [name]       NVARCHAR (100)   NULL,
    [content]    NVARCHAR (MAX)   NULL,
    [created]    DATETIME         NULL,
    [created_by] NVARCHAR (50)    NULL,
    CONSTRAINT [PK_security_policy] PRIMARY KEY CLUSTERED ([Oid] ASC)
);

