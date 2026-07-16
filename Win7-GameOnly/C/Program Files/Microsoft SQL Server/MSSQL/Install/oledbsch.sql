/*
** Copyright Microsoft, Inc. 1994 - 2000
** All Rights Reserved.
*/
--------------------------------------------
-- OLEDBSCH.SQL: CREATE OLE-DB SYSTEM VIEWS
--------------------------------------------

-- THESE ARE "SYSTEM" OBJECTS --
exec sp_configure 'allow', 1
reconfigure with override
go
exec sp_MS_upd_sysobj_category 1
go

raiserror(15339,-1,-1,'SYSREMOTE_* System Views')
go

-- Tables "exist" in master
use master
go


if object_id('SYSREMOTE_CATALOGS') is not null
    drop table SYSREMOTE_CATALOGS
go
create table SYSREMOTE_CATALOGS (
    CATALOG_NAME					nvarchar(128) NULL,	-- DBTYPE_WSTR
    DESCRIPTION						nvarchar(4000) NULL	-- DBTYPE_WSTR
    )
go


if object_id('SYSREMOTE_SCHEMATA') is not null
    drop table SYSREMOTE_SCHEMATA
go
create table SYSREMOTE_SCHEMATA (
	CATALOG_NAME					nvarchar(128) NULL,	-- DBTYPE_WSTR
	SCHEMA_NAME						nvarchar(128) NULL,	-- DBTYPE_WSTR
	SCHEMA_OWNER					nvarchar(128) NULL,	-- DBTYPE_WSTR
	DEFAULT_CHARACTER_SET_CATALOG	nvarchar(128) NULL,	-- DBTYPE_WSTR
	DEFAULT_CHARACTER_SET_SCHEMA	nvarchar(128) NULL,	-- DBTYPE_WSTR
	DEFAULT_CHARACTER_SET_NAME		nvarchar(128) NULL	-- DBTYPE_WSTR
	)
go


if object_id('SYSREMOTE_TABLES') is not null
    drop table SYSREMOTE_TABLES
go
create table SYSREMOTE_TABLES (
	TABLE_CATALOG					nvarchar(128) NULL,	-- DBTYPE_WSTR
	TABLE_SCHEMA					nvarchar(128) NULL,	-- DBTYPE_WSTR
	TABLE_NAME						nvarchar(128) NULL,	-- DBTYPE_WSTR
	TABLE_TYPE						nvarchar(128) NULL,	-- DBTYPE_WSTR
	TABLE_GUID						uniqueidentifier NULL,	-- DBTYPE_GUID
	DESCRIPTION						nvarchar(4000) NULL	-- DBTYPE_WSTR
	)
go

if object_id('SYSREMOTE_VIEWS') is not null
    drop table SYSREMOTE_VIEWS
go
create table SYSREMOTE_VIEWS (
	TABLE_CATALOG					nvarchar(128) NULL,	-- DBTYPE_WSTR
	TABLE_SCHEMA					nvarchar(128) NULL,	-- DBTYPE_WSTR
	TABLE_NAME						nvarchar(128) NULL,	-- DBTYPE_WSTR
	VIEW_DEFINITION					nvarchar(4000) NULL,	-- DBTYPE_WSTR
	CHECK_OPTION					bit NULL,			-- DBTYPE_BOOL
	IS_UPDATABLE					bit NULL,			-- DBTYPE_BOOL
	DESCRIPTION						nvarchar(4000) NULL 	-- DBTYPE_WSTR
	)
go

if object_id('SYSREMOTE_COLUMNS') is not null
    drop table SYSREMOTE_COLUMNS
go
create table SYSREMOTE_COLUMNS (
	TABLE_CATALOG					nvarchar(128) NULL,	-- DBTYPE_WSTR
	TABLE_SCHEMA					nvarchar(128) NULL,	-- DBTYPE_WSTR
	TABLE_NAME						nvarchar(128) NULL,	-- DBTYPE_WSTR
	COLUMN_NAME						nvarchar(128) NULL,	-- DBTYPE_WSTR
	COLUMN_GUID						uniqueidentifier NULL,	-- DBTYPE_GUID
	COLUMN_PROPID					int NULL,			-- DBTYPE_UI4
	ORDINAL_POSITION				int NULL,			-- DBTYPE_UI4
	COLUMN_HASDEFAULT				bit NULL,			-- DBTYPE_BOOL
	COLUMN_DEFAULT					nvarchar(128) NULL,	-- DBTYPE_WSTR
	COLUMN_FLAGS					int NULL,			-- DBTYPE_UI4
	IS_NULLABLE						bit NULL,			-- DBTYPE_BOOL
	DATA_TYPE						smallint NULL,		-- DBTYPE_UI2
	TYPE_GUID						uniqueidentifier NULL,	-- DBTYPE_GUID
	CHARACTER_MAXIMUM_LENGTH		int NULL,			-- DBTYPE_UI4
	CHARACTER_OCTET_LENGTH			int NULL,			-- DBTYPE_UI4
	NUMERIC_PRECISION				smallint NULL,		-- DBTYPE_UI2
	NUMERIC_SCALE					smallint NULL,		-- DBTYOE_I2
	DATETIME_PRECISION				int NULL,			-- DBTYPE_UI4
	CHARACTER_SET_CATALOG			nvarchar(128) NULL,	-- DBTYPE_WSTR
	CHARACTER_SET_SCHEMA			nvarchar(128) NULL,	-- DBTYPE_WSTR
	CHARACTER_SET_NAME				nvarchar(128) NULL,	-- DBTYPE_WSTR
	COLLATION_CATALOG				nvarchar(128) NULL,	-- DBTYPE_WSTR
	COLLATION_SCHEMA				nvarchar(128) NULL,	-- DBTYPE_WSTR
	COLLATION_NAME					nvarchar(128) NULL,	-- DBTYPE_WSTR
	DOMAIN_CATALOG					nvarchar(128) NULL,	-- DBTYPE_WSTR
	DOMAIN_SCHEMA					nvarchar(128) NULL,	-- DBTYPE_WSTR
	DOMAIN_NAME						nvarchar(128) NULL,	-- DBTYPE_WSTR
	DESCRIPTION						nvarchar(4000) NULL	-- DBTYPE_WSTR
    )
go


if object_id('SYSREMOTE_INDEXES') is not null
    drop table SYSREMOTE_INDEXES
go
create table SYSREMOTE_INDEXES (
    TABLE_CATALOG					nvarchar(128) NULL,	-- DBTYPE_WSTR
	TABLE_SCHEMA					nvarchar(128) NULL,	-- DBTYPE_WSTR
	TABLE_NAME						nvarchar(128) NULL,	-- DBTYPE_WSTR
    INDEX_CATALOG					nvarchar(128) NULL,	-- DBTYPE_WSTR
	INDEX_SCHEMA					nvarchar(128) NULL,	-- DBTYPE_WSTR
	INDEX_NAME						nvarchar(128) NULL,	-- DBTYPE_WSTR
	PRIMARY_KEY						bit NULL,			-- DBTYPE_BOOL
	[UNIQUE]						bit NULL,			-- DBTYPE_BOOL
	[CLUSTERED]						bit NULL,			-- DBTYPE_BOOL
	TYPE							smallint NULL,		-- DBTYPE_UI2
	FILL_FACTOR						int NULL,			-- DBTYPE_I4
	INITIAL_SIZE					int NULL,			-- DBTYPE_I4
	NULLS							int NULL,			-- DBTYPE_I4
	SORT_BOOKMARKS					bit NULL,			-- DBTYPE_BOOL
	AUTO_UPDATE						bit NULL,			-- DBTYPE_BOOL
	NULL_COLLATION					int NULL,			-- DBTYPE_I4
	ORDINAL_POSITION				int NULL,			-- DBTYPE_UI4
	COLUMN_NAME						nvarchar(128) NULL,		-- DBTYPE_WSTR
	COLUMN_GUID						uniqueidentifier NULL,		-- DBTYPE_GUID
	COLUMN_PROPID					int NULL,			-- DBTYPE_UI4
	[COLLATION]						smallint NULL,		-- DBTYPE_I2
	CARDINALITY						int NULL,			-- DBTYPE_I4
	PAGES							int NULL,			-- DBTYPE_I4
	FILTER_CONDITION				nvarchar(4000) NULL	-- DBTYPE_WSTR
    )
go

if object_id('SYSREMOTE_STATISTICS') is not null
    drop table SYSREMOTE_STATISTICS
go
create table SYSREMOTE_STATISTICS (
	TABLE_CATALOG					nvarchar(128) NULL,	-- DBTYPE_WSTR
	TABLE_SCHEMA					nvarchar(128) NULL,	-- DBTYPE_WSTR
	TABLE_NAME						nvarchar(128) NULL,	-- DBTYPE_WSTR
	CARDINALITY						int NULL			-- DBTYPE_I4
	)
go

if object_id('SYSREMOTE_PROVIDER_TYPES') is not null
    drop table SYSREMOTE_PROVIDER_TYPES
go
create table SYSREMOTE_PROVIDER_TYPES (
	TYPE_NAME						nvarchar(128) NULL,	-- DBTYPE_WSTR
	DATA_TYPE						smallint NULL,		-- DBTYPE_UI2
	COLUMN_SIZE						int NULL,			-- DBTYPE_UI4
	LITERAL_PREFIX					nvarchar(128) NULL,	-- DBTYPE_WSTR
	LITERAL_SUFFIX					nvarchar(128) NULL,	-- DBTYPE_WSTR
	CREATE_PARAMS					nvarchar(128) NULL,	-- DBTYPE_WSTR
	IS_NULLABLE						bit NULL,			-- DBTYPE_BOOL
	CASE_SENSITIVE					bit NULL,			-- DBTYPE_BOOL
	SEARCHABLE						int NULL,			-- DBTYPE_UI4
	UNSIGNED_ATTRIBUTE				bit NULL,			-- DBTYPE_BOOL
	FIXED_PREC_SCALE				bit NULL,			-- DBTYPE_BOOL
	AUTO_UNIQUE_VALUE				bit NULL,			-- DBTYPE_BOOL
	LOCAL_TYPE_NAME					nvarchar(128) NULL,	-- DBTYPE_WSTR
	MINIMUM_SCALE					smallint NULL,		-- DBTYPE_I2
	MAXIMUM_SCALE					smallint NULL,		-- DBTYPE_I2
	GUID							uniqueidentifier NULL,	-- DBTYPE_GUID
	TYPELIB							nvarchar(128) NULL,	-- DBTYPE_WSTR
	VERSION							nvarchar(4000) NULL,	-- DBTYPE_WSTR
	IS_LONG							bit NULL,			-- DBTYPE_BOOL
	BEST_MATCH						bit NULL			-- DBTYPE_BOOL
	)
go

if object_id('SYSREMOTE_TABLE_PRIVILEGES') is not null
    drop table SYSREMOTE_TABLE_PRIVILEGES
go
create table SYSREMOTE_TABLE_PRIVILEGES (
	GRANTOR							nvarchar(128) NULL,	-- DBTYPE_WSTR
	GRANTEE							nvarchar(128) NULL,	-- DBTYPE_WSTR
	TABLE_CATALOG					nvarchar(128) NULL,	-- DBTYPE_WSTR
	TABLE_SCHEMA					nvarchar(128) NULL,	-- DBTYPE_WSTR
	TABLE_NAME						nvarchar(128) NULL,	-- DBTYPE_WSTR
	PRIVILEGE_TYPE					nvarchar(128) NULL,	-- DBTYPE_WSTR
	IS_GRANTABLE					bit NULL			-- DBTYPE_BOOL
	)
go

if object_id('SYSREMOTE_COLUMN_PRIVILEGES') is not null
    drop table SYSREMOTE_COLUMN_PRIVILEGES
go
create table SYSREMOTE_COLUMN_PRIVILEGES (
	GRANTOR							nvarchar(128) NULL,	-- DBTYPE_WSTR
	GRANTEE							nvarchar(128) NULL,	-- DBTYPE_WSTR
	TABLE_CATALOG					nvarchar(128) NULL,	-- DBTYPE_WSTR
	TABLE_SCHEMA					nvarchar(128) NULL,	-- DBTYPE_WSTR
	TABLE_NAME						nvarchar(128) NULL,	-- DBTYPE_WSTR
	COLUMN_NAME						nvarchar(128) NULL,	-- DBTYPE_WSTR
	COLUMN_GUID						uniqueidentifier NULL,	-- DBTYPE_GUID
	COLUMN_PROPID					int NULL,			-- DBTYPE_UI4
	PRIVILEGE_TYPE					nvarchar(128) NULL,	-- DBTYPE_WSTR
	IS_GRANTABLE					bit NULL			-- DBTYPE_BOOL
	)
go

if object_id('SYSREMOTE_PRIMARY_KEYS') is not null
    drop table SYSREMOTE_PRIMARY_KEYS
go
create table SYSREMOTE_PRIMARY_KEYS (
	TABLE_CATALOG					nvarchar(128) NULL,	-- DBTYPE_WSTR
	TABLE_SCHEMA					nvarchar(128) NULL,	-- DBTYPE_WSTR
	TABLE_NAME						nvarchar(128) NULL,	-- DBTYPE_WSTR
	COLUMN_NAME						nvarchar(128) NULL,	-- DBTYPE_WSTR
	COLUMN_GUID						uniqueidentifier NULL,	-- DBTYPE_GUID
	COLUMN_PROPID					int NULL,			-- DBTYPE_UI4
	ORDINAL							int NULL,			-- DBTYPE_UI4
	)
go

if object_id('SYSREMOTE_FOREIGN_KEYS') is not null
    drop table SYSREMOTE_FOREIGN_KEYS
go
create table SYSREMOTE_FOREIGN_KEYS (
	PK_TABLE_CATALOG				nvarchar(128) NULL,	-- DBTYPE_WSTR
	PK_TABLE_SCHEMA					nvarchar(128) NULL,	-- DBTYPE_WSTR
	PK_TABLE_NAME					nvarchar(128) NULL,	-- DBTYPE_WSTR
	PK_COLUMN_NAME					nvarchar(128) NULL,	-- DBTYPE_WSTR
	PK_COLUMN_GUID					uniqueidentifier NULL,	-- DBTYPE_GUID
	PK_COLUMN_PROPID				int NULL,			-- DBTYPE_UI4
	FK_TABLE_CATALOG				nvarchar(128) NULL,	-- DBTYPE_WSTR
	FK_TABLE_SCHEMA					nvarchar(128) NULL,	-- DBTYPE_WSTR
	FK_TABLE_NAME					nvarchar(128) NULL,	-- DBTYPE_WSTR
	FK_COLUMN_NAME					nvarchar(128) NULL,	-- DBTYPE_WSTR
	FK_COLUMN_GUID					uniqueidentifier NULL,	-- DBTYPE_GUID
	FK_COLUMN_PROPID				int NULL,			-- DBTYPE_UI4
	ORDINAL							int NULL,			-- DBTYPE_UI4
	UPDATE_RULE						nvarchar(128) NULL,	-- DBTYPE_WSTR
	DELETE_RULE						nvarchar(128) NULL 	-- DBTYPE_WSTR
	)
go

/* NOT TO USED BY SQL SERVER ... ?
-- more constraints
create table SYSREMOTE_REFERENTIAL_CONSTRAINTS
create table SYSREMOTE_CHECK_CONSTRAINTS
create table SYSREMOTE_TABLE_CONSTRAINTS
-- procedures
create table SYSREMOTE_PROCEDURES
create table SYSREMOTE_PROCEDURE_PARAMETERS
create table SYSREMOTE_PROCEDURE_COLUMNS
create table SYSREMOTE_USAGE_PRIVILEGES
-- etc
create table SYSREMOTE_ASSERTIONS
create table SYSREMOTE_CHARACTER_SETS
create table SYSREMOTE_COLLATIONS
create table SYSREMOTE_SQL_LANGUAGES
create table SYSREMOTE_TRANSLATIONS
create table SYSREMOTE_KEY_COLUMN_USAGE
create table SYSREMOTE_VIEW_COLUMN_USAGE
create table SYSREMOTE_VIEW_TABLE_USAGE
create table SYSREMOTE_CONSTRAINT_COLUMN_USAGE
create table SYSREMOTE_CONSTRAINT_TABLE_USAGE
create table SYSREMOTE_COLUMN_DOMAIN_USAGE
*/

-- END OF "SYSTEM" OBJECT CREATION --
exec sp_MS_upd_sysobj_category 2
go
exec sp_configure 'allow', 0
reconfigure with override
go
