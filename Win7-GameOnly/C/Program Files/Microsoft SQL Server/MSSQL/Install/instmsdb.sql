/**********************************************************************/
/* INSTMSDB.SQL                                                       */
/*                                                                    */
/* Installs the tables, triggers and stored procedures necessary for  */
/* supporting local (and multi-server) jobs, alerts, operators, and   */
/* backup history.  These objects are used by SQLDMO, SQL Enterprise  */
/* Manager, and SQLServerAgent.                                       */
/*                                                                    */
/* Also contains SQL DTS (Data Transformation Services) tables and    */
/* stored procedures for local SQL Server storage of DTS Packages.    */
/*                                                                    */
/*
** Copyright Microsoft, Inc. 1994 - 2000
** All Rights Reserved.
*/
/**********************************************************************/

PRINT '----------------------------------'
PRINT 'Starting execution of INSTMSDB.SQL'
PRINT '----------------------------------'
go

/**************************************************************/
/* Turn 'System Object' marking ON                            */
/**************************************************************/
EXECUTE master.dbo.sp_MS_upd_sysobj_category 1
go

-- Explicitly set the options that the server stores with the object in sysobjects.status
-- so that it doesn't matter if the script is run using a DBLib or ODBC based client.
SET QUOTED_IDENTIFIER OFF -- We don't use quoted identifiers
SET ANSI_NULLS ON         -- We don't want (NULL = NULL) == TRUE
go
SET ANSI_PADDING ON       -- Set so that trailing zeros aren't trimmed off sysjobs.owner_login_sid
go

-- Allow updates to system catalogs so that all our SP's inherit full DML capability on
-- system objects and so that we can exercise full DDL control on our system objects
EXECUTE master.dbo.sp_configure N'allow updates', 1
go
RECONFIGURE WITH OVERRIDE
go

/**************************************************************/
/*                                                            */
/*      D  A  T  A  B  A  S  E    C  R  E  A  T  I  O  N      */
/*                                                            */
/**************************************************************/

IF (NOT EXISTS (SELECT name
                FROM master.dbo.sysdatabases
                WHERE (name = N'msdb')))
BEGIN
  PRINT 'Creating the msdb database...'
END
go

USE master
go

SET NOCOUNT ON

-- NOTE: It is important that this script can be re-run WITHOUT causing loss of data, hence
--       we only create the database if it missing (if the database already exists we test
--       that it has enough free space and if not we expand both the device and the database).
DECLARE @model_db_size    INT
DECLARE @msdb_db_size     INT
DECLARE @sz_msdb_db_size  VARCHAR(10)
DECLARE @device_directory NVARCHAR(520)
DECLARE @page_size        INT
DECLARE @size             INT
DECLARE @free_db_space    FLOAT

SELECT @page_size = 8

IF (NOT EXISTS (SELECT name
                FROM master.dbo.sysdatabases
                WHERE (name = N'msdb')))
BEGIN
  -- Make sure that we create [the data portion of] MSDB to be at least as large as
  -- the MODEL database
  SELECT @model_db_size = (SUM(size) * @page_size)
  FROM model.dbo.sysfiles

  IF (@model_db_size > 3072) -- 3 is the minimum required size for MSDB (in megabytes)
    SELECT @msdb_db_size = @model_db_size
  ELSE
    SELECT @msdb_db_size = 3072

  SELECT @device_directory = SUBSTRING(phyname, 1, CHARINDEX(N'master.mdf', LOWER(phyname)) - 1)
  FROM master.dbo.sysdevices
  WHERE (name = N'master')

  -- Drop any existing MSDBData / MSDBLog file(s)
  EXECUTE(N'EXECUTE master.dbo.xp_cmdshell N''DEL ' + @device_directory + N'MSDBData.mdf'', no_output')
  EXECUTE(N'EXECUTE master.dbo.xp_cmdshell N''DEL ' + @device_directory + N'MSDBLog.ldf'', no_output')

  -- Create the database
  PRINT ''
  PRINT 'Creating MSDB database...'
  SELECT @sz_msdb_db_size = RTRIM(LTRIM(CONVERT(VARCHAR, @msdb_db_size)))
  EXECUTE (N'CREATE DATABASE msdb ON (NAME = N''MSDBData'', FILENAME = N''' + @device_directory + N'MSDBData.mdf'', SIZE = ' + @sz_msdb_db_size + N'KB, MAXSIZE = UNLIMITED, FILEGROWTH = 256KB)
	                      LOG ON (NAME = N''MSDBLog'',  FILENAME = N''' + @device_directory + N'MSDBLog.ldf'',  SIZE = 512KB, MAXSIZE = UNLIMITED, FILEGROWTH = 256KB)')
  PRINT ''
END
ELSE
BEGIN
  PRINT 'Checking the size of MSDB...'

  DBCC UPDATEUSAGE(N'msdb') WITH NO_INFOMSGS

  -- Make sure that MSDBLog has unlimited growth
  ALTER DATABASE msdb MODIFY FILE (NAME = N'MSDBLog', MAXSIZE = UNLIMITED)

  -- Determine amount of free space in msdb. We need at least 2MB free.
  SELECT @free_db_space = ((((SELECT SUM(size)
                              FROM msdb.dbo.sysfiles
                              WHERE status & 0x8040 = 0) -
                             (SELECT SUM(reserved)
                              FROM msdb.dbo.sysindexes
                              WHERE indid IN (0, 1, 255))) * @page_size) / 1024.0)

  IF (@free_db_space < 2)
  BEGIN
    DECLARE @logical_file_name sysname
    DECLARE @os_file_name      NVARCHAR(255)
    DECLARE @size_as_char      VARCHAR(10)
	
    SELECT @logical_file_name = name,
           @os_file_name = phyname,
           @size_as_char = CONVERT(VARCHAR(10), ((high + 1) / 4) + 2048)
    FROM master.dbo.sysdevices
    WHERE (name = N'MSDBData')

    PRINT 'Attempting to expand the msdb database...'
    EXECUTE (N'ALTER DATABASE msdb MODIFY FILE (NAME = N''' + @logical_file_name + N''',
                                                FILENAME = N''' + @os_file_name + N''',
                                                SIZE = @size_as_char)')
    IF (@@error <> 0)
      RAISERROR('Unable to expand the msdb database. INSTMSDB.SQL terminating.', 20, 127) WITH LOG
  END
  PRINT ''
END
go

EXECUTE sp_dboption msdb, N'trunc. log on chkpt.', TRUE
go

USE msdb
go

-- Check that we're in msdb
IF (DB_NAME() <> N'msdb')
  RAISERROR('A problem was encountered accessing msdb. INSTMSDB.SQL terminating.', 20, 127) WITH LOG
go

-- Add the guest user
IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysusers
                WHERE (name = N'guest')
                  AND (hasdbaccess = 1)))
BEGIN
  PRINT ''
  EXECUTE sp_adduser N'guest'
END
go

DUMP TRANSACTION msdb WITH NO_LOG
go
CHECKPOINT
go

/**************************************************************/
/*                                                            */
/*                      U P G R A D E S                       */
/*                                                            */
/**************************************************************/

/**************************************************************/
-- If not on Windows 9x, use LSA instead of Registry to store
-- confidential information
/**************************************************************/
DECLARE @OS int
EXECUTE master.dbo.xp_MSplatform @OS OUTPUT

IF (@OS <> 2)
BEGIN
  PRINT 'Update SQL Agent Registry Settings'

  DECLARE @host_login_name               sysname
  DECLARE @host_login_password           VARBINARY(512)

  -- HostLoginID
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'HostLoginID',
                                         @host_login_name OUTPUT,
                                         N'no_output'

  IF (@host_login_name IS NULL) SELECT @host_login_name = N'sa'

  EXECUTE master.dbo.xp_sqlagent_param   1, 
                                         N'HostLoginID',
                                         @host_login_name

  EXECUTE master.dbo.xp_instance_regwrite
                                         N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'HostLoginID',
                                         N'REG_SZ',
                                         N''

  EXECUTE master.dbo.xp_instance_regdeletevalue
                                         N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'HostLoginID'

  -- HostPassword
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'HostPassword',
                                         @host_login_password OUTPUT,
                                         N'no_output'

  EXECUTE master.dbo.xp_sqlagent_param   1, 
                                         N'HostPassword',
                                         @host_login_password

  EXECUTE master.dbo.xp_instance_regwrite
                                         N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'HostPassword',
                                         N'REG_BINARY',
                                         N''

  EXECUTE master.dbo.xp_instance_regdeletevalue
                                         N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'HostPassword'

END -- If not Windows 9x, use LSA instead of Registry
/**************************************************************/
go

/**************************************************************/
-- Upgrade the SQLAgent table to no longer use "(local)"
-- but always use the server name or server\instance name
/**************************************************************/
IF EXISTS (SELECT * FROM msdb.dbo.sysobjects WHERE name = N'sysjobs' and type = 'U')
BEGIN
  PRINT ''
  PRINT 'Update sysjobs'
  UPDATE  msdb.dbo.sysjobs
  SET     originating_server = CONVERT(NVARCHAR(30), SERVERPROPERTY('servername'))
  WHERE   UPPER(originating_server) = '(LOCAL)'
END

IF EXISTS (SELECT * FROM msdb.dbo.sysobjects WHERE name = N'sysjobhistory' and type = 'U')
BEGIN
  PRINT ''
  PRINT 'Update sysjobhistory'
  UPDATE  msdb.dbo.sysjobhistory
  SET     server = CONVERT(NVARCHAR(30), SERVERPROPERTY('servername'))
  WHERE   UPPER(server) = '(LOCAL)'
END
/**************************************************************/
go

/**************************************************************/
/*                                                            */
/*              T  A  B  L  E     D  R  O  P  S               */
/*                                                            */
/**************************************************************/

SET NOCOUNT ON

DECLARE @build_number   INT
DECLARE @rebuild_needed TINYINT

SELECT @build_number = @@microsoftversion & 0xffff

IF (@build_number <= 0) -- The last build that we changed the schema in
  SELECT @rebuild_needed = 1
ELSE
  SELECT @rebuild_needed = 0

IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sqlagent_info')
              AND (type = 'U')
              AND (@rebuild_needed = 1)))
BEGIN
  PRINT ''
  PRINT 'Dropping table sqlagent_info...'
  DROP TABLE dbo.sqlagent_info
END

IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sysdownloadlist')
              AND (type = 'U')
              AND (@rebuild_needed = 1)))
BEGIN
  PRINT ''
  PRINT 'Dropping table sysdownloadlist...'

  IF (EXISTS (SELECT *
              FROM msdb.dbo.syscolumns
              WHERE (id = OBJECT_ID(N'sysdownloadlist'))
                AND (name = N'error_message')
                AND (cdefault <> 0)))
    EXECUTE sp_unbindefault N'sysdownloadlist.error_message'

  IF (EXISTS (SELECT *
              FROM msdb.dbo.syscolumns
              WHERE (id = OBJECT_ID(N'sysdownloadlist'))
                AND (name = N'date_posted')
                AND (cdefault <> 0)))
    EXECUTE sp_unbindefault N'sysdownloadlist.date_posted'

  IF (EXISTS (SELECT *
              FROM msdb.dbo.syscolumns
              WHERE (id = OBJECT_ID(N'sysdownloadlist'))
                AND (name = N'status')
                AND (cdefault <> 0)))
    EXECUTE sp_unbindefault N'sysdownloadlist.status'

  DROP TABLE dbo.sysdownloadlist
END

IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sysjobhistory')
              AND (type = 'U')
              AND (@rebuild_needed = 1)))
BEGIN
  PRINT ''
  PRINT 'Dropping table sysjobhistory...'
  DROP TABLE dbo.sysjobhistory
END

IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sysjobservers')
              AND (type = 'U')
              AND (@rebuild_needed = 1)))
BEGIN
  PRINT ''
  PRINT 'Dropping table sysjobservers...'
  DROP TABLE dbo.sysjobservers
END

IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sysjobs')
              AND (type = 'U')
              AND (@rebuild_needed = 1)))
BEGIN
  PRINT ''
  PRINT 'Dropping table sysjobs...'
  DROP TABLE dbo.sysjobs
END

IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sysjobsteps')
              AND (type = 'U')
              AND (@rebuild_needed = 1)))
BEGIN
  PRINT ''
  PRINT 'Dropping table sysjobsteps...'
  DROP TABLE dbo.sysjobsteps
END

IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sysjobschedules')
              AND (type = 'U')
              AND (@rebuild_needed = 1)))
BEGIN
  PRINT ''
  PRINT 'Dropping table sysjobschedules...'

  IF (EXISTS (SELECT *
              FROM msdb.dbo.syscolumns
              WHERE (id = OBJECT_ID(N'sysjobschedules'))
                AND (name = N'date_created')
                AND (cdefault <> 0)))
    EXECUTE sp_unbindefault N'sysjobschedules.date_created'

  DROP TABLE dbo.sysjobschedules
END

IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'syscategories')
              AND (type = 'U')
              AND (@rebuild_needed = 1)))
BEGIN
  PRINT ''
  PRINT 'Dropping table syscategories...'
  DROP TABLE dbo.syscategories
END

IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'systargetservers')
              AND (type = 'U')
              AND (@rebuild_needed = 1)))
BEGIN
  PRINT ''
  PRINT 'Dropping table systargetservers...'

  IF (EXISTS (SELECT *
              FROM msdb.dbo.syscolumns
              WHERE (id = OBJECT_ID(N'systargetservers'))
                AND (name = N'enlist_date')
                AND (cdefault <> 0)))
    EXECUTE sp_unbindefault N'systargetservers.enlist_date'

  IF (EXISTS (SELECT *
              FROM msdb.dbo.syscolumns
              WHERE (id = OBJECT_ID(N'systargetservers'))
                AND (name = N'last_poll_date')
                AND (cdefault <> 0)))
    EXECUTE sp_unbindefault N'systargetservers.last_poll_date'

  IF (EXISTS (SELECT *
              FROM msdb.dbo.syscolumns
              WHERE (id = OBJECT_ID(N'systargetservers'))
                AND (name = N'status')
                AND (cdefault <> 0)))
    EXECUTE sp_unbindefault N'systargetservers.status'

  DROP TABLE dbo.systargetservers
END

IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'systargetservergroups')
              AND (type = 'U')
              AND (@rebuild_needed = 1)))
BEGIN
  PRINT ''
  PRINT 'Dropping table systargetservergroups...'
  DROP TABLE dbo.systargetservergroups
END

IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'systargetservergroupmembers')
              AND (type = 'U')
              AND (@rebuild_needed = 1)))
BEGIN
  PRINT ''
  PRINT 'Dropping table systargetservergroupmembers...'
  DROP TABLE dbo.systargetservergroupmembers
END

IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'systaskids')
              AND (type = 'U')
              AND (@rebuild_needed = 1)))
BEGIN
  PRINT ''
  PRINT 'Dropping table systaskids...'
  DROP TABLE dbo.systaskids
END

IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sysalerts')
              AND (type = 'U')
              AND (@rebuild_needed = 1)))
BEGIN
  PRINT ''
  PRINT 'Dropping table sysalerts...'
  DROP TABLE dbo.sysalerts
END

IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sysoperators')
              AND (type = 'U')
              AND (@rebuild_needed = 1)))
BEGIN
  PRINT ''
  PRINT 'Dropping table sysoperators...'
  DROP TABLE dbo.sysoperators
END

IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sysnotifications')
              AND (type = 'U')
              AND (@rebuild_needed = 1)))
BEGIN
  PRINT ''
  PRINT 'Dropping table sysnotifications...'
  DROP TABLE dbo.sysnotifications
END

IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sysdbmaintplan_jobs')
              AND (type = 'U')
              AND (@rebuild_needed = 1)))
BEGIN
  PRINT ''
  PRINT 'Dropping table sysdbmaintplan_jobs...'
  DROP TABLE sysdbmaintplan_jobs
END

IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sysdbmaintplan_databases')
              AND (type = 'U')
              AND (@rebuild_needed = 1)))
BEGIN
  PRINT ''
  PRINT 'Dropping table sysdbmaintplan_databases...'
  DROP TABLE sysdbmaintplan_databases
END

IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sysdbmaintplan_history')
              AND (type = 'U')
              AND (@rebuild_needed = 1)))
BEGIN
  PRINT ''
  PRINT 'Dropping table sysdbmaintplan_history...'
  DROP TABLE sysdbmaintplan_history
END

IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sysdbmaintplans')
              AND (type = 'U')
              AND (@rebuild_needed = 1)))
BEGIN
  PRINT ''
  PRINT 'Dropping table sysdbmaintplans...'
  DROP TABLE sysdbmaintplans
END

IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'syscachedcredentials')
              AND (type = 'U')
              AND (@rebuild_needed = 1)))
BEGIN
  PRINT ''
  PRINT 'Dropping table syscachedcredentials...'
  DROP TABLE syscachedcredentials
END

IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'default_sdl_error_message')
              AND (type = 'D')
              AND (@rebuild_needed = 1)))
  DROP DEFAULT default_sdl_error_message

IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'default_current_date')
              AND (type = 'D')
              AND (@rebuild_needed = 1)))
  DROP DEFAULT default_current_date

IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'default_zero')
              AND (type = 'D')
              AND (@rebuild_needed = 1)))
  DROP DEFAULT default_zero

IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'default_one')
              AND (type = 'D')
              AND (@rebuild_needed = 1)))
  DROP DEFAULT default_one
go

DUMP TRANSACTION msdb WITH NO_LOG
go
CHECKPOINT
go

/**************************************************************/
/*                                                            */
/*                     D  E  F  A  U  L  T  S                 */
/*                                                            */
/**************************************************************/

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = N'default_sdl_error_message')
                  AND (type = 'D')))
  EXECUTE('CREATE DEFAULT default_sdl_error_message AS NULL')
go
IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = N'default_current_date')
                  AND (type = 'D')))
  EXECUTE('CREATE DEFAULT default_current_date AS GETDATE()')
go
IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = N'default_zero')
                  AND (type = 'D')))
  EXECUTE('CREATE DEFAULT default_zero AS 0')
go
IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = N'default_one')
                  AND (type = 'D')))
  EXECUTE('CREATE DEFAULT default_one AS 1')
go

/**************************************************************/
/*                                                            */
/*                       T  A  B  L  E  S                     */
/*                                                            */
/**************************************************************/

/**************************************************************/
/* SQLAGENT_INFO                                              */
/**************************************************************/

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = N'sqlagent_info')
                  AND (type = 'U')))
BEGIN
  PRINT ''
  PRINT 'Creating table sqlagent_info...'

  CREATE TABLE sqlagent_info
  (
  attribute sysname       NOT NULL,
  value     NVARCHAR(512) NOT NULL
  )
END
go

/**************************************************************/
/* SYSDOWNLOADLIST                                            */
/**************************************************************/

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = N'sysdownloadlist')
                  AND (type = 'U')))
BEGIN
  PRINT ''
  PRINT 'Creating table sysdownloadlist...'

  CREATE TABLE sysdownloadlist
  (
  instance_id         INT IDENTITY     NOT NULL,
  source_server       NVARCHAR(30)     NOT NULL,
  operation_code      TINYINT          NOT NULL,
  object_type         TINYINT          NOT NULL,
  object_id           UNIQUEIDENTIFIER NOT NULL,
  target_server       NVARCHAR(30)     NOT NULL,
  error_message       NVARCHAR(1024)   NULL,
  date_posted         DATETIME         NOT NULL,
  date_downloaded     DATETIME         NULL,
  status              TINYINT          NOT NULL,
  deleted_object_name sysname          NULL
  )

  EXECUTE sp_bindefault default_sdl_error_message, N'sysdownloadlist.error_message'
  EXECUTE sp_bindefault default_current_date,      N'sysdownloadlist.date_posted'
  EXECUTE sp_bindefault default_zero,              N'sysdownloadlist.status'

  CREATE UNIQUE CLUSTERED INDEX clust ON sysdownloadlist(instance_id)
  CREATE NONCLUSTERED     INDEX nc1   ON sysdownloadlist(target_server)
  CREATE NONCLUSTERED     INDEX nc2   ON sysdownloadlist(object_id)
END
go

/**************************************************************/
/* SYSJOBHISTORY                                              */
/**************************************************************/

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = N'sysjobhistory')
                  AND (type = 'U')))
BEGIN
  PRINT ''
  PRINT 'Creating table sysjobhistory...'

  CREATE TABLE sysjobhistory
  (
  instance_id          INT IDENTITY     NOT NULL,
  job_id               UNIQUEIDENTIFIER NOT NULL,
  step_id              INT              NOT NULL,
  step_name            sysname          NOT NULL,
  sql_message_id       INT              NOT NULL,
  sql_severity         INT              NOT NULL,
  message              NVARCHAR(1024)   NULL,
  run_status           INT              NOT NULL,
  run_date             INT              NOT NULL,
  run_time             INT              NOT NULL,
  run_duration         INT              NOT NULL,
  operator_id_emailed  INT              NOT NULL,
  operator_id_netsent  INT              NOT NULL,
  operator_id_paged    INT              NOT NULL,
  retries_attempted    INT              NOT NULL,
  server               NVARCHAR(30)     NOT NULL
  )

  CREATE UNIQUE CLUSTERED INDEX clust ON sysjobhistory(instance_id)
  CREATE NONCLUSTERED     INDEX nc1   ON sysjobhistory(job_id)
END
go

/**************************************************************/
/* SYSJOBS                                                    */
/**************************************************************/

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = N'sysjobs')
                  AND (type = 'U')))
BEGIN
  PRINT ''
  PRINT 'Creating table sysjobs...'

  CREATE TABLE sysjobs
  (
  job_id                     UNIQUEIDENTIFIER NOT NULL,
  originating_server         NVARCHAR(30)     NOT NULL,
  name                       sysname          NOT NULL,
  enabled                    TINYINT          NOT NULL,
  description                NVARCHAR(512)    NULL,
  start_step_id              INT              NOT NULL,
  category_id                INT              NOT NULL,
  owner_sid                  VARBINARY(85)    NOT NULL,
  notify_level_eventlog      INT              NOT NULL,
  notify_level_email         INT              NOT NULL,
  notify_level_netsend       INT              NOT NULL,
  notify_level_page          INT              NOT NULL,
  notify_email_operator_id   INT              NOT NULL,
  notify_netsend_operator_id INT              NOT NULL,
  notify_page_operator_id    INT              NOT NULL,
  delete_level               INT              NOT NULL,
  date_created               DATETIME         NOT NULL,
  date_modified              DATETIME         NOT NULL,
  version_number             INT              NOT NULL
  )

  CREATE UNIQUE CLUSTERED INDEX clust ON sysjobs(job_id)
  CREATE NONCLUSTERED     INDEX nc1   ON sysjobs(name) -- NOTE: This is deliberately non-unique
  CREATE NONCLUSTERED     INDEX nc2   ON sysjobs(originating_server)
  CREATE NONCLUSTERED     INDEX nc3   ON sysjobs(category_id)
  CREATE NONCLUSTERED     INDEX nc4   ON sysjobs(owner_sid)
END
go

/**************************************************************/
/* SYSJOBS_VIEW                                               */
/**************************************************************/

PRINT ''
PRINT 'Creating view sysjobs_view...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sysjobs_view')
              AND (type = 'V')))
  DROP VIEW sysjobs_view
go
CREATE VIEW sysjobs_view
AS
SELECT *
FROM msdb.dbo.sysjobs
WHERE (owner_sid = SUSER_SID())
   OR (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 1)
   OR (ISNULL(IS_MEMBER(N'TargetServersRole'), 0) = 1)
go

/**************************************************************/
/* SYSJOBSERVERS                                              */
/**************************************************************/

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = N'sysjobservers')
                  AND (type = 'U')))
BEGIN
  PRINT ''
  PRINT 'Creating table sysjobservers...'

  CREATE TABLE sysjobservers
  (
  job_id               UNIQUEIDENTIFIER NOT NULL,
  server_id            INT              NOT NULL,
  last_run_outcome     TINYINT          NOT NULL,
  last_outcome_message NVARCHAR(1024)   NULL,
  last_run_date        INT              NOT NULL,
  last_run_time        INT              NOT NULL,
  last_run_duration    INT              NOT NULL
  )

  CREATE CLUSTERED    INDEX clust ON sysjobservers(job_id)
  CREATE NONCLUSTERED INDEX nc1   ON sysjobservers(server_id)
END
go

/**************************************************************/
/* SYSJOBSTEPS                                                */
/**************************************************************/

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = N'sysjobsteps')
                  AND (type = 'U')))
BEGIN
  PRINT ''
  PRINT 'Creating table sysjobsteps...'

  CREATE TABLE sysjobsteps
  (
  job_id                UNIQUEIDENTIFIER NOT NULL,
  step_id               INT              NOT NULL,
  step_name             sysname          NOT NULL,
  subsystem             NVARCHAR(40)     NOT NULL,
  command               NVARCHAR(3200)   NULL,      -- NOTE: 3.125K since unicode requires 2x space
  flags                 INT              NOT NULL,
  additional_parameters NTEXT            NULL,
  cmdexec_success_code  INT              NOT NULL,
  on_success_action     TINYINT          NOT NULL,
  on_success_step_id    INT              NOT NULL,
  on_fail_action        TINYINT          NOT NULL,
  on_fail_step_id       INT              NOT NULL,
  server                sysname          NULL,      -- Used only by replication
  database_name         sysname          NULL,
  database_user_name    sysname          NULL,
  retry_attempts        INT              NOT NULL,
  retry_interval        INT              NOT NULL,
  os_run_priority       INT              NOT NULL,  -- NOTE: Cannot use TINYINT because we need a signed number
  output_file_name      NVARCHAR(200)    NULL,
  last_run_outcome      INT              NOT NULL,
  last_run_duration     INT              NOT NULL,
  last_run_retries      INT              NOT NULL,
  last_run_date         INT              NOT NULL,
  last_run_time         INT              NOT NULL
  )

  CREATE UNIQUE CLUSTERED INDEX clust ON sysjobsteps(job_id, step_id)
  CREATE UNIQUE NONCLUSTERED INDEX nc1 ON sysjobsteps(job_id, step_name)
END
go

/**************************************************************/
/* SYSJOBSCHEDULES                                            */
/**************************************************************/

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = N'sysjobschedules')
                  AND (type = 'U')))
BEGIN
  PRINT ''
  PRINT 'Creating table sysjobschedules...'

  CREATE TABLE sysjobschedules
  (
  schedule_id            INT IDENTITY     NOT NULL,
  job_id                 UNIQUEIDENTIFIER NOT NULL,
  name                   sysname          NOT NULL,
  enabled                INT              NOT NULL,
  freq_type              INT              NOT NULL,
  freq_interval          INT              NOT NULL,
  freq_subday_type       INT              NOT NULL,
  freq_subday_interval   INT              NOT NULL,
  freq_relative_interval INT              NOT NULL,
  freq_recurrence_factor INT              NOT NULL,
  active_start_date      INT              NOT NULL,
  active_end_date        INT              NOT NULL,
  active_start_time      INT              NOT NULL,
  active_end_time        INT              NOT NULL,
  next_run_date          INT              NOT NULL,
  next_run_time          INT              NOT NULL,
  date_created           DATETIME         NOT NULL
  )

  EXECUTE sp_bindefault default_current_date, N'sysjobschedules.date_created'

  CREATE UNIQUE CLUSTERED INDEX clust ON sysjobschedules(job_id, name)
  CREATE UNIQUE NONCLUSTERED INDEX nc1 ON sysjobschedules(schedule_id)
END
go

/**************************************************************/
/* SYSCATEGORIES                                              */
/**************************************************************/

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = N'syscategories')
                  AND (type = 'U')))
BEGIN
  PRINT ''
  PRINT 'Creating table syscategories...'

  CREATE TABLE syscategories
  (
  category_id    INT IDENTITY NOT NULL,
  category_class INT          NOT NULL, -- 1 = Job, 2 = Alert, 3 = Operator
  category_type  TINYINT      NOT NULL, -- 1 = Local, 2 = Multi-Server [Only relevant if class is 1; otherwise, 3 (None)]
  name           sysname      NOT NULL
  )

  CREATE UNIQUE CLUSTERED INDEX clust ON syscategories(name, category_class)
END
go

-- Install standard [permanent] categories (reserved ID range is 0 - 99)
SET IDENTITY_INSERT msdb.dbo.syscategories ON

DELETE FROM msdb.dbo.syscategories
WHERE (category_id < 100)

-- Core categories
INSERT INTO msdb.dbo.syscategories (category_id, category_class, category_type, name) VALUES ( 0, 1, 1, N'[Uncategorized (Local)]')        -- Local default
INSERT INTO msdb.dbo.syscategories (category_id, category_class, category_type, name) VALUES ( 1, 1, 1, N'Jobs from MSX')                  -- All jobs downloaded from the MSX are placed in this category
INSERT INTO msdb.dbo.syscategories (category_id, category_class, category_type, name) VALUES ( 2, 1, 2, N'[Uncategorized (Multi-Server)]') -- Multi-server default
INSERT INTO msdb.dbo.syscategories (category_id, category_class, category_type, name) VALUES ( 3, 1, 1, N'Database Maintenance')           -- Default for all jobs created by the Maintenance Plan Wizard
INSERT INTO msdb.dbo.syscategories (category_id, category_class, category_type, name) VALUES ( 4, 1, 1, N'Web Assistant')                  -- Default for all jobs created by the Web Assistant
INSERT INTO msdb.dbo.syscategories (category_id, category_class, category_type, name) VALUES ( 5, 1, 1, N'Full-Text')                      -- Default for all jobs created by the Index Server
INSERT INTO msdb.dbo.syscategories (category_id, category_class, category_type, name) VALUES (98, 2, 3, N'[Uncategorized]')                -- Alert default
INSERT INTO msdb.dbo.syscategories (category_id, category_class, category_type, name) VALUES (99, 3, 3, N'[Uncategorized]')                -- Operator default

-- Replication categories
INSERT INTO msdb.dbo.syscategories (category_id, category_class, category_type, name) VALUES (10, 1, 1, N'REPL-Distribution')
INSERT INTO msdb.dbo.syscategories (category_id, category_class, category_type, name) VALUES (11, 1, 1, N'REPL-Distribution Cleanup')
INSERT INTO msdb.dbo.syscategories (category_id, category_class, category_type, name) VALUES (12, 1, 1, N'REPL-History Cleanup')
INSERT INTO msdb.dbo.syscategories (category_id, category_class, category_type, name) VALUES (13, 1, 1, N'REPL-LogReader')
INSERT INTO msdb.dbo.syscategories (category_id, category_class, category_type, name) VALUES (14, 1, 1, N'REPL-Merge')
INSERT INTO msdb.dbo.syscategories (category_id, category_class, category_type, name) VALUES (15, 1, 1, N'REPL-Snapshot')
INSERT INTO msdb.dbo.syscategories (category_id, category_class, category_type, name) VALUES (16, 1, 1, N'REPL-Checkup')
INSERT INTO msdb.dbo.syscategories (category_id, category_class, category_type, name) VALUES (17, 1, 1, N'REPL-Subscription Cleanup')
INSERT INTO msdb.dbo.syscategories (category_id, category_class, category_type, name) VALUES (18, 1, 1, N'REPL-Alert Response')
INSERT INTO msdb.dbo.syscategories (category_id, category_class, category_type, name) VALUES (19, 1, 1, N'REPL-QueueReader')
INSERT INTO msdb.dbo.syscategories (category_id, category_class, category_type, name) VALUES (20, 2, 3, N'Replication')

SET IDENTITY_INSERT msdb.dbo.syscategories OFF
go

/**************************************************************/
/* SYSTARGETSERVERS                                           */
/**************************************************************/

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = N'systargetservers')
                  AND (type = 'U')))
BEGIN
  PRINT ''
  PRINT 'Creating table systargetservers...'

  CREATE TABLE systargetservers
  (
  server_id               INT IDENTITY  NOT NULL,
  server_name             NVARCHAR(30)  NOT NULL,
  location                NVARCHAR(200) NULL,
  time_zone_adjustment    INT           NOT NULL,  -- The offset from GMT in minutes (set by sp_msx_enlist)
  enlist_date             DATETIME      NOT NULL,
  last_poll_date          DATETIME      NOT NULL,
  status                  INT           NOT NULL,  -- 1 = Normal, 2 = Offline, 4 = Blocked
  local_time_at_last_poll DATETIME      NOT NULL,  -- The local time at the target server as-of the last time it polled the MSX
  enlisted_by_nt_user     NVARCHAR(100) NOT NULL,
  poll_interval           INT           NOT NULL   -- The MSX polling interval (in seconds)
  )

  EXECUTE sp_bindefault default_current_date, N'systargetservers.enlist_date'
  EXECUTE sp_bindefault default_current_date, N'systargetservers.last_poll_date'
  EXECUTE sp_bindefault default_one,          N'systargetservers.status'

  CREATE UNIQUE CLUSTERED    INDEX clust ON systargetservers(server_id)
  CREATE UNIQUE NONCLUSTERED INDEX nc1   ON systargetservers(server_name)
END
go

/**************************************************************/
/* SYSTARGETSERVERS_VIEW                                      */
/**************************************************************/

PRINT ''
PRINT 'Creating view systargetservers_view...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'systargetservers_view')
              AND (type = 'V')))
  DROP VIEW systargetservers_view
go
CREATE VIEW systargetservers_view
AS
SELECT server_id,
       server_name,
       enlist_date,
       last_poll_date
FROM msdb.dbo.systargetservers
UNION
SELECT 0,
       CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName')),
       CONVERT(DATETIME, N'19981113', 112),
       CONVERT(DATETIME, N'19981113', 112)
go

/**************************************************************/
/* SYSTARGETSERVERGROUPS                                      */
/**************************************************************/

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = N'systargetservergroups')
                  AND (type = 'U')))
BEGIN
  PRINT ''
  PRINT 'Creating table systargetservergroups...'

  CREATE TABLE systargetservergroups
  (
  servergroup_id INT IDENTITY NOT NULL,
  name           sysname      NOT NULL
  )

  CREATE UNIQUE CLUSTERED INDEX clust ON systargetservergroups(name)
END
go

/**************************************************************/
/* SYSTARGETSERVERGROUPMEMBERS                                */
/**************************************************************/

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = N'systargetservergroupmembers')
                  AND (type = 'U')))
BEGIN
  PRINT ''
  PRINT 'Creating table systargetservergroupmembers...'

  CREATE TABLE systargetservergroupmembers
  (
  servergroup_id INT NOT NULL,
  server_id      INT NOT NULL
  )

  CREATE UNIQUE CLUSTERED INDEX clust ON systargetservergroupmembers(servergroup_id, server_id)
  CREATE NONCLUSTERED     INDEX nc1   ON systargetservergroupmembers(server_id)
END
go

/**************************************************************/
/* SYSALERTS                                                  */
/**************************************************************/

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = N'sysalerts')
                  AND (type = 'U')))
BEGIN
  PRINT ''
  PRINT 'Creating table sysalerts...'

  CREATE TABLE sysalerts
  (
  id                        INT IDENTITY     NOT NULL,
  name                      sysname          NOT NULL, -- Was length 60 in 6.x
  event_source              NVARCHAR(100)    NOT NULL,
  event_category_id         INT              NULL,
  event_id                  INT              NULL,
  message_id                INT              NOT NULL, -- Was NULL in 6.x
  severity                  INT              NOT NULL, -- Was NULL in 6.x
  enabled                   TINYINT          NOT NULL,
  delay_between_responses   INT              NOT NULL,
  last_occurrence_date      INT              NOT NULL, -- Was NULL in 6.x
  last_occurrence_time      INT              NOT NULL, -- Was NULL in 6.x
  last_response_date        INT              NOT NULL, -- Was NULL in 6.x
  last_response_time        INT              NOT NULL, -- Was NULL in 6.x
  notification_message      NVARCHAR(512)    NULL,
  include_event_description TINYINT          NOT NULL,
  database_name             sysname          NULL,
  event_description_keyword NVARCHAR(100)    NULL,
  occurrence_count          INT              NOT NULL,
  count_reset_date          INT              NOT NULL, -- Was NULL in 6.x
  count_reset_time          INT              NOT NULL, -- Was NULL in 6.x
  job_id                    UNIQUEIDENTIFIER NOT NULL, -- Was NULL in 6.x
  has_notification          INT              NOT NULL, -- New for 7.0
  flags                     INT              NOT NULL, -- Was NULL in 6.x
  performance_condition     NVARCHAR(512)    NULL,
  category_id               INT              NOT NULL  -- New for 7.0
  )

  CREATE UNIQUE CLUSTERED INDEX ByName ON sysalerts(name)
  CREATE UNIQUE INDEX ByID ON sysalerts(id)
END
go

/**************************************************************/
/* SYSOPERATORS                                               */
/**************************************************************/

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = N'sysoperators')
                  AND (type = 'U')))
BEGIN
  PRINT ''
  PRINT 'Creating table sysoperators...'

  CREATE TABLE sysoperators
  (
  id                        INT IDENTITY  NOT NULL,
  name                      sysname       NOT NULL, -- Was length 50 in 6.x
  enabled                   TINYINT       NOT NULL,
  email_address             NVARCHAR(100) NULL,
  last_email_date           INT           NOT NULL, -- Was NULL in 6.x
  last_email_time           INT           NOT NULL, -- Was NULL in 6.x
  pager_address             NVARCHAR(100) NULL,
  last_pager_date           INT           NOT NULL, -- Was NULL in 6.x
  last_pager_time           INT           NOT NULL, -- Was NULL in 6.x
  weekday_pager_start_time  INT           NOT NULL,
  weekday_pager_end_time    INT           NOT NULL,
  saturday_pager_start_time INT           NOT NULL,
  saturday_pager_end_time   INT           NOT NULL,
  sunday_pager_start_time   INT           NOT NULL,
  sunday_pager_end_time     INT           NOT NULL,
  pager_days                TINYINT       NOT NULL,
  netsend_address           NVARCHAR(100) NULL,     -- New for 7.0
  last_netsend_date         INT           NOT NULL, -- New for 7.0
  last_netsend_time         INT           NOT NULL, -- New for 7.0
  category_id               INT           NOT NULL  -- New for 7.0
  )

  CREATE UNIQUE CLUSTERED INDEX ByName ON sysoperators(name)
  CREATE UNIQUE INDEX ByID ON sysoperators(id)
END
go

/**************************************************************/
/* SYSNOTIFICATIONS                                           */
/**************************************************************/

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = N'sysnotifications')
                  AND (type = 'U')))
BEGIN
  PRINT ''
  PRINT 'Creating table sysnotifications...'

  CREATE TABLE sysnotifications
  (
  alert_id             INT      NOT NULL,
  operator_id          INT      NOT NULL,
  notification_method  TINYINT  NOT NULL
  )

  CREATE UNIQUE CLUSTERED INDEX ByAlertIDAndOperatorID ON sysnotifications(alert_id, operator_id)
END
go

/**************************************************************/
/* SYSTASKIDS                                                 */
/*                                                            */
/* This table provides a mapping between new GUID job ID's    */
/* and 6.x INT task ID's.                                     */
/* Entries are made in this table for all existing 6.x tasks  */
/* and for all new tasks added using the 7.0 version of       */
/* sp_addtask.                                                */
/* Callers of the 7.0 version of sp_helptask will ONLY see    */
/* tasks [jobs] that have a corresponding entry in this table */
/* [IE. Jobs created with sp_add_job will not be returned].   */
/**************************************************************/

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = N'systaskids')
                  AND (type = 'U')))
BEGIN
  CREATE TABLE systaskids
  (
  task_id INT IDENTITY     NOT NULL,
  job_id  UNIQUEIDENTIFIER NOT NULL
  )

  CREATE CLUSTERED INDEX clust ON systaskids(job_id)
END
go

/**************************************************************/
/* SYSCACHEDCREDENTIALS                                       */
/*                                                            */
/**************************************************************/

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = N'syscachedcredentials')
                  AND (type = 'U')))
BEGIN
  CREATE TABLE syscachedcredentials
  (
  login_name          sysname      COLLATE database_default NOT NULL PRIMARY KEY,
  has_server_access   BIT          NOT NULL DEFAULT 0,
  is_sysadmin_member  BIT          NOT NULL DEFAULT 0,
  cachedate           DATETIME     NOT NULL DEFAULT getdate()
  )
END
go

DUMP TRANSACTION msdb WITH NO_LOG
go
CHECKPOINT
go

/**************************************************************/
/*                                                            */
/*        C  O  R  E     P  R  O  C  E  D  U  R  E  S         */
/*                                                            */
/**************************************************************/

/**************************************************************/
/* SP_SQLAGENT_GET_STARTUP_INFO                               */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_sqlagent_get_startup_info...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = 'sp_sqlagent_get_startup_info')
              AND (type = 'P')))
  DROP PROCEDURE sp_sqlagent_get_startup_info
go
CREATE PROCEDURE sp_sqlagent_get_startup_info
AS
BEGIN
  DECLARE @tbu INT

  SET NOCOUNT ON

  IF (ServerProperty('InstanceName') IS NULL)
  BEGIN
    EXECUTE @tbu = master.dbo.xp_qv '1338198028'
  END
  ELSE
  BEGIN
    DECLARE @instancename NVARCHAR(128)
    SELECT @instancename = CONVERT(NVARCHAR(128), ServerProperty('InstanceName'))
    EXECUTE @tbu = master.dbo.xp_qv '1338198028', @instancename
  END

  IF (@tbu < 0)
    SELECT @tbu = 0

  SELECT 'msdb_70_compatible' = (SELECT CASE WHEN cmptlevel >= 70 THEN 1 ELSE 0 END FROM master.dbo.sysdatabases WHERE (name = 'msdb')),
         'msdb_read_only' = DATABASEPROPERTY('msdb', 'IsReadOnly'),
         'msdb_available' = CASE ISNULL(DATABASEPROPERTY('msdb', 'IsSingleUser'), 0) WHEN 0 THEN 1 ELSE 0 END &
                            CASE ISNULL(DATABASEPROPERTY('msdb', 'IsDboOnly'), 0) WHEN 0 THEN 1 ELSE 0 END &
                            CASE ISNULL(DATABASEPROPERTY('msdb', 'IsNotRecovered'), 0) WHEN 0 THEN 1 ELSE 0 END &
                            CASE ISNULL(DATABASEPROPERTY('msdb', 'IsSuspect'), 0) WHEN 0 THEN 1 ELSE 0 END,
         'case_sensitive_server' = CASE ISNULL((SELECT 1 WHERE 'a' = 'A'), 0)
                                     WHEN 1 THEN 0
                                     ELSE 1
                                   END,
         'max_user_connection' = (SELECT value FROM master.dbo.syscurconfigs WHERE (config = 103)),
         'sql_server_name' = CONVERT(sysname, SERVERPROPERTY('SERVERNAME')),
         'tbu' = ISNULL(@tbu, 0),
         'platform' = PLATFORM(),
         'instance_name' = ISNULL(CONVERT(sysname, SERVERPROPERTY('INSTANCENAME')), 'MSSQLSERVER'),
         'is_clustered' = CONVERT(INT, SERVERPROPERTY('ISCLUSTERED'))

  RETURN(0) -- Success
END
go

/**************************************************************/
/* SP_SQLAGENT_HAS_SERVER_ACCESS                              */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_sqlagent_has_server_access...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = 'sp_sqlagent_has_server_access')
              AND (type = 'P')))
  DROP PROCEDURE sp_sqlagent_has_server_access
go
CREATE PROCEDURE sp_sqlagent_has_server_access
  @login_name         sysname = NULL,
  @is_sysadmin_member INT     = NULL OUTPUT
AS
BEGIN
  DECLARE @has_server_access BIT
  DECLARE @is_sysadmin       BIT
  DECLARE @actual_login_name sysname
  DECLARE @cachedate         DATETIME

  SET NOCOUNT ON

  SELECT @cachedate = NULL

  -- remove expired entries from the cache
  DELETE msdb.dbo.syscachedcredentials
  WHERE  DATEDIFF(MINUTE, cachedate, GETDATE()) >= 29

  -- query the cache
  SELECT  @is_sysadmin = is_sysadmin_member,
          @has_server_access = has_server_access,
          @cachedate = cachedate
  FROM    msdb.dbo.syscachedcredentials
  WHERE   login_name = @login_name
  AND     DATEDIFF(MINUTE, cachedate, GETDATE()) < 29

  IF (@cachedate IS NOT NULL)
  BEGIN
    -- no output variable
    IF (@is_sysadmin_member IS NULL)
    BEGIN
      -- Return result row
      SELECT has_server_access = @has_server_access,
             is_sysadmin       = @is_sysadmin,
             actual_login_name = @login_name
      RETURN
    END
    ELSE
    BEGIN
      SELECT @is_sysadmin_member = @is_sysadmin
      RETURN
    END
  END -- select from cache

  CREATE TABLE #xp_results
  (
  account_name      sysname      COLLATE database_default NOT NULL PRIMARY KEY,
  type              NVARCHAR(10) COLLATE database_default NOT NULL,
  privilege         NVARCHAR(10) COLLATE database_default NOT NULL,
  mapped_login_name sysname      COLLATE database_default NOT NULL,
  permission_path   sysname      COLLATE database_default NULL
  )

  -- Set defaults
  SELECT @has_server_access = 0
  SELECT @is_sysadmin = 0
  SELECT @actual_login_name = FORMATMESSAGE(14205)

  IF (@login_name IS NULL)
  BEGIN
    SELECT has_server_access = 1,
           is_sysadmin       = IS_SRVROLEMEMBER(N'sysadmin'),
           actual_login_name = SUSER_SNAME()
    RETURN
  END

  IF (@login_name LIKE '%\%')
  BEGIN
    -- Handle the LocalSystem account ('NT AUTHORITY\SYSTEM') as a special case
    IF (UPPER(@login_name) = N'NT AUTHORITY\SYSTEM')
    BEGIN
      IF (EXISTS (SELECT *
                  FROM master.dbo.syslogins
                  WHERE (UPPER(loginname) = N'BUILTIN\ADMINISTRATORS')))
      BEGIN
        SELECT @has_server_access = hasaccess,
               @is_sysadmin = sysadmin,
               @actual_login_name = loginname
        FROM master.dbo.syslogins
        WHERE (UPPER(loginname) = N'BUILTIN\ADMINISTRATORS')
      END
    END
    ELSE
    BEGIN
      -- Check if the NT login has been explicitly denied access
      IF (EXISTS (SELECT *
                  FROM master.dbo.syslogins
                  WHERE (loginname = @login_name)
                    AND (denylogin = 1)))
      BEGIN
        SELECT @has_server_access = 0,
               @is_sysadmin = sysadmin,
               @actual_login_name = loginname
        FROM master.dbo.syslogins
        WHERE (loginname = @login_name)
      END
      ELSE
      BEGIN
        -- Call xp_logininfo to determine server access
        INSERT INTO #xp_results
        EXECUTE master.dbo.xp_logininfo @login_name

        SELECT @has_server_access = CASE COUNT(*)
                                      WHEN 0 THEN 0
                                      ELSE 1
                                    END
        FROM #xp_results
        SELECT @actual_login_name = mapped_login_name,
               @is_sysadmin = CASE UPPER(privilege)
                                WHEN 'ADMIN' THEN 1
                                ELSE 0
                             END
        FROM #xp_results
      END
    END
  END
  ELSE
  BEGIN
    -- Standard login
    IF (EXISTS (SELECT *
                FROM master.dbo.syslogins
                WHERE (loginname = @login_name)))
    BEGIN
      SELECT @has_server_access = hasaccess,
             @is_sysadmin = sysadmin,
             @actual_login_name = loginname
      FROM master.dbo.syslogins
      WHERE (loginname = @login_name)
    END
  END

  -- update the cache only if something is found
  IF  (UPPER(@actual_login_name) <> '(UNKNOWN)')
  BEGIN
    BEGIN TRAN
    IF EXISTS (SELECT * FROM msdb.dbo.syscachedcredentials WITH (TABLOCKX) WHERE login_name = @login_name)
    BEGIN
      UPDATE msdb.dbo.syscachedcredentials
      SET    has_server_access = @has_server_access,
             is_sysadmin_member = @is_sysadmin,
             cachedate = GETDATE()
      WHERE  login_name = @login_name
    END
    ELSE
    BEGIN
      INSERT INTO msdb.dbo.syscachedcredentials(login_name, has_server_access, is_sysadmin_member) 
      VALUES(@login_name, @has_server_access, @is_sysadmin)
    END
    COMMIT TRAN
  END

  IF (@is_sysadmin_member IS NULL)
    -- Return result row
    SELECT has_server_access = @has_server_access,
           is_sysadmin       = @is_sysadmin,
           actual_login_name = @actual_login_name
  ELSE
    -- output variable only
    SELECT @is_sysadmin_member = @is_sysadmin
END
go

/**************************************************************/
/* SP_SEM_ADD_MESSAGE [used by SEM only]                      */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_sem_add_message...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = 'sp_sem_add_message')
              AND (type = 'P')))
  DROP PROCEDURE sp_sem_add_message
go
CREATE PROCEDURE sp_sem_add_message
  @msgnum   INT           = NULL,
  @severity SMALLINT      = NULL,
  @msgtext  NVARCHAR(255) = NULL,
  @lang     sysname       = NULL, -- Message language name
  @with_log VARCHAR(5)    = 'FALSE',
  @replace  VARCHAR(7)    = NULL
AS
BEGIN
  DECLARE @retval        INT
  DECLARE @language_name sysname

  SET NOCOUNT ON

  SET ROWCOUNT 1
  SELECT @language_name = name
  FROM master.dbo.syslanguages
  WHERE msglangid = (SELECT number
                     FROM master.dbo.spt_values
                     WHERE (type = 'LNG')
                       AND (name = @lang))
  SET ROWCOUNT 0

  SELECT @language_name = ISNULL(@language_name, 'us_english')
  EXECUTE @retval = master.dbo.sp_addmessage @msgnum, @severity, @msgtext, @language_name, @with_log, @replace
  RETURN(@retval)
END
go

/**************************************************************/
/* SP_SEM_DROP_MESSAGE [used by SEM only]                     */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_sem_drop_message...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = 'sp_sem_drop_message')
              AND (type = 'P')))
  DROP PROCEDURE sp_sem_drop_message
go
CREATE PROCEDURE sp_sem_drop_message
  @msgnum int     = NULL,
  @lang   sysname = NULL -- Message language name
AS
BEGIN
  DECLARE @retval        INT
  DECLARE @language_name sysname

  SET NOCOUNT ON

  SET ROWCOUNT 1
  SELECT @language_name = name
  FROM master.dbo.syslanguages
  WHERE msglangid = (SELECT number
                     FROM master.dbo.spt_values
                     WHERE (type = 'LNG')
                       AND (name = @lang))
  SET ROWCOUNT 0

  SELECT @language_name = ISNULL(@language_name, 'us_english')
  EXECUTE @retval = master.dbo.sp_dropmessage @msgnum, @language_name
  RETURN(@retval)
END
go

/**************************************************************/
/* SP_GET_MESSAGE_DESCRIPTION [used by SEM only]              */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_get_message_description...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = 'sp_get_message_description')
              AND (type = 'P')))
  DROP PROCEDURE sp_get_message_description
go
CREATE PROCEDURE sp_get_message_description
  @error INT
AS
BEGIN
  IF EXISTS (SELECT * FROM master.dbo.sysmessages WHERE (error = @error) AND (msglangid = (SELECT msglangid FROM master.dbo.syslanguages WHERE (langid = @@langid))))
    SELECT description FROM master.dbo.sysmessages WHERE (error = @error) AND (msglangid = (SELECT msglangid FROM master.dbo.syslanguages WHERE (langid = @@langid)))
  ELSE
    SELECT description FROM master.dbo.sysmessages WHERE (error = @error) AND (msglangid = 1033)
END
go

/**************************************************************/
/* SP_SQLAGENT_GET_PERF_COUNTERS                              */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_sqlagent_get_perf_counters...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_sqlagent_get_perf_counters')
              AND (type = 'P')))
  DROP PROCEDURE sp_sqlagent_get_perf_counters
go
CREATE PROCEDURE sp_sqlagent_get_perf_counters
  @all_counters BIT = 0
AS
BEGIN
  SET NOCOUNT ON

  CREATE TABLE #temp
  (
  performance_condition NVARCHAR(1024) COLLATE database_default NOT NULL
  )

  INSERT INTO #temp VALUES (N'dummy')

  IF (@all_counters = 0)
  BEGIN
    INSERT INTO #temp
    SELECT DISTINCT SUBSTRING(performance_condition, 1, CHARINDEX('|', performance_condition, PATINDEX('%_|_%', performance_condition) + 2) - 1)
    FROM msdb.dbo.sysalerts
    WHERE (performance_condition IS NOT NULL)
      AND (enabled = 1)
  END

  SELECT 'object_name' = RTRIM(SUBSTRING(spi1.object_name, 1, 50)),
         'counter_name' = RTRIM(SUBSTRING(spi1.counter_name, 1, 50)),
         'instance_name' = CASE spi1.instance_name
                             WHEN N'' THEN NULL
                             ELSE RTRIM(spi1.instance_name)
                           END,
         'value' = CASE spi1.cntr_type
                     WHEN 537003008 -- A ratio
                       THEN CONVERT(FLOAT, spi1.cntr_value) / (SELECT CASE spi2.cntr_value WHEN 0 THEN 1 ELSE spi2.cntr_value END
                                                               FROM master.dbo.sysperfinfo spi2
                                                               WHERE (spi1.counter_name + ' ' = SUBSTRING(spi2.counter_name, 1, PATINDEX('% Base%', spi2.counter_name)))
                                                                 AND (spi1.instance_name = spi2.instance_name)
                                                                 AND (spi2.cntr_type = 1073939459))
                     ELSE spi1.cntr_value
                   END
  FROM master.dbo.sysperfinfo spi1,
       #temp tmp
  WHERE (spi1.cntr_type <> 1073939459) -- Divisors
    AND ((@all_counters = 1) OR
         (tmp.performance_condition = RTRIM(spi1.object_name) + '|' + RTRIM(spi1.counter_name)))
END
go


/**************************************************************/
/* SP_SQLAGENT_NOTIFY                                         */
/*                                                            */
/* NOTE: We define this procedure here instead of in the      */
/*      'Support procedures' section because of the many      */
/*       other procedures that reference it.                  */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_sqlagent_notify...'
go

IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_sqlagent_notify')
              AND (type = 'P')))
  DROP PROCEDURE sp_sqlagent_notify
go
CREATE PROCEDURE sp_sqlagent_notify
  @op_type     NCHAR(1),                -- One of: J (Job action [refresh or start/stop]),
                                        --         S (Schedule action [refresh only])
                                        --         A (Alert action [refresh only]),
                                        --         G (Re-cache all registry settings),
                                        --         D (Dump job [or job schedule] cache to errorlog)
                                        --         P (Force an immediate poll of the MSX)
  @job_id      UNIQUEIDENTIFIER = NULL, -- JobID (for OpTypes 'J', 'S' and 'D')
  @schedule_id INT              = NULL, -- ScheduleID (for OpType 'S')
  @alert_id    INT              = NULL, -- AlertID (for OpType 'A')
  @action_type NCHAR(1)         = NULL, -- For 'J' one of: R (Run - no service check),
                                        --                 S (Start - with service check),
                                        --                 I (Insert),
                                        --                 U (Update),
                                        --                 D (Delete),
                                        --                 C (Stop [Cancel])
                                        -- For 'S' or 'A' one of: I (Insert),
                                        --                        U (Update),
                                        --                        D (Delete)
  @error_flag  INT              = 1     -- Set to 0 to suppress the error from xp_sqlagent_notify if SQLServer agent is not running
AS
BEGIN
  DECLARE @retval         INT
  DECLARE @id_as_char     VARCHAR(10)
  DECLARE @job_id_as_char VARCHAR(36)
  DECLARE @nt_user_name   NVARCHAR(100)

  SET NOCOUNT ON

  SELECT @retval = 0 -- Success

  -- Make sure that we're dealing only with uppercase characters
  SELECT @op_type     = UPPER(@op_type)
  SELECT @action_type = UPPER(@action_type)

  -- Verify operation code
  IF (CHARINDEX(@op_type, N'JSAGDP') = 0)
  BEGIN
    RAISERROR(14266, -1, -1, '@op_type', 'J, S, A, G, D, P')
    RETURN(1) -- Failure
  END

  -- Check the job id for those who use it
  IF (CHARINDEX(@op_type, N'JSD') <> 0)
  BEGIN
    IF (NOT ((@op_type = N'D') AND (@job_id IS NULL))) -- For 'D', job_id is optional
    BEGIN
      IF ((@job_id IS NULL) OR
          ((@action_type <> N'D') AND NOT EXISTS (SELECT *
                                                  FROM msdb.dbo.sysjobs_view
                                                  WHERE (job_id = @job_id))))
      BEGIN
        SELECT @job_id_as_char = CONVERT(VARCHAR(36), @job_id)
        RAISERROR(14262, -1, -1, '@job_id', @job_id_as_char)
        RETURN(1) -- Failure
      END
    END
  END

  -- Verify 'job' action parameters
  IF (@op_type = N'J')
  BEGIN
    SELECT @alert_id = 0
    IF (@schedule_id IS NULL) SELECT @schedule_id = 0

    -- The schedule_id (if specified) is the start step
    IF ((CHARINDEX(@action_type, N'RS') <> 0) AND (@schedule_id <> 0))
    BEGIN
      IF (NOT EXISTS (SELECT *
                      FROM msdb.dbo.sysjobsteps
                      WHERE (job_id = @job_id)
                        AND (step_id = @schedule_id)))
      BEGIN
        SELECT @id_as_char = ISNULL(CONVERT(VARCHAR, @schedule_id), '(null)')
        RAISERROR(14262, -1, -1, '@schedule_id', @id_as_char)
        RETURN(1) -- Failure
      END
    END
    ELSE
      SELECT @schedule_id = 0

    IF (CHARINDEX(@action_type, N'RSIUDC') = 0)
    BEGIN
      RAISERROR(14266, -1, -1, '@action_type', 'R, S, I, U, D, C')
      RETURN(1) -- Failure
    END
  END

  -- Verify 'schedule' action parameters
  IF (@op_type = N'S')
  BEGIN
    SELECT @alert_id = 0

    IF (CHARINDEX(@action_type, N'IUD') = 0)
    BEGIN
      RAISERROR(14266, -1, -1, '@action_type', 'I, U, D')
      RETURN(1) -- Failure
    END

    IF ((@schedule_id IS NULL) OR
        ((@action_type <> N'D') AND NOT EXISTS (SELECT *
                                                FROM msdb.dbo.sysjobschedules
                                                WHERE (schedule_id = @schedule_id))))
    BEGIN
      SELECT @id_as_char = ISNULL(CONVERT(VARCHAR, @schedule_id), '(null)')
      RAISERROR(14262, -1, -1, '@schedule_id', @id_as_char)
      RETURN(1) -- Failure
    END
  END

  -- Verify 'alert' action parameters
  IF (@op_type = N'A')
  BEGIN
    SELECT @job_id = 0x00
    SELECT @schedule_id = 0

    IF (CHARINDEX(@action_type, N'IUD') = 0)
    BEGIN
      RAISERROR(14266, -1, -1, '@action_type', 'I, U, D')
      RETURN(1) -- Failure
    END

    IF ((@alert_id IS NULL) OR
        ((@action_type <> N'D') AND NOT EXISTS (SELECT *
                                                FROM msdb.dbo.sysalerts
                                                WHERE (id = @alert_id))))
    BEGIN
      SELECT @id_as_char = ISNULL(CONVERT(VARCHAR, @alert_id), '(null)')
      RAISERROR(14262, -1, -1, '@alert_id', @id_as_char)
      RETURN(1) -- Failure
    END
  END

  -- Verify 'registry', 'job dump' and 'force MSX poll' action parameters
  IF (CHARINDEX(@op_type, N'GDP') <> 0)
  BEGIN
    IF (@op_type <> N'D')
      SELECT @job_id = 0x00
    SELECT @alert_id = 0
    SELECT @schedule_id = 0
    SELECT @action_type = NULL
  END

  -- Parameters are valid, so now check execution permissions...

  -- For anything except a job (or schedule) action the caller must be SysAdmin, DBO, or DB_Owner
  IF (@op_type NOT IN (N'J', N'S'))
  BEGIN
    IF NOT ((ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 1) OR
            (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1) OR
            (UPPER(USER_NAME()) = N'DBO'))
    BEGIN
      RAISERROR(14260, -1, -1)
      RETURN(1) -- Failure
    END
  END

  -- For a Job Action the caller must be SysAdmin, DBO, DB_Owner, or the job owner
  IF (@op_type = N'J')
  BEGIN
    IF NOT ((ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 1) OR
            (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1) OR
            (UPPER(USER_NAME()) = N'DBO') OR
            (EXISTS (SELECT *
                     FROM msdb.dbo.sysjobs_view
                     WHERE (job_id = @job_id))))
    BEGIN
      RAISERROR(14252, -1, -1)
      RETURN(1) -- Failure
    END
  END

  -- Ok, let's do it...
  SELECT @nt_user_name = ISNULL(NT_CLIENT(), ISNULL(SUSER_SNAME(), FORMATMESSAGE(14205)))
  EXECUTE @retval = master.dbo.xp_sqlagent_notify @op_type, @job_id, @schedule_id, @alert_id, @action_type, @nt_user_name, @error_flag, @@trancount

  RETURN(@retval)
END
go

/**************************************************************/
/* SP_IS_SQLAGENT_STARTING                                    */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_is_sqlagent_starting...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_is_sqlagent_starting')
              AND (type = 'P')))
  DROP PROCEDURE sp_is_sqlagent_starting
go
CREATE PROCEDURE sp_is_sqlagent_starting
AS
BEGIN
  DECLARE @retval INT

  SELECT @retval = 0
  EXECUTE master.dbo.xp_sqlagent_is_starting @retval OUTPUT
  IF (@retval = 1)
    RAISERROR(14258, -1, -1)

  RETURN(@retval)
END
go

/**************************************************************/
/* SP_VERIFY_JOB_IDENTIFIERS                                  */
/*                                                            */
/* NOTE: We define this procedure here instead of in the      */
/*      'Support procedures' section because of the many      */
/*       other procedures that reference it.                  */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_verify_job_identifiers...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_verify_job_identifiers')
              AND (type = 'P')))
  DROP PROCEDURE sp_verify_job_identifiers
go
CREATE PROCEDURE sp_verify_job_identifiers
  @name_of_name_parameter  VARCHAR(60),             -- Eg. '@job_name'
  @name_of_id_parameter    VARCHAR(60),             -- Eg. '@job_id'
  @job_name                sysname          OUTPUT, -- Eg. 'My Job'
  @job_id                  UNIQUEIDENTIFIER OUTPUT,
  @sqlagent_starting_test  VARCHAR(7) = 'TEST'      -- By default we DO want to test if SQLServerAgent is running (caller should specify 'NO_TEST' if not desired)
AS
BEGIN
  DECLARE @retval         INT
  DECLARE @job_id_as_char VARCHAR(36)

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @name_of_name_parameter = LTRIM(RTRIM(@name_of_name_parameter))
  SELECT @name_of_id_parameter   = LTRIM(RTRIM(@name_of_id_parameter))
  SELECT @job_name               = LTRIM(RTRIM(@job_name))

  IF (@job_name = N'') SELECT @job_name = NULL

  IF ((@job_name IS NULL)     AND (@job_id IS NULL)) OR
     ((@job_name IS NOT NULL) AND (@job_id IS NOT NULL))
  BEGIN
    RAISERROR(14294, -1, -1, @name_of_id_parameter, @name_of_name_parameter)
    RETURN(1) -- Failure
  END

  -- Check job id
  IF (@job_id IS NOT NULL)
  BEGIN
    SELECT @job_name = name,
           @job_id = job_id
    FROM msdb.dbo.sysjobs_view
    WHERE (job_id = @job_id)
    IF (@job_name IS NULL)
    BEGIN
      SELECT @job_id_as_char = CONVERT(VARCHAR(36), @job_id)
      RAISERROR(14262, -1, -1, '@job_id', @job_id_as_char)
      RETURN(1) -- Failure
    END
  END
  ELSE
  -- Check job name
  IF (@job_name IS NOT NULL)
  BEGIN
    -- Check if the job name is ambiguous
    IF ((SELECT COUNT(*)
         FROM msdb.dbo.sysjobs_view
         WHERE (name = @job_name)) > 1)
    BEGIN
      RAISERROR(14293, -1, -1, @job_name, @name_of_id_parameter, @name_of_name_parameter)
      RETURN(1) -- Failure
    END

    -- The name is not ambiguous, so get the corresponding job_id (if the job exists)
    SELECT @job_id = job_id
    FROM msdb.dbo.sysjobs_view
    WHERE (name = @job_name)
    IF (@job_id IS NULL)
    BEGIN
      RAISERROR(14262, -1, -1, '@job_name', @job_name)
      RETURN(1) -- Failure
    END
  END

  IF (@sqlagent_starting_test = 'TEST')
  BEGIN
    -- Finally, check if SQLServerAgent is in the process of starting and if so prevent the
    -- calling SP from running
    EXECUTE @retval = msdb.dbo.sp_is_sqlagent_starting
    IF (@retval <> 0)
      RETURN(1) -- Failure
  END

  RETURN(0) -- Success
END
go

/**************************************************************/
/* SP_VERIFY_JOBPROC_CALLER                                   */
/*                                                            */
/* NOTE: We define this procedure here instead of in the      */
/*      'Support procedures' section because of the many      */
/*       other procedures that reference it.                  */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_verify_jobproc_caller...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_verify_jobproc_caller')
              AND (type = 'P')))
  DROP PROCEDURE sp_verify_jobproc_caller
go
CREATE PROCEDURE sp_verify_jobproc_caller
  @job_id       UNIQUEIDENTIFIER,
  @program_name sysname
AS
BEGIN
  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @program_name = LTRIM(RTRIM(@program_name))

  IF (EXISTS (SELECT    *
              FROM      msdb.dbo.sysjobs_view
              WHERE     (job_id = @job_id)
              AND       (UPPER(originating_server) <> UPPER(CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName')))))) 
              AND       (PROGRAM_NAME() NOT LIKE @program_name)
  BEGIN
    RAISERROR(14274, -1, -1)
    RETURN(1) -- Failure
  END

  RETURN(0)
END
go

/**************************************************************/
/* SP_DOWNLOADED_ROW_LIMITER                                  */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_downloaded_row_limiter...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_downloaded_row_limiter')
              AND (type = 'P')))
  DROP PROCEDURE dbo.sp_downloaded_row_limiter
go
CREATE PROCEDURE sp_downloaded_row_limiter
  @server_name NVARCHAR(30) -- Target server name
AS
BEGIN
  -- This trigger controls how many downloaded (status = 1) sysdownloadlist rows exist
  -- for any given server.  It does NOT control the absolute number of rows in the table.

  DECLARE @current_rows_per_server INT
  DECLARE @max_rows_per_server     INT -- This value comes from the resgistry (DownloadedMaxRows)
  DECLARE @rows_to_delete          INT
  DECLARE @rows_to_delete_as_char  VARCHAR(10)

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @server_name = LTRIM(RTRIM(@server_name))

  -- Check the server name (if it's bad we fail silently)
  IF (@server_name IS NULL) OR
     (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysdownloadlist
                  WHERE (target_server = @server_name)))
    RETURN(1) -- Failure

  SELECT @max_rows_per_server = 0

  -- Get the max-rows-per-server from the registry
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'DownloadedMaxRows',
                                         @max_rows_per_server OUTPUT,
                                         N'no_output'

  -- Check if we are limiting sysdownloadlist rows
  IF (ISNULL(@max_rows_per_server, -1) = -1)
    RETURN

  -- Check that max_rows_per_server is >= 0
  IF (@max_rows_per_server < -1)
  BEGIN
    -- It isn't, so default to 100 rows
    SELECT @max_rows_per_server = 100
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'DownloadedMaxRows',
                                            N'REG_DWORD',
                                            @max_rows_per_server
  END

  -- Get the number of downloaded rows in sysdownloadlist for the target server in question
  -- NOTE: Determining this [quickly] requires a [non-clustered] index on target_server
  SELECT @current_rows_per_server = COUNT(*)
  FROM msdb.dbo.sysdownloadlist
  WHERE (target_server = @server_name)
    AND (status = 1)

  -- Delete the oldest downloaded row(s) for the target server in question if the new row has
  -- pushed us over the per-server row limit
  SELECT @rows_to_delete = @current_rows_per_server - @max_rows_per_server
  SELECT @rows_to_delete_as_char = CONVERT(VARCHAR, @rows_to_delete)

  IF (@rows_to_delete > 0)
  BEGIN
    EXECUTE ('DECLARE @new_oldest_id INT
              SET NOCOUNT ON
              SET ROWCOUNT ' + @rows_to_delete_as_char +
             'SELECT @new_oldest_id = instance_id
              FROM msdb.dbo.sysdownloadlist
              WHERE (target_server = N''' + @server_name + ''')' +
             '  AND (status = 1)
              ORDER BY instance_id
              SET ROWCOUNT 0
              DELETE FROM msdb.dbo.sysdownloadlist
              WHERE (target_server = N''' + @server_name + ''')' +
             '  AND (instance_id <= @new_oldest_id)
                AND (status = 1)')
  END
END
go

/**************************************************************/
/* SP_POST_MSX_OPERATION                                      */
/*                                                            */
/* NOTE: We define this procedure here instead of in the      */
/*      'Support procedures' section because of the many      */
/*       other procedures that reference it.                  */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_post_msx_operation...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = 'sp_post_msx_operation')
              AND (type = 'P')))
  DROP PROCEDURE sp_post_msx_operation
go
CREATE PROCEDURE sp_post_msx_operation
  @operation              VARCHAR(64),
  @object_type            VARCHAR(64)      = 'JOB',
  @job_id                 UNIQUEIDENTIFIER = NULL, -- NOTE: 0x00 means 'ALL'
  @specific_target_server NVARCHAR(30)     = NULL,
  @value                  INT              = NULL  -- For polling interval value
AS
BEGIN
  DECLARE @operation_code            INT
  DECLARE @specific_target_server_id INT
  DECLARE @instructions_posted       INT
  DECLARE @job_id_as_char            VARCHAR(36)
  DECLARE @msx_time_zone_adjustment  INT
  DECLARE @local_machine_name        NVARCHAR(30)
  DECLARE @retval                    INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @operation              = LTRIM(RTRIM(@operation))
  SELECT @object_type            = LTRIM(RTRIM(@object_type))
  SELECT @specific_target_server = LTRIM(RTRIM(@specific_target_server))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@specific_target_server = N'') SELECT @specific_target_server = NULL

  -- Only a sysadmin can do this, but fail silently for a non-sysadmin
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
    RETURN(0) -- Success (or more accurately a no-op)

  -- Check operation
  SELECT @operation = UPPER(@operation)
  SELECT @operation_code = CASE @operation
                             WHEN 'INSERT'    THEN 1
                             WHEN 'UPDATE'    THEN 2
                             WHEN 'DELETE'    THEN 3
                             WHEN 'START'     THEN 4
                             WHEN 'STOP'      THEN 5
                             WHEN 'RE-ENLIST' THEN 6
                             WHEN 'DEFECT'    THEN 7
                             WHEN 'SYNC-TIME' THEN 8
                             WHEN 'SET-POLL'  THEN 9
                             ELSE 0
                           END
  IF (@operation_code = 0)
  BEGIN
    RAISERROR(14266, -1, -1, '@operation_code', 'INSERT, UPDATE, DELETE, START, STOP, RE-ENLIST, DEFECT, SYNC-TIME, SET-POLL')
    RETURN(1) -- Failure
  END

  -- Check object type (in 7.0 only 'JOB' or 'SERVER' are valid)
  IF ((@object_type <> 'JOB') AND (@object_type <> 'SERVER'))
  BEGIN
    RAISERROR(14266, -1, -1, '@object_type', 'JOB, SERVER')
    RETURN(1) -- Failure
  END

  -- Check that for a object type of JOB a job_id has been supplied
  IF ((@object_type = 'JOB') AND (@job_id IS NULL))
  BEGIN
    RAISERROR(14233, -1, -1)
    RETURN(1) -- Failure
  END

  -- Check polling interval value
  IF (@operation_code = 9) AND ((ISNULL(@value, 0) < 10) OR (ISNULL(@value, 0) > 28800))
  BEGIN
    RAISERROR(14266, -1, -1, '@value', '10..28800')
    RETURN(1) -- Failure
  END

  -- Check specific target server
  IF (@specific_target_server IS NOT NULL)
  BEGIN
    -- Check if the local server is being targeted
    IF (UPPER(@specific_target_server) = UPPER(CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName'))))
    BEGIN
      RETURN(0)
    END
    ELSE
    BEGIN
      SELECT @specific_target_server_id = server_id
      FROM msdb.dbo.systargetservers
      WHERE (server_name = @specific_target_server)
      IF (@specific_target_server_id IS NULL)
      BEGIN
        RAISERROR(14262, -1, -1, '@specific_target_server', @specific_target_server)
        RETURN(1) -- Failure
      END
    END
  END

  -- Check that this server is an MSX server
  IF ((SELECT COUNT(*)
       FROM msdb.dbo.systargetservers) = 0)
  BEGIN
    RETURN(0)
  END

  -- Get local machine name
  EXECUTE @retval = master.dbo.xp_getnetname @local_machine_name OUTPUT
  IF (@retval <> 0) OR (@local_machine_name IS NULL)
  BEGIN
    RAISERROR(14225, -1, -1)
    RETURN(1)
  END

  CREATE TABLE #target_servers (server_name sysname COLLATE database_default NOT NULL)

  -- Optimization: Simply update the date-posted if the operation has already been posted (but
  -- not yet downloaded) and the target server is not currently polling...
  IF ((@object_type = 'JOB')    AND (ISNULL(@job_id, 0x00) <> CONVERT(UNIQUEIDENTIFIER, 0x00)) AND (@operation_code IN (1, 2, 3, 4, 5))) OR -- Any JOB operation
     ((@object_type = 'SERVER') AND (@operation_code IN (6, 7))) -- RE-ENLIST or DEFECT operations
  BEGIN
    -- Populate the list of target servers to post to
    IF (@specific_target_server IS NOT NULL)
      INSERT INTO #target_servers VALUES (@specific_target_server)
    ELSE
    BEGIN
      IF (@object_type = 'SERVER')
        INSERT INTO #target_servers
        SELECT server_name
        FROM msdb.dbo.systargetservers

      IF (@object_type = 'JOB')
        INSERT INTO #target_servers
        SELECT sts.server_name
        FROM msdb.dbo.sysjobs_view     sjv,
             msdb.dbo.sysjobservers    sjs,
             msdb.dbo.systargetservers sts
        WHERE (sjv.job_id = @job_id)
          AND (sjv.job_id = sjs.job_id)
          AND (sjs.server_id = sts.server_id)
          AND (sjs.server_id <> 0)
    END
  END

  -- Job-specific processing...
  IF (@object_type = 'JOB')
  BEGIN
    -- Validate the job (if supplied)
    IF (@job_id <> CONVERT(UNIQUEIDENTIFIER, 0x00))
    BEGIN
      SELECT @job_id_as_char = CONVERT(VARCHAR(36), @job_id)

      -- Check if the job exists
      IF (NOT EXISTS (SELECT *
                      FROM msdb.dbo.sysjobs_view
                      WHERE (job_id = @job_id)))
      BEGIN
        RAISERROR(14262, -1, -1, '@job_id', @job_id_as_char)
        RETURN(1) -- Failure
      END

      -- If this is a local job then there's nothing for us to do
      IF (EXISTS (SELECT *
                  FROM msdb.dbo.sysjobservers
                  WHERE (job_id = @job_id)
                    AND (server_id = 0))) -- 0 means local server
      OR (NOT EXISTS (SELECT *
                      FROM msdb.dbo.sysjobservers
                      WHERE (job_id = @job_id)))
      BEGIN
        RETURN(0)
      END
    END

    -- Generate the sysdownloadlist row(s)...
    IF (@operation_code = 1) OR  -- Insert
       (@operation_code = 2) OR  -- Update
       (@operation_code = 3) OR  -- Delete
       (@operation_code = 4) OR  -- Start
       (@operation_code = 5)     -- Stop
    BEGIN
      IF (@job_id = CONVERT(UNIQUEIDENTIFIER, 0x00)) -- IE. 'ALL'
      BEGIN
        -- All jobs

        -- Handle DELETE as a special case (rather than posting 1 instruction per job we just
        -- post a single instruction that means 'delete all jobs from the MSX')
        IF (@operation_code = 3)
        BEGIN
          INSERT INTO msdb.dbo.sysdownloadlist
                (source_server,
                 operation_code,
                 object_type,
                 object_id,
                 target_server)
          SELECT @local_machine_name,
                 @operation_code,
                 1,                -- 1 means 'JOB'
                 CONVERT(UNIQUEIDENTIFIER, 0x00),
                 sts.server_name
          FROM systargetservers sts
          WHERE ((@specific_target_server_id IS NULL) OR (sts.server_id = @specific_target_server_id))
            AND ((SELECT COUNT(*)
                  FROM msdb.dbo.sysjobservers
                  WHERE (server_id = sts.server_id)) > 0)
          SELECT @instructions_posted = @@rowcount
        END
        ELSE
        BEGIN
          INSERT INTO msdb.dbo.sysdownloadlist
                (source_server,
                 operation_code,
                 object_type,
                 object_id,
                 target_server)
          SELECT @local_machine_name,
                 @operation_code,
                 1,                -- 1 means 'JOB'
                 sjv.job_id,
                 sts.server_name
          FROM sysjobs_view     sjv,
               sysjobservers    sjs,
               systargetservers sts
          WHERE (sjv.job_id = sjs.job_id)
            AND (sjs.server_id = sts.server_id)
            AND (sjs.server_id <> 0) -- We want to exclude local jobs
            AND ((@specific_target_server_id IS NULL) OR (sjs.server_id = @specific_target_server_id))
          SELECT @instructions_posted = @@rowcount
        END
      END
      ELSE
      BEGIN
        -- Specific job (ie. @job_id is not 0x00)
        INSERT INTO msdb.dbo.sysdownloadlist
              (source_server,
               operation_code,
               object_type,
               object_id,
               target_server,
               deleted_object_name)
        SELECT @local_machine_name,
               @operation_code,
               1,                -- 1 means 'JOB'
               sjv.job_id,
               sts.server_name,
               CASE @operation_code WHEN 3 -- Delete
                                      THEN sjv.name
                                      ELSE NULL
                                    END
        FROM sysjobs_view     sjv,
             sysjobservers    sjs,
             systargetservers sts
        WHERE (sjv.job_id = @job_id)
          AND (sjv.job_id = sjs.job_id)
          AND (sjs.server_id = sts.server_id)
          AND (sjs.server_id <> 0) -- We want to exclude local jobs
          AND ((@specific_target_server_id IS NULL) OR (sjs.server_id = @specific_target_server_id))
        SELECT @instructions_posted = @@rowcount
      END
    END
    ELSE
    BEGIN
      RAISERROR(14266, -1, -1, '@operation_code', 'INSERT, UPDATE, DELETE, START, STOP')
      RETURN(1) -- Failure
    END
  END

  -- Server-specific processing...
  IF (@object_type = 'SERVER')
  BEGIN
    -- Generate the sysdownloadlist row(s)...
    IF (@operation_code = 6) OR  -- ReEnlist
       (@operation_code = 7) OR  -- Defect
       (@operation_code = 8) OR  -- Synchronize time (with MSX)
       (@operation_code = 9)     -- Set MSX polling interval (in seconds)
    BEGIN
      IF (@operation_code = 8)
      BEGIN
        EXECUTE master.dbo.xp_regread N'HKEY_LOCAL_MACHINE',
                                      N'SYSTEM\CurrentControlSet\Control\TimeZoneInformation',
                                      N'Bias',
                                      @msx_time_zone_adjustment OUTPUT,
                                      N'no_output'
        SELECT @msx_time_zone_adjustment = -ISNULL(@msx_time_zone_adjustment, 0)
      END

      INSERT INTO msdb.dbo.sysdownloadlist
            (source_server,
             operation_code,
             object_type,
             object_id,
             target_server)
      SELECT @local_machine_name,
             @operation_code,
             2,                  -- 2 means 'SERVER'
             CASE @operation_code
               WHEN 8 THEN CONVERT(UNIQUEIDENTIFIER, CONVERT(BINARY(16), -(@msx_time_zone_adjustment - sts.time_zone_adjustment)))
               WHEN 9 THEN CONVERT(UNIQUEIDENTIFIER, CONVERT(BINARY(16), @value))
               ELSE CONVERT(UNIQUEIDENTIFIER, 0x00)
             END,
             sts.server_name
      FROM systargetservers sts
      WHERE ((@specific_target_server_id IS NULL) OR (sts.server_id = @specific_target_server_id))
      SELECT @instructions_posted = @@rowcount
    END
    ELSE
    BEGIN
      RAISERROR(14266, -1, -1, '@operation_code', 'RE-ENLIST, DEFECT, SYNC-TIME, SET-POLL')
      RETURN(1) -- Failure
    END
  END


  -- Report number of rows inserted
  IF (@object_type = 'JOB') AND
     (@job_id = CONVERT(UNIQUEIDENTIFIER, 0x00)) AND
     (@instructions_posted = 0) AND
     (@specific_target_server_id IS NOT NULL)
    RAISERROR(14231, 0, 1, '@specific_target_server', @specific_target_server)
  ELSE
    RAISERROR(14230, 0, 1, @instructions_posted, @operation)

  -- Delete any [downloaded] instructions that are over the registry-defined limit
  IF (@specific_target_server IS NOT NULL)
    EXECUTE msdb.dbo.sp_downloaded_row_limiter @specific_target_server

  RETURN(0) -- 0 means success
END
go

/**************************************************************/
/* SP_DELETE_JOB_REFERENCES                                   */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_delete_job_references...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_delete_job_references')
              AND (type = 'P')))
  DROP PROCEDURE sp_delete_job_references
go
CREATE PROCEDURE sp_delete_job_references
AS
BEGIN
  DECLARE @deleted_job_id  UNIQUEIDENTIFIER
  DECLARE @task_id_as_char VARCHAR(10)
  DECLARE @job_is_cached   INT
  DECLARE @alert_name      sysname

  -- Keep SQLServerAgent's cache in-sync and cleanup any 'webtask' cross-references to the deleted job(s)
  -- NOTE: The caller must have created a table called #temp_jobs_to_delete of the format
  --       (job_id UNIQUEIDENTIFIER NOT NULL, job_is_cached INT NOT NULL).

  DECLARE sqlagent_notify CURSOR LOCAL
  FOR
  SELECT job_id, job_is_cached
  FROM #temp_jobs_to_delete

  OPEN sqlagent_notify
  FETCH NEXT FROM sqlagent_notify INTO @deleted_job_id, @job_is_cached

  WHILE (@@fetch_status = 0)
  BEGIN
    -- NOTE: We only notify SQLServerAgent if we know the job has been cached
    IF(@job_is_cached = 1)
      EXECUTE msdb.dbo.sp_sqlagent_notify @op_type     = N'J',
                                          @job_id      = @deleted_job_id,
                                          @action_type = N'D'

    IF (EXISTS (SELECT *
                FROM master.dbo.sysobjects
                WHERE (name = N'sp_cleanupwebtask')
                  AND (type = 'P')))
    BEGIN
      SELECT @task_id_as_char = CONVERT(VARCHAR(10), task_id)
      FROM msdb.dbo.systaskids
      WHERE (job_id = @deleted_job_id)
      IF (@task_id_as_char IS NOT NULL)
        EXECUTE ('master.dbo.sp_cleanupwebtask @taskid = ' + @task_id_as_char)
    END

    FETCH NEXT FROM sqlagent_notify INTO @deleted_job_id, @job_is_cached
  END
  DEALLOCATE sqlagent_notify

  -- Remove systaskid references (must do this AFTER sp_cleanupwebtask stuff)
  DELETE FROM msdb.dbo.systaskids
  WHERE job_id IN (SELECT job_id FROM #temp_jobs_to_delete)

  -- Remove sysdbmaintplan_jobs references
  DELETE FROM msdb.dbo.sysdbmaintplan_jobs
  WHERE job_id IN (SELECT job_id FROM #temp_jobs_to_delete)

  -- Finally, clean up any dangling references in sysalerts to the deleted job(s)
  DECLARE sysalerts_cleanup CURSOR LOCAL
  FOR
  SELECT name
  FROM msdb.dbo.sysalerts
  WHERE (job_id IN (SELECT job_id FROM #temp_jobs_to_delete))

  OPEN sysalerts_cleanup
  FETCH NEXT FROM sysalerts_cleanup INTO @alert_name
  WHILE (@@fetch_status = 0)
  BEGIN
    EXECUTE msdb.dbo.sp_update_alert @name   = @alert_name,
                                     @job_id = 0x00
    FETCH NEXT FROM sysalerts_cleanup INTO @alert_name
  END
  DEALLOCATE sysalerts_cleanup
END
go

/**************************************************************/
/* SP_DELETE_ALL_MSX_JOBS                                     */
/*                                                            */
/* NOTE: This is a separate procedure because SQLServerAgent  */
/*       needs to call it, as does sp_msx_defect and          */
/*       sp_delete_job.                                       */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_delete_all_msx_jobs...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_delete_all_msx_jobs')
              AND (type = 'P')))
  DROP PROCEDURE sp_delete_all_msx_jobs
go
CREATE PROCEDURE sp_delete_all_msx_jobs
  @msx_server   NVARCHAR(30),
  @jobs_deleted INT = NULL OUTPUT
AS
BEGIN
  SET NOCOUNT ON

  -- Change server name to always reflect real servername or servername\instancename
  IF (UPPER(@msx_server) = '(LOCAL)')
    SELECT @msx_server = UPPER(CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName')))

  -- Delete all the jobs that originated from the MSX
  CREATE TABLE #temp_jobs_to_delete (job_id UNIQUEIDENTIFIER NOT NULL, job_is_cached INT NOT NULL)

  -- NOTE: The left outer-join here is to handle the [unlikely] case of missing sysjobservers rows
  INSERT INTO #temp_jobs_to_delete
  SELECT sjv.job_id, CASE sjs.server_id WHEN 0 THEN 1 ELSE 0 END
  FROM msdb.dbo.sysjobs_view sjv
       LEFT OUTER JOIN msdb.dbo.sysjobservers sjs ON (sjv.job_id = sjs.job_id)
  WHERE (ISNULL(sjs.server_id, 0) = 0)
    AND (sjv.originating_server = @msx_server)

  -- Must do this before deleting the job itself since sp_sqlagent_notify does a lookup on sysjobs_view
  EXECUTE msdb.dbo.sp_delete_job_references

  BEGIN TRANSACTION

    DELETE FROM msdb.dbo.sysjobs_view
    WHERE job_id IN (SELECT job_id FROM #temp_jobs_to_delete)

    DELETE FROM msdb.dbo.sysjobservers
    WHERE job_id IN (SELECT job_id FROM #temp_jobs_to_delete)

    DELETE FROM msdb.dbo.sysjobsteps
    WHERE job_id IN (SELECT job_id FROM #temp_jobs_to_delete)

    DELETE FROM msdb.dbo.sysjobschedules
    WHERE job_id IN (SELECT job_id FROM #temp_jobs_to_delete)

    DELETE FROM msdb.dbo.sysjobhistory
    WHERE job_id IN (SELECT job_id FROM #temp_jobs_to_delete)

  COMMIT TRANSACTION

  SELECT @jobs_deleted = COUNT(*)
  FROM #temp_jobs_to_delete

  DROP TABLE #temp_jobs_to_delete
END
go

/**************************************************************/
/* SP_GENERATE_TARGET_SERVER_JOB_ASSIGNMENT_SQL               */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_generate_target_server_job_assignment_sql...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_generate_target_server_job_assignment_sql')
              AND (type = 'P')))
  DROP PROCEDURE sp_generate_target_server_job_assignment_sql
go
CREATE PROCEDURE sp_generate_target_server_job_assignment_sql
  @server_name     NVARCHAR(30) = NULL, 
  @new_server_name NVARCHAR(30) = NULL  -- Use this if the target server computer has been renamed
AS
BEGIN
  SET NOCOUNT ON

  -- Change server name to always reflect real servername or servername\instancename
  IF (@server_name IS NULL) OR (UPPER(@server_name) = '(LOCAL)')
    SELECT @server_name = UPPER(CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName')))

  -- Verify the server name
  IF (UPPER(@server_name) <> UPPER(CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName')))) AND
     (NOT EXISTS (SELECT *
                  FROM msdb.dbo.systargetservers
                  WHERE (server_name = @server_name)))
  BEGIN
    RAISERROR(14262, 16, 1, '@server_name', @server_name)
    RETURN(1) -- Failure
  END

  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobservers    sjs,
                   msdb.dbo.systargetservers sts
              WHERE (sjs.server_id = sts.server_id)
                AND (sts.server_name = @server_name)))
  BEGIN
    -- Generate the SQL
    SELECT 'Execute this SQL to re-assign jobs to the target server' =
           'EXECUTE msdb.dbo.sp_add_jobserver @job_id = ''' + CONVERT(VARCHAR(36), sjs.job_id) +
           ''', @server_name = ''' +  ISNULL(@new_server_name, sts.server_name) + ''''
    FROM msdb.dbo.sysjobservers    sjs,
         msdb.dbo.systargetservers sts
    WHERE (sjs.server_id = sts.server_id)
      AND (sts.server_name = @server_name)
  END
  ELSE
    RAISERROR(14548, 10, 1, @server_name)

  RETURN(0) -- Success
END
go

/**************************************************************/
/* SP_GENERATE_SERVER_DESCRIPTION                             */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_generate_server_description...'
go

IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_generate_server_description')
              AND (type = 'P')))
  DROP PROCEDURE sp_generate_server_description
go
CREATE PROCEDURE sp_generate_server_description
  @description NVARCHAR(100) = NULL OUTPUT,
  @result_set  BIT = 0
AS
BEGIN
  SET NOCOUNT ON

  CREATE TABLE #xp_results
  (
  id              INT           NOT NULL,
  name            NVARCHAR(30)  COLLATE database_default NOT NULL,
  internal_value  INT           NULL,
  character_value NVARCHAR(212) COLLATE database_default NULL
  )
  INSERT INTO #xp_results
  EXECUTE master.dbo.xp_msver

  UPDATE #xp_results
  SET character_value = FORMATMESSAGE(14205)
  WHERE (character_value IS NULL)

  SELECT @description = (SELECT character_value FROM #xp_results WHERE (id = 1)) + N' ' +
                        (SELECT character_value FROM #xp_results WHERE (id = 2)) + N' / Windows ' +
                        (SELECT character_value FROM #xp_results WHERE (id = 15)) + N' / ' +
                        (SELECT character_value FROM #xp_results WHERE (id = 16)) + N' ' +
                        (SELECT CASE character_value
                                  WHEN N'PROCESSOR_INTEL_386'     THEN N'386'
                                  WHEN N'PROCESSOR_INTEL_486'     THEN N'486'
                                  WHEN N'PROCESSOR_INTEL_PENTIUM' THEN N'Pentium'
                                  WHEN N'PROCESSOR_MIPS_R4000'    THEN N'MIPS'
                                  WHEN N'PROCESSOR_ALPHA_21064'   THEN N'Alpha'
                                  ELSE character_value
                                END
                         FROM #xp_results WHERE (id = 18)) + N' CPU(s) / ' +
                        (SELECT CONVERT(NVARCHAR, internal_value) FROM #xp_results WHERE (id = 19)) + N' MB RAM.'
  DROP TABLE #xp_results
  IF (@result_set = 1)
    SELECT @description
END
go

/**************************************************************/
/* SP_MSX_ENLIST                                              */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_msx_enlist...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = 'sp_msx_enlist')
              AND (type = 'P')))
  DROP PROCEDURE sp_msx_enlist
go
CREATE PROCEDURE sp_msx_enlist
  @msx_server_name NVARCHAR(30),
  @location        NVARCHAR(100) = NULL, -- The procedure will supply a default
  @ping_server     BIT = 1               -- Set to 0 to skip the MSX ping test
AS
BEGIN
  DECLARE @current_msx_server   NVARCHAR(30)
  DECLARE @local_machine_name   NVARCHAR(30)
  DECLARE @retval               INT
  DECLARE @time_zone_adjustment INT
  DECLARE @local_time           NVARCHAR(100)
  DECLARE @nt_user              NVARCHAR(100)
  DECLARE @poll_interval        INT

  SET NOCOUNT ON

  -- Only a sysadmin can do this
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  -- Only an NT server can be enlisted
  IF ((PLATFORM() & 0x1) <> 0x1) -- NT
  BEGIN
    RAISERROR(14540, -1, 1)
    RETURN(1) -- Failure
  END

  -- Only SBS, Standard, or Enterprise editions of SQL Server can be enlisted
  IF ((PLATFORM() & 0x100) = 0x100) -- Desktop package
  BEGIN
    RAISERROR(14539, -1, -1)
    RETURN(1) -- Failure
  END

  -- Remove any leading/trailing spaces from parameters
  SELECT @msx_server_name = LTRIM(RTRIM(@msx_server_name))
  SELECT @location        = LTRIM(RTRIM(@location))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@location = N'') SELECT @location = NULL

  -- Change to MSX server name to upper-case since it's a machine name
--  SELECT @msx_server_name = UPPER(@msx_server_name)

  SELECT @retval = 0

  -- Get the values that we'll need for the [re]enlistment operation (except the local time
  -- which we get right before we call xp_msx_enlist to that it's as accurate as possible)
  SELECT @nt_user = ISNULL(NT_CLIENT(), ISNULL(SUSER_SNAME(), FORMATMESSAGE(14205)))
  EXECUTE master.dbo.xp_regread N'HKEY_LOCAL_MACHINE',
                                N'SYSTEM\CurrentControlSet\Control\TimeZoneInformation',
                                N'Bias',
                                @time_zone_adjustment OUTPUT,
                                N'no_output'
  IF ((PLATFORM() & 0x1) = 0x1) -- NT
    SELECT @time_zone_adjustment = -ISNULL(@time_zone_adjustment, 0)
  ELSE
    SELECT @time_zone_adjustment = -CONVERT(INT, CONVERT(BINARY(2), ISNULL(@time_zone_adjustment, 0)))

  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'MSXPollInterval',
                                         @poll_interval OUTPUT,
                                         N'no_output'
  SELECT @poll_interval = ISNULL(@poll_interval, 60) -- This should be the same as DEF_REG_MSX_POLL_INTERVAL
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'MSXServerName',
                                         @current_msx_server OUTPUT,
                                         N'no_output'
  SELECT @current_msx_server = LTRIM(RTRIM(@current_msx_server))
  
  -- Check if this machine is an MSX (and therefore cannot be enlisted into another MSX)
  IF (EXISTS (SELECT *
              FROM msdb.dbo.systargetservers))
  BEGIN
	--Get local server/instance name
	SELECT @local_machine_name = UPPER(CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName')))
	
    RAISERROR(14299, -1, -1, @local_machine_name)
    RETURN(1) -- Failure
  END

  -- Check if the MSX supplied is the same as the local machine (this is not allowed)
/*  IF (UPPER(@local_machine_name) = UPPER(@msx_server_name))
  BEGIN
    RAISERROR(14297, -1, -1)
    RETURN(1) -- Failure
  END*/

  -- Check if MSDB has be re-installed since we enlisted
  IF (@current_msx_server IS NOT NULL) AND
     (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sqlagent_info
                  WHERE (attribute = 'DateEnlisted')))
  BEGIN
    -- User is tring to [re]enlist after a re-install, so we have to forcefully defect before
    -- we can fully enlist again
    EXECUTE msdb.dbo.sp_msx_defect @forced_defection = 1
    SELECT @current_msx_server = NULL
  END

  -- Check if we are already enlisted, in which case we re-enlist
  IF ((@current_msx_server IS NOT NULL) AND (@current_msx_server <> N''))
  BEGIN
    IF (UPPER(@current_msx_server) = UPPER(@msx_server_name))
    BEGIN
      -- Update the [existing] enlistment
      SELECT @local_time = CONVERT(NVARCHAR, GETDATE(), 112) + N' ' + CONVERT(NVARCHAR, GETDATE(), 108)
      EXECUTE @retval = master.dbo.xp_msx_enlist 2, @msx_server_name, @nt_user, @location, @time_zone_adjustment, @local_time, @poll_interval
      RETURN(@retval) -- 0 means success
    END
    ELSE
    BEGIN
      RAISERROR(14296, -1, -1, @current_msx_server)
      RETURN(1) -- Failure
    END
  END

  -- If we get this far then we're dealing with a new enlistment...

  -- Check if the MSX supplied exists on the network

  IF (@ping_server = 1)
  BEGIN
    DECLARE @msx_machine_name NVARCHAR (30)
    DECLARE @char_index       INT

    SELECT @char_index = CHARINDEX (N'\', @msx_server_name)
    IF (@char_index > 0)
    BEGIN
      SELECT @msx_machine_name = LEFT (@msx_server_name, @char_index - 1)
    END
    ELSE
    BEGIN
      SELECT @msx_machine_name = @msx_server_name
    END

    IF ((PLATFORM() & 0x2) = 0x2) -- Win9x
    BEGIN
      EXECUTE(N'CREATE TABLE #output (output NVARCHAR(1024) COLLATE database_default)
                SET NOCOUNT ON
                INSERT INTO #output
                EXECUTE master.dbo.xp_cmdshell N''net view \\' + @msx_machine_name + N'''
                IF (EXISTS (SELECT *
                            FROM #output
                            WHERE (output LIKE N''% 53%'')))
                   RAISERROR(14262, -1, -1, N''@msx_server_name'', N''' + @msx_machine_name + N''') WITH SETERROR')
      IF (@@error <> 0)
        RETURN(1) -- Failure
    END
    ELSE
    BEGIN
      EXECUTE(N'DECLARE @retval INT
                SET NOCOUNT ON
                EXECUTE @retval = master.dbo.xp_cmdshell N''net view \\' + @msx_machine_name + N' > nul'', no_output
                IF (@retval <> 0)
                  RAISERROR(14262, -1, -1, N''@msx_server_name'', N''' + @msx_machine_name + N''') WITH SETERROR')
      IF (@@error <> 0)
        RETURN(1) -- Failure
    END
  END

  -- If no location is supplied, generate one (such as we can)
  IF (@location IS NULL)
    EXECUTE msdb.dbo.sp_generate_server_description @location OUTPUT

  SELECT @local_time = CONVERT(NVARCHAR, GETDATE(), 112) + ' ' + CONVERT(NVARCHAR, GETDATE(), 108)
  EXECUTE @retval = master.dbo.xp_msx_enlist 0, @msx_server_name, @nt_user, @location, @time_zone_adjustment, @local_time, @poll_interval

  IF (@retval = 0)
  BEGIN
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'MSXServerName',
                                            N'REG_SZ',
                                            @msx_server_name

    IF (@current_msx_server IS NOT NULL)
      RAISERROR(14228, 0, 1, @current_msx_server, @msx_server_name)
    ELSE
      RAISERROR(14229, 0, 1, @msx_server_name)

    -- Add entry to sqlagent_info
    INSERT INTO msdb.dbo.sqlagent_info (attribute, value) VALUES ('DateEnlisted', CONVERT(VARCHAR(10), GETDATE(), 112))
  END

  RETURN(@retval) -- 0 means success
END
go

/**************************************************************/
/* SP_MSX_DEFECT                                              */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_msx_defect...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_msx_defect')
              AND (type = 'P')))
  DROP PROCEDURE sp_msx_defect
go
CREATE PROCEDURE sp_msx_defect
  @forced_defection BIT = 0
AS
BEGIN
  DECLARE @current_msx_server NVARCHAR(30)
  DECLARE @retval             INT
  DECLARE @jobs_deleted       INT
  DECLARE @polling_interval   INT
  DECLARE @nt_user            NVARCHAR(100)

  SET NOCOUNT ON

  -- Only a sysadmin can do this
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  SELECT @retval = 0
  SELECT @jobs_deleted = 0

  -- Get the current MSX server name from the registry
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'MSXServerName',
                                         @current_msx_server OUTPUT,
                                         N'no_output'

  SELECT @current_msx_server = LTRIM(RTRIM(@current_msx_server))
  IF ((@current_msx_server IS NULL) OR (@current_msx_server = N''))
  BEGIN
    RAISERROR(14298, -1, -1)
    RETURN(1) -- Failure
  END

  SELECT @nt_user = ISNULL(NT_CLIENT(), ISNULL(SUSER_SNAME(), FORMATMESSAGE(14205)))

  EXECUTE @retval = master.dbo.xp_msx_enlist 1, @current_msx_server, @nt_user

  IF (@retval <> 0) AND (@forced_defection = 0)
    RETURN(1) -- Failure

  -- Clear the MSXServerName registry entry
  EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                          N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                          N'MSXServerName',
                                          N'REG_SZ',
                                          N''

  -- Delete the MSXPollingInterval registry entry
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'MSXPollInterval',
                                         @polling_interval OUTPUT,
                                         N'no_output'
  IF (@polling_interval IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regdeletevalue N'HKEY_LOCAL_MACHINE',
                                                  N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                                  N'MSXPollInterval'

  -- Remove the entry from sqlagent_info
  DELETE FROM msdb.dbo.sqlagent_info
  WHERE (attribute = N'DateEnlisted')

  -- Delete all the jobs that originated from the MSX
  -- NOTE: We can't use sp_delete_job here since sp_delete_job checks if the caller is
  --       SQLServerAgent (only SQLServerAgent can delete non-local jobs).
  EXECUTE msdb.dbo.sp_delete_all_msx_jobs @current_msx_server, @jobs_deleted OUTPUT
  RAISERROR(14227, 0, 1, @current_msx_server, @jobs_deleted)

  -- If a forced defection was performed, attempt to notify the MSXOperator
  IF (@forced_defection = 1)
  BEGIN
    DECLARE @network_address    NVARCHAR(100)
    DECLARE @command            NVARCHAR(512)
    DECLARE @local_machine_name NVARCHAR(30)
    DECLARE @res_warning        NVARCHAR(300)

    SELECT @network_address = netsend_address
    FROM msdb.dbo.sysoperators
    WHERE (name = N'MSXOperator')

    IF (@network_address IS NOT NULL)
    BEGIN
      EXECUTE @retval = master.dbo.xp_getnetname @local_machine_name OUTPUT
      IF (@retval <> 0)
        RETURN(1) -- Failure
      SELECT @res_warning = FORMATMESSAGE(14217)
      SELECT @command = N'NET SEND ' + @network_address + N' ' + @res_warning
      SELECT @command = STUFF(@command, PATINDEX(N'%[%%]s%', @command), 2, NT_CLIENT())
      SELECT @command = STUFF(@command, PATINDEX(N'%[%%]s%', @command), 2, @local_machine_name)
      EXECUTE master.dbo.xp_cmdshell @command, no_output
    END
  END

  -- Delete the 'MSXOperator' (must do this last)
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysoperators
              WHERE (name = N'MSXOperator')))
    EXECUTE msdb.dbo.sp_delete_operator @name = N'MSXOperator'

  RETURN(0) -- 0 means success
END
go

/**************************************************************/
/* SP_ENLIST_TSX                                                                                                         */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_enlist_tsx' 
go

IF EXISTS (SELECT name FROM sysobjects 
         WHERE name = 'sp_enlist_tsx' AND type = 'P')
   DROP PROCEDURE sp_enlist_tsx
GO

print N'Creating stored procedure sp_enlist_tsx'
go
create proc sp_enlist_tsx
	@Action int,			-- 0 - enlist; 1 - defect; 2 - update
	@ServerName  nvarchar(30),	-- tsx server name
	@Location  nvarchar(200),	-- tsx server location
	@TimeZoneAdjustment int,	-- tsx server time zone adjustment
	@LocalTime datetime,		-- tsx server local time
	@NTUserName nvarchar(100),	-- name of the user performing the enlistment
	@PollInterval int		-- polling interval
as
begin
   SET NOCOUNT ON

   /* check permissions */
   IF (not is_srvrolemember(N'TargetServerRole') = 1)
   begin
	raiserror(15003,-1,-1, N'TargetServerRole')
	return 1
   end

   /* check input parameters */
   if @ServerName is null
   begin
	raiserror(14043, -1, -1, '@ServerName')
	return 2
   end

   select @ServerName = LTRIM(@ServerName)
   select @ServerName = RTRIM(@ServerName)
   if @ServerName = ''
   begin
	raiserror(21263, -1, -1, '@ServerName')
	return 3
   end

   if @Action <> 1 And @Action <> 2
   begin
	/* default action is to enlist */
	select @Action = 0
   end

  if @Action = 0 /* enlisting */
  begin
	/* check input parameters */
	if @NTUserName is null
	begin
	   raiserror(14043, -1, -1, '@NTUserName')
	   return 4
	end

	select @NTUserName = LTRIM(@NTUserName)
	select @NTUserName = RTRIM(@NTUserName)
	if @NTUserName = ''
	begin
	  raiserror(21263, -1, -1, '@NTUserName')
	  return 5
	end

	/* check if local server is already configured as TSX machine */
	declare @msx_server_name NVARCHAR(128)
	select @msx_server_name = N''

	execute master.dbo.xp_instance_regread 
		N'HKEY_LOCAL_MACHINE',
		N'Software\Microsoft\MSSQLServer\SQLServerAgent',
		N'MSXServerName',
		@msx_server_name OUTPUT

	select @msx_server_name = LTRIM(@msx_server_name)
	select @msx_server_name = RTRIM(@msx_server_name)
	if @msx_server_name <> N''
	begin
	   raiserror(14360, -1, -1, @@SERVERNAME)
	   return 6
	end

	/* 
	* check that local server is not running a desktop SKU, 
	* i.e. Win9x, Office, or MSDE
	*/
	if( PLATFORM() & 0x100 = 0x100 )
	begin
	   raiserror(14362, -1, -1)
	   return 8
	end

	/* check if we have any MSXOperators defined */
	if not exists (SELECT * FROM msdb.dbo.sysoperators WHERE name = N'MSXOperator')
	begin
	   raiserror(14363, -1, -1)
	   return 9
	end

	/* all checks have passed, insert new row into systargetservers table */
	INSERT INTO msdb.dbo.systargetservers 
	(
	server_name, 
	location, 
	time_zone_adjustment, 
	enlist_date, 
	last_poll_date, 
	status, 
	local_time_at_last_poll, 
	enlisted_by_nt_user, 
	poll_interval
	) 
	VALUES 
	(
	@ServerName, 
	@Location, 
	@TimeZoneAdjustment, 
	GETDATE(), 
	GETDATE(), 
	1, 
	@LocalTime, 
	@NTUserName, 
	@PollInterval
	)

	/* delete hanging rows from sysdownloadlist */
	DELETE FROM msdb.dbo.sysdownloadlist 
	WHERE target_server = @ServerName
   end

   if @Action = 2 /* updating existing enlistment */
   begin
	/* check if we have any MSXOperators defined */
	if not exists (SELECT * FROM msdb.dbo.sysoperators WHERE name = N'MSXOperator')
	begin
	   raiserror(14363, -1, -1)
	   return 10
	end

	/* check if TSX machine is already enlisted */
	If not exists (SELECT * FROM msdb.dbo.systargetservers WHERE server_name =@ServerName)
	begin
	   raiserror(14364, -1, -1)
	   return 11
	end

	if @Location is null /* don't update the location if it is not supplied */
	begin
		UPDATE msdb.dbo.systargetservers SET 
		time_zone_adjustment = @TimeZoneAdjustment, 
		poll_interval = @PollInterval
		WHERE (server_name = @ServerName)
	end
	else
	begin
		UPDATE msdb.dbo.systargetservers SET 
		location = @Location, 
		time_zone_adjustment = @TimeZoneAdjustment, 
		poll_interval = @PollInterval
		WHERE (server_name = @ServerName)
	end
   end

  if @Action = 1 /* defecting */
  begin
	if (exists (SELECT * FROM msdb.dbo.systargetservers WHERE server_name = @ServerName)) 
	begin
		execute msdb.dbo.sp_delete_targetserver 
			@server_name = @ServerName, 
			@post_defection = 0 
	end
	else
	begin
		DELETE FROM msdb.dbo.sysdownloadlist 
		WHERE (target_server = @ServerName)
	end
  end

  if @Action = 0 Or @Action = 2 /* enlisting or updating existing enlistment */
  begin
	/* select resultset to return to the caller */
	SELECT 
	id,
	name, 
	enabled, 
	email_address, 
	pager_address, 
	netsend_address, 
	weekday_pager_start_time, 
	weekday_pager_end_time, 
	saturday_pager_start_time, 
	saturday_pager_end_time, 
	sunday_pager_start_time, 
	sunday_pager_end_time, 
	pager_days 
	FROM 
	msdb.dbo.sysoperators WHERE (name = N'MSXOperator')
   end
end
go

grant execute on sp_enlist_tsx to public
go

/**************************************************************/
/* SP_GET_SQLAGENT_PROPERTIES                                 */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_get_sqlagent_properties...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_get_sqlagent_properties')
              AND (type = 'P')))
  DROP PROCEDURE sp_get_sqlagent_properties
go
CREATE PROCEDURE sp_get_sqlagent_properties
AS
BEGIN
  DECLARE @auto_start                  INT
  DECLARE @startup_account             NVARCHAR(100)
  DECLARE @msx_server_name             NVARCHAR(30)

  -- Non-SQLDMO exposed properties
  DECLARE @sqlserver_restart           INT
  DECLARE @jobhistory_max_rows         INT
  DECLARE @jobhistory_max_rows_per_job INT
  DECLARE @errorlog_file               NVARCHAR(255)
  DECLARE @errorlogging_level          INT
  DECLARE @error_recipient             NVARCHAR(30)
  DECLARE @monitor_autostart           INT
  DECLARE @local_host_server           NVARCHAR(30)
  DECLARE @job_shutdown_timeout        INT
  DECLARE @cmdexec_account             VARBINARY(64)
  DECLARE @regular_connections         INT
  DECLARE @host_login_name             sysname
  DECLARE @host_login_password         VARBINARY(512)
  DECLARE @login_timeout               INT
  DECLARE @idle_cpu_percent            INT
  DECLARE @idle_cpu_duration           INT
  DECLARE @oem_errorlog                INT
  DECLARE @sysadmin_only               INT
  DECLARE @email_profile               NVARCHAR(64)
  DECLARE @email_save_in_sent_folder   INT
  DECLARE @cpu_poller_enabled          INT

  SET NOCOUNT ON

  -- NOTE: We return all SQLServerAgent properties at one go for performance reasons

  -- Read the values from the registry
  IF ((PLATFORM() & 0x1) = 0x1) -- NT
  BEGIN
    DECLARE @key NVARCHAR(200)

    SELECT @key = N'SYSTEM\CurrentControlSet\Services\'
    IF (SERVERPROPERTY('INSTANCENAME') IS NOT NULL)
      SELECT @key = @key + N'SQLAgent$' + CONVERT (sysname, SERVERPROPERTY('INSTANCENAME'))
    ELSE
      SELECT @key = @key + N'SQLServerAgent'

    EXECUTE master.dbo.xp_regread N'HKEY_LOCAL_MACHINE',
                                  @key,
                                  N'Start',
                                  @auto_start OUTPUT,
                                  N'no_output'
    EXECUTE master.dbo.xp_regread N'HKEY_LOCAL_MACHINE',
                                  @key,
                                  N'ObjectName',
                                  @startup_account OUTPUT,
                                  N'no_output'
  END
  ELSE
  BEGIN
    SELECT @auto_start = 3 -- Manual start
    SELECT @startup_account = NULL
  END
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'MSXServerName',
                                         @msx_server_name OUTPUT,
                                         N'no_output'

  -- Non-SQLDMO exposed properties
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'RestartSQLServer',
                                         @sqlserver_restart OUTPUT,
                                         N'no_output'
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'JobHistoryMaxRows',
                                         @jobhistory_max_rows OUTPUT,
                                         N'no_output'
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'JobHistoryMaxRowsPerJob',
                                         @jobhistory_max_rows_per_job OUTPUT,
                                         N'no_output'
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'ErrorLogFile',
                                         @errorlog_file OUTPUT,
                                         N'no_output'
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'ErrorLoggingLevel',
                                         @errorlogging_level OUTPUT,
                                         N'no_output'
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'ErrorMonitor',
                                         @error_recipient OUTPUT,
                                         N'no_output'
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'MonitorAutoStart',
                                         @monitor_autostart OUTPUT,
                                         N'no_output'
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'ServerHost',
                                         @local_host_server OUTPUT,
                                         N'no_output'
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'JobShutdownTimeout',
                                         @job_shutdown_timeout OUTPUT,
                                         N'no_output'
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'CmdExecAccount',
                                         @cmdexec_account OUTPUT,
                                         N'no_output'
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'RegularConnections',
                                         @regular_connections OUTPUT,
                                         N'no_output'
  DECLARE @OS int
  EXECUTE master.dbo.xp_MSplatform @OS OUTPUT

  IF (@OS = 2)
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'HostLoginID',
                                         @host_login_name OUTPUT,
                                         N'no_output'
  ELSE
  EXECUTE master.dbo.xp_sqlagent_param   0, 
                                         N'HostLoginID',
                                         @host_login_name OUTPUT

  
  --check permissions
   IF (is_srvrolemember(N'sysadmin') = 1)
   begin
    IF (@OS = 2)
        EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'HostPassword',
                                         @host_login_password OUTPUT,
                                         N'no_output'
    ELSE
        EXECUTE master.dbo.xp_sqlagent_param   0, 
                                         N'HostPassword',
                                         @host_login_password OUTPUT      
   end
   ELSE
       SELECT  @host_login_password = 0
  
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'LoginTimeout',
                                         @login_timeout OUTPUT,
                                         N'no_output'
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'IdleCPUPercent',
                                         @idle_cpu_percent OUTPUT,
                                         N'no_output'
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'IdleCPUDuration',
                                         @idle_cpu_duration OUTPUT,
                                         N'no_output'
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'OemErrorLog',
                                         @oem_errorlog OUTPUT,
                                         N'no_output'
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'SysAdminOnly',
                                         @sysadmin_only OUTPUT,
                                         N'no_output'
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'EmailProfile',
                                         @email_profile OUTPUT,
                                         N'no_output'
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'EmailSaveSent',
                                         @email_save_in_sent_folder OUTPUT,
                                         N'no_output'
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'CoreEngineMask',
                                         @cpu_poller_enabled OUTPUT,
                                         N'no_output'
  IF (@cpu_poller_enabled IS NOT NULL)
    SELECT @cpu_poller_enabled = CASE WHEN (@cpu_poller_enabled & 32) = 32 THEN 0 ELSE 1 END

  -- Return the values to the client
  SELECT auto_start = CASE @auto_start
                        WHEN 2 THEN 1 -- 2 means auto-start
                        WHEN 3 THEN 0 -- 3 means don't auto-start
                        ELSE 0        -- Safety net
                      END,
         msx_server_name = @msx_server_name,
         sqlagent_type = (SELECT CASE
                                    WHEN (COUNT(*) = 0) AND (ISNULL(DATALENGTH(@msx_server_name), 0) = 0) THEN 1 -- Standalone
                                    WHEN (COUNT(*) = 0) AND (ISNULL(DATALENGTH(@msx_server_name), 0) > 0) THEN 2 -- TSX
                                    WHEN (COUNT(*) > 0) AND (ISNULL(DATALENGTH(@msx_server_name), 0) = 0) THEN 3 -- MSX
                                    WHEN (COUNT(*) > 0) AND (ISNULL(DATALENGTH(@msx_server_name), 0) > 0) THEN 0 -- Multi-Level MSX (currently invalid)
                                    ELSE 0 -- Invalid
                                  END
                           FROM msdb.dbo.systargetservers),
         startup_account = @startup_account,

         -- Non-SQLDMO exposed properties
         sqlserver_restart = @sqlserver_restart,
         jobhistory_max_rows = @jobhistory_max_rows,
         jobhistory_max_rows_per_job = @jobhistory_max_rows_per_job,
         errorlog_file = @errorlog_file,
         errorlogging_level = ISNULL(@errorlogging_level, 7),
         error_recipient = @error_recipient,
         monitor_autostart = ISNULL(@monitor_autostart, 0),
         local_host_server = @local_host_server,
         job_shutdown_timeout = ISNULL(@job_shutdown_timeout, 15),
         cmdexec_account = @cmdexec_account,
         regular_connections = ISNULL(@regular_connections, 0),
         host_login_name = @host_login_name,
         host_login_password = @host_login_password,
         login_timeout = ISNULL(@login_timeout, 30),
         idle_cpu_percent = ISNULL(@idle_cpu_percent, 10),
         idle_cpu_duration = ISNULL(@idle_cpu_duration, 600),
         oem_errorlog = ISNULL(@oem_errorlog, 0),
         sysadmin_only = ISNULL(@sysadmin_only, 0),
         email_profile = @email_profile,
         email_save_in_sent_folder = ISNULL(@email_save_in_sent_folder, 0),
         cpu_poller_enabled = ISNULL(@cpu_poller_enabled, 0)
END
go

/**************************************************************/
/* SP_SET_SQLAGENT_PROPERTIES                                 */
/**************************************************************/
IF EXISTS (SELECT * FROM msdb.dbo.sysobjects WHERE name = N'sp_set_sqlagent_properties' AND type = 'P')
BEGIN
  DROP PROCEDURE dbo.sp_set_sqlagent_properties
END
go

PRINT ''
PRINT 'Create procedure sp_set_sqlagent_properties...'
go

CREATE PROCEDURE dbo.sp_set_sqlagent_properties
  @auto_start                  INT           = NULL, -- 1 or 0
  -- Non-SQLDMO exposed properties
  @sqlserver_restart           INT           = NULL, -- 1 or 0
  @jobhistory_max_rows         INT           = NULL, -- No maximum = -1, otherwise must be > 1
  @jobhistory_max_rows_per_job INT           = NULL, -- 1 to @jobhistory_max_rows
  @errorlog_file               NVARCHAR(255) = NULL, -- Full drive\path\name of errorlog file
  @errorlogging_level          INT           = NULL, -- 1 = error, 2 = warning, 4 = information
  @error_recipient             NVARCHAR(30)  = NULL, -- Network address of error popup recipient
  @monitor_autostart           INT           = NULL, -- 1 or 0
  @local_host_server           NVARCHAR(30)  = NULL, -- Alias of local host server
  @job_shutdown_timeout        INT           = NULL, -- 5 to 600 seconds
  @cmdexec_account             VARBINARY(64) = NULL, -- CmdExec account information
  @regular_connections         INT           = NULL, -- 1 or 0
  @host_login_name             sysname       = NULL, -- Login name (if regular_connections = 1)
  @host_login_password         VARBINARY(512) = NULL, -- Login password (if regular_connections = 1)
  @login_timeout               INT           = NULL, -- 5 to 45 (seconds)
  @idle_cpu_percent            INT           = NULL, -- 1 to 100
  @idle_cpu_duration           INT           = NULL, -- 20 to 86400 seconds
  @oem_errorlog                INT           = NULL, -- 1 or 0
  @sysadmin_only               INT           = NULL, -- 1 or 0
  @email_profile               NVARCHAR(64)  = NULL, -- Email profile name
  @email_save_in_sent_folder   INT           = NULL, -- 1 or 0
  @cpu_poller_enabled          INT           = NULL  -- 1 or 0
AS
BEGIN
  -- NOTE: We set all SQLServerAgent properties at one go for performance reasons.
  -- NOTE: You cannot set the value of the properties msx_server_name, is_msx or
  --       startup_account - they are all read only.

  DECLARE @res_valid_range           NVARCHAR(100)
  DECLARE @existing_core_engine_mask INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @errorlog_file     = LTRIM(RTRIM(@errorlog_file))
  SELECT @error_recipient   = LTRIM(RTRIM(@error_recipient))
  SELECT @local_host_server = LTRIM(RTRIM(@local_host_server))
  SELECT @host_login_name   = LTRIM(RTRIM(@host_login_name))
  SELECT @email_profile     = LTRIM(RTRIM(@email_profile))

  -- Make sure values (if supplied) are good
  IF (@auto_start IS NOT NULL)
  BEGIN
    -- NOTE: When setting the the services start value, 2 == auto-start, 3 == Don't auto-start
    SELECT @auto_start = CASE @auto_start
                           WHEN 0 THEN 3
                           WHEN 1 THEN 2
                           ELSE 3 -- Assume non auto-start if passed a junk value
                          END
  END

  -- Non-SQLDMO exposed properties
  IF ((@sqlserver_restart IS NOT NULL) AND (@sqlserver_restart <> 0))
    SELECT @sqlserver_restart = 1

  IF (@jobhistory_max_rows IS NOT NULL)
  BEGIN
    SELECT @res_valid_range = FORMATMESSAGE(14207)
    IF ((@jobhistory_max_rows < -1) OR (@jobhistory_max_rows = 0))
    BEGIN
      RAISERROR(14266, -1, -1, '@jobhistory_max_rows', @res_valid_range)
      RETURN(1) -- Failure
    END
  END
  ELSE
  BEGIN
    EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                           N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                           N'JobHistoryMaxRows',
                                           @jobhistory_max_rows OUTPUT,
                                           N'no_output'
    SELECT @jobhistory_max_rows = ISNULL(@jobhistory_max_rows, -1)
  END

  IF (@jobhistory_max_rows_per_job IS NOT NULL)
  BEGIN
    IF (@jobhistory_max_rows = -1)
      SELECT @jobhistory_max_rows_per_job = 0
    ELSE
    BEGIN
      IF ((@jobhistory_max_rows_per_job < 1) OR (@jobhistory_max_rows_per_job > @jobhistory_max_rows))
      BEGIN
        SELECT @res_valid_range = N'1..' + CONVERT(NVARCHAR, @jobhistory_max_rows)
        RAISERROR(14266, -1, -1, '@jobhistory_max_rows', @res_valid_range)
        RETURN(1) -- Failure
      END
    END
  END

  IF (@errorlogging_level IS NOT NULL) AND ((@errorlogging_level < 1) OR (@errorlogging_level > 7))
  BEGIN
    RAISERROR(14266, -1, -1, '@errorlogging_level', '1..7')
    RETURN(1) -- Failure
  END

  IF (@monitor_autostart IS NOT NULL) AND ((@monitor_autostart < 0) OR (@monitor_autostart > 1))
  BEGIN
    RAISERROR(14266, -1, -1, '@monitor_autostart', '0, 1')
    RETURN(1) -- Failure
  END

  IF (@job_shutdown_timeout IS NOT NULL) AND ((@job_shutdown_timeout < 5) OR (@job_shutdown_timeout > 600))
  BEGIN
    RAISERROR(14266, -1, -1, '@job_shutdown_timeout', '5..600')
    RETURN(1) -- Failure
  END

  IF (@regular_connections IS NOT NULL) AND ((@regular_connections < 0) OR (@regular_connections > 1))
  BEGIN
    RAISERROR(14266, -1, -1, '@regular_connections', '0, 1')
    RETURN(1) -- Failure
  END

  IF (@login_timeout IS NOT NULL) AND ((@login_timeout < 5) OR (@login_timeout > 45))
  BEGIN
    RAISERROR(14266, -1, -1, '@login_timeout', '5..45')
    RETURN(1) -- Failure
  END

  IF ((@idle_cpu_percent IS NOT NULL) AND ((@idle_cpu_percent < 1) OR (@idle_cpu_percent > 100)))
  BEGIN
    RAISERROR(14266, -1, -1, '@idle_cpu_percent', '10..100')
    RETURN(1) -- Failure
  END

  IF ((@idle_cpu_duration IS NOT NULL) AND ((@idle_cpu_duration < 20) OR (@idle_cpu_duration > 86400)))
  BEGIN
    RAISERROR(14266, -1, -1, '@idle_cpu_duration', '20..86400')
    RETURN(1) -- Failure
  END

  IF (@oem_errorlog IS NOT NULL) AND ((@oem_errorlog < 0) OR (@oem_errorlog > 1))
  BEGIN
    RAISERROR(14266, -1, -1, '@oem_errorlog', '0, 1')
    RETURN(1) -- Failure
  END

  IF (@sysadmin_only IS NOT NULL) AND ((@sysadmin_only < 0) OR (@sysadmin_only > 1))
  BEGIN
    RAISERROR(14266, -1, -1, '@sysadmin_only', '0, 1')
    RETURN(1) -- Failure
  END

  IF (@email_save_in_sent_folder IS NOT NULL) AND ((@email_save_in_sent_folder < 0) OR (@email_save_in_sent_folder > 1))
  BEGIN
    RAISERROR(14266, -1, -1, 'email_save_in_sent_folder', '0, 1')
    RETURN(1) -- Failure
  END

  IF (@cpu_poller_enabled IS NOT NULL) AND ((@cpu_poller_enabled < 0) OR (@cpu_poller_enabled > 1))
  BEGIN
    RAISERROR(14266, -1, -1, 'cpu_poller_enabled', '0, 1')
    RETURN(1) -- Failure
  END

  -- Write out the values
  IF (@auto_start IS NOT NULL)
  BEGIN
    IF ((PLATFORM() & 0x1) = 0x1) -- NT
    BEGIN
      DECLARE @key NVARCHAR(200)

      SELECT @key = N'SYSTEM\CurrentControlSet\Services\'
      IF (SERVERPROPERTY('INSTANCENAME') IS NOT NULL)
        SELECT @key = @key + N'SQLAgent$' + CONVERT (sysname, SERVERPROPERTY('INSTANCENAME'))
      ELSE
        SELECT @key = @key + N'SQLServerAgent'

      EXECUTE master.dbo.xp_regwrite N'HKEY_LOCAL_MACHINE',
                                     @key,
                                     N'Start',
                                     N'REG_DWORD',
                                     @auto_start
    END
    ELSE
      RAISERROR(14546, 16, 1, '@auto_start')
  END

  -- Non-SQLDMO exposed properties
  IF (@sqlserver_restart IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'RestartSQLServer',
                                            N'REG_DWORD',
                                            @sqlserver_restart
  IF (@jobhistory_max_rows IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'JobHistoryMaxRows',
                                            N'REG_DWORD',
                                            @jobhistory_max_rows
  IF (@jobhistory_max_rows_per_job IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'JobHistoryMaxRowsPerJob',
                                            N'REG_DWORD',
                                            @jobhistory_max_rows_per_job
  IF (@errorlog_file IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'ErrorLogFile',
                                            N'REG_SZ',
                                            @errorlog_file
  IF (@errorlogging_level IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'ErrorLoggingLevel',
                                            N'REG_DWORD',
                                            @errorlogging_level
  IF (@error_recipient IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'ErrorMonitor',
                                            N'REG_SZ',
                                            @error_recipient
  IF (@monitor_autostart IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'MonitorAutoStart',
                                            N'REG_DWORD',
                                            @monitor_autostart
  IF (@local_host_server IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'ServerHost',
                                            N'REG_SZ',
                                            @local_host_server
  IF (@job_shutdown_timeout IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'JobShutdownTimeout',
                                            N'REG_DWORD',
                                            @job_shutdown_timeout
  IF (@cmdexec_account IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'CmdExecAccount',
                                            N'REG_BINARY',
                                            @cmdexec_account
  IF (@regular_connections IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'RegularConnections',
                                            N'REG_DWORD',
                                            @regular_connections

  DECLARE @OS int
  EXECUTE master.dbo.xp_MSplatform @OS OUTPUT

  IF (@regular_connections = 0)
  BEGIN
    IF (@OS = 2)
    BEGIN
      EXECUTE master.dbo.xp_instance_regdeletevalue N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'HostLoginID'
      EXECUTE master.dbo.xp_instance_regdeletevalue N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'HostPassword'
    END
    ELSE
    BEGIN
      EXECUTE master.dbo.xp_sqlagent_param    2, N'HostLoginID'
      EXECUTE master.dbo.xp_sqlagent_param    2, N'HostPassword'
    END
  END

  IF (@host_login_name IS NOT NULL)
  BEGIN
    IF (@OS = 2)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'HostLoginID',
                                            N'REG_SZ',
                                            @host_login_name
    ELSE
    EXECUTE master.dbo.xp_sqlagent_param    1,
                                            N'HostLoginID',
                                            @host_login_name
  END

  IF (@host_login_password IS NOT NULL)
  BEGIN
    IF (@OS = 2)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'HostPassword',
                                            N'REG_BINARY',
                                            @host_login_password
    ELSE
    EXECUTE master.dbo.xp_sqlagent_param    1,
                                            N'HostPassword',
                                            @host_login_password
  END

  IF (@login_timeout IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'LoginTimeout',
                                            N'REG_DWORD',
                                            @login_timeout
  IF (@idle_cpu_percent IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'IdleCPUPercent',
                                            N'REG_DWORD',
                                            @idle_cpu_percent
  IF (@idle_cpu_duration IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'IdleCPUDuration',
                                            N'REG_DWORD',
                                            @idle_cpu_duration
  IF (@oem_errorlog IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'OemErrorLog',
                                            N'REG_DWORD',
                                            @oem_errorlog
  IF (@sysadmin_only IS NOT NULL)
    BEGIN
    IF (@sysadmin_only = 1)
      BEGIN
	EXECUTE master.dbo.xp_sqlagent_proxy_account N'DEL'
      END
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'SysAdminOnly',
                                            N'REG_DWORD',
                                            @sysadmin_only
    END

  IF (@email_profile IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'EmailProfile',
                                            N'REG_SZ',
                                            @email_profile
  IF (@email_save_in_sent_folder IS NOT NULL)
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'EmailSaveSent',
                                            N'REG_DWORD',
                                            @email_save_in_sent_folder
  IF (@cpu_poller_enabled IS NOT NULL)
  BEGIN
    EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                           N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                           N'CoreEngineMask',
                                           @existing_core_engine_mask OUTPUT,
                                           N'no_output'
    IF ((@existing_core_engine_mask IS NOT NULL) OR (@cpu_poller_enabled = 1))
    BEGIN
      IF (@cpu_poller_enabled = 1)
        SELECT @cpu_poller_enabled = (ISNULL(@existing_core_engine_mask, 0) & ~32)
      ELSE
        SELECT @cpu_poller_enabled = (ISNULL(@existing_core_engine_mask, 0) | 32)

      IF ((@existing_core_engine_mask IS NOT NULL) AND (@cpu_poller_enabled = 32))
        EXECUTE master.dbo.xp_instance_regdeletevalue N'HKEY_LOCAL_MACHINE',
                                                      N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                                      N'CoreEngineMask'
      ELSE
        EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                                N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                                N'CoreEngineMask',
                                                N'REG_DWORD',
                                                @cpu_poller_enabled
    END
  END

  RETURN(0) -- Success
END
go

/**************************************************************/
/* SP_ADD_TARGETSERVERGROUP                                   */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_add_targetservergroup...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_add_targetservergroup')
              AND (type = 'P')))
  DROP PROCEDURE sp_add_targetservergroup
go
CREATE PROCEDURE sp_add_targetservergroup
  @name sysname
AS
BEGIN
  SET NOCOUNT ON

  -- Only a sysadmin can do this
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  -- Remove any leading/trailing spaces from parameters
  SELECT @name = LTRIM(RTRIM(@name))

  -- Check if the group already exists
  IF (EXISTS (SELECT *
              FROM msdb.dbo.systargetservergroups
              WHERE name = @name))
  BEGIN
    RAISERROR(14261, -1, -1, '@name', @name)
    RETURN(1) -- Failure
  END

  -- Disallow names with commas in them (since sp_apply_job_to_targets parses a comma-separated list of group names)
  IF (@name LIKE N'%,%')
  BEGIN
    RAISERROR(14289, -1, -1, '@name', ',')
    RETURN(1) -- Failure
  END

  INSERT INTO msdb.dbo.systargetservergroups (name)
  VALUES (@name)

  RETURN(@@error) -- 0 means success
END
go

/**************************************************************/
/* SP_UPDATE_TARGETSERVERGROUP                                */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_update_targetservergroup...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_update_targetservergroup')
              AND (type = 'P')))
  DROP PROCEDURE sp_update_targetservergroup
go
CREATE PROCEDURE sp_update_targetservergroup
  @name     sysname,
  @new_name sysname
AS
BEGIN
  SET NOCOUNT ON

  -- Only a sysadmin can do this
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  -- Remove any leading/trailing spaces from parameters
  SELECT @name     = LTRIM(RTRIM(@name))
  SELECT @new_name = LTRIM(RTRIM(@new_name))

  -- Check if the group exists
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.systargetservergroups
                  WHERE (name = @name)))
  BEGIN
    RAISERROR(14262, -1, -1, '@name', @name)
    RETURN(1) -- Failure
  END

  -- Check if a group with the new name already exists
  IF (EXISTS (SELECT *
              FROM msdb.dbo.systargetservergroups
              WHERE (name = @new_name)))
  BEGIN
    RAISERROR(14261, -1, -1, '@new_name', @new_name)
    RETURN(1) -- Failure
  END

  -- Disallow names with commas in them (since sp_apply_job_to_targets parses a comma-separated list of group names)
  IF (@new_name LIKE N'%,%')
  BEGIN
    RAISERROR(14289, -1, -1, '@new_name', ',')
    RETURN(1) -- Failure
  END

  -- Update the group's name
  UPDATE msdb.dbo.systargetservergroups
  SET name = @new_name
  WHERE (name = @name)

  RETURN(@@error) -- 0 means success
END
go

/**************************************************************/
/* SP_DELETE_TARGETSERVERGROUP                                */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_delete_targetservergroup...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_delete_targetservergroup')
              AND (type = 'P')))
  DROP PROCEDURE sp_delete_targetservergroup
go
CREATE PROCEDURE sp_delete_targetservergroup
  @name sysname
AS
BEGIN
  DECLARE @servergroup_id INT

  SET NOCOUNT ON

  -- Only a sysadmin can do this
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  -- Remove any leading/trailing spaces from parameters
  SELECT @name = LTRIM(RTRIM(@name))

  -- Check if the group exists
  SELECT @servergroup_id = servergroup_id
  FROM msdb.dbo.systargetservergroups
  WHERE (name = @name)

  IF (@servergroup_id IS NULL)
  BEGIN
    RAISERROR(14262, -1, -1, '@name', @name)
    RETURN(1) -- Failure
  END

  -- Remove the group members
  DELETE FROM msdb.dbo.systargetservergroupmembers
  WHERE (servergroup_id = @servergroup_id)

  -- Remove the group
  DELETE FROM msdb.dbo.systargetservergroups
  WHERE (name = @name)

  RETURN(@@error) -- 0 means success
END
go

/**************************************************************/
/* SP_HELP_TARGETSERVERGROUP                                  */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_help_targetservergroup...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_help_targetservergroup')
              AND (type = 'P')))
  DROP PROCEDURE sp_help_targetservergroup
go
CREATE PROCEDURE sp_help_targetservergroup
  @name sysname = NULL
AS
BEGIN
  DECLARE @servergroup_id INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @name = LTRIM(RTRIM(@name))

  IF (@name IS NULL)
  BEGIN
    -- Show all groups
    SELECT servergroup_id, name
    FROM msdb.dbo.systargetservergroups
    RETURN(@@error) -- 0 means success
  END
  ELSE
  BEGIN
    -- Check if the group exists
    SELECT @servergroup_id = servergroup_id
    FROM msdb.dbo.systargetservergroups
    WHERE (name = @name)

    IF (@servergroup_id IS NULL)
    BEGIN
      RAISERROR(14262, -1, -1, '@name', @name)
      RETURN(1) -- Failure
    END

    -- Return the members of the group
    SELECT sts.server_id,
           sts.server_name
    FROM msdb.dbo.systargetservers sts,
         msdb.dbo.systargetservergroupmembers stsgm
    WHERE (stsgm.servergroup_id = @servergroup_id)
      AND (stsgm.server_id = sts.server_id)

    RETURN(@@error) -- 0 means success
  END
END
go

/**************************************************************/
/* SP_ADD_TARGETSVRGRP_MEMBER                                 */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_add_targetsvgrp_member...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_add_targetsvrgrp_member')
              AND (type = 'P')))
  DROP PROCEDURE sp_add_targetsvrgrp_member
go
CREATE PROCEDURE sp_add_targetsvrgrp_member
  @group_name  sysname,
  @server_name NVARCHAR(30)
AS
BEGIN
  DECLARE @servergroup_id INT
  DECLARE @server_id      INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @group_name = LTRIM(RTRIM(@group_name))
  SELECT @server_name = LTRIM(RTRIM(@server_name))

  -- Check if the group exists
  SELECT @servergroup_id = servergroup_id
  FROM msdb.dbo.systargetservergroups
  WHERE (name = @group_name)

  IF (@servergroup_id IS NULL)
  BEGIN
    RAISERROR(14262, -1, -1, '@group_name', @group_name)
    RETURN(1) -- Failure
  END

  -- Check if the server exists
  SELECT @server_id = server_id
  FROM msdb.dbo.systargetservers
  WHERE (server_name = @server_name)

  IF (@server_id IS NULL)
  BEGIN
    RAISERROR(14262, -1, -1, '@server_name', @server_name)
    RETURN(1) -- Failure
  END

  -- Check if the server is already in this group
  IF (EXISTS (SELECT *
              FROM msdb.dbo.systargetservergroupmembers
              WHERE (servergroup_id = @servergroup_id)
                AND (server_id = @server_id)))
  BEGIN
    RAISERROR(14263, -1, -1, @server_name, @group_name)
    RETURN(1) -- Failure
  END

  -- Add the row to systargetservergroupmembers
  INSERT INTO msdb.dbo.systargetservergroupmembers
  VALUES (@servergroup_id, @server_id)

  RETURN(@@error) -- 0 means success
END
go

/**************************************************************/
/* SP_DELETE_TARGETSVRGRP_MEMBER                              */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_delete_targetsvrgrp_member...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_delete_targetsvrgrp_member')
              AND (type = 'P')))
  DROP PROCEDURE sp_delete_targetsvrgrp_member
go
CREATE PROCEDURE sp_delete_targetsvrgrp_member
  @group_name  sysname,
  @server_name NVARCHAR(30)
AS
BEGIN
  DECLARE @servergroup_id INT
  DECLARE @server_id      INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @group_name = LTRIM(RTRIM(@group_name))
  SELECT @server_name = LTRIM(RTRIM(@server_name))

  -- Check if the group exists
  SELECT @servergroup_id = servergroup_id
  FROM msdb.dbo.systargetservergroups
  WHERE (name = @group_name)

  IF (@servergroup_id IS NULL)
  BEGIN
    RAISERROR(14262, -1, -1, '@group_name', @group_name)
    RETURN(1) -- Failure
  END

  -- Check if the server exists
  SELECT @server_id = server_id
  FROM msdb.dbo.systargetservers
  WHERE (server_name = @server_name)

  IF (@server_id IS NULL)
  BEGIN
    RAISERROR(14262, -1, -1, '@server_name', @server_name)
    RETURN(1) -- Failure
  END

  -- Check if the server is in the group
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.systargetservergroupmembers
                  WHERE (servergroup_id = @servergroup_id)
                    AND (server_id = @server_id)))
  BEGIN
    RAISERROR(14264, -1, -1, @server_name, @group_name)
    RETURN(1) -- Failure
  END

  -- Delete the row from systargetservergroupmembers
  DELETE FROM msdb.dbo.systargetservergroupmembers
  WHERE (servergroup_id = @servergroup_id)
    AND (server_id = @server_id)

  RETURN(@@error) -- 0 means success
END
go

/**************************************************************/
/* SP_VERIFY_CATEGORY                                         */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_verify_category...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_verify_category')
              AND (type = 'P')))
  DROP PROCEDURE sp_verify_category
go
CREATE PROCEDURE sp_verify_category
  @class          VARCHAR(8),
  @type           VARCHAR(12)  = NULL, -- Supply NULL only if you don't want it checked
  @name           sysname      = NULL, -- Supply NULL only if you don't want it checked
  @category_class INT OUTPUT,
  @category_type  INT OUTPUT           -- Supply NULL only if you don't want the return value
AS
BEGIN
  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @class = LTRIM(RTRIM(@class))
  SELECT @type  = LTRIM(RTRIM(@type))
  SELECT @name  = LTRIM(RTRIM(@name))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@type = '') SELECT @type = NULL
  IF (@name = N'') SELECT @name = NULL

  -- Check class
  SELECT @class = UPPER(@class)
  SELECT @category_class = CASE @class
                             WHEN 'JOB'      THEN 1
                             WHEN 'ALERT'    THEN 2
                             WHEN 'OPERATOR' THEN 3
                             ELSE 0
                           END
  IF (@category_class = 0)
  BEGIN
    RAISERROR(14266, -1, -1, '@class', 'JOB, ALERT, OPERATOR')
    RETURN(1) -- Failure
  END

  -- Check name
  IF ((@name IS NOT NULL) AND (@name = N'[DEFAULT]'))
  BEGIN
    RAISERROR(14200, -1, -1, '@name')
    RETURN(1) -- Failure
  END

  -- Check type [optionally]
  IF (@type IS NOT NULL)
  BEGIN
    IF (@class = 'JOB')
    BEGIN
      SELECT @type = UPPER(@type)
      SELECT @category_type = CASE @type
                                WHEN 'LOCAL'        THEN 1
                                WHEN 'MULTI-SERVER' THEN 2
                                ELSE 0
                              END
      IF (@category_type = 0)
      BEGIN
        RAISERROR(14266, -1, -1, '@type', 'LOCAL, MULTI-SERVER')
        RETURN(1) -- Failure
      END
    END
    ELSE
    BEGIN
      IF (@type <> 'NONE')
      BEGIN
        RAISERROR(14266, -1, -1, '@type', 'NONE')
        RETURN(1) -- Failure
      END
      ELSE
        SELECT @category_type = 3
    END
  END

  RETURN(0) -- Success
END
go

/**************************************************************/
/* SP_ADD_CATEGORY                                            */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_add_category...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_add_category')
              AND (type = 'P')))
  DROP PROCEDURE sp_add_category
go
CREATE PROCEDURE sp_add_category
  @class VARCHAR(8)   = 'JOB',   -- JOB or ALERT or OPERATOR
  @type  VARCHAR(12)  = 'LOCAL', -- LOCAL or MULTI-SERVER (for JOB) or NONE otherwise
  @name  sysname
AS
BEGIN
  DECLARE @retval         INT
  DECLARE @category_type  INT
  DECLARE @category_class INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @class = LTRIM(RTRIM(@class))
  SELECT @type  = LTRIM(RTRIM(@type))
  SELECT @name  = LTRIM(RTRIM(@name))

  EXECUTE @retval = sp_verify_category @class,
                                       @type,
                                       @name,
                                       @category_class OUTPUT,
                                       @category_type  OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check name
  IF (EXISTS (SELECT *
              FROM msdb.dbo.syscategories
              WHERE (category_class = @category_class)
                AND (name = @name)))
  BEGIN
    RAISERROR(14261, -1, -1, '@name', @name)
    RETURN(1) -- Failure
  END

  -- Add the row
  INSERT INTO msdb.dbo.syscategories (category_class, category_type, name)
  VALUES (@category_class, @category_type, @name)

  RETURN(@@error) -- 0 means success
END
go

/**************************************************************/
/* SP_UPDATE_CATEGORY                                         */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_update_category...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_update_category')
              AND (type = 'P')))
  DROP PROCEDURE sp_update_category
go
CREATE PROCEDURE sp_update_category
  @class    VARCHAR(8),  -- JOB or ALERT or OPERATOR
  @name     sysname,
  @new_name sysname
AS
BEGIN
  DECLARE @retval         INT
  DECLARE @category_id    INT
  DECLARE @category_class INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @class    = LTRIM(RTRIM(@class))
  SELECT @name     = LTRIM(RTRIM(@name))
  SELECT @new_name = LTRIM(RTRIM(@new_name))

  EXECUTE @retval = sp_verify_category @class,
                                       NULL,
                                       @new_name,
                                       @category_class OUTPUT,
                                       NULL
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check name
  SELECT @category_id = category_id
  FROM msdb.dbo.syscategories
  WHERE (category_class = @category_class)
    AND (name = @new_name)
  IF (@category_id IS NOT NULL)
  BEGIN
    RAISERROR(14261, -1, -1, '@new_name', @new_name)
    RETURN(1) -- Failure
  END

  -- Make sure that we're not updating one of the permanent categories (id's 0 - 99)
  IF (@category_id < 100)
  BEGIN
    RAISERROR(14276, -1, -1, @name, @class)
    RETURN(1) -- Failure
  END

  -- Update the category name
  UPDATE msdb.dbo.syscategories
  SET name = @new_name
  WHERE (category_class = @category_class)
    AND (name = @name)

  RETURN(@@error) -- 0 means success
END
go

/**************************************************************/
/* SP_DELETE_CATEGORY                                         */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_delete_category...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_delete_category')
              AND (type = 'P')))
  DROP PROCEDURE sp_delete_category
go
CREATE PROCEDURE sp_delete_category
  @class VARCHAR(8),  -- JOB or ALERT or OPERATOR
  @name  sysname
AS
BEGIN
  DECLARE @retval         INT
  DECLARE @category_id    INT
  DECLARE @category_class INT
  DECLARE @category_type  INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @class = LTRIM(RTRIM(@class))
  SELECT @name  = LTRIM(RTRIM(@name))

  EXECUTE @retval = sp_verify_category @class,
                                       NULL,
                                       NULL,
                                       @category_class OUTPUT,
                                       NULL
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check name
  SELECT @category_id = category_id,
         @category_type = category_type
  FROM msdb.dbo.syscategories
  WHERE (category_class = @category_class)
    AND (name = @name)
  IF (@category_id IS NULL)
  BEGIN
    RAISERROR(14262, -1, -1, '@name', @name)
    RETURN(1) -- Failure
  END

  -- Make sure that we're not deleting one of the permanent categories (id's 0 - 99)
  IF (@category_id < 100)
  BEGIN
    RAISERROR(14276, -1, -1, @name, @class)
    RETURN(1) -- Failure
  END

  BEGIN TRANSACTION

    -- Clean-up any Jobs that reference the deleted category
    UPDATE msdb.dbo.sysjobs
    SET category_id = CASE @category_type
                        WHEN 1 THEN 0 -- [Uncategorized (Local)]
                        WHEN 2 THEN 2 -- [Uncategorized (Multi-Server)]
                      END
    WHERE (category_id = @category_id)

    -- Clean-up any Alerts that reference the deleted category
    UPDATE msdb.dbo.sysalerts
    SET category_id = 98
    WHERE (category_id = @category_id)

    -- Clean-up any Operators that reference the deleted category
    UPDATE msdb.dbo.sysoperators
    SET category_id = 99
    WHERE (category_id = @category_id)

    -- Finally, delete the category itself
    DELETE FROM msdb.dbo.syscategories
    WHERE (category_id = @category_id)

  COMMIT TRANSACTION

  RETURN(0) -- Success
END
go

/**************************************************************/
/* SP_HELP_CATEGORY                                           */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_help_category...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_help_category')
              AND (type = 'P')))
  DROP PROCEDURE sp_help_category
go
CREATE PROCEDURE sp_help_category
  @class  VARCHAR(8)   = 'JOB', -- JOB, ALERT or OPERATOR
  @type   VARCHAR(12)  = NULL,  -- LOCAL, MULTI-SERVER, or NONE
  @name   sysname      = NULL,
  @suffix BIT          = 0      -- 0 = no suffix, 1 = add suffix
AS
BEGIN
  DECLARE @retval         INT
  DECLARE @type_in        VARCHAR(12)
  DECLARE @category_type  INT
  DECLARE @category_class INT
  DECLARE @where_clause   NVARCHAR(255)
  DECLARE @cmd            NVARCHAR(255)

  SET NOCOUNT ON

  -- Both name and type can be NULL (this is valid, indeed it is how SQLDMO populates
  -- the JobCategory collection)

  -- Remove any leading/trailing spaces from parameters
  SELECT @class = LTRIM(RTRIM(@class))
  SELECT @type  = LTRIM(RTRIM(@type))
  SELECT @name  = LTRIM(RTRIM(@name))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@type = '') SELECT @type = NULL
  IF (@name = N'') SELECT @name = NULL

  -- Double up any single quotes in @name
  IF (@name IS NOT NULL)
    SELECT @name = REPLACE(@name, N'''', N'''''')

  -- Check the type and class
  IF (@class = 'JOB') AND (@type IS NULL)
    SELECT @type_in = 'LOCAL' -- This prevents sp_verify_category from failing
  ELSE
  IF (@class <> 'JOB') AND (@type IS NULL)
    SELECT @type_in = 'NONE'
  ELSE
    SELECT @type_in = @type

  EXECUTE @retval = sp_verify_category @class,
                                       @type_in,
                                       NULL,
                                       @category_class OUTPUT,
                                       @category_type  OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Make sure that 'suffix' is either 0 or 1
  IF (@suffix <> 0)
    SELECT @suffix = 1

  -- Build the WHERE qualifier
  SELECT @where_clause = N'WHERE (category_class = ' + CONVERT(NVARCHAR, @category_class) + N') '
  IF (@name IS NOT NULL)
    SELECT @where_clause = @where_clause + N'AND (name = N''' + @name + N''') '
  IF (@type IS NOT NULL)
    SELECT @where_clause = @where_clause + N'AND (category_type = ' + CONVERT(NVARCHAR, @category_type) + N') '

  -- Construct the query
  SELECT @cmd = N'SELECT category_id, '
  IF (@suffix = 1)
  BEGIN
    SELECT @cmd = @cmd + N'''category_type'' = '
    SELECT @cmd = @cmd + N'CASE category_type '
    SELECT @cmd = @cmd + N'WHEN 0 THEN ''NONE'' '
    SELECT @cmd = @cmd + N'WHEN 1 THEN ''LOCAL'' '
    SELECT @cmd = @cmd + N'WHEN 2 THEN ''MULTI-SERVER'' '
    SELECT @cmd = @cmd + N'ELSE FORMATMESSAGE(14205) '
    SELECT @cmd = @cmd + N'END, '
  END
  ELSE
  BEGIN
    SELECT @cmd = @cmd + N'category_type, '
  END
  SELECT @cmd = @cmd + N'name '
  SELECT @cmd = @cmd + N'FROM msdb.dbo.syscategories '

  -- Execute the query
  EXECUTE (@cmd + @where_clause + N'ORDER BY category_type, name')

  RETURN(@@error) -- 0 means success
END
go

/**************************************************************/
/* SP_DELETE_TARGETSERVER                                     */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_delete_targetserver...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_delete_targetserver')
              AND (type = 'P')))
  DROP PROCEDURE sp_delete_targetserver
go
CREATE PROCEDURE sp_delete_targetserver
  @server_name        NVARCHAR(30),
  @clear_downloadlist BIT = 1,
  @post_defection     BIT = 1
AS
BEGIN
  DECLARE @server_id INT
  DECLARE @tsx_probe NVARCHAR(50)

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @server_name = LTRIM(RTRIM(@server_name))

  -- Check server name
  SELECT @server_id = server_id
  FROM msdb.dbo.systargetservers
  WHERE (server_name = @server_name)

  IF (@server_id IS NULL)
  BEGIN
    RAISERROR(14262, -1, -1, '@server_name', @server_name)
    RETURN(1) -- Failure
  END

  BEGIN TRANSACTION

    IF (@clear_downloadlist = 1)
    BEGIN
      DELETE FROM msdb.dbo.sysdownloadlist
      WHERE (target_server = @server_name)
    END

    IF (@post_defection = 1)
    BEGIN
      -- Post a defect instruction to the server
      -- NOTE: We must do this BEFORE deleting the systargetservers row
      EXECUTE msdb.dbo.sp_post_msx_operation 'DEFECT', 'SERVER', 0x00, @server_name
    END

    DELETE FROM msdb.dbo.systargetservers
    WHERE (server_id = @server_id)

    DELETE FROM msdb.dbo.systargetservergroupmembers
    WHERE (server_id = @server_id)

    DELETE FROM msdb.dbo.sysjobservers
    WHERE (server_id = @server_id)

  COMMIT TRANSACTION

  RETURN(@@error) -- 0 means success
END
go

/**************************************************************/
/* SP_HELP_TARGETSERVER                                       */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_help_targetserver...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_help_targetserver')
              AND (type = 'P')))
  DROP PROCEDURE sp_help_targetserver
go
CREATE PROCEDURE sp_help_targetserver
  @server_name NVARCHAR(30) = NULL
AS
BEGIN
  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @server_name = LTRIM(RTRIM(@server_name))

  IF (@server_name IS NOT NULL)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.systargetservers
                    WHERE (server_name = @server_name)))
    BEGIN
      RAISERROR(14262, -1, -1, '@server_name', @server_name)
      RETURN(1) -- Failure
    END
  END

  CREATE TABLE #unread_instructions
  (
  target_server       NVARCHAR(30) COLLATE database_default,
  unread_instructions INT
  )

  INSERT INTO #unread_instructions
  SELECT target_server, COUNT(*)
  FROM msdb.dbo.sysdownloadlist
  WHERE (status = 0)
  GROUP BY target_server

  SELECT sts.server_id,
         sts.server_name,
         sts.location,
         sts.time_zone_adjustment,
         sts.enlist_date,
         sts.last_poll_date,
        'status' = sts.status |
                   CASE WHEN DATEDIFF(ss, sts.last_poll_date, GETDATE()) > (3 * sts.poll_interval) THEN 0x2 ELSE 0 END |
                   CASE WHEN ((SELECT COUNT(*)
                               FROM msdb.dbo.sysdownloadlist sdl
                               WHERE (sdl.target_server = sts.server_name)
                                 AND (sdl.error_message IS NOT NULL)) > 0) THEN 0x4 ELSE 0 END,
        'unread_instructions' = ISNULL(ui.unread_instructions, 0),
        'local_time' = DATEADD(SS, DATEDIFF(SS, sts.last_poll_date, GETDATE()), sts.local_time_at_last_poll),
        sts.enlisted_by_nt_user,
        sts.poll_interval
  FROM msdb.dbo.systargetservers sts LEFT OUTER JOIN
       #unread_instructions      ui  ON (sts.server_name = ui.target_server)
  WHERE ((@server_name IS NULL) OR (sts.server_name = @server_name))
  ORDER BY server_name

  RETURN(@@error) -- 0 means success
END
go

/**************************************************************/
/* SP_RESYNC_TARGETSERVER                                     */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_resync_targetserver...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_resync_targetserver')
              AND (type = 'P')))
  DROP PROCEDURE sp_resync_targetserver
go
CREATE PROCEDURE sp_resync_targetserver
  @server_name NVARCHAR(30)
AS
BEGIN
  SET NOCOUNT ON

  -- Only a sysadmin can do this
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  -- Remove any leading/trailing spaces from parameters
  SELECT @server_name = LTRIM(RTRIM(@server_name))

  IF (@server_name <> N'ALL')
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.systargetservers
                    WHERE (server_name = @server_name)))
    BEGIN
      RAISERROR(14262, -1, -1, '@server_name', @server_name)
      RETURN(1) -- Failure
    END

    -- We want the target server to:
    -- a) delete all their current MSX jobs, and
    -- b) download all their jobs again.
    -- So we delete all the current instructions and post a new set
    DELETE FROM msdb.dbo.sysdownloadlist
    WHERE (target_server = @server_name)
    EXECUTE msdb.dbo.sp_post_msx_operation 'DELETE', 'JOB', 0x00, @server_name
    EXECUTE msdb.dbo.sp_post_msx_operation 'INSERT', 'JOB', 0x00, @server_name
  END
  ELSE
  BEGIN
    -- We want ALL target servers to:
    -- a) delete all their current MSX jobs, and
    -- b) download all their jobs again.
    -- So we delete all the current instructions and post a new set
    TRUNCATE TABLE msdb.dbo.sysdownloadlist
    EXECUTE msdb.dbo.sp_post_msx_operation 'DELETE', 'JOB', 0x00, NULL
    EXECUTE msdb.dbo.sp_post_msx_operation 'INSERT', 'JOB', 0x00, NULL
  END

  RETURN(@@error) -- 0 means success
END
go

DUMP TRANSACTION msdb WITH NO_LOG
go
CHECKPOINT
go

/**************************************************************/
/* SP_PURGE_JOBHISTORY                                        */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_purge_jobhistory...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_purge_jobhistory')
              AND (type = 'P')))
  DROP PROCEDURE sp_purge_jobhistory
go
CREATE PROCEDURE sp_purge_jobhistory
  @job_name sysname          = NULL,
  @job_id   UNIQUEIDENTIFIER = NULL
AS
BEGIN
  DECLARE @rows_affected INT
  DECLARE @total_rows    INT
  DECLARE @retval        INT
  DECLARE @category_id   INT

  SET NOCOUNT ON

  IF ((@job_name IS NOT NULL) OR (@job_id IS NOT NULL))
  BEGIN
    EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                                '@job_id',
                                                 @job_name OUTPUT,
                                                 @job_id   OUTPUT
    IF (@retval <> 0)
      RETURN(1) -- Failure

    -- Get category to see if it is a misc. replication agent. @category_id will be
    -- NULL if there is no @job_id.
    select @category_id = category_id from msdb.dbo.sysjobs where job_id = @job_id

    -- Delete the histories for this job
    DELETE FROM msdb.dbo.sysjobhistory
    WHERE (job_id = @job_id)
    SELECT @rows_affected = @@rowcount

    -- If misc. replication job, then update global replication status table
    IF (@category_id IN (11, 12, 16, 17, 18))
    BEGIN
      -- Nothing can be done if this fails, so don't worry about the return code
      EXECUTE master.dbo.sp_MSupdate_replication_status
        @publisher = '',
        @publisher_db = '',
        @publication = '',
        @publication_type = -1,
        @agent_type = 5,
        @agent_name = @job_name,
        @status = -1 -- Delete
    END
  END
  ELSE
  BEGIN
    -- Only a sysadmin can do this
    IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
    BEGIN
      RAISERROR(15003, 16, 1, N'sysadmin')
      RETURN(1) -- Failure
    END

    SELECT @total_rows = COUNT(*)
    FROM msdb.dbo.sysjobhistory
    SELECT @rows_affected = @total_rows
    TRUNCATE TABLE msdb.dbo.sysjobhistory

    -- Remove all misc. replication jobs from global replication status table
    -- Nothing can be done if this fails, so don't worry about the return code
    EXECUTE master.dbo.sp_MSupdate_replication_status
      @publisher = '',
      @publisher_db = '',
      @publication = '',
      @publication_type = -1,
      @agent_type = 5,
      @agent_name = '%',
      @status = -1 -- Delete
  END
  RAISERROR(14226, 0, 1, @rows_affected)

  RETURN(0) -- Success
END
go

/**************************************************************/
/* SP_VERIFY_JOB_DATE                                         */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_verify_job_date...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_verify_job_date')
              AND (type = 'P')))
  DROP PROCEDURE sp_verify_job_date
go
CREATE PROCEDURE sp_verify_job_date
  @date           INT,
  @date_name      VARCHAR(60) = 'date',
  @error_severity INT         = -1
AS
BEGIN
  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @date_name = LTRIM(RTRIM(@date_name))

  IF ((ISDATE(CONVERT(VARCHAR, @date)) = 0) OR (@date < 19900101) OR (@date > 99991231))
  BEGIN
    RAISERROR(14266, @error_severity, -1, @date_name, '19900101..99991231')
    RETURN(1) -- Failure
  END

  RETURN(0) -- Success
END
go

/**************************************************************/
/* SP_VERIFY_JOB_TIME                                         */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_verify_job_time...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_verify_job_time')
              AND (type = 'P')))
  DROP PROCEDURE sp_verify_job_time
go

CREATE PROCEDURE sp_verify_job_time
  @time           INT,
  @time_name      VARCHAR(60) = 'time',
  @error_severity INT = -1
AS
BEGIN
  DECLARE @hour      INT
  DECLARE @minute    INT
  DECLARE @second    INT
  DECLARE @part_name NVARCHAR(50)

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @time_name = LTRIM(RTRIM(@time_name))

  IF ((@time < 0) OR (@time > 235959))
  BEGIN
    RAISERROR(14266, @error_severity, -1, @time_name, '000000..235959')
    RETURN(1) -- Failure
  END

  SELECT @hour   = (@time / 10000)
  SELECT @minute = (@time % 10000) / 100
  SELECT @second = (@time % 100)

  -- Check hour range
  IF (@hour > 23)
  BEGIN
    SELECT @part_name = FORMATMESSAGE(14218)
    RAISERROR(14287, @error_severity, -1, @time_name, @part_name)
    RETURN(1) -- Failure
  END

  -- Check minute range
  IF (@minute > 59)
  BEGIN
    SELECT @part_name = FORMATMESSAGE(14219)
    RAISERROR(14287, @error_severity, -1, @time_name, @part_name)
    RETURN(1) -- Failure
  END

  -- Check second range
  IF (@second > 59)
  BEGIN
    SELECT @part_name = FORMATMESSAGE(14220)
    RAISERROR(14287, @error_severity, -1, @time_name, @part_name)
    RETURN(1) -- Failure
  END

  RETURN(0) -- Success
END
go

/**************************************************************/
/* SP_HELP_JOBHISTORY                                         */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_help_jobhistory...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_help_jobhistory')
              AND (type = 'P')))
  DROP PROCEDURE sp_help_jobhistory
go
CREATE PROCEDURE sp_help_jobhistory
  @job_id               UNIQUEIDENTIFIER = NULL,
  @job_name             sysname          = NULL,
  @step_id              INT              = NULL,
  @sql_message_id       INT              = NULL,
  @sql_severity         INT              = NULL,
  @start_run_date       INT              = NULL,     -- YYYYMMDD
  @end_run_date         INT              = NULL,     -- YYYYMMDD
  @start_run_time       INT              = NULL,     -- HHMMSS
  @end_run_time         INT              = NULL,     -- HHMMSS
  @minimum_run_duration INT              = NULL,     -- HHMMSS
  @run_status           INT              = NULL,     -- SQLAGENT_EXEC_X code
  @minimum_retries      INT              = NULL,
  @oldest_first         INT              = 0,        -- Or 1
  @server               NVARCHAR(30)     = NULL,
  @mode                 VARCHAR(7)       = 'SUMMARY' -- Or 'FULL' or 'SEM'
AS
BEGIN
  DECLARE @retval   INT
  DECLARE @order_by INT  -- Must be INT since it can be -1

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @server   = LTRIM(RTRIM(@server))
  SELECT @mode     = LTRIM(RTRIM(@mode))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@server = N'')   SELECT @server = NULL

  -- Check job id/name (if supplied)
  IF ((@job_id IS NOT NULL) OR (@job_name IS NOT NULL))
  BEGIN
    EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                                '@job_id',
                                                 @job_name OUTPUT,
                                                 @job_id   OUTPUT
    IF (@retval <> 0)
      RETURN(1) -- Failure
  END

  -- Check @start_run_date
  IF (@start_run_date IS NOT NULL)
  BEGIN
    EXECUTE @retval = sp_verify_job_date @start_run_date, '@start_run_date'
    IF (@retval <> 0)
      RETURN(1) -- Failure
  END

  -- Check @end_run_date
  IF (@end_run_date IS NOT NULL)
  BEGIN
    EXECUTE @retval = sp_verify_job_date @end_run_date, '@end_run_date'
    IF (@retval <> 0)
      RETURN(1) -- Failure
  END

  -- Check @start_run_time
  EXECUTE @retval = sp_verify_job_time @start_run_time, '@start_run_time'
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check @end_run_time
  EXECUTE @retval = sp_verify_job_time @end_run_time, '@end_run_time'
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check @run_status
  IF ((@run_status < 0) OR (@run_status > 5))
  BEGIN
    RAISERROR(13266, -1, -1, '@run_status', '0..5')
    RETURN(1) -- Failure
  END

  -- Check mode
  SELECT @mode = UPPER(@mode)
  IF (@mode NOT IN ('SUMMARY', 'FULL', 'SEM'))
  BEGIN
    RAISERROR(14266, -1, -1, '@mode', 'SUMMARY, FULL, SEM')
    RETURN(1) -- Failure
  END

  SELECT @order_by = -1
  IF (@oldest_first = 1)
    SELECT @order_by = 1

  -- Return history information filtered by the supplied parameters.
  -- NOTE: SQLDMO relies on the 'FULL' format; ** DO NOT CHANGE IT **
  IF (@mode = 'FULL')
  BEGIN
    SELECT sjh.instance_id, -- This is included just for ordering purposes
           sj.job_id,
           job_name = sj.name,
           sjh.step_id,
           sjh.step_name,
           sjh.sql_message_id,
           sjh.sql_severity,
           sjh.message,
           sjh.run_status,
           sjh.run_date,
           sjh.run_time,
           sjh.run_duration,
           operator_emailed = so1.name,
           operator_netsent = so2.name,
           operator_paged = so3.name,
           sjh.retries_attempted,
           sjh.server
    FROM msdb.dbo.sysjobhistory                sjh
         LEFT OUTER JOIN msdb.dbo.sysoperators so1  ON (sjh.operator_id_emailed = so1.id)
         LEFT OUTER JOIN msdb.dbo.sysoperators so2  ON (sjh.operator_id_netsent = so2.id)
         LEFT OUTER JOIN msdb.dbo.sysoperators so3  ON (sjh.operator_id_paged = so3.id),
         msdb.dbo.sysjobs_view                 sj
    WHERE (sj.job_id = sjh.job_id)
      AND ((@job_id               IS NULL) OR (@job_id = sjh.job_id))
      AND ((@step_id              IS NULL) OR (@step_id = sjh.step_id))
      AND ((@sql_message_id       IS NULL) OR (@sql_message_id = sjh.sql_message_id))
      AND ((@sql_severity         IS NULL) OR (@sql_severity = sjh.sql_severity))
      AND ((@start_run_date       IS NULL) OR (sjh.run_date >= @start_run_date))
      AND ((@end_run_date         IS NULL) OR (sjh.run_date <= @end_run_date))
      AND ((@start_run_time       IS NULL) OR (sjh.run_time >= @start_run_time))
      AND ((@end_run_time         IS NULL) OR (sjh.run_time <= @end_run_time))
      AND ((@minimum_run_duration IS NULL) OR (sjh.run_duration >= @minimum_run_duration))
      AND ((@run_status           IS NULL) OR (@run_status = sjh.run_status))
      AND ((@minimum_retries      IS NULL) OR (sjh.retries_attempted >= @minimum_retries))
      AND ((@server               IS NULL) OR (sjh.server = @server))
    ORDER BY (sjh.instance_id * @order_by)
  END
  ELSE
  IF (@mode = 'SUMMARY')
  BEGIN
    -- Summary format: same WHERE clause just a different SELECT list
    SELECT sj.job_id,
           job_name = sj.name,
           sjh.run_status,
           sjh.run_date,
           sjh.run_time,
           sjh.run_duration,
           operator_emailed = substring(so1.name, 1, 20),
           operator_netsent = substring(so2.name, 1, 20),
           operator_paged = substring(so3.name, 1, 20),
           sjh.retries_attempted,
           sjh.server
    FROM msdb.dbo.sysjobhistory                sjh
         LEFT OUTER JOIN msdb.dbo.sysoperators so1  ON (sjh.operator_id_emailed = so1.id)
         LEFT OUTER JOIN msdb.dbo.sysoperators so2  ON (sjh.operator_id_netsent = so2.id)
         LEFT OUTER JOIN msdb.dbo.sysoperators so3  ON (sjh.operator_id_paged = so3.id),
         msdb.dbo.sysjobs_view                 sj
    WHERE (sj.job_id = sjh.job_id)
      AND ((@job_id               IS NULL) OR (@job_id = sjh.job_id))
      AND ((@step_id              IS NULL) OR (@step_id = sjh.step_id))
      AND ((@sql_message_id       IS NULL) OR (@sql_message_id = sjh.sql_message_id))
      AND ((@sql_severity         IS NULL) OR (@sql_severity = sjh.sql_severity))
      AND ((@start_run_date       IS NULL) OR (sjh.run_date >= @start_run_date))
      AND ((@end_run_date         IS NULL) OR (sjh.run_date <= @end_run_date))
      AND ((@start_run_time       IS NULL) OR (sjh.run_time >= @start_run_time))
      AND ((@end_run_time         IS NULL) OR (sjh.run_time <= @end_run_time))
      AND ((@minimum_run_duration IS NULL) OR (sjh.run_duration >= @minimum_run_duration))
      AND ((@run_status           IS NULL) OR (@run_status = sjh.run_status))
      AND ((@minimum_retries      IS NULL) OR (sjh.retries_attempted >= @minimum_retries))
      AND ((@server               IS NULL) OR (sjh.server = @server))
    ORDER BY (sjh.instance_id * @order_by)
  END
  ELSE
  IF (@mode = 'SEM')
  BEGIN
    -- SQL Enterprise Manager format
    SELECT sjh.step_id,
           sjh.step_name,
           sjh.message,
           sjh.run_status,
           sjh.run_date,
           sjh.run_time,
           sjh.run_duration,
           operator_emailed = so1.name,
           operator_netsent = so2.name,
           operator_paged = so3.name
    FROM msdb.dbo.sysjobhistory                sjh
         LEFT OUTER JOIN msdb.dbo.sysoperators so1  ON (sjh.operator_id_emailed = so1.id)
         LEFT OUTER JOIN msdb.dbo.sysoperators so2  ON (sjh.operator_id_netsent = so2.id)
         LEFT OUTER JOIN msdb.dbo.sysoperators so3  ON (sjh.operator_id_paged = so3.id),
         msdb.dbo.sysjobs_view                 sj
    WHERE (sj.job_id = sjh.job_id)
      AND (@job_id = sjh.job_id)
    ORDER BY (sjh.instance_id * @order_by)
  END

  RETURN(0) -- Success
END
go

/**************************************************************/
/* SP_ADD_JOBSERVER                                           */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_add_jobserver...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_add_jobserver')
              AND (type = 'P')))
  DROP PROCEDURE sp_add_jobserver
go

CREATE PROCEDURE sp_add_jobserver
  @job_id         UNIQUEIDENTIFIER = NULL, -- Must provide either this or job_name
  @job_name       sysname          = NULL, -- Must provide either this or job_id
  @server_name    NVARCHAR(30)     = NULL, -- if NULL will default to serverproperty('ServerName')
  @automatic_post BIT = 1                  -- Flag for SEM use only
AS
BEGIN
  DECLARE @retval                    INT
  DECLARE @server_id                 INT
  DECLARE @job_type                  VARCHAR(12)
  DECLARE @current_job_category_type VARCHAR(12)
  DECLARE @msx_operator_id           INT
  DECLARE @local_server_name         NVARCHAR(30)
  DECLARE @is_sysadmin               INT
  DECLARE @job_owner                 sysname

  SET NOCOUNT ON

  IF (@server_name IS NULL) OR (UPPER(@server_name) = N'(LOCAL)')
    SELECT @server_name = CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName'))

  -- Remove any leading/trailing spaces from parameters
  SELECT @server_name = LTRIM(RTRIM(@server_name))

  EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                              '@job_id',
                                               @job_name OUTPUT,
                                               @job_id   OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- First, check if the server is the local server
  SELECT @local_server_name = CONVERT(NVARCHAR,SERVERPROPERTY ('SERVERNAME'))

  IF (UPPER(@server_name) = UPPER(@local_server_name))
    SELECT @server_name = UPPER(CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName')))

  -- Only the SA can add a multi-server job
  IF (UPPER(@server_name) <> UPPER(CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName')))) AND 
     (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 0)
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  -- For a multi-server job...
  IF (UPPER(@server_name) <> UPPER(CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName'))))
  BEGIN
    -- 1) Check if the job owner is a sysadmin
    SELECT @job_owner = SUSER_SNAME(owner_sid)
    FROM msdb.dbo.sysjobs
    WHERE (job_id = @job_id)
    SELECT @is_sysadmin = 0
    EXECUTE msdb.dbo.sp_sqlagent_has_server_access @login_name = @job_owner, @is_sysadmin_member = @is_sysadmin OUTPUT
    IF (@is_sysadmin = 0)
    BEGIN
      RAISERROR(14544, -1, -1, @job_owner, N'sysadmin')
      RETURN(1) -- Failure
    END

    -- 2) Check if any of the TSQL steps have a non-null database_user_name
    IF (EXISTS (SELECT *
                FROM msdb.dbo.sysjobsteps
                WHERE (job_id = @job_id)
                  AND (subsystem = N'TSQL')
                  AND (database_user_name IS NOT NULL)))
    BEGIN
      RAISERROR(14542, -1, -1, N'database_user_name')
      RETURN(1) -- Failure
    END
  END

  -- Check server name
  IF (UPPER(@server_name) <> UPPER(CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName'))))
  BEGIN
    SELECT @server_id = server_id
    FROM msdb.dbo.systargetservers
    WHERE (server_name = @server_name)
    IF (@server_id IS NULL)
    BEGIN
      RAISERROR(14262, -1, -1, '@server_name', @server_name)
      RETURN(1) -- Failure
    END
  END
  ELSE
    SELECT @server_id = 0

  -- Check that this job has not already been targeted at this server
  IF (EXISTS (SELECT *
               FROM msdb.dbo.sysjobservers
               WHERE (job_id = @job_id)
                 AND (server_id = @server_id)))
  BEGIN
    RAISERROR(14269, -1, -1, @job_name, @server_name)
    RETURN(1) -- Failure
  END

  -- Prevent the job from being targeted at both the local AND remote servers
  SELECT @job_type = 'UNKNOWN'
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobservers
              WHERE (job_id = @job_id)
                AND (server_id = 0)))
    SELECT @job_type = 'LOCAL'
  ELSE
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobservers
              WHERE (job_id = @job_id)
                AND (server_id <> 0)))
    SELECT @job_type = 'MULTI-SERVER'

  IF ((@server_id = 0) AND (@job_type = 'MULTI-SERVER'))
  BEGIN
    RAISERROR(14290, -1, -1)
    RETURN(1) -- Failure
  END
  IF ((@server_id <> 0) AND (@job_type = 'LOCAL'))
  BEGIN
    RAISERROR(14291, -1, -1)
    RETURN(1) -- Failure
  END

  -- For a multi-server job, check that any notifications are to the MSXOperator
  IF (@job_type = 'MULTI-SERVER')
  BEGIN
    SELECT @msx_operator_id = id
    FROM msdb.dbo.sysoperators
    WHERE (name = N'MSXOperator')

    IF (EXISTS (SELECT *
                FROM msdb.dbo.sysjobs
                WHERE (job_id = @job_id)
                  AND (((notify_email_operator_id <> 0)   AND (notify_email_operator_id <> @msx_operator_id)) OR
                       ((notify_page_operator_id <> 0)    AND (notify_page_operator_id <> @msx_operator_id))  OR
                       ((notify_netsend_operator_id <> 0) AND (notify_netsend_operator_id <> @msx_operator_id)))))
    BEGIN
      RAISERROR(14221, -1, -1, 'MSXOperator')
      RETURN(1) -- Failure
    END
  END

  -- Insert the sysjobservers row
  INSERT INTO msdb.dbo.sysjobservers
         (job_id,
          server_id,
          last_run_outcome,
          last_outcome_message,
          last_run_date,
          last_run_time,
          last_run_duration)
  VALUES (@job_id,
          @server_id,
          5,  -- ie. SQLAGENT_EXEC_UNKNOWN (can't use 0 since this is SQLAGENT_EXEC_FAIL)
          NULL,
          0,
          0,
          0)

  -- Re-categorize the job (if necessary)
  SELECT @current_job_category_type = CASE category_type
                                        WHEN 1 THEN 'LOCAL'
                                        WHEN 2 THEN 'MULTI-SERVER'
                                      END
  FROM msdb.dbo.sysjobs_view  sjv,
       msdb.dbo.syscategories sc
  WHERE (sjv.category_id = sc.category_id)
    AND (sjv.job_id = @job_id)

  IF (@server_id = 0) AND (@current_job_category_type = 'MULTI-SERVER')
  BEGIN
    UPDATE msdb.dbo.sysjobs
    SET category_id = 0 -- [Uncategorized (Local)]
    WHERE (job_id = @job_id)
  END
  IF (@server_id <> 0) AND (@current_job_category_type = 'LOCAL')
  BEGIN
    UPDATE msdb.dbo.sysjobs
    SET category_id = 2 -- [Uncategorized (Multi-Server)]
    WHERE (job_id = @job_id)
  END

  -- Instruct the new server to pick up the job
  IF (@automatic_post = 1)
    EXECUTE @retval = sp_post_msx_operation 'INSERT', 'JOB', @job_id, @server_name

  -- If the job is local, make sure that SQLServerAgent caches it
  IF (@server_id = 0)
  BEGIN
    EXECUTE msdb.dbo.sp_sqlagent_notify @op_type     = N'J',
                                        @job_id      = @job_id,
                                        @action_type = N'I'
  END

  RETURN(@retval) -- 0 means success
END
go

/**************************************************************/
/* SP_DELETE_JOBSERVER                                        */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_delete_jobserver...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_delete_jobserver')
              AND (type = 'P')))
  DROP PROCEDURE sp_delete_jobserver
go
CREATE PROCEDURE sp_delete_jobserver
  @job_id      UNIQUEIDENTIFIER = NULL, -- Must provide either this or job_name
  @job_name    sysname          = NULL, -- Must provide either this or job_id
  @server_name NVARCHAR(30)
AS
BEGIN
  DECLARE @retval             INT
  DECLARE @server_id          INT
  DECLARE @local_machine_name NVARCHAR(30)

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @server_name = LTRIM(RTRIM(@server_name))

  IF (UPPER(@server_name) = '(LOCAL)')
    SELECT @server_name = UPPER(CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName')))

  EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                              '@job_id',
                                               @job_name OUTPUT,
                                               @job_id   OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- First, check if the server is the local server
  EXECUTE @retval = master.dbo.xp_getnetname @local_machine_name OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure
  IF (@local_machine_name IS NOT NULL) AND (UPPER(@server_name) = UPPER(@local_machine_name))
    SELECT @server_name = UPPER(CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName')))

  -- Check server name
  IF (UPPER(@server_name) <> UPPER(CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName'))))
  BEGIN
    SELECT @server_id = server_id
    FROM msdb.dbo.systargetservers
    WHERE (server_name = @server_name)
    IF (@server_id IS NULL)
    BEGIN
      RAISERROR(14262, -1, -1, '@server_name', @server_name)
      RETURN(1) -- Failure
    END
  END
  ELSE
    SELECT @server_id = 0

  -- Check that the job is indeed targeted at the server
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysjobservers
                  WHERE (job_id = @job_id)
                    AND (server_id = @server_id)))
  BEGIN
    RAISERROR(14270, -1, -1, @job_name, @server_name)
    RETURN(1) -- Failure
  END

  -- Instruct the deleted server to purge the job
  -- NOTE: We must do this BEFORE we delete the sysjobservers row
  EXECUTE @retval = sp_post_msx_operation 'DELETE', 'JOB', @job_id, @server_name

  -- Delete the sysjobservers row
  DELETE FROM msdb.dbo.sysjobservers
  WHERE (job_id = @job_id)
    AND (server_id = @server_id)

  -- If we deleted the last jobserver then re-categorize the job to the sp_add_job default
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysjobservers
                  WHERE (job_id = @job_id)))
  BEGIN
    UPDATE msdb.dbo.sysjobs
    SET category_id = 0 -- [Uncategorized (Local)]
    WHERE (job_id = @job_id)
  END

  -- If the job is local, make sure that SQLServerAgent removes it from cache
  IF (@server_id = 0)
  BEGIN
    EXECUTE msdb.dbo.sp_sqlagent_notify @op_type     = N'J',
                                        @job_id      = @job_id,
                                        @action_type = N'D'
  END

  RETURN(@retval) -- 0 means success
END
go

/**************************************************************/
/* SP_HELP_JOBSERVER                                          */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_help_jobserver...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_help_jobserver')
              AND (type = 'P')))
  DROP PROCEDURE sp_help_jobserver
go
CREATE PROCEDURE sp_help_jobserver
  @job_id                UNIQUEIDENTIFIER = NULL, -- Must provide either this or job_name
  @job_name              sysname          = NULL, -- Must provide either this or job_id
  @show_last_run_details TINYINT          = 0     -- Controls if last-run execution information is part of the result set (1 = yes, 0 = no)
AS
BEGIN
  DECLARE @retval INT

  SET NOCOUNT ON

  EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                              '@job_id',
                                               @job_name OUTPUT,
                                               @job_id   OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- The show-last-run-details flag must be either 1 or 0
  IF (@show_last_run_details <> 0)
    SELECT @show_last_run_details = 1

  IF (@show_last_run_details = 1)
  BEGIN
    -- List the servers that @job_name has been targeted at (INCLUDING last-run details)
    SELECT stsv.server_id,
           stsv.server_name,
           stsv.enlist_date,
           stsv.last_poll_date,
           sjs.last_run_date,
           sjs.last_run_time,
           sjs.last_run_duration,
           sjs.last_run_outcome,  -- Same as JOB_OUTCOME_CODE (SQLAGENT_EXEC_x)
           sjs.last_outcome_message
    FROM msdb.dbo.sysjobservers         sjs  LEFT OUTER JOIN
         msdb.dbo.systargetservers_view stsv ON (sjs.server_id = stsv.server_id)
    WHERE (sjs.job_id = @job_id)
  END
  ELSE
  BEGIN
    -- List the servers that @job_name has been targeted at (EXCLUDING last-run details)
    SELECT stsv.server_id,
           stsv.server_name,
           stsv.enlist_date,
           stsv.last_poll_date
    FROM msdb.dbo.sysjobservers         sjs  LEFT OUTER JOIN
         msdb.dbo.systargetservers_view stsv ON (sjs.server_id = stsv.server_id)
    WHERE (sjs.job_id = @job_id)
  END

  RETURN(@@error) -- 0 means success
END
go

/**************************************************************/
/* SP_HELP_DOWNLOADLIST                                       */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_help_downloadlist...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_help_downloadlist')
              AND (type = 'P')))
  DROP PROCEDURE sp_help_downloadlist
go
CREATE PROCEDURE sp_help_downloadlist
  @job_id          UNIQUEIDENTIFIER = NULL, -- If provided must NOT also provide job_name
  @job_name        sysname          = NULL, -- If provided must NOT also provide job_id
  @operation       VARCHAR(64)      = NULL,
  @object_type     VARCHAR(64)      = NULL, -- Only 'JOB' or 'SERVER' are valid in 7.0
  @object_name     sysname          = NULL,
  @target_server   NVARCHAR(30)     = NULL,
  @has_error       TINYINT          = NULL, -- NULL or 1
  @status          TINYINT          = NULL,
  @date_posted     DATETIME         = NULL  -- Include all entries made on OR AFTER this date
AS
BEGIN
  DECLARE @retval         INT
  DECLARE @operation_code INT
  DECLARE @object_type_id TINYINT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @operation     = LTRIM(RTRIM(@operation))
  SELECT @object_type   = LTRIM(RTRIM(@object_type))
  SELECT @object_name   = LTRIM(RTRIM(@object_name))
  SELECT @target_server = LTRIM(RTRIM(@target_server))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@operation     = '') SELECT @operation = NULL
  IF (@object_type   = '') SELECT @object_type = NULL
  IF (@object_name   = N'') SELECT @object_name = NULL
  IF (@target_server = N'') SELECT @target_server = NULL

  IF ((@job_id IS NOT NULL) OR (@job_name IS NOT NULL))
  BEGIN
    EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                                '@job_id',
                                                 @job_name OUTPUT,
                                                 @job_id   OUTPUT
    IF (@retval <> 0)
      RETURN(1) -- Failure
  END

  -- Check operation
  IF (@operation IS NOT NULL)
  BEGIN
    SELECT @operation = UPPER(@operation)
    SELECT @operation_code = CASE @operation
                               WHEN 'INSERT'    THEN 1
                               WHEN 'UPDATE'    THEN 2
                               WHEN 'DELETE'    THEN 3
                               WHEN 'START'     THEN 4
                               WHEN 'STOP'      THEN 5
                               WHEN 'RE-ENLIST' THEN 6
                               WHEN 'DEFECT'    THEN 7
                               WHEN 'SYNC-TIME' THEN 8
                               WHEN 'SET-POLL'  THEN 9
                               ELSE 0
                             END
    IF (@operation_code = 0)
    BEGIN
      RAISERROR(14266, -1, -1, '@operation_code', 'INSERT, UPDATE, DELETE, START, STOP, RE-ENLIST, DEFECT, SYNC-TIME, SET-POLL')
      RETURN(1) -- Failure
    END
  END

  -- Check object type (in 7.0 only 'JOB' and 'SERVER' are valid)
  IF (@object_type IS NOT NULL)
  BEGIN
    SELECT @object_type = UPPER(@object_type)
    IF ((@object_type <> 'JOB') AND (@object_type <> 'SERVER'))
    BEGIN
      RAISERROR(14266, -1, -1, '@object_type', 'JOB, SERVER')
      RETURN(1) -- Failure
    END
    ELSE
      SELECT @object_type_id = CASE @object_type
                                 WHEN 'JOB'    THEN 1
                                 WHEN 'SERVER' THEN 2
                                 ELSE 0
                               END
  END

  -- If object-type is supplied then object-name must also be supplied
  IF ((@object_type IS NOT NULL) AND (@object_name IS NULL)) OR
     ((@object_type IS NULL)     AND (@object_name IS NOT NULL))
  BEGIN
    RAISERROR(14272, -1, -1)
    RETURN(1) -- Failure
  END

  -- Check target server
  IF (@target_server IS NOT NULL) AND NOT EXISTS (SELECT *
                                                  FROM msdb.dbo.systargetservers
                                                  WHERE server_name = @target_server)
  BEGIN
    RAISERROR(14262, -1, -1, '@target_server', @target_server)
    RETURN(1) -- Failure
  END

  -- Check has-error
  IF (@has_error IS NOT NULL) AND (@has_error <> 1)
  BEGIN
    RAISERROR(14266, -1, -1, '@has_error', '1, NULL')
    RETURN(1) -- Failure
  END

  -- Check status
  IF (@status IS NOT NULL) AND (@status <> 0) AND (@status <> 1)
  BEGIN
    RAISERROR(14266, -1, -1, '@status', '0, 1')
    RETURN(1) -- Failure
  END

  -- Return the result set
  SELECT sdl.instance_id,
         sdl.source_server,
        'operation_code' = CASE sdl.operation_code
                             WHEN 1 THEN '1 (INSERT)'
                             WHEN 2 THEN '2 (UPDATE)'
                             WHEN 3 THEN '3 (DELETE)'
                             WHEN 4 THEN '4 (START)'
                             WHEN 5 THEN '5 (STOP)'
                             WHEN 6 THEN '6 (RE-ENLIST)'
                             WHEN 7 THEN '7 (DEFECT)'
                             WHEN 8 THEN '8 (SYNC-TIME)'
                             WHEN 9 THEN '9 (SET-POLL)'
                             ELSE CONVERT(VARCHAR, sdl.operation_code) + ' ' + FORMATMESSAGE(14205)
                           END,
        'object_name' = ISNULL(sjv.name, CASE
                                           WHEN (sdl.operation_code >= 1) AND (sdl.operation_code <= 5) AND (sdl.object_id = CONVERT(UNIQUEIDENTIFIER, 0x00)) THEN FORMATMESSAGE(14212) -- '(all jobs)'
                                           WHEN (sdl.operation_code  = 3) AND (sdl.object_id <> CONVERT(UNIQUEIDENTIFIER, 0x00)) THEN sdl.deleted_object_name -- Special case handling for a deleted job
                                           WHEN (sdl.operation_code >= 1) AND (sdl.operation_code <= 5) AND (sdl.object_id <> CONVERT(UNIQUEIDENTIFIER, 0x00)) THEN FORMATMESSAGE(14580) -- 'job' (safety belt: should never appear)
                                           WHEN (sdl.operation_code >= 6) AND (sdl.operation_code <= 9) THEN sdl.target_server
                                           ELSE FORMATMESSAGE(14205)
                                         END),
        'object_id' = ISNULL(sjv.job_id, CASE sdl.object_id
                                           WHEN CONVERT(UNIQUEIDENTIFIER, 0x00) THEN CONVERT(UNIQUEIDENTIFIER, 0x00)
                                           ELSE sdl.object_id
                                         END),
         sdl.target_server,
         sdl.error_message,
         sdl.date_posted,
         sdl.date_downloaded,
         sdl.status
  FROM msdb.dbo.sysdownloadlist sdl LEFT OUTER JOIN
       msdb.dbo.sysjobs_view    sjv ON (sdl.object_id = sjv.job_id)
  WHERE ((@operation_code IS NULL) OR (operation_code = @operation_code))
    AND ((@object_type_id IS NULL) OR (object_type = @object_type_id))
    AND ((@job_id         IS NULL) OR (object_id = @job_id))
    AND ((@target_server  IS NULL) OR (target_server = @target_server))
    AND ((@has_error      IS NULL) OR (DATALENGTH(error_message) >= 1 * @has_error))
    AND ((@status         IS NULL) OR (status = @status))
    AND ((@date_posted    IS NULL) OR (date_posted >= @date_posted))
  ORDER BY sdl.instance_id

  RETURN(@@error) -- 0 means success

END
go

/**************************************************************/
/* SP_ENUM_SQLAGENT_SUBSYSTEMS                                */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_enum_sqlagent_subsystems...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_enum_sqlagent_subsystems')
              AND (type = 'P')))
  DROP PROCEDURE sp_enum_sqlagent_subsystems
go
CREATE PROCEDURE sp_enum_sqlagent_subsystems
AS
BEGIN
  DECLARE @part                  NVARCHAR(300)
  DECLARE @fmt                   NVARCHAR(300)
  DECLARE @subsystem             NVARCHAR(40)
  DECLARE @replication_installed INT

  SET NOCOUNT ON

  CREATE TABLE #xp_results (subsystem   NVARCHAR(40)  COLLATE database_default NOT NULL,
                            description NVARCHAR(300) COLLATE database_default NOT NULL)
  CREATE TABLE #sp_enum_ss_temp (subsystem          NVARCHAR(40)  COLLATE database_default NOT NULL,
                                 description        NVARCHAR(80)  COLLATE database_default NOT NULL,
                                 subsystem_dll      NVARCHAR(255) COLLATE database_default NULL,
                                 agent_exe          NVARCHAR(80)  COLLATE database_default NULL,
                                 start_entry_point  NVARCHAR(30)  COLLATE database_default NULL,
                                 event_entry_point  NVARCHAR(30)  COLLATE database_default NULL,
                                 stop_entry_point   NVARCHAR(30)  COLLATE database_default NULL,
                                 max_worker_threads INT           NULL)

  -- Check if replication is installed
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\Replication',
                                         N'IsInstalled',
                                         @replication_installed OUTPUT,
                                         N'no_output'
  SELECT @replication_installed = ISNULL(@replication_installed, 0)

  INSERT INTO #xp_results
  EXECUTE master.dbo.xp_instance_regenumvalues N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent\SubSystems'

  IF (@replication_installed = 0)
  BEGIN
    DELETE FROM #xp_results
    WHERE (subsystem IN (N'Distribution', N'LogReader', N'Merge', N'Snapshot', N'QueueReader'))
  END

  DECLARE all_subsystems CURSOR LOCAL
  FOR
  SELECT subsystem, description
  FROM #xp_results

  OPEN all_subsystems
  FETCH NEXT FROM all_subsystems INTO @subsystem, @part
  WHILE (@@fetch_status = 0)
  BEGIN
    IF (@subsystem = N'TSQL')
      INSERT INTO #sp_enum_ss_temp VALUES (N'TSQL', FORMATMESSAGE(14556), FORMATMESSAGE(14557), FORMATMESSAGE(14557), FORMATMESSAGE(14557), FORMATMESSAGE(14557), FORMATMESSAGE(14557), CONVERT(INT, @part))
    ELSE
    BEGIN
      SELECT @fmt = N''
      WHILE (CHARINDEX(N',', @part) > 0)
      BEGIN
        SELECT @fmt = @fmt + 'N''' + SUBSTRING(@part, 1, CHARINDEX(N',', @part) - 1) + ''', '
        SELECT @part = RIGHT(@part, (DATALENGTH(@part) / 2) - CHARINDEX(N',', @part))
      END
      SELECT @fmt = @fmt + @part
      IF (DATALENGTH(@fmt) > 0)
        INSERT INTO #sp_enum_ss_temp
        EXECUTE(N'SELECT ''' + @subsystem + N''', N'''', ' + @fmt)
    END
    FETCH NEXT FROM all_subsystems INTO @subsystem, @part
  END
  DEALLOCATE all_subsystems

  UPDATE #sp_enum_ss_temp SET description = FORMATMESSAGE(14550)
  WHERE (subsystem = N'CmdExec')
  UPDATE #sp_enum_ss_temp SET description = FORMATMESSAGE(14551)
  WHERE (subsystem = N'Snapshot')
  UPDATE #sp_enum_ss_temp SET description = FORMATMESSAGE(14552)
  WHERE (subsystem = N'LogReader')
  UPDATE #sp_enum_ss_temp SET description = FORMATMESSAGE(14553)
  WHERE (subsystem = N'Distribution')
  UPDATE #sp_enum_ss_temp SET description = FORMATMESSAGE(14554)
  WHERE (subsystem = N'Merge')
  UPDATE #sp_enum_ss_temp SET description = FORMATMESSAGE(14555)
  WHERE (subsystem = N'ActiveScripting')
  UPDATE #sp_enum_ss_temp SET description = FORMATMESSAGE(14581)
  WHERE (subsystem = N'QueueReader')

  -- 'TSQL' is always available (since it's a built-in subsystem), so we explicity add it
  -- to the result set
  IF (NOT EXISTS (SELECT *
                  FROM #sp_enum_ss_temp
                  WHERE (subsystem = N'TSQL')))
    INSERT INTO #sp_enum_ss_temp VALUES (N'TSQL', FORMATMESSAGE(14556), FORMATMESSAGE(14557), FORMATMESSAGE(14557), FORMATMESSAGE(14557), FORMATMESSAGE(14557), FORMATMESSAGE(14557), CASE (PLATFORM() & 0x2) WHEN 0x2 THEN 10 ELSE 20 END) -- Worker thread rule should match DEF_REG_MAX_TSQL_WORKER_THREADS

  SELECT subsystem,
         description,
         subsystem_dll,
         agent_exe,
         start_entry_point,
         event_entry_point,
         stop_entry_point,
         max_worker_threads
  FROM #sp_enum_ss_temp
  ORDER BY subsystem
END
go

/**************************************************************/
/* SP_VERIFY_SUBSYSTEM                                        */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_verify_subsystem...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_verify_subsystem')
              AND (type = 'P')))
  DROP PROCEDURE sp_verify_subsystem
go
CREATE PROCEDURE sp_verify_subsystem
  @subsystem NVARCHAR(40)
AS
BEGIN
  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @subsystem = LTRIM(RTRIM(@subsystem))

  -- NOTE: We don't use the results of sp_enum_sqlagent_subsystems for performance reasons
  IF (UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) IN 
                           (N'ACTIVESCRIPTING',
                            N'CMDEXEC',
                            N'DISTRIBUTION',
                            N'SNAPSHOT',
                            N'LOGREADER',
                            N'MERGE',
                            N'TSQL',
                            N'QUEUEREADER'))
    RETURN(0) -- Success
  ELSE
  BEGIN
    RAISERROR(14234, -1, -1, '@subsystem', 'sp_enum_sqlagent_subsystems')
    RETURN(1) -- Failure
  END
END
go

/**************************************************************/
/* SP_GET_JOBSTEP_DB_USERNAME                                 */
/*                                                            */
/* NOTE: For NT login names this procedure can take several   */
/*       seconds to return as it hits the PDC/BDC.            */
/*       SQLServerAgent calls this at runtime.                */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_get_jobstep_db_username...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_get_jobstep_db_username ')
              AND (type = 'P')))
  DROP PROCEDURE sp_get_jobstep_db_username
go
CREATE PROCEDURE sp_get_jobstep_db_username
  @database_name        sysname,
  @login_name           sysname = NULL,
  @username_in_targetdb sysname OUTPUT
AS
BEGIN
  DECLARE @suser_sid_clause NVARCHAR(200)

  CREATE TABLE #temp_username (user_name sysname COLLATE database_default NOT NULL, is_aliased BIT)

  -- Check the database name
  IF (DB_ID(@database_name) IS NULL)
  BEGIN
    RAISERROR(14262, 16, 1, 'database', @database_name)
    RETURN(1) -- Failure
  END

  -- Initialize return value
  SELECT @username_in_targetdb = NULL

  -- Make sure login name is never NULL
  IF (@login_name IS NULL)
    SELECT @login_name = SUSER_SNAME()
  IF (@login_name IS NULL)
    RETURN(1) -- Failure

  -- Handle an NT login name
  IF (@login_name LIKE N'%\%')
  BEGIN
    -- Special case...
    IF (UPPER(@login_name) = N'NT AUTHORITY\SYSTEM')
      SELECT @username_in_targetdb = N'dbo'
    ELSE
      SELECT @username_in_targetdb = @login_name

    RETURN(0) -- Success
  END

  -- Handle a SQL login name
  SELECT @suser_sid_clause = N'SUSER_SID(N''' + @login_name + N''')'
  IF (SUSER_SID(@login_name) IS NULL)
    RETURN(1) -- Failure

  -- 1) Look for the user name of the current login in the target database
  INSERT INTO #temp_username
  EXECUTE (N'SET NOCOUNT ON
             SELECT name, isaliased
             FROM '+ @database_name + N'.dbo.sysusers
             WHERE (sid = ' + @suser_sid_clause + N')
               AND (hasdbaccess = 1)')

  -- 2) Look for the alias user name of the current login in the target database
  IF (EXISTS (SELECT *
              FROM #temp_username
              WHERE (is_aliased = 1)))
  BEGIN
    TRUNCATE TABLE #temp_username
    INSERT INTO #temp_username
    EXECUTE (N'SET NOCOUNT ON
               SELECT name, 0
               FROM '+ @database_name + N'.dbo.sysusers
               WHERE uid = (SELECT altuid
                            FROM ' + @database_name + N'.dbo.sysusers
                            WHERE (sid = ' + @suser_sid_clause + N'))
                 AND (hasdbaccess = 1)')
  END

  -- 3) Look for the guest user name in the target database
  IF (NOT EXISTS (SELECT *
                  FROM #temp_username))
    INSERT INTO #temp_username
    EXECUTE (N'SET NOCOUNT ON
               SELECT name, 0
               FROM '+ @database_name + N'.dbo.sysusers
               WHERE (name = N''guest'')
                 AND (hasdbaccess = 1)')

  SELECT @username_in_targetdb = user_name
  FROM #temp_username

  RETURN(0) -- Success
END
go

/**************************************************************/
/* SP_VERIFY_JOBSTEP                                          */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_verify_jobstep...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_verify_jobstep')
              AND (type = 'P')))
  DROP PROCEDURE sp_verify_jobstep
go
CREATE PROCEDURE sp_verify_jobstep
  @job_id             UNIQUEIDENTIFIER,
  @step_id            INT,
  @step_name          sysname,
  @subsystem          NVARCHAR(40),
  @command            NVARCHAR(3201),
  @server             NVARCHAR(30),
  @on_success_action  TINYINT,
  @on_success_step_id INT,
  @on_fail_action     TINYINT,
  @on_fail_step_id    INT,
  @os_run_priority    INT,
  @database_name      sysname OUTPUT,
  @database_user_name sysname OUTPUT,
  @flags              INT,
  @output_file_name   NVARCHAR(200)
AS
BEGIN
  DECLARE @max_step_id             INT
  DECLARE @retval                  INT
  DECLARE @valid_values            VARCHAR(50)
  DECLARE @owner_login_name        sysname
  DECLARE @database_name_temp      sysname
  DECLARE @database_user_name_temp sysname
  DECLARE @temp_command            NVARCHAR(3200)
  DECLARE @iPos                    INT
  DECLARE @create_count            INT
  DECLARE @destroy_count           INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @subsystem        = LTRIM(RTRIM(@subsystem))
  SELECT @server           = LTRIM(RTRIM(@server))
  SELECT @output_file_name = LTRIM(RTRIM(@output_file_name))

  -- Get current maximum step id
  SELECT @max_step_id = ISNULL(MAX(step_id), 0)
  FROM msdb.dbo.sysjobsteps
  WHERE (job_id = @job_id)

  -- Check step id
  IF (@step_id < 1) OR (@step_id > @max_step_id + 1)
  BEGIN
    SELECT @valid_values = '1..' + CONVERT(VARCHAR, @max_step_id + 1)
    RAISERROR(14266, -1, -1, '@step_id', @valid_values)
    RETURN(1) -- Failure
  END

  -- Check subsystem
  EXECUTE @retval = sp_verify_subsystem @subsystem
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check command length
  IF ((DATALENGTH(@command) / 2) > 3200)
  BEGIN
    RAISERROR(14250, 16, 1, '@command', 3200)
    RETURN(1) -- Failure
  END

  -- For a VBScript command, check that object creations are paired with object destructions
  IF ((UPPER(@subsystem) = N'ACTIVESCRIPTING') AND (@database_name = N'VBScript'))
  BEGIN
    SELECT @temp_command = @command

    SELECT @create_count = 0
    SELECT @iPos = PATINDEX('%[Cc]reate[Oo]bject[ (]%', @temp_command)
    WHILE(@iPos > 0)
    BEGIN
      SELECT @temp_command = SUBSTRING(@temp_command, @iPos + 1, DATALENGTH(@temp_command) / 2)
      SELECT @iPos = PATINDEX('%[Cc]reate[Oo]bject[ (]%', @temp_command)
      SELECT @create_count = @create_count + 1
    END

    SELECT @destroy_count = 0
    SELECT @iPos = PATINDEX('%[Ss]et %=%[Nn]othing%', @temp_command)
    WHILE(@iPos > 0)
    BEGIN
      SELECT @temp_command = SUBSTRING(@temp_command, @iPos + 1, DATALENGTH(@temp_command) / 2)
      SELECT @iPos = PATINDEX('%[Ss]et %=%[Nn]othing%', @temp_command)
      SELECT @destroy_count = @destroy_count + 1
    END

    IF(@create_count > @destroy_count)
    BEGIN
      RAISERROR(14277, -1, -1)
      RETURN(1) -- Failure
    END
  END

  -- Check step name
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobsteps
              WHERE (job_id = @job_id)
                AND (step_name = @step_name)))
  BEGIN
    RAISERROR(14261, -1, -1, '@step_name', @step_name)
    RETURN(1) -- Failure
  END

  -- Check on-success action/step
  IF (@on_success_action <> 1) AND -- Quit Qith Success
     (@on_success_action <> 2) AND -- Quit Qith Failure
     (@on_success_action <> 3) AND -- Goto Next Step
     (@on_success_action <> 4)     -- Goto Step
  BEGIN
    RAISERROR(14266, -1, -1, '@on_success_action', '1, 2, 3, 4')
    RETURN(1) -- Failure
  END
  IF (@on_success_action = 4) AND
     ((@on_success_step_id < 1) OR (@on_success_step_id = @step_id))
  BEGIN
    -- NOTE: We allow forward references to non-existant steps to prevent the user from
    --       having to make a second update pass to fix up the flow
    RAISERROR(14235, -1, -1, '@on_success_step', @step_id)
    RETURN(1) -- Failure
  END

  -- Check on-fail action/step
  IF (@on_fail_action <> 1) AND -- Quit Qith Success
     (@on_fail_action <> 2) AND -- Quit Qith Failure
     (@on_fail_action <> 3) AND -- Goto Next Step
     (@on_fail_action <> 4)     -- Goto Step
  BEGIN
    RAISERROR(14266, -1, -1, '@on_failure_action', '1, 2, 3, 4')
    RETURN(1) -- Failure
  END
  IF (@on_fail_action = 4) AND
     ((@on_fail_step_id < 1) OR (@on_fail_step_id = @step_id))
  BEGIN
    -- NOTE: We allow forward references to non-existant steps to prevent the user from
    --       having to make a second update pass to fix up the flow
    RAISERROR(14235, -1, -1, '@on_failure_step', @step_id)
    RETURN(1) -- Failure
  END

  -- Warn the user about forward references
  IF ((@on_success_action = 4) AND (@on_success_step_id > @max_step_id))
    RAISERROR(14236, 0, 1, '@on_success_step_id')
  IF ((@on_fail_action = 4) AND (@on_fail_step_id > @max_step_id))
    RAISERROR(14236, 0, 1, '@on_fail_step_id')

  -- Check server (this is the replication server, NOT the job-target server)
  IF (@server IS NOT NULL) AND (NOT EXISTS (SELECT *
                                            FROM master.dbo.sysservers
                                            WHERE (UPPER(srvname) = UPPER(@server))))
  BEGIN
    RAISERROR(14234, -1, -1, '@server', 'sp_helpserver')
    RETURN(1) -- Failure
  END

  -- Check run priority: must be a valid value to pass to SetThreadPriority:
  -- [-15 = IDLE, -1 = BELOW_NORMAL, 0 = NORMAL, 1 = ABOVE_NORMAL, 15 = TIME_CRITICAL]
  IF (@os_run_priority NOT IN (-15, -1, 0, 1, 15))
  BEGIN
    RAISERROR(14266, -1, -1, '@os_run_priority', '-15, -1, 0, 1, 15')
    RETURN(1) -- Failure
  END

  -- Check flags
  IF ((@flags < 0) OR (@flags > 7))
  BEGIN
    RAISERROR(14266, -1, -1, '@flags', '0..7')
    RETURN(1) -- Failure
  END

  -- Check output file
  IF (@output_file_name IS NOT NULL) AND (UPPER(@subsystem) NOT IN ('TSQL', 'CMDEXEC'))
  BEGIN
    RAISERROR(14545, -1, -1, '@output_file_name', @subsystem)
    RETURN(1) -- Failure
  END

  -- For CmdExec steps database-name and database-user-name should both be null
  IF (UPPER(@subsystem) = N'CMDEXEC')
    SELECT @database_name = NULL,
           @database_user_name = NULL

  -- For non-TSQL steps, database-user-name should be null
  IF (UPPER(@subsystem) <> 'TSQL')
    SELECT @database_user_name = NULL

  -- For a TSQL step, get (and check) the username of the caller in the target database.
  IF (UPPER(@subsystem) = 'TSQL')
  BEGIN
    SET NOCOUNT ON

    -- But first check if remote server name has been supplied
    IF (@server IS NOT NULL)
      SELECT @server = NULL

    -- Default database to 'master' if not supplied
    IF (LTRIM(RTRIM(@database_name)) IS NULL)
      SELECT @database_name = N'master'

    -- Check the database (although this is no guarantee that @database_user_name can access it)
    IF (DB_ID(@database_name) IS NULL)
    BEGIN
      RAISERROR(14262, -1, -1, '@database_name', @database_name)
      RETURN(1) -- Failure
    END

    SELECT @owner_login_name = SUSER_SNAME(owner_sid)
    FROM msdb.dbo.sysjobs
    WHERE (job_id = @job_id)

    SELECT @database_user_name = LTRIM(RTRIM(@database_user_name))

    -- Only if a SysAdmin is creating the job can the database user name be non-NULL [since only
    -- SysAdmin's can call SETUSER].
    -- NOTE: In this case we don't try to validate the user name (it's too costly to do so)
    --       so if it's bad we'll get a runtime error when the job executes.
    IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 1)
    BEGIN
      -- Special case handling if the username is 'sa'
      IF (UPPER(@database_user_name) = N'SA')
        SELECT @database_user_name = NULL

      -- If this is a multi-server job then @database_user_name must be null
      IF (@database_user_name IS NOT NULL)
      BEGIN
        IF (EXISTS (SELECT *
                    FROM msdb.dbo.sysjobs       sj,
                         msdb.dbo.sysjobservers sjs
                    WHERE (sj.job_id = sjs.job_id)
                      AND (sj.job_id = @job_id)
                      AND (sjs.server_id <> 0)))
        BEGIN
          RAISERROR(14542, -1, -1, N'database_user_name')
          RETURN(1) -- Failure
        END
      END

      -- For a SQL-user, check if it exists
      IF (@database_user_name NOT LIKE N'%\%')
      BEGIN
        SELECT @database_user_name_temp = REPLACE(@database_user_name, N'''', N'''''')
        SELECT @database_name_temp = REPLACE(@database_name, N'''', N'''''')

        EXECUTE(N'DECLARE @ret INT
                  SELECT @ret = COUNT(*)
                  FROM ' + @database_name_temp + N'.dbo.sysusers
                  WHERE (name = N''' + @database_user_name_temp + N''')
                  HAVING (COUNT(*) > 0)')
        IF (@@ROWCOUNT = 0)
        BEGIN
          RAISERROR(14262, -1, -1, '@database_user_name', @database_user_name)
          RETURN(1) -- Failure
        END
      END
    END
    ELSE
      SELECT @database_user_name = NULL

  END  -- End of TSQL property verification

  RETURN(0) -- Success
END
go

/**************************************************************/
/* SP_ADD_JOBSTEP_INTERNAL                                    */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_add_jobstep_internal...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_add_jobstep_internal')
              AND (type = 'P')))
  DROP PROCEDURE dbo.sp_add_jobstep_internal
go
CREATE PROCEDURE dbo.sp_add_jobstep_internal
  @job_id                UNIQUEIDENTIFIER = NULL,   -- Must provide either this or job_name
  @job_name              sysname          = NULL,   -- Must provide either this or job_id
  @step_id               INT              = NULL,   -- The proc assigns a default
  @step_name             sysname,
  @subsystem             NVARCHAR(40)     = N'TSQL',
  @command               NVARCHAR(3201)   = NULL,   -- We declare this as NVARCHAR(3201) not NVARCHAR(3200) so that we can catch 'silent truncation' of commands
  @additional_parameters NTEXT            = NULL,
  @cmdexec_success_code  INT              = 0,
  @on_success_action     TINYINT          = 1,      -- 1 = Quit With Success, 2 = Quit With Failure, 3 = Goto Next Step, 4 = Goto Step
  @on_success_step_id    INT              = 0,
  @on_fail_action        TINYINT          = 2,      -- 1 = Quit With Success, 2 = Quit With Failure, 3 = Goto Next Step, 4 = Goto Step
  @on_fail_step_id       INT              = 0,
  @server                NVARCHAR(30)	  = NULL,
  @database_name         sysname          = NULL,
  @database_user_name    sysname          = NULL,
  @retry_attempts        INT              = 0,      -- No retries
  @retry_interval        INT              = 0,      -- 0 minute interval
  @os_run_priority       INT              = 0,      -- -15 = Idle, -1 = Below Normal, 0 = Normal, 1 = Above Normal, 15 = Time Critical)
  @output_file_name      NVARCHAR(200)    = NULL,
  @flags                 INT              = 0       -- 0 = Normal, 1 = Encrypted command (read only), 2 = Append output files (if any), 4 = Write TSQL step output to step history
AS
BEGIN
  DECLARE @retval      INT
  DECLARE @max_step_id INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @step_name          = LTRIM(RTRIM(@step_name))
  SELECT @subsystem          = LTRIM(RTRIM(@subsystem))
  SELECT @server             = LTRIM(RTRIM(@server))
  SELECT @database_name      = LTRIM(RTRIM(@database_name))
  SELECT @database_user_name = LTRIM(RTRIM(@database_user_name))
  SELECT @output_file_name   = LTRIM(RTRIM(@output_file_name))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@server             = N'') SELECT @server             = NULL
  IF (@database_name      = N'') SELECT @database_name      = NULL
  IF (@database_user_name = N'') SELECT @database_user_name = NULL
  IF (@output_file_name   = N'') SELECT @output_file_name   = NULL

  -- Check authority (only SQLServerAgent can add a step to a non-local job)
  EXECUTE @retval = sp_verify_jobproc_caller @job_id = @job_id, @program_name = N'SQLAgent%'
  IF (@retval <> 0)
    RETURN(@retval)

  EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                              '@job_id',
                                               @job_name OUTPUT,
                                               @job_id   OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Default step id (if not supplied)
  IF (@step_id IS NULL)
  BEGIN
    SELECT @step_id = ISNULL(MAX(step_id), 0) + 1
    FROM msdb.dbo.sysjobsteps
    WHERE (job_id = @job_id)
  END

  -- Check parameters
  EXECUTE @retval = sp_verify_jobstep @job_id,
                                      @step_id,
                                      @step_name,
                                      @subsystem,
                                      @command,
                                      @server,
                                      @on_success_action,
                                      @on_success_step_id,
                                      @on_fail_action,
                                      @on_fail_step_id,
                                      @os_run_priority,
                                      @database_name      OUTPUT,
                                      @database_user_name OUTPUT,
                                      @flags,
                                      @output_file_name
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Get current maximum step id
  SELECT @max_step_id = ISNULL(MAX(step_id), 0)
  FROM msdb.dbo.sysjobsteps
  WHERE (job_id = @job_id)

  BEGIN TRANSACTION

    -- Update the job's version/last-modified information
    UPDATE msdb.dbo.sysjobs
    SET version_number = version_number + 1,
        date_modified = GETDATE()
    WHERE (job_id = @job_id)

    -- Adjust step id's (unless the new step is being inserted at the 'end')
    -- NOTE: We MUST do this before inserting the step.
    IF (@step_id <= @max_step_id)
    BEGIN
      UPDATE msdb.dbo.sysjobsteps
      SET step_id = step_id + 1
      WHERE (step_id >= @step_id)
        AND (job_id = @job_id)

      -- Clean up OnSuccess/OnFail references
      UPDATE msdb.dbo.sysjobsteps
      SET on_success_step_id = on_success_step_id + 1
      WHERE (on_success_step_id >= @step_id)
        AND (job_id = @job_id)

      UPDATE msdb.dbo.sysjobsteps
      SET on_fail_step_id = on_fail_step_id + 1
      WHERE (on_fail_step_id >= @step_id)
        AND (job_id = @job_id)

      UPDATE msdb.dbo.sysjobsteps
      SET on_success_step_id = 0,
          on_success_action = 1  -- Quit With Success
      WHERE (on_success_step_id = @step_id)
        AND (job_id = @job_id)

      UPDATE msdb.dbo.sysjobsteps
      SET on_fail_step_id = 0,
          on_fail_action = 2     -- Quit With Failure
      WHERE (on_fail_step_id = @step_id)
        AND (job_id = @job_id)
    END

    -- Insert the step
    INSERT INTO msdb.dbo.sysjobsteps
           (job_id,
            step_id,
            step_name,
            subsystem,
            command,
            flags,
            additional_parameters,
            cmdexec_success_code,
            on_success_action,
            on_success_step_id,
            on_fail_action,
            on_fail_step_id,
            server,
            database_name,
            database_user_name,
            retry_attempts,
            retry_interval,
            os_run_priority,
            output_file_name,
            last_run_outcome,
            last_run_duration,
            last_run_retries,
            last_run_date,
            last_run_time)
    VALUES (@job_id,
            @step_id,
            @step_name,
            @subsystem,
            @command,
            @flags,
            @additional_parameters,
            @cmdexec_success_code,
            @on_success_action,
            @on_success_step_id,
            @on_fail_action,
            @on_fail_step_id,
            @server,
            @database_name,
            @database_user_name,
            @retry_attempts,
            @retry_interval,
            @os_run_priority,
            @output_file_name,
            0,
            0,
            0,
            0,
            0)

  COMMIT TRANSACTION

  -- Make sure that SQLServerAgent refreshes the job if the 'Has Steps' property has changed
  IF ((SELECT COUNT(*)
       FROM msdb.dbo.sysjobsteps
       WHERE (job_id = @job_id)) = 1)
  BEGIN
    -- NOTE: We only notify SQLServerAgent if we know the job has been cached
    IF (EXISTS (SELECT *
                FROM msdb.dbo.sysjobservers
                WHERE (job_id = @job_id)
                  AND (server_id = 0)))
      EXECUTE msdb.dbo.sp_sqlagent_notify @op_type       = N'J',
                                            @job_id      = @job_id,
                                            @action_type = N'U'
  END

  -- For a multi-server job, remind the user that they need to call sp_post_msx_operation
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobservers
              WHERE (job_id = @job_id)
                AND (server_id <> 0)))
    RAISERROR(14547, 0, 1, N'INSERT', N'sp_post_msx_operation')

  RETURN(0) -- Success
END
go

/**************************************************************/
/* SP_ADD_JOBSTEP                                             */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_add_jobstep...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_add_jobstep')
              AND (type = 'P')))
  DROP PROCEDURE dbo.sp_add_jobstep
go
CREATE PROCEDURE dbo.sp_add_jobstep
  @job_id                UNIQUEIDENTIFIER = NULL,   -- Must provide either this or job_name
  @job_name              sysname          = NULL,   -- Must provide either this or job_id
  @step_id               INT              = NULL,   -- The proc assigns a default
  @step_name             sysname,
  @subsystem             NVARCHAR(40)     = N'TSQL',
  @command               NVARCHAR(3201)   = NULL,   -- We declare this as NVARCHAR(3201) not NVARCHAR(3200) so that we can catch 'silent truncation' of commands
  @additional_parameters NTEXT            = NULL,
  @cmdexec_success_code  INT              = 0,
  @on_success_action     TINYINT          = 1,      -- 1 = Quit With Success, 2 = Quit With Failure, 3 = Goto Next Step, 4 = Goto Step
  @on_success_step_id    INT              = 0,
  @on_fail_action        TINYINT          = 2,      -- 1 = Quit With Success, 2 = Quit With Failure, 3 = Goto Next Step, 4 = Goto Step
  @on_fail_step_id       INT              = 0,
  @server                NVARCHAR(30)	  = NULL,
  @database_name         sysname          = NULL,
  @database_user_name    sysname          = NULL,
  @retry_attempts        INT              = 0,      -- No retries
  @retry_interval        INT              = 0,      -- 0 minute interval
  @os_run_priority       INT              = 0,      -- -15 = Idle, -1 = Below Normal, 0 = Normal, 1 = Above Normal, 15 = Time Critical)
  @output_file_name      NVARCHAR(200)    = NULL,
  @flags                 INT              = 0       -- 0 = Normal, 1 = Encrypted command (read only), 2 = Append output files (if any), 4 = Write TSQL step output to step history
AS
BEGIN
  DECLARE @retval      INT

  SET NOCOUNT ON

  -- Only sysadmin's or db_owner's of msdb can add replication job steps directly
  IF (UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) IN
                        (N'DISTRIBUTION',
                         N'SNAPSHOT',
                         N'LOGREADER',
                         N'MERGE',
                         N'QUEUEREADER'))
  BEGIN
    IF NOT ((ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 1) OR
            (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1) OR
            (UPPER(USER_NAME()) = N'DBO'))
    BEGIN
      RAISERROR(14260, -1, -1)
      RETURN(1) -- Failure
    END
  END

  EXECUTE @retval = dbo.sp_add_jobstep_internal @job_id = @job_id,
                                                @job_name = @job_name,
                                                @step_id = @step_id,
                                                @step_name = @step_name,
                                                @subsystem = @subsystem,
                                                @command = @command,
                                                @additional_parameters = @additional_parameters,
                                                @cmdexec_success_code = @cmdexec_success_code,
                                                @on_success_action = @on_success_action,
                                                @on_success_step_id = @on_success_step_id,
                                                @on_fail_action = @on_fail_action,
                                                @on_fail_step_id = @on_fail_step_id,
                                                @server = @server,
                                                @database_name = @database_name,
                                                @database_user_name = @database_user_name,
                                                @retry_attempts = @retry_attempts,
                                                @retry_interval = @retry_interval,
                                                @os_run_priority = @os_run_priority,
                                                @output_file_name = @output_file_name,
                                                @flags = @flags

  RETURN(@retval)
END
GO

/**************************************************************/
/* SP_UPDATE_JOBSTEP                                          */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_update_jobstep...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_update_jobstep')
              AND (type = 'P')))
  DROP PROCEDURE sp_update_jobstep
go
CREATE PROCEDURE sp_update_jobstep
  @job_id                 UNIQUEIDENTIFIER = NULL, -- Must provide either this or job_name
  @job_name               sysname          = NULL, -- Not updatable (provided for identification purposes only)
  @step_id                INT,                     -- Not updatable (provided for identification purposes only)
  @step_name              sysname          = NULL,
  @subsystem              NVARCHAR(40)     = NULL,
  @command                NVARCHAR(3201)   = NULL, -- We declare this as NVARCHAR(3201) not NVARCHAR(3200) so that we can catch 'silent truncation' of commands
  @additional_parameters  NTEXT            = NULL,
  @cmdexec_success_code   INT              = NULL,
  @on_success_action      TINYINT          = NULL,
  @on_success_step_id     INT              = NULL,
  @on_fail_action         TINYINT          = NULL,
  @on_fail_step_id        INT              = NULL,
  @server                 NVARCHAR(30)     = NULL,
  @database_name          sysname          = NULL,
  @database_user_name     sysname          = NULL,
  @retry_attempts         INT              = NULL,
  @retry_interval         INT              = NULL,
  @os_run_priority        INT              = NULL,
  @output_file_name       NVARCHAR(200)    = NULL,
  @flags                  INT              = NULL
AS
BEGIN
  DECLARE @retval                 INT
  DECLARE @os_run_priority_code   INT
  DECLARE @step_id_as_char        VARCHAR(10)
  DECLARE @new_step_name          sysname

  DECLARE @x_step_name            sysname
  DECLARE @x_subsystem            NVARCHAR(40)
  DECLARE @x_command              NVARCHAR(3200)
  DECLARE @x_flags                INT
  DECLARE @x_cmdexec_success_code INT
  DECLARE @x_on_success_action    TINYINT
  DECLARE @x_on_success_step_id   INT
  DECLARE @x_on_fail_action       TINYINT
  DECLARE @x_on_fail_step_id      INT
  DECLARE @x_server               NVARCHAR(30)
  DECLARE @x_database_name        sysname
  DECLARE @x_database_user_name   sysname
  DECLARE @x_retry_attempts       INT
  DECLARE @x_retry_interval       INT
  DECLARE @x_os_run_priority      INT
  DECLARE @x_output_file_name     NVARCHAR(200)
  DECLARE @x_last_run_outcome     TINYINT      -- Not updatable (but may be in future)
  DECLARE @x_last_run_duration    INT          -- Not updatable (but may be in future)
  DECLARE @x_last_run_retries     INT          -- Not updatable (but may be in future)
  DECLARE @x_last_run_date        INT          -- Not updatable (but may be in future)
  DECLARE @x_last_run_time        INT          -- Not updatable (but may be in future)

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @step_name          = LTRIM(RTRIM(@step_name))
  SELECT @subsystem          = LTRIM(RTRIM(@subsystem))
  SELECT @command            = LTRIM(RTRIM(@command))
  SELECT @server             = LTRIM(RTRIM(@server))
  SELECT @database_name      = LTRIM(RTRIM(@database_name))
  SELECT @database_user_name = LTRIM(RTRIM(@database_user_name))
  SELECT @output_file_name   = LTRIM(RTRIM(@output_file_name))

  -- Only sysadmin's or db_owner's of msdb can directly change
  -- an existing job step to use one of the replication
  -- subsystems
  IF (UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) IN
                        (N'DISTRIBUTION',
                         N'SNAPSHOT',
                         N'LOGREADER',
                         N'MERGE',
                         N'QUEUEREADER'))
  BEGIN
    IF NOT ((ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 1) OR
            (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1) OR
            (UPPER(USER_NAME()) = N'DBO'))
    BEGIN
      RAISERROR(14260, -1, -1)
      RETURN(1) -- Failure
    END
  END

  EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                              '@job_id',
                                               @job_name OUTPUT,
                                               @job_id   OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check that the step exists
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysjobsteps
                  WHERE (job_id = @job_id)
                    AND (step_id = @step_id)))
  BEGIN
    SELECT @step_id_as_char = CONVERT(VARCHAR(10), @step_id)
    RAISERROR(14262, -1, -1, '@step_id', @step_id_as_char)
    RETURN(1) -- Failure
  END

  -- Check authority (only SQLServerAgent can modify a step of a non-local job)
  EXECUTE @retval = sp_verify_jobproc_caller @job_id = @job_id, @program_name = N'SQLAgent%'
  IF (@retval <> 0)
    RETURN(@retval)

  -- Set the x_ (existing) variables
  SELECT @x_step_name            = step_name,
         @x_subsystem            = subsystem,
         @x_command              = command,
         @x_flags                = flags,
         @x_cmdexec_success_code = cmdexec_success_code,
         @x_on_success_action    = on_success_action,
         @x_on_success_step_id   = on_success_step_id,
         @x_on_fail_action       = on_fail_action,
         @x_on_fail_step_id      = on_fail_step_id,
         @x_server               = server,
         @x_database_name        = database_name,
         @x_database_user_name   = database_user_name,
         @x_retry_attempts       = retry_attempts,
         @x_retry_interval       = retry_interval,
         @x_os_run_priority      = os_run_priority,
         @x_output_file_name     = output_file_name,
         @x_last_run_outcome     = last_run_outcome,
         @x_last_run_duration    = last_run_duration,
         @x_last_run_retries     = last_run_retries,
         @x_last_run_date        = last_run_date,
         @x_last_run_time        = last_run_time
  FROM msdb.dbo.sysjobsteps
  WHERE (job_id = @job_id)
    AND (step_id = @step_id)

  IF ((@step_name IS NOT NULL) AND (@step_name <> @x_step_name))
    SELECT @new_step_name = @step_name

  -- Fill out the values for all non-supplied parameters from the existing values
  IF (@step_name            IS NULL) SELECT @step_name            = @x_step_name
  IF (@subsystem            IS NULL) SELECT @subsystem            = @x_subsystem
  IF (@command              IS NULL) SELECT @command              = @x_command
  IF (@flags                IS NULL) SELECT @flags                = @x_flags
  IF (@cmdexec_success_code IS NULL) SELECT @cmdexec_success_code = @x_cmdexec_success_code
  IF (@on_success_action    IS NULL) SELECT @on_success_action    = @x_on_success_action
  IF (@on_success_step_id   IS NULL) SELECT @on_success_step_id   = @x_on_success_step_id
  IF (@on_fail_action       IS NULL) SELECT @on_fail_action       = @x_on_fail_action
  IF (@on_fail_step_id      IS NULL) SELECT @on_fail_step_id      = @x_on_fail_step_id
  IF (@server               IS NULL) SELECT @server               = @x_server
  IF (@database_name        IS NULL) SELECT @database_name        = @x_database_name
  IF (@database_user_name   IS NULL) SELECT @database_user_name   = @x_database_user_name
  IF (@retry_attempts       IS NULL) SELECT @retry_attempts       = @x_retry_attempts
  IF (@retry_interval       IS NULL) SELECT @retry_interval       = @x_retry_interval
  IF (@os_run_priority      IS NULL) SELECT @os_run_priority      = @x_os_run_priority
  IF (@output_file_name     IS NULL) SELECT @output_file_name     = @x_output_file_name

  -- Turn [nullable] empty string parameters into NULLs
  IF (@command            = N'') SELECT @command            = NULL
  IF (@server             = N'') SELECT @server             = NULL
  IF (@database_name      = N'') SELECT @database_name      = NULL
  IF (@database_user_name = N'') SELECT @database_user_name = NULL
  IF (@output_file_name   = N'') SELECT @output_file_name   = NULL

  -- Check new values
  EXECUTE @retval = sp_verify_jobstep @job_id,
                                      @step_id,
                                      @new_step_name,
                                      @subsystem,
                                      @command,
                                      @server,
                                      @on_success_action,
                                      @on_success_step_id,
                                      @on_fail_action,
                                      @on_fail_step_id,
                                      @os_run_priority,
                                      @database_name      OUTPUT,
                                      @database_user_name OUTPUT,
                                      @flags,
                                      @output_file_name
  IF (@retval <> 0)
    RETURN(1) -- Failure

  BEGIN TRANSACTION

    -- Update the job's version/last-modified information
    UPDATE msdb.dbo.sysjobs
    SET version_number = version_number + 1,
        date_modified = GETDATE()
    WHERE (job_id = @job_id)

    -- Update the step
    UPDATE msdb.dbo.sysjobsteps
    SET step_name             = @step_name,
        subsystem             = @subsystem,
        command               = @command,
        flags                 = @flags,
        cmdexec_success_code  = @cmdexec_success_code,
        on_success_action     = @on_success_action,
        on_success_step_id    = @on_success_step_id,
        on_fail_action        = @on_fail_action,
        on_fail_step_id       = @on_fail_step_id,
        server                = @server,
        database_name         = @database_name,
        database_user_name    = @database_user_name,
        retry_attempts        = @retry_attempts,
        retry_interval        = @retry_interval,
        os_run_priority       = @os_run_priority,
        output_file_name      = @output_file_name,
        last_run_outcome      = @x_last_run_outcome,
        last_run_duration     = @x_last_run_duration,
        last_run_retries      = @x_last_run_retries,
        last_run_date         = @x_last_run_date,
        last_run_time         = @x_last_run_time
    WHERE (job_id = @job_id)
      AND (step_id = @step_id)

    -- Since we can't declare TEXT parameters (and therefore use the @x_ technique) we handle
    -- @additional_parameters as a special case...
    IF (@additional_parameters IS NOT NULL)
    BEGIN
      UPDATE msdb.dbo.sysjobsteps
      SET additional_parameters = @additional_parameters
      WHERE (job_id = @job_id)
        AND (step_id = @step_id)
    END

  COMMIT TRANSACTION

  -- For a multi-server job, remind the user that they need to call sp_post_msx_operation
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobservers
              WHERE (job_id = @job_id)
                AND (server_id <> 0)))
    RAISERROR(14547, 0, 1, N'INSERT', N'sp_post_msx_operation')

  RETURN(0) -- Success
END
go

/**************************************************************/
/* SP_DELETE_JOBSTEP                                          */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_delete_jobstep...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_delete_jobstep')
              AND (type = 'P')))
  DROP PROCEDURE sp_delete_jobstep
go
CREATE PROCEDURE sp_delete_jobstep
  @job_id   UNIQUEIDENTIFIER = NULL, -- Must provide either this or job_name
  @job_name sysname          = NULL, -- Must provide either this or job_id
  @step_id  INT
AS
BEGIN
  DECLARE @retval      INT
  DECLARE @max_step_id INT
  DECLARE @valid_range VARCHAR(50)

  SET NOCOUNT ON

  EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                              '@job_id',
                                               @job_name OUTPUT,
                                               @job_id   OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check authority (only SQLServerAgent can delete a step of a non-local job)
  EXECUTE @retval = sp_verify_jobproc_caller @job_id = @job_id, @program_name = 'SQLAgent%'
  IF (@retval <> 0)
    RETURN(@retval)

  -- Get current maximum step id
  SELECT @max_step_id = ISNULL(MAX(step_id), 0)
  FROM msdb.dbo.sysjobsteps
  WHERE (job_id = @job_id)

  -- Check step id
  IF (@step_id < 0) OR (@step_id > @max_step_id)
  BEGIN
    SELECT @valid_range = FORMATMESSAGE(14201) + CONVERT(VARCHAR, @max_step_id)
    RAISERROR(14266, -1, -1, '@step_id', @valid_range)
    RETURN(1) -- Failure
  END

  BEGIN TRANSACTION

    -- Delete either the specified step or ALL the steps (if step id is 0)
    IF (@step_id = 0)
      DELETE FROM msdb.dbo.sysjobsteps
      WHERE (job_id = @job_id)
    ELSE
      DELETE FROM msdb.dbo.sysjobsteps
      WHERE (job_id = @job_id)
        AND (step_id = @step_id)

    IF (@step_id <> 0)
    BEGIN
      -- Adjust step id's
      UPDATE msdb.dbo.sysjobsteps
      SET step_id = step_id - 1
      WHERE (step_id > @step_id)
        AND (job_id = @job_id)

      -- Clean up OnSuccess/OnFail references
      UPDATE msdb.dbo.sysjobsteps
      SET on_success_step_id = on_success_step_id - 1
      WHERE (on_success_step_id > @step_id)
        AND (job_id = @job_id)

      UPDATE msdb.dbo.sysjobsteps
      SET on_fail_step_id = on_fail_step_id - 1
      WHERE (on_fail_step_id > @step_id)
        AND (job_id = @job_id)

      UPDATE msdb.dbo.sysjobsteps
      SET on_success_step_id = 0,
          on_success_action = 1   -- Quit With Success
      WHERE (on_success_step_id = @step_id)
        AND (job_id = @job_id)

      UPDATE msdb.dbo.sysjobsteps
      SET on_fail_step_id = 0,
          on_fail_action = 2   -- Quit With Failure
      WHERE (on_fail_step_id = @step_id)
        AND (job_id = @job_id)
    END

    -- Update the job's version/last-modified information
    UPDATE msdb.dbo.sysjobs
    SET version_number = version_number + 1,
        date_modified = GETDATE()
    WHERE (job_id = @job_id)

  COMMIT TRANSACTION

  -- Make sure that SQLServerAgent refreshes the job if the 'Has Steps' property has changed
  IF ((SELECT COUNT(*)
       FROM msdb.dbo.sysjobsteps
       WHERE (job_id = @job_id)) = 0)
  BEGIN
    -- NOTE: We only notify SQLServerAgent if we know the job has been cached
    IF (EXISTS (SELECT *
                FROM msdb.dbo.sysjobservers
                WHERE (job_id = @job_id)
                  AND (server_id = 0)))
      EXECUTE msdb.dbo.sp_sqlagent_notify @op_type       = N'J',
                                            @job_id      = @job_id,
                                            @action_type = N'U'
  END

  -- For a multi-server job, remind the user that they need to call sp_post_msx_operation
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobservers
              WHERE (job_id = @job_id)
                AND (server_id <> 0)))
    RAISERROR(14547, 0, 1, N'INSERT', N'sp_post_msx_operation')

  RETURN(0) -- Success
END
go

/**************************************************************/
/* SP_HELP_JOBSTEP                                            */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_help_jobstep...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_help_jobstep')
              AND (type = 'P')))
  DROP PROCEDURE sp_help_jobstep
go
CREATE PROCEDURE sp_help_jobstep
  @job_id    UNIQUEIDENTIFIER = NULL, -- Must provide either this or job_name
  @job_name  sysname          = NULL, -- Must provide either this or job_id
  @step_id   INT              = NULL,
  @step_name sysname          = NULL,
  @suffix    BIT              = 0     -- A flag to control how the result set is formatted
AS
BEGIN
  DECLARE @retval      INT
  DECLARE @max_step_id INT
  DECLARE @valid_range VARCHAR(50)

  SET NOCOUNT ON

  EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                              '@job_id',
                                               @job_name OUTPUT,
                                               @job_id   OUTPUT,
                                              'NO_TEST'
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- The suffix flag must be either 0 (ie. no suffix) or 1 (ie. add suffix). 0 is the default.
  IF (@suffix <> 0)
    SELECT @suffix = 1

  -- Check step id (if supplied)
  IF (@step_id IS NOT NULL)
  BEGIN
    -- Get current maximum step id
    SELECT @max_step_id = ISNULL(MAX(step_id), 0)
    FROM msdb.dbo.sysjobsteps
    WHERE job_id = @job_id

    IF (@step_id < 1) OR (@step_id > @max_step_id)
    BEGIN
      SELECT @valid_range = '1..' + CONVERT(VARCHAR, @max_step_id)
      RAISERROR(14266, -1, -1, '@step_id', @valid_range)
      RETURN(1) -- Failure
    END
  END

  -- Check step name (if supplied)
  -- NOTE: A supplied step id overrides a supplied step name
  IF ((@step_id IS NULL) AND (@step_name IS NOT NULL))
  BEGIN
    SELECT @step_id = step_id
    FROM msdb.dbo.sysjobsteps
    WHERE (step_name = @step_name)
      AND (job_id = @job_id)

    IF (@step_id IS NULL)
    BEGIN
      RAISERROR(14262, -1, -1, '@step_name', @step_name)
      RETURN(1) -- Failure
    END
  END

  -- Return the job steps for this job (or just return the specific step)
  IF (@suffix = 0)
  BEGIN
    SELECT step_id,
           step_name,
           subsystem,
           command,
           flags,
           cmdexec_success_code,
           on_success_action,
           on_success_step_id,
           on_fail_action,
           on_fail_step_id,
           server,
           database_name,
           database_user_name,
           retry_attempts,
           retry_interval,
           os_run_priority,
           output_file_name,
           last_run_outcome,
           last_run_duration,
           last_run_retries,
           last_run_date,
           last_run_time
    FROM msdb.dbo.sysjobsteps
    WHERE (job_id = @job_id)
      AND ((@step_id IS NULL) OR (step_id = @step_id))
  END
  ELSE
  BEGIN
    SELECT step_id,
           step_name,
           subsystem,
           command,
          'flags' = CONVERT(NVARCHAR, flags) + N' (' +
                    ISNULL(CASE WHEN (flags = 0)     THEN FORMATMESSAGE(14561) END, '') +
                    ISNULL(CASE WHEN (flags & 1) = 1 THEN FORMATMESSAGE(14558) + ISNULL(CASE WHEN (flags > 1) THEN N', ' END, '') END, '') +
                    ISNULL(CASE WHEN (flags & 2) = 2 THEN FORMATMESSAGE(14559) + ISNULL(CASE WHEN (flags > 3) THEN N', ' END, '') END, '') +
                    ISNULL(CASE WHEN (flags & 4) = 4 THEN FORMATMESSAGE(14560) END, '') + N')',
           cmdexec_success_code,
          'on_success_action' = CASE on_success_action
                                  WHEN 1 THEN CONVERT(NVARCHAR, on_success_action) + N' ' + FORMATMESSAGE(14562)
                                  WHEN 2 THEN CONVERT(NVARCHAR, on_success_action) + N' ' + FORMATMESSAGE(14563)
                                  WHEN 3 THEN CONVERT(NVARCHAR, on_success_action) + N' ' + FORMATMESSAGE(14564)
                                  WHEN 4 THEN CONVERT(NVARCHAR, on_success_action) + N' ' + FORMATMESSAGE(14565)
                                  ELSE        CONVERT(NVARCHAR, on_success_action) + N' ' + FORMATMESSAGE(14205)
                                END,
           on_success_step_id,
          'on_fail_action' = CASE on_fail_action
                               WHEN 1 THEN CONVERT(NVARCHAR, on_fail_action) + N' ' + FORMATMESSAGE(14562)
                               WHEN 2 THEN CONVERT(NVARCHAR, on_fail_action) + N' ' + FORMATMESSAGE(14563)
                               WHEN 3 THEN CONVERT(NVARCHAR, on_fail_action) + N' ' + FORMATMESSAGE(14564)
                               WHEN 4 THEN CONVERT(NVARCHAR, on_fail_action) + N' ' + FORMATMESSAGE(14565)
                               ELSE        CONVERT(NVARCHAR, on_fail_action) + N' ' + FORMATMESSAGE(14205)
                             END,
           on_fail_step_id,
           server,
           database_name,
           database_user_name,
           retry_attempts,
           retry_interval,
          'os_run_priority' = CASE os_run_priority
                                WHEN -15 THEN CONVERT(NVARCHAR, os_run_priority) + N' ' + FORMATMESSAGE(14566)
                                WHEN -1  THEN CONVERT(NVARCHAR, os_run_priority) + N' ' + FORMATMESSAGE(14567)
                                WHEN  0  THEN CONVERT(NVARCHAR, os_run_priority) + N' ' + FORMATMESSAGE(14561)
                                WHEN  1  THEN CONVERT(NVARCHAR, os_run_priority) + N' ' + FORMATMESSAGE(14568)
                                WHEN  15 THEN CONVERT(NVARCHAR, os_run_priority) + N' ' + FORMATMESSAGE(14569)
                                ELSE          CONVERT(NVARCHAR, os_run_priority) + N' ' + FORMATMESSAGE(14205)
                              END,
           output_file_name,
           last_run_outcome,
           last_run_duration,
           last_run_retries,
           last_run_date,
           last_run_time
    FROM msdb.dbo.sysjobsteps
    WHERE (job_id = @job_id)
      AND ((@step_id IS NULL) OR (step_id = @step_id))
  END

  RETURN(@@error) -- 0 means success

END
go

/**************************************************************/
/* SP_GET_SCHEDULE_DESCRIPTION                                */
/*                                                            */
/* NOTE: This SP only returns an English description of the   */
/*       schedule due to the piecemeal nature of the          */
/*       description's construction.                          */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_get_schedule_description...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_get_schedule_description')
              AND (type = 'P')))
  DROP PROCEDURE sp_get_schedule_description
go
CREATE PROCEDURE sp_get_schedule_description
  @freq_type              INT          = NULL,
  @freq_interval          INT          = NULL,
  @freq_subday_type       INT          = NULL,
  @freq_subday_interval   INT          = NULL,
  @freq_relative_interval INT          = NULL,
  @freq_recurrence_factor INT          = NULL,
  @active_start_date      INT          = NULL,
  @active_end_date        INT          = NULL,
  @active_start_time      INT          = NULL,
  @active_end_time        INT          = NULL,
  @schedule_description   NVARCHAR(255) OUTPUT
AS
BEGIN
  DECLARE @loop              INT
  DECLARE @idle_cpu_percent  INT
  DECLARE @idle_cpu_duration INT

  SET NOCOUNT ON

  IF (@freq_type = 0x1) -- OneTime
  BEGIN
    SELECT @schedule_description = N'Once on ' + CONVERT(NVARCHAR, @active_start_date) + N' at ' + CONVERT(NVARCHAR, @active_start_time)
    RETURN
  END

  IF (@freq_type = 0x4) -- Daily
  BEGIN
    SELECT @schedule_description = N'Every day '
  END

  IF (@freq_type = 0x8) -- Weekly
  BEGIN
    SELECT @schedule_description = N'Every ' + CONVERT(NVARCHAR, @freq_recurrence_factor) + N' week(s) on '
    SELECT @loop = 1
    WHILE (@loop <= 7)
    BEGIN
      IF (@freq_interval & POWER(2, @loop - 1) = POWER(2, @loop - 1))
        SELECT @schedule_description = @schedule_description + DATENAME(dw, N'1996120' + CONVERT(NVARCHAR, @loop)) + N', '
      SELECT @loop = @loop + 1
    END
    IF (RIGHT(@schedule_description, 2) = N', ')
      SELECT @schedule_description = SUBSTRING(@schedule_description, 1, (DATALENGTH(@schedule_description) / 2) - 2) + N' '
  END

  IF (@freq_type = 0x10) -- Monthly
  BEGIN
    SELECT @schedule_description = N'Every ' + CONVERT(NVARCHAR, @freq_recurrence_factor) + N' months(s) on day ' + CONVERT(NVARCHAR, @freq_interval) + N' of that month '
  END

  IF (@freq_type = 0x20) -- Monthly Relative
  BEGIN
    SELECT @schedule_description = N'Every ' + CONVERT(NVARCHAR, @freq_recurrence_factor) + N' months(s) on the '
    SELECT @schedule_description = @schedule_description +
      CASE @freq_relative_interval
        WHEN 0x01 THEN N'first '
        WHEN 0x02 THEN N'second '
        WHEN 0x04 THEN N'third '
        WHEN 0x08 THEN N'fourth '
        WHEN 0x10 THEN N'last '
      END +
      CASE
        WHEN (@freq_interval > 00)
         AND (@freq_interval < 08) THEN DATENAME(dw, N'1996120' + CONVERT(NVARCHAR, @freq_interval))
        WHEN (@freq_interval = 08) THEN N'day'
        WHEN (@freq_interval = 09) THEN N'week day'
        WHEN (@freq_interval = 10) THEN N'weekend day'
      END + N' of that month '
  END

  IF (@freq_type = 0x40) -- AutoStart
  BEGIN
    SELECT @schedule_description = FORMATMESSAGE(14579)
    RETURN
  END

  IF (@freq_type = 0x80) -- OnIdle
  BEGIN
    EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                           N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                           N'IdleCPUPercent',
                                           @idle_cpu_percent OUTPUT,
                                           N'no_output'
    EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                           N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                           N'IdleCPUDuration',
                                           @idle_cpu_duration OUTPUT,
                                           N'no_output'
    SELECT @schedule_description = FORMATMESSAGE(14578, ISNULL(@idle_cpu_percent, 10), ISNULL(@idle_cpu_duration, 600))
    RETURN
  END

  -- Subday stuff
  SELECT @schedule_description = @schedule_description +
    CASE @freq_subday_type
      WHEN 0x1 THEN N'at ' + CONVERT(NVARCHAR, @active_start_time)
      WHEN 0x2 THEN N'every ' + CONVERT(NVARCHAR, @freq_subday_interval) + N' second(s)'
      WHEN 0x4 THEN N'every ' + CONVERT(NVARCHAR, @freq_subday_interval) + N' minute(s)'
      WHEN 0x8 THEN N'every ' + CONVERT(NVARCHAR, @freq_subday_interval) + N' hour(s)'
    END
  IF (@freq_subday_type IN (0x2, 0x4, 0x8))
    SELECT @schedule_description = @schedule_description + N' between ' +
           CONVERT(NVARCHAR, @active_start_time) + N' and ' + CONVERT(NVARCHAR, @active_end_time)
END
go

DUMP TRANSACTION msdb WITH NO_LOG
go
CHECKPOINT
go

/**************************************************************/
/* SP_VERIFY_JOBSCHEDULE                                      */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_verify_jobschedule...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_verify_jobschedule')
              AND (type = 'P')))
  DROP PROCEDURE sp_verify_jobschedule
go
CREATE PROCEDURE sp_verify_jobschedule
  @name                   sysname,
  @enabled                TINYINT,
  @freq_type              INT,
  @freq_interval          INT OUTPUT,   -- Output because we may set it to 0 if Frequency Type is one-time or auto-start
  @freq_subday_type       INT OUTPUT,   -- As above
  @freq_subday_interval   INT OUTPUT,   -- As above
  @freq_relative_interval INT OUTPUT,   -- As above
  @freq_recurrence_factor INT OUTPUT,   -- As above
  @active_start_date      INT OUTPUT,
  @active_start_time      INT OUTPUT,
  @active_end_date        INT OUTPUT,
  @active_end_time        INT OUTPUT,
  @job_id                 UNIQUEIDENTIFIER,
  @schedule_id            INT           -- Will only be provided by sp_update_jobschedule
AS
BEGIN
  DECLARE @return_code             INT
  DECLARE @duplicate_schedule_id   INT
  DECLARE @duplicate_schedule_name sysname
  DECLARE @res_valid_range         NVARCHAR(100)
  DECLARE @reason                  NVARCHAR(200)

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @name = LTRIM(RTRIM(@name))

  -- Make sure that NULL input/output parameters - if NULL - are initialized to 0
  SELECT @freq_interval          = ISNULL(@freq_interval, 0)
  SELECT @freq_subday_type       = ISNULL(@freq_subday_type, 0)
  SELECT @freq_subday_interval   = ISNULL(@freq_subday_interval, 0)
  SELECT @freq_relative_interval = ISNULL(@freq_relative_interval, 0)
  SELECT @freq_recurrence_factor = ISNULL(@freq_recurrence_factor, 0)
  SELECT @active_start_date      = ISNULL(@active_start_date, 0)
  SELECT @active_start_time      = ISNULL(@active_start_time, 0)
  SELECT @active_end_date        = ISNULL(@active_end_date, 0)
  SELECT @active_end_time        = ISNULL(@active_end_time, 0)

  -- Verify name (we disallow schedules called 'ALL' since this has special meaning in sp_delete_jobschedules)
  IF (UPPER(@name) = N'ALL')
  BEGIN
    RAISERROR(14200, -1, -1, '@name')
    RETURN(1) -- Failure
  END

  -- Verify enabled state
  IF (@enabled <> 0) AND (@enabled <> 1)
  BEGIN
    RAISERROR(14266, -1, -1, '@enabled', '0, 1')
    RETURN(1) -- Failure
  END

  -- Verify frequency type
  IF (@freq_type = 0x2) -- OnDemand is no longer supported
  BEGIN
    RAISERROR(14295, -1, -1)
    RETURN(1) -- Failure
  END
  IF (@freq_type NOT IN (0x1, 0x4, 0x8, 0x10, 0x20, 0x40, 0x80))
  BEGIN
    RAISERROR(14266, -1, -1, '@freq_type', '0x1, 0x4, 0x8, 0x10, 0x20, 0x40, 0x80')
    RETURN(1) -- Failure
  END

  -- Verify frequency sub-day type
  IF (@freq_subday_type <> 0) AND (@freq_subday_type NOT IN (0x1, 0x2, 0x4, 0x8))
  BEGIN
    RAISERROR(14266, -1, -1, '@freq_subday_type', '0x1, 0x2, 0x4, 0x8')
    RETURN(1) -- Failure
  END

  -- Default active start/end date/times (if not supplied, or supplied as NULLs or 0)
  IF (@active_start_date = 0)
    SELECT @active_start_date = DATEPART(yy, GETDATE()) * 10000 +
                                DATEPART(mm, GETDATE()) * 100 +
                                DATEPART(dd, GETDATE())
  IF (@active_end_date = 0)
    SELECT @active_end_date = 99991231  -- December 31st 9999
  IF (@active_start_time = 0)
    SELECT @active_start_time = 000000  -- 12:00:00 am
  IF (@active_end_time = 0)
    SELECT @active_end_time = 235959    -- 11:59:59 pm

  -- Verify active start/end dates
  IF (@active_end_date = 0)
    SELECT @active_end_date = 99991231

  EXECUTE @return_code = sp_verify_job_date @active_end_date, '@active_end_date'
  IF (@return_code <> 0)
    RETURN(1) -- Failure

  EXECUTE @return_code = sp_verify_job_date @active_start_date, '@active_start_date'
  IF (@return_code <> 0)
    RETURN(1) -- Failure

  IF (@active_end_date < @active_start_date)
  BEGIN
    RAISERROR(14288, -1, -1, '@active_end_date', '@active_start_date')
    RETURN(1) -- Failure
  END

  -- Verify active start/end times
  IF (@active_end_time = 0)
    SELECT @active_end_time = 235959

  EXECUTE @return_code = sp_verify_job_time @active_end_time, '@active_end_time'
  IF (@return_code <> 0)
    RETURN(1) -- Failure

  EXECUTE @return_code = sp_verify_job_time @active_start_time, '@active_start_time'
  IF (@return_code <> 0)
    RETURN(1) -- Failure

  -- NOTE: It's valid for active_end_time to be less than active_start_time since in this
  --       case we assume that the user wants the active time zone to span midnight.
  --       But it's not valid for active_start_date and active_end_date to be the same...
  IF (@active_start_time = @active_end_time)
  BEGIN
    SELECT @res_valid_range = FORMATMESSAGE(14202)
    RAISERROR(14266, -1, -1, '@active_end_time', @res_valid_range)
    RETURN(1) -- Failure
  END

  -- NOTE: The rest of this procedure is a SQL implementation of VerifySchedule in job.c

  IF ((@freq_type = 0x1) OR  -- FREQTYPE_ONETIME
      (@freq_type = 0x40) OR -- FREQTYPE_AUTOSTART
      (@freq_type = 0x80))   -- FREQTYPE_ONIDLE
  BEGIN
    -- Set standard defaults for non-required parameters
    SELECT @freq_interval          = 0
    SELECT @freq_subday_type       = 0
    SELECT @freq_subday_interval   = 0
    SELECT @freq_relative_interval = 0
    SELECT @freq_recurrence_factor = 0
/*
    -- Check that a one-time schedule isn't already in the past
    IF (@freq_type = 0x1) -- FREQTYPE_ONETIME
    BEGIN
      DECLARE @current_date INT
      DECLARE @current_time INT

      SELECT @current_date = CONVERT(INT, CONVERT(VARCHAR, GETDATE(), 112))
      SELECT @current_time = (DATEPART(hh, GETDATE()) * 10000) + (DATEPART(mi, GETDATE()) * 100) + DATEPART(ss, GETDATE())
      IF (@active_start_date < @current_date) OR ((@active_start_date = @current_date) AND (@active_start_time <= @current_time))
      BEGIN
        SELECT @res_valid_range = '> ' + CONVERT(VARCHAR, @current_date) + ' / ' + CONVERT(VARCHAR, @current_time)
        RAISERROR(14266, -1, -1, '@active_start_date'' / ''@active_start_time', @res_valid_range)
        RETURN(1) -- Failure
      END
    END
*/
    GOTO CheckForDuplicate
  END

  -- Safety net: If the sub-day-type is 0 (and we know that the schedule is not a one-time or
  --             auto-start) then set it to 1 (FREQSUBTYPE_ONCE).  If the user wanted something
  --             other than ONCE then they should have explicitly set @freq_subday_type.
  IF (@freq_subday_type = 0)
    SELECT @freq_subday_type = 0x1 -- FREQSUBTYPE_ONCE

  IF ((@freq_subday_type <> 0x1) AND  -- FREQSUBTYPE_ONCE   (see qsched.h)
      (@freq_subday_type <> 0x2) AND  -- FREQSUBTYPE_SECOND (see qsched.h)
      (@freq_subday_type <> 0x4) AND  -- FREQSUBTYPE_MINUTE (see qsched.h)
      (@freq_subday_type <> 0x8))     -- FREQSUBTYPE_HOUR   (see qsched.h)
  BEGIN
    SELECT @reason = FORMATMESSAGE(14266, '@freq_subday_type', '0x1, 0x2, 0x4, 0x8')
    RAISERROR(14278, -1, -1, @reason)
    RETURN(1) -- Failure
  END
  IF ((@freq_subday_type <> 0x1) AND (@freq_subday_interval < 1))
     OR
     ((@freq_subday_type = 0x2) AND (@freq_subday_interval < 10))
  BEGIN
    SELECT @reason = FORMATMESSAGE(14200, '@freq_subday_interval')
    RAISERROR(14278, -1, -1, @reason)
    RETURN(1) -- Failure
  END

  IF (@freq_type = 0x4)      -- FREQTYPE_DAILY
  BEGIN
    SELECT @freq_recurrence_factor = 0
    IF (@freq_interval < 1)
    BEGIN
      SELECT @reason = FORMATMESSAGE(14572)
      RAISERROR(14278, -1, -1, @reason)
      RETURN(1) -- Failure
    END
  END

  IF (@freq_type = 0x8)      -- FREQTYPE_WEEKLY
  BEGIN
    IF (@freq_interval < 1)   OR
       (@freq_interval > 127) -- (2^7)-1 [freq_interval is a bitmap (Sun=1..Sat=64)]
    BEGIN
      SELECT @reason = FORMATMESSAGE(14573)
      RAISERROR(14278, -1, -1, @reason)
      RETURN(1) -- Failure
    END
  END

  IF (@freq_type = 0x10)    -- FREQTYPE_MONTHLY
  BEGIN
    IF (@freq_interval < 1)  OR
       (@freq_interval > 31)
    BEGIN
      SELECT @reason = FORMATMESSAGE(14574)
      RAISERROR(14278, -1, -1, @reason)
      RETURN(1) -- Failure
    END
  END

  IF (@freq_type = 0x20)     -- FREQTYPE_MONTHLYRELATIVE
  BEGIN
    IF (@freq_relative_interval <> 0x01) AND  -- RELINT_1ST
       (@freq_relative_interval <> 0x02) AND  -- RELINT_2ND
       (@freq_relative_interval <> 0x04) AND  -- RELINT_3RD
       (@freq_relative_interval <> 0x08) AND  -- RELINT_4TH
       (@freq_relative_interval <> 0x10)      -- RELINT_LAST
    BEGIN
      SELECT @reason = FORMATMESSAGE(14575)
      RAISERROR(14278, -1, -1, @reason)
      RETURN(1) -- Failure
    END
  END

  IF (@freq_type = 0x20)     -- FREQTYPE_MONTHLYRELATIVE
  BEGIN
    IF (@freq_interval <> 01) AND -- RELATIVE_SUN
       (@freq_interval <> 02) AND -- RELATIVE_MON
       (@freq_interval <> 03) AND -- RELATIVE_TUE
       (@freq_interval <> 04) AND -- RELATIVE_WED
       (@freq_interval <> 05) AND -- RELATIVE_THU
       (@freq_interval <> 06) AND -- RELATIVE_FRI
       (@freq_interval <> 07) AND -- RELATIVE_SAT
       (@freq_interval <> 08) AND -- RELATIVE_DAY
       (@freq_interval <> 09) AND -- RELATIVE_WEEKDAY
       (@freq_interval <> 10)     -- RELATIVE_WEEKENDDAY
    BEGIN
      SELECT @reason = FORMATMESSAGE(14576)
      RAISERROR(14278, -1, -1, @reason)
      RETURN(1) -- Failure
    END
  END

  IF ((@freq_type = 0x08)  OR   -- FREQTYPE_WEEKLY
      (@freq_type = 0x10)  OR   -- FREQTYPE_MONTHLY
      (@freq_type = 0x20)) AND  -- FREQTYPE_MONTHLYRELATIVE
      (@freq_recurrence_factor < 1)
  BEGIN
    SELECT @reason = FORMATMESSAGE(14577)
    RAISERROR(14278, -1, -1, @reason)
    RETURN(1) -- Failure
  END

CheckForDuplicate:

  -- Check that the schedule is not a duplicate
  SELECT @duplicate_schedule_id = NULL
  SELECT @duplicate_schedule_id = schedule_id,
         @duplicate_schedule_name = name
  FROM msdb.dbo.sysjobschedules
  WHERE (job_id                 = @job_id)
    AND (freq_type              = @freq_type)
    AND (freq_interval          = @freq_interval)
    AND (freq_subday_type       = @freq_subday_type)
    AND (freq_subday_interval   = @freq_subday_interval)
    AND (freq_relative_interval = @freq_relative_interval)
    AND (freq_recurrence_factor = @freq_recurrence_factor)
    AND (active_start_date      = @active_start_date)
    AND (active_start_time      = @active_start_time)
  IF ((@duplicate_schedule_id IS NOT NULL) AND (@duplicate_schedule_id <> @schedule_id))
  BEGIN
    RAISERROR(14259, -1, -1, @duplicate_schedule_id, @duplicate_schedule_name)
    RETURN(1) -- Failure
  END

  -- If we made it this far the schedule is good
  RETURN(0) -- Success

END
go

/**************************************************************/
/* SP_ADD_JOBSCHEDULE                                         */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_add_jobschedule...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_add_jobschedule')
              AND (type = 'P')))
  DROP PROCEDURE sp_add_jobschedule
go
CREATE PROCEDURE sp_add_jobschedule
  @job_id                 UNIQUEIDENTIFIER = NULL,
  @job_name               sysname          = NULL,
  @name                   sysname,
  @enabled                TINYINT          = 1,
  @freq_type              INT              = 0,
  @freq_interval          INT              = 0,
  @freq_subday_type       INT              = 0,
  @freq_subday_interval   INT              = 0,
  @freq_relative_interval INT              = 0,
  @freq_recurrence_factor INT              = 0,
  @active_start_date      INT              = NULL,     -- sp_verify_jobschedule assigns a default
  @active_end_date        INT              = 99991231, -- December 31st 9999
  @active_start_time      INT              = 000000,   -- 12:00:00 am
  @active_end_time        INT              = 235959    -- 11:59:59 pm
AS
BEGIN
  DECLARE @retval      INT
  DECLARE @schedule_id INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @name = LTRIM(RTRIM(@name))

  SELECT @schedule_id = 0

  -- Check authority (only SQLServerAgent can add a schedule to a non-local job)
  EXECUTE @retval = sp_verify_jobproc_caller @job_id = @job_id, @program_name = N'SQLAgent%'
  IF (@retval <> 0)
    RETURN(@retval)

  -- Check that we can uniquely identify the job
  EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                              '@job_id',
                                               @job_name OUTPUT,
                                               @job_id   OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check that the schedule name doesn't already exist
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobschedules
              WHERE (job_id = @job_id)
                AND (name = @name)))
  BEGIN
    RAISERROR(14261, -1, -1, '@name', @name)
    RETURN(1) -- Failure
  END

  -- Check schedule (frequency) parameters
  EXECUTE @retval = sp_verify_jobschedule @name,
                                          @enabled,
                                          @freq_type,
                                          @freq_interval          OUTPUT,
                                          @freq_subday_type       OUTPUT,
                                          @freq_subday_interval   OUTPUT,
                                          @freq_relative_interval OUTPUT,
                                          @freq_recurrence_factor OUTPUT,
                                          @active_start_date      OUTPUT,
                                          @active_start_time      OUTPUT,
                                          @active_end_date        OUTPUT,
                                          @active_end_time        OUTPUT,
                                          @job_id,
                                          NULL
  IF (@retval <> 0)
    RETURN(1) -- Failure

  INSERT INTO msdb.dbo.sysjobschedules
         (job_id,
          name,
          enabled,
          freq_type,
          freq_interval,
          freq_subday_type,
          freq_subday_interval,
          freq_relative_interval,
          freq_recurrence_factor,
          active_start_date,
          active_end_date,
          active_start_time,
          active_end_time,
          next_run_date,
          next_run_time)
  VALUES (@job_id,
          @name,
          @enabled,
          @freq_type,
          @freq_interval,
          @freq_subday_type,
          @freq_subday_interval,
          @freq_relative_interval,
          @freq_recurrence_factor,
          @active_start_date,
          @active_end_date,
          @active_start_time,
          @active_end_time,
          0,
          0)

  SELECT @retval = @@error

  -- Update the job's version/last-modified information
  UPDATE msdb.dbo.sysjobs
  SET version_number = version_number + 1,
      date_modified = GETDATE()
  WHERE (job_id = @job_id)

  SELECT @schedule_id = schedule_id
  FROM msdb.dbo.sysjobschedules
  WHERE (job_id = @job_id)
    AND (name = @name)

  -- Notify SQLServerAgent of the change, but only if we know the job has been cached
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobservers
              WHERE (job_id = @job_id)
                AND (server_id = 0)))
  BEGIN
    EXECUTE msdb.dbo.sp_sqlagent_notify @op_type     = N'S',
                                        @job_id      = @job_id,
                                        @schedule_id = @schedule_id,
                                        @action_type = N'I'
  END

  -- For a multi-server job, remind the user that they need to call sp_post_msx_operation
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobservers
              WHERE (job_id = @job_id)
                AND (server_id <> 0)))
    RAISERROR(14547, 0, 1, N'INSERT', N'sp_post_msx_operation')

  RETURN(@retval) -- 0 means success
END
go

/**************************************************************/
/* SP_UPDATE_REPLICATION_JOB_PARAMETER                        */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_update_replication_job_parameter...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = 'sp_update_replication_job_parameter')
              AND (type = 'P')))
  DROP PROCEDURE sp_update_replication_job_parameter
go
CREATE PROCEDURE sp_update_replication_job_parameter
  @job_id        UNIQUEIDENTIFIER,
  @old_freq_type INT,
  @new_freq_type INT
AS
BEGIN
  DECLARE @category_id INT
  DECLARE @pattern     NVARCHAR(50)
  DECLARE @patternidx  INT
  DECLARE @cmdline     NVARCHAR(3200)
  DECLARE @step_id     INT

  SET NOCOUNT ON
  SELECT @pattern = N'%[-/][Cc][Oo][Nn][Tt][Ii][Nn][Uu][Oo][Uu][Ss]%'

  -- Make sure that we are dealing with relevant replication jobs
  SELECT @category_id = category_id
  FROM msdb.dbo.sysjobs
  WHERE (@job_id = job_id)

  -- @category_id = 10 (REPL-Distribution), 13 (REPL-LogReader), 14 (REPL-Merge),
  --  19 (REPL-QueueReader)
  IF @category_id IN (10, 13, 14, 19)
  BEGIN
    -- Adding the -Continuous parameter (non auto-start to auto-start)
    IF ((@old_freq_type <> 0x40) AND (@new_freq_type = 0x40))
    BEGIN
      -- Use a cursor to handle multiple replication agent job steps
      DECLARE step_cursor CURSOR LOCAL FOR
      SELECT command, step_id
      FROM msdb.dbo.sysjobsteps
      WHERE (@job_id = job_id)
        AND (UPPER(subsystem) IN (N'MERGE', N'LOGREADER', N'DISTRIBUTION', N'QUEUEREADER'))
      OPEN step_cursor
      FETCH step_cursor INTO @cmdline, @step_id

      WHILE (@@FETCH_STATUS <> -1)
      BEGIN
        SELECT @patternidx = PATINDEX(@pattern, @cmdline)
        -- Make sure that the -Continuous parameter has not been specified already
        IF (@patternidx = 0)
        BEGIN
          SELECT @cmdline = @cmdline + N' -Continuous'
          UPDATE msdb.dbo.sysjobsteps
          SET command = @cmdline
          WHERE (@job_id = job_id)
            AND (@step_id = step_id)
        END -- IF (@patternidx = 0)
        FETCH NEXT FROM step_cursor into @cmdline, @step_id
      END -- WHILE (@@FETCH_STATUS <> -1)
      CLOSE step_cursor
      DEALLOCATE step_cursor
    END -- IF ((@old_freq_type...
    -- Removing the -Continuous parameter (auto-start to non auto-start)
    ELSE
    IF ((@old_freq_type = 0x40) AND (@new_freq_type <> 0x40))
    BEGIN
      DECLARE step_cursor CURSOR LOCAL FOR
      SELECT command, step_id
      FROM msdb.dbo.sysjobsteps
      WHERE (@job_id = job_id)
        AND (UPPER(subsystem) IN (N'MERGE', N'LOGREADER', N'DISTRIBUTION', N'QUEUEREADER'))
      OPEN step_cursor
      FETCH step_cursor INTO @cmdline, @step_id

      WHILE (@@FETCH_STATUS <> -1)
      BEGIN
        SELECT @patternidx = PATINDEX(@pattern, @cmdline)
        IF (@patternidx <> 0)
        BEGIN
          -- Handle multiple instances of -Continuous in the commandline
          WHILE (@patternidx <> 0)
          BEGIN
            SELECT @cmdline = STUFF(@cmdline, @patternidx, 11, N'')
            IF (@patternidx > 1)
            BEGIN
              -- Remove the preceding space if -Continuous does not start at the beginning of the commandline
              SELECT @cmdline = stuff(@cmdline, @patternidx - 1, 1, N'')
            END
            SELECT @patternidx = PATINDEX(@pattern, @cmdline)
          END -- WHILE (@patternidx <> 0)
          UPDATE msdb.dbo.sysjobsteps
          SET command = @cmdline
          WHERE (@job_id = job_id)
            AND (@step_id = step_id)
        END -- IF (@patternidx <> -1)
        FETCH NEXT FROM step_cursor INTO @cmdline, @step_id
      END -- WHILE (@@FETCH_STATUS <> -1)
      CLOSE step_cursor
      DEALLOCATE step_cursor
    END -- ELSE IF ((@old_freq_type = 0x40)...
  END -- IF @category_id IN (10, 13, 14)

  RETURN 0
END
go

/**************************************************************/
/* SP_UPDATE_JOBSCHEDULE                                      */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_update_jobschedule...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_update_jobschedule')
              AND (type = 'P')))
  DROP PROCEDURE sp_update_jobschedule
go
CREATE PROCEDURE sp_update_jobschedule
  @job_id                 UNIQUEIDENTIFIER = NULL,
  @job_name               sysname          = NULL,
  @name                   sysname,
  @new_name               sysname          = NULL,
  @enabled                TINYINT          = NULL,
  @freq_type              INT              = NULL,
  @freq_interval          INT              = NULL,
  @freq_subday_type       INT              = NULL,
  @freq_subday_interval   INT              = NULL,
  @freq_relative_interval INT              = NULL,
  @freq_recurrence_factor INT              = NULL,
  @active_start_date      INT              = NULL,
  @active_end_date        INT              = NULL,
  @active_start_time      INT              = NULL,
  @active_end_time        INT              = NULL
AS
BEGIN
  DECLARE @retval                   INT
  DECLARE @schedule_id              INT
  DECLARE @x_name                   sysname
  DECLARE @x_enabled                TINYINT
  DECLARE @x_freq_type              INT
  DECLARE @x_freq_interval          INT
  DECLARE @x_freq_subday_type       INT
  DECLARE @x_freq_subday_interval   INT
  DECLARE @x_freq_relative_interval INT
  DECLARE @x_freq_recurrence_factor INT
  DECLARE @x_active_start_date      INT
  DECLARE @x_active_end_date        INT
  DECLARE @x_active_start_time      INT
  DECLARE @x_active_end_time        INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @name     = LTRIM(RTRIM(@name))
  SELECT @new_name = LTRIM(RTRIM(@new_name))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@new_name = N'') SELECT @new_name = NULL

  -- Check authority (only SQLServerAgent can modify a schedule of a non-local job)
  EXECUTE @retval = sp_verify_jobproc_caller @job_id = @job_id, @program_name = 'SQLAgent%'
  IF (@retval <> 0)
    RETURN(@retval)

  -- Check that we can uniquely identify the job
  EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                              '@job_id',
                                               @job_name OUTPUT,
                                               @job_id   OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check that the schedule exists
  SELECT @schedule_id = schedule_id
  FROM msdb.dbo.sysjobschedules
  WHERE (job_id = @job_id)
    AND (name = @name)
  IF (@schedule_id IS NULL)
  BEGIN
    RAISERROR(14262, -1, -1, 'Schedule Name', @name)
    RETURN(1) -- Failure
  END

  -- Set the x_ (existing) variables
  SELECT @x_name                   = name,
         @x_enabled                = enabled,
         @x_freq_type              = freq_type,
         @x_freq_interval          = freq_interval,
         @x_freq_subday_type       = freq_subday_type,
         @x_freq_subday_interval   = freq_subday_interval,
         @x_freq_relative_interval = freq_relative_interval,
         @x_freq_recurrence_factor = freq_recurrence_factor,
         @x_active_start_date      = active_start_date,
         @x_active_end_date        = active_end_date,
         @x_active_start_time      = active_start_time,
         @x_active_end_time        = active_end_time
  FROM msdb.dbo.sysjobschedules
  WHERE (job_id = @job_id)
    AND (name = @name)

  -- Check that the new name (if any) doesn't already exist for this job
  IF (@new_name IS NOT NULL)
  BEGIN
    IF (EXISTS (SELECT *
                FROM msdb.dbo.sysjobschedules
                WHERE (job_id = @job_id)
                  AND (name = @new_name)
                  AND (@name <> @new_name)))
    BEGIN
      RAISERROR(14261, -1, -1, '@new_name', @new_name)
      RETURN(1) -- Failure
    END
  END

  -- Fill out the values for all non-supplied parameters from the existing values
  IF (@new_name               IS NULL) SELECT @new_name               = @x_name
  IF (@enabled                IS NULL) SELECT @enabled                = @x_enabled
  IF (@freq_type              IS NULL) SELECT @freq_type              = @x_freq_type
  IF (@freq_interval          IS NULL) SELECT @freq_interval          = @x_freq_interval
  IF (@freq_subday_type       IS NULL) SELECT @freq_subday_type       = @x_freq_subday_type
  IF (@freq_subday_interval   IS NULL) SELECT @freq_subday_interval   = @x_freq_subday_interval
  IF (@freq_relative_interval IS NULL) SELECT @freq_relative_interval = @x_freq_relative_interval
  IF (@freq_recurrence_factor IS NULL) SELECT @freq_recurrence_factor = @x_freq_recurrence_factor
  IF (@active_start_date      IS NULL) SELECT @active_start_date      = @x_active_start_date
  IF (@active_end_date        IS NULL) SELECT @active_end_date        = @x_active_end_date
  IF (@active_start_time      IS NULL) SELECT @active_start_time      = @x_active_start_time
  IF (@active_end_time        IS NULL) SELECT @active_end_time        = @x_active_end_time

  -- Check schedule (frequency) parameters
  EXECUTE @retval = sp_verify_jobschedule @new_name,
                                          @enabled,
                                          @freq_type,
                                          @freq_interval          OUTPUT,
                                          @freq_subday_type       OUTPUT,
                                          @freq_subday_interval   OUTPUT,
                                          @freq_relative_interval OUTPUT,
                                          @freq_recurrence_factor OUTPUT,
                                          @active_start_date      OUTPUT,
                                          @active_start_time      OUTPUT,
                                          @active_end_date        OUTPUT,
                                          @active_end_time        OUTPUT,
                                          @job_id,
                                          @schedule_id
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Update the JobSchedule
  UPDATE msdb.dbo.sysjobschedules
  SET name                   = @new_name,
      enabled                = @enabled,
      freq_type              = @freq_type,
      freq_interval          = @freq_interval,
      freq_subday_type       = @freq_subday_type,
      freq_subday_interval   = @freq_subday_interval,
      freq_relative_interval = @freq_relative_interval,
      freq_recurrence_factor = @freq_recurrence_factor,
      active_start_date      = @active_start_date,
      active_end_date        = @active_end_date,
      active_start_time      = @active_start_time,
      active_end_time        = @active_end_time,
      next_run_date          = 0, -- Since SQLServerAgent needs to recalculate it
      next_run_time          = 0  -- Since SQLServerAgent needs to recalculate it
  WHERE (job_id = @job_id)
    AND (name = @name)

  SELECT @retval = @@error

  -- Update the job's version/last-modified information
  UPDATE msdb.dbo.sysjobs
  SET version_number = version_number + 1,
      date_modified = GETDATE()
  WHERE (job_id = @job_id)

  -- Notify SQLServerAgent of the change, but only if we know the job has been cached
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobservers
              WHERE (job_id = @job_id)
                AND (server_id = 0)))
  BEGIN
    EXECUTE msdb.dbo.sp_sqlagent_notify @op_type     = N'S',
                                        @job_id      = @job_id,
                                        @schedule_id = @schedule_id,
                                        @action_type = N'U'
  END

  -- For a multi-server job, remind the user that they need to call sp_post_msx_operation
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobservers
              WHERE (job_id = @job_id)
                AND (server_id <> 0)))
    RAISERROR(14547, 0, 1, N'INSERT', N'sp_post_msx_operation')

  -- Automatic addition and removal of -Continous parameter for replication agent
  EXECUTE sp_update_replication_job_parameter @job_id = @job_id,
                                              @old_freq_type = @x_freq_type,
                                              @new_freq_type = @freq_type

  RETURN(@retval) -- 0 means success
END
go

/**************************************************************/
/* SP_DELETE_JOBSCHEDULE                                      */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_delete_jobschedule...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = 'sp_delete_jobschedule')
              AND (type = 'P')))
  DROP PROCEDURE sp_delete_jobschedule
go
CREATE PROCEDURE sp_delete_jobschedule
  @job_id   UNIQUEIDENTIFIER = NULL,
  @job_name sysname          = NULL,
  @name     sysname
AS
BEGIN
  DECLARE @retval      INT
  DECLARE @schedule_id INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @name = LTRIM(RTRIM(@name))

  -- Check authority (only SQLServerAgent can delete a schedule of a non-local job)
  EXECUTE @retval = sp_verify_jobproc_caller @job_id = @job_id, @program_name = N'SQLAgent%'
  IF (@retval <> 0)
    RETURN(@retval)

  -- Check that we can uniquely identify the job
  EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                              '@job_id',
                                               @job_name OUTPUT,
                                               @job_id   OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  IF (UPPER(@name) = N'ALL')
  BEGIN
    SELECT @schedule_id = -1  -- We use this in the call to sp_sqlagent_notify

    DELETE FROM msdb.dbo.sysjobschedules
    WHERE (job_id = @job_id)
  END
  ELSE
  BEGIN
    -- Check that the schedule exists
    SELECT @schedule_id = schedule_id
    FROM msdb.dbo.sysjobschedules
    WHERE (job_id = @job_id)
      AND (name = @name)
    IF (@schedule_id IS NULL)
    BEGIN
      RAISERROR(14262, -1, -1, '@name', @name)
      RETURN(1) -- Failure
    END

    DELETE FROM msdb.dbo.sysjobschedules
    WHERE (job_id = @job_id)
      AND (schedule_id = @schedule_id)
  END

  SELECT @retval = @@error

  -- Update the job's version/last-modified information
  UPDATE msdb.dbo.sysjobs
  SET version_number = version_number + 1,
      date_modified = GETDATE()
  WHERE (job_id = @job_id)

  -- Notify SQLServerAgent of the change, but only if we know the job has been cached
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobservers
              WHERE (job_id = @job_id)
                AND (server_id = 0)))
  BEGIN
    EXECUTE msdb.dbo.sp_sqlagent_notify @op_type     = N'S',
                                        @job_id      = @job_id,
                                        @schedule_id = @schedule_id,
                                        @action_type = N'D'
  END

  -- For a multi-server job, remind the user that they need to call sp_post_msx_operation
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobservers
              WHERE (job_id = @job_id)
                AND (server_id <> 0)))
    RAISERROR(14547, 0, 1, N'INSERT', N'sp_post_msx_operation')

  RETURN(@retval) -- 0 means success
END
go

/**************************************************************/
/* SP_HELP_JOBSCHEDULE                                        */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_help_jobschedule...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_help_jobschedule')
              AND (type = 'P')))
  DROP PROCEDURE sp_help_jobschedule
go
CREATE PROCEDURE sp_help_jobschedule
  @job_id              UNIQUEIDENTIFIER = NULL,
  @job_name            sysname          = NULL,
  @schedule_name       sysname          = NULL,
  @schedule_id         INT              = NULL,
  @include_description BIT              = 0 -- 1 if a schedule description is required (NOTE: It's expensive to generate the description)
AS
BEGIN
  DECLARE @retval                 INT
  DECLARE @schedule_description   NVARCHAR(255)
  DECLARE @name                   sysname
  DECLARE @freq_type              INT
  DECLARE @freq_interval          INT
  DECLARE @freq_subday_type       INT
  DECLARE @freq_subday_interval   INT
  DECLARE @freq_relative_interval INT
  DECLARE @freq_recurrence_factor INT
  DECLARE @active_start_date      INT
  DECLARE @active_end_date        INT
  DECLARE @active_start_time      INT
  DECLARE @active_end_time        INT
  DECLARE @schedule_id_as_char    VARCHAR(10)

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @schedule_name = LTRIM(RTRIM(@schedule_name))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@schedule_name = N'') SELECT @schedule_name = NULL

  -- The user must provide either:
  -- 1) job_id (or job_name) and (optionally) a schedule name
  -- or...
  -- 2) just schedule_id
  IF (@schedule_id IS NULL) AND
     (@job_id      IS NULL) AND
     (@job_name    IS NULL)
  BEGIN
    RAISERROR(14273, -1, -1)
    RETURN(1) -- Failure
  END

  IF (@schedule_id IS NOT NULL) AND ((@job_id        IS NOT NULL) OR
                                     (@job_name      IS NOT NULL) OR
                                     (@schedule_name IS NOT NULL))
  BEGIN
    RAISERROR(14273, -1, -1)
    RETURN(1) -- Failure
  END

  -- Check that the schedule (by ID) exists
  IF (@schedule_id IS NOT NULL)
  BEGIN
    SELECT @job_id = job_id
    FROM msdb.dbo.sysjobschedules
    WHERE (schedule_id = @schedule_id)
    IF (@job_id IS NULL)
    BEGIN
      SELECT @schedule_id_as_char = CONVERT(VARCHAR, @schedule_id)
      RAISERROR(14262, -1, -1, '@schedule_id', @schedule_id_as_char)
      RETURN(1) -- Failure
    END
  END

  -- Check that we can uniquely identify the job
  IF (@job_id IS NOT NULL) OR (@job_name IS NOT NULL)
  BEGIN
    EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                                '@job_id',
                                                 @job_name OUTPUT,
                                                 @job_id   OUTPUT,
                                                'NO_TEST'
    IF (@retval <> 0)
      RETURN(1) -- Failure
  END

  -- Check that the schedule (by name) exists
  IF (@schedule_name IS NOT NULL)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysjobschedules
                    WHERE (job_id = @job_id)
                      AND (name = @schedule_name)))
    BEGIN
      RAISERROR(14262, -1, -1, '@schedule_name', @schedule_name)
      RETURN(1) -- Failure
    END
  END

  -- Get the schedule(s) into a temporary table
  SELECT schedule_id,
        'schedule_name' = name,
         enabled,
         freq_type,
         freq_interval,
         freq_subday_type,
         freq_subday_interval,
         freq_relative_interval,
         freq_recurrence_factor,
         active_start_date,
         active_end_date,
         active_start_time,
         active_end_time,
         date_created,
        'schedule_description' = FORMATMESSAGE(14549),
         next_run_date,
         next_run_time
  INTO #temp_jobschedule
  FROM msdb.dbo.sysjobschedules
  WHERE ((@job_id IS NULL) OR (job_id = @job_id))
    AND ((@schedule_name IS NULL) OR (name = @schedule_name))
    AND ((@schedule_id IS NULL) OR (schedule_id = @schedule_id))

  IF (@include_description = 1)
  BEGIN
    -- For each schedule, generate the textual schedule description and update the temporary
    -- table with it
    IF (EXISTS (SELECT *
                FROM #temp_jobschedule))
    BEGIN
      WHILE (EXISTS (SELECT *
                     FROM #temp_jobschedule
                     WHERE schedule_description = FORMATMESSAGE(14549)))
      BEGIN
        SET ROWCOUNT 1
        SELECT @name                   = schedule_name,
               @freq_type              = freq_type,
               @freq_interval          = freq_interval,
               @freq_subday_type       = freq_subday_type,
               @freq_subday_interval   = freq_subday_interval,
               @freq_relative_interval = freq_relative_interval,
               @freq_recurrence_factor = freq_recurrence_factor,
               @active_start_date      = active_start_date,
               @active_end_date        = active_end_date,
               @active_start_time      = active_start_time,
               @active_end_time        = active_end_time
        FROM #temp_jobschedule
        WHERE (schedule_description = FORMATMESSAGE(14549))
        SET ROWCOUNT 0

        EXECUTE sp_get_schedule_description
          @freq_type,
          @freq_interval,
          @freq_subday_type,
          @freq_subday_interval,
          @freq_relative_interval,
          @freq_recurrence_factor,
          @active_start_date,
          @active_end_date,
          @active_start_time,
          @active_end_time,
          @schedule_description OUTPUT

        UPDATE #temp_jobschedule
        SET schedule_description = ISNULL(LTRIM(RTRIM(@schedule_description)), FORMATMESSAGE(14205))
        WHERE (schedule_name = @name)
      END -- While
    END
  END

  -- Return the result set
  SELECT *
  FROM #temp_jobschedule
  ORDER BY schedule_id

  RETURN(@@error) -- 0 means success
END
go

DUMP TRANSACTION msdb WITH NO_LOG
go
CHECKPOINT
go

/**************************************************************/
/* SP_VERIFY_JOB                                              */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_verify_job...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_verify_job')
              AND (type = 'P')))
  DROP PROCEDURE sp_verify_job
go
CREATE PROCEDURE sp_verify_job
  @job_id                       UNIQUEIDENTIFIER,
  @name                         sysname,
  @enabled                      TINYINT,
  @start_step_id                INT,
  @category_name                sysname,
  @owner_sid                    VARBINARY(85) OUTPUT, -- Output since we may modify it
  @notify_level_eventlog        INT,
  @notify_level_email           INT           OUTPUT, -- Output since we may reset it to 0
  @notify_level_netsend         INT           OUTPUT, -- Output since we may reset it to 0
  @notify_level_page            INT           OUTPUT, -- Output since we may reset it to 0
  @notify_email_operator_name   sysname,
  @notify_netsend_operator_name sysname,
  @notify_page_operator_name    sysname,
  @delete_level                 INT,
  @category_id                  INT           OUTPUT, -- The ID corresponding to the name
  @notify_email_operator_id     INT           OUTPUT, -- The ID corresponding to the name
  @notify_netsend_operator_id   INT           OUTPUT, -- The ID corresponding to the name
  @notify_page_operator_id      INT           OUTPUT, -- The ID corresponding to the name
  @originating_server           NVARCHAR(30)  OUTPUT  -- Output since we may modify it
AS
BEGIN
  DECLARE @job_type           INT
  DECLARE @retval             INT
  DECLARE @current_date       INT
  DECLARE @local_machine_name NVARCHAR(30)
  DECLARE @res_valid_range    NVARCHAR(200)

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @name                       = LTRIM(RTRIM(@name))
  SELECT @category_name              = LTRIM(RTRIM(@category_name))
  SELECT @originating_server         = LTRIM(RTRIM(@originating_server))

  -- Make sure that input/output strings - if NULL - are initialized to NOT null
  EXECUTE @retval = master.dbo.xp_getnetname @local_machine_name OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure
  SELECT @originating_server = ISNULL(@originating_server, ISNULL(@local_machine_name, UPPER(CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName')))))

  -- Replace the local server name with local server name
  IF (UPPER(@originating_server) = UPPER(@local_machine_name))
    SELECT @originating_server = UPPER(CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName')))

  -- Check originating server (only the SQLServerAgent can add jobs that originate from a remote server)
  IF (UPPER(@originating_server) <> UPPER(CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName')))) AND
     (PROGRAM_NAME() NOT LIKE N'SQLAgent%')
  BEGIN
    RAISERROR(14275, -1, -1, @local_machine_name)
    RETURN(1) -- Failure
  END

  -- Make sure that the local server is always referred to as local server name (ie. lower-case)
  IF (UPPER(@originating_server) = UPPER(CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName'))))
    SELECT @originating_server = LOWER(@originating_server)

  -- NOTE: We allow jobs with the same name (since job_id is always unique) but only if
  --       they originate from different servers.  Thus jobs can flow from an MSX to a TSX
  --       without having to worry about naming conflicts.
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobs
              WHERE (name = @name)
                AND (originating_server = @originating_server)
                AND (job_id <> ISNULL(@job_id, 0x911)))) -- When adding a new job @job_id is NULL
  BEGIN
    RAISERROR(14261, -1, -1, '@name', @name)
    RETURN(1) -- Failure
  END

  -- Check enabled state
  IF (@enabled <> 0) AND (@enabled <> 1)
  BEGIN
    RAISERROR(14266, -1, -1, '@enabled', '0, 1')
    RETURN(1) -- Failure
  END

  -- Check start step
  IF (@job_id IS NULL)
  BEGIN
    -- New job
    -- NOTE: For [new] MSX jobs we allow the start step to be other than 1 since
    --       the start step was validated when the job was created at the MSX
    IF (@start_step_id <> 1) AND (UPPER(@originating_server) = UPPER(CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName'))))
    BEGIN
      RAISERROR(14266, -1, -1, '@start_step_id', '1')
      RETURN(1) -- Failure
    END
  END
  ELSE
  BEGIN
    -- Existing job
    DECLARE @max_step_id INT
    DECLARE @valid_range VARCHAR(50)

    -- Get current maximum step id
    SELECT @max_step_id = ISNULL(MAX(step_id), 0)
    FROM msdb.dbo.sysjobsteps
    WHERE (job_id = @job_id)

    IF (@start_step_id < 1) OR (@start_step_id > @max_step_id + 1)
    BEGIN
      SELECT @valid_range = '1..' + CONVERT(VARCHAR, @max_step_id + 1)
      RAISERROR(14266, -1, -1, '@start_step_id', @valid_range)
      RETURN(1) -- Failure
    END
  END

  -- Check category
  SELECT @job_type = NULL

  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobservers
              WHERE (job_id = @job_id)
                AND (server_id = 0)))
    SELECT @job_type = 1 -- LOCAL

  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobservers
              WHERE (job_id = @job_id)
                AND (server_id <> 0)))
    SELECT @job_type = 2 -- MULTI-SERVER

  -- A local job cannot be added to a multi-server job_category
  IF (@job_type = 1) AND (EXISTS (SELECT *
                                  FROM msdb.dbo.syscategories
                                  WHERE (category_class = 1) -- Job
                                    AND (category_type = 2) -- Multi-Server
                                    AND (name = @category_name)))
  BEGIN
    RAISERROR(14285, -1, -1)
    RETURN(1) -- Failure
  END

  -- A multi-server job cannot be added to a local job_category
  IF (@job_type = 2) AND (EXISTS (SELECT *
                                  FROM msdb.dbo.syscategories
                                  WHERE (category_class = 1) -- Job
                                    AND (category_type = 1) -- Local
                                    AND (name = @category_name)))
  BEGIN
    RAISERROR(14286, -1, -1)
    RETURN(1) -- Failure
  END

  -- Get the category_id, handling any special-cases as appropriate
  SELECT @category_id = NULL
  IF (@category_name = N'[DEFAULT]') -- User wants to revert to the default job category
  BEGIN
    SELECT @category_id = CASE ISNULL(@job_type, 1)
                            WHEN 1 THEN 0 -- [Uncategorized (Local)]
                            WHEN 2 THEN 2 -- [Uncategorized (Multi-Server)]
                          END
  END
  ELSE
  IF (@category_name IS NULL) -- The sp_add_job default
  BEGIN
    SELECT @category_id = 0
  END
  ELSE
  BEGIN
    SELECT @category_id = category_id
    FROM msdb.dbo.syscategories
    WHERE (category_class = 1) -- Job
      AND (name = @category_name)
  END

  IF (@category_id IS NULL)
  BEGIN
    RAISERROR(14234, -1, -1, '@category_name', 'sp_help_category')
    RETURN(1) -- Failure
  END

  -- Only SQLServerAgent may add jobs to the 'Jobs From MSX' category
  IF (@category_id = 1) AND
     (PROGRAM_NAME() NOT LIKE N'SQLAgent%')
  BEGIN
    RAISERROR(14267, -1, -1, @category_name)
    RETURN(1) -- Failure
  END

  -- Check owner
  -- If a non-sa is [illegally] trying to create a job for another user then default the owner
  -- to be the calling user.
  IF ((ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 0) AND (@owner_sid <> SUSER_SID()))
    SELECT @owner_sid = SUSER_SID()

  -- Now just check that the login id is valid (ie. it exists and isn't an NT group)
  IF ((UPPER(SUSER_SNAME(@owner_sid)) <> N'NT AUTHORITY\SYSTEM') AND
     (UPPER(SUSER_SNAME(@owner_sid)) <> N'NT AUTHORITY\NETWORK SERVICE')) 
  BEGIN
     IF (@owner_sid IS NULL) OR (EXISTS (SELECT *
                                      FROM master.dbo.syslogins
                                      WHERE (sid = @owner_sid)
                                        AND (isntgroup <> 0)))
     BEGIN
       -- NOTE: In the following message we quote @owner_login_name instead of @owner_sid
       --       since this is the parameter the user passed to the calling SP (ie. either
       --       sp_add_job or sp_update_job)
       SELECT @res_valid_range = FORMATMESSAGE(14203)
       RAISERROR(14234, -1, -1, '@owner_login_name', @res_valid_range)
       RETURN(1) -- Failure
     END
  END

  -- Check notification levels (must be 0, 1, 2 or 3)
  IF (@notify_level_eventlog & 0x3 <> @notify_level_eventlog)
  BEGIN
    RAISERROR(14266, -1, -1, '@notify_level_eventlog', '0, 1, 2, 3')
    RETURN(1) -- Failure
  END
  IF (@notify_level_email & 0x3 <> @notify_level_email)
  BEGIN
    RAISERROR(14266, -1, -1, '@notify_level_email', '0, 1, 2, 3')
    RETURN(1) -- Failure
  END
  IF (@notify_level_netsend & 0x3 <> @notify_level_netsend)
  BEGIN
    RAISERROR(14266, -1, -1, '@notify_level_netsend', '0, 1, 2, 3')
    RETURN(1) -- Failure
  END
  IF (@notify_level_page & 0x3 <> @notify_level_page)
  BEGIN
    RAISERROR(14266, -1, -1, '@notify_level_page', '0, 1, 2, 3')
    RETURN(1) -- Failure
  END

  -- If we're at a TSX, only SQLServerAgent may add jobs that notify 'MSXOperator'
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.systargetservers)) AND
     ((@notify_email_operator_name = N'MSXOperator') OR
      (@notify_page_operator_name = N'MSXOperator') OR
      (@notify_netsend_operator_name = N'MSXOperator')) AND
     (PROGRAM_NAME() NOT LIKE N'SQLAgent%')
  BEGIN
    RAISERROR(14251, -1, -1, 'MSXOperator')
    RETURN(1) -- Failure
  END

  -- Check operator to notify (via email)
  IF (@notify_email_operator_name IS NOT NULL)
  BEGIN
    SELECT @notify_email_operator_id = id
    FROM msdb.dbo.sysoperators
    WHERE (name = @notify_email_operator_name)

    IF (@notify_email_operator_id IS NULL)
    BEGIN
      RAISERROR(14234, -1, -1, '@notify_email_operator_name', 'sp_help_operator')
      RETURN(1) -- Failure
    END
    -- If a valid operator is specified the level must be non-zero
    IF (@notify_level_email = 0)
    BEGIN
      RAISERROR(14266, -1, -1, '@notify_level_email', '1, 2, 3')
      RETURN(1) -- Failure
    END
  END
  ELSE
  BEGIN
    SELECT @notify_email_operator_id = 0
    SELECT @notify_level_email = 0
  END

  -- Check operator to notify (via netsend)
  IF (@notify_netsend_operator_name IS NOT NULL)
  BEGIN
    SELECT @notify_netsend_operator_id = id
    FROM msdb.dbo.sysoperators
    WHERE (name = @notify_netsend_operator_name)

    IF (@notify_netsend_operator_id IS NULL)
    BEGIN
      RAISERROR(14234, -1, -1, '@notify_netsend_operator_name', 'sp_help_operator')
      RETURN(1) -- Failure
    END
    -- If a valid operator is specified the level must be non-zero
    IF (@notify_level_netsend = 0)
    BEGIN
      RAISERROR(14266, -1, -1, '@notify_level_netsend', '1, 2, 3')
      RETURN(1) -- Failure
    END
  END
  ELSE
  BEGIN
    SELECT @notify_netsend_operator_id = 0
    SELECT @notify_level_netsend = 0
  END

  -- Check operator to notify (via page)
  IF (@notify_page_operator_name IS NOT NULL)
  BEGIN
    SELECT @notify_page_operator_id = id
    FROM msdb.dbo.sysoperators
    WHERE (name = @notify_page_operator_name)

    IF (@notify_page_operator_id IS NULL)
    BEGIN
      RAISERROR(14234, -1, -1, '@notify_page_operator_name', 'sp_help_operator')
      RETURN(1) -- Failure
    END
    -- If a valid operator is specified the level must be non-zero
    IF (@notify_level_page = 0)
    BEGIN
      RAISERROR(14266, -1, -1, '@notify_level_page', '1, 2, 3')
      RETURN(1) -- Failure
    END
  END
  ELSE
  BEGIN
    SELECT @notify_page_operator_id = 0
    SELECT @notify_level_page = 0
  END

  -- Check delete level (must be 0, 1, 2 or 3)
  IF (@delete_level & 0x3 <> @delete_level)
  BEGIN
    RAISERROR(14266, -1, -1, '@delete_level', '0, 1, 2, 3')
    RETURN(1) -- Failure
  END

  RETURN(0) -- Success
END
go

/**************************************************************/
/* SP_ADD_JOB                                                 */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_add_job...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_add_job')
              AND (type = 'P')))
  DROP PROCEDURE sp_add_job
go
CREATE PROCEDURE sp_add_job
  @job_name                     sysname,
  @enabled                      TINYINT          = 1,        -- 0 = Disabled, 1 = Enabled
  @description                  NVARCHAR(512)    = NULL,
  @start_step_id                INT              = 1,
  @category_name                sysname          = NULL,
  @category_id                  INT              = NULL,     -- A language-independent way to specify which category to use
  @owner_login_name             sysname          = NULL,     -- The procedure assigns a default
  @notify_level_eventlog        INT              = 2,        -- 0 = Never, 1 = On Success, 2 = On Failure, 3 = Always
  @notify_level_email           INT              = 0,        -- 0 = Never, 1 = On Success, 2 = On Failure, 3 = Always
  @notify_level_netsend         INT              = 0,        -- 0 = Never, 1 = On Success, 2 = On Failure, 3 = Always
  @notify_level_page            INT              = 0,        -- 0 = Never, 1 = On Success, 2 = On Failure, 3 = Always
  @notify_email_operator_name   sysname          = NULL,
  @notify_netsend_operator_name sysname          = NULL,
  @notify_page_operator_name    sysname          = NULL,
  @delete_level                 INT              = 0,        -- 0 = Never, 1 = On Success, 2 = On Failure, 3 = Always
  @job_id                       UNIQUEIDENTIFIER = NULL OUTPUT,
  @originating_server           NVARCHAR(30)     = NULL
AS
BEGIN
  DECLARE @retval                     INT
  DECLARE @notify_email_operator_id   INT
  DECLARE @notify_netsend_operator_id INT
  DECLARE @notify_page_operator_id    INT
  DECLARE @owner_sid                  VARBINARY(85)

  SET NOCOUNT ON

  IF (@originating_server IS NULL) OR (UPPER(@originating_server) = '(LOCAL)')
    SELECT @originating_server= UPPER(CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName')))

  -- Remove any leading/trailing spaces from parameters (except @owner_login_name)
  SELECT @originating_server           = LTRIM(RTRIM(@originating_server))
  SELECT @job_name                     = LTRIM(RTRIM(@job_name))
  SELECT @description                  = LTRIM(RTRIM(@description))
  SELECT @category_name                = LTRIM(RTRIM(@category_name))
  SELECT @notify_email_operator_name   = LTRIM(RTRIM(@notify_email_operator_name))
  SELECT @notify_netsend_operator_name = LTRIM(RTRIM(@notify_netsend_operator_name))
  SELECT @notify_page_operator_name    = LTRIM(RTRIM(@notify_page_operator_name))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@description                  = N'') SELECT @description                  = NULL
  IF (@category_name                = N'') SELECT @category_name                = NULL
  IF (@notify_email_operator_name   = N'') SELECT @notify_email_operator_name   = NULL
  IF (@notify_netsend_operator_name = N'') SELECT @notify_netsend_operator_name = NULL
  IF (@notify_page_operator_name    = N'') SELECT @notify_page_operator_name    = NULL

  -- Default the owner (if not supplied or if a non-sa is [illegally] trying to create a job for another user)
  IF (@owner_login_name IS NULL) OR ((ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 0) AND (@owner_login_name <> SUSER_SNAME()))
    SELECT @owner_sid = SUSER_SID()
  ELSE
    SELECT @owner_sid = SUSER_SID(@owner_login_name) -- If @owner_login_name is invalid then SUSER_SID() will return NULL

  -- Default the description (if not supplied)
  IF (@description IS NULL)
    SELECT @description = FORMATMESSAGE(14571)

  -- If a category ID is provided this overrides any supplied category name
  IF (@category_id IS NOT NULL)
  BEGIN
    SELECT @category_name = name
    FROM msdb.dbo.syscategories
    WHERE (category_id = @category_id)
    SELECT @category_name = ISNULL(@category_name, FORMATMESSAGE(14205))
  END

  -- Check parameters
  EXECUTE @retval = sp_verify_job NULL,  --  The job id is null since this is a new job
                                  @job_name,
                                  @enabled,
                                  @start_step_id,
                                  @category_name,
                                  @owner_sid                  OUTPUT,
                                  @notify_level_eventlog,
                                  @notify_level_email         OUTPUT,
                                  @notify_level_netsend       OUTPUT,
                                  @notify_level_page          OUTPUT,
                                  @notify_email_operator_name,
                                  @notify_netsend_operator_name,
                                  @notify_page_operator_name,
                                  @delete_level,
                                  @category_id                OUTPUT,
                                  @notify_email_operator_id   OUTPUT,
                                  @notify_netsend_operator_id OUTPUT,
                                  @notify_page_operator_id    OUTPUT,
                                  @originating_server         OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  IF (@job_id IS NULL)
  BEGIN
    -- Assign the GUID
    SELECT @job_id = NEWID()
  END
  ELSE
  BEGIN
    -- A job ID has been provided, so check that the caller is SQLServerAgent (inserting an MSX job)
    IF (PROGRAM_NAME() NOT LIKE N'SQLAgent%')
    BEGIN
      RAISERROR(14284, -1, -1)
      RETURN(1) -- Failure
    END
  END

  INSERT INTO msdb.dbo.sysjobs
         (job_id,
          originating_server,
          name,
          enabled,
          description,
          start_step_id,
          category_id,
          owner_sid,
          notify_level_eventlog,
          notify_level_email,
          notify_level_netsend,
          notify_level_page,
          notify_email_operator_id,
          notify_netsend_operator_id,
          notify_page_operator_id,
          delete_level,
          date_created,
          date_modified,
          version_number)
  VALUES (@job_id,
          @originating_server,
          @job_name,
          @enabled,
          @description,
          @start_step_id,
          @category_id,
          @owner_sid,
          @notify_level_eventlog,
          @notify_level_email,
          @notify_level_netsend,
          @notify_level_page,
          @notify_email_operator_id,
          @notify_netsend_operator_id,
          @notify_page_operator_id,
          @delete_level,
          GETDATE(),
          GETDATE(),
          1) -- Version number 1
  SELECT @retval = @@error

  -- If misc. replication job, then update global replication status table
  IF (@category_id IN (11, 12, 16, 17, 18))
  BEGIN
    -- Nothing can be done if this fails, so don't worry about the return code
    EXECUTE master.dbo.sp_MSupdate_replication_status
      @publisher = '',
      @publisher_db = '',
      @publication = '',
      @publication_type = -1,
      @agent_type = 5,
      @agent_name = @job_name,
      @status = NULL    -- Never run
  END

  -- NOTE: We don't notify SQLServerAgent to update it's cache (we'll do this in sp_add_jobserver)

  RETURN(@retval) -- 0 means success
END
go

/**************************************************************/
/* SP_UPDATE_JOB                                              */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_update_job...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_update_job')
              AND (type = 'P')))
  DROP PROCEDURE sp_update_job
go
CREATE PROCEDURE sp_update_job
  @job_id                       UNIQUEIDENTIFIER = NULL, -- Must provide this or current_name
  @job_name                     sysname          = NULL, -- Must provide this or job_id
  @new_name                     sysname          = NULL,
  @enabled                      TINYINT          = NULL,
  @description                  NVARCHAR(512)    = NULL,
  @start_step_id                INT              = NULL,
  @category_name                sysname          = NULL,
  @owner_login_name             sysname          = NULL,
  @notify_level_eventlog        INT              = NULL,
  @notify_level_email           INT              = NULL,
  @notify_level_netsend         INT              = NULL,
  @notify_level_page            INT              = NULL,
  @notify_email_operator_name   sysname          = NULL,
  @notify_netsend_operator_name sysname          = NULL,
  @notify_page_operator_name    sysname          = NULL,
  @delete_level                 INT              = NULL,
  @automatic_post               BIT              = 1     -- Flag for SEM use only
AS
BEGIN
  DECLARE @retval                        INT
  DECLARE @category_id                   INT
  DECLARE @notify_email_operator_id      INT
  DECLARE @notify_netsend_operator_id    INT
  DECLARE @notify_page_operator_id       INT
  DECLARE @owner_sid                     VARBINARY(85)
  DECLARE @alert_id                      INT
  DECLARE @cached_attribute_modified     INT
  DECLARE @is_sysadmin                   INT
  DECLARE @current_owner                 sysname

  DECLARE @x_new_name                    sysname
  DECLARE @x_enabled                     TINYINT
  DECLARE @x_description                 NVARCHAR(512)
  DECLARE @x_start_step_id               INT
  DECLARE @x_category_name               sysname
  DECLARE @x_category_id                 INT
  DECLARE @x_owner_sid                   VARBINARY(85)
  DECLARE @x_notify_level_eventlog       INT
  DECLARE @x_notify_level_email          INT
  DECLARE @x_notify_level_netsend        INT
  DECLARE @x_notify_level_page           INT
  DECLARE @x_notify_email_operator_name  sysname
  DECLARE @x_notify_netsnd_operator_name sysname
  DECLARE @x_notify_page_operator_name   sysname
  DECLARE @x_delete_level                INT
  DECLARE @x_originating_server          NVARCHAR(30) -- Not updatable

  -- Remove any leading/trailing spaces from parameters (except @owner_login_name)
  SELECT @job_name                     = LTRIM(RTRIM(@job_name))
  SELECT @new_name                     = LTRIM(RTRIM(@new_name))
  SELECT @description                  = LTRIM(RTRIM(@description))
  SELECT @category_name                = LTRIM(RTRIM(@category_name))
  SELECT @notify_email_operator_name   = LTRIM(RTRIM(@notify_email_operator_name))
  SELECT @notify_netsend_operator_name = LTRIM(RTRIM(@notify_netsend_operator_name))
  SELECT @notify_page_operator_name    = LTRIM(RTRIM(@notify_page_operator_name))

  SET NOCOUNT ON

  EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                              '@job_id',
                                               @job_name OUTPUT,
                                               @job_id   OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Are we modifying an attribute which SQLServerAgent caches?
  IF ((@new_name                     IS NOT NULL) OR
      (@enabled                      IS NOT NULL) OR
      (@start_step_id                IS NOT NULL) OR
      (@owner_login_name             IS NOT NULL) OR
      (@notify_level_eventlog        IS NOT NULL) OR
      (@notify_level_email           IS NOT NULL) OR
      (@notify_level_netsend         IS NOT NULL) OR
      (@notify_level_page            IS NOT NULL) OR
      (@notify_email_operator_name   IS NOT NULL) OR
      (@notify_netsend_operator_name IS NOT NULL) OR
      (@notify_page_operator_name    IS NOT NULL) OR
      (@delete_level                 IS NOT NULL))
    SELECT @cached_attribute_modified = 1
  ELSE
    SELECT @cached_attribute_modified = 0

  -- Set the x_ (existing) variables
  SELECT @x_new_name                    = sjv.name,
         @x_enabled                     = sjv.enabled,
         @x_description                 = sjv.description,
         @x_start_step_id               = sjv.start_step_id,
         @x_category_name               = sc.name,                  -- From syscategories
         @x_category_id                 = sc.category_id,           -- From syscategories
         @x_owner_sid                   = sjv.owner_sid,
         @x_notify_level_eventlog       = sjv.notify_level_eventlog,
         @x_notify_level_email          = sjv.notify_level_email,
         @x_notify_level_netsend        = sjv.notify_level_netsend,
         @x_notify_level_page           = sjv.notify_level_page,
         @x_notify_email_operator_name  = so1.name,                   -- From sysoperators
         @x_notify_netsnd_operator_name = so2.name,                   -- From sysoperators
         @x_notify_page_operator_name   = so3.name,                   -- From sysoperators
         @x_delete_level                = sjv.delete_level,
         @x_originating_server          = sjv.originating_server
  FROM msdb.dbo.sysjobs_view                 sjv
       LEFT OUTER JOIN msdb.dbo.sysoperators so1 ON (sjv.notify_email_operator_id = so1.id)
       LEFT OUTER JOIN msdb.dbo.sysoperators so2 ON (sjv.notify_netsend_operator_id = so2.id)
       LEFT OUTER JOIN msdb.dbo.sysoperators so3 ON (sjv.notify_page_operator_id = so3.id),
       msdb.dbo.syscategories                sc
  WHERE (sjv.job_id = @job_id)
    AND (sjv.category_id = sc.category_id)

  -- Check authority (only SQLServerAgent can modify a non-local job)
  IF (UPPER(@x_originating_server) <> UPPER(CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName')))) AND
     (PROGRAM_NAME() NOT LIKE N'SQLAgent%')
  BEGIN
    RAISERROR(14274, -1, -1)
    RETURN(1) -- Failure
  END

  IF (@new_name = N'') SELECT @new_name = NULL

  -- Fill out the values for all non-supplied parameters from the existing values
  IF (@new_name                     IS NULL) SELECT @new_name                     = @x_new_name
  IF (@enabled                      IS NULL) SELECT @enabled                      = @x_enabled
  IF (@description                  IS NULL) SELECT @description                  = @x_description
  IF (@start_step_id                IS NULL) SELECT @start_step_id                = @x_start_step_id
  IF (@category_name                IS NULL) SELECT @category_name                = @x_category_name
  IF (@owner_sid                    IS NULL) SELECT @owner_sid                    = @x_owner_sid
  IF (@notify_level_eventlog        IS NULL) SELECT @notify_level_eventlog        = @x_notify_level_eventlog
  IF (@notify_level_email           IS NULL) SELECT @notify_level_email           = @x_notify_level_email
  IF (@notify_level_netsend         IS NULL) SELECT @notify_level_netsend         = @x_notify_level_netsend
  IF (@notify_level_page            IS NULL) SELECT @notify_level_page            = @x_notify_level_page
  IF (@notify_email_operator_name   IS NULL) SELECT @notify_email_operator_name   = @x_notify_email_operator_name
  IF (@notify_netsend_operator_name IS NULL) SELECT @notify_netsend_operator_name = @x_notify_netsnd_operator_name
  IF (@notify_page_operator_name    IS NULL) SELECT @notify_page_operator_name    = @x_notify_page_operator_name
  IF (@delete_level                 IS NULL) SELECT @delete_level                 = @x_delete_level

  -- If the SA is attempting to assign ownership of the job to someone else, then convert
  -- the login name to an ID
  IF ((ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 1) AND (@owner_login_name IS NOT NULL))
    SELECT @owner_sid = SUSER_SID(@owner_login_name) -- If @owner_login_name is invalid then SUSER_SID() will return NULL

  -- Only the SA can re-assign jobs
  IF ((ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1) AND (@owner_login_name IS NOT NULL))
    RAISERROR(14242, -1, -1)

  -- Ownership of a multi-server job cannot be assigned to a non-sysadmin
  IF (@owner_login_name IS NOT NULL) AND
     (EXISTS (SELECT *
              FROM msdb.dbo.sysjobs       sj,
                   msdb.dbo.sysjobservers sjs
              WHERE (sj.job_id = sjs.job_id)
                AND (sj.job_id = @job_id)
                AND (sjs.server_id <> 0)))
  BEGIN
    SELECT @is_sysadmin = 0
    EXECUTE msdb.dbo.sp_sqlagent_has_server_access @login_name = @owner_login_name, @is_sysadmin_member = @is_sysadmin OUTPUT
    IF (@is_sysadmin = 0)
    BEGIN
      SELECT @current_owner = SUSER_SNAME(@x_owner_sid)
      RAISERROR(14543, -1, -1, @current_owner, N'sysadmin')
      RETURN(1) -- Failure
    END
  END

  -- Turn [nullable] empty string parameters into NULLs
  IF (@description                  = N'') SELECT @description                  = NULL
  IF (@category_name                = N'') SELECT @category_name                = NULL
  IF (@notify_email_operator_name   = N'') SELECT @notify_email_operator_name   = NULL
  IF (@notify_netsend_operator_name = N'') SELECT @notify_netsend_operator_name = NULL
  IF (@notify_page_operator_name    = N'') SELECT @notify_page_operator_name    = NULL

  -- Check new values
  EXECUTE @retval = sp_verify_job @job_id,
                                  @new_name,
                                  @enabled,
                                  @start_step_id,
                                  @category_name,
                                  @owner_sid                  OUTPUT,
                                  @notify_level_eventlog,
                                  @notify_level_email         OUTPUT,
                                  @notify_level_netsend       OUTPUT,
                                  @notify_level_page          OUTPUT,
                                  @notify_email_operator_name,
                                  @notify_netsend_operator_name,
                                  @notify_page_operator_name,
                                  @delete_level,
                                  @category_id                OUTPUT,
                                  @notify_email_operator_id   OUTPUT,
                                  @notify_netsend_operator_id OUTPUT,
                                  @notify_page_operator_id    OUTPUT,
                                  @x_originating_server       OUTPUT -- We ignore the return value
  IF (@retval <> 0)
    RETURN(1) -- Failure

  BEGIN TRANSACTION

  -- If the job is being re-assigned, modify sysjobsteps.database_user_name as necessary
  IF (@owner_login_name IS NOT NULL)
  BEGIN
    IF (EXISTS (SELECT *
                FROM msdb.dbo.sysjobsteps
                WHERE (job_id = @job_id)
                  AND (subsystem = N'TSQL')))
    BEGIN
      IF (EXISTS (SELECT *
                  FROM master.dbo.syslogins
                  WHERE (sid = @owner_sid)
                    AND (sysadmin <> 1)))
      BEGIN
        -- The job is being re-assigned to an non-SA
        UPDATE msdb.dbo.sysjobsteps
        SET database_user_name = NULL
        WHERE (job_id = @job_id)
          AND (subsystem = N'TSQL')
      END
    END
  END

  UPDATE msdb.dbo.sysjobs
  SET name                       = @new_name,
      enabled                    = @enabled,
      description                = @description,
      start_step_id              = @start_step_id,
      category_id                = @category_id,              -- Returned from sp_verify_job
      owner_sid                  = @owner_sid,
      notify_level_eventlog      = @notify_level_eventlog,
      notify_level_email         = @notify_level_email,
      notify_level_netsend       = @notify_level_netsend,
      notify_level_page          = @notify_level_page,
      notify_email_operator_id   = @notify_email_operator_id,   -- Returned from sp_verify_job
      notify_netsend_operator_id = @notify_netsend_operator_id, -- Returned from sp_verify_job
      notify_page_operator_id    = @notify_page_operator_id,    -- Returned from sp_verify_job
      delete_level               = @delete_level,
      version_number             = version_number + 1,  -- Update the job's version
      date_modified              = GETDATE()            -- Update the job's last-modified information
  WHERE (job_id = @job_id)
  SELECT @retval = @@error

  COMMIT TRANSACTION

  -- If change to or from a misc. replication job, then update global replication status table
  IF ((@category_name != @x_category_name) AND
    (@x_category_id IN (11, 12, 16, 17, 18) OR @category_id IN (11, 12,16, 17, 18)))
  BEGIN
    -- Delete entry if change misc. replication job to other
    IF (@x_category_name IS NOT NULL)
    BEGIN
      -- Nothing can be done if this fails, so don't worry about the return code
      EXECUTE master.dbo.sp_MSupdate_replication_status
        @publisher = '',
        @publisher_db = '',
        @publication = '',
        @publication_type = -1,
        @agent_type = 5,
        @agent_name = @job_name,
        @status = -1  -- Delete
    END

    -- Add entry if updated to misc. replication job
    IF (@x_category_name IS NOT NULL)
    BEGIN
      -- Nothing can be done if this fails, so don't worry about the return code
      EXECUTE master.dbo.sp_MSupdate_replication_status
        @publisher = '',
        @publisher_db = '',
        @publication = '',
        @publication_type = -1,
        @agent_type = 5,
        @agent_name = @job_name,
        @status = NULL    -- Never run
    END
  END

  -- Always re-post the job if it's an auto-delete job (or if we're updating an auto-delete job
  -- to be non-auto-delete)
  IF (((SELECT delete_level
        FROM msdb.dbo.sysjobs
        WHERE (job_id = @job_id)) <> 0) OR
      ((@x_delete_level = 1) AND (@delete_level = 0)))
    EXECUTE msdb.dbo.sp_post_msx_operation 'INSERT', 'JOB', @job_id
  ELSE
  BEGIN
    -- Post the update to target servers
    IF (@automatic_post = 1)
      EXECUTE msdb.dbo.sp_post_msx_operation 'UPDATE', 'JOB', @job_id
  END

  -- Keep SQLServerAgent's cache in-sync
  -- NOTE: We only notify SQLServerAgent if we know the job has been cached and if
  --       attributes other than description or category have been changed (since
  --       SQLServerAgent doesn't cache these two)
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobservers
              WHERE (job_id = @job_id)
                AND (server_id = 0)
                AND (@cached_attribute_modified = 1)))
    EXECUTE msdb.dbo.sp_sqlagent_notify @op_type     = N'J',
                                        @job_id      = @job_id,
                                        @action_type = N'U'

  -- If the name was changed, make SQLServerAgent re-cache any alerts that reference the job
  -- since the alert cache contains the job name
  IF ((@job_name <> @new_name) AND (EXISTS (SELECT *
                                            FROM msdb.dbo.sysalerts
                                            WHERE (job_id = @job_id))))
  BEGIN
    DECLARE sysalerts_cache_update CURSOR LOCAL
    FOR
    SELECT id
    FROM msdb.dbo.sysalerts
    WHERE (job_id = @job_id)

    OPEN sysalerts_cache_update
    FETCH NEXT FROM sysalerts_cache_update INTO @alert_id

    WHILE (@@fetch_status = 0)
    BEGIN
      EXECUTE msdb.dbo.sp_sqlagent_notify @op_type     = N'A',
                                          @alert_id    = @alert_id,
                                          @action_type = N'U'
      FETCH NEXT FROM sysalerts_cache_update INTO @alert_id
    END
    DEALLOCATE sysalerts_cache_update
  END

  RETURN(@retval) -- 0 means success
END
go

/**************************************************************/
/* SP_DELETE_JOB                                              */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_delete_job...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_delete_job')
              AND (type = 'P')))
  DROP PROCEDURE sp_delete_job
go
CREATE PROCEDURE sp_delete_job
  @job_id             UNIQUEIDENTIFIER = NULL, -- If provided should NOT also provide job_name
  @job_name           sysname          = NULL, -- If provided should NOT also provide job_id
  @originating_server NVARCHAR(30)     = NULL, -- Reserved (used by SQLAgent)
  @delete_history     BIT              = 1     -- Reserved (used by SQLAgent)
AS
BEGIN
  DECLARE @current_msx_server NVARCHAR(30)
  DECLARE @bMSX_job           BIT
  DECLARE @retval             INT
  DECLARE @local_machine_name NVARCHAR(30)
  DECLARE @category_id        INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @originating_server = LTRIM(RTRIM(@originating_server))

  -- Change server name to always reflect real servername or servername\instancename
  IF (UPPER(@originating_server) = '(LOCAL)')
    SELECT @originating_server = UPPER(CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName')))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@originating_server = N'') 
    SELECT @originating_server = NULL

  IF ((@job_id IS NOT NULL) OR (@job_name IS NOT NULL))
  BEGIN
    EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                                '@job_id',
                                                 @job_name OUTPUT,
                                                 @job_id   OUTPUT
    IF (@retval <> 0)
      RETURN(1) -- Failure
  END

  -- We need either a job name or a server name, not both
  IF ((@job_name IS NULL)     AND (@originating_server IS NULL)) OR
     ((@job_name IS NOT NULL) AND (@originating_server IS NOT NULL))
  BEGIN
    RAISERROR(14279, -1, -1)
    RETURN(1) -- Failure
  END

  -- Get category to see if it is a misc. replication agent. @category_id will be
  -- NULL if there is no @job_id.
  select @category_id = category_id from msdb.dbo.sysjobs where job_id = @job_id

  -- If job name was given, determine if the job is from an MSX
  IF (@job_id IS NOT NULL)
  BEGIN
    SELECT @bMSX_job = CASE UPPER(originating_server)
                         WHEN UPPER(CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName'))) THEN 0
                         ELSE 1
                       END
    FROM msdb.dbo.sysjobs_view
    WHERE (job_id = @job_id)
  END

  -- If server name was given, warn user if different from current MSX
  IF (@originating_server IS NOT NULL)
  BEGIN
    EXECUTE @retval = master.dbo.xp_getnetname @local_machine_name OUTPUT
    IF (@retval <> 0)
      RETURN(1) -- Failure

    IF ((UPPER(@originating_server) = UPPER(CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName')))) OR (UPPER(@originating_server) = UPPER(@local_machine_name)))
      SELECT @originating_server = UPPER(CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName')))

    EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                           N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                           N'MSXServerName',
                                           @current_msx_server OUTPUT,
                                           N'no_output'

    -- If server name was given but it's not the current MSX, print a warning
    SELECT @current_msx_server = LTRIM(RTRIM(@current_msx_server))
    IF ((@current_msx_server IS NOT NULL) AND (@current_msx_server <> N'') AND (@originating_server <> @current_msx_server))
      RAISERROR(14224, 0, 1, @current_msx_server)
  END

  -- Check authority (only SQLServerAgent can delete a non-local job)
  IF (((@originating_server IS NOT NULL) AND (@originating_server <> UPPER(CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName'))))) OR (@bMSX_job = 1)) AND
     (PROGRAM_NAME() NOT LIKE N'SQLAgent%')
  BEGIN
    RAISERROR(14274, -1, -1)
    RETURN(1) -- Failure
  END

  CREATE TABLE #temp_jobs_to_delete (job_id UNIQUEIDENTIFIER NOT NULL, job_is_cached INT NOT NULL)

  -- Do the delete (for a specific job)
  IF (@job_id IS NOT NULL)
  BEGIN
    INSERT INTO #temp_jobs_to_delete
    SELECT job_id, (SELECT COUNT(*)
                    FROM msdb.dbo.sysjobservers
                    WHERE (job_id = @job_id)
                      AND (server_id = 0))
    FROM msdb.dbo.sysjobs_view
    WHERE (job_id = @job_id)

    -- Check if we have any work to do
    IF (NOT EXISTS (SELECT *
                    FROM #temp_jobs_to_delete))
      RETURN(0) -- Success

    -- Post the delete to any target servers (need to do this BEFORE deleting the job itself,
    -- but AFTER clearing all all pending download instructions).  Note that if the job is
    -- NOT a multi-server job then sp_post_msx_operation will catch this and will do nothing.
    DELETE FROM msdb.dbo.sysdownloadlist
    WHERE (object_id = @job_id)
    EXECUTE msdb.dbo.sp_post_msx_operation 'DELETE', 'JOB', @job_id

    -- Must do this before deleting the job itself since sp_sqlagent_notify does a lookup on sysjobs_view
    EXECUTE msdb.dbo.sp_delete_job_references

    -- Delete all traces of the job
    BEGIN TRANSACTION

    DELETE FROM msdb.dbo.sysjobs
    WHERE job_id IN (SELECT job_id FROM #temp_jobs_to_delete)

    DELETE FROM msdb.dbo.sysjobservers
    WHERE job_id IN (SELECT job_id FROM #temp_jobs_to_delete)

    DELETE FROM msdb.dbo.sysjobsteps
    WHERE job_id IN (SELECT job_id FROM #temp_jobs_to_delete)

    DELETE FROM msdb.dbo.sysjobschedules
    WHERE job_id IN (SELECT job_id FROM #temp_jobs_to_delete)

    IF (@delete_history = 1)
      DELETE FROM msdb.dbo.sysjobhistory
      WHERE job_id IN (SELECT job_id FROM #temp_jobs_to_delete)

    COMMIT TRANSACTION

  END
  ELSE
  -- Do the delete (for all jobs originating from the specific server)
  IF (@originating_server IS NOT NULL)
  BEGIN
    EXECUTE msdb.dbo.sp_delete_all_msx_jobs @msx_server = @originating_server

    -- NOTE: In this case there is no need to propagate the delete via sp_post_msx_operation
    --       since this type of delete is only ever performed on a TSX.
  END

  DROP TABLE #temp_jobs_to_delete

  -- If misc. replication job, then update global replication status table.
  -- @category_id will have a value ONLY if @job_name or @job_id is provided.
  IF (@category_id IS NOT NULL AND @category_id IN (11, 12, 16, 17, 18))
  BEGIN
    -- Nothing can be done if this fails, so don't worry about the return code
    EXECUTE master.dbo.sp_MSupdate_replication_status
      @publisher = '',
      @publisher_db = '',
      @publication = '',
      @publication_type = -1,
      @agent_type = 5,
      @agent_name = @job_name,
      @status = -1 -- Delete
  END

  RETURN(0) -- 0 means success
END
go

/**************************************************************/
/* SP_GET_COMPOSITE_JOB_INFO                                  */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_get_composite_job_info...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_get_composite_job_info')
              AND (type = 'P')))
  DROP PROCEDURE sp_get_composite_job_info
go
CREATE PROCEDURE sp_get_composite_job_info
  @job_id             UNIQUEIDENTIFIER = NULL,
  @job_type           VARCHAR(12)      = NULL,  -- LOCAL or MULTI-SERVER
  @owner_login_name   sysname          = NULL,
  @subsystem          NVARCHAR(40)     = NULL,
  @category_id        INT              = NULL,
  @enabled            TINYINT          = NULL,
  @execution_status   INT              = NULL,  -- 0 = Not idle or suspended, 1 = Executing, 2 = Waiting For Thread, 3 = Between Retries, 4 = Idle, 5 = Suspended, [6 = WaitingForStepToFinish], 7 = PerformingCompletionActions
  @date_comparator    CHAR(1)          = NULL,  -- >, < or =
  @date_created       DATETIME         = NULL,
  @date_last_modified DATETIME         = NULL,
  @description        NVARCHAR(512)    = NULL   -- We do a LIKE on this so it can include wildcards
AS
BEGIN
  DECLARE @is_sysadmin INT
  DECLARE @job_owner   sysname

  SET NOCOUNT ON

  -- By 'composite' we mean a combination of sysjobs and xp_sqlagent_enum_jobs data.
  -- This proc should only ever be called by sp_help_job, so we don't verify the
  -- parameters (sp_help_job has already done this).

  -- Step 1: Create intermediate work tables
  CREATE TABLE #job_execution_state (job_id                  UNIQUEIDENTIFIER NOT NULL,
                                     date_started            INT              NOT NULL,
                                     time_started            INT              NOT NULL,
                                     execution_job_status    INT              NOT NULL,
                                     execution_step_id       INT              NULL,
                                     execution_step_name     sysname          COLLATE database_default NULL,
                                     execution_retry_attempt INT              NOT NULL,
                                     next_run_date           INT              NOT NULL,
                                     next_run_time           INT              NOT NULL,
                                     next_run_schedule_id    INT              NOT NULL)
  CREATE TABLE #filtered_jobs (job_id                   UNIQUEIDENTIFIER NOT NULL,
                               date_created             DATETIME         NOT NULL,
                               date_last_modified       DATETIME         NOT NULL,
                               current_execution_status INT              NULL,
                               current_execution_step   sysname          COLLATE database_default NULL,
                               current_retry_attempt    INT              NULL,
                               last_run_date            INT              NOT NULL,
                               last_run_time            INT              NOT NULL,
                               last_run_outcome         INT              NOT NULL,
                               next_run_date            INT              NULL,
                               next_run_time            INT              NULL,
                               next_run_schedule_id     INT              NULL,
                               type                     INT              NOT NULL)
  CREATE TABLE #xp_results (job_id                UNIQUEIDENTIFIER NOT NULL,
                            last_run_date         INT              NOT NULL,
                            last_run_time         INT              NOT NULL,
                            next_run_date         INT              NOT NULL,
                            next_run_time         INT              NOT NULL,
                            next_run_schedule_id  INT              NOT NULL,
                            requested_to_run      INT              NOT NULL, -- BOOL
                            request_source        INT              NOT NULL,
                            request_source_id     sysname          COLLATE database_default NULL,
                            running               INT              NOT NULL, -- BOOL
                            current_step          INT              NOT NULL,
                            current_retry_attempt INT              NOT NULL,
                            job_state             INT              NOT NULL)

  -- Step 2: Capture job execution information (for local jobs only since that's all SQLServerAgent caches)
  SELECT @is_sysadmin = ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0)
  SELECT @job_owner = SUSER_SNAME()

  IF ((@@microsoftversion / 0x01000000) >= 8) -- SQL Server 8.0 or greater
    INSERT INTO #xp_results
    EXECUTE master.dbo.xp_sqlagent_enum_jobs @is_sysadmin, @job_owner, @job_id
  ELSE
    INSERT INTO #xp_results
    EXECUTE master.dbo.xp_sqlagent_enum_jobs @is_sysadmin, @job_owner

  INSERT INTO #job_execution_state
  SELECT xpr.job_id,
         xpr.last_run_date,
         xpr.last_run_time,
         xpr.job_state,
         sjs.step_id,
         sjs.step_name,
         xpr.current_retry_attempt,
         xpr.next_run_date,
         xpr.next_run_time,
         xpr.next_run_schedule_id
  FROM #xp_results                          xpr
       LEFT OUTER JOIN msdb.dbo.sysjobsteps sjs ON ((xpr.job_id = sjs.job_id) AND (xpr.current_step = sjs.step_id)),
       msdb.dbo.sysjobs_view                sjv
  WHERE (sjv.job_id = xpr.job_id)

  -- Step 3: Filter on everything but dates and job_type
  IF ((@subsystem        IS NULL) AND
      (@owner_login_name IS NULL) AND
      (@enabled          IS NULL) AND
      (@category_id      IS NULL) AND
      (@execution_status IS NULL) AND
      (@description      IS NULL) AND
      (@job_id           IS NULL))
  BEGIN
    -- Optimize for the frequently used case...
    INSERT INTO #filtered_jobs
    SELECT sjv.job_id,
           sjv.date_created,
           sjv.date_modified,
           ISNULL(jes.execution_job_status, 4), -- Will be NULL if the job is non-local or is not in #job_execution_state (NOTE: 4 = STATE_IDLE)
           CASE ISNULL(jes.execution_step_id, 0)
             WHEN 0 THEN NULL                   -- Will be NULL if the job is non-local or is not in #job_execution_state
             ELSE CONVERT(NVARCHAR, jes.execution_step_id) + N' (' + jes.execution_step_name + N')'
           END,
           jes.execution_retry_attempt,         -- Will be NULL if the job is non-local or is not in #job_execution_state
           0,  -- last_run_date placeholder    (we'll fix it up in step 3.3)
           0,  -- last_run_time placeholder    (we'll fix it up in step 3.3)
           5,  -- last_run_outcome placeholder (we'll fix it up in step 3.3 - NOTE: We use 5 just in case there are no jobservers for the job)
           jes.next_run_date,                   -- Will be NULL if the job is non-local or is not in #job_execution_state
           jes.next_run_time,                   -- Will be NULL if the job is non-local or is not in #job_execution_state
           jes.next_run_schedule_id,            -- Will be NULL if the job is non-local or is not in #job_execution_state
           0   -- type placeholder             (we'll fix it up in step 3.4)
    FROM msdb.dbo.sysjobs_view                sjv
         LEFT OUTER JOIN #job_execution_state jes ON (sjv.job_id = jes.job_id)
  END
  ELSE
  BEGIN
    INSERT INTO #filtered_jobs
    SELECT DISTINCT
           sjv.job_id,
           sjv.date_created,
           sjv.date_modified,
           ISNULL(jes.execution_job_status, 4), -- Will be NULL if the job is non-local or is not in #job_execution_state (NOTE: 4 = STATE_IDLE)
           CASE ISNULL(jes.execution_step_id, 0)
             WHEN 0 THEN NULL                   -- Will be NULL if the job is non-local or is not in #job_execution_state
             ELSE CONVERT(NVARCHAR, jes.execution_step_id) + N' (' + jes.execution_step_name + N')'
           END,
           jes.execution_retry_attempt,         -- Will be NULL if the job is non-local or is not in #job_execution_state
           0,  -- last_run_date placeholder    (we'll fix it up in step 3.3)
           0,  -- last_run_time placeholder    (we'll fix it up in step 3.3)
           5,  -- last_run_outcome placeholder (we'll fix it up in step 3.3 - NOTE: We use 5 just in case there are no jobservers for the job)
           jes.next_run_date,                   -- Will be NULL if the job is non-local or is not in #job_execution_state
           jes.next_run_time,                   -- Will be NULL if the job is non-local or is not in #job_execution_state
           jes.next_run_schedule_id,            -- Will be NULL if the job is non-local or is not in #job_execution_state
           0   -- type placeholder             (we'll fix it up in step 3.4)
    FROM msdb.dbo.sysjobs_view                sjv
         LEFT OUTER JOIN #job_execution_state jes ON (sjv.job_id = jes.job_id)
         LEFT OUTER JOIN msdb.dbo.sysjobsteps sjs ON (sjv.job_id = sjs.job_id)
    WHERE ((@subsystem        IS NULL) OR (sjs.subsystem            = @subsystem))
      AND ((@owner_login_name IS NULL) OR (sjv.owner_sid            = SUSER_SID(@owner_login_name)))
      AND ((@enabled          IS NULL) OR (sjv.enabled              = @enabled))
      AND ((@category_id      IS NULL) OR (sjv.category_id          = @category_id))
      AND ((@execution_status IS NULL) OR ((@execution_status > 0) AND (jes.execution_job_status = @execution_status))
                                       OR ((@execution_status = 0) AND (jes.execution_job_status <> 4) AND (jes.execution_job_status <> 5)))
      AND ((@description      IS NULL) OR (sjv.description       LIKE @description))
      AND ((@job_id           IS NULL) OR (sjv.job_id               = @job_id))
  END

  -- Step 3.1: Change the execution status of non-local jobs from 'Idle' to 'Unknown'
  UPDATE #filtered_jobs
  SET current_execution_status = NULL
  WHERE (current_execution_status = 4)
    AND (job_id IN (SELECT job_id
                    FROM msdb.dbo.sysjobservers
                    WHERE (server_id <> 0)))

  -- Step 3.2: Check that if the user asked to see idle jobs that we still have some.
  --           If we don't have any then the query should return no rows.
  IF (@execution_status = 4) AND
     (NOT EXISTS (SELECT *
                  FROM #filtered_jobs
                  WHERE (current_execution_status = 4)))
  BEGIN
    TRUNCATE TABLE #filtered_jobs
  END

  -- Step 3.3: Populate the last run date/time/outcome [this is a little tricky since for
  --           multi-server jobs there are multiple last run details in sysjobservers, so
  --           we simply choose the most recent].
  IF (EXISTS (SELECT *
              FROM msdb.dbo.systargetservers))
  BEGIN
    UPDATE #filtered_jobs
    SET last_run_date = sjs.last_run_date,
        last_run_time = sjs.last_run_time,
        last_run_outcome = sjs.last_run_outcome
    FROM #filtered_jobs         fj,
         msdb.dbo.sysjobservers sjs
    WHERE (CONVERT(FLOAT, sjs.last_run_date) * 1000000) + sjs.last_run_time =
           (SELECT MAX((CONVERT(FLOAT, last_run_date) * 1000000) + last_run_time)
            FROM msdb.dbo.sysjobservers
            WHERE (job_id = sjs.job_id))
      AND (fj.job_id = sjs.job_id)
  END
  ELSE
  BEGIN
    UPDATE #filtered_jobs
    SET last_run_date = sjs.last_run_date,
        last_run_time = sjs.last_run_time,
        last_run_outcome = sjs.last_run_outcome
    FROM #filtered_jobs         fj,
         msdb.dbo.sysjobservers sjs
    WHERE (fj.job_id = sjs.job_id)
  END

  -- Step 3.4 : Set the type of the job to local (1) or multi-server (2)
  --            NOTE: If the job has no jobservers then it wil have a type of 0 meaning
  --                  unknown.  This is marginally inconsistent with the behaviour of
  --                  defaulting the category of a new job to [Uncategorized (Local)], but
  --                  prevents incompletely defined jobs from erroneously showing up as valid
  --                  local jobs.
  UPDATE #filtered_jobs
  SET type = 1 -- LOCAL
  FROM #filtered_jobs         fj,
       msdb.dbo.sysjobservers sjs
  WHERE (fj.job_id = sjs.job_id)
    AND (server_id = 0)
  UPDATE #filtered_jobs
  SET type = 2 -- MULTI-SERVER
  FROM #filtered_jobs         fj,
       msdb.dbo.sysjobservers sjs
  WHERE (fj.job_id = sjs.job_id)
    AND (server_id <> 0)

  -- Step 4: Filter on job_type
  IF (@job_type IS NOT NULL)
  BEGIN
    IF (UPPER(@job_type) = 'LOCAL')
      DELETE FROM #filtered_jobs
      WHERE (type <> 1) -- IE. Delete all the non-local jobs
    IF (UPPER(@job_type) = 'MULTI-SERVER')
      DELETE FROM #filtered_jobs
      WHERE (type <> 2) -- IE. Delete all the non-multi-server jobs
  END

  -- Step 5: Filter on dates
  IF (@date_comparator IS NOT NULL)
  BEGIN
    IF (@date_created IS NOT NULL)
    BEGIN
      IF (@date_comparator = '=')
        DELETE FROM #filtered_jobs WHERE (date_created <> @date_created)
      IF (@date_comparator = '>')
        DELETE FROM #filtered_jobs WHERE (date_created <= @date_created)
      IF (@date_comparator = '<')
        DELETE FROM #filtered_jobs WHERE (date_created >= @date_created)
    END
    IF (@date_last_modified IS NOT NULL)
    BEGIN
      IF (@date_comparator = '=')
        DELETE FROM #filtered_jobs WHERE (date_last_modified <> @date_last_modified)
      IF (@date_comparator = '>')
        DELETE FROM #filtered_jobs WHERE (date_last_modified <= @date_last_modified)
      IF (@date_comparator = '<')
        DELETE FROM #filtered_jobs WHERE (date_last_modified >= @date_last_modified)
    END
  END

  -- Return the result set (NOTE: No filtering occurs here)
  SELECT sjv.job_id,
         sjv.originating_server,
         sjv.name,
         sjv.enabled,
         sjv.description,
         sjv.start_step_id,
         category = ISNULL(sc.name, FORMATMESSAGE(14205)),
         owner = SUSER_SNAME(sjv.owner_sid),
         sjv.notify_level_eventlog,
         sjv.notify_level_email,
         sjv.notify_level_netsend,
         sjv.notify_level_page,
         notify_email_operator   = ISNULL(so1.name, FORMATMESSAGE(14205)),
         notify_netsend_operator = ISNULL(so2.name, FORMATMESSAGE(14205)),
         notify_page_operator    = ISNULL(so3.name, FORMATMESSAGE(14205)),
         sjv.delete_level,
         sjv.date_created,
         sjv.date_modified,
         sjv.version_number,
         fj.last_run_date,
         fj.last_run_time,
         fj.last_run_outcome,
         next_run_date = ISNULL(fj.next_run_date, 0),                                 -- This column will be NULL if the job is non-local
         next_run_time = ISNULL(fj.next_run_time, 0),                                 -- This column will be NULL if the job is non-local
         next_run_schedule_id = ISNULL(fj.next_run_schedule_id, 0),                   -- This column will be NULL if the job is non-local
         current_execution_status = ISNULL(fj.current_execution_status, 0),           -- This column will be NULL if the job is non-local
         current_execution_step = ISNULL(fj.current_execution_step, N'0 ' + FORMATMESSAGE(14205)), -- This column will be NULL if the job is non-local
         current_retry_attempt = ISNULL(fj.current_retry_attempt, 0),                 -- This column will be NULL if the job is non-local
         has_step = (SELECT COUNT(*)
                     FROM msdb.dbo.sysjobsteps sjst
                     WHERE (sjst.job_id = sjv.job_id)),
         has_schedule = (SELECT COUNT(*)
                         FROM msdb.dbo.sysjobschedules sjsch
                         WHERE (sjsch.job_id = sjv.job_id)),
         has_target = (SELECT COUNT(*)
                       FROM msdb.dbo.sysjobservers sjs
                       WHERE (sjs.job_id = sjv.job_id)),
         type = fj.type
  FROM #filtered_jobs                         fj
       LEFT OUTER JOIN msdb.dbo.sysjobs_view  sjv ON (fj.job_id = sjv.job_id)
       LEFT OUTER JOIN msdb.dbo.sysoperators  so1 ON (sjv.notify_email_operator_id = so1.id)
       LEFT OUTER JOIN msdb.dbo.sysoperators  so2 ON (sjv.notify_netsend_operator_id = so2.id)
       LEFT OUTER JOIN msdb.dbo.sysoperators  so3 ON (sjv.notify_page_operator_id = so3.id)
       LEFT OUTER JOIN msdb.dbo.syscategories sc  ON (sjv.category_id = sc.category_id)
  ORDER BY sjv.job_id

  -- Clean up
  DROP TABLE #job_execution_state
  DROP TABLE #filtered_jobs
  DROP TABLE #xp_results
END
go

/**************************************************************/
/* SP_HELP_JOB                                                */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_help_job...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_help_job')
              AND (type = 'P')))
  DROP PROCEDURE sp_help_job
go
CREATE PROCEDURE sp_help_job
  -- Individual job parameters
  @job_id                     UNIQUEIDENTIFIER = NULL,  -- If provided should NOT also provide job_name
  @job_name                   sysname          = NULL,  -- If provided should NOT also provide job_id
  @job_aspect                 VARCHAR(9)       = NULL,  -- JOB, STEPS, SCEDULES, TARGETS or ALL
  -- Job set parameters
  @job_type                   VARCHAR(12)      = NULL,  -- LOCAL or MULTI-SERVER
  @owner_login_name           sysname          = NULL,
  @subsystem                  NVARCHAR(40)     = NULL,
  @category_name              sysname          = NULL,
  @enabled                    TINYINT          = NULL,
  @execution_status           INT              = NULL,  -- 1 = Executing, 2 = Waiting For Thread, 3 = Between Retries, 4 = Idle, 5 = Suspended, 6 = [obsolete], 7 = PerformingCompletionActions
  @date_comparator            CHAR(1)          = NULL,  -- >, < or =
  @date_created               DATETIME         = NULL,
  @date_last_modified         DATETIME         = NULL,
  @description                NVARCHAR(512)    = NULL   -- We do a LIKE on this so it can include wildcards
AS
BEGIN
  DECLARE @retval          INT
  DECLARE @category_id     INT
  DECLARE @job_id_as_char  VARCHAR(36)
  DECLARE @res_valid_range NVARCHAR(200)

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters (except @owner_login_name)
  SELECT @job_name         = LTRIM(RTRIM(@job_name))
  SELECT @job_aspect       = LTRIM(RTRIM(@job_aspect))
  SELECT @job_type         = LTRIM(RTRIM(@job_type))
  SELECT @subsystem        = LTRIM(RTRIM(@subsystem))
  SELECT @category_name    = LTRIM(RTRIM(@category_name))
  SELECT @description      = LTRIM(RTRIM(@description))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@job_name         = N'') SELECT @job_name = NULL
  IF (@job_aspect       = '')  SELECT @job_aspect = NULL
  IF (@job_type         = '')  SELECT @job_type = NULL
  IF (@owner_login_name = N'') SELECT @owner_login_name = NULL
  IF (@subsystem        = N'') SELECT @subsystem = NULL
  IF (@category_name    = N'') SELECT @category_name = NULL
  IF (@description      = N'') SELECT @description = NULL

  IF ((@job_id IS NOT NULL) OR (@job_name IS NOT NULL))
  BEGIN
    EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                                '@job_id',
                                                 @job_name OUTPUT,
                                                 @job_id   OUTPUT
    IF (@retval <> 0)
      RETURN(1) -- Failure
  END

  SELECT @job_id_as_char = CONVERT(VARCHAR(36), @job_id)

  -- If the user provided a job name or id but no aspect, default to ALL
  IF ((@job_name IS NOT NULL) OR (@job_id IS NOT NULL)) AND (@job_aspect IS NULL)
    SELECT @job_aspect = 'ALL'

  -- The caller must supply EITHER job name (or job id) and aspect OR one-or-more of the set
  -- parameters OR no parameters at all
  IF (((@job_name IS NOT NULL) OR (@job_id IS NOT NULL))
      AND ((@job_aspect          IS NULL)     OR
           (@job_type            IS NOT NULL) OR
           (@owner_login_name    IS NOT NULL) OR
           (@subsystem           IS NOT NULL) OR
           (@category_name       IS NOT NULL) OR
           (@enabled             IS NOT NULL) OR
           (@date_comparator     IS NOT NULL) OR
           (@date_created        IS NOT NULL) OR
           (@date_last_modified  IS NOT NULL)))
     OR
     ((@job_name IS NULL) AND (@job_id IS NULL) AND (@job_aspect IS NOT NULL))
  BEGIN
    RAISERROR(14280, -1, -1)
    RETURN(1) -- Failure
  END

  IF (@job_id IS NOT NULL)
  BEGIN
    -- Individual job...

    -- Check job aspect
    SELECT @job_aspect = UPPER(@job_aspect)
    IF (@job_aspect NOT IN ('JOB', 'STEPS', 'SCHEDULES', 'TARGETS', 'ALL'))
    BEGIN
      RAISERROR(14266, -1, -1, '@job_aspect', 'JOB, STEPS, SCHEDULES, TARGETS, ALL')
      RETURN(1) -- Failure
    END

    -- Generate results set...

    IF (@job_aspect IN ('JOB', 'ALL'))
    BEGIN
      IF (@job_aspect = 'ALL')
      BEGIN
        RAISERROR(14213, 0, 1)
        PRINT REPLICATE('=', DATALENGTH(FORMATMESSAGE(14213)) / 2)
      END
      EXECUTE sp_get_composite_job_info @job_id,
                                        @job_type,
                                        @owner_login_name,
                                        @subsystem,
                                        @category_id,
                                        @enabled,
                                        @execution_status,
                                        @date_comparator,
                                        @date_created,
                                        @date_last_modified,
                                        @description
    END

    IF (@job_aspect IN ('STEPS', 'ALL'))
    BEGIN
      IF (@job_aspect = 'ALL')
      BEGIN
        PRINT ''
        RAISERROR(14214, 0, 1)
        PRINT REPLICATE('=', DATALENGTH(FORMATMESSAGE(14214)) / 2)
      END
      EXECUTE ('EXECUTE sp_help_jobstep @job_id = ''' + @job_id_as_char + ''', @suffix = 1')
    END

    IF (@job_aspect IN ('SCHEDULES', 'ALL'))
    BEGIN
      IF (@job_aspect = 'ALL')
      BEGIN
        PRINT ''
        RAISERROR(14215, 0, 1)
        PRINT REPLICATE('=', DATALENGTH(FORMATMESSAGE(14215)) / 2)
      END
      EXECUTE ('EXECUTE sp_help_jobschedule @job_id = ''' + @job_id_as_char + '''')
    END

    IF (@job_aspect IN ('TARGETS', 'ALL'))
    BEGIN
      IF (@job_aspect = 'ALL')
      BEGIN
        PRINT ''
        RAISERROR(14216, 0, 1)
        PRINT REPLICATE('=', DATALENGTH(FORMATMESSAGE(14216)) / 2)
      END
      EXECUTE ('EXECUTE sp_help_jobserver @job_id = ''' + @job_id_as_char + ''', @show_last_run_details = 1')
    END
  END
  ELSE
  BEGIN
    -- Set of jobs...

    -- Check job type
    IF (@job_type IS NOT NULL)
    BEGIN
      SELECT @job_type = UPPER(@job_type)
      IF (@job_type NOT IN ('LOCAL', 'MULTI-SERVER'))
      BEGIN
        RAISERROR(14266, -1, -1, '@job_type', 'LOCAL, MULTI-SERVER')
        RETURN(1) -- Failure
      END
    END

    -- Check owner
    IF (@owner_login_name IS NOT NULL)
    BEGIN
      IF (SUSER_SID(@owner_login_name) IS NULL)
      BEGIN
        RAISERROR(14262, -1, -1, '@owner_login_name', @owner_login_name)
        RETURN(1) -- Failure
      END
    END

    -- Check subsystem
    IF (@subsystem IS NOT NULL)
    BEGIN
      EXECUTE @retval = sp_verify_subsystem @subsystem
      IF (@retval <> 0)
        RETURN(1) -- Failure
    END

    -- Check job category
    IF (@category_name IS NOT NULL)
    BEGIN
      SELECT @category_id = category_id
      FROM msdb.dbo.syscategories
      WHERE (category_class = 1) -- Job
        AND (name = @category_name)
      IF (@category_id IS NULL)
      BEGIN
        RAISERROR(14262, -1, -1, '@category_name', @category_name)
        RETURN(1) -- Failure
      END
    END

    -- Check enabled state
    IF (@enabled IS NOT NULL) AND (@enabled NOT IN (0, 1))
    BEGIN
      RAISERROR(14266, -1, -1, '@enabled', '0, 1')
      RETURN(1) -- Failure
    END

    -- Check current execution status
    IF (@execution_status IS NOT NULL)
    BEGIN
      IF (@execution_status NOT IN (0, 1, 2, 3, 4, 5, 7))
      BEGIN
        SELECT @res_valid_range = FORMATMESSAGE(14204)
        RAISERROR(14266, -1, -1, '@execution_status', @res_valid_range)
        RETURN(1) -- Failure
      END
    END

    -- If a date comparator is supplied, we must have either a date-created or date-last-modified
    IF ((@date_comparator IS NOT NULL) AND (@date_created IS NOT NULL) AND (@date_last_modified IS NOT NULL)) OR
       ((@date_comparator IS NULL)     AND ((@date_created IS NOT NULL) OR (@date_last_modified IS NOT NULL)))
    BEGIN
      RAISERROR(14282, -1, -1)
      RETURN(1) -- Failure
    END

    -- Check dates / comparator
    IF (@date_comparator IS NOT NULL) AND (@date_comparator NOT IN ('=', '<', '>'))
    BEGIN
      RAISERROR(14266, -1, -1, '@date_comparator', '=, >, <')
      RETURN(1) -- Failure
    END
    IF (@date_created IS NOT NULL) AND
       ((@date_created < '1 Jan 1990 12:00:00am') OR (@date_created > '31 Dec 9999 11:59:59pm'))
    BEGIN
      RAISERROR(14266, -1, -1, '@date_created', '1/1/1990 12:00am .. 12/31/9999 11:59pm')
      RETURN(1) -- Failure
    END
    IF (@date_last_modified IS NOT NULL) AND
       ((@date_last_modified < '1 Jan 1990 12:00am') OR (@date_last_modified > 'Dec 31 9999 11:59:59pm'))
    BEGIN
      RAISERROR(14266, -1, -1, '@date_last_modified', '1/1/1990 12:00am .. 12/31/9999 11:59pm')
      RETURN(1) -- Failure
    END

    -- Generate results set...
    EXECUTE sp_get_composite_job_info @job_id,
                                      @job_type,
                                      @owner_login_name,
                                      @subsystem,
                                      @category_id,
                                      @enabled,
                                      @execution_status,
                                      @date_comparator,
                                      @date_created,
                                      @date_last_modified,
                                      @description
  END

  RETURN(0) -- Success
END
go

DUMP TRANSACTION msdb WITH NO_LOG
go
CHECKPOINT
go

/**************************************************************/
/* SP_MANAGE_JOBS_BY_LOGIN                                    */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_manage_jobs_by_login...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_manage_jobs_by_login')
              AND (type = 'P')))
  DROP PROCEDURE sp_manage_jobs_by_login
go
CREATE PROCEDURE sp_manage_jobs_by_login
  @action                   VARCHAR(10), -- DELETE or REASSIGN
  @current_owner_login_name sysname,
  @new_owner_login_name     sysname = NULL
AS
BEGIN
  DECLARE @current_sid   VARBINARY(85)
  DECLARE @new_sid       VARBINARY(85)
  DECLARE @job_id        UNIQUEIDENTIFIER
  DECLARE @rows_affected INT
  DECLARE @is_sysadmin   INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @action                   = LTRIM(RTRIM(@action))
  SELECT @current_owner_login_name = LTRIM(RTRIM(@current_owner_login_name))
  SELECT @new_owner_login_name     = LTRIM(RTRIM(@new_owner_login_name))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@new_owner_login_name = N'') SELECT @new_owner_login_name = NULL

  -- Only a sysadmin can do this
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  -- Check action
  IF (@action NOT IN ('DELETE', 'REASSIGN'))
  BEGIN
    RAISERROR(14266, -1, -1, '@action', 'DELETE, REASSIGN')
    RETURN(1) -- Failure
  END

  -- Check parameter combinations
  IF ((@action = 'DELETE') AND (@new_owner_login_name IS NOT NULL))
    RAISERROR(14281, 0, 1)

  IF ((@action = 'REASSIGN') AND (@new_owner_login_name IS NULL))
  BEGIN
    RAISERROR(14237, -1, -1)
    RETURN(1) -- Failure
  END

  -- Check current login
  SELECT @current_sid = SUSER_SID(@current_owner_login_name)
  IF (@current_sid IS NULL)
  BEGIN
    RAISERROR(14262, -1, -1, '@current_owner_login_name', @current_owner_login_name)
    RETURN(1) -- Failure
  END

  -- Check new login (if supplied)
  IF (@new_owner_login_name IS NOT NULL)
  BEGIN
    SELECT @new_sid = SUSER_SID(@new_owner_login_name)
    IF (@new_sid IS NULL)
    BEGIN
      RAISERROR(14262, -1, -1, '@new_owner_login_name', @new_owner_login_name)
      RETURN(1) -- Failure
    END
  END

  IF (@action = 'DELETE')
  BEGIN
    DECLARE jobs_to_delete CURSOR LOCAL
    FOR
    SELECT job_id
    FROM msdb.dbo.sysjobs
    WHERE (owner_sid = @current_sid)

    OPEN jobs_to_delete
    FETCH NEXT FROM jobs_to_delete INTO @job_id

    SELECT @rows_affected = 0
    WHILE (@@fetch_status = 0)
    BEGIN
      EXECUTE sp_delete_job @job_id = @job_id
      SELECT @rows_affected = @rows_affected + 1
      FETCH NEXT FROM jobs_to_delete INTO @job_id
    END
    DEALLOCATE jobs_to_delete
    RAISERROR(14238, 0, 1, @rows_affected)
  END
  ELSE
  IF (@action = 'REASSIGN')
  BEGIN
    -- Check if the current owner owns any multi-server jobs.
    -- If they do, then the new owner must be member of the sysadmin role.
    IF (EXISTS (SELECT *
                FROM msdb.dbo.sysjobs       sj,
                     msdb.dbo.sysjobservers sjs
                WHERE (sj.job_id = sjs.job_id)
                  AND (sj.owner_sid = @current_sid)
                  AND (sjs.server_id <> 0)))
    BEGIN
      SELECT @is_sysadmin = 0
      EXECUTE msdb.dbo.sp_sqlagent_has_server_access @login_name = @new_owner_login_name, @is_sysadmin_member = @is_sysadmin OUTPUT
      IF (@is_sysadmin = 0)
      BEGIN
        RAISERROR(14543, -1, -1, @current_owner_login_name, N'sysadmin')
        RETURN(1) -- Failure
      END
    END

    UPDATE msdb.dbo.sysjobs
    SET owner_sid = @new_sid
    WHERE (owner_sid = @current_sid)
    RAISERROR(14239, 0, 1, @@rowcount, @new_owner_login_name)
  END

  RETURN(0) -- Success
END
go

/**************************************************************/
/* SP_APPLY_JOB_TO_TARGETS                                    */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_apply_job_to_targets...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_apply_job_to_targets')
              AND (type = 'P')))
  DROP PROCEDURE sp_apply_job_to_targets
go
CREATE PROCEDURE sp_apply_job_to_targets
  @job_id               UNIQUEIDENTIFIER = NULL,   -- Must provide either this or job_name
  @job_name             sysname          = NULL,   -- Must provide either this or job_id
  @target_server_groups NVARCHAR(2048)   = NULL,   -- A comma-separated list of target server groups
  @target_servers       NVARCHAR(2048)   = NULL,   -- An comma-separated list of target servers
  @operation            VARCHAR(7)       = 'APPLY' -- Or 'REMOVE'
AS
BEGIN
  DECLARE @retval        INT
  DECLARE @rows_affected INT
  DECLARE @server_name   NVARCHAR(30)
  DECLARE @groups        NVARCHAR(2048)
  DECLARE @group         sysname
  DECLARE @servers       NVARCHAR(2048)
  DECLARE @server        NVARCHAR(30)
  DECLARE @pos_of_comma  INT

  SET NOCOUNT ON

  -- Only a sysadmin can do this
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  -- Remove any leading/trailing spaces from parameters
  SELECT @target_server_groups = LTRIM(RTRIM(@target_server_groups))
  SELECT @target_servers       = LTRIM(RTRIM(@target_servers))
  SELECT @operation            = LTRIM(RTRIM(@operation))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@target_server_groups = NULL) SELECT @target_server_groups = NULL
  IF (@target_servers       = NULL) SELECT @target_servers = NULL
  IF (@operation            = NULL) SELECT @operation = NULL

  EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                              '@job_id',
                                               @job_name OUTPUT,
                                               @job_id   OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check operation type
  IF ((@operation <> 'APPLY') AND (@operation <> 'REMOVE'))
  BEGIN
    RAISERROR(14266, -1, -1, '@operation', 'APPLY, REMOVE')
    RETURN(1) -- Failure
  END

  CREATE TABLE #temp_groups (group_name sysname COLLATE database_default NOT NULL)
  CREATE TABLE #temp_server_name (server_name NVARCHAR(30) COLLATE database_default NOT NULL)

  -- Check that we have a target server group list and/or a target server list
  IF ((@target_server_groups IS NULL) AND (@target_servers IS NULL))
  BEGIN
    RAISERROR(14283, -1, -1)
    RETURN(1) -- Failure
  END

  -- Parse the Target Server comma-separated list (if supplied)
  IF (@target_servers IS NOT NULL)
  BEGIN
    SELECT @servers = @target_servers
    SELECT @pos_of_comma = CHARINDEX(N',', @servers)
    WHILE (@pos_of_comma <> 0)
    BEGIN
      SELECT @server = SUBSTRING(@servers, 1, @pos_of_comma - 1)
      INSERT INTO #temp_server_name (server_name) VALUES (LTRIM(RTRIM(@server)))
      SELECT @servers = RIGHT(@servers, (DATALENGTH(@servers) / 2) - @pos_of_comma)
      SELECT @pos_of_comma = CHARINDEX(N',', @servers)
    END
    INSERT INTO #temp_server_name (server_name) VALUES (LTRIM(RTRIM(@servers)))
  END

  -- Parse the Target Server Groups comma-separated list
  IF (@target_server_groups IS NOT NULL)
  BEGIN
    SELECT @groups = @target_server_groups
    SELECT @pos_of_comma = CHARINDEX(N',', @groups)
    WHILE (@pos_of_comma <> 0)
    BEGIN
      SELECT @group = SUBSTRING(@groups, 1, @pos_of_comma - 1)
      INSERT INTO #temp_groups (group_name) VALUES (LTRIM(RTRIM(@group)))
      SELECT @groups = RIGHT(@groups, (DATALENGTH(@groups) / 2) - @pos_of_comma)
      SELECT @pos_of_comma = CHARINDEX(N',', @groups)
    END
    INSERT INTO #temp_groups (group_name) VALUES (LTRIM(RTRIM(@groups)))
  END

  -- Check server groups
  SET ROWCOUNT 1 -- We do this so that we catch the FIRST invalid group
  SELECT @group = NULL
  SELECT @group = group_name
  FROM #temp_groups
  WHERE group_name NOT IN (SELECT name
                           FROM msdb.dbo.systargetservergroups)
  IF (@group IS NOT NULL)
  BEGIN
    RAISERROR(14262, -1, -1, '@target_server_groups', @group)
    RETURN(1) -- Failure
  END
  SET ROWCOUNT 0

  -- Find the distinct list of servers being targeted
  INSERT INTO #temp_server_name (server_name)
  SELECT DISTINCT sts.server_name
  FROM msdb.dbo.systargetservergroups       stsg,
       msdb.dbo.systargetservergroupmembers stsgm,
       msdb.dbo.systargetservers            sts
  WHERE (stsg.name IN (SELECT group_name FROM #temp_groups))
    AND (stsg.servergroup_id = stsgm.servergroup_id)
    AND (stsgm.server_id = sts.server_id)
    AND (sts.server_name NOT IN (SELECT server_name
                                 FROM #temp_server_name))

  IF (@operation = 'APPLY')
  BEGIN
    -- Remove those servers to which the job has already been applied
    DELETE FROM #temp_server_name
    WHERE server_name IN (SELECT sts.server_name
                          FROM msdb.dbo.sysjobservers    sjs,
                               msdb.dbo.systargetservers sts
                          WHERE (sjs.job_id = @job_id)
                            AND (sjs.server_id = sts.server_id))
  END

  IF (@operation = 'REMOVE')
  BEGIN
    -- Remove those servers to which the job is not currently applied
    DELETE FROM #temp_server_name
    WHERE server_name NOT IN (SELECT sts.server_name
                              FROM msdb.dbo.sysjobservers    sjs,
                                   msdb.dbo.systargetservers sts
                              WHERE (sjs.job_id = @job_id)
                                AND (sjs.server_id = sts.server_id))
  END

  SELECT @rows_affected = COUNT(*)
  FROM #temp_server_name

  SET ROWCOUNT 1
  WHILE (EXISTS (SELECT *
                 FROM #temp_server_name))
  BEGIN
    SELECT @server_name = server_name
    FROM #temp_server_name
    IF (@operation = 'APPLY')
      EXECUTE sp_add_jobserver @job_id = @job_id, @server_name = @server_name
    ELSE
    IF (@operation = 'REMOVE')
      EXECUTE sp_delete_jobserver @job_id = @job_id, @server_name = @server_name
    DELETE FROM #temp_server_name
    WHERE (server_name = @server_name)
  END
  SET ROWCOUNT 0

  IF (@operation = 'APPLY')
    RAISERROR(14240, 0, 1, @rows_affected)
  IF (@operation = 'REMOVE')
    RAISERROR(14241, 0, 1, @rows_affected)

  RETURN(0) -- Success
END
go

/**************************************************************/
/* SP_REMOVE_JOB_FROM_TARGETS                                 */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_remove_job_from_targets...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_remove_job_from_targets')
              AND (type = 'P')))
  DROP PROCEDURE sp_remove_job_from_targets
go
CREATE PROCEDURE sp_remove_job_from_targets
  @job_id               UNIQUEIDENTIFIER = NULL,   -- Must provide either this or job_name
  @job_name             sysname          = NULL,   -- Must provide either this or job_id
  @target_server_groups NVARCHAR(1024)   = NULL,   -- A comma-separated list of target server groups
  @target_servers       NVARCHAR(1024)   = NULL    -- A comma-separated list of target servers
AS
BEGIN
  DECLARE @retval INT

  SET NOCOUNT ON

  EXECUTE @retval = sp_apply_job_to_targets @job_id,
                                            @job_name,
                                            @target_server_groups,
                                            @target_servers,
                                           'REMOVE'
  RETURN(@retval) -- 0 means success
END
go

/**************************************************************/
/* SP_GET_JOB_ALERTS                                          */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_get_job_alerts...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_get_job_alerts')
              AND (type = 'P')))
  DROP PROCEDURE sp_get_job_alerts
go
CREATE PROCEDURE sp_get_job_alerts
  @job_id   UNIQUEIDENTIFIER = NULL,
  @job_name sysname          = NULL
AS
BEGIN
  DECLARE @retval INT

  EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                              '@job_id',
                                               @job_name OUTPUT,
                                               @job_id   OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  SELECT id,
         name,
         enabled,
         type = CASE ISNULL(performance_condition, N'!')
                  WHEN N'!' THEN
                    CASE event_source
                      WHEN N'MSSQLSERVER' THEN 1 -- SQL Server event alert
                      ELSE 3                     -- Non SQL Server event alert
                    END
                  ELSE 2                         -- SQL Server performance condition alert
                END
  FROM msdb.dbo.sysalerts
  WHERE (job_id = @job_id)

  RETURN(0) -- Success
END
go

/**************************************************************/
/*                                                            */
/*   S  U  P  P  O  R  T     P  R  O  C  E  D  U  R  E  S     */
/*                                                            */
/**************************************************************/

/**************************************************************/
/* SP_CONVERT_JOBID_TO_CHAR [used by SEM only]                */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_convert_jobid_to_char...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_convert_jobid_to_char')
              AND (type = 'P')))
  DROP PROCEDURE sp_convert_jobid_to_char
go
CREATE PROCEDURE sp_convert_jobid_to_char
  @job_id         UNIQUEIDENTIFIER,
  @job_id_as_char NVARCHAR(34) OUTPUT -- 34 because of the leading '0x'
AS
BEGIN
  DECLARE @job_id_as_binary BINARY(16)
  DECLARE @temp             NCHAR(8)
  DECLARE @counter          INT
  DECLARE @byte_value       INT
  DECLARE @high_word        INT
  DECLARE @low_word         INT
  DECLARE @high_high_nybble INT
  DECLARE @high_low_nybble  INT
  DECLARE @low_high_nybble  INT
  DECLARE @low_low_nybble   INT

  SET NOCOUNT ON

  SELECT @job_id_as_binary = CONVERT(BINARY(16), @job_id)
  SELECT @temp = CONVERT(NCHAR(8), @job_id_as_binary)

  SELECT @job_id_as_char = N''
  SELECT @counter = 1

  WHILE (@counter <= (DATALENGTH(@temp) / 2))
  BEGIN
    SELECT @byte_value       = CONVERT(INT, CONVERT(BINARY(2), SUBSTRING(@temp, @counter, 1)))
    SELECT @high_word        = (@byte_value & 0xff00) / 0x100
    SELECT @low_word         = (@byte_value & 0x00ff)
    SELECT @high_high_nybble = (@high_word & 0xff) / 16
    SELECT @high_low_nybble  = (@high_word & 0xff) % 16
    SELECT @low_high_nybble  = (@low_word & 0xff) / 16
    SELECT @low_low_nybble   = (@low_word & 0xff) % 16

    IF (@high_high_nybble < 10)
      SELECT @job_id_as_char = @job_id_as_char + NCHAR(ASCII('0') + @high_high_nybble)
    ELSE
      SELECT @job_id_as_char = @job_id_as_char + NCHAR(ASCII('A') + (@high_high_nybble - 10))

    IF (@high_low_nybble < 10)
      SELECT @job_id_as_char = @job_id_as_char + NCHAR(ASCII('0') + @high_low_nybble)
    ELSE
      SELECT @job_id_as_char = @job_id_as_char + NCHAR(ASCII('A') + (@high_low_nybble - 10))

    IF (@low_high_nybble < 10)
      SELECT @job_id_as_char = @job_id_as_char + NCHAR(ASCII('0') + @low_high_nybble)
    ELSE
      SELECT @job_id_as_char = @job_id_as_char + NCHAR(ASCII('A') + (@low_high_nybble - 10))

    IF (@low_low_nybble < 10)
      SELECT @job_id_as_char = @job_id_as_char + NCHAR(ASCII('0') + @low_low_nybble)
    ELSE
      SELECT @job_id_as_char = @job_id_as_char + NCHAR(ASCII('A') + (@low_low_nybble - 10))

    SELECT @counter = @counter + 1
  END

  SELECT @job_id_as_char = N'0x' + LOWER(@job_id_as_char)
END
go

/**************************************************************/
/* SP_START_JOB                                               */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_start_job...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_start_job')
              AND (type = 'P')))
  DROP PROCEDURE sp_start_job
go
CREATE PROCEDURE sp_start_job
  @job_name    sysname          = NULL,
  @job_id      UNIQUEIDENTIFIER = NULL,
  @error_flag  INT              = 1,    -- Set to 0 to suppress the error from sp_sqlagent_notify if SQLServerAgent is not running
  @server_name NVARCHAR(30)     = NULL, -- The specific target server to start the [multi-server] job on
  @step_name   sysname          = NULL, -- The name of the job step to start execution with [for use with a local job only]
  @output_flag INT              = 1     -- Set to 0 to suppress the success message
AS
BEGIN
  DECLARE @job_id_as_char VARCHAR(36)
  DECLARE @retval         INT
  DECLARE @step_id        INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @job_name    = LTRIM(RTRIM(@job_name))
  SELECT @server_name = LTRIM(RTRIM(@server_name))
  SELECT @step_name   = LTRIM(RTRIM(@step_name))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@job_name = N'')    SELECT @job_name = NULL
  IF (@server_name = N'') SELECT @server_name = NULL
  IF (@step_name = N'')   SELECT @step_name = NULL

  EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                              '@job_id',
                                               @job_name OUTPUT,
                                               @job_id   OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysjobservers
                  WHERE (job_id = @job_id)))
  BEGIN
    SELECT @job_id_as_char = CONVERT(VARCHAR(36), @job_id)
    RAISERROR(14256, -1, -1, @job_name, @job_id_as_char)
    RETURN(1) -- Failure
  END

  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobservers
              WHERE (job_id = @job_id)
                AND (server_id = 0)))
  BEGIN
    -- The job is local, so start (run) the job locally

    -- Check the step name (if supplied)
    IF (@step_name IS NOT NULL)
    BEGIN
      SELECT @step_id = step_id
      FROM msdb.dbo.sysjobsteps
      WHERE (step_name = @step_name)
        AND (job_id = @job_id)

      IF (@step_id IS NULL)
      BEGIN
        RAISERROR(14262, -1, -1, '@step_name', @step_name)
        RETURN(1) -- Failure
      END
    END

    EXECUTE @retval = msdb.dbo.sp_sqlagent_notify @op_type     = N'J',
                                                  @job_id      = @job_id,
                                                  @schedule_id = @step_id, -- This is the start step
                                                  @action_type = N'S',
                                                  @error_flag  = @error_flag
    IF ((@retval = 0) AND (@output_flag = 1))
      RAISERROR(14243, 0, 1, @job_name)
  END
  ELSE
  BEGIN
    -- The job is a multi-server job

    -- Check target server name (if any)
    IF (@server_name IS NOT NULL)
    BEGIN
      IF (NOT EXISTS (SELECT *
                      FROM msdb.dbo.systargetservers
                      WHERE (server_name = @server_name)))
      BEGIN
        RAISERROR(14262, -1, -1, '@server_name', @server_name)
        RETURN(1) -- Failure
      END
    END

    -- Re-post the job if it's an auto-delete job
    IF ((SELECT delete_level
         FROM msdb.dbo.sysjobs
         WHERE (job_id = @job_id)) <> 0)
      EXECUTE @retval = msdb.dbo.sp_post_msx_operation 'INSERT', 'JOB', @job_id, @server_name

    -- Post start instruction(s)
    EXECUTE @retval = msdb.dbo.sp_post_msx_operation 'START', 'JOB', @job_id, @server_name
  END

  RETURN(@retval) -- 0 means success
END
go

/**************************************************************/
/* SP_STOP_JOB                                                */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_stop_job...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_stop_job')
              AND (type = 'P')))
  DROP PROCEDURE sp_stop_job
go
CREATE PROCEDURE sp_stop_job
  @job_name           sysname          = NULL,
  @job_id             UNIQUEIDENTIFIER = NULL,
  @originating_server NVARCHAR(30)     = NULL, -- So that we can stop ALL jobs that came from the given server
  @server_name        NVARCHAR(30)     = NULL  -- The specific target server to stop the [multi-server] job on
AS
BEGIN
  DECLARE @job_id_as_char VARCHAR(36)
  DECLARE @retval         INT
  DECLARE @num_parameters INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @job_name           = LTRIM(RTRIM(@job_name))
  SELECT @originating_server = LTRIM(RTRIM(@originating_server))
  SELECT @server_name        = LTRIM(RTRIM(@server_name))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@job_name           = N'') SELECT @job_name = NULL
  IF (@originating_server = N'') SELECT @originating_server = NULL
  IF (@server_name        = N'') SELECT @server_name = NULL

  -- We must have EITHER a job id OR a job name OR an originating server
  SELECT @num_parameters = 0
  IF (@job_id IS NOT NULL)
    SELECT @num_parameters = @num_parameters + 1
  IF (@job_name IS NOT NULL)
    SELECT @num_parameters = @num_parameters + 1
  IF (@originating_server IS NOT NULL)
    SELECT @num_parameters = @num_parameters + 1
  IF (@num_parameters <> 1)
  BEGIN
    RAISERROR(14232, -1, -1)
    RETURN(1) -- Failure
  END

  IF (@originating_server IS NOT NULL)
  BEGIN
    -- Stop (cancel) ALL local jobs that originated from the specified server
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysjobs_view
                    WHERE (originating_server = @originating_server)))
    BEGIN
      RAISERROR(14268, -1, -1, @originating_server)
      RETURN(1) -- Failure
    END

    DECLARE @total_counter   INT
    DECLARE @success_counter INT

    DECLARE stop_jobs CURSOR LOCAL
    FOR
    SELECT job_id
    FROM msdb.dbo.sysjobs_view
    WHERE (originating_server = @originating_server)

    SELECT @total_counter = 0, @success_counter = 0
    OPEN stop_jobs
    FETCH NEXT FROM stop_jobs INTO @job_id
    WHILE (@@fetch_status = 0)
    BEGIN
      SELECT @total_counter + @total_counter + 1
      EXECUTE @retval = msdb.dbo.sp_sqlagent_notify @op_type     = N'J',
                                                    @job_id      = @job_id,
                                                    @action_type = N'C'
      IF (@retval = 0)
        SELECT @success_counter = @success_counter + 1
      FETCH NEXT FROM stop_jobs INTO @job_id
    END
    RAISERROR(14253, 0, 1, @success_counter, @total_counter)
    DEALLOCATE stop_jobs

    RETURN(0) -- 0 means success
  END
  ELSE
  BEGIN
    -- Stop ONLY the specified job
    EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                                '@job_id',
                                                 @job_name OUTPUT,
                                                 @job_id   OUTPUT
    IF (@retval <> 0)
      RETURN(1) -- Failure

    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysjobservers
                    WHERE (job_id = @job_id)))
    BEGIN
      SELECT @job_id_as_char = CONVERT(VARCHAR(36), @job_id)
      RAISERROR(14257, -1, -1, @job_name, @job_id_as_char)
      RETURN(1) -- Failure
    END

    IF (EXISTS (SELECT *
                FROM msdb.dbo.sysjobservers
                WHERE (job_id = @job_id)
                  AND (server_id = 0)))
    BEGIN
      -- The job is local, so stop (cancel) the job locally
      EXECUTE @retval = msdb.dbo.sp_sqlagent_notify @op_type     = N'J',
                                                    @job_id      = @job_id,
                                                    @action_type = N'C'
      IF (@retval = 0)
        RAISERROR(14254, 0, 1, @job_name)
    END
    ELSE
    BEGIN
      -- The job is a multi-server job

      -- Check target server name (if any)
      IF (@server_name IS NOT NULL)
      BEGIN
        IF (NOT EXISTS (SELECT *
                        FROM msdb.dbo.systargetservers
                        WHERE (server_name = @server_name)))
        BEGIN
          RAISERROR(14262, -1, -1, '@server_name', @server_name)
          RETURN(1) -- Failure
        END
      END

      -- Post the stop instruction(s)
      EXECUTE @retval = sp_post_msx_operation 'STOP', 'JOB', @job_id, @server_name
    END

    RETURN(@retval) -- 0 means success
  END

END
go

/**************************************************************/
/* SP_GET_CHUNKED_JOBSTEP_PARAMS                              */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_get_chunked_jobstep_params...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_get_chunked_jobstep_params')
              AND (type = 'P')))
  DROP PROCEDURE sp_get_chunked_jobstep_params
go
CREATE PROCEDURE sp_get_chunked_jobstep_params
  @job_name sysname,
  @step_id  INT = 1
AS
BEGIN
  DECLARE @job_id           UNIQUEIDENTIFIER
  DECLARE @step_id_as_char  VARCHAR(10)
  DECLARE @text_pointer     VARBINARY(16)
  DECLARE @remaining_length INT
  DECLARE @offset           INT
  DECLARE @chunk            INT
  DECLARE @retval           INT

  SET NOCOUNT ON

  -- Check that the job exists
  EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                              '@job_id',
                                               @job_name OUTPUT,
                                               @job_id   OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check that the step exists
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysjobsteps
                  WHERE (job_id = @job_id)
                    AND (step_id = @step_id)))
  BEGIN
    SELECT @step_id_as_char = CONVERT(VARCHAR(10), @step_id)
    RAISERROR(14262, -1, -1, '@step_id', @step_id_as_char)
    RETURN(1) -- Failure
  END

  -- Return the sysjobsteps.additional_parameters TEXT column as multiple readtexts of
  -- length 2048

  SELECT @text_pointer = TEXTPTR(additional_parameters),
         @remaining_length = (DATALENGTH(additional_parameters) / 2)
  FROM msdb.dbo.sysjobsteps
  WHERE (job_id = @job_id)
    AND (step_id = @step_id)

  SELECT @offset = 0, @chunk = 100

  -- Get all the chunks of @chunk size
  WHILE (@remaining_length > @chunk)
  BEGIN
    READTEXT msdb.dbo.sysjobsteps.additional_parameters @text_pointer @offset @chunk
    SELECT @offset = @offset + @chunk
    SELECT @remaining_length = @remaining_length - @chunk
  END

  -- Get the last chunk
  IF (@remaining_length > 0)
    READTEXT msdb.dbo.sysjobsteps.additional_parameters @text_pointer @offset @remaining_length

  RETURN(@@error) -- 0 means success
END
go

/**************************************************************/
/* SP_CHECK_FOR_OWNED_JOBS                                    */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_check_for_owned_jobs...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_check_for_owned_jobs')
              AND (type = 'P')))
  DROP PROCEDURE sp_check_for_owned_jobs
go
CREATE PROCEDURE sp_check_for_owned_jobs
  @login_name sysname,
  @table_name sysname
AS
BEGIN
  SET NOCOUNT ON

  -- This procedure is called by sp_droplogin to check if the login being dropped
  -- still owns jobs.  The return value (the number of jobs owned) is passed back
  -- via the supplied table name [this cumbersome approach is necessary because
  -- sp_check_for_owned_jobs is invoked via an EXEC() and because we always want
  -- sp_droplogin to work, even if msdb and/or sysjobs does not exist].

  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysobjects
              WHERE (name = N'sysjobs')
                AND (type = 'U')))
  BEGIN
    SELECT @login_name = REPLACE(@login_name, N'''', N'''''')
    EXECUTE(N'INSERT INTO ' + @table_name + N' SELECT COUNT(*) FROM msdb.dbo.sysjobs_view WHERE (owner_sid = SUSER_SID(N''' + @login_name + '''))')
  END
END
go

/**************************************************************/
/* SP_CHECK_FOR_OWNED_JOBSTEPS                                */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_check_for_owned_jobsteps...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_check_for_owned_jobsteps')
              AND (type = 'P')))
  DROP PROCEDURE sp_check_for_owned_jobsteps
go
CREATE PROCEDURE sp_check_for_owned_jobsteps
  @login_name         sysname = NULL,  -- Supply this OR the database_X parameters, but not both
  @database_name      sysname = NULL,
  @database_user_name sysname = NULL
AS
BEGIN
  DECLARE @db_name         NVARCHAR(255)
  DECLARE @escaped_db_name NVARCHAR(255)

  SET NOCOUNT ON

  CREATE TABLE #work_table
  (
  database_name      sysname COLLATE database_default,
  database_user_name sysname COLLATE database_default
  )

  IF ((@login_name IS NOT NULL) AND (@database_name IS NULL) AND (@database_user_name IS NULL))
  BEGIN
    IF (SUSER_SID(@login_name) IS NULL)
    BEGIN
      RAISERROR(14262, -1, -1, '@login_name', @login_name)
      RETURN(1) -- Failure
    END

    DECLARE all_databases CURSOR LOCAL
    FOR
    SELECT name
    FROM master.dbo.sysdatabases

    OPEN all_databases
    FETCH NEXT FROM all_databases INTO @db_name

    -- Double up any single quotes in @login_name
    SELECT @login_name = REPLACE(@login_name, N'''', N'''''')

    WHILE (@@fetch_status = 0)
    BEGIN
      SELECT @escaped_db_name = QUOTENAME(@db_name, N'[')
      SELECT @db_name = REPLACE(@db_name, '''', '''''')
      EXECUTE(N'INSERT INTO #work_table
                SELECT N''' + @db_name + N''', name
                FROM ' + @escaped_db_name + N'.dbo.sysusers
                WHERE (sid = SUSER_SID(N''' + @login_name + N'''))')
      FETCH NEXT FROM all_databases INTO @db_name
    END

    DEALLOCATE all_databases

    -- If the login is an NT login, check for steps run as the login directly (as is the case with transient NT logins)
    IF (@login_name LIKE '%\%')
    BEGIN
      INSERT INTO #work_table
      SELECT database_name, database_user_name
      FROM msdb.dbo.sysjobsteps
      WHERE (database_user_name = @login_name)
    END
  END

  IF ((@login_name IS NULL) AND (@database_name IS NOT NULL) AND (@database_user_name IS NOT NULL))
  BEGIN
    INSERT INTO #work_table
    SELECT @database_name, @database_user_name
  END

  IF (EXISTS (SELECT *
              FROM #work_table wt,
                   msdb.dbo.sysjobsteps sjs
              WHERE (wt.database_name = sjs.database_name)
                AND (wt.database_user_name = sjs.database_user_name)))
  BEGIN
    SELECT sjv.job_id,
           sjv.name,
           sjs.step_id,
           sjs.step_name
    FROM #work_table           wt,
         msdb.dbo.sysjobsteps  sjs,
         msdb.dbo.sysjobs_view sjv
    WHERE (wt.database_name = sjs.database_name)
      AND (wt.database_user_name = sjs.database_user_name)
      AND (sjv.job_id = sjs.job_id)
    ORDER BY sjs.job_id
  END

  RETURN(0) -- 0 means success
END
go

/**************************************************************/
/* SP_SQLAGENT_REFRESH_JOB                                    */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_sqlagent_refresh_job...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_sqlagent_refresh_job')
              AND (type = 'P')))
  DROP PROCEDURE sp_sqlagent_refresh_job
go
CREATE PROCEDURE sp_sqlagent_refresh_job
  @job_id      UNIQUEIDENTIFIER = NULL,
  @server_name NVARCHAR(30)     = NULL -- This parameter allows a TSX to use this SP when updating a job
AS
BEGIN
  DECLARE @server_id INT

  SET NOCOUNT ON

  IF (@server_name IS NULL) OR (UPPER(@server_name) = '(LOCAL)')
    SELECT @server_name = UPPER(CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName')))

  SELECT @server_id = server_id
  FROM msdb.dbo.systargetservers_view
  WHERE (server_name = ISNULL(@server_name, UPPER(CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName')))))

  SELECT @server_id = ISNULL(@server_id, 0)

  SELECT sjv.job_id,
         sjv.name,
         sjv.enabled,
         sjv.start_step_id,
         owner = SUSER_SNAME(sjv.owner_sid),
         sjv.notify_level_eventlog,
         sjv.notify_level_email,
         sjv.notify_level_netsend,
         sjv.notify_level_page,
         sjv.notify_email_operator_id,
         sjv.notify_netsend_operator_id,
         sjv.notify_page_operator_id,
         sjv.delete_level,
         has_step = (SELECT COUNT(*)
                     FROM msdb.dbo.sysjobsteps sjst
                     WHERE (sjst.job_id = sjv.job_id)),
         sjv.version_number,
         last_run_date = ISNULL(sjs.last_run_date, 0),
         last_run_time = ISNULL(sjs.last_run_time, 0),
         sjv.originating_server,
         sjv.description
  FROM msdb.dbo.sysjobs_view  sjv,
       msdb.dbo.sysjobservers sjs
  WHERE ((@job_id IS NULL) OR (@job_id = sjv.job_id))
    AND (sjv.job_id = sjs.job_id)
    AND (sjs.server_id = @server_id)
  ORDER BY sjv.job_id

  RETURN(@@error) -- 0 means success
END
go

/**************************************************************/
/* SP_JOBHISTORY_ROW_LIMITER                                  */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_jobhistory_row_limiter...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_jobhistory_row_limiter')
              AND (type = 'P')))
  DROP PROCEDURE dbo.sp_jobhistory_row_limiter
go
CREATE PROCEDURE sp_jobhistory_row_limiter
  @job_id UNIQUEIDENTIFIER
AS
BEGIN
  DECLARE @max_total_rows         INT -- This value comes from the registry (MaxJobHistoryTableRows)
  DECLARE @max_rows_per_job       INT -- This value comes from the registry (MaxJobHistoryRows)
  DECLARE @rows_to_delete         INT
  DECLARE @rows_to_delete_as_char VARCHAR(10)
  DECLARE @current_rows           INT
  DECLARE @current_rows_per_job   INT
  DECLARE @job_id_as_char         VARCHAR(36)

  SET NOCOUNT ON

  SELECT @job_id_as_char = CONVERT(VARCHAR(36), @job_id)

  -- Get max-job-history-rows from the registry
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'JobHistoryMaxRows',
                                         @max_total_rows OUTPUT,
                                         N'no_output'

  -- Check if we are limiting sysjobhistory rows
  IF (ISNULL(@max_total_rows, -1) = -1)
    RETURN(0)

  -- Check that max_total_rows is more than 1
  IF (ISNULL(@max_total_rows, 0) < 2)
  BEGIN
    -- It isn't, so set the default to 1000 rows
    SELECT @max_total_rows = 1000
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'JobHistoryMaxRows',
                                            N'REG_DWORD',
                                            @max_total_rows
  END

  -- Get the per-job maximum number of rows to keep
  SELECT @max_rows_per_job = 0
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'JobHistoryMaxRowsPerJob',
                                         @max_rows_per_job OUTPUT,
                                         N'no_output'

  -- Check that max_rows_per_job is <= max_total_rows
  IF ((@max_rows_per_job > @max_total_rows) OR (@max_rows_per_job < 1))
  BEGIN
    -- It isn't, so default the rows_per_job to max_total_rows
    SELECT @max_rows_per_job = @max_total_rows
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'JobHistoryMaxRowsPerJob',
                                            N'REG_DWORD',
                                            @max_rows_per_job
  END

  BEGIN TRANSACTION

  SELECT @current_rows_per_job = COUNT(*)
  FROM msdb.dbo.sysjobhistory (TABLOCKX)
  WHERE (job_id = @job_id)

  -- Delete the oldest history row(s) for the job being inserted if the new row has
  -- pushed us over the per-job row limit (MaxJobHistoryRows)
  SELECT @rows_to_delete = @current_rows_per_job - @max_rows_per_job
  SELECT @rows_to_delete_as_char = CONVERT(VARCHAR, @rows_to_delete)

  IF (@rows_to_delete > 0)
  BEGIN
    EXECUTE ('DECLARE @new_oldest_id INT
              SET NOCOUNT ON
              SET ROWCOUNT ' + @rows_to_delete_as_char +
             'SELECT @new_oldest_id = instance_id
              FROM msdb.dbo.sysjobhistory
              WHERE (job_id = ''' + @job_id_as_char + ''') ' +
             'ORDER BY instance_id
              SET ROWCOUNT 0
              DELETE FROM msdb.dbo.sysjobhistory
              WHERE (job_id = ''' + @job_id_as_char + ''')' +
             '  AND (instance_id <= @new_oldest_id)')
  END

  -- Delete the oldest history row(s) if inserting the new row has pushed us over the
  -- global MaxJobHistoryTableRows limit.
  SELECT @current_rows = COUNT(*)
  FROM msdb.dbo.sysjobhistory

  SELECT @rows_to_delete = @current_rows - @max_total_rows
  SELECT @rows_to_delete_as_char = CONVERT(VARCHAR, @rows_to_delete)

  IF (@rows_to_delete > 0)
  BEGIN
    EXECUTE ('DECLARE @new_oldest_id INT
              SET NOCOUNT ON
              SET ROWCOUNT ' + @rows_to_delete_as_char +
             'SELECT @new_oldest_id = instance_id
              FROM msdb.dbo.sysjobhistory
              ORDER BY instance_id
              SET ROWCOUNT 0
              DELETE FROM msdb.dbo.sysjobhistory
              WHERE (instance_id <= @new_oldest_id)')
  END

  IF (@@trancount > 0)
    COMMIT TRANSACTION

  RETURN(0) -- Success
END
go


/**************************************************************/
/* SP_SQLAGENT_LOG_JOBHISTORY                                 */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_sqlagent_log_jobhistory...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_sqlagent_log_jobhistory')
              AND (type = 'P')))
  DROP PROCEDURE sp_sqlagent_log_jobhistory
go
CREATE PROCEDURE sp_sqlagent_log_jobhistory
  @job_id               UNIQUEIDENTIFIER,
  @step_id              INT,
  @sql_message_id       INT = 0,
  @sql_severity         INT = 0,
  @message              NVARCHAR(1024) = NULL,
  @run_status           INT, -- SQLAGENT_EXEC_X code
  @run_date             INT,
  @run_time             INT,
  @run_duration         INT,
  @operator_id_emailed  INT = 0,
  @operator_id_netsent  INT = 0,
  @operator_id_paged    INT = 0,
  @retries_attempted    INT,
  @server               NVARCHAR(30) = NULL
AS
BEGIN
  DECLARE @retval              INT
  DECLARE @job_id_as_char      VARCHAR(36)
  DECLARE @step_id_as_char     VARCHAR(10)
  DECLARE @operator_id_as_char VARCHAR(10)
  DECLARE @step_name           sysname
  DECLARE @error_severity      INT

  SET NOCOUNT ON

  IF (@server IS NULL) OR (UPPER(@server) = '(LOCAL)')
    SELECT @server = UPPER(CONVERT(NVARCHAR(30), SERVERPROPERTY('ServerName')))

  -- Check authority (only SQLServerAgent can add a history entry for a job)
  EXECUTE @retval = sp_verify_jobproc_caller @job_id = @job_id, @program_name = N'SQLAgent%'
  IF (@retval <> 0)
    RETURN(@retval)

  -- NOTE: We raise all errors as informational (sev 0) to prevent SQLServerAgent from caching
  --       the operation (if it fails) since if the operation will never run successfully we
  --       don't want it to hang around in the operation cache.
  SELECT @error_severity = 0

  -- Check job_id
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysjobs_view
                  WHERE (job_id = @job_id)))
  BEGIN
    SELECT @job_id_as_char = CONVERT(VARCHAR(36), @job_id)
    RAISERROR(14262, @error_severity, -1, 'Job', @job_id_as_char)
    RETURN(1) -- Failure
  END

  -- Check step id
  IF (@step_id <> 0) -- 0 means 'for the whole job'
  BEGIN
    SELECT @step_name = step_name
    FROM msdb.dbo.sysjobsteps
    WHERE (job_id = @job_id)
      AND (step_id = @step_id)
    IF (@step_name IS NULL)
    BEGIN
      SELECT @step_id_as_char = CONVERT(VARCHAR, @step_id)
      RAISERROR(14262, @error_severity, -1, '@step_id', @step_id_as_char)
      RETURN(1) -- Failure
    END
  END
  ELSE
    SELECT @step_name = FORMATMESSAGE(14570)

  -- Check run_status
  IF (@run_status NOT IN (0, 1, 2, 3, 4, 5)) -- SQLAGENT_EXEC_X code
  BEGIN
    RAISERROR(14266, @error_severity, -1, '@run_status', '0, 1, 2, 3, 4, 5')
    RETURN(1) -- Failure
  END

  -- Check run_date
  EXECUTE @retval = sp_verify_job_date @run_date, '@run_date', 10
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check run_time
  EXECUTE @retval = sp_verify_job_time @run_time, '@run_time', 10
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check operator_id_emailed
  IF (@operator_id_emailed <> 0)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysoperators
                    WHERE (id = @operator_id_emailed)))
    BEGIN
      SELECT @operator_id_as_char = CONVERT(VARCHAR, @operator_id_emailed)
      RAISERROR(14262, @error_severity, -1, '@operator_id_emailed', @operator_id_as_char)
      RETURN(1) -- Failure
    END
  END

  -- Check operator_id_netsent
  IF (@operator_id_netsent <> 0)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysoperators
                    WHERE (id = @operator_id_netsent)))
    BEGIN
      SELECT @operator_id_as_char = CONVERT(VARCHAR, @operator_id_netsent)
      RAISERROR(14262, @error_severity, -1, '@operator_id_netsent', @operator_id_as_char)
      RETURN(1) -- Failure
    END
  END

  -- Check operator_id_paged
  IF (@operator_id_paged <> 0)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysoperators
                    WHERE (id = @operator_id_paged)))
    BEGIN
      SELECT @operator_id_as_char = CONVERT(VARCHAR, @operator_id_paged)
      RAISERROR(14262, @error_severity, -1, '@operator_id_paged', @operator_id_as_char)
      RETURN(1) -- Failure
    END
  END

  -- Insert the history row
  INSERT INTO msdb.dbo.sysjobhistory
         (job_id,
          step_id,
          step_name,
          sql_message_id,
          sql_severity,
          message,
          run_status,
          run_date,
          run_time,
          run_duration,
          operator_id_emailed,
          operator_id_netsent,
          operator_id_paged,
          retries_attempted,
          server)
  VALUES (@job_id,
          @step_id,
          @step_name,
          @sql_message_id,
          @sql_severity,
          @message,
          @run_status,
          @run_date,
          @run_time,
          @run_duration,
          @operator_id_emailed,
          @operator_id_netsent,
          @operator_id_paged,
          @retries_attempted,
          @server)

  -- Special handling of replication jobs 
  DECLARE @job_name sysname
  DECLARE @category_id int
  SELECT  @job_name = name, @category_id = category_id from msdb.dbo.sysjobs 
	where job_id = @job_id 
  -- If misc. replication job, then update global replication status table
  IF @category_id IN (11, 12, 16, 17, 18)
  BEGIN
    -- Nothing can be done if this fails, so don't worry about the return code
    EXECUTE master.dbo.sp_MSupdate_replication_status
      @publisher = '',
      @publisher_db = '',
      @publication = '',
      @publication_type = -1,
      @agent_type = 5,
      @agent_name = @job_name,
      @status = @run_status
  END
  -- If replicatio agents (snapshot, logreader, distribution, merge, and queuereader
  -- and the step has been canceled and if we are at the distributor.
  IF @category_id in (10,13,14,15,19) and @run_status = 3 and 
	object_id('MSdistributiondbs') is not null
  BEGIN
    -- Get the database
    DECLARE @database sysname
    SELECT @database = database_name from sysjobsteps where job_id = @job_id and 
	lower(subsystem) in (N'distribution', N'logreader','snapshot',N'merge',
		N'queuereader')
    -- If the database is a distribution database
    IF EXISTS (select * from MSdistributiondbs where name = @database)
    BEGIN
	DECLARE @proc nvarchar(500)
	SELECT @proc = quotename(@database) + N'.dbo.sp_MSlog_agent_cancel'
	EXEC @proc @job_id = @job_id, @category_id = @category_id, 
		@message = @message
    END 	
  END

  -- Delete any history rows that are over the registry-defined limits
  EXECUTE msdb.dbo.sp_jobhistory_row_limiter @job_id

  RETURN(@@error) -- 0 means success
END
go

/**************************************************************/
/* SP_SQLAGENT_CHECK_MSX_VERSION                              */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_sqlagent_check_msx_version...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_sqlagent_check_msx_version')
              AND (type = 'P')))
  DROP PROCEDURE sp_sqlagent_check_msx_version
go
CREATE PROCEDURE sp_sqlagent_check_msx_version
  @required_microsoft_version INT = NULL
AS
BEGIN
  SET NOCOUNT ON

  DECLARE @msx_version          NVARCHAR(16)
  DECLARE @required_msx_version NVARCHAR(16)

  IF (@required_microsoft_version IS NULL)
    SELECT @required_microsoft_version = 0x07000252 -- 7.0.594

  IF (@@microsoftversion < @required_microsoft_version)
  BEGIN
    SELECT @msx_version = CONVERT( NVARCHAR(2), CONVERT( INT, CONVERT( BINARY(1), @@microsoftversion / 0x1000000 ) ) )
	+ N'.' 
	+ CONVERT( NVARCHAR(2), CONVERT( INT, CONVERT( BINARY(1), CONVERT( BINARY(2), ((@@microsoftversion / 0x10000) % 0x100) ) ) ) )
	+ N'.'
	+ CONVERT( NVARCHAR(4), @@microsoftversion % 0x10000 )

    SELECT @required_msx_version = CONVERT( NVARCHAR(2), CONVERT( INT, CONVERT( BINARY(1), @required_microsoft_version / 0x1000000 ) ) )
	+ N'.'
	+ CONVERT( NVARCHAR(2), CONVERT( INT, CONVERT( BINARY(1), CONVERT( BINARY(2), ((@required_microsoft_version / 0x10000) % 0x100) ) ) ) )
	+ N'.' 
	+ CONVERT( NVARCHAR(4), @required_microsoft_version % 0x10000 )    

	RAISERROR(14541, -1, -1, @msx_version, @required_msx_version)
    RETURN(1) -- Failure
  END
  RETURN(0) -- Success
END
go

/**************************************************************/
/* SP_SQLAGENT_PROBE_MSX                                      */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_sqlagent_probe_msx...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_sqlagent_probe_msx')
              AND (type = 'P')))
  DROP PROCEDURE sp_sqlagent_probe_msx
go
CREATE PROCEDURE sp_sqlagent_probe_msx
  @server_name          NVARCHAR(30),  -- The name of the target server probing the MSX
  @local_time           NVARCHAR(100), -- The local time at the target server in the format YYYY/MM/DD HH:MM:SS
  @poll_interval        INT,           -- The frequency (in seconds) with which the target polls the MSX
  @time_zone_adjustment INT = NULL     -- The offset from GMT in minutes (may be NULL if unknown)
AS
BEGIN
  DECLARE @bad_enlistment        BIT
  DECLARE @blocking_instructions INT
  DECLARE @pending_instructions  INT

  SET NOCOUNT ON

  SELECT @bad_enlistment = 0, @blocking_instructions = 0, @pending_instructions = 0

  UPDATE msdb.dbo.systargetservers
  SET last_poll_date = GETDATE(),
      local_time_at_last_poll = CONVERT(DATETIME, @local_time, 111),
      poll_interval = @poll_interval,
      time_zone_adjustment = ISNULL(@time_zone_adjustment, time_zone_adjustment)
  WHERE (server_name = @server_name)

  -- If the systargetservers entry is missing (and no DEFECT instruction has been posted)
  -- then the enlistment is bad
  IF (NOT EXISTS (SELECT 1
                  FROM msdb.dbo.systargetservers
                  WHERE (server_name = @server_name))) AND
     (NOT EXISTS (SELECT 1
                  FROM msdb.dbo.sysdownloadlist
                  WHERE (target_server = @server_name)
                    AND (operation_code = 7)
                    AND (object_type = 2)))
    SELECT @bad_enlistment = 1

  SELECT @blocking_instructions = COUNT(*)
  FROM msdb.dbo.sysdownloadlist
  WHERE (target_server = @server_name)
    AND (error_message IS NOT NULL)

  SELECT @pending_instructions = COUNT(*)
  FROM msdb.dbo.sysdownloadlist
  WHERE (target_server = @server_name)
    AND (error_message IS NULL)
    AND (status = 0)

  SELECT @bad_enlistment, @blocking_instructions, @pending_instructions
END
go

/**************************************************************/
/* SP_SET_LOCAL_TIME                                          */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_set_local_time...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_set_local_time')
              AND (type = 'P')))
  DROP PROCEDURE sp_set_local_time
go
CREATE PROCEDURE sp_set_local_time
  @server_name           NVARCHAR(30) = NULL,
  @adjustment_in_minutes INT          = 0 -- Only needed for Win9x
AS
BEGIN
  DECLARE @ret              INT
  DECLARE @local_time       INT
  DECLARE @local_date       INT
  DECLARE @current_datetime DATETIME
  DECLARE @local_time_sz    VARCHAR(30)
  DECLARE @cmd              NVARCHAR(200)
  DECLARE @date_format      NVARCHAR(64)
  DECLARE @year_sz          NVARCHAR(16)
  DECLARE @month_sz         NVARCHAR(16)
  DECLARE @day_sz           NVARCHAR(16)

  -- Synchronize the clock with the remote server (if supplied)
  -- NOTE: NT takes timezones into account, whereas Win9x does not
  IF (@server_name IS NOT NULL)
  BEGIN
    SELECT @cmd = N'net time \\' + @server_name + N' /set /y'
    EXECUTE @ret = master.dbo.xp_cmdshell @cmd, no_output
    IF (@ret <> 0)
      RETURN(1) -- Failure
  END

  -- Since NET TIME on Win9x does not take time zones into account we need to manually adjust
  -- for this using @adjustment_in_minutes which will be the difference between the MSX GMT
  -- offset and the target server GMT offset
  IF ((PLATFORM() & 0x2) = 0x2) -- Win9x
  BEGIN
    -- Get the date format from the registry (so that we can construct our DATE command-line command)
    EXECUTE master.dbo.xp_regread N'HKEY_CURRENT_USER',
                                  N'Control Panel\International',
                                  N'sShortDate',
                                  @date_format OUTPUT,
                                  N'no_output'
    SELECT @date_format = LOWER(@date_format)

    IF (@adjustment_in_minutes <> 0)
    BEGIN
      -- Wait for SQLServer to re-cache the OS time
      WAITFOR DELAY '00:01:00'

      SELECT @current_datetime = DATEADD(mi, @adjustment_in_minutes, GETDATE())
      SELECT @local_time_sz = SUBSTRING(CONVERT(VARCHAR, @current_datetime, 8), 1, 5)
      SELECT @local_time = CONVERT(INT, LTRIM(SUBSTRING(@local_time_sz, 1, PATINDEX('%:%', @local_time_sz) - 1)  + SUBSTRING(@local_time_sz, PATINDEX('%:%', @local_time_sz) + 1, 2)))
      SELECT @local_date = CONVERT(INT, CONVERT(VARCHAR, @current_datetime, 112))

      -- Set the date
      SELECT @year_sz = CONVERT(NVARCHAR, @local_date / 10000)
      SELECT @month_sz = CONVERT(NVARCHAR, (@local_date % 10000) / 100)
      SELECT @day_sz = CONVERT(NVARCHAR, @local_date % 100)

      IF (@date_format LIKE N'y%m%d')
        SELECT @cmd = N'DATE ' + @year_sz + N'-' + @month_sz + N'-' + @day_sz
      IF (@date_format LIKE N'y%d%m')
        SELECT @cmd = N'DATE ' + @year_sz + N'-' + @day_sz + N'-' + @month_sz
      IF (@date_format LIKE N'm%d%y')
        SELECT @cmd = N'DATE ' + @month_sz + N'-' + @day_sz + N'-' + @year_sz
      IF (@date_format LIKE N'd%m%y')
        SELECT @cmd = N'DATE ' + @day_sz + N'-' + @month_sz + N'-' + @year_sz

      EXECUTE @ret = master.dbo.xp_cmdshell @cmd, no_output
      IF (@ret <> 0)
        RETURN 1 -- Failure

      -- Set the time (NOTE: We can't set the millisecond part of the time, so we may be up to .999 sec off)
      SELECT @cmd = N'TIME ' + CONVERT(NVARCHAR, @local_time / 100) + N':' + CONVERT(NVARCHAR, @local_time % 100) + ':' + CONVERT(NVARCHAR(2), DATEPART(SS, GETDATE()))
      EXECUTE @ret = master.dbo.xp_cmdshell @cmd, no_output
      IF (@ret <> 0)
        RETURN 1 -- Failure
    END

  END

  RETURN(0) -- Success
END
go

/**************************************************************/
/* SP_MULTI_SERVER_JOB_SUMMARY [used by SEM only]             */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_multi_server_job_summary...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_multi_server_job_summary')
              AND (type = 'P')))
  DROP PROCEDURE sp_multi_server_job_summary
go
CREATE PROCEDURE sp_multi_server_job_summary
  @job_id   UNIQUEIDENTIFIER = NULL,
  @job_name sysname          = NULL
AS
BEGIN
  DECLARE @retval INT

  SET NOCOUNT ON

  IF ((@job_id IS NOT NULL) OR (@job_name IS NOT NULL))
  BEGIN
    EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                                '@job_id',
                                                 @job_name OUTPUT,
                                                 @job_id   OUTPUT
    IF (@retval <> 0)
      RETURN(1) -- Failure
  END

  -- NOTE: We join with syscategories - not sysjobservers - since we want to include jobs
  --       which are of type multi-server but which don't currently have any servers
  SELECT 'job_id'   = sj.job_id,
         'job_name' = sj.name,
         'enabled'  = sj.enabled,
         'category_name'  = sc.name,
         'target_servers' = (SELECT COUNT(*)
                             FROM msdb.dbo.sysjobservers sjs
                             WHERE (sjs.job_id = sj.job_id)),
         'pending_download_instructions' = (SELECT COUNT(*)
                                            FROM msdb.dbo.sysdownloadlist sdl
                                            WHERE (sdl.object_id = sj.job_id)
                                              AND (status = 0)),
         'download_errors' = (SELECT COUNT(*)
                              FROM msdb.dbo.sysdownloadlist sdl
                              WHERE (sdl.object_id = sj.job_id)
                                AND (sdl.error_message IS NOT NULL)),
         'execution_failures' = (SELECT COUNT(*)
                                 FROM msdb.dbo.sysjobservers sjs
                                 WHERE (sjs.job_id = sj.job_id)
                                   AND (sjs.last_run_date <> 0)
                                   AND (sjs.last_run_outcome <> 1)) -- 1 is success
  FROM msdb.dbo.sysjobs sj,
       msdb.dbo.syscategories sc
  WHERE (sj.category_id = sc.category_id)
    AND (sc.category_class = 1) -- JOB
    AND (sc.category_type  = 2) -- Multi-Server
    AND ((@job_id IS NULL)   OR (sj.job_id = @job_id))
    AND ((@job_name IS NULL) OR (sj.name = @job_name))

  RETURN(0) -- Success
END
go

/**************************************************************/
/* SP_TARGET_SERVER_SUMMARY [used by SEM only]                */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_target_server_summary...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_target_server_summary')
              AND (type = 'P')))
  DROP PROCEDURE sp_target_server_summary
go
CREATE PROCEDURE sp_target_server_summary
  @target_server NVARCHAR(30) = NULL
AS
BEGIN
  SET NOCOUNT ON

  SELECT server_id,
         server_name,
        'local_time' = DATEADD(SS, DATEDIFF(SS, last_poll_date, GETDATE()), local_time_at_last_poll),
         last_poll_date,
        'unread_instructions' = (SELECT COUNT(*)
                                 FROM msdb.dbo.sysdownloadlist sdl
                                 WHERE (sdl.target_server = sts.server_name)
                                   AND (sdl.status = 0)),
        'blocked' = (SELECT COUNT(*)
                     FROM msdb.dbo.sysdownloadlist sdl
                     WHERE (sdl.target_server = sts.server_name)
                       AND (sdl.error_message IS NOT NULL)),
         poll_interval
  FROM msdb.dbo.systargetservers sts
  WHERE ((@target_server IS NULL) OR (@target_server = sts.server_name))
END
go

DUMP TRANSACTION msdb WITH NO_LOG
go
CHECKPOINT
go


/**************************************************************/
/*                                                            */
/*         6  .  X     P  R  O  C  E  D  U  R  E  S           */
/*                                                            */
/* These procedures are provided for backwards compatability  */
/* with 6.x scripts and 6.x replication.  The re-implemented  */
/* procedures are as follows:                                 */
/*                                                            */
/* - sp_uniquetaskname  (SQLDMO)                              */
/* - systasks_view      (INSTDIST.SQL)                        */
/* - sp_addtask         (INSTREPL.SQL, INSTDIST.SQL, SQLDMO)  */
/* - sp_updatetask      (INSTDIST.SQL)                        */
/* - sp_droptask        (INSTREPL.SQL, INSTDIST.SQL, SQLDMO)  */
/* - sp_helptask        (INSTREPL.SQL, SQLDMO)                */
/* - sp_verifytaskid    (INSTREPL.SQL)                        */
/* - sp_reassigntask    (INSTDIST.SQL)                        */
/* - sp_helphistory     (For completeness only)               */
/* - sp_purgehistory    (For completeness only)               */
/* - systasks           (For completeness only)               */
/**************************************************************/

/**************************************************************/
/* SYSTASKS (a view to simulate the 6.x systasks table)       */
/**************************************************************/

PRINT ''
PRINT 'Creating [legacy] table systasks [as a view]...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'systasks')
              AND (type = 'U')))
  DROP TABLE systasks -- Just a precaution in case the systasks table is somehow still lingering around
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'systasks')
              AND (type = 'V')))
  DROP VIEW systasks
go
CREATE VIEW systasks
AS
  SELECT 'id'                     = sti.task_id,
         'name'                   = sj.name,
         'subsystem'              = sjst.subsystem,
         'server'                 = sjst.server,
         'username'               = sjst.database_user_name,
         'ownerloginid'           = 1, -- Always default to SA since suid is no longer available
         'databasename'           = sjst.database_name,
         'enabled'                = sj.enabled,
         'freqtype'               = ISNULL(sjsch.freq_type, 2), -- On Demand
         'freqinterval'           = ISNULL(sjsch.freq_interval, 0),
         'freqsubtype'            = ISNULL(sjsch.freq_subday_type, 0),
         'freqsubinterval'        = ISNULL(sjsch.freq_subday_interval, 0),
         'freqrelativeinterval'   = ISNULL(sjsch.freq_relative_interval, 0),
         'freqrecurrencefactor'   = ISNULL(sjsch.freq_recurrence_factor, 0),
         'activestartdate'        = ISNULL(sjsch.active_start_date, 19900101),
         'activeenddate'          = ISNULL(sjsch.active_end_date, 99991231),
         'activestarttimeofday'   = ISNULL(sjsch.active_start_time, 0),
         'activeendtimeofday'     = ISNULL(sjsch.active_end_time, 235959),
         'lastrundate'            = sjs.last_run_date,
         'lastruntime'            = sjs.last_run_time,
         'nextrundate'            = ISNULL(sjsch.next_run_date, 0),
         'nextruntime'            = ISNULL(sjsch.next_run_time, 0),
         'runpriority'            = sjst.os_run_priority,
         'emailoperatorid'        = sj.notify_email_operator_id,
         'retryattempts'          = sjst.retry_attempts,
         'retrydelay'             = sjst.retry_interval,
         'datecreated'            = sj.date_created,
         'datemodified'           = sj.date_modified,
         'command'                = sjst.command,
         'lastruncompletionlevel' = sjs.last_run_outcome,
         'lastrunduration'        = sjst.last_run_duration,
         'lastrunretries'         = sjst.last_run_retries,
         'loghistcompletionlevel' = sj.notify_level_eventlog,
         'emailcompletionlevel'   = sj.notify_level_email,
         'description'            = sj.description,
         'tagadditionalinfo'      = 0,
         'tagobjectid'            = 0,
         'tagobjecttype'          = 0,
         'parameters'             = CONVERT(TEXT, sjst.additional_parameters),
         'cmdexecsuccesscode'     = sjst.cmdexec_success_code
    FROM msdb.dbo.sysjobs                         sj
         LEFT OUTER JOIN msdb.dbo.sysjobschedules sjsch ON (sj.job_id = sjsch.job_id),
         msdb.dbo.systaskids                      sti,
         msdb.dbo.sysjobsteps                     sjst,
         msdb.dbo.sysjobservers                   sjs
    WHERE (sj.job_id = sti.job_id)
      AND (sj.job_id = sjst.job_id)
      AND (sjst.step_id = 1)
      AND (sj.job_id = sjs.job_id)
      AND (sjs.server_id = 0)
      AND ((sjsch.name = N'6.x schedule') OR (sjsch.name IS NULL)) -- NULL handles the case of the job not having a schedule
  UNION ALL -- NOTE: We do this just to make the view non-updatable
  SELECT 0, '', '', '', '', 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, GETDATE(), GETDATE(), '', 0, 0, 0, 0, 0, '', 0, 0, 0, '', 0
  WHERE (1 = 2)
go

/**************************************************************/
/* SYSTASKS_VIEW                                              */
/**************************************************************/

PRINT ''
PRINT 'Creating [legacy] view systasks_view...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'systasks_view')
              AND (type = 'V')))
  DROP VIEW systasks_view
go
CREATE VIEW systasks_view
AS
  SELECT 'id'                     = sti.task_id,
         'name'                   = sjv.name,
         'subsystem'              = sjst.subsystem,
         'server'                 = sjst.server,
         'username'               = sjst.database_user_name,
         'ownerloginid'           = 1, -- Always default to SA since suid is no longer available
         'databasename'           = sjst.database_name,
         'enabled'                = sjv.enabled,
         'freqtype'               = ISNULL(sjsch.freq_type, 2), -- On Demand
         'freqinterval'           = ISNULL(sjsch.freq_interval, 0),
         'freqsubtype'            = ISNULL(sjsch.freq_subday_type, 0),
         'freqsubinterval'        = ISNULL(sjsch.freq_subday_interval, 0),
         'freqrelativeinterval'   = ISNULL(sjsch.freq_relative_interval, 0),
         'freqrecurrencefactor'   = ISNULL(sjsch.freq_recurrence_factor, 0),
         'activestartdate'        = ISNULL(sjsch.active_start_date, 19900101),
         'activeenddate'          = ISNULL(sjsch.active_end_date, 99991231),
         'activestarttimeofday'   = ISNULL(sjsch.active_start_time, 0),
         'activeendtimeofday'     = ISNULL(sjsch.active_end_time, 235959),
         'lastrundate'            = sjs.last_run_date,
         'lastruntime'            = sjs.last_run_time,
         'nextrundate'            = ISNULL(sjsch.next_run_date, 0),
         'nextruntime'            = ISNULL(sjsch.next_run_time, 0),
         'runpriority'            = sjst.os_run_priority,
         'emailoperatorid'        = sjv.notify_email_operator_id,
         'retryattempts'          = sjst.retry_attempts,
         'retrydelay'             = sjst.retry_interval,
         'datecreated'            = sjv.date_created,
         'datemodified'           = sjv.date_modified,
         'command'                = sjst.command,
         'lastruncompletionlevel' = sjs.last_run_outcome,
         'lastrunduration'        = sjst.last_run_duration,
         'lastrunretries'         = sjst.last_run_retries,
         'loghistcompletionlevel' = sjv.notify_level_eventlog,
         'emailcompletionlevel'   = sjv.notify_level_email,
         'description'            = sjv.description,
         'tagadditionalinfo'      = 0,
         'tagobjectid'            = 0,
         'tagobjecttype'          = 0,
         'parameters'             = CONVERT(TEXT, sjst.additional_parameters),
         'cmdexecsuccesscode'     = sjst.cmdexec_success_code
    FROM msdb.dbo.sysjobs_view                    sjv
         LEFT OUTER JOIN msdb.dbo.sysjobschedules sjsch ON (sjv.job_id = sjsch.job_id),
         msdb.dbo.systaskids                      sti,
         msdb.dbo.sysjobsteps                     sjst,
         msdb.dbo.sysjobservers                   sjs
    WHERE (sjv.job_id = sti.job_id)
      AND (sjv.job_id = sjst.job_id)
      AND (sjst.step_id = 1)
      AND (sjv.job_id = sjs.job_id)
      AND (sjs.server_id = 0)
      AND ((sjsch.name = N'6.x schedule') OR (sjsch.name IS NULL)) -- NULL handles the case of the job not having a schedule
  UNION ALL -- NOTE: We do this just to make the view non-updatable
  SELECT 0, '', '', '', '', 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, GETDATE(), GETDATE(), '', 0, 0, 0, 0, 0, '', 0, 0, 0, '', 0
  WHERE (1 = 2)
go

/**************************************************************/
/* SP_UNIQUETASKNAME                                          */
/**************************************************************/

PRINT ''
PRINT 'Creating [legacy] procedure sp_uniquetaskname...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_uniquetaskname')
              AND (type = 'P')))
  DROP PROCEDURE sp_uniquetaskname
go
CREATE PROCEDURE sp_uniquetaskname
  @seed NVARCHAR(92)
AS
BEGIN
  DECLARE @newest_suffix INT

  SET NOCOUNT ON

  -- We're going to add a suffix of 8 characters so make sure the seed is at most 84 characters
  SELECT @seed = LTRIM(RTRIM(@seed))
  IF (DATALENGTH(@seed) > 0)
    SELECT @seed = SUBSTRING(@seed, 1, 84)

  -- Find the newest (highest) suffix so far
  SELECT @newest_suffix = MAX(CONVERT(INT, RIGHT(name, 8)))
  FROM msdb.dbo.sysjobs -- DON'T use sysjobs_view here!
  WHERE (name LIKE N'%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')

  -- Generate the task name by appending the 'newest suffix' value (plus one) to the seed
  IF (@newest_suffix IS NOT NULL)
  BEGIN
    SELECT @newest_suffix = @newest_suffix + 1
    SELECT 'TaskName' = CONVERT(NVARCHAR(92), @seed + REPLICATE(N'0', 8 - (DATALENGTH(CONVERT(NVARCHAR, @newest_suffix)) / 2)) + CONVERT(NVARCHAR, @newest_suffix))
  END
  ELSE
    SELECT 'TaskName' = CONVERT(NVARCHAR(92), @seed + N'00000001')
END
go

/**************************************************************/
/* SP_ADDTASK                                                 */
/**************************************************************/

PRINT ''
PRINT 'Creating [legacy] procedure sp_addtask...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_addtask')
              AND (type = 'P')))
  DROP PROCEDURE sp_addtask
go
CREATE PROCEDURE sp_addtask
  @name                   sysname,               -- Was VARCHAR(100) in 6.x
  @subsystem              NVARCHAR(40)   = N'TSQL', -- Was VARCHAR(30) in 6.x
  @server                 NVARCHAR(30)   = NULL,
  @username               sysname        = NULL, -- Was VARCHAR(30) in 6.x
  @databasename           sysname        = NULL, -- Was VARCHAR(30) in 6.x
  @enabled                TINYINT        = 0,
  @freqtype               INT            = 2,    -- 2 means OnDemand
  @freqinterval           INT            = 1,
  @freqsubtype            INT            = 1,
  @freqsubinterval        INT            = 1,
  @freqrelativeinterval   INT            = 1,
  @freqrecurrencefactor   INT            = 1,
  @activestartdate        INT            = 0,
  @activeenddate          INT            = 0,
  @activestarttimeofday   INT            = 0,
  @activeendtimeofday     INT            = 0,
  @nextrundate            INT            = 0,
  @nextruntime            INT            = 0,
  @runpriority            INT            = 0,
  @emailoperatorname      sysname        = NULL, -- Was VARCHAR(50) in 6.x
  @retryattempts          INT            = 0,
  @retrydelay             INT            = 10,
  @command                NVARCHAR(3200) = NULL, -- Was VARCHAR(255) in 6.x
  @loghistcompletionlevel INT            = 2,
  @emailcompletionlevel   INT            = 0,
  @description            NVARCHAR(512)  = NULL, -- Was VARCHAR(255) in 6.x
  @tagadditionalinfo      VARCHAR(96)    = NULL, -- Obsolete in 7.0
  @tagobjectid            INT            = NULL, -- Obsolete in 7.0
  @tagobjecttype          INT            = NULL, -- Obsolete in 7.0
  @newid                  INT            = NULL OUTPUT,
  @parameters             NTEXT          = NULL, -- Was TEXT in 6.x
  @cmdexecsuccesscode     INT            = 0,
  @category_name          sysname        = NULL, -- New for 7.0
  @category_id            INT            = NULL  -- New for 7.0
AS
BEGIN
  DECLARE @retval INT
  DECLARE @job_id UNIQUEIDENTIFIER
  DECLARE @id     INT
  DECLARE @distdb sysname
  DECLARE @proc nvarchar(255)

  SET NOCOUNT ON

  SELECT @retval = 1 -- 0 means success, 1 means failure

  -- Set 7.0 category names for 6.5 replication tasks
  IF (LOWER(@subsystem) = N'sync')
    SELECT @category_id = 15
  ELSE IF (LOWER(@subsystem) = N'logreader')
    SELECT @category_id = 13
  ELSE IF (LOWER(@subsystem) = N'distribution')
    SELECT @category_id = 10

  -- Convert old replication synchronization subsystem name to the 7.0 name
  IF (LOWER(@subsystem) = N'sync')
    SELECT @subsystem = N'Snapshot'

  -- If a category ID is provided this overrides any supplied category name
  IF (@category_id IS NOT NULL)
  BEGIN
    SELECT @category_name = name
    FROM msdb.dbo.syscategories
    WHERE (category_id = @category_id)
    SELECT @category_name = ISNULL(@category_name, FORMATMESSAGE(14205))
  END

  -- In 6.x active start date was not restricted, but it is in 7.0; so to avoid a "noisey"
  -- failure in sp_add_jobschedule we modify the value accordingly
  IF ((@activestartdate <> 0) AND (@activestartdate < 19900101))
    SELECT @activestartdate = 19900101

  BEGIN TRANSACTION

    -- Add the job
    EXECUTE @retval = sp_add_job
      @job_name                   = @name,
      @enabled                    = @enabled,
      @start_step_id              = 1,
      @description                = @description,
      @category_name              = @category_name,
      @notify_level_eventlog      = @loghistcompletionlevel,
      @notify_level_email         = @emailcompletionlevel,
      @notify_email_operator_name = @emailoperatorname,
      @job_id                     = @job_id OUTPUT

    IF (@retval <> 0)
    BEGIN
      ROLLBACK TRANSACTION
      GOTO Quit
    END

    -- Add an entry to systaskids for the new job (created by a 6.x client)
    INSERT INTO msdb.dbo.systaskids (job_id) VALUES (@job_id)

    -- Get the assigned task id
    SELECT @id = task_id, @newid = task_id
    FROM msdb.dbo.systaskids
    WHERE (job_id = @job_id)

    -- Add the job step
    EXECUTE @retval = sp_add_jobstep
      @job_id                = @job_id,
      @step_id               = 1,
      @step_name             = N'Step 1',
      @subsystem             = @subsystem,
      @command               = @command,
      @additional_parameters = @parameters,
      @cmdexec_success_code  = @cmdexecsuccesscode,
      @server                = @server,
      @database_name         = @databasename,
      @database_user_name    = @username,
      @retry_attempts        = @retryattempts,
      @retry_interval        = @retrydelay,
      @os_run_priority       = @runpriority

    IF (@retval <> 0)
    BEGIN
      ROLLBACK TRANSACTION
      GOTO Quit
    END

    -- Add the job schedule
    IF (@activestartdate = 0)
      SELECT @activestartdate = NULL
    IF (@activeenddate = 0)
      SELECT @activeenddate = NULL
    IF (@activestarttimeofday = 0)
      SELECT @activestarttimeofday = NULL
    IF (@activeendtimeofday = 0)
      SELECT @activeendtimeofday = NULL
    IF (@freqtype <> 0x2) -- OnDemand tasks simply have no schedule in 7.0
    BEGIN
      EXECUTE @retval = sp_add_jobschedule
        @job_id                 = @job_id,
        @name                   = N'6.x schedule',
        @enabled                = 1,
        @freq_type              = @freqtype,
        @freq_interval          = @freqinterval,
        @freq_subday_type       = @freqsubtype,
        @freq_subday_interval   = @freqsubinterval,
        @freq_relative_interval = @freqrelativeinterval,
        @freq_recurrence_factor = @freqrecurrencefactor,
        @active_start_date      = @activestartdate,
        @active_end_date        = @activeenddate,
        @active_start_time      = @activestarttimeofday,
        @active_end_time        = @activeendtimeofday

      IF (@retval <> 0)
      BEGIN
        ROLLBACK TRANSACTION
        GOTO Quit
      END
    END

    -- And finally, add the job server
    EXECUTE @retval = sp_add_jobserver @job_id = @job_id, @server_name = NULL

    IF (@retval <> 0)
    BEGIN
      ROLLBACK TRANSACTION
      GOTO Quit
    END

    -- Add the replication agent for monitoring
    IF (@category_id = 13) -- Logreader
    BEGIN
      SELECT @distdb = distribution_db from MSdistpublishers where name = @server
      SELECT @proc = @distdb + '.dbo.sp_MSadd_logreader_agent'

      EXECUTE @retval = @proc
        @name = @name,
        @publisher = @server,
        @publisher_db = @databasename,
        @publication = '',
        @local_job = 1,
        @job_existing = 1,
        @job_id = @job_id

      IF (@retval <> 0)
      BEGIN
        ROLLBACK TRANSACTION
        GOTO Quit
      END
    END
    ELSE
    IF (@category_id = 15) -- Snapshot
    BEGIN
      DECLARE @publication sysname

      EXECUTE @retval = master.dbo.sp_MSget_publication_from_taskname
                            @taskname = @name,
                            @publisher = @server,
                            @publisherdb = @databasename,
                            @publication = @publication OUTPUT

      IF (@publication IS NOT NULL)
      BEGIN

        SELECT @distdb = distribution_db from MSdistpublishers where name = @server
        SELECT @proc = @distdb + '.dbo.sp_MSadd_snapshot_agent'

        EXECUTE @retval = @proc
                @name = @name,
                @publisher = @server,
                @publisher_db = @databasename,
                @publication = @publication,
                @local_job = 1,
                @job_existing = 1,
                @snapshot_jobid = @job_id

        IF (@retval <> 0)
        BEGIN
          ROLLBACK TRANSACTION
          GOTO Quit
        END

        SELECT @proc = @distdb + '.dbo.sp_MSadd_publication'
        EXECUTE @retval = @proc
                @publisher = @server,
                @publisher_db = @databasename,
                @publication = @publication,
                @publication_type = 0 -- Transactional
        IF (@retval <> 0)
        BEGIN
          ROLLBACK TRANSACTION
          GOTO Quit
        END
      END
    END

  COMMIT TRANSACTION

  -- If this is an autostart LogReader or Distribution job, add the [new] '-Continuous' paramter to the command
  IF (@freqtype = 0x40) AND ((UPPER(@subsystem) = N'LOGREADER') OR (UPPER(@subsystem) = N'DISTRIBUTION'))
  BEGIN
    UPDATE msdb.dbo.sysjobsteps
    SET command = command + N' -Continuous'
    WHERE (job_id = @job_id)
      AND (step_id = 1)
  END

  -- If this is an autostart job, start it now (for backwards compatibility with 6.x SQLExecutive behaviour)
  IF (@freqtype = 0x40)
    EXECUTE msdb.dbo.sp_start_job @job_id = @job_id, @error_flag = 0, @output_flag = 0

Quit:
  RETURN(@retval) -- 0 means success

END
go

/**************************************************************/
/* SP_UPDATETASK                                              */
/**************************************************************/

PRINT ''
PRINT 'Creating [legacy] procedure sp_updatetask...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_updatetask')
              AND (type = 'P')))
  DROP PROCEDURE sp_updatetask
go
CREATE PROCEDURE sp_updatetask
  @currentname            sysname        = NULL, -- Was VARCHAR(100) in 6.x
  @id                     INT            = NULL,
  @name                   sysname        = NULL, -- Was VARCHAR(100) in 6.x
  @subsystem              NVARCHAR(40)   = NULL, -- Was VARCHAR(30) in 6.x
  @server                 NVARCHAR(30)   = NULL, -- Was VARCHAR(30) in 6.x
  @username               sysname        = NULL, -- Was VARCHAR(30) in 6.x
  @databasename           sysname        = NULL, -- Was VARCHAR(30) in 6.x
  @enabled                TINYINT        = NULL,
  @freqtype               INT            = NULL,
  @freqinterval           INT            = NULL,
  @freqsubtype            INT            = NULL,
  @freqsubinterval        INT            = NULL,
  @freqrelativeinterval   INT            = NULL,
  @freqrecurrencefactor   INT            = NULL,
  @activestartdate        INT            = NULL,
  @activeenddate          INT            = NULL,
  @activestarttimeofday   INT            = NULL,
  @activeendtimeofday     INT            = NULL,
  @nextrundate            INT            = NULL,
  @nextruntime            INT            = NULL,
  @runpriority            INT            = NULL,
  @emailoperatorname      sysname        = NULL, -- Was VARCHAR(50) in 6.x
  @retryattempts          INT            = NULL,
  @retrydelay             INT            = NULL,
  @command                NVARCHAR(3200) = NULL,
  @loghistcompletionlevel INT            = NULL,
  @emailcompletionlevel   INT            = NULL,
  @description            VARCHAR(512)   = NULL,
  @tagadditionalinfo      VARCHAR(96)    = NULL, -- Obsolete in 7.0
  @tagobjectid            INT            = NULL, -- Obsolete in 7.0
  @tagobjecttype          INT            = NULL, -- Obsolete in 7.0
  @parameters             TEXT           = NULL,
  @cmdexecsuccesscode     INT            = NULL
AS
BEGIN
  DECLARE @retval INT
  DECLARE @job_id UNIQUEIDENTIFIER

  SET NOCOUNT ON

  SELECT @retval = 1 -- 0 means success, 1 means failure

  -- Convert old replication synchronization subsystem name to the 7.0 name
  IF (LOWER(@subsystem) = N'sync')
    SELECT @subsystem = N'Snapshot'

  IF ((@id IS NULL) AND (@currentname IS NULL)) OR
     ((@id IS NOT NULL) AND (@currentname IS NOT NULL))
  BEGIN
    RAISERROR(14246, -1, -1)
    RETURN(1) -- Failure
  END

  -- In 6.x active start date was not restricted, but it is in 7.0; so to avoid a "noisey"
  -- failure in sp_update_jobschedule we modify the value accordingly
  IF ((@activestartdate IS NOT NULL) AND (@activestartdate < 19900101))
    SELECT @activestartdate = 19900101

  -- If the name is supplied, get the job_id directly from sysjobs
  IF (@currentname IS NOT NULL)
  BEGIN
    -- Check if the name is ambiguous
    IF ((SELECT COUNT(*)
         FROM msdb.dbo.sysjobs_view
         WHERE (name = @currentname)) > 1)
    BEGIN
      RAISERROR(14292, -1, -1, @currentname, '@id', '@currentname')
      RETURN(1) -- Failure
    END

    SELECT @job_id = job_id
    FROM msdb.dbo.sysjobs_view
    WHERE (name = @currentname)

    SELECT @id = task_id
    FROM msdb.dbo.systaskids
    WHERE (job_id = @job_id)

    IF (@job_id IS NULL)
    BEGIN
      RAISERROR(14262, -1, -1, '@currentname', @currentname)
      RETURN(1) -- Failure
    END
  END

  -- If the id is supplied lookup the corresponding job_id from systaskids
  IF (@id IS NOT NULL)
  BEGIN
    SELECT @job_id = job_id
    FROM msdb.dbo.systaskids
    WHERE (task_id = @id)

    -- Check that the job still exists
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysjobs_view
                    WHERE (job_id = @job_id)))
    BEGIN
      SELECT @currentname = CONVERT(NVARCHAR, @id)
      RAISERROR(14262, -1, -1, '@id', @currentname)
      RETURN(1) -- Failure
    END
  END

  -- Do the update
  BEGIN TRANSACTION

    -- Update the Job Step
    IF (@subsystem          IS NOT NULL) OR
       (@command            IS NOT NULL) OR
       (@cmdexecsuccesscode IS NOT NULL) OR
       (@server             IS NOT NULL) OR
       (@databasename       IS NOT NULL) OR
       (@username           IS NOT NULL) OR
       (@retryattempts      IS NOT NULL) OR
       (@retrydelay         IS NOT NULL) OR
       (@runpriority        IS NOT NULL)
    BEGIN
      EXECUTE @retval = sp_update_jobstep
        @job_id               = @job_id,
        @step_id              = 1,
        @subsystem            = @subsystem,
        @command              = @command,
        @cmdexec_success_code = @cmdexecsuccesscode,
        @server               = @server,
        @database_name        = @databasename,
        @database_user_name   = @username,
        @retry_attempts       = @retryattempts,
        @retry_interval       = @retrydelay,
        @os_run_priority      = @runpriority

      IF (@retval <> 0)
      BEGIN
        ROLLBACK TRANSACTION
        GOTO Quit
      END
    END

    -- Now update the job itself
    IF (@name                   IS NOT NULL) OR
       (@enabled                IS NOT NULL) OR
       (@description            IS NOT NULL) OR
       (@loghistcompletionlevel IS NOT NULL) OR
       (@emailcompletionlevel   IS NOT NULL) OR
       (@emailoperatorname      IS NOT NULL)
    BEGIN
      EXECUTE @retval = sp_update_job
        @job_id                     = @job_id,
        @new_name                   = @name,
        @enabled                    = @enabled,
        @description                = @description,
        @notify_level_eventlog      = @loghistcompletionlevel,
        @notify_level_email         = @emailcompletionlevel,
        @notify_email_operator_name = @emailoperatorname

    IF (@retval <> 0)
      BEGIN
        ROLLBACK TRANSACTION
        GOTO Quit
      END
    END

    -- Finally, update the job schedule
    IF (@freqtype             IS NOT NULL) OR
       (@freqinterval         IS NOT NULL) OR
       (@freqsubtype          IS NOT NULL) OR
       (@freqsubinterval      IS NOT NULL) OR
       (@freqrelativeinterval IS NOT NULL) OR
       (@freqrecurrencefactor IS NOT NULL) OR
       (@activestartdate      IS NOT NULL) OR
       (@activeenddate        IS NOT NULL) OR
       (@activestarttimeofday IS NOT NULL) OR
       (@activeendtimeofday   IS NOT NULL)
    BEGIN
      IF (@freqtype = 0x2)
      BEGIN
        -- OnDemand tasks simply have no schedule in 7.0, so delete the job schedule
        EXECUTE @retval = sp_delete_jobschedule
          @job_id = @job_id,
          @name   = N'6.x schedule'
      END
      ELSE
      BEGIN
        IF (NOT EXISTS (SELECT *
                        FROM msdb.dbo.sysjobschedules
                        WHERE (job_id = @job_id)
                          AND (name = N'6.x schedule')))
          EXECUTE @retval = sp_add_jobschedule
            @job_id                 = @job_id,
            @name                   = N'6.x schedule',
            @enabled                = 1,
            @freq_type              = @freqtype,
            @freq_interval          = @freqinterval,
            @freq_subday_type       = @freqsubtype,
            @freq_subday_interval   = @freqsubinterval,
            @freq_relative_interval = @freqrelativeinterval,
            @freq_recurrence_factor = @freqrecurrencefactor,
            @active_start_date      = @activestartdate,
            @active_end_date        = @activeenddate,
            @active_start_time      = @activestarttimeofday,
            @active_end_time        = @activeendtimeofday
        ELSE
          EXECUTE @retval = sp_update_jobschedule
            @job_id                 = @job_id,
            @name                   = N'6.x schedule',
            @enabled                = 1,
            @freq_type              = @freqtype,
            @freq_interval          = @freqinterval,
            @freq_subday_type       = @freqsubtype,
            @freq_subday_interval   = @freqsubinterval,
            @freq_relative_interval = @freqrelativeinterval,
            @freq_recurrence_factor = @freqrecurrencefactor,
            @active_start_date      = @activestartdate,
            @active_end_date        = @activeenddate,
            @active_start_time      = @activestarttimeofday,
            @active_end_time        = @activeendtimeofday
      END

      IF (@retval <> 0)
      BEGIN
        ROLLBACK TRANSACTION
        GOTO Quit
      END
    END

  COMMIT TRANSACTION

Quit:
  RETURN(@retval) -- 0 means success

END
go

/**************************************************************/
/* SP_DROPTASK                                                */
/**************************************************************/

PRINT ''
PRINT 'Creating [legacy] procedure sp_droptask...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_droptask')
              AND (type = 'P')))
  DROP PROCEDURE sp_droptask
go
CREATE PROCEDURE sp_droptask
  @name      sysname = NULL, -- Was VARCHAR(100) in 6.x
  @loginname sysname = NULL, -- Was VARCHAR(30) in 6.x
  @id        INT     = NULL
AS
BEGIN
  DECLARE @retval INT
  DECLARE @job_id UNIQUEIDENTIFIER
  DECLARE @category_id int

  SET NOCOUNT ON

  IF ((@name      IS NULL)     AND (@id    IS NULL)     AND (@loginname IS NULL)) OR
     ((@name      IS NOT NULL) AND ((@id   IS NOT NULL) OR  (@loginname IS NOT NULL))) OR
     ((@id        IS NOT NULL) AND ((@name IS NOT NULL) OR  (@loginname IS NOT NULL))) OR
     ((@loginname IS NOT NULL) AND ((@name IS NOT NULL) OR  (@id        IS NOT NULL)))
  BEGIN
    RAISERROR(14245, -1, -1)
    RETURN(1) -- Failure
  END

  -- If the name is supplied, get the job_id directly from sysjobs
  IF (@name IS NOT NULL)
  BEGIN
    -- Check if the name is ambiguous
    IF ((SELECT COUNT(*)
         FROM msdb.dbo.sysjobs_view
         WHERE (name = @name)) > 1)
    BEGIN
      RAISERROR(14292, -1, -1, @name, '@id', '@name')
      RETURN(1) -- Failure
    END

    SELECT @job_id = job_id, @category_id = category_id
    FROM msdb.dbo.sysjobs_view
    WHERE (name = @name)

    SELECT @id = task_id
    FROM msdb.dbo.systaskids
    WHERE (job_id = @job_id)

    IF (@job_id IS NULL)
    BEGIN
      RAISERROR(14262, -1, -1, '@name', @name)
      RETURN(1) -- Failure
    END
  END

  -- If the id is supplied lookup the corresponding job_id from systaskids
  IF (@id IS NOT NULL)
  BEGIN
    SELECT @job_id = job_id
    FROM msdb.dbo.systaskids
    WHERE (task_id = @id)

    -- Check that the job still exists
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysjobs_view
                    WHERE (job_id = @job_id)))
    BEGIN
      SELECT @name = CONVERT(NVARCHAR, @id)
      RAISERROR(14262, -1, -1, '@id', @name)
      RETURN(1) -- Failure
    END

    -- Get the name of this job
    SELECT @name = name, @category_id = category_id
    FROM msdb.dbo.sysjobs_view
    WHERE (job_id = @job_id)
  END

  -- Delete the specific job
  IF (@name IS NOT NULL)
  BEGIN
    BEGIN TRANSACTION

    DELETE FROM msdb.dbo.systaskids
    WHERE (job_id = @job_id)
    EXECUTE @retval = sp_delete_job @job_id = @job_id
    IF (@retval <> 0)
	BEGIN
      ROLLBACK TRANSACTION
	  GOTO Quit
	END

	-- If a Logreader or Snapshot task, delete corresponding replication agent information
	IF @category_id = 13 or @category_id = 15
	BEGIN
   	  EXECUTE @retval = sp_MSdrop_6x_replication_agent @job_id, @category_id
	  IF (@retval <> 0)
	  BEGIN
	  	ROLLBACK TRANSACTION
	  	GOTO Quit
	  END
	END


    COMMIT TRANSACTION
  END

  -- Delete all jobs belonging to the specified login
  IF (@loginname IS NOT NULL)
  BEGIN
    BEGIN TRANSACTION

    DELETE FROM msdb.dbo.systaskids
    WHERE job_id IN (SELECT job_id
                     FROM msdb.dbo.sysjobs_view
                     WHERE (owner_sid = SUSER_SID(@loginname)))
    EXECUTE @retval = sp_manage_jobs_by_login @action = 'DELETE',
                                              @current_owner_login_name = @loginname
    IF (@retval <> 0)
    BEGIN
      ROLLBACK TRANSACTION
      GOTO Quit
    END		

    COMMIT TRANSACTION
  END

Quit:
  RETURN(@retval) -- 0 means success

END
go


/**************************************************************/
/* SP_HELPTASK                                                */
/**************************************************************/

PRINT ''
PRINT 'Creating [legacy] procedure procedure sp_helptask...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_helptask')
              AND (type = 'P')))
  DROP PROCEDURE sp_helptask
go
CREATE PROCEDURE sp_helptask
  @taskname     sysname      = NULL, -- Was VARCHAR(100) in 6.x
  @taskid       INT          = NULL,
  @loginname    sysname      = NULL, -- Was VARCHAR(20) in 6.x
  @operatorname sysname      = NULL, -- Was VARCHAR(50) in 6.x
  @subsystem    NVARCHAR(40) = NULL, -- Was VARCHAR(30) in 6.x
  @mode         VARCHAR(10)  = 'QUICK'  -- Or 'FULL'
AS
BEGIN
  DECLARE @operator_id INT
  DECLARE @owner_sid   VARBINARY(85)

  SET NOCOUNT ON

  -- Convert old replication synchronization subsystem name to the 7.0 name
  IF (LOWER(@subsystem) = N'sync')
    SELECT @subsystem = N'Snapshot'

  -- Get the login id for the login name (if supplied)
  IF (@loginname IS NOT NULL)
  BEGIN
    IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 0) AND (SUSER_SNAME() <> @loginname)
    BEGIN
      RAISERROR(14247, -1, -1)
      RETURN(1) -- Failure
    END

    SELECT @owner_sid = SUSER_ID(@loginname)
    IF (@owner_sid IS NULL)
    BEGIN
      RAISERROR(14234, -1, -1, '@loginname', 'sp_helplogins')
      RETURN(1) -- Failure
    END
  END

  -- Get the operator id for the operator name (if supplied)
  IF (@operatorname IS NOT NULL)
  BEGIN
    SELECT @operator_id = id
    FROM msdb.dbo.sysoperators
    WHERE (name = @operatorname)

    IF (@operator_id IS NULL)
    BEGIN
      RAISERROR(14262, -1, -1, '@operatorname', @operatorname)
      RETURN(1) -- Failure
    END
  END

  -- Check the mode
  SELECT @mode = UPPER(@mode)
  IF (@mode NOT IN ('FULL', 'QUICK'))
  BEGIN
    RAISERROR(14266, -1, -1, '@mode', 'FULL, QUICK')
    RETURN(1) -- Failure
  END

  -- Return task details...
  -- NOTE: SQLOLE and Starfighter rely on the 'FULL' mode format - do not change it!
  IF (@mode = 'FULL')
  BEGIN
    SELECT name                   = sjv.name,
           id                     = sti.task_id,
           subsystem              = sjst.subsystem,
           server                 = sjst.server,
           username               = sjst.database_user_name,
           ownerloginname         = SUSER_SNAME(sjv.owner_sid),
           databasename           = sjst.database_name,
           enabled                = sjv.enabled,
           freqtype               = ISNULL(sjsch.freq_type, 2), -- On Demand
           freqinterval           = ISNULL(sjsch.freq_interval, 0),
           freqsubtype            = ISNULL(sjsch.freq_subday_type, 0),
           freqsubinterval        = ISNULL(sjsch.freq_subday_interval, 0),
           freqrelativeinterval   = ISNULL(sjsch.freq_relative_interval, 0),
           freqrecurrencefactor   = ISNULL(sjsch.freq_recurrence_factor, 0),
           activestartdate        = ISNULL(sjsch.active_start_date, 19900101),
           activeenddate          = ISNULL(sjsch.active_end_date, 99991231),
           activestarttimeofday   = ISNULL(sjsch.active_start_time, 0),
           activeendtimeofday     = ISNULL(sjsch.active_end_time, 235959),
           lastrundate            = sjs.last_run_date,
           lastruntime            = sjs.last_run_time,
           nextrundate            = ISNULL(sjsch.next_run_date, 0),
           nextruntime            = ISNULL(sjsch.next_run_time, 0),
           runpriority            = sjst.os_run_priority,
           emailoperatorname      = so.name,
           retryattempts          = sjst.retry_attempts,
           retrydelay             = sjst.retry_interval,
           datecreated            = sjv.date_created,
           datemodified           = sjv.date_modified,
           command                = sjst.command,
           lastruncompletionlevel = sjs.last_run_outcome,
           lastrunduration        = sjst.last_run_duration,
           lastrunretries         = sjst.last_run_retries,
           loghistcompletionlevel = sjv.notify_level_eventlog,
           emailcompletionlevel   = sjv.notify_level_email,
           description            = sjv.description,
           tagadditionalinfo      = 0,
           tagobjectid            = 0,
           tagobjecttype          = 0,
           cmdexecsuccesscode     = sjst.cmdexec_success_code
    FROM msdb.dbo.sysjobs_view                    sjv
         LEFT OUTER JOIN msdb.dbo.sysoperators    so    ON (sjv.notify_email_operator_id = so.id)
         LEFT OUTER JOIN msdb.dbo.systaskids      sti   ON (sjv.job_id = sti.job_id)
         LEFT OUTER JOIN msdb.dbo.sysjobschedules sjsch ON (sjv.job_id = sjsch.job_id),
         msdb.dbo.sysjobsteps                     sjst,
         msdb.dbo.sysjobservers                   sjs
    WHERE (sjv.job_id = sjst.job_id)
      AND (sjst.step_id = 1)
      AND (sjv.job_id = sjs.job_id)
      AND (sjs.server_id = 0)
      AND ((sjsch.name = N'6.x schedule') OR (sjsch.name IS NULL)) -- NULL handles the case of the job not having a schedule
      AND ((@owner_sid      IS NULL) OR (sjv.owner_sid                = @owner_sid))
      AND ((@subsystem      IS NULL) OR (sjst.subsystem               = @subsystem))
      AND ((@operator_id    IS NULL) OR (sjv.notify_email_operator_id = @operator_id))
      AND ((@taskname       IS NULL) OR (sjv.name                     = @taskname))
      AND ((@taskid         IS NULL) OR (sti.task_id                  = @taskid))
    ORDER BY sj.name
  END
  ELSE
  BEGIN
    SELECT name      = SUBSTRING(sjv.name, 1, 20),
           id        = sti.task_id,
           subsystem = SUBSTRING(sjst.subsystem, 1, 15),
           server    = SUBSTRING(sjst.server, 1, 20),
           username  = SUBSTRING(sjst.database_user_name, 1, 20),
           dbname    = SUBSTRING(sjst.database_name, 1, 20),
           enabled   = sjv.enabled
    FROM msdb.dbo.sysjobs_view               sjv
         LEFT OUTER JOIN msdb.dbo.systaskids sti ON (sjv.job_id = sti.job_id),
         msdb.dbo.sysjobsteps                sjst
    WHERE (sjv.job_id = sjst.job_id)
      AND (sjst.step_id = 1)
      AND ((@owner_sid      IS NULL) OR (sjv.owner_sid                = @owner_sid))
      AND ((@subsystem      IS NULL) OR (sjst.subsystem               = @subsystem))
      AND ((@operator_id    IS NULL) OR (sjv.notify_email_operator_id = @operator_id))
      AND ((@taskname       IS NULL) OR (sjv.name                     = @taskname))
      AND ((@taskid         IS NULL) OR (sti.task_id                  = @taskid))
    ORDER BY sjv.name
  END
END
go

DUMP TRANSACTION msdb WITH NO_LOG
go
CHECKPOINT
go

/**************************************************************/
/* SP_VERIFYTASKID                                            */
/**************************************************************/

PRINT ''
PRINT 'Creating [legacy] procedure procedure sp_verifytaskid...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_verifytaskid')
              AND (type = 'P')))
  DROP PROCEDURE sp_verifytaskid
go
CREATE PROCEDURE sp_verifytaskid
  @taskid    INT,
  @subsystem NVARCHAR(40) = N'%'
AS
BEGIN
  SET NOCOUNT ON

  -- Convert old replication synchronization subsystem name to the 7.0 name
  IF (LOWER(@subsystem) = N'sync')
    SELECT @subsystem = N'Snapshot'

  -- Check if the task [job] exists
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysjobs_view sjv,
                   msdb.dbo.sysjobsteps  sjst,
                   msdb.dbo.systaskids   sti
              WHERE (sjv.job_id = sjst.job_id)
                AND (sjv.job_id = sti.job_id)
                AND (sti.task_id = @taskid)
                AND (LOWER(sjst.subsystem) LIKE LOWER(@subsystem))))
    RETURN(0) -- Success
  ELSE
    RETURN(1) -- Failure
END
go

/**************************************************************/
/* SP_REASSIGNTASK                                            */
/**************************************************************/

PRINT ''
PRINT 'Creating [legacy] procedure sp_reassigntask...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_reassigntask')
              AND (type = 'P')))
  DROP PROCEDURE sp_reassigntask
go
CREATE PROCEDURE sp_reassigntask
  @taskname     sysname = NULL, -- Was VARCHAR(100) in 6.x
  @newloginname sysname,        -- Was VARCHAR(30) in 6.x
  @oldloginname sysname = NULL  -- Was VARCHAR(30) in 6.x
AS
BEGIN
  DECLARE @retval INT

  SET NOCOUNT ON

  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(14244, -1, -1)
    RETURN(1) -- Failure
  END

  -- Check that we have either task or old login name (or both, though it's redundant)
  IF ((@taskname IS NULL) AND (@oldloginname IS NULL))
  BEGIN
    RAISERROR(14249, -1, -1)
    RETURN(1) -- Failure
  END

  -- Case [1]: Reassign a specific task [job]...
  IF (@taskname IS NOT NULL)
  BEGIN
    -- Check new login id
    IF (SUSER_ID(@newloginname) IS NULL)
    BEGIN
      RAISERROR(14262, -1, -1, '@newloginname', @newloginname)
      RETURN(1) -- Failure
    END

    -- NOTE: Normally we'd invoke sp_update_job by supplying the job_id, but since this is
    --       a legacy procedure we cannot change the parameter list to have the job_id
    --       supplied to us.  Hence we use name and we run the risk of a [handled] error
    --       if the task [job] name is not unique.
    EXECUTE @retval = sp_update_job @job_name = @taskname, @owner_login_name = @newloginname
    RETURN(@retval) -- 0 means success
  END

  -- Case [2]: Reassign all jobs belonging to the specified old login name...
  IF (@oldloginname IS NOT NULL)
  BEGIN
    EXECUTE @retval = sp_manage_jobs_by_login @action = 'REASSIGN',
                                              @current_owner_login_name = @oldloginname,
                                              @new_owner_login_name = @newloginname
    RETURN(@retval) -- 0 means success
  END
END
go

/**************************************************************/
/* SP_HELPHISTORY (Replication doesn't need this - It is here */
/* for completeness only)                                     */
/**************************************************************/

PRINT ''
PRINT 'Creating [legacy] procedure sp_helphistory...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_helphistory')
              AND (type = 'P')))
  DROP PROCEDURE sp_helphistory
go
CREATE PROCEDURE sp_helphistory
  @taskname            sysname     = NULL,   -- Was VARCHAR(100) in 6.x
  @taskid              INT         = NULL,
  @eventid             INT         = NULL,
  @messageid           INT         = NULL,
  @severity            INT         = NULL,
  @source              VARCHAR(30) = NULL,   -- Obsolete in 7.0
  @category            VARCHAR(30) = NULL,   -- Obsolete in 7.0
  @startdate           INT         = NULL,   -- YYYYMMDD format
  @enddate             INT         = NULL,   -- YYYYMMDD format
  @starttime           INT         = NULL,   -- HHMMSS format
  @endtime             INT         = NULL,   -- HHMMSS format
  @minimumtimesskipped INT         = NULL,
  @minimumrunduration  INT         = NULL,   -- HHMMSS format
  @runstatusmask       INT         = NULL,   -- SQLOLE_COMPLETION_STATUS
  @minimumretries      INT         = NULL,
  @oldestfirst         INT         = NULL,
  @mode                VARCHAR(10) = 'QUICK' -- Or FULL
AS
BEGIN
  DECLARE @job_id   UNIQUEIDENTIFIER
  DECLARE @order_by INT

  SET NOCOUNT ON

  -- If the name is supplied, get the job_id directly from sysjobs
  IF (@taskname IS NOT NULL)
  BEGIN
    SELECT @job_id = job_id
    FROM msdb.dbo.sysjobs_view
    WHERE (name = @taskname)

    -- Check if the name is ambiguous
    IF (@@rowcount > 1)
    BEGIN
      RAISERROR(14292, -1, -1, @taskname, '@taskid', '@taskname')
      RETURN(1) -- Failure
    END

    IF (@job_id IS NULL)
    BEGIN
      RAISERROR(14262, -1, -1, '@taskname', @taskname)
      RETURN(1) -- Failure
    END
  END

  -- If the id is supplied lookup the corresponding job_id from systaskids
  IF (@taskid IS NOT NULL)
  BEGIN
    SELECT @job_id = job_id
    FROM msdb.dbo.systaskids
    WHERE (task_id = @taskid)

    -- Check that the job still exists
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysjobs_view
                    WHERE (job_id = @job_id)))
    BEGIN
      SELECT @taskname = CONVERT(NVARCHAR, @taskid)
      RAISERROR(14262, -1, -1, '@taskid', @taskname)
      RETURN(1) -- Failure
    END
  END

  SELECT @mode = UPPER(@mode)
  IF (@mode = 'QUICK')
    SELECT @mode = 'SUMMARY'

  CREATE TABLE #task_history_full
  (
  instance_id       INT              NOT NULL,
  job_id            UNIQUEIDENTIFIER NOT NULL,
  job_name          sysname          COLLATE database_default NOT NULL,
  step_id           INT              NOT NULL,
  step_name         sysname          COLLATE database_default NOT NULL,
  sql_message_id    INT              NOT NULL,
  sql_severity      INT              NOT NULL,
  message           NVARCHAR(1024)   COLLATE database_default NULL,
  run_status        INT              NOT NULL,
  run_date          INT              NOT NULL,
  run_time          INT              NOT NULL,
  run_duration      INT              NOT NULL,
  operator_emailed  sysname          COLLATE database_default NULL,
  operator_netsent  sysname          COLLATE database_default NULL,
  operator_paged    sysname          COLLATE database_default NULL,
  retries_attempted INT              NOT NULL,
  server            NVARCHAR(30)     COLLATE database_default NOT NULL
  )

  CREATE TABLE #task_history_quick
  (
  job_id            UNIQUEIDENTIFIER NOT NULL,
  job_name          sysname          COLLATE database_default NOT NULL,
  run_status        INT              NOT NULL,
  run_date          INT              NOT NULL,
  run_time          INT              NOT NULL,
  run_duration      INT              NOT NULL,
  operator_emailed  sysname          COLLATE database_default NULL,
  operator_netsent  sysname          COLLATE database_default NULL,
  operator_paged    sysname          COLLATE database_default NULL,
  retries_attempted INT              NOT NULL,
  server            NVARCHAR(30)     COLLATE database_default NOT NULL
  )

  IF (@mode = 'FULL')
  BEGIN
    INSERT INTO #task_history_full
    EXECUTE msdb.dbo.sp_help_jobhistory  @job_id               = @job_id,
                                         @sql_message_id       = @messageid,
                                         @sql_severity         = @severity,
                                         @start_run_date       = @startdate,
                                         @end_run_date         = @enddate,
                                         @start_run_time       = @starttime,
                                         @end_run_time         = @endtime,
                                         @minimum_run_duration = @minimumrunduration,
                                         @run_status           = @runstatusmask,
                                         @minimum_retries      = @minimumretries,
                                         @oldest_first         = @oldestfirst,
                                         @mode                 = @mode
  END
  ELSE
  BEGIN
    INSERT INTO #task_history_quick
    EXECUTE msdb.dbo.sp_help_jobhistory  @job_id               = @job_id,
                                         @sql_message_id       = @messageid,
                                         @sql_severity         = @severity,
                                         @start_run_date       = @startdate,
                                         @end_run_date         = @enddate,
                                         @start_run_time       = @starttime,
                                         @end_run_time         = @endtime,
                                         @minimum_run_duration = @minimumrunduration,
                                         @run_status           = @runstatusmask,
                                         @minimum_retries      = @minimumretries,
                                         @oldest_first         = @oldestfirst,
                                         @mode                 = @mode
  END

  IF (@mode = 'FULL')
  BEGIN
    SELECT id                = sti.task_id,
           eventid           = 0,
           messageid         = sql_message_id,
           severity          = sql_severity,
           taskname          = job_name,
           source            = '',
           category          = '',
           runstatus         = run_status,
           rundate           = run_date,
           runtime           = run_time,
           runduration       = run_duration,
           reviewstatus      = 0,
           emailoperatorname = operator_emailed,
           retries           = retries_attempted,
           comments          = message,
           timesskipped      = 0
    FROM #task_history_full thf,
         systaskids         sti
    WHERE (thf.job_id = sti.job_id)
  END
  ELSE
  BEGIN
    SELECT taskname          = job_name,
           source            = '',
           runstatus         = run_status,
           rundate           = run_date,
           runtime           = run_time,
           runduration       = run_duration,
           emailoperatorname = operator_emailed,
           retries           = retries_attempted
    FROM #task_history_quick
  END
END
go

/**************************************************************/
/* SP_PURGEHISTORY (Replication doesn't need this - It is     */
/* here for completeness only)                                */
/**************************************************************/

PRINT ''
PRINT 'Creating [legacy] procedure sp_purgehistory...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_purgehistory')
              AND (type = 'P')))
  DROP PROCEDURE sp_purgehistory
go
CREATE PROCEDURE sp_purgehistory
  @taskname sysname = NULL, -- Was VARCHAR(100) in 6.x
  @taskid   INT     = NULL
AS
BEGIN
  DECLARE @job_id UNIQUEIDENTIFIER

  SET NOCOUNT ON

  -- If the name is supplied, get the job_id directly from sysjobs
  IF (@taskname IS NOT NULL)
  BEGIN
    SELECT @job_id = job_id
    FROM msdb.dbo.sysjobs_view
    WHERE (name = @taskname)

    -- Check if the name is ambiguous
    IF (@@rowcount > 1)
    BEGIN
      RAISERROR(14292, -1, -1, @taskname, '@taskid', '@taskname')
      RETURN(1) -- Failure
    END

    IF (@job_id IS NULL)
    BEGIN
      RAISERROR(14262, -1, -1, '@taskname', @taskname)
      RETURN(1) -- Failure
    END
  END

  -- If the id is supplied lookup the corresponding job_id from systaskids
  IF (@taskid IS NOT NULL)
  BEGIN
    SELECT @job_id = job_id
    FROM msdb.dbo.systaskids
    WHERE (task_id = @taskid)

    -- Check that the job still exists
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysjobs_view
                    WHERE (job_id = @job_id)))
    BEGIN
      SELECT @taskname = CONVERT(NVARCHAR, @taskid)
      RAISERROR(14262, -1, -1, '@taskid', @taskname)
      RETURN(1) -- Failure
    END
  END

  EXECUTE sp_purge_jobhistory @job_id = @job_id
END
go


/**************************************************************/
/*                                                            */
/*         E  R  R  O  R    M  E  S  S  A  G  E  S            */
/*                                                            */
/*  These are now created by MESSAGES.SQL.                    */
/*                                                            */
/*  NOTE: 14255 and 14265 are called by dynamic SQL generated */
/*        by SQLServerAgent.                                  */
/**************************************************************/


/**************************************************************/
/*                                                            */
/*                   T  R  I  G  G  E  R  S                   */
/*                                                            */
/**************************************************************/

/**************************************************************/
/* TRIG_TARGETSERVER_INSERT                                   */
/**************************************************************/

PRINT ''
PRINT 'Creating trigger trig_targetserver_insert...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'trig_targetserver_insert')
              AND (type = 'TR')))
  DROP TRIGGER dbo.trig_targetserver_insert
go
CREATE TRIGGER trig_targetserver_insert
ON msdb.dbo.systargetservers
FOR INSERT, DELETE
AS
BEGIN
  SET NOCOUNT ON

  -- Disallow the insert if the server is called 'ALL'
  -- NOTE: We have to do this check here in the trigger since there is no sp_add_targetserver
  --       (target servers insert a row for themselves when they 'enlist' in an MSX)
  IF (EXISTS (SELECT *
              FROM inserted
              WHERE (server_name = N'ALL')))
  BEGIN
    DELETE FROM msdb.dbo.systargetservers
    WHERE (server_name = N'ALL')
    RAISERROR(14271, -1, -1, 'ALL')
    RETURN
  END

  -- Set (or delete) the registy flag (so that SETUP can detect if we're an MSX)
  IF ((SELECT COUNT(*)
       FROM msdb.dbo.systargetservers) = 0)
  BEGIN
    DECLARE @val INT

    EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                           N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                           N'MSXServer',
                                           @val OUTPUT,
                                           N'no_output'
    IF (@val IS NOT NULL)
      EXECUTE master.dbo.xp_instance_regdeletevalue N'HKEY_LOCAL_MACHINE',
                                                    N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                                    N'MSXServer'
  END
  ELSE
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'MSXServer',
                                            N'REG_DWORD',
                                            1
END
go

DUMP TRANSACTION msdb WITH NO_LOG
go
CHECKPOINT
go



/**************************************************************/
/**                                                          **/
/**          A L E R T S  A N D  O P E R A T O R S           **/
/**                                                          **/
/**************************************************************/

/**************************************************************/
/*                                                            */
/*        C  O  R  E     P  R  O  C  E  D  U  R  E  S         */
/*                                                            */
/**************************************************************/

DUMP TRANSACTION msdb WITH NO_LOG
go

/**************************************************************/
/* SP_VERIFY_PERFORMANCE_CONDITION                            */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_verify_performance_condition...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_verify_performance_condition')
              AND (type = 'P')))
  DROP PROCEDURE sp_verify_performance_condition
go
CREATE PROCEDURE sp_verify_performance_condition
  @performance_condition NVARCHAR(512)
AS
BEGIN
  DECLARE @delimiter_count INT
  DECLARE @temp_str        NVARCHAR(512)
  DECLARE @object_name     sysname
  DECLARE @counter_name    sysname
  DECLARE @instance_name   sysname
  DECLARE @pos             INT

  SET NOCOUNT ON

  -- The performance condition must have the format 'object|counter|instance|comparator|value'
  -- NOTE: 'instance' may be empty.
  IF (PATINDEX(N'%_|%_|%|[><=]|[0-9]%', @performance_condition) = 0)
  BEGIN
    RAISERROR(14507, 16, 1)
    RETURN(1) -- Failure
  END

  -- Parse the performance_condition
  SELECT @delimiter_count = 0
  SELECT @temp_str = @performance_condition
  SELECT @pos = CHARINDEX(N'|', @temp_str)
  WHILE (@pos <> 0)
  BEGIN
    SELECT @delimiter_count = @delimiter_count + 1
    IF (@delimiter_count = 1) SELECT @object_name = SUBSTRING(@temp_str, 1, @pos - 1)
    IF (@delimiter_count = 2) SELECT @counter_name = SUBSTRING(@temp_str, 1, @pos - 1)
    IF (@delimiter_count = 3) SELECT @instance_name = SUBSTRING(@temp_str, 1, @pos - 1)
    SELECT @temp_str = SUBSTRING(@temp_str, @pos + 1, (DATALENGTH(@temp_str) / 2) - @pos)
    SELECT @pos = CHARINDEX(N'|', @temp_str)
  END
  IF (@delimiter_count <> 4)
  BEGIN
    RAISERROR(14507, 16, 1)
    RETURN(1) -- Failure
  END

  -- Check the object_name
  IF (NOT EXISTS (SELECT *
                  FROM master.dbo.sysperfinfo
                  WHERE (object_name = @object_name)))
  BEGIN
    RAISERROR(14262, 16, 1, 'object_name', @object_name)
    RETURN(1) -- Failure
  END

  -- Check the counter_name
  IF (NOT EXISTS (SELECT *
                  FROM master.dbo.sysperfinfo
                  WHERE (object_name = @object_name)
                    AND (counter_name = @counter_name)))
  BEGIN
    RAISERROR(14262, 16, 1, 'counter_name', @counter_name)
    RETURN(1) -- Failure
  END

  -- Check the instance_name
  IF (@instance_name IS NOT NULL)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM master.dbo.sysperfinfo
                    WHERE (object_name = @object_name)
                      AND (counter_name = @counter_name)
                      AND (instance_name = @instance_name)))
    BEGIN
      RAISERROR(14262, 16, 1, 'instance_name', @instance_name)
      RETURN(1) -- Failure
    END
  END

  RETURN(0) -- Success
END
go

/**************************************************************/
/* SP_VERIFY_ALERT                                            */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_verify_alert...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_verify_alert')
              AND (type = 'P')))
  DROP PROCEDURE sp_verify_alert
go
CREATE PROCEDURE sp_verify_alert
  @name                          sysname,
  @message_id                    INT,
  @severity                      INT,
  @enabled                       TINYINT,
  @delay_between_responses       INT,
  @notification_message          NVARCHAR(512),
  @include_event_description_in  TINYINT,
  @database_name                 sysname,
  @event_description_keyword     NVARCHAR(100),
  @job_id                        UNIQUEIDENTIFIER OUTPUT,
  @job_name                      sysname          OUTPUT,
  @occurrence_count              INT,
  @raise_snmp_trap               TINYINT,
  @performance_condition         NVARCHAR(512),
  @category_name                 sysname,
  @category_id                   INT              OUTPUT,
  @count_reset_date              INT,
  @count_reset_time              INT
AS
BEGIN
  DECLARE @retval               INT
  DECLARE @non_alertable_errors VARCHAR(512)
  DECLARE @message_id_as_string VARCHAR(10)
  DECLARE @res_valid_range      NVARCHAR(100)

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @name                      = LTRIM(RTRIM(@name))
  SELECT @notification_message      = LTRIM(RTRIM(@notification_message))
  SELECT @database_name             = LTRIM(RTRIM(@database_name))
  SELECT @event_description_keyword = LTRIM(RTRIM(@event_description_keyword))
  SELECT @job_name                  = LTRIM(RTRIM(@job_name))
  SELECT @performance_condition     = LTRIM(RTRIM(@performance_condition))
  SELECT @category_name             = LTRIM(RTRIM(@category_name))

  -- Only a sysadmin can do this
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  -- Check if the NewName is unique
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysalerts
              WHERE (name = @name)))
  BEGIN
    RAISERROR(14261, 16, 1, '@name', @name)
    RETURN(1) -- Failure
  END

  -- Check if the user has supplied MessageID OR Severity OR Performance-Condition
  IF ((@performance_condition IS NULL)     AND ((@message_id = 0) AND (@severity = 0)) OR ((@message_id <> 0) AND (@severity <> 0))) OR
     ((@performance_condition IS NOT NULL) AND ((@message_id <> 0) OR (@severity <> 0)))
  BEGIN
    RAISERROR(14500, 16, 1)
    RETURN(1) -- Failure
  END

  -- Check the Severity
  IF ((@severity < 0) OR (@severity > 25))
  BEGIN
    RAISERROR(14266, 16, 1, '@severity', '0..25')
    RETURN(1) -- Failure
  END

  -- Check the MessageID
  IF (@message_id <> 0) AND
     (NOT EXISTS (SELECT error
                  FROM master.dbo.sysmessages
                  WHERE (error = @message_id)))
  BEGIN
    SELECT @message_id_as_string = CONVERT(VARCHAR, @message_id)
    RAISERROR(14262, 16, 1, '@message_id', @message_id_as_string)
    RETURN(1) -- Failure
  END

  -- Check if it is legal to set an alert on this MessageID
  CREATE TABLE #TempRetVal (RetVal INT)
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'NonAlertableErrors',
                                         @non_alertable_errors OUTPUT,
                                         N'no_output'
  IF (ISNULL(@non_alertable_errors, N'NULL') <> N'NULL')
  BEGIN
    DECLARE @message_id_as_char VARCHAR(10)

    SELECT @message_id_as_char = CONVERT(VARCHAR(10), @message_id)
    INSERT INTO #TempRetVal
    EXECUTE ('IF (' + @message_id_as_char + ' IN (' + @non_alertable_errors + ')) SELECT 1')
  END

  IF (EXISTS (SELECT *
              FROM #TempRetVal))
  BEGIN
    RAISERROR(14506, 16, 1, @message_id)
    RETURN(1) -- Failure
  END

  DROP TABLE #TempRetVal

  -- Enabled must be 0 or 1
  IF (@enabled NOT IN (0, 1))
  BEGIN
    RAISERROR(14266, 16, 1, '@enabled', '0, 1')
    RETURN(1) -- Failure
  END

  -- DelayBetweenResponses must be > 0
  IF (@delay_between_responses < 0)
  BEGIN
    SELECT @res_valid_range = FORMATMESSAGE(14206)
    RAISERROR(14266, 16, 1, '@delay_between_responses', @res_valid_range)
    RETURN(1) -- Failure
  END

  -- NOTE: We don't check the notification message

  -- Check IncludeEventDescriptionIn
  IF ((@include_event_description_in < 0) OR (@include_event_description_in > 7))
  BEGIN
    SELECT @res_valid_range = FORMATMESSAGE(14208)
    RAISERROR(14266, 16, 1, '@include_event_description_in', @res_valid_range)
    RETURN(1) -- Failure
  END

  -- Check the database name
  IF (@database_name IS NOT NULL) AND (DB_ID(@database_name) IS NULL)
  BEGIN
    RAISERROR(15010, 16, 1, @database_name)
    RETURN(1) -- Failure
  END

  -- NOTE: We don't check the event description keyword

  -- Check JobName/ID
  IF ((@job_id IS NOT NULL) OR (@job_name IS NOT NULL))
  BEGIN
    -- We use '' as a special value which means 'no job' (we cannot use NULL since this forces
    -- sp_update_alert to use the existing value)
    IF (@job_name = N'')
      SELECT @job_id = 0x00
    ELSE
    BEGIN
      EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                                  '@job_id',
                                                   @job_name OUTPUT,
                                                   @job_id   OUTPUT
      IF (@retval <> 0)
        RETURN(1) -- Failure
      -- Check that the job is a local job
      IF (NOT EXISTS (SELECT *
                      FROM msdb.dbo.sysjobservers
                      WHERE (job_id = @job_id)
                        AND (server_id = 0)))
      BEGIN
        RAISERROR(14234, -1, -1, '@job_id', 'sp_help_job @job_type = ''LOCAL''')
        RETURN(1) -- Failure
      END
    END
  END

  -- OccurrenceCount must be > 0
  IF (@occurrence_count < 0)
  BEGIN
    RAISERROR(14266, 16, 1, '@occurrence_count', '0..n')
    RETURN(1) -- Failure
  END

  -- RaiseSNMPTrap must be 0 or 1
  IF (@raise_snmp_trap NOT IN (0, 1))
  BEGIN
    RAISERROR(14266, 16, 1, '@raise_snmp_trap', '0, 1')
    RETURN(1) -- Failure
  END

  -- Check the performance condition (including invalid parameter combinations)
  IF (@performance_condition IS NOT NULL)
  BEGIN
    IF (@database_name IS NOT NULL)
    BEGIN
      RAISERROR(14505, 16, 1, 'database_name')
      RETURN(1) -- Failure
    END

    IF (@event_description_keyword IS NOT NULL)
    BEGIN
      RAISERROR(14505, 16, 1, 'event_description_keyword')
      RETURN(1) -- Failure
    END

    -- Verify the performance condition
    EXECUTE @retval = msdb.dbo.sp_verify_performance_condition @performance_condition
    IF (@retval <> 0)
      RETURN(1) -- Failure
  END

  -- Check category name
  IF (@category_name = N'[DEFAULT]')
    SELECT @category_id = 98
  ELSE
  BEGIN
    SELECT @category_id = category_id
    FROM msdb.dbo.syscategories
    WHERE (category_class = 2) -- Alerts
      AND (category_type = 3) -- None
      AND (name = @category_name)
  END
  IF (@category_id IS NULL)
  BEGIN
    RAISERROR(14262, -1, -1, '@category_name', @category_name)
    RETURN(1) -- Failure
  END

  -- Check count reset date
  IF (@count_reset_date <> 0)
  BEGIN
    EXECUTE @retval = msdb.dbo.sp_verify_job_date @count_reset_date, '@count_reset_date'
    IF (@retval <> 0)
      RETURN(1) -- Failure
  END

  -- Check count reset time
  IF (@count_reset_time <> 0)
  BEGIN
    EXECUTE @retval = msdb.dbo.sp_verify_job_time @count_reset_time, '@count_reset_time'
    IF (@retval <> 0)
      RETURN(1) -- Failure
  END

  RETURN(0) -- Success
END
go

/**************************************************************/
/* SP_ADD_ALERT                                               */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_add_alert...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_add_alert')
              AND (type = 'P')))
  DROP PROCEDURE sp_add_alert
go
CREATE PROCEDURE sp_add_alert
  @name                         sysname,
  @message_id                   INT              = 0,
  @severity                     INT              = 0,
  @enabled                      TINYINT          = 1,
  @delay_between_responses      INT              = 0,
  @notification_message         NVARCHAR(512)    = NULL,
  @include_event_description_in TINYINT          = 5,    -- 0 = None, 1 = Email, 2 = Pager, 4 = NetSend, 7 = All
  @database_name                sysname          = NULL,
  @event_description_keyword    NVARCHAR(100)    = NULL,
  @job_id                       UNIQUEIDENTIFIER = NULL, -- If provided must NOT also provide job_name
  @job_name                     sysname          = NULL, -- If provided must NOT also provide job_id
  @raise_snmp_trap              TINYINT          = 0,
  @performance_condition        NVARCHAR(512)    = NULL, -- New for 7.0
  @category_name                sysname          = NULL  -- New for 7.0
AS
BEGIN
  DECLARE @event_source           NVARCHAR(100)
  DECLARE @event_category_id      INT
  DECLARE @event_id               INT
  DECLARE @last_occurrence_date   INT
  DECLARE @last_occurrence_time   INT
  DECLARE @last_notification_date INT
  DECLARE @last_notification_time INT
  DECLARE @occurrence_count       INT
  DECLARE @count_reset_date       INT
  DECLARE @count_reset_time       INT
  DECLARE @has_notification       INT
  DECLARE @return_code            INT
  DECLARE @duplicate_name         sysname
  DECLARE @category_id            INT
  DECLARE @alert_id               INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @name                      = LTRIM(RTRIM(@name))
  SELECT @notification_message      = LTRIM(RTRIM(@notification_message))
  SELECT @database_name             = LTRIM(RTRIM(@database_name))
  SELECT @event_description_keyword = LTRIM(RTRIM(@event_description_keyword))
  SELECT @job_name                  = LTRIM(RTRIM(@job_name))
  SELECT @performance_condition     = LTRIM(RTRIM(@performance_condition))
  SELECT @category_name             = LTRIM(RTRIM(@category_name))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@notification_message      = N'') SELECT @notification_message = NULL
  IF (@database_name             = N'') SELECT @database_name = NULL
  IF (@event_description_keyword = N'') SELECT @event_description_keyword = NULL
  IF (@job_name                  = N'') SELECT @job_name = NULL
  IF (@performance_condition     = N'') SELECT @performance_condition = NULL
  IF (@category_name             = N'') SELECT @category_name = NULL

  SELECT @message_id = ISNULL(@message_id, 0)
  SELECT @severity = ISNULL(@severity, 0)

  -- Only a sysadmin can do this
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  -- Check if SQLServerAgent is in the process of starting
  EXECUTE @return_code = msdb.dbo.sp_is_sqlagent_starting
  IF (@return_code <> 0)
    RETURN(1) -- Failure

  -- Hard-code the new Alert defaults
  -- event source needs to be instance aware
  DECLARE @instance_name sysname
  SELECT @instance_name = CONVERT (sysname, SERVERPROPERTY ('InstanceName'))
  IF (@instance_name IS NULL OR @instance_name = N'MSSQLSERVER')
    SELECT @event_source  = N'MSSQLSERVER'
  ELSE
    SELECT @event_source  = N'MSSQL$' + @instance_name

  SELECT @event_category_id = NULL
  SELECT @event_id = NULL
  SELECT @last_occurrence_date = 0
  SELECT @last_occurrence_time = 0
  SELECT @last_notification_date = 0
  SELECT @last_notification_time = 0
  SELECT @occurrence_count = 0
  SELECT @count_reset_date = 0
  SELECT @count_reset_time = 0
  SELECT @has_notification = 0

  IF (@category_name IS NULL)
  BEGIN
    SELECT @category_name = name
    FROM msdb.dbo.syscategories
    WHERE (category_id = 98)
  END

  -- Map a job_id of 0 to the real value we use to mean 'no job'
  IF (@job_id = CONVERT(UNIQUEIDENTIFIER, 0x00)) AND (@job_name IS NULL)
    SELECT @job_name = N''

  -- Verify the Alert
  IF (@job_id = CONVERT(UNIQUEIDENTIFIER, 0x00))
    SELECT @job_id = NULL
  EXECUTE @return_code = sp_verify_alert @name,
                                         @message_id,
                                         @severity,
                                         @enabled,
                                         @delay_between_responses,
                                         @notification_message,
                                         @include_event_description_in,
                                         @database_name,
                                         @event_description_keyword,
                                         @job_id OUTPUT,
                                         @job_name OUTPUT,
                                         @occurrence_count,
                                         @raise_snmp_trap,
                                         @performance_condition,
                                         @category_name,
                                         @category_id OUTPUT,
                                         @count_reset_date,
                                         @count_reset_time
  IF (@return_code <> 0)
    RETURN(1) -- Failure

  -- Check if this Alert already exists
  SELECT @duplicate_name = FORMATMESSAGE(14205)
  SELECT @duplicate_name = name
  FROM msdb.dbo.sysalerts
  WHERE (ISNULL(performance_condition, N'apples') = ISNULL(@performance_condition, N'oranges'))
     OR ((performance_condition IS NULL) AND
         (message_id = @message_id) AND
         (severity = @severity) AND
         (ISNULL(database_name, N'') = ISNULL(@database_name, N'')) AND
         (ISNULL(event_description_keyword, N'') = ISNULL(@event_description_keyword, N'')))
  IF (@duplicate_name <> FORMATMESSAGE(14205))
  BEGIN
    RAISERROR(14501, 16, 1, @duplicate_name)
    RETURN(1) -- Failure
  END

  -- Finally, do the actual INSERT
  INSERT INTO msdb.dbo.sysalerts
         (name,
          event_source,
          event_category_id,
          event_id,
          message_id,
          severity,
          enabled,
          delay_between_responses,
          last_occurrence_date,
          last_occurrence_time,
          last_response_date,
          last_response_time,
          notification_message,
          include_event_description,
          database_name,
          event_description_keyword,
          occurrence_count,
          count_reset_date,
          count_reset_time,
          job_id,
          has_notification,
          flags,
          performance_condition,
          category_id)
  VALUES (@name,
          @event_source,
          @event_category_id,
          @event_id,
          @message_id,
          @severity,
          @enabled,
          @delay_between_responses,
          @last_occurrence_date,
          @last_occurrence_time,
          @last_notification_date,
          @last_notification_time,
          @notification_message,
          @include_event_description_in,
          @database_name,
          @event_description_keyword,
          @occurrence_count,
          @count_reset_date,
          @count_reset_time,
          ISNULL(@job_id, CONVERT(UNIQUEIDENTIFIER, 0x00)),
          @has_notification,
          @raise_snmp_trap,
          @performance_condition,
          @category_id)

  -- Notify SQLServerAgent of the change
  SELECT @alert_id = id
  FROM msdb.dbo.sysalerts
  WHERE (name = @name)
  EXECUTE msdb.dbo.sp_sqlagent_notify @op_type     = N'A',
                                      @alert_id    = @alert_id,
                                      @action_type = N'I'
  RETURN(0) -- Success
END
go

/**************************************************************/
/* SP_UPDATE_ALERT                                            */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_update_alert...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_update_alert')
              AND (type = 'P')))
  DROP PROCEDURE sp_update_alert
go
CREATE PROCEDURE sp_update_alert
  @name                         sysname,
  @new_name                     sysname          = NULL,
  @enabled                      TINYINT          = NULL,
  @message_id                   INT              = NULL,
  @severity                     INT              = NULL,
  @delay_between_responses      INT              = NULL,
  @notification_message         NVARCHAR(512)    = NULL,
  @include_event_description_in TINYINT          = NULL, -- 0 = None, 1 = Email, 2 = Pager. 4 = NetSend, 7 = All
  @database_name                sysname          = NULL,
  @event_description_keyword    NVARCHAR(100)    = NULL,
  @job_id                       UNIQUEIDENTIFIER = NULL, -- If provided must NOT also provide job_name
  @job_name                     sysname          = NULL, -- If provided must NOT also provide job_id
  @occurrence_count             INT              = NULL, -- Can only be set to 0
  @count_reset_date             INT              = NULL,
  @count_reset_time             INT              = NULL,
  @last_occurrence_date         INT              = NULL, -- Can only be set to 0
  @last_occurrence_time         INT              = NULL, -- Can only be set to 0
  @last_response_date           INT              = NULL, -- Can only be set to 0
  @last_response_time           INT              = NULL, -- Can only be set to 0
  @raise_snmp_trap              TINYINT          = NULL,
  @performance_condition        NVARCHAR(512)    = NULL, -- New for 7.0
  @category_name                sysname          = NULL  -- New for 7.0
AS
BEGIN
  DECLARE @x_enabled                   TINYINT
  DECLARE @x_message_id                INT
  DECLARE @x_severity                  INT
  DECLARE @x_delay_between_responses   INT
  DECLARE @x_notification_message      NVARCHAR(512)
  DECLARE @x_include_event_description TINYINT
  DECLARE @x_database_name             sysname
  DECLARE @x_event_description_keyword NVARCHAR(100)
  DECLARE @x_occurrence_count          INT
  DECLARE @x_count_reset_date          INT
  DECLARE @x_count_reset_time          INT
  DECLARE @x_last_occurrence_date      INT
  DECLARE @x_last_occurrence_time      INT
  DECLARE @x_last_response_date        INT
  DECLARE @x_last_response_time        INT
  DECLARE @x_flags                     INT
  DECLARE @x_performance_condition     NVARCHAR(512)
  DECLARE @x_job_id                    UNIQUEIDENTIFIER
  DECLARE @x_category_id               INT

  DECLARE @include_event_desc_code     TINYINT
  DECLARE @return_code                 INT
  DECLARE @duplicate_name              sysname
  DECLARE @category_id                 INT
  DECLARE @alert_id                    INT
  DECLARE @cached_attribute_modified   INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @new_name                  = LTRIM(RTRIM(@new_name))
  SELECT @job_name                  = LTRIM(RTRIM(@job_name))
  SELECT @notification_message      = LTRIM(RTRIM(@notification_message))
  SELECT @database_name             = LTRIM(RTRIM(@database_name))
  SELECT @event_description_keyword = LTRIM(RTRIM(@event_description_keyword))
  SELECT @performance_condition     = LTRIM(RTRIM(@performance_condition))
  SELECT @category_name             = LTRIM(RTRIM(@category_name))

  -- Are we modifying an attribute which SQLServerAgent caches?
  IF ((@new_name                     IS NOT NULL) OR
      (@enabled                      IS NOT NULL) OR
      (@message_id                   IS NOT NULL) OR
      (@severity                     IS NOT NULL) OR
      (@delay_between_responses      IS NOT NULL) OR
      (@notification_message         IS NOT NULL) OR
      (@include_event_description_in IS NOT NULL) OR
      (@database_name                IS NOT NULL) OR
      (@event_description_keyword    IS NOT NULL) OR
      (@job_id                       IS NOT NULL) OR
      (@job_name                     IS NOT NULL) OR
      (@last_response_date           IS NOT NULL) OR
      (@last_response_time           IS NOT NULL) OR
      (@raise_snmp_trap              IS NOT NULL) OR
      (@performance_condition        IS NOT NULL))
    SELECT @cached_attribute_modified = 1
  ELSE
    SELECT @cached_attribute_modified = 0

  -- Map a job_id of 0 to the real value we use to mean 'no job'
  IF (@job_id = CONVERT(UNIQUEIDENTIFIER, 0x00)) AND (@job_name IS NULL)
    SELECT @job_name = N''

  -- Only a sysadmin can do this
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1)
  END

  -- Check if SQLServerAgent is in the process of starting
  EXECUTE @return_code = msdb.dbo.sp_is_sqlagent_starting
  IF (@return_code <> 0)
    RETURN(1) -- Failure

  -- Check if this Alert exists
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysalerts
                  WHERE (name = @name)))
  BEGIN
    RAISERROR(14262, 16, 1, '@name', @name)
    RETURN(1)
  END

  -- Certain values (if supplied) may only be updated to 0
  IF (@occurrence_count <> 0)
  BEGIN
    RAISERROR(14266, -1, -1, '@occurrence_count', '0')
    RETURN(1) -- Failure
  END
  IF (@last_occurrence_date <> 0)
  BEGIN
    RAISERROR(14266, -1, -1, '@last_occurrence_date', '0')
    RETURN(1) -- Failure
  END
  IF (@last_occurrence_time <> 0)
  BEGIN
    RAISERROR(14266, -1, -1, '@last_occurrence_time', '0')
    RETURN(1) -- Failure
  END
  IF (@last_response_date <> 0)
  BEGIN
    RAISERROR(14266, -1, -1, '@last_response_date', '0')
    RETURN(1) -- Failure
  END
  IF (@last_response_time <> 0)
  BEGIN
    RAISERROR(14266, -1, -1, '@last_response_time', '0')
    RETURN(1) -- Failure
  END

  -- Get existing (@x_) values
  SELECT @alert_id                    = id,
         @x_enabled                   = enabled,
         @x_message_id                = message_id,
         @x_severity                  = severity,
         @x_delay_between_responses   = delay_between_responses,
         @x_notification_message      = notification_message,
         @x_include_event_description = include_event_description,
         @x_database_name             = database_name,
         @x_event_description_keyword = event_description_keyword,
         @x_occurrence_count          = occurrence_count,
         @x_count_reset_date          = count_reset_date,
         @x_count_reset_time          = count_reset_time,
         @x_job_id                    = job_id,
         @x_last_occurrence_date      = last_occurrence_date,
         @x_last_occurrence_time      = last_occurrence_time,
         @x_last_response_date        = last_response_date,
         @x_last_response_time        = last_response_time,
         @x_flags                     = flags,
         @x_performance_condition     = performance_condition,
         @x_category_id               = category_id
  FROM msdb.dbo.sysalerts
  WHERE (name = @name)

  SELECT @x_job_id = sjv.job_id
  FROM msdb.dbo.sysalerts    sa,
       msdb.dbo.sysjobs_view sjv
  WHERE (sa.job_id = sjv.job_id)
    AND (sa.name = @name)

  -- Fill out the values for all non-supplied parameters from the existsing values
  IF (@enabled                      IS NULL) SELECT @enabled                      = @x_enabled
  IF (@message_id                   IS NULL) SELECT @message_id                   = @x_message_id
  IF (@severity                     IS NULL) SELECT @severity                     = @x_severity
  IF (@delay_between_responses      IS NULL) SELECT @delay_between_responses      = @x_delay_between_responses
  IF (@notification_message         IS NULL) SELECT @notification_message         = @x_notification_message
  IF (@include_event_description_in IS NULL) SELECT @include_event_description_in = @x_include_event_description
  IF (@database_name                IS NULL) SELECT @database_name                = @x_database_name
  IF (@event_description_keyword    IS NULL) SELECT @event_description_keyword    = @x_event_description_keyword
  IF (@job_id IS NULL) AND (@job_name IS NULL) SELECT @job_id                     = @x_job_id
  IF (@occurrence_count             IS NULL) SELECT @occurrence_count             = @x_occurrence_count
  IF (@count_reset_date             IS NULL) SELECT @count_reset_date             = @x_count_reset_date
  IF (@count_reset_time             IS NULL) SELECT @count_reset_time             = @x_count_reset_time
  IF (@last_occurrence_date         IS NULL) SELECT @last_occurrence_date         = @x_last_occurrence_date
  IF (@last_occurrence_time         IS NULL) SELECT @last_occurrence_time         = @x_last_occurrence_time
  IF (@last_response_date           IS NULL) SELECT @last_response_date           = @x_last_response_date
  IF (@last_response_time           IS NULL) SELECT @last_response_time           = @x_last_response_time
  IF (@raise_snmp_trap              IS NULL) SELECT @raise_snmp_trap              = @x_flags & 0x1
  IF (@performance_condition        IS NULL) SELECT @performance_condition        = @x_performance_condition
  IF (@category_name                IS NULL) SELECT @category_name = name FROM msdb.dbo.syscategories WHERE (category_id = @x_category_id)

  IF (@category_name IS NULL)
  BEGIN
    SELECT @category_name = name
    FROM msdb.dbo.syscategories
    WHERE (category_id = 98)
  END

  -- Turn [nullable] empty string parameters into NULLs
  IF (@new_name                  = N'') SELECT @new_name                  = NULL
  IF (@notification_message      = N'') SELECT @notification_message      = NULL
  IF (@database_name             = N'') SELECT @database_name             = NULL
  IF (@event_description_keyword = N'') SELECT @event_description_keyword = NULL
  IF (@performance_condition     = N'') SELECT @performance_condition     = NULL

  -- Check if this alert would match an already existing alert
  SELECT @duplicate_name = FORMATMESSAGE(14205)
  SELECT @duplicate_name = name
  FROM msdb.dbo.sysalerts
  WHERE (ISNULL(performance_condition, N'') = ISNULL(@performance_condition, N''))
    AND (message_id = @message_id)
    AND (severity = @severity)
    AND (ISNULL(database_name, N'') = ISNULL(@database_name, N''))
    AND (ISNULL(event_description_keyword, N'') = ISNULL(@event_description_keyword, N''))
    AND (name <> @name)
  IF (@duplicate_name <> FORMATMESSAGE(14205))
  BEGIN
    RAISERROR(14501, 16, 1, @duplicate_name)
    RETURN(1) -- Failure
  END

  -- Verify the Alert
  IF (@job_id = CONVERT(UNIQUEIDENTIFIER, 0x00))
    SELECT @job_id = NULL
  EXECUTE @return_code = sp_verify_alert @new_name,
                                         @message_id,
                                         @severity,
                                         @enabled,
                                         @delay_between_responses,
                                         @notification_message,
                                         @include_event_description_in,
                                         @database_name,
                                         @event_description_keyword,
                                         @job_id OUTPUT,
                                         @job_name OUTPUT,
                                         @occurrence_count,
                                         @raise_snmp_trap,
                                         @performance_condition,
                                         @category_name,
                                         @category_id OUTPUT,
                                         @count_reset_date,
                                         @count_reset_time
  IF (@return_code <> 0)
    RETURN(1) -- Failure

  -- If the user didn't supply a NewName, use the old one.
  -- NOTE: This must be done AFTER sp_verify_alert.
  IF (@new_name IS NULL)
    SELECT @new_name = @name

  -- Turn the 1st 'flags' bit on or off accordingly
  IF (@raise_snmp_trap = 0)
    SELECT @x_flags = @x_flags & 0xFFFE
  ELSE
    SELECT @x_flags = @x_flags | 0x0001

  -- Finally, do the actual UPDATE
  UPDATE msdb.dbo.sysalerts
  SET name                        = @new_name,
      message_id                  = @message_id,
      severity                    = @severity,
      enabled                     = @enabled,
      delay_between_responses     = @delay_between_responses,
      notification_message        = @notification_message,
      include_event_description   = @include_event_description_in,
      database_name               = @database_name,
      event_description_keyword   = @event_description_keyword,
      job_id                      = ISNULL(@job_id, CONVERT(UNIQUEIDENTIFIER, 0x00)),
      occurrence_count            = @occurrence_count,
      count_reset_date            = @count_reset_date,
      count_reset_time            = @count_reset_time,
      last_occurrence_date        = @last_occurrence_date,
      last_occurrence_time        = @last_occurrence_time,
      last_response_date          = @last_response_date,
      last_response_time          = @last_response_time,
      flags                       = @x_flags,
      performance_condition       = @performance_condition,
      category_id                 = @category_id
  WHERE (name = @name)

  -- Notify SQLServerAgent of the change
  IF (@cached_attribute_modified = 1)
    EXECUTE msdb.dbo.sp_sqlagent_notify @op_type     = N'A',
                                        @alert_id    = @alert_id,
                                        @action_type = N'U'
  RETURN(0) -- Success
END
go

/**************************************************************/
/* SP_DELETE_ALERT                                            */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_delete_alert...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_delete_alert')
              AND (type = 'P')))
  DROP PROCEDURE sp_delete_alert
go
CREATE PROCEDURE sp_delete_alert
  @name sysname
AS
BEGIN
  DECLARE @alert_id    INT
  DECLARE @return_code INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @name = LTRIM(RTRIM(@name))

  -- Only a sysadmin can do this
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  -- Check if SQLServerAgent is in the process of starting
  EXECUTE @return_code = msdb.dbo.sp_is_sqlagent_starting
  IF (@return_code <> 0)
    RETURN(1) -- Failure

  -- Check if this Alert exists
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysalerts
                  WHERE (name = @name)))
  BEGIN
    RAISERROR(14262, 16, 1, '@name', @name)
    RETURN(1) -- Failure
  END

  -- Convert the Name to it's ID
  SELECT @alert_id = id
  FROM msdb.dbo.sysalerts
  WHERE (name = @name)

  BEGIN TRANSACTION

    -- Delete sysnotifications entries
    DELETE FROM msdb.dbo.sysnotifications
    WHERE (alert_id = @alert_id)

    -- Finally, do the actual DELETE
    DELETE FROM msdb.dbo.sysalerts
    WHERE (id = @alert_id)

  COMMIT TRANSACTION

  -- Notify SQLServerAgent of the change
  EXECUTE msdb.dbo.sp_sqlagent_notify @op_type     = N'A',
                                      @alert_id    = @alert_id,
                                      @action_type = N'D'
  RETURN(0) -- Success
END
go

/**************************************************************/
/* SP_HELP_ALERT                                              */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_help_alert...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_help_alert')
              AND (type = 'P')))
  DROP PROCEDURE sp_help_alert
go
CREATE PROCEDURE sp_help_alert
  @alert_name    sysname = NULL,
  @order_by      sysname = N'name',
  @alert_id      INT     = NULL,
  @category_name sysname = NULL
AS
BEGIN
  DECLARE @alert_id_as_char NVARCHAR(10)

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @alert_name    = LTRIM(RTRIM(@alert_name))
  SELECT @order_by      = LTRIM(RTRIM(@order_by))
  SELECT @category_name = LTRIM(RTRIM(@category_name))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@category_name = N'') SELECT @category_name = NULL
  IF (@alert_name = N'')    SELECT @alert_name = NULL

  -- Check alert name
  IF (@alert_name IS NOT NULL)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysalerts
                    WHERE (name = @alert_name)))
    BEGIN
      RAISERROR(14262, -1, -1, '@alert_name', @alert_name)
      RETURN(1) -- Failure
    END
  END

  -- Check alert id
  IF (@alert_id IS NOT NULL)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysalerts
                    WHERE (id = @alert_id)))
    BEGIN
      SELECT @alert_id_as_char = CONVERT(VARCHAR, @alert_id)
      RAISERROR(14262, -1, -1, '@alert_id', @alert_id_as_char)
      RETURN(1) -- Failure
    END
  END

  IF (@order_by NOT LIKE N'job_name%')
    SELECT @order_by = N'sa.' + @order_by

  IF (@alert_id IS NOT NULL)
    SELECT @alert_id_as_char = CONVERT(VARCHAR, @alert_id)
  ELSE
    SELECT @alert_id_as_char = N'NULL'

  -- Double up any single quotes in @alert_name
  IF (@alert_name IS NOT NULL)
    SELECT @alert_name = REPLACE(@alert_name, N'''', N'''''')

  -- Double up any single quotes in @category_name
  IF (@category_name IS NOT NULL)
    SELECT @category_name = REPLACE(@category_name, N'''', N'''''')

  EXECUTE (N'SELECT sa.id,
                    sa.name,
                    sa.event_source,
                    sa.event_category_id,
                    sa.event_id,
                    sa.message_id,
                    sa.severity,
                    sa.enabled,
                    sa.delay_between_responses,
                    sa.last_occurrence_date,
                    sa.last_occurrence_time,
                    sa.last_response_date,
                    sa.last_response_time,
                    sa.notification_message,
                    sa.include_event_description,
                    sa.database_name,
                    sa.event_description_keyword,
                    sa.occurrence_count,
                    sa.count_reset_date,
                    sa.count_reset_time,
                    sjv.job_id,
                    job_name = sjv.name,
                    sa.has_notification,
                    sa.flags,
                    sa.performance_condition,
                    category_name = sc.name,
                    type = CASE ISNULL(performance_condition, ''!'')
                             WHEN ''!'' THEN
                               CASE event_source
                                 WHEN ''MSSQLSERVER'' THEN 1 -- SQL Server event alert
                                 ELSE 3                      -- Non SQL Server event alert
                               END
                             ELSE 2                          -- SQL Server performance condition alert
                           END
             FROM msdb.dbo.sysalerts                     sa
                  LEFT OUTER JOIN msdb.dbo.sysjobs_view  sjv ON (sa.job_id = sjv.job_id)
                  LEFT OUTER JOIN msdb.dbo.syscategories sc  ON (sa.category_id = sc.category_id)
             WHERE ((N''' + @alert_name + N''' = N'''') OR (sa.name = N''' + @alert_name + N'''))
               AND ((' + @alert_id_as_char + N' IS NULL) OR (sa.id = ' + @alert_id_as_char + N'))
               AND ((N''' + @category_name + N''' = N'''') OR (sc.name = N''' + @category_name + N'''))
             ORDER BY ' + @order_by)

  RETURN(@@error) -- 0 means success
END
go

/**************************************************************/
/* SP_VERIFY_OPERATOR                                         */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_verify_operator...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_verify_operator')
              AND (type = 'P')))
  DROP PROCEDURE sp_verify_operator
go
CREATE PROCEDURE sp_verify_operator
  @name                      sysname,
  @enabled                   TINYINT,
  @pager_days                TINYINT,
  @weekday_pager_start_time  INT,
  @weekday_pager_end_time    INT,
  @saturday_pager_start_time INT,
  @saturday_pager_end_time   INT,
  @sunday_pager_start_time   INT,
  @sunday_pager_end_time     INT,
  @category_name             sysname,
  @category_id               INT OUTPUT
AS
BEGIN
  DECLARE @return_code     TINYINT
  DECLARE @res_valid_range NVARCHAR(100)

  SET NOCOUNT ON

  SELECT @res_valid_range = FORMATMESSAGE(14209)

  -- Remove any leading/trailing spaces from parameters
  SELECT @name          = LTRIM(RTRIM(@name))
  SELECT @category_name = LTRIM(RTRIM(@category_name))

  -- The name must be unique
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysoperators
              WHERE (name = @name)))
  BEGIN
    RAISERROR(14261, 16, 1, '@name', @name)
    RETURN(1) -- Failure
  END

  -- Enabled must be 0 or 1
  IF (@enabled NOT IN (0, 1))
  BEGIN
    RAISERROR(14266, 16, 1, '@enabled', '0, 1')
    RETURN(1) -- Failure
  END

  -- Check PagerDays
  IF (@pager_days < 0) OR (@pager_days > 127)
  BEGIN
    RAISERROR(14266, 16, 1, '@pager_days', @res_valid_range)
    RETURN(1) -- Failure
  END

  -- Check Start/End Times
  EXECUTE @return_code = sp_verify_job_time @weekday_pager_start_time, '@weekday_pager_start_time'
  IF (@return_code <> 0)
    RETURN(1)

  EXECUTE @return_code = sp_verify_job_time @weekday_pager_end_time, '@weekday_pager_end_time'
  IF (@return_code <> 0)
    RETURN(1)

  EXECUTE @return_code = sp_verify_job_time @saturday_pager_start_time, '@saturday_pager_start_time'
  IF (@return_code <> 0)
    RETURN(1)

  EXECUTE @return_code = sp_verify_job_time @saturday_pager_end_time, '@saturday_pager_end_time'
  IF (@return_code <> 0)
    RETURN(1)

  EXECUTE @return_code = sp_verify_job_time @sunday_pager_start_time, '@sunday_pager_start_time'
  IF (@return_code <> 0)
    RETURN(1)

  EXECUTE @return_code = sp_verify_job_time @sunday_pager_end_time, '@sunday_pager_end_time'
  IF (@return_code <> 0)
    RETURN(1)

  -- Check category name
  IF (@category_name = N'[DEFAULT]')
    SELECT @category_id = 99
  ELSE
  BEGIN
    SELECT @category_id = category_id
    FROM msdb.dbo.syscategories
    WHERE (category_class = 3) -- Operators
      AND (category_type = 3) -- None
      AND (name = @category_name)
  END
  IF (@category_id IS NULL)
  BEGIN
    RAISERROR(14262, -1, -1, '@category_name', @category_name)
    RETURN(1) -- Failure
  END

  RETURN(0)
END
go

/**************************************************************/
/* SP_ADD_OPERATOR                                            */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_add_operator...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_add_operator')
              AND (type = 'P')))
  DROP PROCEDURE sp_add_operator
go
CREATE PROCEDURE sp_add_operator
  @name                      sysname,
  @enabled                   TINYINT       = 1,
  @email_address             NVARCHAR(100) = NULL,
  @pager_address             NVARCHAR(100) = NULL,
  @weekday_pager_start_time  INT           = 090000, -- HHMMSS using 24 hour clock
  @weekday_pager_end_time    INT           = 180000, -- As above
  @saturday_pager_start_time INT           = 090000, -- As above
  @saturday_pager_end_time   INT           = 180000, -- As above
  @sunday_pager_start_time   INT           = 090000, -- As above
  @sunday_pager_end_time     INT           = 180000, -- As above
  @pager_days                TINYINT       = 0,      -- 1 = Sunday .. 64 = Saturday
  @netsend_address           NVARCHAR(100) = NULL,   -- New for 7.0
  @category_name             sysname       = NULL    -- New for 7.0
AS
BEGIN
  DECLARE @return_code TINYINT
  DECLARE @category_id INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @name            = LTRIM(RTRIM(@name))
  SELECT @email_address   = LTRIM(RTRIM(@email_address))
  SELECT @pager_address   = LTRIM(RTRIM(@pager_address))
  SELECT @netsend_address = LTRIM(RTRIM(@netsend_address))
  SELECT @category_name   = LTRIM(RTRIM(@category_name))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@email_address   = N'') SELECT @email_address   = NULL
  IF (@pager_address   = N'') SELECT @pager_address   = NULL
  IF (@netsend_address = N'') SELECT @netsend_address = NULL
  IF (@category_name   = N'') SELECT @category_name   = NULL

  -- Only a sysadmin can do this
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  IF (@category_name IS NULL)
  BEGIN
    SELECT @category_name = name
    FROM msdb.dbo.syscategories
    WHERE (category_id = 99)
  END

  -- Verify the operator
  EXECUTE @return_code = sp_verify_operator @name,
                                            @enabled,
                                            @pager_days,
                                            @weekday_pager_start_time,
                                            @weekday_pager_end_time,
                                            @saturday_pager_start_time,
                                            @saturday_pager_end_time,
                                            @sunday_pager_start_time,
                                            @sunday_pager_end_time,
                                            @category_name,
                                            @category_id OUTPUT
  IF (@return_code <> 0)
    RETURN(1) -- Failure

  -- Finally, do the INSERT
  INSERT INTO msdb.dbo.sysoperators
         (name,
          enabled,
          email_address,
          last_email_date,
          last_email_time,
          pager_address,
          last_pager_date,
          last_pager_time,
          weekday_pager_start_time,
          weekday_pager_end_time,
          saturday_pager_start_time,
          saturday_pager_end_time,
          sunday_pager_start_time,
          sunday_pager_end_time,
          pager_days,
          netsend_address,
          last_netsend_date,
          last_netsend_time,
          category_id)
  VALUES (@name,
          @enabled,
          @email_address,
          0,
          0,
          @pager_address,
          0,
          0,
          @weekday_pager_start_time,
          @weekday_pager_end_time,
          @saturday_pager_start_time,
          @saturday_pager_end_time,
          @sunday_pager_start_time,
          @sunday_pager_end_time,
          @pager_days,
          @netsend_address,
          0,
          0,
          @category_id)

  RETURN(@@error) -- 0 means success
END
go

/**************************************************************/
/* SP_UPDATE_OPERATOR                                         */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_update_operator...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_update_operator')
              AND (type = 'P')))
  DROP PROCEDURE sp_update_operator
go
CREATE PROCEDURE sp_update_operator
  @name                      sysname,
  @new_name                  sysname       = NULL,
  @enabled                   TINYINT       = NULL,
  @email_address             NVARCHAR(100) = NULL,
  @pager_address             NVARCHAR(100) = NULL,
  @weekday_pager_start_time  INT           = NULL, -- HHMMSS using 24 hour clock
  @weekday_pager_end_time    INT           = NULL, -- As above
  @saturday_pager_start_time INT           = NULL, -- As above
  @saturday_pager_end_time   INT           = NULL, -- As above
  @sunday_pager_start_time   INT           = NULL, -- As above
  @sunday_pager_end_time     INT           = NULL, -- As above
  @pager_days                TINYINT       = NULL,
  @netsend_address           NVARCHAR(100) = NULL, -- New for 7.0
  @category_name             sysname       = NULL  -- New for 7.0
AS
BEGIN
  DECLARE @x_enabled                   TINYINT
  DECLARE @x_email_address             NVARCHAR(100)
  DECLARE @x_pager_address             NVARCHAR(100)
  DECLARE @x_weekday_pager_start_time  INT
  DECLARE @x_weekday_pager_end_time    INT
  DECLARE @x_saturday_pager_start_time INT
  DECLARE @x_saturday_pager_end_time   INT
  DECLARE @x_sunday_pager_start_time   INT
  DECLARE @x_sunday_pager_end_time     INT
  DECLARE @x_pager_days                TINYINT
  DECLARE @x_netsend_address           NVARCHAR(100)
  DECLARE @x_category_id               INT

  DECLARE @return_code                 INT
  DECLARE @notification_method         INT
  DECLARE @alert_fail_safe_operator    sysname
  DECLARE @current_msx_server          NVARCHAR(30)
  DECLARE @category_id                 INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @name            = LTRIM(RTRIM(@name))
  SELECT @new_name        = LTRIM(RTRIM(@new_name))
  SELECT @email_address   = LTRIM(RTRIM(@email_address))
  SELECT @pager_address   = LTRIM(RTRIM(@pager_address))
  SELECT @netsend_address = LTRIM(RTRIM(@netsend_address))
  SELECT @category_name   = LTRIM(RTRIM(@category_name))

  -- Only a sysadmin can do this
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  -- Check if this Operator exists
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysoperators
                  WHERE (name = @name)))
  BEGIN
    RAISERROR(14262, 16, 1, '@name', @name)
    RETURN(1) -- Failure
  END

  -- Check if this operator is 'MSXOperator'
  IF (@name = N'MSXOperator')
  BEGIN
    -- Disallow the update operation if we're at a TSX for all callers other than xp_msx_enlist
    EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                           N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                           N'MSXServerName',
                                           @current_msx_server OUTPUT,
                                           N'no_output'
    IF ((@current_msx_server IS NOT NULL) AND (PROGRAM_NAME() <> N'xp_msx_enlist'))
    BEGIN
      RAISERROR(14223, 16, 1, 'MSXOperator', 'TSX')
      RETURN(1) -- Failure
    END
  END

  -- Get existing (@x_) operator property values
  SELECT @x_enabled                   = enabled,
         @x_email_address             = email_address,
         @x_pager_address             = pager_address,
         @x_weekday_pager_start_time  = weekday_pager_start_time,
         @x_weekday_pager_end_time    = weekday_pager_end_time,
         @x_saturday_pager_start_time = saturday_pager_start_time,
         @x_saturday_pager_end_time   = saturday_pager_end_time,
         @x_sunday_pager_start_time   = sunday_pager_start_time,
         @x_sunday_pager_end_time     = sunday_pager_end_time,
         @x_pager_days                = pager_days,
         @x_netsend_address           = netsend_address,
         @x_category_id               = category_id
  FROM msdb.dbo.sysoperators
  WHERE (name = @name)

  -- Fill out the values for all non-supplied parameters from the existsing values
  IF (@enabled                   IS NULL) SELECT @enabled                   = @x_enabled
  IF (@email_address             IS NULL) SELECT @email_address             = @x_email_address
  IF (@pager_address             IS NULL) SELECT @pager_address             = @x_pager_address
  IF (@weekday_pager_start_time  IS NULL) SELECT @weekday_pager_start_time  = @x_weekday_pager_start_time
  IF (@weekday_pager_end_time    IS NULL) SELECT @weekday_pager_end_time    = @x_weekday_pager_end_time
  IF (@saturday_pager_start_time IS NULL) SELECT @saturday_pager_start_time = @x_saturday_pager_start_time
  IF (@saturday_pager_end_time   IS NULL) SELECT @saturday_pager_end_time   = @x_saturday_pager_end_time
  IF (@sunday_pager_start_time   IS NULL) SELECT @sunday_pager_start_time   = @x_sunday_pager_start_time
  IF (@sunday_pager_end_time     IS NULL) SELECT @sunday_pager_end_time     = @x_sunday_pager_end_time
  IF (@pager_days                IS NULL) SELECT @pager_days                = @x_pager_days
  IF (@netsend_address           IS NULL) SELECT @netsend_address           = @x_netsend_address
  IF (@category_name             IS NULL) SELECT @category_name = name FROM msdb.dbo.syscategories WHERE (category_id = @x_category_id)

  IF (@category_name IS NULL)
  BEGIN
    SELECT @category_name = name
    FROM msdb.dbo.syscategories
    WHERE (category_id = 99)
  END

  -- Turn [nullable] empty string parameters into NULLs
  IF (@email_address   = N'') SELECT @email_address   = NULL
  IF (@pager_address   = N'') SELECT @pager_address   = NULL
  IF (@netsend_address = N'') SELECT @netsend_address = NULL
  IF (@category_name   = N'') SELECT @category_name   = NULL

  -- Verify the operator
  EXECUTE @return_code = sp_verify_operator @new_name,
                                            @enabled,
                                            @pager_days,
                                            @weekday_pager_start_time,
                                            @weekday_pager_end_time,
                                            @saturday_pager_start_time,
                                            @saturday_pager_end_time,
                                            @sunday_pager_start_time,
                                            @sunday_pager_end_time,
                                            @category_name,
                                            @category_id OUTPUT
  IF (@return_code <> 0)
    RETURN(1) -- Failure

  -- If no new name is supplied, use the old one
  -- NOTE: We must do this AFTER calling sp_verify_operator.
  IF (@new_name IS NULL)
    SELECT @new_name = @name
  ELSE
  BEGIN
    -- You can't rename the MSXOperator
    IF (@name = N'MSXOperator')
    BEGIN
      RAISERROR(14222, 16, 1, 'MSXOperator')
      RETURN(1) -- Failure
    END
  END

  -- Do the UPDATE
  UPDATE msdb.dbo.sysoperators
  SET name                      = @new_name,
      enabled                   = @enabled,
      email_address             = @email_address,
      pager_address             = @pager_address,
      weekday_pager_start_time  = @weekday_pager_start_time,
      weekday_pager_end_time    = @weekday_pager_end_time,
      saturday_pager_start_time = @saturday_pager_start_time,
      saturday_pager_end_time   = @saturday_pager_end_time,
      sunday_pager_start_time   = @sunday_pager_start_time,
      sunday_pager_end_time     = @sunday_pager_end_time,
      pager_days                = @pager_days,
      netsend_address           = @netsend_address,
      category_id               = @category_id
  WHERE (name = @name)

  -- Check if the operator is 'MSXOperator', in which case we need to re-enlist all the targets
  -- so that they will download the new MSXOperator details
  IF ((@name = N'MSXOperator') AND ((SELECT COUNT(*) FROM msdb.dbo.systargetservers) > 0))
    EXECUTE msdb.dbo.sp_post_msx_operation 'RE-ENLIST', 'SERVER', 0x00

  -- Check if this operator is the FailSafe Operator
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'AlertFailSafeOperator',
                                         @alert_fail_safe_operator OUTPUT,
                                         N'no_output'

  -- If it is, we update the 4 'AlertFailSafe...' registry entries and AlertNotificationMethod
  IF (LTRIM(RTRIM(@alert_fail_safe_operator)) = @name)
  BEGIN
    -- Update AlertFailSafeX values
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'AlertFailSafeOperator',
                                            N'REG_SZ',
                                            @new_name
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'AlertFailSafeEmailAddress',
                                            N'REG_SZ',
                                            @email_address
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'AlertFailSafePagerAddress',
                                            N'REG_SZ',
                                            @pager_address
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'AlertFailSafeNetSendAddress',
                                            N'REG_SZ',
                                            @netsend_address

    -- Update AlertNotificationMethod values
    EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                           N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                           N'AlertNotificationMethod',
                                           @notification_method OUTPUT,
                                           N'no_output'
    IF (LTRIM(RTRIM(@email_address)) IS NULL)
      SELECT @notification_method = @notification_method & ~1
    IF (LTRIM(RTRIM(@pager_address)) IS NULL)
      SELECT @notification_method = @notification_method & ~2
    IF (LTRIM(RTRIM(@netsend_address)) IS NULL)
      SELECT @notification_method = @notification_method & ~4
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'AlertNotificationMethod',
                                            N'REG_DWORD',
                                            @notification_method

    -- And finally, let SQLServerAgent know of the changes
    EXECUTE msdb.dbo.sp_sqlagent_notify @op_type = N'G'
  END

  RETURN(0) -- Success
END
go

/**************************************************************/
/* SP_DELETE_OPERATOR                                         */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_delete_operator...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_delete_operator')
              AND (type = 'P')))
  DROP PROCEDURE sp_delete_operator
go
CREATE PROCEDURE sp_delete_operator
  @name                 sysname,
  @reassign_to_operator sysname = NULL
AS
BEGIN
  DECLARE @id                         INT
  DECLARE @alert_fail_safe_operator   sysname
  DECLARE @job_id                     UNIQUEIDENTIFIER
  DECLARE @job_id_as_char             VARCHAR(36)
  DECLARE @notify_email_operator_id   INT
  DECLARE @notify_netsend_operator_id INT
  DECLARE @notify_page_operator_id    INT
  DECLARE @reassign_to_id             INT
  DECLARE @cmd                        NVARCHAR(512)
  DECLARE @current_msx_server         NVARCHAR(30)

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @name                 = LTRIM(RTRIM(@name))
  SELECT @reassign_to_operator = LTRIM(RTRIM(@reassign_to_operator))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@reassign_to_operator = N'') SELECT @reassign_to_operator = NULL

  -- Only a sysadmin can do this
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  -- Check if this Operator exists
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysoperators
                  WHERE (name = @name)))
  BEGIN
    RAISERROR(14262, 16, 1, '@name', @name)
    RETURN(1) -- Failure
  END

  -- Check if this operator the FailSafe Operator
  EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                         N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                         N'AlertFailSafeOperator',
                                         @alert_fail_safe_operator OUTPUT,
                                         N'no_output'

  -- If it is, we disallow the delete operation
  IF (LTRIM(RTRIM(@alert_fail_safe_operator)) = @name)
  BEGIN
    RAISERROR(14504, 16, 1, @name, @name)
    RETURN(1) -- Failure
  END

  -- Check if this operator is 'MSXOperator'
  IF (@name = N'MSXOperator')
  BEGIN
    DECLARE @server_type VARCHAR(3)

    -- Disallow the delete operation if we're an MSX or a TSX
    EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                           N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                           N'MSXServerName',
                                           @current_msx_server OUTPUT,
                                           N'no_output'
    IF (@current_msx_server IS NOT NULL)
      SELECT @server_type = 'TSX'

    IF ((SELECT COUNT(*)
         FROM msdb.dbo.systargetservers) > 0)
      SELECT @server_type = 'MSX'

    IF (@server_type IS NOT NULL)
    BEGIN
      RAISERROR(14223, 16, 1, 'MSXOperator', @server_type)
      RETURN(1) -- Failure
    END
  END

  -- Convert the Name to it's ID
  SELECT @id = id
  FROM msdb.dbo.sysoperators
  WHERE (name = @name)

  IF (@reassign_to_operator IS NOT NULL)
  BEGIN
    -- On a TSX or standalone server, disallow re-assigning to the MSXOperator
    IF (@reassign_to_operator = N'MSXOperator') AND
       (NOT EXISTS (SELECT *
                    FROM msdb.dbo.systargetservers))
    BEGIN
      RAISERROR(14251, -1, -1, @reassign_to_operator)
      RETURN(1) -- Failure
    END

    SELECT @reassign_to_id = id
    FROM msdb.dbo.sysoperators
    WHERE (name = @reassign_to_operator)

    IF (@reassign_to_id IS NULL)
    BEGIN
      RAISERROR(14262, -1, -1, '@reassign_to_operator', @reassign_to_operator)
      RETURN(1) -- Failure
    END
  END

  -- Double up any single quotes in @reassign_to_operator
  IF (@reassign_to_operator IS NOT NULL)
    SELECT @reassign_to_operator = REPLACE(@reassign_to_operator, N'''', N'''''')

  BEGIN TRANSACTION

    -- Reassign (or delete) any sysnotifications rows that reference this operator
    IF (@reassign_to_operator IS NOT NULL)
    BEGIN
      UPDATE msdb.dbo.sysnotifications
      SET operator_id = @reassign_to_id
      WHERE (operator_id = @id)
        AND (NOT EXISTS (SELECT *
                         FROM msdb.dbo.sysnotifications sn2
                         WHERE (sn2.alert_id = msdb.dbo.sysnotifications.alert_id)
                           AND (sn2.operator_id = @reassign_to_id)))
    END

    DELETE FROM msdb.dbo.sysnotifications
    WHERE (operator_id = @id)

    -- Update any jobs that reference this operator
    DECLARE jobs_referencing_this_operator CURSOR LOCAL
    FOR
    SELECT job_id,
           notify_email_operator_id,
           notify_netsend_operator_id,
           notify_page_operator_id
    FROM msdb.dbo.sysjobs
    WHERE (notify_email_operator_id = @id)
       OR (notify_netsend_operator_id = @id)
       OR (notify_page_operator_id = @id)

    OPEN jobs_referencing_this_operator
    FETCH NEXT FROM jobs_referencing_this_operator INTO @job_id,
                                                        @notify_email_operator_id,
                                                        @notify_netsend_operator_id,
                                                        @notify_page_operator_id
    WHILE (@@fetch_status = 0)
    BEGIN
      SELECT @job_id_as_char = CONVERT(VARCHAR(36), @job_id)
      SELECT @cmd = N'msdb.dbo.sp_update_job @job_id = ''' + @job_id_as_char + N''', '

      IF (@notify_email_operator_id = @id)
        IF (@reassign_to_operator IS NOT NULL)
          SELECT @cmd = @cmd + N'@notify_email_operator_name = N''' + @reassign_to_operator + N''', '
        ELSE
          SELECT @cmd = @cmd + N'@notify_email_operator_name = N'''', @notify_level_email = 0, '

      IF (@notify_netsend_operator_id = @id)
        IF (@reassign_to_operator IS NOT NULL)
          SELECT @cmd = @cmd + N'@notify_netsend_operator_name = N''' + @reassign_to_operator + N''', '
        ELSE
          SELECT @cmd = @cmd + N'@notify_netsend_operator_name = N'''', @notify_level_netsend = 0, '

      IF (@notify_page_operator_id = @id)
        IF (@reassign_to_operator IS NOT NULL)
          SELECT @cmd = @cmd + N'@notify_page_operator_name = N''' + @reassign_to_operator + N''', '
        ELSE
          SELECT @cmd = @cmd + N'@notify_page_operator_name = N'''', @notify_level_page = 0, '

      SELECT @cmd = SUBSTRING(@cmd, 1, (DATALENGTH(@cmd) / 2) - 2)
      EXECUTE (N'EXECUTE ' + @cmd)

      FETCH NEXT FROM jobs_referencing_this_operator INTO @job_id,
                                                          @notify_email_operator_id,
                                                          @notify_netsend_operator_id,
                                                          @notify_page_operator_id
    END
    DEALLOCATE jobs_referencing_this_operator

    -- Finally, do the actual DELETE
    DELETE FROM msdb.dbo.sysoperators
    WHERE (id = @id)

  COMMIT TRANSACTION

  RETURN(@@error) -- 0 means success
END
go

/**************************************************************/
/* SP_HELP_OPERATOR                                           */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_help_operator...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_help_operator')
              AND (type = 'P')))
  DROP PROCEDURE sp_help_operator
go
CREATE PROCEDURE sp_help_operator
  @operator_name sysname = NULL,
  @operator_id   INT     = NULL
AS
BEGIN
  DECLARE @operator_id_as_char VARCHAR(10)

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @operator_name = LTRIM(RTRIM(@operator_name))
  IF (@operator_name = '') SELECT @operator_name = NULL

  -- Check operator name
  IF (@operator_name IS NOT NULL)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysoperators
                    WHERE (name = @operator_name)))
    BEGIN
      RAISERROR(14262, -1, -1, '@operator_name', @operator_name)
      RETURN(1) -- Failure
    END
  END

  -- Check operator id
  IF (@operator_id IS NOT NULL)
  BEGIN
    IF (NOT EXISTS (SELECT *
                    FROM msdb.dbo.sysoperators
                    WHERE (id = @operator_id)))
    BEGIN
      SELECT @operator_id_as_char = CONVERT(VARCHAR, @operator_id)
      RAISERROR(14262, -1, -1, '@operator_id', @operator_id_as_char)
      RETURN(1) -- Failure
    END
  END

  SELECT so.id,
         so.name,
         so.enabled,
         so.email_address,
         so.last_email_date,
         so.last_email_time,
         so.pager_address,
         so.last_pager_date,
         so.last_pager_time,
         so.weekday_pager_start_time,
         so.weekday_pager_end_time,
         so.saturday_pager_start_time,
         so.saturday_pager_end_time,
         so.sunday_pager_start_time,
         so.sunday_pager_end_time,
         so.pager_days,
         so.netsend_address,
         so.last_netsend_date,
         so.last_netsend_time,
         category_name = sc.name
  FROM msdb.dbo.sysoperators                  so
       LEFT OUTER JOIN msdb.dbo.syscategories sc ON (so.category_id = sc.category_id)
  WHERE ((@operator_name IS NULL) OR (so.name = @operator_name))
    AND ((@operator_id IS NULL) OR (so.id = @operator_id))
  ORDER BY so.name

  RETURN(@@error) -- 0 means success
END
go

/**************************************************************/
/* SP_HELP_OPERATOR_JOBS                                      */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_help_operator_jobs...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = 'sp_help_operator_jobs')
              AND (type = 'P')))
  DROP PROCEDURE sp_help_operator_jobs
go
CREATE PROCEDURE sp_help_operator_jobs
  @operator_name sysname = NULL
AS
BEGIN
  DECLARE @operator_id INT

  SET NOCOUNT ON

  -- Check operator name
  SELECT @operator_id = id
  FROM msdb.dbo.sysoperators
  WHERE (name = @operator_name)
  IF (@operator_id IS NULL)
  BEGIN
    RAISERROR(14262, -1, -1, '@operator_name', @operator_name)
    RETURN(1) -- Failure
  END

  -- Get the job info
  SELECT job_id, name, notify_level_email, notify_level_netsend, notify_level_page
  FROM msdb.dbo.sysjobs_view
  WHERE ((notify_email_operator_id = @operator_id)   AND (notify_level_email <> 0))
     OR ((notify_netsend_operator_id = @operator_id) AND (notify_level_netsend <> 0))
     OR ((notify_page_operator_id = @operator_id)    AND (notify_level_page <> 0))

  RETURN(0) -- Success
END
go

/**************************************************************/
/* SP_VERIFY_NOTIFICATION                                     */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_verify_notification...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_verify_notification')
              AND (type = 'P')))
  DROP PROCEDURE sp_verify_notification
go
CREATE PROCEDURE sp_verify_notification
  @alert_name          sysname,
  @operator_name       sysname,
  @notification_method TINYINT,
  @alert_id            INT OUTPUT,
  @operator_id         INT OUTPUT
AS
BEGIN
  DECLARE @res_valid_range NVARCHAR(100)

  SET NOCOUNT ON

  SELECT @res_valid_range = FORMATMESSAGE(14208)

  -- Remove any leading/trailing spaces from parameters
  SELECT @alert_name    = LTRIM(RTRIM(@alert_name))
  SELECT @operator_name = LTRIM(RTRIM(@operator_name))

  -- Check if the AlertName is valid
  SELECT @alert_id = id
  FROM msdb.dbo.sysalerts
  WHERE (name = @alert_name)

  IF (@alert_id IS NULL)
  BEGIN
    RAISERROR(14262, 16, 1, '@alert_name', @alert_name)
    RETURN(1) -- Failure
  END

  -- Check if the OperatorName is valid
  SELECT @operator_id = id
  FROM msdb.dbo.sysoperators
  WHERE (name = @operator_name)

  IF (@operator_id IS NULL)
  BEGIN
    RAISERROR(14262, 16, 1, '@operator_name', @operator_name)
    RETURN(1) -- Failure
  END

  -- If we're at a TSX, we disallow using operator 'MSXOperator'
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.systargetservers)) AND
     (@operator_name = N'MSXOperator')
  BEGIN
    RAISERROR(14251, -1, -1, @operator_name)
    RETURN(1) -- Failure
  END

  -- Check if the NotificationMethod is valid
  IF ((@notification_method < 1) OR (@notification_method > 7))
  BEGIN
    RAISERROR(14266, 16, 1, '@notification_method', @res_valid_range)
    RETURN(1) -- Failure
  END

  RETURN(0) -- Success
END
go

/**************************************************************/
/* SP_ADD_NOTIFICATION                                        */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_add_notification...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_add_notification')
              AND (type = 'P')))
  DROP PROCEDURE sp_add_notification
go
CREATE PROCEDURE sp_add_notification
  @alert_name          sysname,
  @operator_name       sysname,
  @notification_method TINYINT -- 1 = Email, 2 = Pager, 4 = NetSend, 7 = All
AS
BEGIN
  DECLARE @alert_id             INT
  DECLARE @operator_id          INT
  DECLARE @notification         NVARCHAR(512)
  DECLARE @retval               INT
  DECLARE @old_has_notification INT
  DECLARE @new_has_notification INT
  DECLARE @res_notification     NVARCHAR(100)

  SET NOCOUNT ON

  SELECT @res_notification = FORMATMESSAGE(14210)

  -- Remove any leading/trailing spaces from parameters
  SELECT @alert_name    = LTRIM(RTRIM(@alert_name))
  SELECT @operator_name = LTRIM(RTRIM(@operator_name))

  -- Only a sysadmin can do this
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  -- Check if the Notification is valid
  EXECUTE @retval = msdb.dbo.sp_verify_notification @alert_name,
                                                    @operator_name,
                                                    @notification_method,
                                                    @alert_id     OUTPUT,
                                                    @operator_id  OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check if this notification already exists
  -- NOTE: The unique index would catch this, but testing for the problem here lets us
  --       control the message.
  IF (EXISTS (SELECT *
              FROM msdb.dbo.sysnotifications
              WHERE (alert_id = @alert_id)
                AND (operator_id = @operator_id)))
  BEGIN
    SELECT @notification = @alert_name + N' / ' + @operator_name + N' / ' + CONVERT(NVARCHAR, @notification_method)
    RAISERROR(14261, 16, 1, @res_notification, @notification)
    RETURN(1) -- Failure
  END

  SELECT @old_has_notification = has_notification
  FROM msdb.dbo.sysalerts
  WHERE (id = @alert_id)

  -- Do the INSERT
  INSERT INTO msdb.dbo.sysnotifications
         (alert_id,
          operator_id,
          notification_method)
  VALUES (@alert_id,
          @operator_id,
          @notification_method)

  SELECT @retval = @@error

  SELECT @new_has_notification = has_notification
  FROM msdb.dbo.sysalerts
  WHERE (id = @alert_id)

  -- Notify SQLServerAgent of the change - if any - to has_notifications
  IF (@old_has_notification <> @new_has_notification)
    EXECUTE msdb.dbo.sp_sqlagent_notify @op_type     = N'A',
                                        @alert_id    = @alert_id,
                                        @action_type = N'U'

  RETURN(@retval) -- 0 means success
END
go

/**************************************************************/
/* SP_UPDATE_NOTIFICATION                                     */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_update_notification...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_update_notification')
              AND (type = 'P')))
  DROP PROCEDURE sp_update_notification
go
CREATE PROCEDURE sp_update_notification
  @alert_name          sysname,
  @operator_name       sysname,
  @notification_method TINYINT -- 1 = Email, 2 = Pager, 4 = NetSend, 7 = All
AS
BEGIN
  DECLARE @alert_id             INT
  DECLARE @operator_id          INT
  DECLARE @notification         NVARCHAR(512)
  DECLARE @retval               INT
  DECLARE @old_has_notification INT
  DECLARE @new_has_notification INT
  DECLARE @res_notification     NVARCHAR(100)

  SET NOCOUNT ON

  SELECT @res_notification = FORMATMESSAGE(14210)

  -- Remove any leading/trailing spaces from parameters
  SELECT @alert_name    = LTRIM(RTRIM(@alert_name))
  SELECT @operator_name = LTRIM(RTRIM(@operator_name))

  -- Only a sysadmin can do this
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  -- Check if the Notification is valid
  EXECUTE sp_verify_notification @alert_name,
                                 @operator_name,
                                 @notification_method,
                                 @alert_id     OUTPUT,
                                 @operator_id  OUTPUT

  -- Check if this notification exists
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysnotifications
                  WHERE (alert_id = @alert_id)
                    AND (operator_id = @operator_id)))
  BEGIN
    SELECT @notification = @alert_name + N' / ' + @operator_name
    RAISERROR(14262, 16, 1, @res_notification, @notification)
    RETURN(1) -- Failure
  END

  SELECT @old_has_notification = has_notification
  FROM msdb.dbo.sysalerts
  WHERE (id = @alert_id)

  -- Do the UPDATE
  UPDATE msdb.dbo.sysnotifications
  SET notification_method = @notification_method
  WHERE (alert_id = @alert_id)
    AND (operator_id = @operator_id)

  SELECT @retval = @@error

  SELECT @new_has_notification = has_notification
  FROM msdb.dbo.sysalerts
  WHERE (id = @alert_id)

  -- Notify SQLServerAgent of the change - if any - to has_notifications
  IF (@old_has_notification <> @new_has_notification)
    EXECUTE msdb.dbo.sp_sqlagent_notify @op_type       = N'A',
                                          @alert_id    = @alert_id,
                                          @action_type = N'U'

  RETURN(@retval) -- 0 means success
END
go

/**************************************************************/
/* SP_DELETE_NOTIFICATION                                     */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_delete_notification...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_delete_notification')
              AND (type = 'P')))
  DROP PROCEDURE sp_delete_notification
go
CREATE PROCEDURE sp_delete_notification
  @alert_name    sysname,
  @operator_name sysname
AS
BEGIN
  DECLARE @alert_id             INT
  DECLARE @operator_id          INT
  DECLARE @ignored              TINYINT
  DECLARE @notification         NVARCHAR(512)
  DECLARE @retval               INT
  DECLARE @old_has_notification INT
  DECLARE @new_has_notification INT
  DECLARE @res_notification     NVARCHAR(100)

  SET NOCOUNT ON

  SELECT @res_notification = FORMATMESSAGE(14210)

  -- Remove any leading/trailing spaces from parameters
  SELECT @alert_name    = LTRIM(RTRIM(@alert_name))
  SELECT @operator_name = LTRIM(RTRIM(@operator_name))

  -- Only a sysadmin can do this
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  -- Get the alert and operator ID's
  EXECUTE sp_verify_notification @alert_name,
                                 @operator_name,
                                 7,           -- A dummy (but valid) value
                                 @alert_id    OUTPUT,
                                 @operator_id OUTPUT

  -- Check if this notification exists
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysnotifications
                  WHERE (alert_id = @alert_id)
                    AND (operator_id = @operator_id)))
  BEGIN
    SELECT @notification = @alert_name + N' / ' + @operator_name
    RAISERROR(14262, 16, 1, @res_notification, @notification)
    RETURN(1) -- Failure
  END

  SELECT @old_has_notification = has_notification
  FROM msdb.dbo.sysalerts
  WHERE (id = @alert_id)

  -- Do the Delete
  DELETE FROM msdb.dbo.sysnotifications
  WHERE (alert_id = @alert_id)
    AND (operator_id = @operator_id)

  SELECT @retval = @@error

  SELECT @new_has_notification = has_notification
  FROM msdb.dbo.sysalerts
  WHERE (id = @alert_id)

  -- Notify SQLServerAgent of the change - if any - to has_notifications
  IF (@old_has_notification <> @new_has_notification)
    EXECUTE msdb.dbo.sp_sqlagent_notify @op_type       = N'A',
                                          @alert_id    = @alert_id,
                                          @action_type = N'U'

  RETURN(@retval) -- 0 means success
END
go

/**************************************************************/
/* SP_HELP_NOTIFICATION                                       */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_help_notification...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_help_notification')
              AND (type = 'P')))
  DROP PROCEDURE sp_help_notification
go
CREATE PROCEDURE sp_help_notification
  @object_type          CHAR(9),   -- Either 'ALERTS'    (enumerates Alerts for given Operator)
                                   --     or 'OPERATORS' (enumerates Operators for given Alert)
  @name                 sysname,   -- Either an Operator Name (if @object_type is 'ALERTS')
                                   --     or an Alert Name    (if @object_type is 'OPERATORS')
  @enum_type            CHAR(10),  -- Either 'ALL'    (enumerate all objects [eg. all alerts irrespective of whether 'Fred' receives a notification for them])
                                   --     or 'ACTUAL' (enumerate only the associated objects [eg. only the alerts which 'Fred' receives a notification for])
                                   --     or 'TARGET' (enumerate only the objects matching @target_name [eg. a single row showing how 'Fred' is notfied for alert 'Test'])
  @notification_method  TINYINT,   -- Either 1 (Email)   - Modifies the result set to only show use_email column
                                   --     or 2 (Pager)   - Modifies the result set to only show use_pager column
                                   --     or 4 (NetSend) - Modifies the result set to only show use_netsend column
                                   --     or 7 (All)     - Modifies the result set to show all the use_xxx columns
  @target_name   sysname = NULL    -- Either an Alert Name    (if @object_type is 'ALERTS')
                                   --     or an Operator Name (if @object_type is 'OPERATORS')
                                   -- NOTE: This parameter is only required if @enum_type is 'TARGET')
AS
BEGIN
  DECLARE @id              INT    -- We use this to store the decode of @name
  DECLARE @target_id       INT    -- We use this to store the decode of @target_name
  DECLARE @select_clause   NVARCHAR(1024)
  DECLARE @from_clause     NVARCHAR(512)
  DECLARE @where_clause    NVARCHAR(512)
  DECLARE @res_valid_range NVARCHAR(100)

  SET NOCOUNT ON

  SELECT @res_valid_range = FORMATMESSAGE(14208)

  -- Remove any leading/trailing spaces from parameters
  SELECT @object_type = UPPER(LTRIM(RTRIM(@object_type)))
  SELECT @name        = LTRIM(RTRIM(@name))
  SELECT @enum_type   = UPPER(LTRIM(RTRIM(@enum_type)))
  SELECT @target_name = LTRIM(RTRIM(@target_name))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@target_name = N'') SELECT @target_name = NULL

  -- Check ObjectType
  IF (@object_type NOT IN ('ALERTS', 'OPERATORS'))
  BEGIN
    RAISERROR(14266, 16, 1, '@object_type', 'ALERTS, OPERATORS')
    RETURN(1) -- Failure
  END

  -- Check AlertName
  IF (@object_type = 'OPERATORS') AND
     (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysalerts
                  WHERE (name = @name)))
  BEGIN
    RAISERROR(14262, 16, 1, '@name', @name)
    RETURN(1) -- Failure
  END

  -- Check OperatorName
  IF (@object_type = 'ALERTS') AND
     (NOT EXISTS (SELECT *
                  FROM msdb.dbo.sysoperators
                  WHERE (name = @name)))
  BEGIN
    RAISERROR(14262, 16, 1, '@name', @name)
    RETURN(1) -- Failure
  END

  -- Check EnumType
  IF (@enum_type NOT IN ('ALL', 'ACTUAL', 'TARGET'))
  BEGIN
    RAISERROR(14266, 16, 1, '@enum_type', 'ALL, ACTUAL, TARGET')
    RETURN(1) -- Failure
  END

  -- Check Notification Method
  IF ((@notification_method < 1) OR (@notification_method > 7))
  BEGIN
    RAISERROR(14266, 16, 1, '@notification_method', @res_valid_range)
    RETURN(1) -- Failure
  END

  -- If EnumType is 'TARGET', check if we have a @TargetName parameter
  IF (@enum_type = 'TARGET') AND (@target_name IS NULL)
  BEGIN
    RAISERROR(14502, 16, 1)
    RETURN(1) -- Failure
  END

  -- If EnumType isn't 'TARGET', we shouldn't have an @target_name parameter
  IF (@enum_type <> 'TARGET') AND (@target_name IS NOT NULL)
  BEGIN
    RAISERROR(14503, 16, 1)
    RETURN(1) -- Failure
  END

  -- Translate the Name into an ID
  IF (@object_type = 'ALERTS')
  BEGIN
    SELECT @id = id
    FROM msdb.dbo.sysoperators
    WHERE (name = @name)
  END
  IF (@object_type = 'OPERATORS')
  BEGIN
    SELECT @id = id
    FROM msdb.dbo.sysalerts
    WHERE (name = @name)
  END

  -- Translate the TargetName into a TargetID
  IF (@target_name IS NOT NULL)
  BEGIN
    IF (@object_type = 'OPERATORS')
    BEGIN
      SELECT @target_id = id
      FROM msdb.dbo.sysoperators
      WHERE (name = @target_name )
    END
    IF (@object_type = 'ALERTS')
    BEGIN
      SELECT @target_id = id
      FROM msdb.dbo.sysalerts
      WHERE (name = @target_name)
    END
    IF (@target_id IS NULL) -- IE. the Target Name is invalid
    BEGIN
      RAISERROR(14262, 16, 1, @object_type, @target_name)
      RETURN(1) -- Failure
    END
  END

  -- Ok, the parameters look good so generate the SQL then EXECUTE() it...

  -- Generate the 'stub' SELECT clause and the FROM clause
  IF (@object_type = 'OPERATORS') -- So we want a list of Operators for the supplied AlertID
  BEGIN
    SELECT @select_clause = N'SELECT operator_id = o.id, operator_name = o.name, '
    IF (@enum_type = 'ALL')
      SELECT @from_clause = N'FROM msdb.dbo.sysoperators o LEFT OUTER JOIN msdb.dbo.sysnotifications sn ON (o.id = sn.operator_id) '
    ELSE
      SELECT @from_clause = N'FROM msdb.dbo.sysoperators o, msdb.dbo.sysnotifications sn '
  END
  IF (@object_type = 'ALERTS') -- So we want a list of Alerts for the supplied OperatorID
  BEGIN
    SELECT @select_clause = N'SELECT alert_id = a.id, alert_name = a.name, '
    IF (@enum_type = 'ALL')
      SELECT @from_clause = N'FROM msdb.dbo.sysalerts a LEFT OUTER JOIN msdb.dbo.sysnotifications sn ON (a.id = sn.alert_id) '
    ELSE
      SELECT @from_clause = N'FROM msdb.dbo.sysalerts a, msdb.dbo.sysnotifications sn '
  END

  -- Add the required use_xxx columns to the SELECT clause
  IF (@notification_method & 1 = 1)
    SELECT @select_clause = @select_clause + N'use_email = ISNULL((sn.notification_method & 1) / POWER(2, 0), 0), '
  IF (@notification_method & 2 = 2)
    SELECT @select_clause = @select_clause + N'use_pager = ISNULL((sn.notification_method & 2) / POWER(2, 1), 0), '
  IF (@notification_method & 4 = 4)
    SELECT @select_clause = @select_clause + N'use_netsend = ISNULL((sn.notification_method & 4) / POWER(2, 2), 0), '

  -- Remove the trailing comma
  SELECT @select_clause = SUBSTRING(@select_clause, 1, (DATALENGTH(@select_clause) / 2) - 2) + N' '

  -- Generate the WHERE clause
  IF (@object_type = 'OPERATORS')
  BEGIN
    IF (@enum_type = 'ALL')
      SELECT @from_clause = @from_clause + N' AND (sn.alert_id = ' + CONVERT(VARCHAR(10), @id) + N')'

    IF (@enum_type = 'ACTUAL')
      SELECT @where_clause = N'WHERE (o.id = sn.operator_id) AND (sn.alert_id = ' + CONVERT(VARCHAR(10), @id) + N') AND (sn.notification_method & ' + CONVERT(VARCHAR, @notification_method) + N' <> 0)'

    IF (@enum_type = 'TARGET')
      SELECT @where_clause = N'WHERE (o.id = sn.operator_id) AND (sn.operator_id = ' + CONVERT(VARCHAR(10), @target_id) + N') AND (sn.alert_id = ' + CONVERT(VARCHAR(10), @id) + N')'
  END
  IF (@object_type = 'ALERTS')
  BEGIN
    IF (@enum_type = 'ALL')
      SELECT @from_clause = @from_clause + N' AND (sn.operator_id = ' + CONVERT(VARCHAR(10), @id) + N')'

    IF (@enum_type = 'ACTUAL')
      SELECT @where_clause = N'WHERE (a.id = sn.alert_id) AND (sn.operator_id = ' + CONVERT(VARCHAR(10), @id) + N') AND (sn.notification_method & ' + CONVERT(VARCHAR, @notification_method) + N' <> 0)'

    IF (@enum_type = 'TARGET')
      SELECT @where_clause = N'WHERE (a.id = sn.alert_id) AND (sn.alert_id = ' + CONVERT(VARCHAR(10), @target_id) + N') AND (sn.operator_id = ' + CONVERT(VARCHAR(10), @id) + N')'
  END

  -- Add the has_email and has_pager columns to the SELECT clause
  IF (@object_type = 'OPERATORS')
  BEGIN
    SELECT @select_clause = @select_clause + N', has_email = PATINDEX(N''%[^ ]%'', ISNULL(o.email_address, N''''))'
    SELECT @select_clause = @select_clause + N', has_pager = PATINDEX(N''%[^ ]%'', ISNULL(o.pager_address, N''''))'
    SELECT @select_clause = @select_clause + N', has_netsend = PATINDEX(N''%[^ ]%'', ISNULL(o.netsend_address, N''''))'
  END
  IF (@object_type = 'ALERTS')
  BEGIN
    -- NOTE: We return counts so that the UI can detect 'unchecking' the last notification
    SELECT @select_clause = @select_clause + N', has_email = (SELECT COUNT(*) FROM sysnotifications WHERE (alert_id = a.id) AND ((notification_method & 1) = 1)) '
    SELECT @select_clause = @select_clause + N', has_pager = (SELECT COUNT(*) FROM sysnotifications WHERE (alert_id = a.id) AND ((notification_method & 2) = 2)) '
    SELECT @select_clause = @select_clause + N', has_netsend = (SELECT COUNT(*) FROM sysnotifications WHERE (alert_id = a.id) AND ((notification_method & 4) = 4)) '
  END

  EXECUTE (@select_clause + @from_clause + @where_clause)

  RETURN(@@error) -- 0 means success
END
go

DUMP TRANSACTION msdb WITH NO_LOG
go

/**************************************************************/
/*                                                            */
/*                    T  R  I G  G  E  R  S                   */
/*                                                            */
/**************************************************************/

/**************************************************************/
/* DROP THE OLD 6.x TRIGGERS                                  */
/* [multiple triggers of the same type are allowed in 7.0]    */
/**************************************************************/

IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'NewOrChangedNotification')
              AND (type = 'TR')))
  DROP TRIGGER NewOrChangedNotification

IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'RemovedNotification')
              AND (type = 'TR')))
  DROP TRIGGER RemovedNotification
go

/**************************************************************/
/* TRIG_NOTIFICATION_INS_OR_UPD                               */
/**************************************************************/

PRINT ''
PRINT 'Creating trigger trig_notification_ins_or_upd...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'trig_notification_ins_or_upd')
              AND (type = 'TR')))
  DROP TRIGGER trig_notification_ins_or_upd
go
CREATE TRIGGER trig_notification_ins_or_upd
ON msdb.dbo.sysnotifications
FOR INSERT,
    UPDATE
AS
BEGIN
  SET NOCOUNT ON

  -- First, throw out 'non-notification' rows
  DELETE FROM msdb.dbo.sysnotifications
  WHERE (notification_method = 0)

  -- Reset the has_notification flag for the affected alerts
  UPDATE msdb.dbo.sysalerts
  SET has_notification = 0
  FROM inserted           i,
       msdb.dbo.sysalerts sa
  WHERE (i.alert_id = sa.id)

  -- Update sysalerts.has_notification (for email)
  UPDATE msdb.dbo.sysalerts
  SET has_notification = has_notification | 1
  FROM msdb.dbo.sysalerts        sa,
       msdb.dbo.sysnotifications sn,
       inserted                  i
  WHERE (sa.id = sn.alert_id)
    AND (sa.id = i.alert_id)
    AND ((sn.notification_method & 1) = 1)

  -- Update sysalerts.has_notification (for pager)
  UPDATE msdb.dbo.sysalerts
  SET has_notification = has_notification | 2
  FROM msdb.dbo.sysalerts        sa,
       msdb.dbo.sysnotifications sn,
       inserted                  i
  WHERE (sa.id = sn.alert_id)
    AND (sa.id = i.alert_id)
    AND ((sn.notification_method & 2) = 2)

  -- Update sysalerts.has_notification (for netsend)
  UPDATE msdb.dbo.sysalerts
  SET has_notification = has_notification | 4
  FROM msdb.dbo.sysalerts        sa,
       msdb.dbo.sysnotifications sn,
       inserted                  i
  WHERE (sa.id = sn.alert_id)
    AND (sa.id = i.alert_id)
    AND ((sn.notification_method & 4) = 4)
END
go

/**************************************************************/
/* TRIG_NOTIFICATION_DELETE                                   */
/**************************************************************/

PRINT ''
PRINT 'Creating trigger trig_notification_delete...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'trig_notification_delete')
              AND (type = 'TR')))
  DROP TRIGGER trig_notification_delete
go
CREATE TRIGGER trig_notification_delete
ON msdb.dbo.sysnotifications
FOR DELETE
AS
BEGIN
  SET NOCOUNT ON

  -- Reset the has_notification flag for the affected alerts
  UPDATE msdb.dbo.sysalerts
  SET has_notification = 0
  FROM deleted            d,
       msdb.dbo.sysalerts sa
  WHERE (d.alert_id = sa.id)

  -- Update sysalerts.has_notification (for email)
  UPDATE msdb.dbo.sysalerts
  SET has_notification = has_notification | 1
  FROM msdb.dbo.sysalerts        sa,
       msdb.dbo.sysnotifications sn,
       deleted                   d
  WHERE (sa.id = sn.alert_id)
    AND (sa.id = d.alert_id)
    AND ((sn.notification_method & 1) = 1)

  -- Update sysalerts.has_notification (for pager)
  UPDATE msdb.dbo.sysalerts
  SET has_notification = has_notification | 2
  FROM msdb.dbo.sysalerts        sa,
       msdb.dbo.sysnotifications sn,
       deleted                   d
  WHERE (sa.id = sn.alert_id)
    AND (sa.id = d.alert_id)
    AND ((sn.notification_method & 2) = 2)

  -- Update sysalerts.has_notification (for netsend)
  UPDATE msdb.dbo.sysalerts
  SET has_notification = has_notification | 4
  FROM msdb.dbo.sysalerts        sa,
       msdb.dbo.sysnotifications sn,
       deleted                   d
  WHERE (sa.id = sn.alert_id)
    AND (sa.id = d.alert_id)
    AND ((sn.notification_method & 4) = 4)
END
go

DUMP TRANSACTION msdb WITH NO_LOG
go

/**************************************************************/
/*                                                            */
/*          D  E  F  A  U  L  T    A  L  E  R  T  S           */
/*                                                            */
/**************************************************************/

PRINT ''
PRINT 'Installing default alerts...'
go

EXECUTE master.dbo.sp_altermessage 9002, 'WITH_LOG', TRUE
go

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysalerts
                WHERE (name = N'Demo: Full msdb log')
                   OR ((severity = 0) AND
                       (message_id = 9002) AND
                       (database_name = N'msdb') AND
                       (event_description_keyword IS NULL) AND
                       (performance_condition IS NULL))))
  EXECUTE msdb.dbo.sp_add_alert @name = N'Demo: Full msdb log',
                                @message_id = 9002,
                                @severity = 0,
                                @enabled = 1,
                                @delay_between_responses = 10,
                                @database_name = N'msdb',
                                @notification_message = NULL,
                                @job_name = NULL,
                                @event_description_keyword = NULL,
                                @include_event_description_in = 5 -- Email and NetSend
go

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysalerts
                WHERE (name = N'Demo: Full tempdb')
                   OR ((severity = 0) AND
                       (message_id = 9002) AND
                       (database_name = N'tempdb') AND
                       (event_description_keyword IS NULL) AND
                       (performance_condition IS NULL))))
  EXECUTE msdb.dbo.sp_add_alert @name = N'Demo: Full tempdb',
                                @message_id = 9002,
                                @severity = 0,
                                @enabled = 1,
                                @delay_between_responses = 10,
                                @database_name = N'tempdb',
                                @notification_message = NULL,
                                @job_name = NULL,
                                @event_description_keyword = NULL,
                                @include_event_description_in = 5 -- Email and NetSend
go

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysalerts
                WHERE (name = N'Demo: Sev. 19 Errors')
                   OR ((severity = 19) AND
                       (message_id = 0) AND
                       (database_name IS NULL) AND
                       (event_description_keyword IS NULL) AND
                       (performance_condition IS NULL))))
  EXECUTE msdb.dbo.sp_add_alert @name = N'Demo: Sev. 19 Errors',
                                @message_id = 0,
                                @severity = 19,
                                @enabled = 1,
                                @delay_between_responses = 10,
                                @database_name = NULL,
                                @notification_message = NULL,
                                @job_name = NULL,
                                @event_description_keyword = NULL,
                                @include_event_description_in = 5 -- Email and NetSend
go

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysalerts
                WHERE (name = N'Demo: Sev. 20 Errors')
                   OR ((severity = 20) AND
                       (message_id = 0) AND
                       (database_name IS NULL) AND
                       (event_description_keyword IS NULL) AND
                       (performance_condition IS NULL))))
  EXECUTE msdb.dbo.sp_add_alert @name = N'Demo: Sev. 20 Errors',
                                @message_id = 0,
                                @severity = 20,
                                @enabled = 1,
                                @delay_between_responses = 10,
                                @database_name = NULL,
                                @notification_message = NULL,
                                @job_name = NULL,
                                @event_description_keyword = NULL,
                                @include_event_description_in = 5 -- Email and NetSend
go

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysalerts
                WHERE (name = N'Demo: Sev. 21 Errors')
                   OR ((severity = 21) AND
                       (message_id = 0) AND
                       (database_name IS NULL) AND
                       (event_description_keyword IS NULL) AND
                       (performance_condition IS NULL))))
  EXECUTE msdb.dbo.sp_add_alert @name = N'Demo: Sev. 21 Errors',
                                @message_id = 0,
                                @severity = 21,
                                @enabled = 1,
                                @delay_between_responses = 10,
                                @database_name = NULL,
                                @notification_message = NULL,
                                @job_name = NULL,
                                @event_description_keyword = NULL,
                                @include_event_description_in = 5 -- Email and NetSend
go

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysalerts
                WHERE (name = N'Demo: Sev. 22 Errors')
                   OR ((severity = 22) AND
                       (message_id = 0) AND
                       (database_name IS NULL) AND
                       (event_description_keyword IS NULL) AND
                       (performance_condition IS NULL))))
  EXECUTE msdb.dbo.sp_add_alert @name = N'Demo: Sev. 22 Errors',
                                @message_id = 0,
                                @severity = 22,
                                @enabled = 1,
                                @delay_between_responses = 10,
                                @database_name = NULL,
                                @notification_message = NULL,
                                @job_name = NULL,
                                @event_description_keyword = NULL,
                                @include_event_description_in = 5 -- Email and NetSend
go

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysalerts
                WHERE name = N'Demo: Sev. 23 Errors'
                   OR ((severity = 23) AND
                       (message_id = 0) AND
                       (database_name IS NULL) AND
                       (event_description_keyword IS NULL) AND
                       (performance_condition IS NULL))))
  EXECUTE msdb.dbo.sp_add_alert @name = N'Demo: Sev. 23 Errors',
                                @message_id = 0,
                                @severity = 23,
                                @enabled = 1,
                                @delay_between_responses = 10,
                                @database_name = NULL,
                                @notification_message = NULL,
                                @job_name = NULL,
                                @event_description_keyword = NULL,
                                @include_event_description_in = 5 -- Email and NetSend
go

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysalerts
                WHERE (name = N'Demo: Sev. 24 Errors')
                   OR ((severity = 24) AND
                       (message_id = 0) AND
                       (database_name IS NULL) AND
                       (event_description_keyword IS NULL) AND
                       (performance_condition IS NULL))))
  EXECUTE msdb.dbo.sp_add_alert @name = N'Demo: Sev. 24 Errors',
                                @message_id = 0,
                                @severity = 24,
                                @enabled = 1,
                                @delay_between_responses = 10,
                                @database_name = NULL,
                                @notification_message = NULL,
                                @job_name = NULL,
                                @event_description_keyword = NULL,
                                @include_event_description_in = 5 -- Email and NetSend
go

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysalerts
                WHERE (name = N'Demo: Sev. 25 Errors')
                   OR ((severity = 25) AND
                       (message_id = 0) AND
                       (database_name IS NULL) AND
                       (event_description_keyword IS NULL) AND
                       (performance_condition IS NULL))))
  EXECUTE msdb.dbo.sp_add_alert @name = N'Demo: Sev. 25 Errors',
                                @message_id = 0,
                                @severity = 25,
                                @enabled = 1,
                                @delay_between_responses = 10,
                                @database_name = NULL,
                                @notification_message = NULL,
                                @job_name = NULL,
                                @event_description_keyword = NULL,
                                @include_event_description_in = 5 -- Email and NetSend
go


/**************************************************************/
/**                                                          **/
/**       B A C K U P   H I S T O R Y   S U P P O R T        **/
/**                                                          **/
/**************************************************************/

/**************************************************************/
/* T A B L E S                                                */
/**************************************************************/

/**************************************************************/
/* BACKUPMEDIASET                                             */
/**************************************************************/

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = 'backupmediaset')))
BEGIN
  PRINT ''
  PRINT 'Creating table backupmediaset...'

  CREATE TABLE backupmediaset
  (
  media_set_id       INT IDENTITY     NOT NULL PRIMARY KEY,
  media_uuid         UNIQUEIDENTIFIER NULL,  -- Null if this media set only one media family
  media_family_count TINYINT          NULL,  -- Number of media families in the media set
  name               NVARCHAR(128)    NULL,
  description        NVARCHAR(255)    NULL,
  software_name      NVARCHAR(128)    NULL,
  software_vendor_id INT              NULL,
  MTF_major_version  TINYINT          NULL
  )

  CREATE INDEX backupmediasetuuid ON backupmediaset (media_uuid)
END
go

/**************************************************************/
/* BACKUPMEDIAFAMILY                                          */
/**************************************************************/

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = 'backupmediafamily')))
BEGIN
  PRINT ''
  PRINT 'Creating table backupmediafamily...'

  CREATE TABLE backupmediafamily
  (
  media_set_id           INT              NOT NULL REFERENCES backupmediaset(media_set_id),
  family_sequence_number TINYINT          NOT NULL, -- Raid sequence number
  media_family_id        UNIQUEIDENTIFIER NULL,     -- This will be a uuid in MTF 2.0, allow space
  media_count            INT              NULL,     -- Number of media in the family
  logical_device_name    NVARCHAR(128)    NULL,     -- Name from sysdevices, if any
  physical_device_name   NVARCHAR(260)    NULL,     -- To facilitate restores from online media (disk)
  device_type            TINYINT          NULL,  -- Disk, tape, pipe, ...
  physical_block_size    INT              NULL
  PRIMARY KEY (media_set_id, family_sequence_number)
  )

  CREATE INDEX backupmediafamilyuuid ON backupmediafamily (media_family_id)
END
go

/**************************************************************/
/* BACKUPSET - One row per backup operation.                  */
/**************************************************************/

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = 'backupset')))
BEGIN
  PRINT ''
  PRINT 'Creating table backupset...'

  CREATE TABLE backupset
  (
  backup_set_id          INT IDENTITY     NOT NULL PRIMARY KEY,
  backup_set_uuid        UNIQUEIDENTIFIER NOT NULL,
  media_set_id           INT              NOT NULL REFERENCES backupmediaset(media_set_id),
  first_family_number    TINYINT          NULL,  -- family number & media number of the media
  first_media_number     SMALLINT         NULL,  -- containing the start of this backup (first SSET)
  last_family_number     TINYINT          NULL,  -- family number & media number of the media
  last_media_number      SMALLINT         NULL,  -- containing the end of this backup (ESET after MBC)
  catalog_family_number  TINYINT          NULL,  -- family number & media number of the media
  catalog_media_number   SMALLINT         NULL,  -- containing the start of the 'directory' data stream

  position               INT              NULL,  -- For FILE=
  expiration_date        DATETIME         NULL,

  -- From SSET...
  software_vendor_id     INT              NULL,  -- Might want table for sw vendors
  name                   NVARCHAR(128)    NULL,
  description            NVARCHAR(255)    NULL,
  user_name              NVARCHAR(128)    NULL,
  software_major_version TINYINT          NULL,	
  software_minor_version TINYINT          NULL,	
  software_build_version SMALLINT         NULL,
  time_zone              SMALLINT         NULL,		
  mtf_minor_version      TINYINT          NULL,

  -- From CONFIG_INFO...
  first_lsn              NUMERIC(25,0)    NULL,
  last_lsn               NUMERIC(25,0)    NULL,
  checkpoint_lsn         NUMERIC(25,0)    NULL,
  database_backup_lsn    NUMERIC(25,0)    NULL,
  database_creation_date DATETIME         NULL,
  backup_start_date      DATETIME         NULL,
  backup_finish_date     DATETIME         NULL,
  type                   CHAR(1)          NULL,
  sort_order             SMALLINT         NULL,
  code_page              SMALLINT         NULL,
  compatibility_level    TINYINT          NULL,
  database_version       INT              NULL,
  backup_size            NUMERIC(20,0)    NULL,
  database_name          NVARCHAR(128)    NULL,
  server_name            NVARCHAR(128)    NULL,
  machine_name           NVARCHAR(128)    NULL,
  flags                  INT              NULL,
  unicode_locale         INT              NULL,
  unicode_compare_style  INT              NULL,
  collation_name         NVARCHAR(128)    NULL
  )

  CREATE INDEX backupsetuuid ON backupset (backup_set_uuid)
END
ELSE
BEGIN
  IF NOT EXISTS (
    select * from msdb.dbo.syscolumns where name='flags' and id =
        (select id from msdb.dbo.sysobjects where name='backupset'))

    ALTER TABLE backupset ADD flags INT NULL

  IF NOT EXISTS (
    select * from msdb.dbo.syscolumns where name='collation_name' and id =
        (select id from msdb.dbo.sysobjects where name='backupset'))

    ALTER TABLE backupset ADD
      unicode_locale         INT              NULL,
      unicode_compare_style  INT              NULL,
      collation_name         NVARCHAR(128)    NULL
END
go

/**************************************************************/
/* BACKUPFILE - One row per file backed up (data file, log    */
/*              file)                                         */
/**************************************************************/

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = 'backupfile')))
BEGIN
  PRINT ''
  PRINT 'Creating table backupfile...'

  CREATE TABLE backupfile
  (
  backup_set_id          INT           NOT NULL REFERENCES backupset(backup_set_id),
  first_family_number    TINYINT       NULL,     -- Family number & media number of he first media
  first_media_number     SMALLINT      NULL,     -- containing this file
  filegroup_name         NVARCHAR(128) NULL,
  page_size              INT           NULL,
  file_number            NUMERIC(10,0) NOT NULL,
  backed_up_page_count   NUMERIC(10,0) NULL,
  file_type              CHAR(1)       NULL,     -- database or log
  source_file_block_size NUMERIC(10,0) NULL,
  file_size              NUMERIC(20,0) NULL,
  logical_name           NVARCHAR(128) NULL,
  physical_drive         VARCHAR(260)  NULL,     -- Drive or partition name
  physical_name          VARCHAR(260)  NULL      -- Remainder of physical (OS) filename
  PRIMARY KEY (backup_set_id, file_number)
  )
END
go

/**************************************************************/
/* RESTOREHISTORY - One row per restore operation.            */
/**************************************************************/

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = 'restorehistory')))
BEGIN
  PRINT ''
  PRINT 'Creating table restorehistory...'

  CREATE TABLE restorehistory
  (
  restore_history_id        INT           NOT NULL IDENTITY PRIMARY KEY,
  restore_date              DATETIME      NULL,
  destination_database_name NVARCHAR(128) NULL,
  user_name                 NVARCHAR(128) NULL,
  backup_set_id             INT           NOT NULL REFERENCES backupset(backup_set_id), -- The backup set restored
  restore_type              CHAR(1)       NULL,      -- Database, file, filegroup, log, verifyonly, ...

  -- Various options...
  replace                   BIT           NULL,      -- Replace(1), Noreplace(0)
  recovery                  BIT           NULL,      -- Recovery(1), Norecovery(0)
  restart                   BIT           NULL,      -- Restart(1), Norestart(0)
  stop_at                   DATETIME      NULL,
  device_count              TINYINT       NULL,      -- Can be less than number of media families
  stop_at_mark_name         NVARCHAR(128) NULL,
  stop_before               BIT           NULL
  )

  CREATE INDEX restorehistorybackupset ON restorehistory (backup_set_id)
END

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.syscolumns
                WHERE (name in ('stop_at_mark_name', 'stop_before'))
                AND (id = (SELECT id
                          FROM msdb.dbo.sysobjects
                          WHERE (name = 'restorehistory')))))
BEGIN
  IF NOT EXISTS (
    select * from msdb.dbo.syscolumns where name='stop_before' and id =
        (select id from msdb.dbo.sysobjects where name='restorehistory'))
  BEGIN
    PRINT ''
    PRINT 'Adding columns to table restorehistory...'

    ALTER TABLE restorehistory
      ADD
      stop_at_mark_name       NVARCHAR(128) NULL,
      stop_before             BIT           NULL
  END
END
go

/**************************************************************/
/* RESTOREFILE - One row per file restored.                   */
/**************************************************************/

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = 'restorefile')))
BEGIN
  PRINT ''
  PRINT 'Creating table restorefile...'

  CREATE TABLE restorefile
  (
  restore_history_id     INT           NOT NULL REFERENCES restorehistory(restore_history_id),
  file_number            NUMERIC(10,0) NULL,      -- Note: requires database to make unique
  destination_phys_drive VARCHAR(260)  NULL,
  destination_phys_name  VARCHAR(260)  NULL
  )
END
go

/**************************************************************/
/* RESTOREFILEGROUP - One row per filegroup restored.         */
/**************************************************************/

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = 'restorefilegroup')))
BEGIN
  PRINT ''
  PRINT 'Creating table restorefilegroup...'

  CREATE TABLE restorefilegroup
  (
  restore_history_id INT           NOT NULL REFERENCES restorehistory(restore_history_id),
  filegroup_name     NVARCHAR(128) NULL
  )
END
go

/**************************************************************/
/* LOGMARKHISTORY - One row per log mark generated            */
/**************************************************************/

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = 'logmarkhistory')))
BEGIN
  PRINT ''
  PRINT 'Creating table logmarkhistory...'

  CREATE TABLE logmarkhistory
  (
  database_name     NVARCHAR(128)   NOT NULL,
  mark_name         NVARCHAR(128)   NOT NULL,
  description       NVARCHAR(255)   NULL,
  user_name         NVARCHAR(128)   NOT NULL,
  lsn               NUMERIC(25,0)   NOT NULL,
  mark_time         DATETIME        NOT NULL
  )

  CREATE INDEX logmarkhistory1 ON logmarkhistory (database_name, mark_name)

  CREATE INDEX logmarkhistory2 ON logmarkhistory (database_name, lsn)
END
go

IF (EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = 'trig_backupset_delete')
                  AND (OBJECTPROPERTY(id, 'IsTrigger') != 0)))
BEGIN
  DROP TRIGGER trig_backupset_delete
END
go

CREATE TRIGGER trig_backupset_delete ON msdb.dbo.backupset FOR DELETE AS
BEGIN
  DELETE FROM msdb.dbo.logmarkhistory from deleted
  WHERE (msdb.dbo.logmarkhistory.database_name = deleted.database_name)
    AND (msdb.dbo.logmarkhistory.lsn >= deleted.first_lsn)
    AND (msdb.dbo.logmarkhistory.lsn < deleted.last_lsn)
END
go

/**************************************************************/
/**                                                          **/
/**           O B J E C T    P E R M I S S I O N S           **/
/**                                                          **/
/**************************************************************/

PRINT ''
PRINT 'Setting object permissions...'
go

-- Permissions a non-SA needs to create/update/delete a job
GRANT EXECUTE ON sp_get_sqlagent_properties  TO PUBLIC
GRANT EXECUTE ON sp_help_category            TO PUBLIC
GRANT EXECUTE ON sp_enum_sqlagent_subsystems TO PUBLIC
GRANT EXECUTE ON sp_add_jobserver            TO PUBLIC
GRANT EXECUTE ON sp_delete_jobserver         TO PUBLIC
GRANT SELECT  ON syscategories               TO PUBLIC

GRANT EXECUTE ON sp_purge_jobhistory TO PUBLIC
GRANT EXECUTE ON sp_help_jobhistory  TO PUBLIC

GRANT EXECUTE ON sp_add_jobstep    TO PUBLIC
GRANT EXECUTE ON sp_update_jobstep TO PUBLIC
GRANT EXECUTE ON sp_delete_jobstep TO PUBLIC
GRANT EXECUTE ON sp_help_jobstep   TO PUBLIC

GRANT EXECUTE ON sp_add_jobschedule    TO PUBLIC
GRANT EXECUTE ON sp_update_jobschedule TO PUBLIC
GRANT EXECUTE ON sp_delete_jobschedule TO PUBLIC
GRANT EXECUTE ON sp_help_jobschedule   TO PUBLIC

GRANT EXECUTE ON sp_add_job    TO PUBLIC
GRANT EXECUTE ON sp_update_job TO PUBLIC
GRANT EXECUTE ON sp_delete_job TO PUBLIC
GRANT EXECUTE ON sp_help_job   TO PUBLIC
GRANT EXECUTE ON sp_start_job  TO PUBLIC
GRANT EXECUTE ON sp_stop_job   TO PUBLIC

GRANT EXECUTE ON sp_help_jobserver TO PUBLIC

GRANT EXECUTE ON sp_check_for_owned_jobs     TO PUBLIC
GRANT EXECUTE ON sp_check_for_owned_jobsteps TO PUBLIC
GRANT EXECUTE ON sp_get_jobstep_db_username  TO PUBLIC
GRANT EXECUTE ON sp_post_msx_operation       TO PUBLIC
GRANT EXECUTE ON sp_get_job_alerts           TO PUBLIC

GRANT EXECUTE ON sp_uniquetaskname TO PUBLIC
GRANT EXECUTE ON sp_addtask        TO PUBLIC
GRANT EXECUTE ON sp_updatetask     TO PUBLIC
GRANT EXECUTE ON sp_droptask       TO PUBLIC
GRANT EXECUTE ON sp_helptask       TO PUBLIC
GRANT EXECUTE ON sp_verifytaskid   TO PUBLIC
GRANT EXECUTE ON sp_reassigntask   TO PUBLIC
GRANT EXECUTE ON sp_helphistory    TO PUBLIC
GRANT EXECUTE ON sp_purgehistory   TO PUBLIC

GRANT SELECT ON sysjobs_view  TO PUBLIC
GRANT SELECT ON systasks_view TO PUBLIC
REVOKE ALL ON systargetservers                 FROM PUBLIC
REVOKE ALL ON systargetservers_view            FROM PUBLIC
REVOKE ALL ON systargetservergroups            FROM PUBLIC
REVOKE ALL ON systargetservergroupmembers      FROM PUBLIC
REVOKE INSERT, UPDATE, DELETE ON syscategories FROM PUBLIC
REVOKE ALL ON sysalerts                        FROM PUBLIC
REVOKE ALL ON sysoperators                     FROM PUBLIC
REVOKE ALL ON sysnotifications                 FROM PUBLIC

GRANT SELECT ON backupfile        TO PUBLIC
GRANT SELECT ON backupmediafamily TO PUBLIC
GRANT SELECT ON backupmediaset    TO PUBLIC
GRANT SELECT ON backupset         TO PUBLIC
GRANT SELECT ON restorehistory    TO PUBLIC
GRANT SELECT ON restorefile       TO PUBLIC
GRANT SELECT ON restorefilegroup  TO PUBLIC
GRANT SELECT ON logmarkhistory    TO PUBLIC
go

-- Create the TargetServers role (for use by target servers when downloading jobs / uploading status)
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysusers
            WHERE (name = N'TargetServersRole')
              AND (issqlrole = 1)))
BEGIN
  -- If there are no members in the role, then drop and re-create it
  IF ((SELECT COUNT(*)
       FROM msdb.dbo.sysusers   su,
            msdb.dbo.sysmembers sm
       WHERE (su.uid = sm.groupuid)
         AND (su.name = N'TargetServersRole')
         AND (su.issqlrole = 1)) = 0)
  BEGIN
    EXECUTE msdb.dbo.sp_droprole @rolename = N'TargetServersRole'
    EXECUTE msdb.dbo.sp_addrole @rolename = N'TargetServersRole'
  END
END
ELSE
  EXECUTE msdb.dbo.sp_addrole @rolename = N'TargetServersRole'

GRANT SELECT, UPDATE, DELETE ON sysdownloadlist               TO TargetServersRole
GRANT SELECT, UPDATE         ON sysjobservers                 TO TargetServersRole
GRANT SELECT, UPDATE         ON systargetservers              TO TargetServersRole
GRANT EXECUTE                ON sp_downloaded_row_limiter     TO TargetServersRole
GRANT SELECT                 ON sysjobs                       TO TargetServersRole
GRANT EXECUTE                ON sp_help_jobstep               TO TargetServersRole
GRANT EXECUTE                ON sp_help_jobschedule           TO TargetServersRole
GRANT EXECUTE                ON sp_sqlagent_refresh_job       TO TargetServersRole
GRANT EXECUTE                ON sp_sqlagent_probe_msx         TO TargetServersRole
GRANT EXECUTE                ON sp_sqlagent_check_msx_version TO TargetServersRole

--revoke TargetServerRole permission that would allow modifying of jobs
DENY ALL ON sp_add_jobserver     TO TargetServersRole
DENY ALL ON sp_delete_jobserver  TO TargetServersRole

DENY ALL ON sp_add_jobstep    TO TargetServersRole
DENY ALL ON sp_update_jobstep TO TargetServersRole
DENY ALL ON sp_delete_jobstep TO TargetServersRole

DENY ALL ON sp_add_jobschedule    TO TargetServersRole
DENY ALL ON sp_update_jobschedule TO TargetServersRole
DENY ALL ON sp_delete_jobschedule TO TargetServersRole

DENY ALL ON sp_add_job    TO TargetServersRole
DENY ALL ON sp_update_job TO TargetServersRole
DENY ALL ON sp_delete_job TO TargetServersRole
DENY ALL ON sp_start_job  TO TargetServersRole
DENY ALL ON sp_stop_job   TO TargetServersRole

DENY ALL ON sp_post_msx_operation       TO TargetServersRole

DENY ALL ON sp_addtask        TO TargetServersRole
DENY ALL ON sp_updatetask     TO TargetServersRole
DENY ALL ON sp_droptask       TO TargetServersRole
DENY ALL ON sp_reassigntask   TO TargetServersRole
DENY ALL ON sp_purgehistory   TO TargetServersRole

-------------------------------------------------------------------------

go

USE msdb
go

/**************************************************************/
/**************************************************************/
/* BEGIN DTS                                                  */
/**************************************************************/
/**************************************************************/

/**************************************************************/
/* DTS TABLES                                                 */
/* These are never dropped since we dropped MSDB itself if    */
/* this was an upgrade from pre-beta3, and we preserve beta3  */
/* packages.  However, we need to add the owner_sid column    */
/* if it's not there already, defaulting to sa ownership.     */
/**************************************************************/

/**************************************************************/
/* SYSDTSCATEGORIES                                           */
/**************************************************************/
IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = N'sysdtscategories')))
BEGIN
  PRINT ''
  PRINT 'Creating table sysdtscategories...'
  CREATE TABLE sysdtscategories
  (
    name                   sysname             NOT NULL,
    description            NVARCHAR(1024)      NULL,
    id                     UNIQUEIDENTIFIER    NOT NULL,
    parentid               UNIQUEIDENTIFIER    NOT NULL,         --// IID_NULL if a predefined root category
    CONSTRAINT pk_dtscategories PRIMARY KEY (id),
    CONSTRAINT uq_dtscategories_name_parent UNIQUE (name, parentid)
  )

  /**************************************************************/
  /* PREDEFINED DTS CATEGORIES                                  */
  /**************************************************************/
  PRINT ''
  PRINT 'Adding predefined dts categories...'
  --// MUST BE IN SYNC with DTSPkg.h!
  --// These must be INSERTed explicitly as the IID_NULL parent does not exist.
  INSERT sysdtscategories VALUES (N'Local', 'DTS Packages stored on local SQL Server', 'B8C30000-A282-11D1-B7D9-00C04FB6EFD5', '00000000-0000-0000-0000-000000000000')
  INSERT sysdtscategories VALUES (N'Repository', 'DTS Packages stored on Repository', 'B8C30001-A282-11D1-B7D9-00C04FB6EFD5', '00000000-0000-0000-0000-000000000000')

  --// Default location for DTSPackage.SaveToSQLServer
  INSERT sysdtscategories VALUES (N'LocalDefault', 'Default local subcategory for DTS Packages', 'B8C30002-A282-11D1-B7D9-00C04FB6EFD5', 'B8C30000-A282-11D1-B7D9-00C04FB6EFD5')
END
GO

/**************************************************************/
/* SYSDTSPACKAGES                                             */
/**************************************************************/
IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = N'sysdtspackages')))
BEGIN
  PRINT ''
  PRINT 'Creating table sysdtspackages...'
  CREATE TABLE sysdtspackages
  (
    name                   sysname             NOT NULL,                   --// May have multiple ids
    id                     UNIQUEIDENTIFIER    NOT NULL,                   --// May have multiple versionids
    versionid              UNIQUEIDENTIFIER    NOT NULL UNIQUE,
    description            NVARCHAR(1024)      NULL,
    categoryid             UNIQUEIDENTIFIER    NOT NULL REFERENCES sysdtscategories (id),
    createdate             DATETIME,
    owner                  sysname,
    packagedata            IMAGE,
    owner_sid              VARBINARY(85)       NOT NULL DEFAULT SUSER_SID(N'sa'),
    packagetype            int                 NOT NULL DEFAULT 0          --// DTSPkgType_Default
    CONSTRAINT pk_dtspackages PRIMARY KEY (id, versionid)
  )
END ELSE BEGIN
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.syscolumns
                  WHERE name = N'owner_sid' AND id = OBJECT_ID(N'sysdtspackages')))
  BEGIN
    PRINT ''
    PRINT 'Altering table sysdtspackages for owner_sid and packagetype...'
    ALTER TABLE sysdtspackages ADD owner_sid VARBINARY(85) NOT NULL DEFAULT SUSER_SID(N'sa'),
                                   packagetype int NOT NULL DEFAULT 0      --// DTSPkgType_Default
  END
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.syscolumns
                  WHERE name = N'packagetype' AND id = OBJECT_ID(N'sysdtspackages')))
  BEGIN
    PRINT ''
    PRINT 'Altering table sysdtspackages for packagetype...'
    ALTER TABLE sysdtspackages ADD packagetype int NOT NULL DEFAULT 0      --// DTSPkgType_Default
  END
END
GO

/**************************************************************/
/* SP_MAKE_DTSPACKAGENAME                                     */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_get_dtsversion...'
go
IF OBJECT_ID(N'sp_get_dtsversion') IS NOT NULL
  DROP PROCEDURE sp_get_dtsversion
go
CREATE PROCEDURE sp_get_dtsversion
AS
  /* Values for this are same as @@microsoftversion */
  /* @@microsoftversion format is 0xaaiibbbb (aa = major, ii = minor, bb[bb] = build #) */
  DECLARE @i INT
  select @i = 0x08000000	/* Must be in hex! */

  /* Select the numeric value, and a conversion to make it readable */
  select N'Microsoft SQLDTS Scripts' = @i, N'Version' = convert(binary(4), @i)
GO
GRANT EXECUTE ON sp_get_dtsversion TO PUBLIC
GO

/**************************************************************/
/* SP_MAKE_DTSPACKAGENAME                                     */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_make_dtspackagename...'
go
IF OBJECT_ID(N'sp_make_dtspackagename') IS NOT NULL
  DROP PROCEDURE sp_make_dtspackagename
go
CREATE PROCEDURE sp_make_dtspackagename
  @categoryid UNIQUEIDENTIFIER,
  @name sysname OUTPUT,
  @flags int = 0
AS
  SET NOCOUNT ON

  --// If NULL catid, default to the LocalDefault category.
  IF (@categoryid IS NULL)
    SELECT @categoryid = 'B8C30002-A282-11d1-B7D9-00C04FB6EFD5'

  --// Validate category.  We'll generate a unique name within category.
  DECLARE @stringfromclsid NVARCHAR(200)
  IF NOT EXISTS (SELECT * FROM sysdtscategories WHERE id = @categoryid)
  BEGIN
    SELECT @stringfromclsid = CONVERT(NVARCHAR(50), @categoryid)
    RAISERROR(14262, 16, 1, '@categoryid', @stringfromclsid)
    RETURN(1) -- Failure
  END

  --// Autogenerate the next name in our format.
  DECLARE @max sysname, @i INT, @spidchar NVARCHAR(20)

  --// Any logic we use may have collisions so let's get the max and wrap if we have to.
  --// @@spid is necessary for guaranteed uniqueness but makes it ugly so for now, don't use it.
  --// Note:  use only 9 characters as it makes the pattern match easier without overflowing.
  SELECT @i = 0, @spidchar = '_'               -- + LTRIM(STR(@@spid)) + '_'
  SELECT @max = MAX(name)
    FROM sysdtspackages
    WHERE name like 'DTS_' + @spidchar + '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
  IF @max IS NOT NULL
    SELECT @i = CONVERT(INT, SUBSTRING(@max, (DATALENGTH(N'DTS_' + @spidchar) / 2) + 1, 9))

  --// Wrap if needed.  Find a gap in the names.
  IF @i < 999999999
  BEGIN
    SELECT @i = @i + 1
  END ELSE BEGIN
    SELECT @i = 1
    DECLARE @existingname sysname
    DECLARE hC CURSOR LOCAL FOR SELECT name FROM sysdtspackages WHERE categoryid = @categoryid ORDER BY name FOR READ ONLY
    OPEN hC
    FETCH NEXT FROM hC INTO @existingname
    WHILE @@FETCH_STATUS = 0 AND @i < 999999999
    BEGIN
      SELECT @name = 'DTS_' + @spidchar + REPLICATE('0', 9 - DATALENGTH(LTRIM(STR(@i)))) + LTRIM(STR(@i))
      IF @existingname > @name
        BREAK
      SELECT @i = @i + 1
      FETCH NEXT FROM hC INTO @existingname
    END
    CLOSE hC
    DEALLOCATE hC
  END

  --// Set the name.
  SELECT @name = 'DTS_' + @spidchar + REPLICATE('0', 9 - DATALENGTH(LTRIM(STR(@i)))) + LTRIM(STR(@i))
  IF (@flags & 1) <> 0
    SELECT @name
GO
GRANT EXECUTE ON sp_make_dtspackagename TO PUBLIC
GO

/**************************************************************/
/* SP_ADD_DTSPACKAGE                                          */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_add_dtspackage...'
GO
IF OBJECT_ID(N'sp_add_dtspackage') IS NOT NULL
  DROP PROCEDURE sp_add_dtspackage
GO
CREATE PROCEDURE sp_add_dtspackage
  @name sysname,
  @id UNIQUEIDENTIFIER,
  @versionid UNIQUEIDENTIFIER,
  @description NVARCHAR(255),
  @categoryid UNIQUEIDENTIFIER,
  @owner sysname,
  @packagedata IMAGE,
  @packagetype int = 0		--// DTSPkgType_Default
AS
  SET NOCOUNT ON

  --// If NULL catid, default to the LocalDefault category.
  IF (@categoryid IS NULL)
    SELECT @categoryid = 'B8C30002-A282-11d1-B7D9-00C04FB6EFD5'

  --// Autogenerate name if it came in NULL.  If it didn't, the below will validate uniqueness.
  IF DATALENGTH(@name) = 0
    SELECT @name = NULL
  IF @name IS NULL
  BEGIN
    --// First see if they specified a new version based on id instead of name.
    if @id IS NOT NULL
    BEGIN
      SELECT @name = name
        FROM sysdtspackages WHERE @id = id
      IF @name IS NOT NULL
        GOTO AddPackage          -- OK, add with the existing name
    END

    --// Name not available, autogenerate one.
    exec sp_make_dtspackagename @categoryid, @name OUTPUT
    GOTO AddPackage
  END

  --// Verify name unique within category.  Allow a new versionid of the same name though.
  IF EXISTS (SELECT * FROM sysdtspackages WHERE name = @name AND categoryid = @categoryid AND id <> @id)
  BEGIN
    RAISERROR (14590, -1, -1, @name)
    RETURN(1) -- Failure
  END

  --// Verify that the same id is not getting a different name.
  IF EXISTS (SELECT * FROM sysdtspackages WHERE id = @id AND name <> @name)
  BEGIN
    DECLARE @stringfromclsid NVARCHAR(200)
    SELECT @stringfromclsid = CONVERT(NVARCHAR(50), @id)
    RAISERROR (14597, -1, -1, @stringfromclsid)
    RETURN(1) -- Failure
  END

  --// Verify all versions of a package go in the same category.
  IF EXISTS (SELECT * FROM sysdtspackages WHERE id = @id AND categoryid <> @categoryid)
  BEGIN
    RAISERROR (14596, -1, -1, @name)
    RETURN(1) -- Failure
  END

  --// The real information is in the IMAGE; the rest is "documentary".
  --// Therefore, there is no need to verify anything.
  --// The REFERENCE in sysdtspackages will validate @categoryid.
AddPackage:

  --// We will use the original owner_sid for all new versions - all must have the same owner.
  --// New packages will get the current login's SID as owner_sid.
  DECLARE @owner_sid VARBINARY(85)
  SELECT @owner_sid = MIN(owner_sid) FROM sysdtspackages WHERE id = @id
  IF @@rowcount = 0 OR @owner_sid IS NULL
  BEGIN
    SELECT @owner_sid = SUSER_SID()
  END ELSE BEGIN
    --// Only the owner of DTS Package ''%s'' or a member of the sysadmin role may create new versions of it.
    IF (@owner_sid <> SUSER_SID() AND (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1))
    BEGIN
      RAISERROR (14586, -1, -1, @name)
      RETURN(1) -- Failure
    END
  END

  --// Everything checks out, add the package or its new version.
  INSERT sysdtspackages (
    name,
    id,
    versionid,
    description,
    categoryid,
    createdate,
    owner,
    packagedata,
    owner_sid,
	packagetype
  ) VALUES (
    @name,
    @id,
    @versionid,
    @description,
    @categoryid,
    GETDATE(),
    @owner,
    @packagedata,
    @owner_sid,
	@packagetype
  )
  RETURN 0    -- SUCCESS
GO
GRANT EXECUTE ON sp_add_dtspackage TO PUBLIC
GO

/**************************************************************/
/* SP_DROP_DTSPACKAGE                                         */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_drop_dtspackage...'
go
IF OBJECT_ID(N'sp_drop_dtspackage') IS NOT NULL
  DROP PROCEDURE sp_drop_dtspackage
go
CREATE PROCEDURE sp_drop_dtspackage
  @name sysname,
  @id UNIQUEIDENTIFIER,
  @versionid UNIQUEIDENTIFIER
AS
  SET NOCOUNT ON

  --// Does the specified package (uniquely) exist?  Referencing by name only may not be unique.
  --// We do a bit of a hack here as SQL can't handle a DISTINCT clause with UNIQUEIDENTIFIER.
  --// @id will get the first id returned; if only name specified, see if there are more.
  DECLARE @findid UNIQUEIDENTIFIER
  SELECT @findid = id FROM sysdtspackages
    WHERE (@name IS NOT NULL OR @id IS NOT NULL OR @versionid IS NOT NULL)
      AND (@name IS NULL OR @name = name)
      AND (@id IS NULL OR @id = id)
      AND (@versionid IS NULL or @versionid = versionid)
  IF @@rowcount = 0
  BEGIN
    DECLARE @pkgnotfound NVARCHAR(200)
    DECLARE @dts_package_res NVARCHAR(100)
    SELECT @pkgnotfound = FORMATMESSAGE(14599) + ' = ''' + ISNULL(@name, FORMATMESSAGE(14589)) + '''; ' + FORMATMESSAGE(14588) + ' {'
    SELECT @pkgnotfound = @pkgnotfound + CASE WHEN @id IS NULL THEN FORMATMESSAGE(14589) ELSE CONVERT(NVARCHAR(50), @id) END + '}.{'
    SELECT @pkgnotfound = @pkgnotfound + CASE WHEN @versionid IS NULL THEN FORMATMESSAGE(14589) ELSE CONVERT(NVARCHAR(50), @versionid) END + '}'
    SELECT @dts_package_res = FORMATMESSAGE(14594)
    RAISERROR(14262, 16, 1, @dts_package_res, @pkgnotfound)
    RETURN(1) -- Failure
  END ELSE IF @name IS NOT NULL AND @id IS NULL AND @versionid IS NULL AND
      EXISTS (SELECT * FROM sysdtspackages WHERE name = @name AND id <> @findid)
  BEGIN
    RAISERROR(14595, -1, -1, @name)
    RETURN(1) -- Failure
  END
  SELECT @id = @findid

  --// Only the owner of DTS Package ''%s'' or a member of the sysadmin role may drop it or any of its versions.
  --// sp_add_dtspackage ensures that all versions have the same owner_sid.
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    IF (NOT EXISTS (SELECT * FROM sysdtspackages WHERE id = @id AND owner_sid = SUSER_SID()))
    BEGIN
      SELECT @name = name FROM sysdtspackages WHERE id = @id
      RAISERROR (14587, -1, -1, @name)
      RETURN(1) -- Failure
    END
  END

  --// If @versionid is NULL, drop all versions of name, else only the @versionid version.
  DELETE sysdtspackages
  WHERE id = @id
    AND (@versionid IS NULL OR @versionid = versionid)
  RETURN 0    -- SUCCESS
go
GRANT EXECUTE ON sp_drop_dtspackage TO PUBLIC
go

/**************************************************************/
/* SP_REASSIGN_DTSPACKAGEOWNER                                */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_reassign_dtspackageowner...'
go
IF OBJECT_ID(N'sp_reassign_dtspackageowner') IS NOT NULL
  DROP PROCEDURE sp_reassign_dtspackageowner
go
CREATE PROCEDURE sp_reassign_dtspackageowner
  @name sysname,
  @id UNIQUEIDENTIFIER,
  @newloginname sysname
AS
  SET NOCOUNT ON

  --// First, is this a valid login?
  IF SUSER_SID(@newloginname) IS NULL
  BEGIN
    RAISERROR(14262, -1, -1, '@newloginname', @newloginname)
    RETURN(1) -- Failure
  END

  --// Does the specified package (uniquely) exist?  Referencing by name only may not be unique.
  --// We do a bit of a hack here as SQL can't handle a DISTINCT clause with UNIQUEIDENTIFIER.
  --// @id will get the first id returned; if only name specified, see if there are more.
  DECLARE @findid UNIQUEIDENTIFIER
  SELECT @findid = id FROM sysdtspackages
    WHERE (@name IS NOT NULL OR @id IS NOT NULL)
      AND (@name IS NULL OR @name = name)
      AND (@id IS NULL OR @id = id)
  IF @@rowcount = 0
  BEGIN
    DECLARE @pkgnotfound NVARCHAR(200)
    DECLARE @dts_package_res NVARCHAR(100)
    SELECT @pkgnotfound = FORMATMESSAGE(14599) + ' = ''' + ISNULL(@name, FORMATMESSAGE(14589)) + '''; ' + FORMATMESSAGE(14588) + ' {'
    SELECT @pkgnotfound = @pkgnotfound + CASE WHEN @id IS NULL THEN FORMATMESSAGE(14589) ELSE CONVERT(NVARCHAR(50), @id) END + '}.{'
    SELECT @pkgnotfound = @pkgnotfound + FORMATMESSAGE(14589) + '}'
    SELECT @dts_package_res = FORMATMESSAGE(14594)
    RAISERROR(14262, 16, 1, @dts_package_res, @pkgnotfound)
    RETURN(1) -- Failure
  END ELSE IF @name IS NOT NULL AND @id IS NULL AND
      EXISTS (SELECT * FROM sysdtspackages WHERE name = @name AND id <> @findid)
  BEGIN
    RAISERROR(14595, -1, -1, @name)
    RETURN(1) -- Failure
  END
  SELECT @id = @findid

  --// Only the owner of DTS Package ''%s'' or a member of the sysadmin role may reassign its ownership.
  --// sp_add_dtspackage ensures that all versions have the same owner_sid.
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    IF (NOT EXISTS (SELECT * FROM sysdtspackages WHERE id = @id AND owner_sid = SUSER_SID()))
    BEGIN
      SELECT @name = name FROM sysdtspackages WHERE id = @id
      RAISERROR (14585, -1, -1, @name)
      RETURN(1) -- Failure
    END
  END

  --// Everything checks out, so reassign the owner.
  --// Note that @newloginname may be a sql server login rather than a network user,
  --// which is not quite the same as when a package is created.
  UPDATE sysdtspackages
    SET owner_sid = SUSER_SID(@newloginname),
	    owner = @newloginname
	WHERE id = @id

  RETURN 0    -- SUCCESS
GO
GRANT EXECUTE ON sp_reassign_dtspackageowner TO PUBLIC
GO

/**************************************************************/
/* SP_GET_DTSPACKAGE                                          */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_get_dtspackage...'
go
IF OBJECT_ID(N'sp_get_dtspackage') IS NOT NULL
  DROP PROCEDURE sp_get_dtspackage
go
CREATE PROCEDURE sp_get_dtspackage
  @name sysname,
  @id UNIQUEIDENTIFIER,
  @versionid UNIQUEIDENTIFIER
AS
  SET NOCOUNT ON

  --// Does the specified package (uniquely) exist?  Dropping by name only may not be unique.
  --// We do a bit of a hack here as SQL can't handle a DISTINCT clause with UNIQUEIDENTIFIER.
  --// @id will get the first id returned; if only name specified, see if there are more.
  DECLARE @findid UNIQUEIDENTIFIER
  SELECT @findid = id FROM sysdtspackages
    WHERE (@name IS NOT NULL OR @id IS NOT NULL OR @versionid IS NOT NULL)
      AND (@name IS NULL OR @name = name)
      AND (@id IS NULL OR @id = id)
      AND (@versionid IS NULL or @versionid = versionid)
  IF @@rowcount = 0
  BEGIN
    DECLARE @pkgnotfound NVARCHAR(200)
    DECLARE @dts_package_res NVARCHAR(100)
    SELECT @pkgnotfound = FORMATMESSAGE(14599) + ' = ''' + ISNULL(@name, FORMATMESSAGE(14589)) + '''; ' + FORMATMESSAGE(14588) + ' {'
    SELECT @pkgnotfound = @pkgnotfound + CASE WHEN @id IS NULL THEN FORMATMESSAGE(14589) ELSE CONVERT(NVARCHAR(50), @id) END + '}.{'
    SELECT @pkgnotfound = @pkgnotfound + CASE WHEN @versionid IS NULL THEN FORMATMESSAGE(14589) ELSE CONVERT(NVARCHAR(50), @versionid) END + '}'
    SELECT @dts_package_res = FORMATMESSAGE(14594)
    RAISERROR(14262, 16, 1, @dts_package_res, @pkgnotfound)
    RETURN(1) -- Failure
  END ELSE IF @name IS NOT NULL AND @id IS NULL AND @versionid IS NULL AND
      EXISTS (SELECT * FROM sysdtspackages WHERE name = @name AND id <> @findid)
  BEGIN
    RAISERROR(14595, -1, -1, @name)
    RETURN(1) -- Failure
  END
  SELECT @id = @findid

  --// If @versionid is NULL, select all versions of name, else only the @versionid version.
  --// This must return the IMAGE as the rightmost column.
  SELECT
    name,
    id,
    versionid,
    description,
    createdate,
    owner,
    pkgsize = datalength(packagedata),
    packagedata,
    isowner = CASE WHEN (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 1 OR owner_sid = SUSER_SID()) THEN 1 ELSE 0 END,
	packagetype
  FROM sysdtspackages
  WHERE id = @id
    AND (@versionid IS NULL OR @versionid = versionid)
  ORDER BY name, createdate DESC

  RETURN 0    -- SUCCESS
go
GRANT EXECUTE ON sp_get_dtspackage TO PUBLIC
go

/**************************************************************/
/* SP_REASSIGN_DTSPACKAGECATEGORY                             */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_reassign_dtspackagecategory...'
go
IF OBJECT_ID(N'sp_reassign_dtspackagecategory') IS NOT NULL
  DROP PROCEDURE sp_reassign_dtspackagecategory
go
CREATE PROCEDURE sp_reassign_dtspackagecategory
  @packageid UNIQUEIDENTIFIER,
  @categoryid UNIQUEIDENTIFIER
AS
  SET NOCOUNT ON

  --// Does the package exist?
  DECLARE @stringfromclsid NVARCHAR(200)
  IF NOT EXISTS (SELECT * from sysdtspackages WHERE id = @packageid)
  BEGIN
    SELECT @stringfromclsid = CONVERT(NVARCHAR(50), @packageid)
    RAISERROR(14262, 16, 1, '@packageid', @stringfromclsid)
    RETURN(1) -- Failure
  END

  --// Does the category exist?
  IF NOT EXISTS (SELECT * FROM sysdtscategories WHERE id = @categoryid)
  BEGIN
    SELECT @stringfromclsid = CONVERT(NVARCHAR(50), @categoryid)
    RAISERROR(14262, 16, 1, '@categoryid', @stringfromclsid)
    RETURN(1) -- Failure
  END

  UPDATE sysdtspackages SET categoryid = @categoryid WHERE id = @packageid
go

/**************************************************************/
/* SP_ENUM_DTSPACKAGES                                        */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_enum_dtspackages...'
go
IF OBJECT_ID(N'sp_enum_dtspackages') IS NOT NULL
  DROP PROCEDURE sp_enum_dtspackages
go
CREATE PROCEDURE sp_enum_dtspackages
  @name_like sysname = '%',
  @description_like NVARCHAR(255) = '%',
  @categoryid UNIQUEIDENTIFIER = NULL,
  @flags INT = 0,          --// Bitmask:  0x01 == return image data
                           --//           0x02 == recursive (packagenames and categorynames only)
                           --//           0x04 == all versions (default == only most-recent-versions)
                           --//           0x08 == all prior versions versions (not most-recent; requires @id)
  @id UNIQUEIDENTIFIER = NULL,    --// If non-NULL, enum versions of this package.
  @wanttype int = NULL            --// If non-NULL, enum only packages of the given type
AS
  IF (@flags & 0x02) <> 0
    GOTO DO_RECURSE

  --// Just return the non-IMAGE stuff - sp_get_dtspackage will return the
  --// actual dtspackage info.
  DECLARE @latestversiondate datetime
  SELECT @latestversiondate = NULL
  IF (@flags & 0x08 = 0x08)
  BEGIN
    SELECT @latestversiondate = MAX(t.createdate) FROM sysdtspackages t WHERE t.id = @id
    IF @latestversiondate IS NULL
    BEGIN
      DECLARE @pkgnotfound NVARCHAR(200)
      DECLARE @dts_package_res NVARCHAR(100)
      SELECT @pkgnotfound = FORMATMESSAGE(14599) + ' = ' + FORMATMESSAGE(14589) + '; ' + FORMATMESSAGE(14588) + ' {'
      SELECT @pkgnotfound = @pkgnotfound + CASE WHEN @id IS NULL THEN FORMATMESSAGE(14589) ELSE CONVERT(NVARCHAR(50), @id) END + '}.{'
      SELECT @pkgnotfound = @pkgnotfound + FORMATMESSAGE(14589) + '}'
      SELECT @dts_package_res = FORMATMESSAGE(14594)
      RAISERROR(14262, 16, 1, @dts_package_res, @pkgnotfound)
      RETURN(1) -- Failure
    END
  END
  SELECT
    p.name,
    p.id,
    p.versionid,
    p.description,
    p.createdate,
    p.owner,
    size = datalength(p.packagedata),
    packagedata = CASE (@flags & 0x01) WHEN 0 THEN NULL ELSE p.packagedata END,
    isowner = CASE WHEN (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 1 OR p.owner_sid = SUSER_SID()) THEN 1 ELSE 0 END,
	p.packagetype
  FROM sysdtspackages p
  WHERE (@name_like IS NULL OR p.name LIKE @name_like)
    AND (@description_like IS NULL OR p.description LIKE @description_like)
    AND (@categoryid IS NULL OR p.categoryid = @categoryid)
    AND (@id is NULL OR p.id = @id)
    -- These filter by version
    AND ( (@flags & 0x08 = 0x08 AND p.createdate < @latestversiondate)
          OR ( (@flags & 0x04 = 0x04)
		       OR (@flags & 0x08 = 0 AND p.createdate = (SELECT MAX(t.createdate) FROM sysdtspackages t WHERE t.id = p.id))
             )
        )
	AND (@wanttype is NULL or p.packagetype = @wanttype)
  ORDER BY id, createdate DESC
  RETURN 0    -- SUCCESS

  DO_RECURSE:
  DECLARE @packagesfound INT
  SELECT @packagesfound = 0

  --// Starting parent category.  If null, start at root.
  if (@categoryid IS NULL)
    SELECT @categoryid = '00000000-0000-0000-0000-000000000000'

  IF EXISTS (SELECT *
      FROM sysdtspackages p INNER JOIN sysdtscategories c ON p.categoryid = c.id
      WHERE p.categoryid = @categoryid
      AND (@name_like IS NULL OR p.name LIKE @name_like)
      AND (@description_like IS NULL OR p.description LIKE @description_like)
    )
    SELECT @packagesfound = 1

  IF (@packagesfound <> 0)
  BEGIN
    --// Identify the category and list its Packages.
    SELECT 'Level' = @@nestlevel, 'PackageName' = p.name, 'CategoryName' = c.name
        FROM sysdtspackages p INNER JOIN sysdtscategories c ON p.categoryid = c.id
        WHERE p.categoryid = @categoryid
        AND (@name_like IS NULL OR p.name LIKE @name_like)
        AND (@description_like IS NULL OR p.description LIKE @description_like)
  END

  --// List its subcategories' packages
  DECLARE @childid UNIQUEIDENTIFIER
  DECLARE hC CURSOR LOCAL FOR SELECT id FROM sysdtscategories c WHERE parentid = @categoryid ORDER BY c.name FOR READ ONLY
  OPEN hC
  FETCH NEXT FROM hC INTO @childid
  WHILE @@FETCH_STATUS = 0
  BEGIN
    EXECUTE sp_enum_dtspackages @name_like, @description_like, @childid, @flags
    FETCH NEXT FROM hC INTO @childid
  END
  CLOSE hC
  DEALLOCATE hC
  RETURN 0
go

GRANT EXECUTE ON sp_enum_dtspackages TO PUBLIC
go

/**************************************************************/
/* SP_ADD_DTSCATEGORY                                         */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_add_dtscategory...'
go
IF OBJECT_ID(N'sp_add_dtscategory') IS NOT NULL
  DROP PROCEDURE sp_add_dtscategory
go
CREATE PROCEDURE sp_add_dtscategory
  @name sysname,
  @description NVARCHAR(1024),
  @id UNIQUEIDENTIFIER,
  @parentid UNIQUEIDENTIFIER
AS
  SET NOCOUNT ON

  --// If parentid is NULL, use 'Local'
  IF @parentid IS NULL
    SELECT @parentid = 'B8C30000-A282-11d1-B7D9-00C04FB6EFD5'

  --// First do some simple validation of "non-assert" cases.  UI should validate others and the table
  --// definitions will act as an "assert", but we check here (with a nice message) for user-error stuff
  --// it would be hard for UI to validate.
  IF NOT EXISTS (SELECT * FROM sysdtscategories WHERE id = @parentid)
  BEGIN
    DECLARE @stringfromclsid NVARCHAR(200)
    SELECT @stringfromclsid = CONVERT(NVARCHAR(50), @parentid)
    RAISERROR(14262, 16, 1, '@parentid', @stringfromclsid)
    RETURN(1) -- Failure
  END

  IF EXISTS (SELECT * FROM sysdtscategories WHERE name = @name AND parentid = @parentid)
  BEGIN
    RAISERROR(14591, 16, -1, @name)
    RETURN(1) -- Failure
  END

  --// id uniqueness is ensured by the primary key.
  INSERT sysdtscategories (
    name,
    description,
    id,
    parentid
  ) VALUES (
    @name,
    @description,
    @id,
    @parentid
  )
  RETURN 0    -- SUCCESS
go

/**************************************************************/
/* SP_DROP_DTSCATEGORY                                        */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_drop_dtscategory...'
go
IF OBJECT_ID(N'sp_drop_dtscategory') IS NOT NULL
  DROP PROCEDURE sp_drop_dtscategory
go
CREATE PROCEDURE sp_drop_dtscategory
  @name_like sysname,
  @id UNIQUEIDENTIFIER = NULL,
  @flags INT = 0           --// Bitmask:  0x01 == recursive (drop all subcategories and packages)
AS
  SET NOCOUNT ON

  --// Temp table in case recursion is needed.
  CREATE TABLE #recurse(id UNIQUEIDENTIFIER, passcount INT DEFAULT(0))

  IF (@name_like IS NOT NULL)
  BEGIN
    INSERT #recurse (id) SELECT id FROM sysdtscategories WHERE name LIKE @name_like
    IF @@rowcount = 0
    BEGIN
      RAISERROR(14262, 16, 1, '@name_like', @name_like)
      RETURN(1) -- Failure
    END
    IF @@rowcount > 1
    BEGIN
      RAISERROR(14592, 16, -1, @name_like)
      RETURN(1) -- Failure
    END
    SELECT @name_like = name, @id = id FROM sysdtscategories WHERE name LIKE @name_like
  END ELSE BEGIN
    --// Verify the id.  @name_like will be NULL if we're here so no need to initialize.
    SELECT @name_like = name FROM sysdtscategories WHERE id = @id
    IF @name_like IS NULL
    BEGIN
      DECLARE @stringfromclsid NVARCHAR(200)
      SELECT @stringfromclsid = CONVERT(NVARCHAR(50), @id)
      RAISERROR(14262, 16, 1, '@id', @stringfromclsid)
      RETURN(1) -- Failure
    END
    INSERT #recurse (id) VALUES (@id)
  END

  --// We now have a unique category.

  --// Cannot drop the predefined categories (or the root, which already failed above as IID_NULL
  --// is not an id in sysdtscategories).  These will be at top level.
  IF @id IN (
    'B8C30000-A282-11d1-B7D9-00C04FB6EFD5'
    , 'B8C30001-A282-11d1-B7D9-00C04FB6EFD5'
    , 'B8C30002-A282-11d1-B7D9-00C04FB6EFD5'
  ) BEGIN
      RAISERROR(14598, 16, 1)
      RETURN(1) -- Failure
  END

  --// Check for subcategories or packages.
  IF EXISTS (SELECT * FROM sysdtspackages WHERE categoryid = @id)
             OR EXISTS (SELECT * FROM sysdtscategories WHERE parentid = @id)
  BEGIN
    --// It does.  Make sure recursion was requested.
    IF (@flags & 0x01 = 0)
    BEGIN
      RAISERROR(14593, 16, -1, @name_like)
      RETURN(1) -- Failure
    END

    --// Fill up #recurse.
    UPDATE #recurse SET passcount = 0
    WHILE (1 = 1)
    BEGIN
      UPDATE #recurse SET passcount = passcount + 1
      INSERT #recurse (id, passcount)
        SELECT c.id, 0 FROM sysdtscategories c INNER JOIN #recurse r ON c.parentid = r.id
        WHERE passcount = 1
      IF @@rowcount = 0
        BREAK
    END
  END

  DELETE sysdtspackages FROM sysdtspackages INNER JOIN #recurse ON sysdtspackages.categoryid = #recurse.id
  DELETE sysdtscategories FROM sysdtscategories INNER JOIN #recurse ON sysdtscategories.id = #recurse.id
  RETURN(0) -- SUCCESS
go

/**************************************************************/
/* SP_MODIFY_DTSCATEGORY                                      */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_modify_dtscategory...'
go
IF OBJECT_ID(N'sp_modify_dtscategory') IS NOT NULL
  DROP PROCEDURE sp_modify_dtscategory
go
CREATE PROCEDURE sp_modify_dtscategory
  @id UNIQUEIDENTIFIER,
  @name sysname,
  @description NVARCHAR(1024),
  @parentid UNIQUEIDENTIFIER
AS
  SET NOCOUNT ON

  --// Validate.
  DECLARE @stringfromclsid NVARCHAR(200)
  IF NOT EXISTS (SELECT * FROM sysdtscategories WHERE id = @id)
  BEGIN
    SELECT @stringfromclsid = CONVERT(NVARCHAR(50), @id)
    RAISERROR(14262, 16, 1, '@id', @stringfromclsid)
    RETURN(1) -- Failure
  END

  IF NOT EXISTS (SELECT * FROM sysdtscategories WHERE id = @parentid)
  BEGIN
    SELECT @stringfromclsid = CONVERT(NVARCHAR(50), @parentid)
    RAISERROR(14262, 16, 1, '@parentid', @stringfromclsid)
    RETURN(1) -- Failure
  END

  --// Check the name uniqueness within parent, but make sure the id is different (we may just be renaming
  --// without reassigning parentage).
  IF EXISTS (SELECT * FROM sysdtscategories WHERE name = @name AND parentid = @parentid and id <> @id)
  BEGIN
    RAISERROR(14591, 16, -1, @name)
    RETURN(1) -- Failure
  END

  UPDATE sysdtscategories SET name = @name, description = @description, parentid = @parentid
    WHERE id = @id
  RETURN(0) -- SUCCESS
go

/**************************************************************/
/* SP_ENUM_DTSCATEGORIES                                      */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_enum_dtscategories...'
go
IF OBJECT_ID(N'sp_enum_dtscategories') IS NOT NULL
  DROP PROCEDURE sp_enum_dtscategories
go
CREATE PROCEDURE sp_enum_dtscategories
  @parentid UNIQUEIDENTIFIER = NULL,
  @flags INT = 0           --// Bitmask:  0x01 == recursive (enum all subcategories; names only)
AS
  IF (@flags & 0x01) <> 0
    GOTO DO_RECURSE

  --// Go to the root if no parentid specified
  IF @parentid IS NULL
    SELECT @parentid = '00000000-0000-0000-0000-000000000000'

  --// 'No results' is valid here.
  SELECT name, description, id FROM sysdtscategories WHERE parentid = @parentid
    ORDER BY name
  RETURN 0

  DO_RECURSE:

  --// Identify the category.
  IF @@nestlevel <> 0
    SELECT 'Level' = @@nestlevel, name FROM sysdtscategories WHERE id = @parentid

  --// List its subcategories
  DECLARE @childid UNIQUEIDENTIFIER
  DECLARE hC CURSOR LOCAL FOR SELECT id FROM sysdtscategories c WHERE parentid = @parentid ORDER BY c.name FOR READ ONLY
  OPEN hC
  FETCH NEXT FROM hC INTO @childid
  WHILE @@FETCH_STATUS = 0
  BEGIN
    EXECUTE sp_enum_dtscategories @childid, @flags
    FETCH NEXT FROM hC INTO @childid
  END
  CLOSE hC
  DEALLOCATE hC
  RETURN 0
go

/**************************************************************/
/* Drop Beta1 DTS Logging objects                             */
/**************************************************************/

if OBJECT_ID('sysdtspackagestepslog') IS NOT NULL
BEGIN
	PRINT ''
	PRINT 'Dropping Beta1 logging tables and stored procedures...'
	DROP TABLE sysdtspackagestepslog
	IF OBJECT_ID('sysdtspackagelog') IS NOT NULL
		DROP TABLE sysdtspackagelog
	IF OBJECT_ID('sp_log_dtspackage') IS NOT NULL
		DROP PROCEDURE sp_log_dtspackage
	IF OBJECT_ID('sp_log_dtspackagesteps') IS NOT NULL
		DROP PROCEDURE sp_log_dtspackagesteps
END

/**************************************************************/
/* SYSDTSPACKAGELOG                                           */
/**************************************************************/
if OBJECT_ID('sysdtspackagelog') IS NULL
BEGIN
  PRINT ''
  PRINT 'Creating table sysdtspackagelog...'
  CREATE TABLE sysdtspackagelog
  (
    name				sysname			NOT NULL,
    description				NVARCHAR(1000)		NULL,
    id					UNIQUEIDENTIFIER	NOT NULL,
    versionid				UNIQUEIDENTIFIER	NOT NULL,
    lineagefull				UNIQUEIDENTIFIER	NOT NULL PRIMARY KEY,
    lineageshort			INT			NOT NULL,
    starttime				DATETIME		NOT NULL,
    endtime				DATETIME		NULL,
    elapsedtime				double precision	NULL,
    computer				sysname			NOT NULL,
    operator				sysname			NOT NULL,
    logdate				datetime		NOT NULL DEFAULT GETDATE(),
    errorcode				INT			NULL,
    errordescription			NVARCHAR(2000)		NULL
  )
END

/**************************************************************/
/* SYSDTSSTEPLOG                                              */
/**************************************************************/
if OBJECT_ID('sysdtssteplog') IS NULL
BEGIN
  PRINT ''
  PRINT 'Creating table sysdtssteplog...'
  CREATE TABLE sysdtssteplog
  (
    stepexecutionid			BIGINT IDENTITY (1, 1)	NOT NULL PRIMARY KEY,
    lineagefull				UNIQUEIDENTIFIER	NOT NULL 
					REFERENCES sysdtspackagelog(lineagefull)
					ON DELETE CASCADE,
    stepname				sysname			NOT NULL,
    stepexecstatus			int				NULL,
    stepexecresult			int				NULL,
    starttime				DATETIME		NOT NULL,
    endtime				DATETIME		NULL,
    elapsedtime				double precision	NULL,
    errorcode				INT			NULL,
    errordescription			NVARCHAR(2000)		NULL,
    progresscount			BIGINT			NULL
  )
END ELSE BEGIN
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.syscolumns
                  WHERE name = N'stepexecresult' AND id = OBJECT_ID(N'sysdtssteplog')))
  BEGIN
    PRINT ''
    PRINT 'Altering table sysdtssteplog...'
    ALTER TABLE sysdtssteplog ADD stepexecresult INT NULL DEFAULT 0
  END
END

/**************************************************************/
/* SYSDTSTASKLOG                                              */
/**************************************************************/
if OBJECT_ID('sysdtstasklog') IS NULL
BEGIN
  PRINT ''
  PRINT 'Creating table sysdtstasklog...'
  CREATE TABLE sysdtstasklog
  (
    stepexecutionid			BIGINT			NOT NULL
					REFERENCES sysdtssteplog (stepexecutionid)
					ON DELETE CASCADE,
    sequenceid				INT			NOT NULL,
    errorcode				INT			NOT NULL,
    description				NVARCHAR(2000)		NULL,
    PRIMARY KEY				(stepexecutionid, sequenceid)
  )
END

/**************************************************************/
/* SP_LOG_DTSPACKAGE_BEGIN                                    */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_log_dtspackage_begin...'
GO
IF OBJECT_ID(N'sp_log_dtspackage_begin') IS NOT NULL
  DROP PROCEDURE sp_log_dtspackage_begin
GO
CREATE PROCEDURE sp_log_dtspackage_begin
  @name			sysname,
  @description		NVARCHAR(1000),
  @id			UNIQUEIDENTIFIER,
  @versionid		UNIQUEIDENTIFIER,
  @lineagefull		UNIQUEIDENTIFIER,
  @lineageshort		INT,
  @starttime		DATETIME,
  @computer		sysname,
  @operator		sysname
AS
  SET NOCOUNT ON

  INSERT sysdtspackagelog (
    name,
    description,
    id,
    versionid,
    lineagefull,
    lineageshort,
    starttime,
    computer,
    operator
  ) VALUES (
    @name,
    @description,
    @id,
    @versionid,
    @lineagefull,
    @lineageshort,
    @starttime,
    @computer,
    @operator
  )
  RETURN 0    -- SUCCESS
GO
GRANT EXECUTE ON sp_log_dtspackage_begin TO PUBLIC
GO

/**************************************************************/
/* SP_LOG_DTSPACKAGE_END                                      */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_log_dtspackage_end...'
GO
IF OBJECT_ID(N'sp_log_dtspackage_end') IS NOT NULL
  DROP PROCEDURE sp_log_dtspackage_end
GO
CREATE PROCEDURE sp_log_dtspackage_end
  @lineagefull		UNIQUEIDENTIFIER,
  @endtime		DATETIME,
  @elapsedtime		double precision,
  @errorcode		INT,
  @errordescription	NVARCHAR(2000)
AS
  SET NOCOUNT ON

  --// Validate lineage.
  DECLARE @stringfromclsid NVARCHAR(200)
  IF NOT EXISTS (SELECT * FROM sysdtspackagelog WHERE lineagefull = @lineagefull)
  BEGIN
    SELECT @stringfromclsid = CONVERT(NVARCHAR(50), @lineagefull)
    RAISERROR(14262, 16, 1, '@lineagefull', @stringfromclsid)
    RETURN(1) -- Failure
  END

  UPDATE sysdtspackagelog
    SET 
        endtime = @endtime,
        elapsedtime = @elapsedtime,
        errorcode = @errorcode,
        errordescription = @errordescription
    WHERE lineagefull = @lineagefull

  RETURN 0    -- SUCCESS
GO
GRANT EXECUTE ON sp_log_dtspackage_end TO PUBLIC
GO

/**************************************************************/
/* SP_LOG_DTSSTEP_BEGIN                                       */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_log_dtsstep_begin...'
GO
IF OBJECT_ID(N'sp_log_dtsstep_begin') IS NOT NULL
  DROP PROCEDURE sp_log_dtsstep_begin
GO
CREATE PROCEDURE sp_log_dtsstep_begin
  @lineagefull		UNIQUEIDENTIFIER,
  @stepname		sysname,
  @starttime		DATETIME
AS
  SET NOCOUNT ON

  --// Validate lineage.
  DECLARE @stringfromclsid NVARCHAR(200)
  IF NOT EXISTS (SELECT * FROM sysdtspackagelog WHERE lineagefull = @lineagefull)
  BEGIN
    SELECT @stringfromclsid = CONVERT(NVARCHAR(50), @lineagefull)
    RAISERROR(14262, 16, 1, '@lineagefull', @stringfromclsid)
    RETURN(1) -- Failure
  END

  INSERT sysdtssteplog (
    lineagefull,
    stepname,
    starttime
  ) VALUES (
    @lineagefull,
    @stepname,
    @starttime
  )

  --// Return the @@identity for sp_log_dtstask and sp_logdtsstep_end
  SELECT @@IDENTITY

  RETURN 0    -- SUCCESS
GO
GRANT EXECUTE ON sp_log_dtsstep_begin TO PUBLIC
GO

/**************************************************************/
/* SP_LOG_DTSSTEP_END                                         */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_log_dtsstep_end...'
GO
IF OBJECT_ID(N'sp_log_dtsstep_end') IS NOT NULL
  DROP PROCEDURE sp_log_dtsstep_end
GO
CREATE PROCEDURE sp_log_dtsstep_end
  @stepexecutionid	BIGINT,
  @stepexecstatus	int,
  @stepexecresult	int,
  @endtime		DATETIME,
  @elapsedtime		double precision,
  @errorcode		INT,
  @errordescription	NVARCHAR(2000),
  @progresscount	BIGINT
AS
  SET NOCOUNT ON

  --// Validate @stepexecutionid.
  DECLARE @stringfromclsid NVARCHAR(200)
  IF NOT EXISTS (SELECT * FROM sysdtssteplog WHERE stepexecutionid = @stepexecutionid)
  BEGIN
    SELECT @stringfromclsid = CONVERT(NVARCHAR(50), @stepexecutionid)
    RAISERROR(14262, 16, 1, '@stepexecutionid', @stringfromclsid)
    RETURN(1) -- Failure
  END

  UPDATE sysdtssteplog
    SET 
        stepexecstatus = @stepexecstatus,
        stepexecresult = @stepexecresult,
        endtime = @endtime,
        elapsedtime = @elapsedtime,
        errorcode = @errorcode,
        errordescription = @errordescription,
        progresscount = @progresscount
    WHERE stepexecutionid = @stepexecutionid

  RETURN 0    -- SUCCESS
GO
GRANT EXECUTE ON sp_log_dtsstep_end TO PUBLIC
GO

/**************************************************************/
/* SP_LOG_DTSTASK                                             */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_log_dtstask...'
GO
IF OBJECT_ID(N'sp_log_dtstask') IS NOT NULL
  DROP PROCEDURE sp_log_dtstask
GO
CREATE PROCEDURE sp_log_dtstask
  @stepexecutionid	BIGINT,
  @sequenceid		INT,
  @errorcode		INT,
  @description		NVARCHAR(2000)
AS
  SET NOCOUNT ON

  --// Validate @stepexecutionid.
  DECLARE @stringfromclsid NVARCHAR(200)
  IF NOT EXISTS (SELECT * FROM sysdtssteplog WHERE stepexecutionid = @stepexecutionid)
  BEGIN
    SELECT @stringfromclsid = CONVERT(NVARCHAR(50), @stepexecutionid)
    RAISERROR(14262, 16, 1, '@stepexecutionid', @stringfromclsid)
    RETURN(1) -- Failure
  END

  INSERT sysdtstasklog (
    stepexecutionid,
    sequenceid,
    errorcode,
    description
  ) VALUES (
    @stepexecutionid,
    @sequenceid,
    @errorcode,
    @description
  )

  RETURN 0    -- SUCCESS
GO
GRANT EXECUTE ON sp_log_dtstask TO PUBLIC
GO

/**************************************************************/
/* SP_ENUM_DTSPACKAGELOG                                      */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_enum_dtspackagelog...'
GO
IF OBJECT_ID(N'sp_enum_dtspackagelog') IS NOT NULL
  DROP PROCEDURE sp_enum_dtspackagelog
GO
CREATE PROCEDURE sp_enum_dtspackagelog
  @name sysname,
  @flags INT = 0,          		--// Bitmask:  0x01 == return only latest
  @id UNIQUEIDENTIFIER = NULL,		--// If non-NULL, use instead of @name.
  @versionid UNIQUEIDENTIFIER = NULL,	--// If non-NULL, use instead of @id or @name
  @lineagefull UNIQUEIDENTIFIER = NULL	--// If non-NULL, use instead of @versionid or @id or @name
AS
  SET NOCOUNT ON

  --// This is used for realtime viewing of package logs, so don't error if no entries
  --// found, simply return an empty result set.
  SELECT
    p.name,
    p.description,
    p.id,
    p.versionid,
    p.lineagefull,
    p.lineageshort,
    p.starttime,
    p.endtime,
    p.elapsedtime,
    p.computer,
    p.operator,
    p.logdate,
    p.errorcode,
    p.errordescription
  FROM sysdtspackagelog p
  WHERE ((@lineagefull IS NULL OR p.lineagefull = @lineagefull)
      AND  (@versionid IS NULL OR p.versionid = @versionid)
      AND (@id IS NULL OR p.id = @id)
      AND (@name IS NULL OR p.name = @name))
    AND ((@flags & 0x01) = 0
      OR p.logdate = 
      (
        SELECT MAX(logdate) 
        FROM sysdtspackagelog d
        WHERE (d.id = p.id)
      )
     )
  ORDER BY logdate 

  RETURN 0    -- SUCCESS
GO
GRANT EXECUTE ON sp_enum_dtspackagelog TO PUBLIC
GO

/**************************************************************/
/* SP_ENUM_DTSSTEPLOG                                         */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_enum_dtssteplog...'
GO
IF OBJECT_ID(N'sp_enum_dtssteplog') IS NOT NULL
  DROP PROCEDURE sp_enum_dtssteplog
GO
CREATE PROCEDURE sp_enum_dtssteplog
  @lineagefull		UNIQUEIDENTIFIER = NULL,	-- all steps in this package execution
  @stepexecutionid	BIGINT = NULL
AS
  SET NOCOUNT ON

  --// This is used for realtime viewing of package logs, so don't error if no entries
  --// found, simply return an empty result set.
  --// This query must be restricted within a single package execution (lineage); it may
  --// be further restricted by stepexecutionid to a single step within that package execution.
  SELECT
    stepexecutionid,
    lineagefull,
    stepname,
    stepexecstatus,
    stepexecresult,
    starttime,
    endtime,
    elapsedtime,
    errorcode,
    errordescription,
    progresscount
  FROM sysdtssteplog
  WHERE (@lineagefull IS NULL OR lineagefull = @lineagefull)
    AND (@stepexecutionid IS NULL OR stepexecutionid = @stepexecutionid)
  ORDER BY stepexecutionid

  RETURN 0    -- SUCCESS
GO
GRANT EXECUTE ON sp_enum_dtssteplog TO PUBLIC
GO

/**************************************************************/
/* SP_ENUM_DTSTASKLOG                                         */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_enum_dtstasklog...'
GO
IF OBJECT_ID(N'sp_enum_dtstasklog') IS NOT NULL
  DROP PROCEDURE sp_enum_dtstasklog
GO
CREATE PROCEDURE sp_enum_dtstasklog
  @stepexecutionid	BIGINT,
  @sequenceid		INT = NULL
AS
  SET NOCOUNT ON

  --// This is used for realtime viewing of package logs, so don't error if no entries
  --// found, simply return an empty result set.
  --// This query must be restricted within a single step execution; it may
  --// be further restricted by stepexecutionid to a single record within that step execution.
  SELECT
    -- stepexecutionid,  -- this is always passed in so we don't need to return it.
    sequenceid,
    errorcode,
    description
  FROM sysdtstasklog
  WHERE (stepexecutionid IS NULL or stepexecutionid = @stepexecutionid)
    AND (@sequenceid IS NULL OR sequenceid = @sequenceid)
  ORDER BY sequenceid

  RETURN 0    -- SUCCESS
GO
GRANT EXECUTE ON sp_enum_dtstasklog TO PUBLIC
GO

/**************************************************************/
/* SP_DUMP_DTSLOG_ALL                                         */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_dump_dtslog_all...'
GO
IF OBJECT_ID(N'sp_dump_dtslog_all') IS NOT NULL
  DROP PROCEDURE sp_dump_dtslog_all
GO
CREATE PROCEDURE sp_dump_dtslog_all
AS
  SET NOCOUNT ON

  --// sysadmin only.
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  DELETE sysdtspackagelog
  RETURN 0    -- SUCCESS
GO
GRANT EXECUTE ON sp_dump_dtslog_all TO PUBLIC
GO

/**************************************************************/
/* SP_DUMP_DTSPACKAGELOG                                      */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_dump_dtspackagelog...'
GO
IF OBJECT_ID(N'sp_dump_dtspackagelog') IS NOT NULL
  DROP PROCEDURE sp_dump_dtspackagelog
GO
CREATE PROCEDURE sp_dump_dtspackagelog
  @name sysname,
  @flags INT = 0,          		--// Bitmask:  0x01 == preserve latest
  @id UNIQUEIDENTIFIER = NULL,		--// If non-NULL, use instead of @name.
  @versionid UNIQUEIDENTIFIER = NULL,	--// If non-NULL, use instead of @id or @name
  @lineagefull UNIQUEIDENTIFIER = NULL	--// If non-NULL, use instead of @versionid or @id or @name
AS
  SET NOCOUNT ON

  --// sysadmin only.
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  --// Don't error if no entries found, as the desired result will be met.
  --// DELETE will CASCADE
  DELETE sysdtspackagelog
  FROM sysdtspackagelog p
  WHERE ((@lineagefull IS NULL OR p.lineagefull = @lineagefull)
      AND  (@versionid IS NULL OR p.versionid = @versionid)
      AND (@id IS NULL OR p.id = @id)
      AND (@name IS NULL OR p.name = @name))
    AND ((@flags & 0x01) = 0
      OR p.logdate < 
      (
        SELECT MAX(logdate) 
        FROM sysdtspackagelog d
        WHERE (d.id = p.id)
      )
     )

  RETURN 0    -- SUCCESS
GO
GRANT EXECUTE ON sp_dump_dtspackagelog TO PUBLIC
GO

/**************************************************************/
/* SP_DUMP_DTSSTEPLOG                                         */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_dump_dtssteplog...'
GO
IF OBJECT_ID(N'sp_dump_dtssteplog') IS NOT NULL
  DROP PROCEDURE sp_dump_dtssteplog
GO
CREATE PROCEDURE sp_dump_dtssteplog
  @lineagefull		UNIQUEIDENTIFIER = NULL,	-- all steps in this package execution
  @stepexecutionid	BIGINT = NULL
AS
  SET NOCOUNT ON

  --// sysadmin only.
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  --// Don't error if no entries found, as the desired result will be met.
  --// DELETE will CASCADE
  DELETE sysdtssteplog
  WHERE (@lineagefull IS NULL OR lineagefull = @lineagefull)
    AND (@stepexecutionid IS NULL OR stepexecutionid = @stepexecutionid)

  RETURN 0    -- SUCCESS
GO
GRANT EXECUTE ON sp_dump_dtssteplog TO PUBLIC
GO

/**************************************************************/
/* SP_DUMP_DTSTASKLOG                                         */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_dump_dtstasklog...'
GO
IF OBJECT_ID(N'sp_dump_dtstasklog') IS NOT NULL
  DROP PROCEDURE sp_dump_dtstasklog
GO
CREATE PROCEDURE sp_dump_dtstasklog
  @stepexecutionid	BIGINT,
  @sequenceid		INT = NULL
AS
  SET NOCOUNT ON

  --// sysadmin only.
  IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
  BEGIN
    RAISERROR(15003, 16, 1, N'sysadmin')
    RETURN(1) -- Failure
  END

  --// Don't error if no entries found, as the desired result will be met.
  DELETE sysdtstasklog
  WHERE (stepexecutionid IS NULL or stepexecutionid = @stepexecutionid)
    AND (@sequenceid IS NULL OR sequenceid = @sequenceid)

  RETURN 0    -- SUCCESS
GO
GRANT EXECUTE ON sp_dump_dtstasklog TO PUBLIC
GO

/**************************************************************/
/*                                                            */
/*  D  B    M  A  I  N  T  E  N  A  N  C  E    P  L  A  N  S  */
/*                                                            */
/**************************************************************/

/**************************************************************/
/* SYSDBMAINTPLANS                                            */
/**************************************************************/

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = N'sysdbmaintplans')
                  AND (type = 'U')))
BEGIN
  PRINT ''
  PRINT 'Creating table sysdbmaintplans...'

  CREATE TABLE sysdbmaintplans
  (
  plan_id                    UNIQUEIDENTIFIER NOT NULL PRIMARY KEY CLUSTERED,
  plan_name                  sysname          NOT NULL,
  date_created               DATETIME         NOT NULL DEFAULT (GETDATE()),
  owner                      sysname          NOT NULL DEFAULT (ISNULL(NT_CLIENT(), SUSER_SNAME())),
  max_history_rows           INT              NOT NULL DEFAULT (0),
  remote_history_server      sysname          NOT NULL DEFAULT (''),
  max_remote_history_rows    INT              NOT NULL DEFAULT (0),
  user_defined_1             INT              NULL,
  user_defined_2             NVARCHAR(100)    NULL,
  user_defined_3             DATETIME         NULL,
  user_defined_4             UNIQUEIDENTIFIER NULL
  )
END
go

-- Add row for "plan 0"
IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysdbmaintplans
                WHERE (plan_id = CONVERT(UNIQUEIDENTIFIER, 0x00))))
  INSERT INTO sysdbmaintplans(plan_id, plan_name, owner) VALUES (0x00, N'All ad-hoc plans', N'sa')
go

/**************************************************************/
/* SYSDBMAINTPLAN_JOBS                                        */
/**************************************************************/

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = N'sysdbmaintplan_jobs')
                  AND (type = 'U')))
BEGIN
  PRINT ''
  PRINT 'Creating table sysdbmaintplan_jobs...'

  CREATE TABLE sysdbmaintplan_jobs
  (
  plan_id UNIQUEIDENTIFIER NOT NULL UNIQUE CLUSTERED (plan_id, job_id)
                                    FOREIGN KEY REFERENCES msdb.dbo.sysdbmaintplans (plan_id),
  job_id  UNIQUEIDENTIFIER NOT NULL
  )
END
go

/**************************************************************/
/* SYSDBMAINTPLAN_DATABASES                                   */
/**************************************************************/

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = N'sysdbmaintplan_databases')
                  AND (type = 'U')))
BEGIN
  PRINT ''
  PRINT 'Creating table sysdbmaintplan_databases...'

  CREATE TABLE sysdbmaintplan_databases
  (
  plan_id       UNIQUEIDENTIFIER NOT NULL UNIQUE CLUSTERED (plan_id, database_name)
                                          FOREIGN KEY REFERENCES msdb.dbo.sysdbmaintplans (plan_id),
  database_name sysname          NOT NULL
  )
END
go

/**************************************************************/
/* SYSDBMAINTPLAN_HISTORY                                     */
/**************************************************************/

IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = N'sysdbmaintplan_history')
                  AND (type = 'U')))
BEGIN
  PRINT ''
  PRINT 'Creating table sysdbmaintplan_history...'

  CREATE TABLE sysdbmaintplan_history
  (
  sequence_id    INT               NOT NULL IDENTITY UNIQUE NONCLUSTERED,
  plan_id        UNIQUEIDENTIFIER  NOT NULL DEFAULT('00000000-0000-0000-0000-000000000000'),
  plan_name      sysname           NOT NULL DEFAULT('All ad-hoc plans'),
  database_name  sysname           NULL,
  server_name    sysname           NOT NULL DEFAULT (CONVERT(sysname, ServerProperty('ServerName'))),
  activity       NVARCHAR(128)     NULL,
  succeeded      BIT               NOT NULL DEFAULT (1),
  end_time       DATETIME          NOT NULL DEFAULT (GETDATE()),
  duration       INT               NULL     DEFAULT (0),
  start_time     AS                DATEADD (ss, -duration, end_time),
  error_number   INT               NOT NULL DEFAULT (0),
  message        NVARCHAR(512)     NULL
  )

  CREATE CLUSTERED INDEX clust ON sysdbmaintplan_history(plan_id)
END
-- ALTER TABLE to correct default constraint 
ELSE
BEGIN
  CREATE TABLE #t
  (
  constraint_type         NVARCHAR(146)  COLLATE database_default NULL,
  constraint_name         sysname        COLLATE database_default NULL,
  delete_action           NVARCHAR(20)   COLLATE database_default NULL,
  update_action           NVARCHAR(20)   COLLATE database_default NULL,
  status_enabled          NVARCHAR(20)   COLLATE database_default NULL,
  status_for_replication  NVARCHAR(20)   COLLATE database_default NULL,
  constraint_keys         NVARCHAR(2126) COLLATE database_default NULL
  )

  INSERT INTO #t EXEC sp_helpconstraint N'sysdbmaintplan_history', 'nomsg'

  DECLARE @constraint_name sysname
  DECLARE @sql NVARCHAR(4000)

  SELECT @constraint_name = constraint_name 
  FROM   #t 
  WHERE  constraint_type = N'DEFAULT on column server_name' 
  AND    constraint_keys = N'(@@servername)'

  DROP TABLE #t

  -- default found
  IF (@constraint_name IS NOT NULL)
  BEGIN
    PRINT ''
    PRINT 'Alter sysdbmaintplan_history ...'
    SELECT @sql = N'ALTER TABLE sysdbmaintplan_history DROP CONSTRAINT ' + @constraint_name
    EXEC (@sql)

    ALTER TABLE sysdbmaintplan_history 
      ADD CONSTRAINT servername_default DEFAULT (CONVERT(sysname, ServerProperty('ServerName')))
      FOR server_name
  END
END
go

/**************************************************************/
/* SPs for the maintenance plans                              */
/**************************************************************/
/**************************************************************/
/* sp_clear_dbmaintplan_by_db                                 */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_clear_dbmaintplan_by_db...'
GO
IF (EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = N'sp_clear_dbmaintplan_by_db') AND (type = 'P')))
  DROP PROCEDURE sp_clear_dbmaintplan_by_db
GO
CREATE PROCEDURE sp_clear_dbmaintplan_by_db
  @db_name sysname
AS
BEGIN
  DECLARE planid_cursor CURSOR
  FOR
  select plan_id from msdb.dbo.sysdbmaintplan_databases where database_name=@db_name
  OPEN planid_cursor
  declare @planid uniqueidentifier
  FETCH NEXT FROM planid_cursor INTO @planid
  WHILE (@@FETCH_STATUS <> -1)
  BEGIN
    IF (@@FETCH_STATUS <> -2)
    BEGIN
      delete from msdb.dbo.sysdbmaintplan_databases where plan_id=@planid AND database_name=@db_name
      if (NOT EXISTS(select * from msdb.dbo.sysdbmaintplan_databases where plan_id=@planid))
      BEGIN
        --delete the job
        DECLARE jobid_cursor CURSOR
        FOR
        select job_id from msdb.dbo.sysdbmaintplan_jobs where plan_id=@planid
        OPEN jobid_cursor
        DECLARE @jobid uniqueidentifier
        FETCH NEXT FROM jobid_cursor INTO @jobid
        WHILE (@@FETCH_STATUS <> -1)
        BEGIN
          if (@@FETCH_STATUS <> -2)
          BEGIN
            execute msdb.dbo.sp_delete_job @jobid
          END
          FETCH NEXT FROM jobid_cursor into @jobid
        END
        CLOSE jobid_cursor
        DEALLOCATE jobid_cursor
        --delete the history
        delete from msdb.dbo.sysdbmaintplan_history where plan_id=@planid
        --delete the plan
        delete from msdb.dbo.sysdbmaintplans where plan_id=@planid
      END
    END
    FETCH NEXT FROM planid_cursor INTO @planid
  END
  CLOSE planid_cursor
  DEALLOCATE planid_cursor
END
GO

/**************************************************************/
/* sp_add_maintenance_plan                                    */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_add_maintenance_plan...'
GO
IF (EXISTS (SELECT *
                FROM msdb.dbo.sysobjects
                WHERE (name = N'sp_add_maintenance_plan') AND (type = 'P')))
  DROP PROCEDURE sp_add_maintenance_plan
GO
CREATE PROCEDURE sp_add_maintenance_plan
  @plan_name varchar(128),
  @plan_id   UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
  IF (NOT EXISTS (SELECT *
                FROM msdb.dbo.sysdbmaintplans
                WHERE plan_name=@plan_name))
    BEGIN
      SELECT @plan_id=NEWID()
      INSERT INTO msdb.dbo.sysdbmaintplans (plan_id, plan_name) VALUES (@plan_id, @plan_name)
    END
  ELSE
    BEGIN
      RAISERROR(14261,-1,-1,'@plan_name',@plan_name)
      RETURN(1) -- failure
    END
END
GO

/**************************************************************/
/* sp_delete_maintenance_plan                                 */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_delete_maintenance_plan...'
GO
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_delete_maintenance_plan')
              AND (type = 'P')))
  DROP PROCEDURE sp_delete_maintenance_plan
GO
CREATE PROCEDURE sp_delete_maintenance_plan
  @plan_id UNIQUEIDENTIFIER
AS
BEGIN
  /*check if the plan_id is valid*/
  IF (NOT EXISTS(SELECT *
                 FROM sysdbmaintplans
                 WHERE plan_id=@plan_id))
  BEGIN
    DECLARE @syserr VARCHAR(100)
    SELECT @syserr=CONVERT(VARCHAR(100),@plan_id)
    RAISERROR(14262,-1,-1,'@plan_id',@syserr)
    RETURN(1)
  END
  /* clean the related records in sysdbmaintplan_database */
  DELETE FROM msdb.dbo.sysdbmaintplan_databases
  WHERE plan_id=@plan_id
  /* clean the related records in sysdbmaintplan_jobs*/
  DELETE FROM msdb.dbo.sysdbmaintplan_jobs
  WHERE plan_id=@plan_id
  /* clean sysdbmaintplans */
  DELETE FROM msdb.dbo.sysdbmaintplans
  WHERE  plan_id= @plan_id
END
GO

/**************************************************************/
/* sp_add_maintenance_plan_db                                 */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_add_maintenance_plan_db...'
GO
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_add_maintenance_plan_db')
              AND (type = 'P')))
  DROP PROCEDURE sp_add_maintenance_plan_db
GO
CREATE PROCEDURE sp_add_maintenance_plan_db
  @plan_id UNIQUEIDENTIFIER,
  @db_name sysname
AS
BEGIN
  DECLARE @syserr VARCHAR(100)
  /*check if the plan_id is valid */
  IF (NOT EXISTS (SELECT plan_id
              FROM  msdb.dbo.sysdbmaintplans
              WHERE plan_id=@plan_id))
  BEGIN
    SELECT @syserr=CONVERT(VARCHAR(100),@plan_id)
    RAISERROR(14262,-1,-1,'@plan_id',@syserr)
    RETURN(1)
  END
  /*check if the database name is valid */
  IF (NOT EXISTS (SELECT name
              FROM master.dbo.sysdatabases
              WHERE name=@db_name))
	BEGIN
    RAISERROR(14262,-1,-1,'@db_name',@db_name)
    RETURN(1)
  END
  /*check if the (plan_id, database) pair already exists*/
  IF (EXISTS (SELECT *
              FROM sysdbmaintplan_databases
              WHERE plan_id=@plan_id AND database_name=@db_name))
  BEGIN
    SELECT @syserr=CONVERT(VARCHAR(100),@plan_id)+' + '+@db_name
    RAISERROR(14261,-1,-1,'@plan_id+@db_name',@syserr)
    RETURN(1)
  END
  INSERT INTO msdb.dbo.sysdbmaintplan_databases (plan_id,database_name) VALUES (@plan_id, @db_name)
END
GO

/**************************************************************/
/* sp_delete_maintenance_plan_db                              */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_delete_maintenance_plan_db...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_delete_maintenance_plan_db')
              AND (type = 'P')))
  DROP PROCEDURE sp_delete_maintenance_plan_db
go
CREATE PROCEDURE sp_delete_maintenance_plan_db
  @plan_id uniqueidentifier,
  @db_name sysname
AS
BEGIN
  /*check if the (plan_id, db_name) exists in the table*/
  IF (NOT EXISTS(SELECT *
                 FROM msdb.dbo.sysdbmaintplan_databases
                 WHERE @plan_id=plan_id AND @db_name=database_name))
  BEGIN
    DECLARE @syserr VARCHAR(300)
    SELECT @syserr=CONVERT(VARCHAR(100),@plan_id)+' + '+@db_name
    RAISERROR(14262,-1,-1,'@plan_id+@db_name',@syserr)
    RETURN(1)
  END
  /*delete the pair*/
  DELETE FROM msdb.dbo.sysdbmaintplan_databases
  WHERE plan_id=@plan_id AND database_name=@db_name
END
GO

/**************************************************************/
/* sp_add_maintenance_plan_job                                */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_add_maintenance_plan_job...'
GO
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_add_maintenance_plan_job')
              AND (type = 'P')))
  DROP PROCEDURE sp_add_maintenance_plan_job
GO
CREATE PROCEDURE sp_add_maintenance_plan_job
  @plan_id UNIQUEIDENTIFIER,
  @job_id  UNIQUEIDENTIFIER
AS
BEGIN
  DECLARE @syserr varchar(100)
  /*check if the @plan_id is valid*/
  IF (NOT EXISTS(SELECT plan_id
                 FROM msdb.dbo.sysdbmaintplans
                 WHERE plan_id=@plan_id))
  BEGIN
    SELECT @syserr=CONVERT(VARCHAR(100),@plan_id)
    RAISERROR(14262,-1,-1,'@plan_id',@syserr)
    RETURN(1)
  END
  /*check if the @job_id is valid*/
  IF (NOT EXISTS(SELECT job_id
                 FROM msdb.dbo.sysjobs
                 WHERE job_id=@job_id))
  BEGIN
    SELECT @syserr=CONVERT(VARCHAR(100),@job_id)
    RAISERROR(14262,-1,-1,'@job_id',@syserr)
    RETURN(1)
  END
  /*check if the job has at least one step calling xp_sqlmaint*/
  DECLARE @maxind INT
  SELECT @maxind=(SELECT MAX(CHARINDEX('xp_sqlmaint', command))
                FROM  msdb.dbo.sysjobsteps
                WHERE @job_id=job_id)
  IF (@maxind<=0)
  BEGIN
    /*print N'Warning: The job is not for maitenance plan.' -- will add the new sysmessage here*/
    SELECT @syserr=CONVERT(VARCHAR(100),@job_id)
    RAISERROR(14199,-1,-1,'@job_id',@syserr)
    RETURN(1)
  END
  INSERT INTO msdb.dbo.sysdbmaintplan_jobs(plan_id,job_id) VALUES (@plan_id, @job_id) --don't have to check duplicate here
END
GO

/**************************************************************/
/* sp_delete_maintenance_plan_job                             */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_delete_maintenance_plan_job...'
GO
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_delete_maintenance_plan_job')
              AND (type = 'P')))
  DROP PROCEDURE sp_delete_maintenance_plan_job
GO
CREATE PROCEDURE sp_delete_maintenance_plan_job
  @plan_id uniqueidentifier,
  @job_id  uniqueidentifier
AS
BEGIN
  /*check if the (plan_id, job_id) exists*/
  IF (NOT EXISTS(SELECT *
                 FROM sysdbmaintplan_jobs
                 WHERE @plan_id=plan_id AND @job_id=job_id))
  BEGIN
    DECLARE @syserr VARCHAR(300)
    SELECT @syserr=CONVERT(VARCHAR(100),@plan_id)+' + '+CONVERT(VARCHAR(100),@job_id)
    RAISERROR(14262,-1,-1,'@plan_id+@job_id',@syserr)
    RETURN(1)
  END
  DELETE FROM msdb.dbo.sysdbmaintplan_jobs
  WHERE plan_id=@plan_id AND job_id=@job_id
END
GO

/**************************************************************/
/* sp_help_maintenance_plan                                   */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_help_maintenance_plan...'
GO
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_help_maintenance_plan')
              AND (type = 'P')))
  DROP PROCEDURE sp_help_maintenance_plan
GO
CREATE PROCEDURE sp_help_maintenance_plan
  @plan_id UNIQUEIDENTIFIER = NULL
AS
BEGIN
  IF (@plan_id IS NOT NULL)
    BEGIN
      /*return the information about the plan itself*/
      SELECT *
      FROM msdb.dbo.sysdbmaintplans
      WHERE plan_id=@plan_id
      /*return the information about databases this plan defined on*/
      SELECT database_name
      FROM msdb.dbo.sysdbmaintplan_databases
      WHERE plan_id=@plan_id
      /*return the information about the jobs that relating to the plan*/
      SELECT job_id
      FROM msdb.dbo.sysdbmaintplan_jobs
      WHERE plan_id=@plan_id
    END
  ELSE
    BEGIN
      SELECT *
      FROM msdb.dbo.sysdbmaintplans
    END
END
GO

/**************************************************************/
/*                                                            */
/* B A C K U P  H I S T O R Y                                 */
/*                                                            */
/**************************************************************/
/**************************************************************/
/* sp_delete_database_backuphistory                           */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_delete_database_backuphistory...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_delete_database_backuphistory')
              AND (type = 'P')))
  DROP PROCEDURE sp_delete_database_backuphistory
go
CREATE   PROCEDURE sp_delete_database_backuphistory
  @db_nm nvarchar(256)
AS
BEGIN
  declare @bsid int
  declare @msid int
  declare @rows int
  declare @errorflag int
  declare @str nvarchar(64)

  set nocount on
  set @errorflag = 0
  declare oldbackups insensitive cursor for
    select backup_set_id from backupset where database_name=@db_nm
    for read only
  open oldbackups
  fetch next from oldbackups into @bsid
  while(@@fetch_status = 0)
  begin
    begin transaction
    set rowcount 1
    set @rows = (select count(*) from restorehistory where backup_set_id = @bsid)
    set rowcount 0
    if (@rows > 0)
    begin
      delete from restorefile where restore_history_id in (select restore_history_id from restorehistory where backup_set_id = @bsid)
      if (@@error <> 0)
      begin
         rollback transaction
         set @errorflag = 1
         break
      end
      delete from restorefilegroup where restore_history_id in (select restore_history_id from restorehistory where backup_set_id = @bsid)
      if (@@error <> 0)
      begin
         rollback transaction
         set @errorflag = 1
         break
      end
      delete from restorehistory where backup_set_id = @bsid
      if (@@error <> 0)
      begin
         rollback transaction
         set @errorflag = 1
         break
      end
    end
    delete from backupfile where backup_set_id = @bsid
    if (@@error <> 0)
    begin
       rollback transaction
       set @errorflag = 1
       break
    end
    set @msid = (select media_set_id from backupset where backup_set_id = @bsid)
    delete from backupset where backup_set_id = @bsid
    if (@@error <> 0)
    begin
       rollback transaction
       set @errorflag = 1
       break
    end
    set rowcount 1
    set @rows = (select count(*) from backupset where media_set_id = @msid)
    set rowcount 0
    if (@rows = 0)
    begin
      delete from backupmediafamily where media_set_id = @msid
      if (@@error <> 0)
      begin
         rollback transaction
         set @errorflag = 1
         break
      end
      delete from backupmediaset where media_set_id = @msid
      if (@@error <> 0)
      begin
         rollback transaction
         set @errorflag = 1
         break
      end
    end
    commit transaction
    fetch next from oldbackups into @bsid
  end
  deallocate oldbackups
  set nocount off

  if (@errorflag <> 0)
  begin
    set @str = (select convert( nvarchar(64), @bsid))
    raiserror( 4325, -1, -1, @str )
    return(1)
  end

END
go

/**************************************************************/
/* SP_DELETE_BACKUPHISTORY                                    */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_delete_backuphistory...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = N'sp_delete_backuphistory')
              AND (type = 'P')))
  DROP PROCEDURE sp_delete_backuphistory
go
CREATE   PROCEDURE sp_delete_backuphistory
  @oldest_date datetime
AS
BEGIN
  declare @bsid int
  declare @msid int
  declare @rows int
  declare @errorflag int
  declare @str nvarchar(64)

  set nocount on
  set @errorflag = 0
  declare oldbackups insensitive cursor for
    select backup_set_id from backupset where backup_finish_date < @oldest_date
    for read only
  open oldbackups
  fetch next from oldbackups into @bsid
  while(@@fetch_status = 0)
  begin
    begin transaction
    set rowcount 1
    set @rows = (select count(*) from restorehistory where backup_set_id = @bsid)
    set rowcount 0
    if (@rows > 0)
    begin
      delete from restorefile where restore_history_id in (select restore_history_id from restorehistory where backup_set_id = @bsid)
      if (@@error <> 0)
      begin
         rollback transaction
         set @errorflag = 1
         break
      end
      delete from restorefilegroup where restore_history_id in (select restore_history_id from restorehistory where backup_set_id = @bsid)
      if (@@error <> 0)
      begin
         rollback transaction
         set @errorflag = 1
         break
      end
      delete from restorehistory where backup_set_id = @bsid
      if (@@error <> 0)
      begin
         rollback transaction
         set @errorflag = 1
         break
      end
    end
    delete from backupfile where backup_set_id = @bsid
    if (@@error <> 0)
    begin
       rollback transaction
       set @errorflag = 1
       break
    end
    set @msid = (select media_set_id from backupset where backup_set_id = @bsid)
    delete from backupset where backup_set_id = @bsid
    if (@@error <> 0)
    begin
       rollback transaction
       set @errorflag = 1
       break
    end
    set rowcount 1
    set @rows = (select count(*) from backupset where media_set_id = @msid)
    set rowcount 0
    if (@rows = 0)
    begin
      delete from backupmediafamily where media_set_id = @msid
      if (@@error <> 0)
      begin
         rollback transaction
         set @errorflag = 1
         break
      end
      delete from backupmediaset where media_set_id = @msid
      if (@@error <> 0)
      begin
         rollback transaction
         set @errorflag = 1
         break
      end
    end
    commit transaction
    fetch next from oldbackups into @bsid
  end
  deallocate oldbackups
  set nocount off

  if (@errorflag <> 0)
  begin
    set @str = (select convert( nvarchar(64), @bsid))
    raiserror( 4325, -1, -1, @str )
    return(1)
  end

  set @str = (select convert( nvarchar(64), @oldest_date))
  raiserror( 4324, -1, -1, @str  )
  return(0)

END
go

/**************************************************************/
/* SP_DELETE_BACKUP_AND_RESTORE_HISTORY                       */
/**************************************************************/

PRINT ''
PRINT 'Creating procedure sp_delete_backup_and_restore_history...'
go
IF (EXISTS (SELECT *
            FROM msdb.dbo.sysobjects
            WHERE (name = 'sp_delete_backup_and_restore_history')
              AND (type = 'P')))
  DROP PROCEDURE sp_delete_backup_and_restore_history
go
CREATE PROCEDURE sp_delete_backup_and_restore_history
  @database_name sysname
AS
BEGIN
  SET NOCOUNT ON

  CREATE TABLE #backup_set_id      (backup_set_id INT)
  CREATE TABLE #media_set_id       (media_set_id INT)
  CREATE TABLE #restore_history_id (restore_history_id INT)

  INSERT INTO #backup_set_id (backup_set_id)
  SELECT DISTINCT backup_set_id
  FROM msdb.dbo.backupset
  WHERE database_name = @database_name

  INSERT INTO #media_set_id (media_set_id)
  SELECT DISTINCT media_set_id
  FROM msdb.dbo.backupset
  WHERE database_name = @database_name

  INSERT INTO #restore_history_id (restore_history_id)
  SELECT DISTINCT restore_history_id
  FROM msdb.dbo.restorehistory
  WHERE backup_set_id IN (SELECT backup_set_id
                          FROM #backup_set_id)

  BEGIN TRANSACTION

  DELETE FROM msdb.dbo.backupfile
  WHERE backup_set_id IN (SELECT backup_set_id
                          FROM #backup_set_id)
  IF (@@error > 0)
    GOTO Quit

  DELETE FROM msdb.dbo.restorefile
  WHERE restore_history_id IN (SELECT restore_history_id
                               FROM #restore_history_id)
  IF (@@error > 0)
    GOTO Quit

  DELETE FROM msdb.dbo.restorefilegroup
  WHERE restore_history_id IN (SELECT restore_history_id
                               FROM #restore_history_id)
  IF (@@error > 0)
    GOTO Quit

  DELETE FROM msdb.dbo.restorehistory
  WHERE restore_history_id IN (SELECT restore_history_id
                               FROM #restore_history_id)
  IF (@@error > 0)
    GOTO Quit

  DELETE FROM msdb.dbo.backupset
  WHERE backup_set_id IN (SELECT backup_set_id
                          FROM #backup_set_id)
  IF (@@error > 0)
    GOTO Quit

  DELETE msdb.dbo.backupmediafamily
  FROM msdb.dbo.backupmediafamily bmf
  WHERE bmf.media_set_id IN (SELECT media_set_id
                             FROM #media_set_id)
    AND ((SELECT COUNT(*)
          FROM msdb.dbo.backupset
          WHERE media_set_id = bmf.media_set_id) = 0)
  IF (@@error > 0)
    GOTO Quit

  DELETE msdb.dbo.backupmediaset
  FROM msdb.dbo.backupmediaset bms
  WHERE bms.media_set_id IN (SELECT media_set_id
                             FROM #media_set_id)
    AND ((SELECT COUNT(*)
          FROM msdb.dbo.backupset
          WHERE media_set_id = bms.media_set_id) = 0)
  IF (@@error > 0)
    GOTO Quit

  COMMIT TRANSACTION
  RETURN

Quit:
  ROLLBACK TRANSACTION

END
go


/**********************************************************************/
/* TABLE : log_shipping_primaries                                     */
/* Populated on the monitor server                                    */
/*                                                                    */
/**********************************************************************/

IF (NOT EXISTS (SELECT *
            FROM INFORMATION_SCHEMA.TABLES
            WHERE (TABLE_NAME = N'log_shipping_primaries')))
BEGIN
 PRINT ''
 PRINT 'Creating table log_shipping_primaries...'
 CREATE TABLE log_shipping_primaries
 (
  primary_id                   INT IDENTITY     NOT NULL PRIMARY KEY,
  primary_server_name          sysname          NOT NULL,
  primary_database_name        sysname          NOT NULL,
  maintenance_plan_id          UNIQUEIDENTIFIER NULL,
  backup_threshold             INT              NOT NULL,
  threshold_alert              INT              NOT NULL,
  threshold_alert_enabled      BIT              NOT NULL, /* 1 = enabled, 0 = disabled */
  last_backup_filename         NVARCHAR(500)    NULL,
  last_updated                 DATETIME         NULL,
  planned_outage_start_time    INT              NOT NULL,
  planned_outage_end_time      INT              NOT NULL,
  planned_outage_weekday_mask  INT              NOT NULL,
  source_directory             NVARCHAR(500)    NULL
 )
END
ELSE 
BEGIN
  IF (NOT EXISTS (SELECT * 
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE (TABLE_NAME = N'log_shipping_primaries')
      AND (COLUMN_NAME = N'source_directory')))

  BEGIN
    PRINT ''
    PRINT 'Adding columns to table log_shipping_primaries...'

    ALTER TABLE log_shipping_primaries
     ADD source_directory NVARCHAR(500) NULL

  END
END 
go

/**********************************************************************/
/* TABLE : log_shipping_secondaries                                   */
/* Populated on the monitor server                                    */
/*                                                                    */
/**********************************************************************/

IF (NOT EXISTS (SELECT *
            FROM INFORMATION_SCHEMA.TABLES
            WHERE (TABLE_NAME = N'log_shipping_secondaries')))
BEGIN
 PRINT ''
 PRINT 'Creating table log_shipping_secondaries...'
 CREATE TABLE log_shipping_secondaries
 (
  primary_id                   INT                FOREIGN KEY REFERENCES log_shipping_primaries (primary_id),
  secondary_server_name        sysname,
  secondary_database_name      sysname,
  last_copied_filename         NVARCHAR(500),
  last_loaded_filename         NVARCHAR(500),
  last_copied_last_updated     DATETIME,
  last_loaded_last_updated     DATETIME,
  secondary_plan_id            UNIQUEIDENTIFIER,
  copy_enabled                 BIT,
  load_enabled                 BIT,              /* 1 = load enabled, 0 = load disabled */
  out_of_sync_threshold        INT,
  threshold_alert              INT,
  threshold_alert_enabled      BIT,              /*1 = enabled, 0 = disabled */
  planned_outage_start_time    INT,
  planned_outage_end_time      INT,
  planned_outage_weekday_mask  INT,
  allow_role_change            BIT DEFAULT (0)
 )
END
ELSE 
BEGIN
  IF (NOT EXISTS (SELECT * 
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE (TABLE_NAME = N'log_shipping_secondaries')
      AND (COLUMN_NAME = N'allow_role_change')))

  BEGIN
    PRINT ''
    PRINT 'Adding columns to table log_shipping_secondaries...'

    ALTER TABLE log_shipping_secondaries
     ADD allow_role_change BIT DEFAULT (0)

  END
END 
go

/**************************************************************/
/* sp_add_log_shipping_monitor_jobs                           */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_add_log_shipping_monitor_jobs...'
go
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_add_log_shipping_monitor_jobs' AND type = N'P')  )
  drop procedure sp_add_log_shipping_monitor_jobs
go
CREATE PROCEDURE sp_add_log_shipping_monitor_jobs AS 
BEGIN
  SET NOCOUNT ON
  BEGIN TRANSACTION
  DECLARE @rv INT
  DECLARE @backup_job_name sysname
  SET @backup_job_name = N'Log Shipping Alert Job - Backup'
  IF (NOT EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE name = @backup_job_name))
  BEGIN
    EXECUTE @rv = msdb.dbo.sp_add_job @job_name = N'Log Shipping Alert Job - Backup'

    IF (@@error <> 0 OR @rv <> 0) GOTO rollback_quit -- error 

    EXECUTE @rv = msdb.dbo.sp_add_jobstep 
      @job_name = N'Log Shipping Alert Job - Backup', 
      @step_id = 1, 
      @step_name = N'Log Shipping Alert - Backup', 
      @command = N'EXECUTE msdb.dbo.sp_log_shipping_monitor_backup',
      @on_fail_action = 2, 
      @flags = 4, 
      @subsystem = N'TSQL', 
      @on_success_step_id = 0, 
      @on_success_action = 1, 
      @on_fail_step_id = 0
    IF (@@error <> 0 OR @rv <> 0) GOTO rollback_quit -- error 

   EXECUTE @rv = msdb.dbo.sp_add_jobschedule 
      @job_name = @backup_job_name, 
      @freq_type = 4, 
      @freq_interval = 1, 
      @freq_subday_type = 0x4, 
      @freq_subday_interval = 1, -- run every minute
      @freq_relative_interval = 0, 
      @name = @backup_job_name
    IF (@@error <> 0 OR @rv <> 0) GOTO rollback_quit -- error

   EXECUTE @rv = msdb.dbo.sp_add_jobserver @job_name = @backup_job_name, @server_name = NULL
    IF (@@error <> 0 OR @rv <> 0) GOTO rollback_quit -- error
  END

  DECLARE @restore_job_name sysname
  SET @restore_job_name = 'Log Shipping Alert Job - Restore'
  IF (NOT EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE name = @restore_job_name))
  BEGIN
    EXECUTE @rv = msdb.dbo.sp_add_job @job_name = @restore_job_name

    IF (@@error <> 0 OR @rv <> 0) GOTO rollback_quit -- error 

    EXECUTE @rv = msdb.dbo.sp_add_jobstep 
      @job_name = @restore_job_name, 
      @step_id = 1, 
      @step_name = @restore_job_name, 
      @command = N'EXECUTE msdb.dbo.sp_log_shipping_monitor_restore',
      @on_fail_action = 2, 
      @flags = 4, 
      @subsystem = N'TSQL', 
      @on_success_step_id = 0, 
      @on_success_action = 1, 
      @on_fail_step_id = 0
    IF (@@error <> 0 OR @rv <> 0) GOTO rollback_quit -- error 

    EXECUTE @rv = msdb.dbo.sp_add_jobschedule 
      @job_name = @restore_job_name, 
      @freq_type = 4, 
      @freq_interval = 1, 
      @freq_subday_type = 0x4, 
      @freq_subday_interval = 1, -- run every minute
      @freq_relative_interval = 0, 
      @name = @restore_job_name
    IF (@@error <> 0 OR @rv <> 0) GOTO rollback_quit -- error

    EXECUTE @rv = msdb.dbo.sp_add_jobserver @job_name = @restore_job_name, @server_name = NULL
    IF (@@error <> 0 OR @rv <> 0) GOTO rollback_quit -- error
  END
  COMMIT TRANSACTION
  RETURN

rollback_quit:
  ROLLBACK TRANSACTION
END
go

/**************************************************************/
/* sp_add_log_shipping_primary                                */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_add_log_shipping_primary...'
go
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_add_log_shipping_primary' AND type = N'P'))
  drop procedure sp_add_log_shipping_primary
go
CREATE PROCEDURE sp_add_log_shipping_primary
  @primary_server_name         sysname,
  @primary_database_name       sysname,
  @maintenance_plan_id         UNIQUEIDENTIFIER = NULL,
  @backup_threshold            INT              = 60,
  @threshold_alert             INT              = 14420,
  @threshold_alert_enabled     BIT              = 1,
  @planned_outage_start_time   INT              = 0,
  @planned_outage_end_time     INT              = 0,
  @planned_outage_weekday_mask INT              = 0,
  @primary_id				   INT = NULL OUTPUT       
AS
BEGIN
  SET NOCOUNT ON
  IF EXISTS (SELECT * FROM msdb.dbo.log_shipping_primaries WHERE primary_server_name = @primary_server_name AND primary_database_name = @primary_database_name)
  BEGIN  
    DECLARE @pair_name NVARCHAR 
	SELECT @pair_name = @primary_server_name + N'.' + @primary_database_name
	RAISERROR (14261,16,1, N'primary_server_name.primary_database_name', @pair_name)
    RETURN (1) -- error
  END
  INSERT INTO msdb.dbo.log_shipping_primaries (
    primary_server_name,
    primary_database_name,
    maintenance_plan_id,
    backup_threshold,
    threshold_alert,
    threshold_alert_enabled,
    last_backup_filename,
    last_updated,
    planned_outage_start_time,
    planned_outage_end_time,
    planned_outage_weekday_mask,
    source_directory)  
  VALUES (@primary_server_name,  
    @primary_database_name, 
    @maintenance_plan_id, 
    @backup_threshold,
    @threshold_alert,
    @threshold_alert_enabled,
    N'first_file_000000000000.trn',
    GETDATE (),
    @planned_outage_start_time,
    @planned_outage_end_time,
    @planned_outage_weekday_mask,
    NULL)

  SELECT @primary_id = @@IDENTITY

  EXECUTE msdb.dbo.sp_add_log_shipping_monitor_jobs
END
go

/**************************************************************/
/* sp_add_log_shipping_secondary                              */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_add_log_shipping_secondary...'
go
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_add_log_shipping_secondary' AND type = N'P'))
  drop procedure sp_add_log_shipping_secondary
go
CREATE PROCEDURE sp_add_log_shipping_secondary
  @primary_id                  INT,
  @secondary_server_name       sysname,
  @secondary_database_name     sysname,
  @secondary_plan_id           UNIQUEIDENTIFIER,
  @copy_enabled                BIT              = 1,
  @load_enabled                BIT              = 1,
  @out_of_sync_threshold       INT              = 60,
  @threshold_alert             INT              = 14421,
  @threshold_alert_enabled     BIT              = 1,
  @planned_outage_start_time   INT              = 0,
  @planned_outage_end_time     INT              = 0,
  @planned_outage_weekday_mask INT              = 0,
  @allow_role_change           BIT              = 0 
AS
BEGIN
  SET NOCOUNT ON
  IF NOT EXISTS (SELECT * FROM msdb.dbo.log_shipping_primaries where primary_id = @primary_id)
  BEGIN
    RAISERROR (14262, 16, 1, N'primary_id', N'msdb.dbo.log_shipping_primaries')
    RETURN(1)
  END

  INSERT INTO msdb.dbo.log_shipping_secondaries (
    primary_id,
    secondary_server_name,
    secondary_database_name,
    last_copied_filename,
    last_loaded_filename,
    last_copied_last_updated,
    last_loaded_last_updated,
    secondary_plan_id,
    copy_enabled,
    load_enabled,
    out_of_sync_threshold,
    threshold_alert,
    threshold_alert_enabled,
    planned_outage_start_time,
    planned_outage_end_time,
    planned_outage_weekday_mask,
    allow_role_change)
   VALUES (@primary_id,
    @secondary_server_name,
    @secondary_database_name,
    N'first_file_000000000000.trn',
    N'first_file_000000000000.trn',
    GETDATE (),
    GETDATE (),
    @secondary_plan_id,
    @copy_enabled,
    @load_enabled,
    @out_of_sync_threshold,
    @threshold_alert,
    @threshold_alert_enabled,
    @planned_outage_start_time,
    @planned_outage_end_time,
    @planned_outage_weekday_mask,
    @allow_role_change)
END
go

/**************************************************************/
/* sp_delete_log_shipping_monitor_jobs                        */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_delete_log_shipping_monitor_jobs...'
go
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_delete_log_shipping_monitor_jobs' AND type = N'P')  )
  drop procedure sp_delete_log_shipping_monitor_jobs
go
CREATE PROCEDURE sp_delete_log_shipping_monitor_jobs AS
BEGIN
  DECLARE @backup_job_name sysname
  SET NOCOUNT ON
  SET @backup_job_name = N'Log Shipping Alert Job - Backup'
  IF (EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE name = @backup_job_name))
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'Log Shipping Alert Job - Backup'

  DECLARE @restore_job_name sysname
  SET @restore_job_name = 'Log Shipping Alert Job - Restore'
  IF (EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE name = @restore_job_name))
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'Log Shipping Alert Job - Restore'
END
go

/**************************************************************/
/* sp_delete_log_shipping_primary                             */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_delete_log_shipping_primary...'
go
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_delete_log_shipping_primary' AND type = N'P')  )
  drop procedure sp_delete_log_shipping_primary
go
CREATE PROCEDURE sp_delete_log_shipping_primary 
  @primary_server_name sysname,
  @primary_database_name sysname,
  @delete_secondaries BIT = 0
AS BEGIN
  DECLARE @primary_id INT

  SET NOCOUNT ON

  SELECT @primary_id = primary_id 
    FROM msdb.dbo.log_shipping_primaries 
    WHERE primary_server_name = @primary_server_name AND primary_database_name = @primary_database_name
  IF (@primary_id IS NULL)
    RETURN (0)

  BEGIN TRANSACTION
  IF (EXISTS (SELECT * FROM msdb.dbo.log_shipping_secondaries WHERE primary_id = @primary_id))
  BEGIN
    IF (@delete_secondaries = 0)
    BEGIN
      RAISERROR (14429,-1,-1)
      goto rollback_quit
    END
    DELETE FROM msdb.dbo.log_shipping_secondaries WHERE primary_id = @primary_id
    IF (@@ERROR <> 0)
      GOTO rollback_quit
  END
  DELETE FROM msdb.dbo.log_shipping_primaries WHERE primary_id = @primary_id
  IF (@@ERROR <> 0)
    GOTO rollback_quit

  COMMIT TRANSACTION
  DECLARE @i INT
  SELECT @i = COUNT(*) FROM msdb.dbo.log_shipping_primaries
  IF (@i=0)
    EXECUTE msdb.dbo.sp_delete_log_shipping_monitor_jobs
  RETURN (0)

rollback_quit:
  ROLLBACK TRANSACTION
  RETURN(1) -- error
END
go

/**************************************************************/
/* sp_delete_log_shipping_secondary                           */
/**************************************************************/
PRINT ''
PRINT 'Creating sp_delete_log_shipping_secondary...'
go
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_delete_log_shipping_secondary' AND type = N'P')  )
  drop procedure sp_delete_log_shipping_secondary
go
CREATE PROCEDURE sp_delete_log_shipping_secondary 
  @secondary_server_name   sysname,
  @secondary_database_name sysname
AS BEGIN
  SET NOCOUNT ON
  DELETE FROM msdb.dbo.log_shipping_secondaries WHERE 
    secondary_server_name   = @secondary_server_name AND
    secondary_database_name = @secondary_database_name
END
go

/**************************************************************/
/* sp_log_shipping_in_sync                                    */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_log_shipping_in_sync...'
go
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_log_shipping_in_sync' AND type = N'P')  )
  drop procedure sp_log_shipping_in_sync
go
CREATE PROCEDURE sp_log_shipping_in_sync
  @last_updated        DATETIME,
  @compare_with        DATETIME,
  @threshold           INT,
  @outage_start_time   INT,
  @outage_end_time     INT,
  @outage_weekday_mask INT,
  @enabled             BIT = 1,
  @delta               INT = NULL OUTPUT
AS BEGIN
  SET NOCOUNT ON
  DECLARE @cur_time INT

  SELECT @delta = DATEDIFF (mi, @last_updated, @compare_with)
  -- in sync
  IF (@delta <= @threshold)
    RETURN (0) -- in sync

  IF (@enabled = 0) 
    RETURN(0) -- in sync

  IF (@outage_weekday_mask & DATEPART(dw, GETDATE ()) > 0) -- potentially in outage window
  BEGIN
    SELECT @cur_time = DATEPART (hh, GETDATE()) * 10000 +
                       DATEPART (mi, GETDATE()) * 100 + 
                       DATEPART (ss, GETDATE())
	  -- outage doesn't span midnight
    IF (@outage_start_time < @outage_end_time)
    BEGIN
      IF (@cur_time >= @outage_start_time AND @cur_time < @outage_end_time)
        RETURN(1) -- in outage
    END
	  -- outage does span midnight
	ELSE IF (@outage_start_time > @outage_end_time)
	BEGIN
	  IF (@cur_time >= @outage_start_time OR @cur_time < @outage_end_time)
	    RETURN(1) -- in outage
	END
  END
  RETURN(-1 ) -- not in outage, not in sync
END
go

/**************************************************************/
/* sp_log_shipping_get_date_from_file                         */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_log_shipping_get_date_from_file...'
go
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_log_shipping_get_date_from_file' AND type = N'P')  )
  drop procedure sp_log_shipping_get_date_from_file
go
CREATE PROCEDURE sp_log_shipping_get_date_from_file 
  @db_name sysname,
  @filename NVARCHAR (500),
  @file_date DATETIME OUTPUT
AS
BEGIN
  SET NOCOUNT ON

  DECLARE @tempname NVARCHAR (500)
  IF (LEN (@filename) - (LEN(@db_name) + LEN ('_tlog_')) <= 0)
    RETURN(1) -- filename string isn't long enough
  SELECT @tempname = RIGHT (@filename, LEN (@filename) - (LEN(@db_name) + LEN ('_tlog_')))
  IF (CHARINDEX ('.',@tempname,0) > 0)
    SELECT @tempname = LEFT (@tempname, CHARINDEX ('.',@tempname,0) - 1)
  IF (LEN (@tempname) <>  8 AND LEN (@tempname) <> 12)
    RETURN (1) -- error must be yyyymmddhhmm or yyyymmdd
  IF (ISNUMERIC (@tempname) = 0 OR CHARINDEX ('.',@tempname,0) <> 0 OR CONVERT (FLOAT,SUBSTRING (@tempname, 1,8)) < 1 )
    RETURN (1) -- must be numeric, can't contain any '.' etc
  SELECT @file_date = CONVERT (DATETIME,SUBSTRING (@tempname, 1,8),112)
  IF (LEN (@tempname) = 12)
  BEGIN
    SELECT @file_date = DATEADD (hh, CONVERT (INT, SUBSTRING (@tempname,9,2)),@file_date)
    SELECT @file_date = DATEADD (mi, CONVERT (INT, SUBSTRING (@tempname,11,2)),@file_date)
  END
  RETURN (0) -- success
END
go

/**************************************************************/
/* sp_get_log_shipping_monitor_info                           */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_get_log_shipping_monitor_info...'
go
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_get_log_shipping_monitor_info' AND type = N'P')  )
  drop procedure sp_get_log_shipping_monitor_info
go
CREATE PROCEDURE sp_get_log_shipping_monitor_info
  @primary_server_name     sysname = N'%',
  @primary_database_name   sysname = N'%',
  @secondary_server_name   sysname = N'%',
  @secondary_database_name sysname = N'%'
AS BEGIN
  SET NOCOUNT ON
  CREATE TABLE #lsp (
    primary_server_name            sysname       COLLATE database_default NOT NULL,
    primary_database_name          sysname       COLLATE database_default NOT NULL,
    secondary_server_name          sysname       COLLATE database_default NOT NULL,
    secondary_database_name        sysname       COLLATE database_default NOT NULL,
    backup_threshold               INT           NOT NULL,
    backup_threshold_alert         INT           NOT NULL,
    backup_threshold_alert_enabled BIT           NOT NULL,
    last_backup_filename           NVARCHAR(500) COLLATE database_default NOT NULL,
    last_backup_last_updated       DATETIME      NOT NULL,
    backup_outage_start_time       INT           NOT NULL,
    backup_outage_end_time         INT           NOT NULL,
    backup_outage_weekday_mask     INT           NOT NULL,
    backup_in_sync                 INT           NULL, -- 0 = in sync, -1 = out of sync, 1 = in outage window
    backup_delta                   INT           NULL,
    last_copied_filename           NVARCHAR(500) COLLATE database_default NOT NULL,
    last_copied_last_updated       DATETIME      NOT NULL,
    last_loaded_filename           NVARCHAR(500) COLLATE database_default NOT NULL,
    last_loaded_last_updated       DATETIME      NOT NULL,
    copy_delta                     INT           NULL,
    copy_enabled                   BIT           NOT NULL,
    load_enabled                   BIT           NOT NULL,
    out_of_sync_threshold          INT           NOT NULL,
    load_threshold_alert           INT           NOT NULL,
    load_threshold_alert_enabled   BIT           NOT NULL,
    load_outage_start_time         INT           NOT NULL,
    load_outage_end_time           INT           NOT NULL,
    load_outage_weekday_mask       INT           NOT NULL,
    load_in_sync                   INT           NULL, -- 0 = in sync, -1 = out of sync, 1 = in outage window
    load_delta                     INT           NULL,
    maintenance_plan_id		         UNIQUEIDENTIFIER NULL,
    secondary_plan_id              UNIQUEIDENTIFIER NOT NULL)

  INSERT INTO #lsp

 SELECT
    primary_server_name,
    primary_database_name,
    secondary_server_name,
    secondary_database_name,
    backup_threshold,
    p.threshold_alert,
    p.threshold_alert_enabled,
    last_backup_filename,
    p.last_updated,
    p.planned_outage_start_time,
    p.planned_outage_end_time,
    p.planned_outage_weekday_mask,
    NULL,
    NULL,
    last_copied_filename,
    last_copied_last_updated,
    last_loaded_filename,
    last_loaded_last_updated,
    NULL,
    copy_enabled,
    load_enabled,
    out_of_sync_threshold,
    s.threshold_alert,
    s.threshold_alert_enabled,
    s.planned_outage_start_time,
    s.planned_outage_weekday_mask,
    s.planned_outage_end_time,
    NULL,
    NULL,
    maintenance_plan_id,
    secondary_plan_id
  FROM msdb.dbo.log_shipping_primaries p, msdb.dbo.log_shipping_secondaries s
  WHERE 
    p.primary_id = s.primary_id AND
    primary_server_name LIKE @primary_server_name AND
    primary_database_name LIKE @primary_database_name AND
    secondary_server_name LIKE @secondary_server_name AND
    secondary_database_name LIKE @secondary_database_name

  DECLARE @load_in_sync                   INT
  DECLARE @backup_in_sync                 INT
  DECLARE @_primary_server_name           sysname 
  DECLARE @_primary_database_name         sysname 
  DECLARE @_secondary_server_name         sysname
  DECLARE @_secondary_database_name       sysname
  DECLARE @last_loaded_last_updated       DATETIME
  DECLARE @last_loaded_filename           NVARCHAR (500)
  DECLARE @last_copied_filename           NVARCHAR (500)
  DECLARE @last_backup_last_updated       DATETIME
  DECLARE @last_backup_filename           NVARCHAR (500)
  DECLARE @backup_outage_start_time       INT
  DECLARE @backup_outage_end_time         INT
  DECLARE @backup_outage_weekday_mask     INT
  DECLARE @backup_threshold               INT
  DECLARE @backup_threshold_alert_enabled BIT
  DECLARE @load_outage_start_time         INT
  DECLARE @load_outage_end_time           INT
  DECLARE @load_outage_weekday_mask       INT
  DECLARE @load_threshold                 INT
  DECLARE @load_threshold_alert_enabled   BIT
  DECLARE @backupdt                       DATETIME
  DECLARE @restoredt                      DATETIME
  DECLARE @copydt                         DATETIME
  DECLARE @rv                             INT
  DECLARE @dt                             DATETIME
  DECLARE @copy_delta                     INT
  DECLARE @load_delta                     INT
  DECLARE @backup_delta                   INT
  DECLARE @last_copied_last_updated       DATETIME

  SELECT @dt = GETDATE ()

  DECLARE sync_update CURSOR FOR
    SELECT 
      primary_server_name, 
      primary_database_name, 
      secondary_server_name, 
      secondary_database_name,
      last_backup_filename,
      last_backup_last_updated,
      last_loaded_filename,
      last_loaded_last_updated,
      backup_outage_start_time,
      backup_outage_end_time,
      backup_outage_weekday_mask,
      backup_threshold,
      backup_threshold_alert_enabled,
      load_outage_start_time,
      load_outage_end_time,
      out_of_sync_threshold,
      load_outage_weekday_mask,
      load_threshold_alert_enabled,
      last_copied_filename,
      last_copied_last_updated
    FROM #lsp
    FOR READ ONLY

  OPEN sync_update

loop:
  FETCH NEXT FROM sync_update INTO
    @_primary_server_name, 
    @_primary_database_name, 
    @_secondary_server_name, 
    @_secondary_database_name,
    @last_backup_filename,
    @last_backup_last_updated,
    @last_loaded_filename,
    @last_loaded_last_updated,
    @backup_outage_start_time,
    @backup_outage_end_time,
    @backup_outage_weekday_mask,
    @backup_threshold,
    @backup_threshold_alert_enabled,
    @load_outage_start_time,
    @load_outage_end_time,
    @load_threshold,
    @load_outage_weekday_mask,
    @load_threshold_alert_enabled,
    @last_copied_filename,
    @last_copied_last_updated

  IF @@fetch_status <> 0
    GOTO _loop

  EXECUTE @rv = sp_log_shipping_get_date_from_file @_primary_database_name, @last_backup_filename, @backupdt OUTPUT
  IF (@rv <> 0)
    SElECT @backupdt = @last_backup_last_updated
  EXECUTE @rv = sp_log_shipping_get_date_from_file @_primary_database_name, @last_loaded_filename, @restoredt OUTPUT
  IF  (@rv <> 0)
    SElECT @restoredt = @last_loaded_last_updated
  EXECUTE @rv = sp_log_shipping_get_date_from_file @_primary_database_name, @last_copied_filename, @copydt OUTPUT
  IF  (@rv <> 0)
    SElECT @copydt = @last_copied_last_updated
  
  EXECUTE @load_in_sync = msdb.dbo.sp_log_shipping_in_sync
    @restoredt,
    @backupdt,
    @load_threshold,
    @load_outage_start_time,
    @load_outage_end_time,
    @load_outage_weekday_mask,
    @load_threshold_alert_enabled,
    @load_delta OUTPUT

  EXECUTE @backup_in_sync = msdb.dbo.sp_log_shipping_in_sync
    @last_backup_last_updated,
    @dt,
    @backup_threshold,
    @backup_outage_start_time,
    @backup_outage_end_time,
    @backup_outage_weekday_mask,
    @backup_threshold_alert_enabled,
    @backup_delta OUTPUT

  EXECUTE msdb.dbo.sp_log_shipping_in_sync
    @copydt,
    @backupdt,
    1,0,0,0,0,
    @copy_delta OUTPUT

  UPDATE #lsp 
  SET backup_in_sync = @backup_in_sync, load_in_sync  = @load_in_sync, 
    copy_delta = @copy_delta, load_delta = @load_delta, backup_delta = @backup_delta
  WHERE primary_server_name = @_primary_server_name AND
    secondary_server_name = @_secondary_server_name AND
    primary_database_name = @_primary_database_name AND
    secondary_database_name = @_secondary_database_name 
  GOTO loop
_loop:
  CLOSE sync_update
  DEALLOCATE sync_update
  SELECT * FROM #lsp
END
go

/**************************************************************/
/* sp_update_log_shipping_monitor_info                        */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_update_log_shipping_monitor_info...'
go
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_update_log_shipping_monitor_info' AND type = N'P')  )
  DROP PROCEDURE sp_update_log_shipping_monitor_info
go
CREATE PROCEDURE sp_update_log_shipping_monitor_info
  @primary_server_name                 sysname,
  @primary_database_name               sysname,
  @secondary_server_name               sysname,
  @secondary_database_name             sysname,
  @backup_threshold                    INT = NULL,
  @backup_threshold_alert              INT = NULL,
  @backup_threshold_alert_enabled      BIT = NULL,
  @backup_outage_start_time            INT = NULL,
  @backup_outage_end_time              INT = NULL,
  @backup_outage_weekday_mask          INT = NULL,
  @copy_enabled                        BIT = NULL,
  @load_enabled                        BIT = NULL,
  @out_of_sync_threshold               INT = NULL,
  @out_of_sync_threshold_alert         INT = NULL,
  @out_of_sync_threshold_alert_enabled BIT = NULL,
  @out_of_sync_outage_start_time       INT = NULL,
  @out_of_sync_outage_end_time         INT = NULL,
  @out_of_sync_outage_weekday_mask     INT = NULL
AS BEGIN
  SET NOCOUNT ON
  DECLARE @_backup_threshold                    INT
  DECLARE @_backup_threshold_alert              INT
  DECLARE @_backup_threshold_alert_enabled      BIT
  DECLARE @_backup_outage_start_time            INT
  DECLARE @_backup_outage_end_time              INT
  DECLARE @_backup_outage_weekday_mask          INT
  DECLARE @_copy_enabled                        BIT
  DECLARE @_load_enabled                        BIT
  DECLARE @_out_of_sync_threshold               INT
  DECLARE @_out_of_sync_threshold_alert         INT
  DECLARE @_out_of_sync_threshold_alert_enabled BIT
  DECLARE @_out_of_sync_outage_start_time       INT
  DECLARE @_out_of_sync_outage_end_time         INT
  DECLARE @_out_of_sync_outage_weekday_mask     INT

  -- check that the primary exists
  IF (NOT EXISTS (SELECT * FROM msdb.dbo.log_shipping_primaries WHERE primary_server_name = @primary_server_name AND primary_database_name = @primary_database_name))
  BEGIN
    DECLARE @pp sysname
    SELECT @pp = @primary_server_name + N'.' + @primary_database_name
    RAISERROR (14262, 16, 1, N'primary_server_name.primary_database_name', @pp)
    RETURN (1) -- error
  END

  -- check that the secondary exists
  IF (NOT EXISTS (SELECT * FROM msdb.dbo.log_shipping_secondaries WHERE secondary_server_name = @secondary_server_name AND secondary_database_name = @secondary_database_name))
  BEGIN
    DECLARE @sp sysname
    SELECT @sp = @secondary_server_name + N'.' + @secondary_database_name
    RAISERROR (14262, 16, 1, N'secondary_server_name.secondary_database_name', @sp)
    RETURN (1) -- error
  END

  -- load the original variables

 SELECT
    @_backup_threshold                    = backup_threshold,
    @_backup_threshold_alert              = p.threshold_alert,
    @_backup_threshold_alert_enabled      = p.threshold_alert_enabled,
    @_backup_outage_start_time            = p.planned_outage_start_time,
    @_backup_outage_end_time              = p.planned_outage_end_time,
    @_backup_outage_weekday_mask          = p.planned_outage_weekday_mask,
    @_copy_enabled                        = copy_enabled,
    @_load_enabled                        = load_enabled,
    @_out_of_sync_threshold               = out_of_sync_threshold,
    @_out_of_sync_threshold_alert         = s.threshold_alert,
    @_out_of_sync_threshold_alert_enabled = s.threshold_alert_enabled,
    @_out_of_sync_outage_start_time       = s.planned_outage_start_time,
    @_out_of_sync_outage_weekday_mask     = s.planned_outage_weekday_mask,
    @_out_of_sync_outage_end_time         = s.planned_outage_end_time
  FROM msdb.dbo.log_shipping_primaries p, msdb.dbo.log_shipping_secondaries s
  WHERE 
    p.primary_id            = s.primary_id           AND
    primary_server_name     = @primary_server_name   AND
    primary_database_name   = @primary_database_name AND
    secondary_server_name   = @secondary_server_name AND
    secondary_database_name = @secondary_database_name

  SELECT @_backup_threshold                    = ISNULL (@backup_threshold,                    @_backup_threshold)
  SELECT @_backup_threshold_alert              = ISNULL (@backup_threshold_alert,              @_backup_threshold_alert)
  SELECT @_backup_threshold_alert_enabled      = ISNULL (@backup_threshold_alert_enabled,      @_backup_threshold_alert_enabled)
  SELECT @_backup_outage_start_time            = ISNULL (@backup_outage_start_time,            @_backup_outage_start_time)
  SELECT @_backup_outage_end_time              = ISNULL (@backup_outage_end_time,              @_backup_outage_end_time)
  SELECT @_backup_outage_weekday_mask          = ISNULL (@backup_outage_weekday_mask,          @_backup_outage_weekday_mask)
  SELECT @_copy_enabled                        = ISNULL (@copy_enabled,                        @_copy_enabled)
  SELECT @_load_enabled                        = ISNULL (@load_enabled,                        @_load_enabled)
  SELECT @_out_of_sync_threshold               = ISNULL (@out_of_sync_threshold,               @_out_of_sync_threshold)
  SELECT @_out_of_sync_threshold_alert         = ISNULL (@out_of_sync_threshold_alert,         @_out_of_sync_threshold_alert)
  SELECT @_out_of_sync_threshold_alert_enabled = ISNULL (@out_of_sync_threshold_alert_enabled, @_out_of_sync_threshold_alert_enabled)
  SELECT @_out_of_sync_outage_start_time       = ISNULL (@out_of_sync_outage_start_time,       @_out_of_sync_outage_start_time)
  SELECT @_out_of_sync_outage_end_time         = ISNULL (@out_of_sync_outage_end_time,         @_out_of_sync_outage_end_time)
  SELECT @_out_of_sync_outage_weekday_mask     = ISNULL (@out_of_sync_outage_weekday_mask,     @_out_of_sync_outage_weekday_mask)

  -- updates
  UPDATE msdb.dbo.log_shipping_primaries SET
    backup_threshold            = @_backup_threshold,
    threshold_alert             = @_backup_threshold_alert,
    threshold_alert_enabled     = @_backup_threshold_alert_enabled,
    planned_outage_start_time   = @_backup_outage_start_time,
    planned_outage_end_time     = @_backup_outage_end_time,
    planned_outage_weekday_mask = @_backup_outage_weekday_mask
  WHERE primary_server_name = @primary_server_name AND primary_database_name = @primary_database_name

  UPDATE msdb.dbo.log_shipping_secondaries SET
    copy_enabled                = @_copy_enabled,
    load_enabled                = @_load_enabled,
    out_of_sync_threshold       = @_out_of_sync_threshold,
    threshold_alert             = @_out_of_sync_threshold_alert,
    threshold_alert_enabled     = @_out_of_sync_threshold_alert_enabled,
    planned_outage_start_time   = @_out_of_sync_outage_start_time,
    planned_outage_end_time     = @_out_of_sync_outage_weekday_mask,
    planned_outage_weekday_mask = @_out_of_sync_outage_end_time
  WHERE secondary_server_name = @secondary_server_name AND secondary_database_name = @secondary_database_name
RETURN(0)
END
go

/**************************************************************/
/* sp_delete_log_shipping_monitor_info                        */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_delete_log_shipping_monitor_info...'
go
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_delete_log_shipping_monitor_info' AND type = N'P')  )
  DROP PROCEDURE sp_delete_log_shipping_monitor_info
go
CREATE PROCEDURE sp_delete_log_shipping_monitor_info
  @primary_server_name                 sysname,
  @primary_database_name               sysname,
  @secondary_server_name               sysname,
  @secondary_database_name             sysname
AS BEGIN
  -- check that the primary exists
  IF (NOT EXISTS (SELECT * FROM msdb.dbo.log_shipping_primaries WHERE primary_server_name = @primary_server_name AND primary_database_name = @primary_database_name))
  BEGIN
    DECLARE @pp sysname
    SELECT @pp = @primary_server_name + N'.' + @primary_database_name
    RAISERROR (14262, 16, 1, N'primary_server_name.primary_database_name', @pp)
    RETURN (1) -- error
  END

  -- check that the secondary exists
  IF (NOT EXISTS (SELECT * FROM msdb.dbo.log_shipping_secondaries WHERE secondary_server_name = @secondary_server_name AND secondary_database_name = @secondary_database_name))
  BEGIN
    DECLARE @sp sysname
    SELECT @sp = @secondary_server_name + N'.' + @secondary_database_name
    RAISERROR (14262, 16, 1, N'secondary_server_name.secondary_database_name', @sp)
    RETURN (1) -- error
  END

  BEGIN TRANSACTION

  -- delete the secondary
  DELETE FROM msdb.dbo.log_shipping_secondaries WHERE secondary_server_name = @secondary_server_name AND secondary_database_name = @secondary_database_name
  IF (@@error <> 0)
    goto rollback_quit

  -- if there are no more secondaries for this primary then delete it
  IF (NOT EXISTS (SELECT * FROM msdb.dbo.log_shipping_primaries p, msdb.dbo.log_shipping_secondaries s WHERE p.primary_id = s.primary_id AND primary_server_name = @primary_server_name AND primary_database_name = @primary_database_name))
  BEGIN
    DELETE FROM msdb.dbo.log_shipping_primaries WHERE primary_server_name = @primary_server_name AND primary_database_name = @primary_database_name
    IF (@@error <> 0)
      goto rollback_quit
  END
 COMMIT TRANSACTION
 RETURN (0)

rollback_quit:
  ROLLBACK TRANSACTION
  RETURN(1) -- Failure
END
go 

/**************************************************************/
/* sp_remove_log_shipping_monitor_account                     */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_remove_log_shipping_monitor_account...'
go
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_remove_log_shipping_monitor_account' AND type = N'P')  )
  DROP PROCEDURE sp_remove_log_shipping_monitor_account
go

CREATE PROCEDURE sp_remove_log_shipping_monitor_account
AS
BEGIN
  SET NOCOUNT ON
  EXECUTE sp_dropuser N'log_shipping_monitor_probe'
  EXECUTE sp_droplogin N'log_shipping_monitor_probe'
END
go

/**************************************************************/
/* sp_log_shipping_monitor_backup                             */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_log_shipping_monitor_backup...'
go
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_log_shipping_monitor_backup' AND type = N'P')  )
  drop procedure sp_log_shipping_monitor_backup
go

CREATE PROCEDURE sp_log_shipping_monitor_backup AS
BEGIN
  DECLARE @primary_id                  sysname
  DECLARE @primary_server_name         sysname 
  DECLARE @primary_database_name       sysname 
  DECLARE @maintenance_plan_id         UNIQUEIDENTIFIER
  DECLARE @backup_threshold            INT
  DECLARE @threshold_alert             INT 
  DECLARE @threshold_alert_enabled     BIT 
  DECLARE @last_backup_filename        sysname 
  DECLARE @last_updated                DATETIME
  DECLARE @planned_outage_start_time   INT
  DECLARE @planned_outage_end_time     INT 
  DECLARE @planned_outage_weekday_mask INT
  DECLARE @sync_status                 INT
  DECLARE @backup_delta                INT
  DECLARE @delta_string                NVARCHAR (10)
  DECLARE @dt                             DATETIME

  SELECT @dt = GETDATE ()

  SET NOCOUNT ON

  DECLARE bmlsp_cur CURSOR FOR
    SELECT primary_id, 
           primary_server_name, 
           primary_database_name, 
    	   maintenance_plan_id, 
           backup_threshold, 
           threshold_alert, 
           threshold_alert_enabled, 
           last_backup_filename, 
           last_updated,
           planned_outage_start_time, 
           planned_outage_end_time, 
           planned_outage_weekday_mask 
    FROM msdb.dbo.log_shipping_primaries
    FOR READ ONLY

  OPEN bmlsp_cur
loop:
  FETCH NEXT FROM bmlsp_cur 
  INTO @primary_id, 
       @primary_server_name, 
	   @primary_database_name, 
	   @maintenance_plan_id,
       @backup_threshold, 
	   @threshold_alert, 
	   @threshold_alert_enabled, 
	   @last_backup_filename, 
	   @last_updated, 
  	   @planned_outage_start_time,
       @planned_outage_end_time, 
	   @planned_outage_weekday_mask

  IF @@FETCH_STATUS <> 0 -- nothing more to fetch, finish the loop
    GOTO _loop

  EXECUTE @sync_status = sp_log_shipping_in_sync
    @last_updated,
    @dt,
	  @backup_threshold,
  	@planned_outage_start_time,
  	@planned_outage_end_time,
    @planned_outage_weekday_mask,
  	@threshold_alert_enabled,
  	@backup_delta OUTPUT

   IF (@sync_status < 0)
   BEGIN
     SELECT @delta_string = CONVERT (NVARCHAR(10), @backup_delta)
     RAISERROR (@threshold_alert, 16, 1, @primary_server_name, @primary_database_name, @delta_string)
   END

  GOTO loop
_loop:
  CLOSE bmlsp_cur
  DEALLOCATE bmlsp_cur
END
go

/**************************************************************/
/* sp_log_shipping_monitor_restore                            */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_log_shipping_monitor_restore...'
go
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_log_shipping_monitor_restore' AND type = N'P')  )
  drop procedure sp_log_shipping_monitor_restore
go
CREATE PROCEDURE sp_log_shipping_monitor_restore AS
BEGIN
  SET NOCOUNT ON
  DECLARE @primary_id                  INT
  DECLARE @secondary_server_name       sysname
  DECLARE @secondary_database_name     sysname
  DECLARE @secondary_plan_id           UNIQUEIDENTIFIER
  DECLARE @out_of_sync_threshold       INT 
  DECLARE @threshold_alert             INT 
  DECLARE @threshold_alert_enabled     BIT 
  DECLARE @last_loaded_filename        NVARCHAR (500)
  DECLARE @last_backup_filename        NVARCHAR (500) 
  DECLARE @primary_database_name       sysname
  DECLARE @last_loaded_last_updated    DATETIME
  DECLARE @last_backup_last_updated    DATETIME
  DECLARE @planned_outage_start_time   INT 
  DECLARE @planned_outage_end_time     INT 
  DECLARE @planned_outage_weekday_mask INT
  DECLARE @sync_status                 INT
  DECLARE @sync_delta                  INT
  DECLARE @delta_string                NVARCHAR(10)

  SET NOCOUNT ON
  DECLARE @backupdt  DATETIME
  DECLARE @restoredt DATETIME
  DECLARE @rv        INT
  DECLARE rmlsp_cur CURSOR FOR
    SELECT s.primary_id, 
      s.secondary_server_name, 
      s.secondary_database_name, 
      s.secondary_plan_id, 
      s.out_of_sync_threshold, 
      s.threshold_alert, 
      s.threshold_alert_enabled, 
      s.last_loaded_filename, 
      s.last_loaded_last_updated,
      p.last_backup_filename,
      p.last_updated,
      p.primary_database_name,
      s.planned_outage_start_time, 
      s.planned_outage_end_time, 
      s.planned_outage_weekday_mask 
    FROM msdb.dbo.log_shipping_secondaries s 
    INNER JOIN msdb.dbo.log_shipping_primaries p 
    ON s.primary_id = p.primary_id
    FOR READ ONLY

  OPEN rmlsp_cur
loop:
  FETCH NEXT FROM rmlsp_cur 
  INTO @primary_id, 
  	   @secondary_server_name, 
   	   @secondary_database_name, 
		   @secondary_plan_id, 
       @out_of_sync_threshold, 
		   @threshold_alert, 
		   @threshold_alert_enabled, 
		   @last_loaded_filename, 
		   @last_loaded_last_updated,
       @last_backup_filename,
       @last_backup_last_updated,
       @primary_database_name,
       @planned_outage_start_time, 
		   @planned_outage_end_time, 
		   @planned_outage_weekday_mask 

  IF @@FETCH_STATUS <> 0 -- nothing more to fetch, finish the loop
    GOTO _loop

  EXECUTE @rv = sp_log_shipping_get_date_from_file @primary_database_name, @last_backup_filename, @backupdt OUTPUT
  IF (@rv <> 0)
    SELECT @backupdt = @last_backup_last_updated
  
  EXECUTE @rv = sp_log_shipping_get_date_from_file @primary_database_name, @last_loaded_filename, @restoredt OUTPUT
  IF  (@rv <> 0)
    SELECT @restoredt = @last_loaded_last_updated

  EXECUTE @sync_status = sp_log_shipping_in_sync
    @restoredt,
    @backupdt,
	  @out_of_sync_threshold,
	  @planned_outage_start_time,
	  @planned_outage_end_time,
    @planned_outage_weekday_mask,
    @threshold_alert_enabled,
    @sync_delta OUTPUT

   IF (@sync_status < 0)
   BEGIN
     SELECT @delta_string = CONVERT (NVARCHAR(10), @sync_delta)
     RAISERROR (@threshold_alert, 16, 1, @secondary_server_name, @secondary_database_name, @delta_string)
   END

  GOTO loop
_loop:
  CLOSE rmlsp_cur
  DEALLOCATE rmlsp_cur
END
go

/**************************************************************/
/* sp_change_monitor_role                                     */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_change_monitor_role...'
go
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_change_monitor_role' AND type = N'P')  )
  DROP PROCEDURE sp_change_monitor_role
go
CREATE PROCEDURE sp_change_monitor_role
  @primary_server     sysname,
  @secondary_server   sysname,
  @database           sysname,
  @new_source         NVARCHAR (128)
AS BEGIN
  SET NOCOUNT ON

  BEGIN TRANSACTION

  -- drop the secondary
  DELETE FROM msdb.dbo.log_shipping_secondaries 
    WHERE secondary_server_name = @secondary_server AND secondary_database_name = @database

  IF (@@ROWCOUNT <> 1)
  BEGIN
      ROLLBACK TRANSACTION
      RAISERROR (14442,-1,-1)
      return(1)
  END

  -- let everyone know that we are the new primary
  UPDATE msdb.dbo.log_shipping_primaries 
    SET primary_server_name = @secondary_server, primary_database_name = @database, source_directory = @new_source
    WHERE primary_server_name = @primary_server AND primary_database_name = @database

  IF (@@ROWCOUNT <> 1)
  BEGIN
      ROLLBACK TRANSACTION
      RAISERROR (14442,-1,-1)
      return(1)
  END
  COMMIT TRANSACTION

END
go

/**************************************************************/
/* sp_create_log_shipping_monitor_account                     */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_create_log_shipping_monitor_account...'
go
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_create_log_shipping_monitor_account' AND type = N'P')  )
  drop procedure sp_create_log_shipping_monitor_account
go
CREATE PROCEDURE sp_create_log_shipping_monitor_account @password sysname
AS
BEGIN
  DECLARE @rv INT
  SET NOCOUNT ON
-- raise an error if the password already exists
  if exists(select * from master.dbo.syslogins where loginname = N'log_shipping_monitor_probe')
  begin
    raiserror(15025,-1,-1,N'log_shipping_monitor_probe')
    RETURN (1) -- error
  end

  IF (@password = N'')
  BEGIN
    EXECUTE @rv = sp_addlogin N'log_shipping_monitor_probe', @defdb = N'msdb'
    IF @@error <>0 or @rv <> 0
      RETURN (1) -- error
  END
  ELSE
  BEGIN
    EXECUTE @rv = sp_addlogin N'log_shipping_monitor_probe', @password, N'msdb'
    IF @@error <>0 or @rv <> 0
      RETURN (1) -- error
  END

  EXECUTE @rv = sp_grantdbaccess N'log_shipping_monitor_probe', N'log_shipping_monitor_probe'
  IF @@error <>0 or @rv <> 0
    RETURN (1) -- error

  GRANT UPDATE ON log_shipping_primaries   TO log_shipping_monitor_probe
  GRANT UPDATE ON log_shipping_secondaries TO log_shipping_monitor_probe
  GRANT SELECT ON log_shipping_primaries   TO log_shipping_monitor_probe
  GRANT SELECT ON log_shipping_secondaries TO log_shipping_monitor_probe

  RETURN (0)
END
go

GRANT EXECUTE ON sp_get_log_shipping_monitor_info TO PUBLIC

/**************************************************************/
/* Turn 'System Object' marking OFF                           */
/**************************************************************/
PRINT ''
EXECUTE master.dbo.sp_MS_upd_sysobj_category 2
go

EXECUTE master.dbo.sp_configure N'allow updates', 0
go
RECONFIGURE WITH OVERRIDE
go

PRINT ''
PRINT '----------------------------------'
PRINT 'Execution of INSTMSDB.SQL complete'
PRINT '----------------------------------'
go

DUMP TRANSACTION msdb WITH NO_LOG
go
CHECKPOINT
go
