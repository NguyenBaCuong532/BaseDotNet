CREATE TABLE [dbo].[Parcel] (
    [oid]              UNIQUEIDENTIFIER CONSTRAINT [DF_Parcel_oid] DEFAULT (newid()) NOT NULL,
    [apartment_id]     INT              NOT NULL,
    [parcel_code]      NVARCHAR (50)    NULL,
    [parcel_type]      NVARCHAR (50)    NULL,
    [sender_name]      NVARCHAR (200)   NULL,
    [recipient_name]   NVARCHAR (200)   NULL,
    [recipient_phone]  NVARCHAR (50)    NULL,
    [description]      NVARCHAR (500)   NULL,
    [note]             NVARCHAR (500)   NULL,
    [status]           INT              CONSTRAINT [DF_Parcel_status] DEFAULT ((0)) NOT NULL,
    [received_by]      NVARCHAR (200)   NULL,
    [received_date]    DATETIME         NULL,
    [received_note]    NVARCHAR (500)   NULL,
    [return_reason]    NVARCHAR (500)   NULL,
    [return_date]      DATETIME         NULL,
    [storage_location] NVARCHAR (200)   NULL,
    [create_by]        NVARCHAR (100)   NULL,
    [create_at]        DATETIME         CONSTRAINT [DF_Parcel_create_at] DEFAULT (getdate()) NULL,
    [updated_by]       NVARCHAR (100)   NULL,
    [updated_at]       DATETIME         NULL,
    [weight]           DECIMAL (10, 2)  NULL,
    [tracking_code]    NVARCHAR (100)   NULL,
    [receive_method]   INT              DEFAULT ((0)) NULL,
    [images]           NVARCHAR (MAX)   NULL,
    [tenant_oid]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_Parcel] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_Parcel_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);


GO
CREATE NONCLUSTERED INDEX [IX_Parcel_apartment_id]
    ON [dbo].[Parcel]([apartment_id] ASC);

