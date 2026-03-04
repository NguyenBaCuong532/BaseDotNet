CREATE TABLE [dbo].[advertisement_analytics](
	[id] [uniqueidentifier] NOT NULL
		CONSTRAINT [pk_advertisement_analytics] PRIMARY KEY DEFAULT NEWID(),

	[advertisement_id] [uniqueidentifier] NOT NULL,
	[customer_id] [uniqueidentifier] NULL,
	[session_id] [nvarchar](100) NULL,
	[action] [nvarchar](20) NOT NULL, -- 'View', 'Click'
	[ip_address] [nvarchar](50) NULL,
	[user_agent] [nvarchar](500) NULL,
	[device_type] [nvarchar](50) NULL, -- 'Mobile', 'Desktop', 'Tablet'
	[platform] [nvarchar](50) NULL, -- 'iOS', 'Android', 'Web'
	[apartment_id] [uniqueidentifier] NULL,
	[building_id] [uniqueidentifier] NULL,

	[app_st] [int] NOT NULL CONSTRAINT [df_advertisement_analytics_app_st] DEFAULT(0),
	[created_dt] [datetime] NOT NULL DEFAULT GETUTCDATE(),
	[created_by] [uniqueidentifier] NOT NULL,
	[updated_dt] [datetime] NULL,
	[updated_by] [uniqueidentifier] NULL,

	CONSTRAINT [fk_advertisement_analytics__advertisement_info]
		FOREIGN KEY ([advertisement_id]) REFERENCES [advertisement_info]([id])
) ON [PRIMARY]
GO

-- Create indexes for better performance
CREATE INDEX [ix_advertisement_analytics__advertisement_id] ON [dbo].[advertisement_analytics]
(
	[advertisement_id] ASC
)
GO

CREATE INDEX [ix_advertisement_analytics__created_dt] ON [dbo].[advertisement_analytics]
(
	[created_dt] ASC
)
GO

CREATE INDEX [ix_advertisement_analytics__customer_id] ON [dbo].[advertisement_analytics]
(
	[customer_id] ASC
)
GO