CREATE TABLE [dbo].[MAS_Users] (
    [regUserId]        BIGINT           IDENTITY (1, 1) NOT NULL,
    [UserId]           NVARCHAR (450)   NULL,
    [CustId]           NVARCHAR (50)    NULL,
    [AvatarUrl]        NVARCHAR (250)   NULL,
    [UserLogin]        NVARCHAR (50)    NOT NULL,
    [UserPassword]     NVARCHAR (50)    NULL,
    [IsManager]        BIT              NULL,
    [IsLock]           BIT              NULL,
    [StartDt]          DATETIME         NULL,
    [IsClose]          BIT              NULL,
    [CloseDt]          DATETIME         NULL,
    [AppKey]           NVARCHAR (50)    NULL,
    [IsActived]        BIT              NULL,
    [FullName]         NVARCHAR (250)   NULL,
    [Phone]            NVARCHAR (20)    NULL,
    [Email]            NVARCHAR (150)   NULL,
    [IsVerify]         BIT              NULL,
    [LoginType]        INT              NULL,
    [LoginId]          NVARCHAR (100)   NULL,
    [LastDt]           DATETIME         NULL,
    [EmailConfirm]     INT              NULL,
    [IsCreatePassword] BIT              NULL,
    [Is_Agreed_Term]   BIT              NULL,
    [Agreed_Dt]        DATETIME         NULL,
    [userType]         INT              NULL,
    [oid]              UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Users_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Users] PRIMARY KEY CLUSTERED ([regUserId] ASC),
    CONSTRAINT [FK_MAS_Users_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid]),
    CONSTRAINT [Constraint_MAS_Users_UserLogin] UNIQUE NONCLUSTERED ([UserLogin] ASC)
);








GO
CREATE NONCLUSTERED INDEX [idx_MAS_Users_userType]
    ON [dbo].[MAS_Users]([userType] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Users_Phone]
    ON [dbo].[MAS_Users]([Phone] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Users_CustId]
    ON [dbo].[MAS_Users]([CustId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Users_UserLogin]
    ON [dbo].[MAS_Users]([UserLogin] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Users_UserId]
    ON [dbo].[MAS_Users]([UserId] ASC);


GO
CREATE TRIGGER [dbo].[trg_mas_users_CRM_Apartment_HandOver_User] 
   ON  dbo.MAS_Users
   FOR INSERT
AS 
BEGIN
	
	SET NOCOUNT ON;
			if not exists(select a.UserId from CRM_Apartment_HandOver_User a join Inserted b on a.UserId = b.UserId
																		 join MAS_Employees c on a.UserId = c.UserId
					  where c.DepartmentCd in (select DepartmentCd from CRM_Apartment_HandOver_Team) and c.IsLock = 0)
				begin
					insert into CRM_Apartment_HandOver_User(UserId) select UserId from Inserted 
				end

	/* Insert,Update Records */
	

END
GO
DISABLE TRIGGER [dbo].[trg_mas_users_CRM_Apartment_HandOver_User]
    ON [dbo].[MAS_Users];


GO
CREATE NONCLUSTERED INDEX [IX_Users_UserId]
    ON [dbo].[MAS_Users]([UserId] ASC)
    INCLUDE([CustId]);

