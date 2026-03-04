CREATE TABLE [dbo].[MAS_Apartment_Member_H] (
    [Id]             BIGINT         IDENTITY (1, 1) NOT NULL,
    [ApartmentId]    INT            NOT NULL,
    [CustId]         NVARCHAR (50)  NOT NULL,
    [FullName]       NVARCHAR (200) NULL,
    [Phone]          NVARCHAR (50)  NULL,
    [Birthday]       DATE           NULL,
    [Email]          NVARCHAR (150) NULL,
    [Gender]         TINYINT        NULL,
    [RelationId]     INT            NULL,
    [IsOwner]        BIT            DEFAULT ((0)) NOT NULL,
    [IsForeigner]    BIT            NULL,
    [Nationality]    NVARCHAR (100) NULL,
    [IsNotification] BIT            NULL,
    [EffectiveDate]  DATE           NOT NULL,
    [ExpiredDate]    DATE           NULL,
    [ActionType]     NVARCHAR (50)  NULL,
    [Note]           NVARCHAR (500) NULL,
    [CreatedBy]      NVARCHAR (50)  NULL,
    [CreatedDate]    DATETIME       DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

