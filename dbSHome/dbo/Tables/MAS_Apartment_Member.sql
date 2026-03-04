CREATE TABLE [dbo].[MAS_Apartment_Member] (
    [ApartmentId]    INT              NOT NULL,
    [CustId]         NVARCHAR (50)    NOT NULL,
    [RegDt]          DATETIME         NULL,
    [RelationId]     INT              NULL,
    [memberUserId]   NVARCHAR (100)   NULL,
    [member_st]      INT              NULL,
    [approveBy]      NVARCHAR (100)   NULL,
    [approveDt]      DATETIME         NULL,
    [main_st]        BIT              NULL,
    [isNotification] BIT              NULL,
    [rowguid]        UNIQUEIDENTIFIER CONSTRAINT [MSmerge_df_rowguid_B10CA52231CB47469C798D3ABC3B6798] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [Oid]            UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Apartment_Member_Oid] DEFAULT (newid()) NOT NULL,
    [leaveId]        BIGINT           NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    [apartOid]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Apartment_Member] PRIMARY KEY CLUSTERED ([Oid] ASC),
    CONSTRAINT [FK_MAS_Apartment_Member_apartOid] FOREIGN KEY ([apartOid]) REFERENCES [dbo].[MAS_Apartments] ([oid]),
    CONSTRAINT [FK_MAS_Apartment_Member_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);


















GO
CREATE NONCLUSTERED INDEX [idx_MAS_Apartment_Member_approveBy]
    ON [dbo].[MAS_Apartment_Member]([approveBy] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Apartment_Member_main_st]
    ON [dbo].[MAS_Apartment_Member]([main_st] ASC);


GO



GO
CREATE NONCLUSTERED INDEX [idx_MAS_Apartment_Member_userId]
    ON [dbo].[MAS_Apartment_Member]([memberUserId] ASC);




GO
CREATE NONCLUSTERED INDEX [idx_MAS_Apartment_Member_apartmentId]
    ON [dbo].[MAS_Apartment_Member]([ApartmentId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_MAS_Apartment_Member_CustId_INC_ApartmentId]
    ON [dbo].[MAS_Apartment_Member]([CustId] ASC)
    INCLUDE([ApartmentId]) WITH (DATA_COMPRESSION = ROW);


GO
CREATE NONCLUSTERED INDEX [IX_MAS_Apartment_Member_apartOid]
    ON [dbo].[MAS_Apartment_Member]([apartOid] ASC);

