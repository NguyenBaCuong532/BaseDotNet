CREATE TABLE [dbo].[request_review] (
    [id]         UNIQUEIDENTIFIER CONSTRAINT [DF_request_review_id] DEFAULT (newid()) NOT NULL,
    [src_id]     UNIQUEIDENTIFIER NULL,
    [rating]     INT              NULL,
    [comment]    NVARCHAR (255)   NULL,
    [created_dt] DATETIME         CONSTRAINT [DF_request_review_created_dt] DEFAULT (getdate()) NULL,
    [created_by] UNIQUEIDENTIFIER NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_request_review] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_request_review_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE UNIQUE NONCLUSTERED INDEX [uq_request_review_src_id]
    ON [dbo].[request_review]([src_id] ASC)
    INCLUDE([rating], [comment]);

