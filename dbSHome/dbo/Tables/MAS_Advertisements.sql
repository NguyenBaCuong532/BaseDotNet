CREATE TABLE [dbo].[advertisement_info](
	[id] [uniqueidentifier] NOT NULL
		CONSTRAINT [pk_advertisement_info] PRIMARY KEY DEFAULT NEWID(),

	[title] [nvarchar](200) NOT NULL,
	[description] [nvarchar](500) NULL,
	[image_url] [nvarchar](500) NOT NULL,
	[link_url] [nvarchar](500) NULL,
	[position] [int] NOT NULL DEFAULT(1),
	[priority] [int] NOT NULL DEFAULT(1),
	[start_date] [datetime] NOT NULL,
	[end_date] [datetime] NOT NULL,
	[is_active] [bit] NOT NULL DEFAULT(1),
	[company_name] [nvarchar](200) NULL,
	[company_contact] [nvarchar](100) NULL,
	[company_phone] [nvarchar](20) NULL,
	[company_email] [nvarchar](100) NULL,
	[click_count] [int] NOT NULL DEFAULT(0),
	[view_count] [int] NOT NULL DEFAULT(0),
	[is_deleted] [bit] NOT NULL DEFAULT(0),

	[app_st] [int] NOT NULL CONSTRAINT [df_advertisement_info_app_st] DEFAULT(0),
	[created_dt] [datetime] NOT NULL DEFAULT GETUTCDATE(),
	[created_by] [uniqueidentifier] NOT NULL,
	[updated_dt] [datetime] NULL,
	[updated_by] [uniqueidentifier] NULL
) ON [PRIMARY]
GO