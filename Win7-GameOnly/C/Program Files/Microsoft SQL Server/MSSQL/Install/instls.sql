/**********************************************************************/
/* instls.sql                                                         */
/*                                                                    */
/* Installs the tables and stored procedures used to support log      */
/* shipping on the primary, secondary, and monotor servers.           */
/*
** Copyright Microsoft, Inc. 1994 - 2000
** All Rights Reserved.
*/
/*                                                                    */
/**********************************************************************/

PRINT N'--------------------------------'
PRINT N'Starting execution of INSTLS.SQL'
PRINT N'--------------------------------'
go

USE msdb
go

-- Explicitly set the options that the server stores with the object in sysobjects.status
-- so that it doesn't matter if the script is run using a DBLib or ODBC based client.
SET QUOTED_IDENTIFIER OFF -- We don't use quoted identifiers
SET ANSI_NULLS ON         -- We don't want (NULL = NULL) == TRUE
go

-- @drop_tbl, set to one to drop and then recreate the tables
DECLARE @drop_tbl BIT
SELECT  @drop_tbl = 0

/* drop stored procedures (silently)*/
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_update_log_shipping_plan' AND type = N'P'))
	DROP PROCEDURE sp_update_log_shipping_plan
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_add_log_shipping_plan' AND type = N'P'))
	DROP PROCEDURE sp_add_log_shipping_plan
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_delete_log_shipping_plan' AND type = N'P'))
	DROP PROCEDURE sp_delete_log_shipping_plan
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_add_log_shipping_plan_database' AND type = N'P'))
	DROP PROCEDURE sp_add_log_shipping_plan_database
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_delete_log_shipping_plan_database' AND type = N'P'))
	DROP PROCEDURE sp_delete_log_shipping_plan_database
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_add_log_shipping_database' AND type = N'P'))
	DROP PROCEDURE sp_add_log_shipping_database
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_delete_log_shipping_database' AND type = N'P'))
	DROP PROCEDURE sp_delete_log_shipping_database
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_verify_lsp_identifiers' AND type = N'P'))
	DROP PROCEDURE sp_verify_lsp_identifiers
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_update_log_shipping_plan_database' AND type = N'P'))
	DROP PROCEDURE sp_update_log_shipping_plan_database
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_remove_log_shipping_monitor' AND type = N'P')  )
	DROP PROCEDURE sp_remove_log_shipping_monitor
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_can_tlog_be_applied' AND type = N'P')  )
	DROP PROCEDURE sp_can_tlog_be_applied
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_change_primary_role' AND type = N'P')  )
	DROP PROCEDURE sp_change_primary_role
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_change_secondary_role' AND type = N'P')  )
	DROP PROCEDURE sp_change_secondary_role
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_define_log_shipping_monitor' AND type = N'P'))
	DROP PROCEDURE sp_define_log_shipping_monitor
IF (EXISTS (SELECT * from msdb.dbo.sysobjects WHERE name = N'sp_resolve_logins' AND type = N'P')  )
	DROP PROCEDURE sp_resolve_logins

/* drop tables */
IF (EXISTS (SELECT *
            FROM INFORMATION_SCHEMA.TABLES
            WHERE (TABLE_NAME = N'log_shipping_monitor') AND @drop_tbl = 1))
BEGIN
	PRINT 'Dropping Table log_shipping_monitor'
	DROP TABLE msdb.dbo.log_shipping_monitor
END

IF (EXISTS (SELECT *
            FROM INFORMATION_SCHEMA.TABLES
            WHERE (TABLE_NAME = N'log_shipping_databases') AND @drop_tbl = 1))
BEGIN
	PRINT 'Dropping Table log_shipping_databases'
	DROP TABLE msdb.dbo.log_shipping_databases
END

IF (EXISTS (SELECT *
            FROM INFORMATION_SCHEMA.TABLES
            WHERE (TABLE_NAME = N'log_shipping_plan_databases') AND @drop_tbl = 1))
BEGIN
	PRINT 'Dropping Table log_shipping_plan_databases'
	DROP TABLE msdb.dbo.log_shipping_plan_databases
END

IF (EXISTS (SELECT *
            FROM INFORMATION_SCHEMA.TABLES
            WHERE (TABLE_NAME = N'log_shipping_plans') AND @drop_tbl = 1))
BEGIN
	PRINT 'Dropping Table log_shipping_plans'
	DROP TABLE msdb.dbo.log_shipping_plans
END

IF (EXISTS (SELECT *
            FROM INFORMATION_SCHEMA.TABLES
            WHERE (TABLE_NAME = N'log_shipping_plan_history') AND @drop_tbl = 1))
BEGIN
	PRINT 'Dropping Table log_shipping_plan_history'
	DROP TABLE msdb.dbo.log_shipping_plan_history
END

/* alter existing tables */
IF (EXISTS (SELECT *
            FROM INFORMATION_SCHEMA.TABLES
            WHERE (TABLE_NAME = N'sysdbmaintplans')))
BEGIN
  IF (NOT EXISTS (SELECT *
                  FROM msdb.dbo.syscolumns
                  WHERE name = N'log_shipping' AND id = OBJECT_ID(N'sysdbmaintplans')))
  BEGIN
	PRINT ''
	PRINT 'Altering table sysdbmaintplans.'
	ALTER TABLE sysdbmaintplans ADD log_shipping BIT NULL DEFAULT (0)
  END
END

/* create tables */

/**********************************************************************/
/* TABLE : log_shipping_monitor                                       */
/* Populated on primary and secondary servers. Contains information   */
/* need to contact the monitor server                                 */
/**********************************************************************/

IF (EXISTS (SELECT *
            FROM INFORMATION_SCHEMA.TABLES
            WHERE (TABLE_NAME = N'log_shipping_monitor')))
BEGIN
  PRINT 'Table log_shipping_monitor already exists.'
END

ELSE BEGIN
 PRINT 'Creating table log_shipping monitor.'  
 CREATE TABLE log_shipping_monitor
 (
  monitor_server_name	sysname		      NOT NULL,
  logon_type		      INT		          NOT NULL,
  logon_data		      VARBINARY(256)	NULL
 )
END
go

/**********************************************************************/
/* TABLE : log_shipping_databases	                                  */
/* Populated on the primary server. Used by the GUI to display which  */
/* databases are participating in log shipping.                       */
/**********************************************************************/

IF (EXISTS (SELECT *
            FROM INFORMATION_SCHEMA.TABLES
            WHERE (TABLE_NAME = N'log_shipping_databases')))

BEGIN
 PRINT 'Table log_shipping_databases already exists.'
END

ELSE BEGIN
 PRINT 'Creating table log_shipping_databases.'
 CREATE TABLE log_shipping_databases
 (
  database_name	       	sysname		       NOT NULL,
  maintenance_plan_id   UNIQUEIDENTIFIER NULL
 )
END
go

/**********************************************************************/
/* TABLE : log_shipping_plans                                         */
/* Populated on the secondary server.                                 */
/*                                                                    */
/**********************************************************************/

IF (EXISTS (SELECT *
            FROM INFORMATION_SCHEMA.TABLES
            WHERE (TABLE_NAME = N'log_shipping_plans')))

BEGIN
 PRINT 'Table log_shipping_plans already exists.'
  -- check for old table structure
 IF (NOT EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.COLUMNS
                 WHERE (TABLE_NAME = N'log_shipping_plans')
                 AND (COLUMN_NAME = N'maintenance_plan_id')))
 BEGIN
  PRINT 'Adding column maintenance_plan_id to table log_shipping_plans...'
  ALTER TABLE log_shipping_plans ADD maintenance_plan_id UNIQUEIDENTIFIER NULL
 END
 IF (NOT EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.COLUMNS
                 WHERE (TABLE_NAME = N'log_shipping_plans')
                 AND (COLUMN_NAME = N'backup_job_id')))
 BEGIN
  PRINT 'Adding column backup_job_id to table log_shipping_plans...'
  ALTER TABLE log_shipping_plans ADD backup_job_id UNIQUEIDENTIFIER NULL
 END 
 IF (NOT EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.COLUMNS
                 WHERE (TABLE_NAME = N'log_shipping_plans')
                 AND (COLUMN_NAME = N'share_name')))
 BEGIN
  PRINT 'Adding column share_name to table log_shipping_plans...'
  ALTER TABLE log_shipping_plans ADD share_name NVARCHAR(500) NULL
 END
END

ELSE BEGIN
 PRINT 'Creating table log_shipping_plans.'
 CREATE TABLE log_shipping_plans
 (
  plan_id                  UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
  plan_name                sysname          NOT NULL,
  description              NVARCHAR(500)    NULL,
  source_server            sysname          NOT NULL,
  source_dir               NVARCHAR(500)    NOT NULL,
  destination_dir          NVARCHAR(500)    NOT NULL,
  copy_job_id              UNIQUEIDENTIFIER NOT NULL,
  load_job_id              UNIQUEIDENTIFIER NOT NULL,
  history_retention_period INT              NOT NULL, /* minutes */
  file_retention_period    INT              NOT NULL, /* minutes */
  maintenance_plan_id      UNIQUEIDENTIFIER NULL,     /* for role changes */
  backup_job_id            UNIQUEIDENTIFIER NULL,
  share_name               NVARCHAR(500)    NULL
 )
END
go

/**********************************************************************/
/* TABLE : log_shipping_plan_databases                                */
/* Populated on secondary server.                                     */
/*                                                                    */
/**********************************************************************/

IF (EXISTS (SELECT *
            FROM INFORMATION_SCHEMA.TABLES
            WHERE (TABLE_NAME = N'log_shipping_plan_databases')))
BEGIN
  PRINT 'Table log_shipping_plan_databases already exists.'

 -- check for old table structure
  IF (NOT EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.COLUMNS
                 WHERE (TABLE_NAME = N'log_shipping_plan_databases')
                 AND (COLUMN_NAME = N'recover_db')))
  BEGIN
    PRINT 'Adding column recover_db to table log_shipping_plan_databases...'
    ALTER TABLE log_shipping_plan_databases ADD recover_db BIT NOT NULL DEFAULT 0
  END
  IF (NOT EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.COLUMNS
                 WHERE (TABLE_NAME = N'log_shipping_plan_databases')
                 AND (COLUMN_NAME = N'terminate_users')))
  BEGIN
    PRINT 'Adding column terminate_users to table log_shipping_plan_databases...'
    ALTER TABLE log_shipping_plan_databases ADD terminate_users BIT NOT NULL DEFAULT 0    
  END
END

ELSE BEGIN
 PRINT 'Creating table log_shipping_plan_databases.'
 CREATE TABLE log_shipping_plan_databases
 (
  plan_id               UNIQUEIDENTIFIER NOT NULL,
  source_database       sysname          NOT NULL,
  destination_database  sysname          NOT NULL,
  load_delay            INT              NOT NULL,  /* minutes */
  load_all              BIT              NOT NULL,  /* 1 if all copied T-Logs should be loaded */
  last_file_copied      NVARCHAR(500)    NULL,
  date_last_copied      DATETIME         NULL,
  last_file_loaded      NVARCHAR(500)    NULL,
  date_last_loaded      DATETIME         NULL,
  copy_enabled          BIT              NOT NULL,
  load_enabled          BIT              NOT NULL,  /*1 = load enabled, 0 = load disabled */
  recover_db            BIT              NOT NULL,
  terminate_users       BIT              NOT NULL
 )
END
go

IF (EXISTS (SELECT *
            FROM INFORMATION_SCHEMA.TABLES
            WHERE (TABLE_NAME = N'log_shipping_plan_history')))
BEGIN
 PRINT 'Table log_shipping_plan_history already exists.'
END

ELSE BEGIN
 PRINT 'Creating table log_shipping_plan_history'
  CREATE TABLE msdb.dbo.log_shipping_plan_history
  (
    sequence_id          INT              NOT NULL IDENTITY UNIQUE,
    plan_id              UNIQUEIDENTIFIER NOT NULL,
    source_database      sysname          NOT NULL,
    destination_database sysname          NOT NULL,
    activity             BIT              NOT NULL DEFAULT (0), -- 0 = copy, 1=load
    succeeded            BIT              NOT NULL,
    num_files            INT              NOT NULL DEFAULT (0),
    last_file            NVARCHAR(256)    NULL,
    end_time             DATETIME         NOT NULL DEFAULT (GETDATE()),
    duration             INT              NULL     DEFAULT (0),
    error_number         INT              NOT NULL DEFAULT (0),
    message              NVARCHAR(500)    NULL
 )   
END
go

/**************************************************************/
/* Create stored procedures                                   */
/**************************************************************/

/**************************************************************/
/* sp_verify_lsp_identifiers                                  */
/**************************************************************/
PRINT 'Creating procedure sp_verify_lsp_identifiers.'
go
CREATE PROCEDURE sp_verify_lsp_identifiers
  @plan_id   UNIQUEIDENTIFIER = NULL OUTPUT,
  @plan_name sysname          = NULL
AS BEGIN
  DECLARE @_plan_id UNIQUEIDENTIFIER

  SET NOCOUNT ON

  IF (@plan_id IS NULL) AND (@plan_name IS NULL)
  BEGIN
    RAISERROR (14410, -1, -1)
    RETURN(1)
  END

  IF (@plan_name IS NOT NULL)
  BEGIN
-- load plan_id for supplied plan name
    SELECT @_plan_id = plan_id from msdb.dbo.log_shipping_plans WHERE plan_name = @plan_name
-- IF it doesn't exist
    IF (@_plan_id IS NULL)
    BEGIN
      RAISERROR (14262,16,1, N'plan_name', @plan_name)
      RETURN(1)
    END
-- IF a plan_id was supplied as well, check it matches with the plan_name
    IF @_plan_id <> ISNULL (@plan_id, @_plan_id)
    BEGIN
      RAISERROR (14410, -1, -1)
      RETURN(1)
    END
  END

  SELECT @plan_id = ISNULL (@plan_id, @_plan_id)
  RETURN(0)
END
go

/**************************************************************/
/* sp_add_log_shipping_plan                                   */
/**************************************************************/
PRINT 'Creating procedure sp_add_log_shipping_plan.'
go
CREATE PROCEDURE sp_add_log_shipping_plan
  @plan_name                sysname,
  @description              NVARCHAR(500)    = NULL,
  @source_server            sysname,
  @source_dir               NVARCHAR(500),
  @destination_dir          NVARCHAR(500),
  @history_retention_period INT             = 2880, -- 2 days
  @file_retention_period    INT             = 2880, -- 2 days
  @copy_frequency           INT             = 5,
  @restore_frequency        INT             = 5,
  @plan_id                  UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
  DECLARE @copy_job_id      UNIQUEIDENTIFIER
  DECLARE @restore_job_id   UNIQUEIDENTIFIER
  DECLARE @friendly_name    NVARCHAR(500)
  DECLARE @copy_job_name    NVARCHAR(500)
  DECLARE @copy_sql         NVARCHAR(500)
  DECLARE @restore_job_name NVARCHAR(500)
  DECLARE @restore_sql      NVARCHAR(500)
  DECLARE @rv               INT

  SET NOCOUNT ON
-- check plan_name is unique
  IF EXISTS (select * from msdb.dbo.log_shipping_plans where plan_name = @plan_name)
  BEGIN
    RAISERROR (14261,16,1, N'plan_name', @plan_name)
    RETURN (1) -- Failure
  END

  SELECT @plan_id = NEWID ()
  SELECT @copy_sql =    N'EXECUTE master.dbo.xp_sqlmaint ''-LSCopyPlanID "' + CONVERT (NVARCHAR(36), @plan_id) + '"'''
  SELECT @copy_job_name = N'Log Shipping copy for ' + @plan_name
  SELECT @restore_job_name = N'Log Shipping Restore for ' + @plan_name
  SELECT @restore_sql = N'EXECUTE master.dbo.xp_sqlmaint ''-LSRestorePlanID "' + CONVERT (NVARCHAR(36), @plan_id) + '"'''

  BEGIN TRANSACTION

-- create copy job

    EXECUTE @rv = msdb.dbo.sp_add_job @job_name = @copy_job_name , @job_id= @copy_job_id OUTPUT

    IF (@@error <> 0 OR @rv <> 0) GOTO rollback_quit -- error 

    EXECUTE @rv = msdb.dbo.sp_add_jobstep @job_id = @copy_job_id, @step_id = 1, @step_name = N'Log Shipping Copy', 
      @command = @copy_sql,
      @on_fail_action = 2, @flags = 4, @subsystem = N'TSQL', @on_success_step_id = 0, @on_success_action = 1, 
      @on_fail_step_id = 0
    IF (@@error <> 0 OR @rv <> 0) GOTO rollback_quit -- error 

    EXECUTE @rv = msdb.dbo.sp_add_jobschedule @job_id = @copy_job_id,
      @freq_type = 4, @freq_interval = 1, @freq_subday_type = 0x4, @freq_subday_interval = @copy_frequency,
      @freq_relative_interval = 0, @name = N'Schedule 1'
    IF (@@error <> 0 OR @rv <> 0) GOTO rollback_quit -- error 

    EXECUTE msdb.dbo.sp_add_jobserver @job_id = @copy_job_id, @server_name = N'(local)' 

-- create restore job

    EXECUTE @rv = msdb.dbo.sp_add_job @job_name = @restore_job_name, @job_id= @restore_job_id OUTPUT

    IF (@@error <> 0 OR @rv <> 0) GOTO rollback_quit -- error 

    EXECUTE @rv = msdb.dbo.sp_add_jobstep @job_id = @restore_job_id, @step_id = 1, @step_name = N'Log Shipping Restore', 
      @command = @restore_sql,
      @on_fail_action = 2, @flags = 4, @subsystem = N'TSQL', @on_success_step_id = 0, @on_success_action = 1, 
      @on_fail_step_id = 0
    IF (@@error <> 0 OR @rv <> 0) GOTO rollback_quit -- error 

    EXECUTE @rv = msdb.dbo.sp_add_jobschedule @job_id = @restore_job_id,
      @freq_type = 4, @freq_interval = 1, @freq_subday_type = 0x4, @freq_subday_interval = @copy_frequency,
      @freq_relative_interval = 0, @name = N'Schedule 1'
    IF (@@error <> 0 OR @rv <> 0) GOTO rollback_quit -- error 

    EXECUTE @rv = msdb.dbo.sp_add_jobserver @job_id = @restore_job_id, @server_name = N'(local)'
    IF (@@error <> 0 OR @rv <> 0) GOTO rollback_quit -- error 

-- populate log_shipping_plans

    INSERT INTO msdb.dbo.log_shipping_plans (
      plan_id,
      plan_name,
      description,
      source_server,
      source_dir,
      destination_dir,
      copy_job_id,
      load_job_id,
      history_retention_period,
      file_retention_period )
    VALUES (
      @plan_id, 
      @plan_name, 
      @description, 
      @source_server, 
      @source_dir, 
      @destination_dir, 
      @copy_job_id, 
      @restore_job_id, 
      @history_retention_period,
      @file_retention_period)

    IF (@@error <> 0) GOTO rollback_quit -- error

  COMMIT TRANSACTION
  RETURN(0)  -- success
rollback_quit:
  ROLLBACK TRANSACTION
  RETURN (1) -- Failure
END
go
/**************************************************************/
/* sp_delete_log_shipping_plan                                */
/**************************************************************/
PRINT 'Creating procedure sp_delete_log_shipping_plan.'
go
CREATE PROCEDURE sp_delete_log_shipping_plan
  @plan_id     UNIQUEIDENTIFIER = NULL,
  @plan_name   sysname          = NULL,
  @del_plan_db BIT              = 0
AS BEGIN
  DECLARE @rv	      INT
  DECLARE @copy_job UNIQUEIDENTIFIER
  DECLARE @load_job UNIQUEIDENTIFIER

  SET NOCOUNT ON

  EXECUTE @rv = msdb.dbo.sp_verify_lsp_identifiers @plan_id OUTPUT, @plan_name
  IF (@rv<>0)
    RETURN(1) -- error 

  BEGIN TRANSACTION
-- dri check
  IF EXISTS (SELECT * FROM msdb.dbo.log_shipping_plan_databases WHERE plan_id = @plan_id)
  BEGIN
    IF (@del_plan_db = 0)
    BEGIN
      RAISERROR (14423,-1,-1)
      goto rollback_quit
    END
-- cascade delete
    DELETE FROM msdb.dbo.log_shipping_plan_databases WHERE plan_id = @plan_id
  END

-- delete the copy and load jobs
  SELECT @copy_job = copy_job_id, @load_job = load_job_id FROM msdb.dbo.log_shipping_plans WHERE plan_id = @plan_id
  IF (@copy_job IS NOT NULL)
  BEGIN
    EXECUTE @rv =msdb.dbo.sp_delete_job @copy_job
    IF (@@error <> 0 OR @rv <> 0)
      goto rollback_quit
  END

  IF (@load_job IS NOT NULL)
  BEGIN
    EXECUTE @rv =msdb.dbo.sp_delete_job @load_job
    IF (@@error <> 0 OR @rv <> 0)
      goto rollback_quit
  END
    
  DELETE FROM msdb.dbo.log_shipping_plans WHERE plan_id = @plan_id
  COMMIT TRANSACTION
  RETURN(0)
rollback_quit:
  ROLLBACK TRANSACTION
  RETURN(1) -- error
END
go
/**************************************************************/
/* sp_update_log_shipping_plan                                */
/**************************************************************/
PRINT 'Creating procedure sp_update_log_shipping_plan.'
go
CREATE PROCEDURE sp_update_log_shipping_plan
  @plan_id                  UNIQUEIDENTIFIER = NULL,
  @plan_name                sysname          = NULL,
  @description              NVARCHAR(500)    = NULL,
  @source_server            sysname          = NULL,
  @source_dir               NVARCHAR(500)    = NULL,
  @destination_dir          NVARCHAR(500)    = NULL,
  @copy_job_id              UNIQUEIDENTIFIER = NULL,
  @load_job_id              UNIQUEIDENTIFIER = NULL,
  @history_retention_period INT              = NULL,
  @file_retention_period    INT              = NULL
AS
BEGIN
  DECLARE @_plan_name                sysname
  DECLARE @_description              NVARCHAR(500)
  DECLARE @_source_server            sysname
  DECLARE @_source_dir               NVARCHAR(500)
  DECLARE @_destination_dir          NVARCHAR(500)
  DECLARE @_copy_job_id              UNIQUEIDENTIFIER
  DECLARE @_load_job_id              UNIQUEIDENTIFIER
  DECLARE @_history_retention_period INT
  DECLARE @_file_retention_period    INT
  DECLARE @rv                        INT

  SET NOCOUNT ON

-- check plan name and name
  IF (@plan_id IS NULL)
  BEGIN
    EXECUTE @rv = msdb.dbo.sp_verify_lsp_identifiers @plan_id OUTPUT, @plan_name
    IF (@rv <> 0)
      RETURN(@rv)
  END
  ELSE
  BEGIN
    EXECUTE @rv = msdb.dbo.sp_verify_lsp_identifiers @plan_id OUTPUT
    IF (@rv <> 0)
      RETURN(@rv)
  END
  
-- get existing values
  SELECT
    @_plan_name                = plan_name,
    @_description              = description,
    @_source_server            = source_server,
    @_source_dir               = source_dir,
    @_destination_dir          = destination_dir,
    @_copy_job_id              = copy_job_id,
    @_load_job_id              = load_job_id,
    @_history_retention_period = history_retention_period,
    @_file_retention_period    = file_retention_period
  FROM msdb.dbo.log_shipping_plans
  WHERE plan_id = @plan_id

-- If the plan name is changing, check it doesn't already exist
  IF (@plan_name <> @_plan_name)
  BEGIN
    IF (EXISTS (SELECT plan_id FROM msdb.dbo.log_shipping_plans where plan_name = @plan_name))
    BEGIN
      RAISERROR (14262, 16,1, 'plan_name', @plan_name)
      RETURN(1) -- error
    END
  END

-- enter new values for all changing parameters
  SELECT @_plan_name                = ISNULL (@plan_name,                @_plan_name)
  SELECT @_description              = ISNULL (@description,              @_description)
  SELECT @_source_server            = ISNULL (@source_server,            @_source_server)
  SELECT @_source_dir               = ISNULL (@source_dir,               @_source_dir)
  SELECT @_destination_dir          = ISNULL (@destination_dir,          @_destination_dir)
  SELECT @_copy_job_id              = ISNULL (@copy_job_id,              @_copy_job_id)
  SELECT @_load_job_id              = ISNULL (@load_job_id,              @_load_job_id)
  SELECT @_history_retention_period = ISNULL (@history_retention_period, @_history_retention_period)
  SELECT @_file_retention_period    = ISNULL (@file_retention_period,    @_file_retention_period)

-- update plan
  UPDATE msdb.dbo.log_shipping_plans SET
    plan_name                = @_plan_name,
    description              = @_description,
    source_server            = @_source_server,
    source_dir               = @_source_dir,
    destination_dir          = @_destination_dir,
    copy_job_id              = @_copy_job_id,
    load_job_id              = @_load_job_id,
    history_retention_period = @_history_retention_period,
    file_retention_period    = @_file_retention_period
  WHERE plan_id = @plan_id
END
go
/**************************************************************/
/* sp_add_log_shipping_plan_database                          */
/**************************************************************/
PRINT 'Creating procedure sp_add_log_shipping_plan_database.'
go
CREATE PROCEDURE sp_add_log_shipping_plan_database
  @plan_id               UNIQUEIDENTIFIER  = NULL,
  @plan_name             sysname           = NULL,
  @source_database       sysname,
  @destination_database  sysname,
  @load_delay            INT               = 0,    -- load delay in minutes
  @load_all              BIT               = 1,    -- set to 0 to load 1 db at a time
  @copy_enabled          BIT               = 1,    -- perform copy
  @load_enabled          BIT               = 1,    -- perform load
  @recover_db            BIT               = 1,
  @terminate_users       BIT               = 1
AS BEGIN
  DECLARE @rv INT

  SET NOCOUNT ON
-- check that the log shipping plan exists
  EXECUTE @rv = msdb.dbo.sp_verify_lsp_identifiers  @plan_id OUTPUT, @plan_name
  IF (@rv <> 0) RETURN (-11) -- error

-- check that the destination database exists
  IF NOT EXISTS (SELECT * FROM master.dbo.sysdatabases WHERE name = @destination_database)
  BEGIN
    RAISERROR (14262, 16, 1, N'destination_database', @destination_database)
    RETURN(1) -- error
  END

-- check that the destination database isn't already part of a log shipping pair
  IF EXISTS (SELECT * FROM msdb.dbo.log_shipping_plan_databases where destination_database = @destination_database)
  BEGIN
    RAISERROR (14424,-1,-1, @destination_database)
    RETURN(1) -- error
  END

  INSERT INTO log_shipping_plan_databases (
    plan_id,
    source_database,
    destination_database,
    load_delay,
    load_all,
    last_file_copied,
    date_last_copied,
    last_file_loaded,
    date_last_loaded,
    copy_enabled,
    load_enabled,
	recover_db,
	terminate_users)
  VALUES (
    @plan_id, 
    @source_database, 
    @destination_database, 
    @load_delay, 
    @load_all,
    N'first_file_000000000000.trn', 
    GETDATE (), 
    N'first_file_000000000000.trn', 
    GETDATE (), 
    @copy_enabled, 
    @load_enabled,
    @recover_db,
	@terminate_users)

  RETURN(0)
END
go
/**************************************************************/
/* sp_update_log_shipping_plan_database                       */
/**************************************************************/
PRINT 'Creating procedure sp_update_log_shipping_plan_database.'
go
CREATE PROCEDURE sp_update_log_shipping_plan_database
  @destination_database  sysname,
  @load_delay            INT              = NULL,
  @load_all              BIT              = NULL,
  @file_retention_period INT              = NULL,
  @copy_enabled          BIT              = NULL,
  @load_enabled          BIT              = NULL,
  @recover_db            BIT              = NULL,
  @terminate_users       BIT              = NULL 
AS BEGIN
  DECLARE @_load_delay            INT
  DECLARE @_load_all              BIT
  DECLARE @_copy_enabled          BIT
  DECLARE @_load_enabled          BIT
  DECLARE @_recover_db            BIT
  DECLARE @_terminate_users       BIT
  DECLARE @rv                     INT

  SET NOCOUNT ON

-- get existing values
  SELECT
    @_load_delay            = load_delay,
    @_load_all              = load_all,
    @_copy_enabled          = copy_enabled,
    @_load_enabled          = load_enabled,
	@_recover_db            = recover_db,
	@_terminate_users       = terminate_users
  FROM msdb.dbo.log_shipping_plan_databases
  WHERE destination_database = @destination_database

-- update existing values with usr supplied values
  SELECT @_load_delay            = ISNULL (@load_delay,            @_load_delay)
  SELECT @_load_all              = ISNULL (@load_all,              @_load_all)
  SELECT @_copy_enabled          = ISNULL (@copy_enabled,          @_copy_enabled)
  SELECT @_load_enabled          = ISNULL (@load_enabled,          @_load_enabled)
  SELECT @_recover_db            = ISNULL (@recover_db,            @_recover_db)
  SELECT @_terminate_users       = ISNULL (@terminate_users,       @_terminate_users)

-- update plan_databases
  UPDATE msdb.dbo.log_shipping_plan_databases SET
    load_delay            = @_load_delay,
    load_all              = @_load_all,
    copy_enabled          = @_copy_enabled,
    load_enabled          = @_load_enabled,
    recover_db            = @_recover_db,
    terminate_users       = @_terminate_users   
  WHERE destination_database = @destination_database
  RETURN(0)
END
go
/**************************************************************/
/* sp_delete_log_shipping_plan_database                       */
/**************************************************************/
PRINT 'Creating procedure sp_delete_log_shipping_plan_database.'
go
CREATE PROCEDURE sp_delete_log_shipping_plan_database
  @plan_id              UNIQUEIDENTIFIER = NULL,
  @plan_name            sysname          = NULL,
  @destination_database sysname          = NULL
AS BEGIN
DECLARE @_plan_id UNIQUEIDENTIFIER
DECLARE @_dest_db sysname

  IF (@plan_id IS NULL) AND (@plan_name IS NULL)
  BEGIN
    -- must supply at least one parameter
    IF (@destination_database IS NULL)
    BEGIN
      RAISERROR (14410,-1,-1)
      RETURN(1)
    END
    SELECT @plan_id = plan_id FROM msdb.dbo.log_shipping_plan_databases WHERE destination_database = @destination_database
  END

  IF (@plan_name IS NOT NULL)
  BEGIN
    SELECT @_plan_id = plan_id from msdb.dbo.log_shipping_plans WHERE plan_name = @plan_name
    IF (@_plan_id IS NOT NULL)
    BEGIN
      IF @_plan_id <> ISNULL (@plan_id, @_plan_id)
      BEGIN
        RAISERROR (14410,-1,-1)
        RETURN(1)
      END
    END
    ELSE
    BEGIN
      RAISERROR (14262, 16, 1, 'plan_name', @plan_name)
      RETURN(1)
    END
  END
  SELECT @_plan_id = ISNULL (@plan_id, @_plan_id)
  SELECT @_dest_db = ISNULL (@destination_database, N'%')

  DELETE FROM log_shipping_plan_databases WHERE plan_id = @_plan_id AND destination_database LIKE @_dest_db
END
go
/**************************************************************/
/* sp_add_log_shipping_database                               */
/**************************************************************/
PRINT 'Creating procedure sp_add_log_shipping_database.'
go
CREATE PROCEDURE sp_add_log_shipping_database
  @db_name	             sysname,
  @maintenance_plan_id   UNIQUEIDENTIFIER  = NULL
AS BEGIN
  SET NOCOUNT ON
  IF NOT EXISTS (select dbid from master.dbo.sysdatabases where name = @db_name)
  BEGIN
    RAISERROR (14261, 16, 1, N'Database', @db_name)
    RETURN (1)
  END
  IF EXISTS (select database_name from msdb.dbo.log_shipping_databases where database_name = @db_name)
  BEGIN
    RAISERROR (14424,-1,-1, @db_name)
    RETURN (1)
  END
  INSERT INTO msdb.dbo.log_shipping_databases (database_name, maintenance_plan_id) VALUES (@db_name, @maintenance_plan_id)
END
go

/**************************************************************/
/* sp_delete_log_shipping_database                            */
/**************************************************************/
PRINT 'Creating procedure sp_delete_log_shipping_database.'
go
CREATE PROCEDURE sp_delete_log_shipping_database
  @db_name	sysname
AS BEGIN
  DELETE FROM msdb.dbo.log_shipping_databases WHERE database_name = @db_name
END
go

/**************************************************************/
/* sp_can_tlog_be_applied                                     */
/**************************************************************/
PRINT 'Creating procedure sp_can_tlog_be_applied.'
go
CREATE PROCEDURE sp_can_tlog_be_applied
  @backup_file_name NVARCHAR(128),
  @database_name    sysname,
  @result           BIT = 0 OUTPUT
AS
BEGIN
  DECLARE @command                 NVARCHAR(256)
  DECLARE @db_recovery_fork_id0    UNIQUEIDENTIFIER
  DECLARE @db_recovery_fork_id1    UNIQUEIDENTIFIER
  DECLARE @db_backup_lsn           NUMERIC(25,0)
  DECLARE @backup_type             INT
  DECLARE @backup_recovery_fork_id UNIQUEIDENTIFIER
  DECLARE @backup_last_lsn         NUMERIC(25,0)
  DECLARE @lsn_slot                INT
  DECLARE @lsn_block               INT
  DECLARE @lsn_file                INT

  SET NOCOUNT ON

  SELECT @result = 0

  CREATE TABLE #db_info
  (
  ParentObject NVARCHAR(128) COLLATE database_default ,
  Object       NVARCHAR(128) COLLATE database_default,
  Field        NVARCHAR(128) COLLATE database_default,
  Value        SQL_VARIANT
  )

  CREATE TABLE #backup_header
  (
  BackupName             NVARCHAR(128) COLLATE database_default NULL,
  BackupDescription      NVARCHAR(256) COLLATE database_default NULL,
  BackupType             INT, 
  ExpirationDate         DATETIME NULL,
  Compressed             INT,
  Position               INT,
  DeviceType             INT,
  UserName               NVARCHAR(128) COLLATE database_default NULL,
  ServerName             NVARCHAR(128) COLLATE database_default,
  DatabaseName           NVARCHAR(128) COLLATE database_default,
  DatabaseVersion        INT,
  DatabaseCreationDate   DATETIME,
  BackupSize             NUMERIC(20,0) NULL,
  FirstLsn               NUMERIC(25,0) NULL,
  LastLsn                NUMERIC(25,0) NULL,
  CheckpointLsn          NUMERIC(25,0) NULL,
  DatabaseBackupLsn      NUMERIC(25,0) NULL,
  BackupStartDate        DATETIME,
  BackupFinishDate       DATETIME,
  SortOrder              INT,
  CodePage               INT,
  UnicodeLocaleId        INT,
  UnicodeComparisonStyle INT,
  CompatibilityLevel     INT,
  SoftwareVendorId       INT,
  SoftwareVersionMajor   INT,
  SoftwareVersionMinor   INT,
  SoftwareVersionBuild   INT,
  MachineName            NVARCHAR(128) COLLATE database_default,
  Flags                  INT NULL,
  BindingId              UNIQUEIDENTIFIER NULL,
  RecoveryForkId         UNIQUEIDENTIFIER NULL,
  Collation              nvarchar(128)    null
  )

  -- Populate temp tables

  SELECT @command = N'RESTORE HEADERONLY FROM DISK = N''' + @backup_file_name + N'''' 
  INSERT INTO #backup_header
  EXECUTE (@command)

  SELECT @command = N'DBCC DBINFO(N''' + @database_name + N''') WITH TABLERESULTS'
  INSERT INTO #db_info
  EXECUTE (@command)

  -- Get the values we need into variables for easy access

  SELECT top 1 @db_recovery_fork_id0 = ISNULL(CONVERT(UNIQUEIDENTIFIER, Value), 0x00)
  FROM #db_info
  WHERE (Object = N'dbi_recoveryForkNameStack')
    AND (Field = N'm_guid')

  SELECT @db_recovery_fork_id1 = ISNULL(CONVERT(UNIQUEIDENTIFIER, Value), 0x00)
  FROM #db_info
  WHERE (Object = N'dbi_recoveryForkNameStack')
    AND (Field = N'm_guid')
  
  SELECT @lsn_slot = CONVERT(INT, Value)
  FROM #db_info
  WHERE (Object = N'dbi_dbbackupLSN')
    AND (Field = N'm_slotId')

  SELECT @lsn_block = CONVERT(INT, Value)
  FROM #db_info
  WHERE (Object = N'dbi_dbbackupLSN')
    AND (Field = N'm_blockOffset')

  SELECT @lsn_file = CONVERT(INT, Value)
  FROM #db_info
  WHERE (Object = N'dbi_dbbackupLSN')
    AND (Field = N'm_fSeqNo')

  SELECT @db_backup_lsn = @lsn_file
  SELECT @db_backup_lsn = @db_backup_lsn * 10000000000
  SELECT @db_backup_lsn = @db_backup_lsn + @lsn_block
  SELECT @db_backup_lsn = @db_backup_lsn * 100000
  SELECT @db_backup_lsn = @db_backup_lsn + @lsn_slot

  SELECT TOP 1 @backup_type = BackupType
  FROM #backup_header

  -- Null fork id's indicate an old system, for which this backup scheme won't work,
  -- so we set a null result to a value different than the db fork_id.

  SELECT TOP 1 @backup_recovery_fork_id = ISNULL(RecoveryForkId, 0x01)
  FROM #backup_header

  SELECT TOP 1 @backup_last_lsn = ISNULL(LastLsn, 0)
  FROM #backup_header

  -- Basic sanity checks

  IF ((SELECT TOP 1 DatabaseName FROM #backup_header) <> @database_name)
  BEGIN
    RAISERROR(14418,-1,-1, @database_name)
    RETURN(1) -- Failure
  END

  IF (@backup_type <> 1)
  BEGIN
    RAISERROR(14419,-1,-1)
    RETURN(1) -- Failure
  END

  -- Do the magic.
  IF (@backup_type = 1) AND
     ((@db_recovery_fork_id0 = @backup_recovery_fork_id) OR
      (@db_recovery_fork_id1 = @backup_recovery_fork_id)) AND
     (@db_backup_lsn <= @backup_last_lsn)
    SELECT @result = 1
  ELSE
    SELECT @result = 0

  RETURN(0) -- Success
END
go

/**************************************************************/
/* sp_change_primary_role                                     */
/**************************************************************/
PRINT 'Creating procedure sp_change_primary_role.'
go
CREATE PROCEDURE sp_change_primary_role 
  @db_name       sysname,
  @backup_log    BIT = 1,
  @terminate     BIT = 0,
  @final_state   SMALLINT = 2, -- 1 = RECOVERY, 2 = NORECOVERY, 3 = STANDBY
  @access_level  SMALLINT = 1  -- 1 = multi user, 2 = dbo, 3 = single user
AS BEGIN
  DECLARE @maint_plan_id UNIQUEIDENTIFIER
  DECLARE @job_id        UNIQUEIDENTIFIER
  DECLARE @rv            INT
  DECLARE @cur_date      DATETIME
  DECLARE @command       NVARCHAR (3200)
  DECLARE @pat_index     INT
  DECLARE @backup_loc    NVARCHAR (500)
  DECLARE @backup_ext    NVARCHAR (10)
  DECLARE @backup_fn     NVARCHAR (1000)
  DECLARE @return_value  INT
  SET NOCOUNT ON

  SELECT @return_value = -1

  -- check final_state is valid
  IF (@final_state NOT IN (1,2,3))
  BEGIN
    RAISERROR (14266,-1,-1, N'@final_state', '1,2,3')
    RETURN (1) -- ERROR
  END

  -- check access_level is valid
  IF (@access_level NOT IN (1,2,3))
  BEGIN
    RAISERROR (14266,-1,-1, N'@access_level', '1,2,3')
    RETURN (1) -- ERROR
  END
  
  IF (@db_name IS NULL)
  BEGIN
    RAISERROR (14043,-1,-1,N'@db_name')
    RETURN (1) -- ERROR 
  END

  IF (@terminate = 1)
  BEGIN
    SELECT @command = N'ALTER DATABASE [' + @db_name + N'] SET SINGLE_USER WITH ROLLBACK IMMEDIATE'
    EXECUTE @rv = sp_executesql @command
    IF (@rv <> 0 OR DATABASEPROPERTY (@db_name, N'IsSingleUser') <> 1) 
    BEGIN
      RAISERROR (14440,-1,-1)
      RETURN (1) -- error
    END
  END

  -- get the maintenance plan
  SELECT @maint_plan_id = maintenance_plan_id from msdb.dbo.log_shipping_databases where database_name = @db_name
  IF (@maint_plan_id IS NULL)
    RETURN (1) -- ERROR
  
  -- get the backup job
  SELECT @job_id = job_id FROM msdb.dbo.sysjobsteps 
  WHERE command like '%-BkUpLog%' AND 
    job_id IN (SELECT job_id FROM msdb.dbo.sysdbmaintplan_jobs WHERE plan_id = @maint_plan_id)  

  IF (@job_id IS NULL)
    RETURN (1) -- ERROR

  -- check that this maint plan is involved in log shipping
  IF NOT EXISTS (SELECT 1 FROM msdb.dbo.log_shipping_databases WHERE maintenance_plan_id = @maint_plan_id)
    RETURN (1) -- ERROR

  -- disable the transaction log dump
  EXEC msdb.dbo.sp_update_job @job_id = @job_id, @enabled = 0

  IF (@backup_log = 1)
  BEGIN
    SELECT @cur_date = GETDATE ()
    -- get the location of the tlog dumps
    SELECT @command = command FROM msdb.dbo.sysjobsteps WHERE job_id = @job_id

    SELECT @pat_index = PATINDEX (N'%-BkUpLog%', @command)
    IF (@pat_index IS NOT NULL AND @pat_index > 0 AND PATINDEX (N'%-UseDefDir%', @command) = 0)
    BEGIN
      -- trim "-"
      SELECT @backup_loc = RIGHT (@command, (LEN (@command) - @pat_index)-7)
      SELECT @backup_loc = LTRIM (@backup_loc)
      SELECT @backup_loc = RTRIM (@backup_loc)

      -- check to see if a location is given
      IF (PATINDEX (N'-%', @backup_loc) = 1)
        SELECT @backup_loc = NULL
      ElSE BEGIN
        -- need to trim off the ""
        SELECT @pat_index = PATINDEX (N'%"%', @backup_loc)
        IF (@pat_index IS NOT NULL AND @pat_index > 0)
        BEGIN
          SELECT @backup_loc = RIGHT (@backup_loc, LEN(@backup_loc) - 1)
          SELECT @pat_index = PATINDEX(N'%"%', @backup_loc)
        END
        ELSE
          SELECT @pat_index = PATINDEX (N'% %', @backup_loc)

        IF (@pat_index IS NOT NULL AND @pat_index > 0)
        BEGIN
          SELECT @backup_loc = LEFT (@backup_loc, @pat_index - 1)
          SELECT @backup_loc = @backup_loc + N'\'
        END
      END
    END
    ELSE
      SELECT @backup_loc = NULL

    -- same thing for file extension
    SELECT @pat_index = PATINDEX (N'%-BkExt%', @command)
    IF (@pat_index IS NOT NULL AND @pat_index > 0)
    BEGIN
      SELECT @backup_ext = RIGHT (@command, (LEN (@command) - @pat_index)-5)
      SELECT @backup_ext = LTRIM (@backup_ext)
      SELECT @backup_ext = RTRIM (@backup_ext)
      SELECT @pat_index = PATINDEX (N'%"%', @backup_ext)
      -- need to trim off the ""
      IF (@pat_index IS NOT NULL AND @pat_index > 0)
      BEGIN
        SELECT @backup_ext = RIGHT (@backup_ext, LEN(@backup_ext) - 1)
        SELECT @pat_index = PATINDEX(N'%"%', @backup_ext)
      END
      ELSE
        SELECT @pat_index = PATINDEX (N'% %', @backup_ext)
      IF (@pat_index IS NOT NULL AND @pat_index > 0)
      BEGIN
        SELECT @backup_ext = LEFT (@backup_ext, @pat_index - 1)
      END
    END
    ELSE BEGIN 
      SELECT @backup_ext = N'TRN'
    END

    -- now do the backup
    SELECT @cur_date = DATEADD (mi,1,@cur_date)
    SELECT @backup_fn = 
      ISNULL (@backup_loc, N'') + 
      @db_name + 
      N'_tlog_' + 
      CONVERT (NVARCHAR, @cur_date, 112) +
      LEFT (CONVERT (NVARCHAR, @cur_date, 8), 2) +
      LEFT (RIGHT (CONVERT (NVARCHAR, @cur_date, 8), 5), 2) +
      N'.' +
      @backup_ext

    IF (@final_state = 2)
    BEGIN
      BACKUP LOG @db_name TO DISK = @backup_fn WITH NORECOVERY
      IF (@@error <> 0) GOTO finish
    END
    ELSE IF (@final_state = 3)
    BEGIN
      DECLARE @undo_file NVARCHAR (500)
      SELECT @undo_file = ISNULL (@backup_loc, N'') + @db_name + N'.tuf'
      BACKUP LOG @db_name TO DISK = @backup_fn WITH STANDBY = @undo_file
      IF (@@error <> 0) GOTO finish
    END
    ELSE BEGIN
      BACKUP LOG @db_name TO DISK = @backup_fn
      IF (@@error <> 0) GOTO finish
    END
  END

  EXECUTE msdb.dbo.sp_delete_log_shipping_database @db_name = @db_name
 
  SELECT @return_value = 0

  finish:
  IF (@final_state <> 2)
  BEGIN
    -- put the db in it's final state -- 1 = multi user, 2 = dbo, 3 = single user
    SELECT @command = N'ALTER DATABASE [' + @db_name + N'] SET '
    IF (@access_level = 1) SELECT @command = @command + 'MULTI_USER'
    IF (@access_level = 2) SELECT @command = @command + 'RESTRICTED_USER'
    IF (@access_level = 3) SELECT @command = @command + 'SINGLE_USER'

    EXECUTE sp_executesql @command
  END

  RETURN @return_value
END
go

/**************************************************************/
/* sp_change_secondary_role                                   */
/**************************************************************/
PRINT 'Creating procedure sp_change_secondary_role.'
go
CREATE PROCEDURE sp_change_secondary_role
  @db_name          sysname,
  @do_load          BIT = 1,
  @force_load       BIT = 1,
  @final_state      SMALLINT = 1, -- 1 = RECOVERY, 2 = NORECOVERY, 3 = STANDBY
  @access_level     SMALLINT = 1, -- 1 = multi user, 2 = dbo, 3 = single user
  @terminate        BIT = 1,
  @keep_replication BIT = 0,
  @stopat           DATETIME = NULL
AS BEGIN
  SET NOCOUNT ON
  DECLARE @job_id		     UNIQUEIDENTIFIER
  DECLARE @plan_id		   UNIQUEIDENTIFIER
  DECLARE @maint_plan_id UNIQUEIDENTIFIER
  DECLARE @command		   NVARCHAR (3200)
  DECLARE @backup_job_id UNIQUEIDENTIFIER
  DECLARE @rv            INT
  DECLARE @return_value  INT
  DECLARE @pat_index     INT

  -- check final_state is valid
  IF (@final_state NOT IN (1,2,3))
  BEGIN
    RAISERROR (14266,-1,-1, N'@final_state', '1,2,3')
    RETURN (1) -- ERROR
  END

  -- chaeck access_level is valid
  IF (@access_level NOT IN (1,2,3))
  BEGIN
    RAISERROR (14266,-1,-1, N'@access_level', '1,2,3')
    RETURN (1) -- ERROR
  END

  IF (@db_name IS NULL)
  BEGIN
    RAISERROR (14043,-1,-1,N'@db_name')
    RETURN (1) -- ERROR 
  END

  SELECT @return_value = -1

  IF (@terminate = 1)
  BEGIN
    SELECT @command = N'ALTER DATABASE [' + @db_name + N'] SET SINGLE_USER WITH ROLLBACK IMMEDIATE'
    EXECUTE @rv = sp_executesql @command
    IF (@rv <> 0 OR DATABASEPROPERTY (@db_name, N'IsSingleUser') <> 1) 
    BEGIN
      RAISERROR (14440,-1,-1)
      RETURN (1) -- error
    END
  END

  SELECT @plan_id = plan_id FROM msdb.dbo.log_shipping_plan_databases WHERE destination_database = @db_name
  IF (@plan_id IS NULL)
  BEGIN
    RAISERROR (14425,-1,-1, @db_name)
    GOTO finish
  END

  SELECT @backup_job_id = backup_job_id, @maint_plan_id = maintenance_plan_id FROM msdb.dbo.log_shipping_plans WHERE plan_id = @plan_id


  -- copy any extra files
  IF (@do_load > 0)
  BEGIN
    SELECT @job_id =  copy_job_id FROM msdb.dbo.log_shipping_plans WHERE plan_id = @plan_id
    SELECT @command = command FROM sysjobsteps WHERE job_id = @job_id
    SELECT @pat_index = PATINDEX (N'%''%', @command)
    IF (@pat_index IS NULL)
    BEGIN
      GOTO finish
    END
    
    SELECT @command = RIGHT (@command, LEN (@command) - @pat_index)
    SELECT @command = LEFT  (@command, LEN (@command) - 1)
    EXECUTE @rv = master.dbo.xp_sqlmaint @command
    IF (@rv <> 0)
    BEGIN
      GOTO finish
    END
  END

  -- disable the copy job as we're now dumping tlogs to this location
  EXECUTE msdb.dbo.sp_update_job @job_id = @job_id, @enabled = 0

  -- restore tlogs
  IF (@do_load > 0)
  BEGIN
    SELECT @job_id = load_job_id FROM msdb.dbo.log_shipping_plans WHERE plan_id = @plan_id
    SELECT @command = command FROM sysjobsteps WHERE job_id = @job_id
    SELECT @pat_index = PATINDEX (N'%''%', @command)
    IF (@pat_index IS NULL)
    BEGIN
      GOTO finish
    END
    
    SELECT @command = RIGHT (@command, LEN (@command) - @pat_index)
    -- strip off final '
    DECLARE @len INT
    SELECT @len = LEN (@command)
    SELECT @command = LEFT (@command, @len-1)
    IF (@force_load > 0)
    BEGIN
      SELECT @command = @command + N' -ForceLoad'
    END
    IF (@keep_replication > 0)
    BEGIN
      SELECT @command = @command + N' -KeepRepl'
    END
    IF (@stopat IS NOT NULL)
    BEGIN
      SELECT @command = @command + N' -StopAt "' + CONVERT (NVARCHAR, @stopat, 20) + '"'
    END
    EXECUTE @rv = master.dbo.xp_sqlmaint @command
    IF (@rv <> 0)
    BEGIN
      GOTO finish
    END
  END
  
  -- bring the database online
  IF (@final_state = 1)
    RESTORE DATABASE @db_name WITH RECOVERY
  ELSE IF (@final_state = 2) 
    RESTORE DATABASE @db_name WITH NORECOVERY
  ELSE IF (@final_state = 3)
  BEGIN
    SELECT @command = (SELECT destination_dir FROM msdb.dbo.log_shipping_plans WHERE plan_id = @plan_id) + N'\' + @db_name + N'.TUF'
    RESTORE DATABASE @db_name WITH STANDBY = @command
  END

  IF (@@error <> 0) GOTO finish

  -- remove the database from the logshipping plan
  EXECUTE msdb.dbo.sp_delete_log_shipping_plan_database @destination_database = @db_name

  -- add the database to log_shipping_databases
  EXECUTE msdb.dbo.sp_add_log_shipping_database @db_name = @db_name, @maintenance_plan_id = @maint_plan_id

  -- bring the job online
  IF (@backup_job_id IS NOT NULL)
    EXECUTE sp_update_job @job_id = @backup_job_id, @enabled = 1

  -- if there are no more databases in this plan, delete it
  IF (NOT EXISTS (SELECT * FROM msdb..log_shipping_plan_databases WHERE plan_id = @plan_id))
  BEGIN
    EXECUTE msdb.dbo.sp_delete_log_shipping_plan @plan_id = @plan_id
  END
  ELSE BEGIN
    -- delete extra maint plan information
    UPDATE msdb.dbo.log_shipping_plans 
      SET maintenance_plan_id = NULL, backup_job_id = NULL, share_name = NULL 
      WHERE @plan_id = @plan_id
  END

  SELECT @return_value = 0

finish:
  IF (@final_state <> 2)
  BEGIN
    -- put the db in it's final state -- 1 = multi user, 2 = dbo, 3 = single user
    SELECT @command = N'ALTER DATABASE [' + @db_name + N'] SET '
    IF (@access_level = 1) SELECT @command = @command + 'MULTI_USER'
    IF (@access_level = 2) SELECT @command = @command + 'RESTRICTED_USER'
    IF (@access_level = 3) SELECT @command = @command + 'SINGLE_USER'

    EXECUTE sp_executesql @command
  END

  RETURN @return_value
END
go

/**************************************************************/
/* sp_remove_log_shipping_monitor                             */
/**************************************************************/
PRINT 'Creating procedure sp_remove_log_shipping_monitor.'
go
CREATE PROCEDURE sp_remove_log_shipping_monitor AS
BEGIN
  SET NOCOUNT ON
  -- do not delete the monitor if there this is a primary or secondary server that is still log shipping

  -- check that there are no rows in log_shipping_plans
  IF (EXISTS (SELECT * FROM msdb.dbo.log_shipping_plans))
  BEGIN
    RAISERROR (14428,-1,-1)
    RETURN (1) -- error
  END

  -- check that there are no rows in log_shipping_databases
  IF (EXISTS (SELECT * FROM msdb.dbo.log_shipping_databases))
  BEGIN
    RAISERROR (14428,-1,-1)
    RETURN (1) -- error
  END

  DELETE FROM msdb.dbo.log_shipping_monitor
  RETURN (0) -- success
END
go

/**************************************************************/
/* sp_define_log_shipping_monitor                             */
/**************************************************************/
PRINT 'Creating procedure sp_define_log_shipping_monitor.'
go
CREATE PROCEDURE sp_define_log_shipping_monitor
  @monitor_name    sysname,
  @logon_type      INT,
  @user_name       NVARCHAR(63)	= NULL,
  @password        NVARCHAR(63)	= NULL,
  @delete_existing BIT		= 0
AS BEGIN
  DECLARE @logon_data   VARBINARY(256)

  SET NOCOUNT ON

  SELECT @logon_data = NULL

-- check for an existing monitor. There can be only one
  IF EXISTS (SELECT * FROM msdb.dbo.log_shipping_monitor)
  BEGIN
    IF EXISTS (SELECT * FROM msdb.dbo.log_shipping_monitor WHERE monitor_server_name = @monitor_name)
      SELECT @delete_existing = 1
    IF @delete_existing = 0
    BEGIN
      RAISERROR (14426,-1,-1)
      RETURN (1)
    END
    SET ROWCOUNT 1
    DELETE FROM msdb.dbo.log_shipping_monitor
    SET ROWCOUNT 0
  END

  IF @logon_type NOT BETWEEN 1 AND 2
  BEGIN
    RAISERROR (14266,-1,-1, N'@logon_type', N'1,2')
    RETURN (1)
  END

  IF @logon_type = 2
  BEGIN
    IF @user_name IS NULL
    BEGIN
      RAISERROR (14415,-1,-1)
      RETURN (1)
    END
    IF (@password IS NOT NULL)
	BEGIN
	  EXECUTE master..xp_repl_encrypt @password OUTPUT
      SELECT @logon_data = convert (VARBINARY(256), @password)
	END
  END
  INSERT INTO log_shipping_monitor VALUES (@monitor_name, @logon_type, @logon_data)
END
go

/**************************************************************/
/* marked stored procedures as system shipped objects         */
/**************************************************************/
EXEC dbo.sp_MS_marksystemobject sp_update_log_shipping_plan
EXEC dbo.sp_MS_marksystemobject sp_add_log_shipping_plan
EXEC dbo.sp_MS_marksystemobject sp_delete_log_shipping_plan
EXEC dbo.sp_MS_marksystemobject sp_add_log_shipping_plan_database
EXEC dbo.sp_MS_marksystemobject sp_delete_log_shipping_plan_database
EXEC dbo.sp_MS_marksystemobject sp_add_log_shipping_database
EXEC dbo.sp_MS_marksystemobject sp_delete_log_shipping_database
EXEC dbo.sp_MS_marksystemobject sp_verify_lsp_identifiers
EXEC dbo.sp_MS_marksystemobject sp_update_log_shipping_plan_database
EXEC dbo.sp_MS_marksystemobject sp_remove_log_shipping_monitor
EXEC dbo.sp_MS_marksystemobject sp_can_tlog_be_applied
EXEC dbo.sp_MS_marksystemobject sp_change_primary_role
EXEC dbo.sp_MS_marksystemobject sp_change_secondary_role
EXEC dbo.sp_MS_marksystemobject sp_define_log_shipping_monitor
go

PRINT '--------------------------------'
PRINT 'Finished execution of INSTLS.SQL'
PRINT '--------------------------------'
go
