-- ********************************************************************
-- WEB.SQL 
--
-- Creates mswebtasks table and the following stored procedures
--   sp_makewebtask
--   sp_dropwebtask
--   sp_runwebtask
--	 sp_cleanwebtask (SQLAgent support)
--	 sp_enumcodepages
--	 sp_readwebtask (Web Assistant UI support)
--	 sp_convertwebtasks (6.5 to 7.0 web task upgrade)
--
-- Copyright Microsoft, Inc. 1996 - 2000.                              
-- All Rights Reserved.                                               
--                                                                    
-- ********************************************************************


USE msdb
go

EXEC sp_MS_upd_sysobj_category 1
go

--====================================================================================

EXEC sp_configure 'allow updates', 1
RECONFIGURE WITH OVERRIDE
go

-- Add mswebtasks table if not there
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = N'mswebtasks')
BEGIN
    CREATE TABLE mswebtasks 
	(
	procname	nvarchar(128)	NOT NULL,	-- Name of the procedure
	outputfile	nvarchar(255)	NOT NULL,	-- Physical name of output file
	taskstat	bit				NOT NULL,	-- TRUE if task scheduled, FALSE if not
	wparams		image			NULL,		-- xp_runwebtask parameters
	trigflags	smallint		NULL,		-- trigger status flags
	taskid		int				NULL		-- task id returned by sp_addtask
    )
END
go

IF NOT EXISTS (SELECT * FROM sysindexes WHERE name = N'web_idxproc'
       AND id = object_id(N'mswebtasks'))
BEGIN
    CREATE UNIQUE INDEX web_idxproc ON mswebtasks(procname)
END
go

-- Add sp_insmswebtask if not there
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.sp_insmswebtask') AND type = 'P')
   DROP PROCEDURE dbo.sp_insmswebtask
go

CREATE PROCEDURE sp_insmswebtask
-- This procedure is for internal use by Web Assistant
    @procname		nvarchar(128),
    @outputfile		nvarchar(255),
    @taskstat		bit,
    @wparams		image,
    @trigflags		smallint,
    @taskid			int
AS
    INSERT INTO  dbo.mswebtasks(procname, outputfile, taskstat, wparams, trigflags, taskid)
	    VALUES(@procname, @outputfile, @taskstat, @wparams, @trigflags, @taskid)
go

-- Add sp_updmswebtask if not there
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.sp_updmswebtask') AND type = 'P')
   DROP PROCEDURE dbo.sp_updmswebtask
go

CREATE PROCEDURE sp_updmswebtask
-- This procedure is for internal use by Web Assistant
    @procname		nvarchar(128),
    @wparams		image
AS
    UPDATE dbo.mswebtasks
	SET wparams = @wparams
	WHERE procname = @procname

go

-- Grant privileges on mswebtasks
GRANT SELECT ON mswebtasks TO PUBLIC
go
GRANT INSERT ON mswebtasks TO PUBLIC
go
GRANT DELETE ON mswebtasks TO PUBLIC
go
GRANT UPDATE ON mswebtasks TO PUBLIC
go
GRANT EXECUTE ON sp_insmswebtask TO PUBLIC
go
GRANT EXECUTE ON sp_updmswebtask TO PUBLIC
go

EXEC sp_MS_upd_sysobj_category 2
go

--====================================================================================
-- Update the master database
USE master
go

-- Drop the associated XPs
IF EXISTS (SELECT * FROM sysobjects
			WHERE type = 'X'
			AND name = N'xp_makewebtask')
	EXEC sp_dropextendedproc N'xp_makewebtask'
go
IF EXISTS (SELECT * FROM sysobjects
			WHERE type = 'X'
			AND name = N'xp_dropwebtask')
	EXEC sp_dropextendedproc N'xp_dropwebtask'
go
IF EXISTS (SELECT * FROM sysobjects
			WHERE type = 'X'
			AND name = N'xp_runwebtask')
	EXEC sp_dropextendedproc N'xp_runwebtask'
go
IF EXISTS (SELECT * FROM sysobjects
			WHERE type = 'X'
			AND name = N'xp_cleanupwebtask')
	EXEC sp_dropextendedproc N'xp_cleanupwebtask'
go
IF EXISTS (SELECT * FROM sysobjects
			WHERE type = 'X'
			AND name = N'xp_enumcodepages')
	EXEC sp_dropextendedproc N'xp_enumcodepages'
go
IF EXISTS (SELECT * FROM sysobjects
			WHERE type = 'X'
			AND name = N'xp_convertwebtask')
	EXEC sp_dropextendedproc N'xp_convertwebtask'
go
-- xp for reading web tasks for the Web Wizard.
IF EXISTS(SELECT * FROM sysobjects
		WHERE type = 'X'
			AND name = N'xp_readwebtask')
	EXEC sp_dropextendedproc N'xp_readwebtask'
go

-- Drop the stored procedures if they exist
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.sp_makewebtask') AND type = 'P')
   DROP PROCEDURE dbo.sp_makewebtask
go
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.sp_dropwebtask') AND type = 'P')
   DROP PROCEDURE dbo.sp_dropwebtask
go
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.sp_runwebtask') AND type = 'P')
   DROP PROCEDURE dbo.sp_runwebtask
go
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.sp_cleanupwebtask') AND type = 'P')
   DROP PROCEDURE dbo.sp_cleanupwebtask
go
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.sp_enumcodepages') AND type = 'P')
   DROP PROCEDURE dbo.sp_enumcodepages
go
IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.sp_convertwebtasks') AND type = 'P')
   DROP PROCEDURE dbo.sp_convertwebtasks
go

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'dbo.sp_readwebtask') AND type = 'P')
   DROP PROCEDURE dbo.sp_readwebtask
go

EXEC sp_MS_upd_sysobj_category 1
go

-- Add extended stored procedures for Web Server support.
sp_addextendedproc N'xp_makewebtask', 'xpweb70.dll'
go
sp_addextendedproc N'xp_dropwebtask', 'xpweb70.dll'
go
sp_addextendedproc N'xp_runwebtask', 'xpweb70.dll'
go
sp_addextendedproc N'xp_cleanupwebtask', 'xpweb70.dll'
go
sp_addextendedproc N'xp_enumcodepages', 'xpweb70.dll'
go
sp_addextendedproc N'xp_convertwebtask', 'xpweb70.dll'
go
sp_addextendedproc N'xp_readwebtask', 'xpweb70.dll'
go


--====================================================================================
-- Add extended stored procedures for Web Server support.
--
-- sp_makewebtask: Creates and defines the Web Page Task

CREATE PROCEDURE sp_makewebtask
@outputfile		nvarchar(255),
@query			ntext,
@fixedfont		tinyint = 1,				-- 0/1 
@bold			tinyint = 0,				-- 0/1 
@italic			tinyint = 0,				-- 0/1 
@colheaders		tinyint = 1,				-- 0/1 
@lastupdated	tinyint = 1,				-- 0/1 
@HTMLheader		tinyint = 1,				-- 1-6 
@username		nvarchar(128) = NULL,
@dbname			nvarchar(128) = NULL,
@templatefile	nvarchar(255) = NULL,
@webpagetitle	nvarchar(255) = NULL,
@resultstitle	nvarchar(255) = NULL,
@URL			nvarchar(255) = NULL,
@reftext		nvarchar(255) = NULL,
@table_urls		tinyint = 0,				-- 0/1; 1=use table of URLs 
@url_query		nvarchar(255) = NULL,   
@whentype		tinyint = 1,				-- 1=now, 2=later, 3=every xday 
											-- 4=every n units of time 
@targetdate		int = 0,					-- yyyymmdd as int
@targettime		int = 0,					-- hhnnss as int
@dayflags		tinyint = 1,				-- powers of 2 for days of week 
@numunits		tinyint = 1,
@unittype		tinyint = 1,				-- 1=hours, 2=days, 3=weeks, 4=minutes
@procname		nvarchar(128) = NULL,		-- name to use when making the
											-- task and the wrapper/condenser
											-- stored procs
@maketask		int = 2,					-- 0=create unencrypted sproc, no task
											-- 1=encrypted sproc and task
											-- 2=unencrypted sproc and task
@rowcnt			int = 0,					-- max no of rows to display
@tabborder		tinyint = 1,				-- borders around the results table
@singlerow		tinyint = 0,				-- Single row per page
@blobfmt		ntext = NULL,				-- Formatting for text and image fields
@nrowsperpage	int = 0,					-- Results displayed in multiple pages of n rows per page
@datachg		ntext = NULL,				-- Table and column names for a trigger
@charset		nvarchar(25) = N'utf-8',	-- Universal character set is the default
@codepage		int = 65001					-- utf-8 (universal) code page is the default

AS
BEGIN

   DECLARE @suid smallint
   DECLARE @yearchar nvarchar(4)
   DECLARE @monthchar nvarchar(2)
   DECLARE @daychar nvarchar(2)
   DECLARE @hourchar nvarchar(2)
   DECLARE @minchar nvarchar(2)
   DECLARE @secchar nvarchar(2)
   DECLARE @currdate datetime
   DECLARE  @retval int


-- Check for valid @dbname if supplied
   IF (@dbname is NOT NULL)
      IF (NOT(exists(SELECT * FROM master..sysdatabases WHERE name = @dbname)))
      BEGIN
		 RAISERROR(16854,11,1)
         RETURN (9)
      END

-- Make sure that it's the SA executing this.
   IF ( NOT ( is_srvrolemember('sysadmin') = 1 ) )
   BEGIN
      RAISERROR( 15003, -1, -1, 'sysadmin' )
      RETURN(1)	
   END

-- IF not supplied, determine the user executing this procedure
   SET @username = suser_sname()

   IF ( (charindex ('\',@username) > 0) OR (@username is NULL) OR (@username = 'sa') )
   BEGIN
		SELECT @username = N'dbo'
   END

-- If not supplied, determine the database currently active
   IF (@dbname is NULL)
   BEGIN
	  SELECT @dbname = d.name FROM
	   master..sysdatabases d, master..sysprocesses p
	   WHERE d.dbid = p.dbid AND spid = @@spid

   END

-- Generate @procname if not supplied
   IF (@procname is NULL)
      BEGIN

         SET @currdate = getdate()

		 SET @yearchar = convert(nvarchar(4),year(@currdate))
         SET @monthchar = right('0'+ rtrim(convert(nvarchar(2),month(@currdate))),2)
         SET @daychar = right('0'+rtrim(convert(nvarchar(2),day(@currdate))),2)
         SET @hourchar = right('0'+rtrim(convert(nvarchar(2),datepart(hh,@currdate))),2)
         SET @minchar = right('0'+rtrim(convert(nvarchar(2),datepart(mi,@currdate))),2)
         SET @secchar = right('0'+rtrim(convert(nvarchar(2),datepart(ss,@currdate))),2)

		 -- Get default procname if not supplied
         SET @procname = N'web_'+convert(nchar(14),@yearchar+@monthchar+@daychar+@hourchar+@minchar+@secchar)+convert(nvarchar(20),@@spid)+right(rtrim(convert( VARCHAR(25),RAND() )),4)

      END

   SET @retval = 0

-- Create the Web task
   EXECUTE @retval = master..xp_makewebtask  @outputfile, @query, @username, @procname, @dbname,
	    @fixedfont, @bold, @italic, @colheaders, @lastupdated, @HTMLheader,
	    @templatefile, @webpagetitle, @resultstitle, @URL, @reftext,
	    @table_urls, @url_query, @whentype, @targetdate, @targettime,
	    @dayflags, @numunits, @unittype, @rowcnt, @maketask, @tabborder,
	    @singlerow, @blobfmt, @nrowsperpage, @datachg, @charset, @codepage
    
	IF (@retval <> 0)
	BEGIN
	    SET @procname = 'xp_makewebtask'
	    RAISERROR(@retval, 11, 1, @procname)
	END

   RETURN @retval

END
go

--====================================================================================
-- sp_dropwebtask: Drops a previously created Web Page Task

CREATE PROCEDURE sp_dropwebtask
	    @procname nvarchar(128) = NULL,
	    @outputfile	nvarchar(255) = NULL
AS
BEGIN
    DECLARE	@retval int
	SET @retval = 0

    -- At least one of the parameters have to be NOT NULL
    IF ( (@procname is NULL) AND (@outputfile is NULL) )
	BEGIN
	    RAISERROR(16801,11,1)
	    RETURN(1)
	END
    
	EXEC @retval = master..xp_dropwebtask @procname, @outputfile
    
	IF (@retval <> 0)
	BEGIN
	    SET @procname = 'sp_dropwebtask'
	    RAISERROR(@retval,11,1, @procname)
	END

    RETURN @retval
END
go

--====================================================================================
-- sp_runwebtask: Runs a previously created Web Page Task and creates the
--		    web page

CREATE PROCEDURE sp_runwebtask
	    @procname nvarchar(128) = NULL,
	    @outputfile	nvarchar(255) = NULL
AS
BEGIN
    DECLARE	@retval int
	SET @retval = 0

    -- At least one of the parameters have to be NOT NULL
    IF ( (@procname is NULL) AND (@outputfile is NULL) )
	BEGIN
	    RAISERROR(16803,11,1)
	    RETURN(1)
	END
    
	EXEC @retval = master..xp_runwebtask @procname, @outputfile
    
	IF (@retval <> 0)
	BEGIN
	    SET @procname = 'sp_runwebtask'
	    RAISERROR(@retval,11,1, @procname)
	END

    RETURN @retval
END
go

--====================================================================================
-- sp_cleanupwebtask: Internal stored procedure called by Enterprise Manager
--		    to clean up web
--		    task entries after their system task entry has been
--		    deleted. This procedure will return success
--		    if there is no web task entry associated with the given
--		    task id.

CREATE PROCEDURE sp_cleanupwebtask
	    @taskid  int = 0
AS
BEGIN
    DECLARE	@procname nvarchar(128)
    DECLARE	@retval int
	SET @retval = 0

    IF (@taskid = 0)
	RETURN(1)
    SELECT @procname = (SELECT procname FROM msdb..mswebtasks WHERE taskid = @taskid)

	--  Return if there is no such task
    IF (@procname is NULL)
	RETURN(1)

    EXEC @retval = master..xp_cleanupwebtask @procname
    RETURN @retval
END
go

-- sp_enumcodepages: Get a list of supported code pages
--
CREATE PROCEDURE sp_enumcodepages
AS
BEGIN
	DECLARE @retval int
    DECLARE @procname nvarchar(128)

	SET @retval = 0

	EXEC @retval = master..xp_enumcodepages

    IF (@retval <> 0)
	BEGIN
	    SET @procname = 'sp_enumcodepages'
	    RAISERROR(@retval,11,1, @procname)
	END

    RETURN @retval
END
go

--====================================================================================
-- sp_convertwebtasks: Converts 6.5 webtasks to 7.0 format
--
CREATE PROCEDURE sp_convertwebtasks
AS
BEGIN
    DECLARE	@retval int
    DECLARE	@procname nvarchar(128)
    DECLARE	@thisproc nvarchar(128)
	DECLARE @wpw_65 varbinary(5)
	DECLARE @TotalConverted	int
	DECLARE	@TotalFailed	int


	-- Are there any webtasks to convert?
	IF ((SELECT count(*) FROM msdb..mswebtasks) = 0)
		goto DONE

	SET @TotalConverted = 0
	SET @TotalFailed = 0

	-- Initialize variables
	SET	@thisproc = 'sp_convertwebtasks'
	SET	@retval = 0
	SET	@wpw_65 = 0x00

	-- Loop through all tasks and convert to 7.0 format
	DECLARE webtaskCur cursor FOR 
		SELECT procname FROM msdb..mswebtasks
		WHERE substring(wparams,1,2) = @wpw_65		-- version 6.5

	OPEN webtaskCur
	FETCH webtaskCur INTO @procname	
    
	WHILE (@@fetch_status = 0)
	BEGIN
		EXEC @retval = master..xp_convertwebtask @procname
		IF (@retval <> 0)
		BEGIN
			
			RAISERROR('%s: Failed to convert webtask from 6.5 to 7.0 format.  You need to use sp_makewebtask to recreate the task',16,1,@thisproc, @procname) WITH LOG
			SET @TotalFailed = @TotalFailed + 1

		END
		ELSE
		BEGIN
			
			-- Increment successfully converted task count
			SET @TotalConverted = @TotalConverted + 1
			
			-- Tag webtasks in sysjobs.  Web Assistant tasks are category 4.		
			UPDATE msdb.dbo.sysjobs
			SET category_id = 4
			WHERE name = @procname

		END

		FETCH webtaskCur INTO @procname
	END

	CLOSE webtaskCur
	DEALLOCATE webtaskCur

	RAISERROR('%s: %d web tasks converted successfully.  %d webtasks failed to convert.',0,1,@thisproc, @TotalConverted,@TotalFailed) WITH LOG

-- Done with conversion

DONE:
    RETURN @retval

END
go
--====================================================================================
-- sp_readwebtask: retreive web task parameters
--
CREATE PROCEDURE sp_readwebtask
	    @procname nvarchar(128) = NULL
AS
BEGIN
    DECLARE @retval int
	SET @retval = 0

    -- If the procedure name is NULL, Display a list of web tasks
    IF NOT EXISTS (SELECT * FROM msdb..mswebtasks WHERE procname = @procname)
	BEGIN
	    SET @retval = 16815
		RAISERROR(@retval,11,1,@procname)
	    RETURN(@retval)
	END
    
	-- Execute xp_readwebtask given the procedure name
	EXEC @retval = master..xp_readwebtask @procname
    
	IF (@retval <> 0)
	BEGIN
	    SELECT @procname = 'sp_readwebtask'
	    RAISERROR(@retval,11,1, @procname)
	END

    RETURN @retval
END
go


--====================================================================================
GRANT EXECUTE ON sp_makewebtask TO PUBLIC
go
GRANT EXECUTE ON sp_dropwebtask TO PUBLIC
go
GRANT EXECUTE ON sp_runwebtask TO PUBLIC
go
GRANT EXECUTE ON sp_cleanupwebtask TO PUBLIC
go
GRANT EXECUTE ON sp_enumcodepages TO PUBLIC
go
GRANT EXECUTE ON sp_convertwebtasks TO PUBLIC
go
GRANT EXECUTE ON sp_readwebtask TO PUBLIC
go

-- Reset system object category
EXEC sp_MS_upd_sysobj_category 2
go

-- disallow and reconfigure
EXEC sp_configure 'allow updates', 0
RECONFIGURE WITH OVERRIDE
go
