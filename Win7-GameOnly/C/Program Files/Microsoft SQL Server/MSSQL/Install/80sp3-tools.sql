/*------------------------------------------------------------------------------

80SP3-TOOLS.SQL

THIS SCRIPT TAKES THE TOOLS STORED PROCS FROM 8.0, SP1, AND SP2 TO SP3.

Changes in this file reflects changes in the following files:
	INSTMSDB.SQL
	SQLDMO.SQL
	XPSTAR.SQL
	SQLTRACE.SQL
	WEB.SQL

Notes:
80SP1-TOOLS.SQL AND 80SP2-TOOLS.SQL WILL *NOT* RUN WHEN APPLYING SP3
------------------------------------------------------------------------------*/

PRINT N''
PRINT N'Updating database objects, executing 80SP3-TOOLS.SQL'
PRINT N'Started at ' + convert(nvarchar(25), getdate())
PRINT N''
go

--------------------------------------------------------------------------------
-- VERIFY Server is started in single-user-mode (catalog-updates enabled), 
-- and start marking of system-objects.
--------------------------------------------------------------------------------
use master
go

exec dbo.sp_configure 'allow updates',1
go

reconfigure with override
go

exec sp_MS_upd_sysobj_category 1
go



--------------------------------------------------------------------------------
-- BEGIN OF CHANGE SECTION:
-- Add change sprocs between here and the END OF CHANGE SECTION comment.
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- SQLDMO stored procedures added after release into sqldmo.sql file
--
-- sp_MSobjectprivs
--------------------------------------------------------------------------------

/**************************************************************/
/* sp_MSobjectprivs                                           */
/**************************************************************/
if exists (select * from master..sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MSobjectprivs')
    drop procedure dbo.sp_MSobjectprivs
go

print N''
print N'Creating procedure sp_MSobjectprivs...'
go

create proc dbo.sp_MSobjectprivs
    @objname nvarchar(776) = null,
    @mode nvarchar(10) = N'object',	
    @objid int = null,				
    @srvpriv int = null,			
    @prottype int = null,			
    @grantee nvarchar(258) = null,		
    @flags int = 0,
    @rollup int = 0
as
	create table #objs(id  int NOT NULL)

	/* Temp table will hold output for final select */
	create table #output (
		action      int  NOT NULL,
		colid       int  NULL,
		uid         int  NOT NULL,
		protecttype int  NOT NULL,
		id          int  NOT NULL,
		grantor     int
	)

	create table #tmp(
		action   int   NOT NULL,
		uid      int   NOT NULL,
		protecttype int  NOT NULL,
	)

   /* mode    : 'object', 'user' or 'column'*/
   /*
    * Note:  This was expanded for 6.5 due to changes in sysprotects.columns usage, affecting
    * CPermission::ListPrivilegeColumns.  The following additional parameters are for this.
    */
   /* objid   : ID of the object we're querying */
   /* srvpriv : privilege that we're querying for (e.g. select) */
   /* prottype: Protect type, e.g. GRANT/REVOKE */
   /* grantee : Grantee name. */

   /*** @flags added for DaVinci uses.  If the bit isn't set, use 6.5 ***/
   /*** sp_MSobjectprivs '%s'                                         ***/

   /* 8.0: mode 'column', and grantee != null, we want user column level permissions for CTable/CView::ListUserColumnPermissions */
   /*      @rollup added to indicate special rollup result set for column level permission, set to 1 to roll up */

	/* @flags is for daVinci */
	if (@flags is null)
		select @flags = 0

	/* If @objid is not null, this is for the new query for perm cols. */
	if (@objid is not null) begin
		select u.name, o.name, a = col_name(p.id, a.number), a.low, a.high, a.number
			from master.dbo.spt_values a, dbo.sysprotects p, dbo.sysobjects o, dbo.sysusers u
			where p.id = @objid and p.action = @srvpriv and p.protecttype = @prottype
			and p.uid = user_id(@grantee)
			and p.columns != 0x01 and o.id = p.id and u.uid = o.uid
				and convert(tinyint, substring(isnull(p.columns, 0x01), a.low, 1)) &
					-- 6.5 changed so that the bit 0 position is an "invert the bits" indicator:
					--		when 0, behaviour is the same as in prior versions, and other bits
					--			indicate columns with the specified privilege
					--		when 1, the other bits are indicate columns lacking the specified privilege
					a.high <> (case when (substring(isnull(p.columns, 0x00), 1, 1) & 1 = 0) then 0 else a.high end)
					and col_name(p.id, a.number) is not null
					and a.type = N'P' and a.number <= (select count(*) from dbo.syscolumns where id = @objid) order by a
		return 0
	end

	set nocount on

	/*
	 * To get around a 4.21 subquery bug where returning count(*) of 0 (for proc cols)
	 * causes the result set to return no rows, we need two passes; one to get the
	 * objects, and another to explicitly use a value (@cols) instead of a subquery.
	 */
	declare @id int, @uid int, @cols int
	select @id = null, @uid = null
	if (@mode like N'us%') begin
	   select @uid = user_id(@objname)
   end else if (@mode like N'col%') and (@objname is null) and (@grantee is not null) begin
      /* 8.0, special path to get column level permissions from all objects on the specified user */
      select @uid = user_id(@grantee)
	end else begin
      select @id = object_id(@objname)
   end
	if (@id is null and @uid is null) begin
		RAISERROR (15001, -1, -1, @objname)
		return 1
	end

	/* Get a temp list of objects we're interested in.  Do not include repl_* users. */
   /* This is the original code */
   insert #objs select distinct p.id from dbo.sysprotects p
	   where (@id is null or p.id = @id)
  		and (@uid is null or p.uid = @uid)
   	and p.action in (193, 195, 196, 197, 224, 26) and p.uid not in (16382, 16383)

	/* Use a "fake cursor" by deleting successive id's from #objs, as this must run on 4.21 */
	select @id = min(id) from #objs
	while (@id is not null) begin
		select @cols = count(*) from dbo.syscolumns c where c.id = @id
      /* sysprotects.columns is for SELECT and UPDATE, NULL if it is INSERT or DELETE, since INSERT and DELETE can not be applied to column level */
      insert #output select p.action, (case when p.columns is null then -1 else a.number end), p.uid, p.protecttype, p.id, p.grantor
         from master.dbo.spt_values a, dbo.sysprotects p
         where convert(tinyint, substring( isnull(p.columns, 0x01), a.low, 1)) & a.high !=0
         and (p.id = @id)
         and (@uid is null or p.uid = @uid)
         and a.number <= @cols
         and a.type = N'P'

      declare @count int, @whataction int, @whatid int, @dup int, @whatprot int

      /* First pass to correct duplicates */
      select @count = count(*) from #output where id = @id and colid in (0, -1) and protecttype in (205, 204)
      if ( @count > 0 ) begin
         /* We might have duplicate rows for permission on single coulmn(s) at this point */
         /* Use a fake cursor to remove the duplicates first. */
         insert #tmp select action, uid, protecttype from #output where id = @id and colid in (0, -1) and protecttype in (205, 204)
         select @whataction = min(action) from #tmp
         select @whatid = uid from #tmp where action = @whataction
         while (@whataction is not null) begin
            if (@mode like N'col%') and (@objname is null) and (@grantee is not null) begin
               /* Special case for column level permissions on ALL objects for the specified user, we don't want the row(s) on the entire table */
               /* and we don't want the possible duplicate rows in single column(s) */
               delete #output where (@whatid = uid) and (colid not in (0, -1)) and (protecttype in (205, 204)) and action = @whataction
                      and (exists (select * from #output where (@whatid = uid) and (colid in (0, -1)) and action = @whataction) and (id = @id))
               delete #output where (@whatid = uid) and (colid in (0, -1)) and (action = @whataction) and (id = @id)
            end else if (@mode like N'use%') and (@objname is not null) begin
               /* Special case for the user mode, we do want to keep the entire table permissions */
               delete #output where (@whatid = uid) and (colid not in (0, -1)) and (protecttype in (205, 204)) and action = @whataction and (id = @id)
            end else begin
               /* Other cases */
               delete #output where (@whatid = uid) and (colid not in (0, -1)) and (protecttype in (205, 204)) and action = @whataction
            end

            delete #tmp where @whatid = uid
            select @whataction = min(action) from #tmp
            select @whatid = uid from #tmp where action = @whataction
         end
         delete #tmp
      end

      /* Second pass to correct protect type */
      select @count = count(*) from #output where id = @id and colid in (0, -1)
      if ( @count > 0 ) begin
         /* use another fake cursor to correct the protecttype */
         /* if there are multiple rows in #output for the same id and action, and if colid = 0 exist */
         /* then other rows should have different protecttype from the one in colid = 0 row */
         insert #tmp select action, uid, protecttype from #output where id = @id and colid in (0, -1)
         select @whataction = min(action) from #tmp
         select @whatid = uid from #tmp where action = @whataction
         select @whatprot = protecttype from #tmp where uid = @whatid and action = @whataction
         while (@whataction is not null) begin
               delete #output where id = @id and colid not in (0, -1) and @whataction = action and @whatid = uid and @whatprot = protecttype
               delete #tmp where action = @whataction and @whatid = uid
               select @whataction = min(action) from #tmp
               select @whatid = uid from #tmp where action = @whataction
               select @whatprot = protecttype from #tmp where uid = @whatid and action = @whataction
         end
         delete #tmp
      end

		/* Increment our "fake cursor" column and get the next one. */
		delete #objs where id = @id
		select @id = min(id) from #objs
	end

	/*
	 * Organize so that the non-collist privileges are returned first.. this allows
	 * scripting to combine them.  sysprotects.action is tinyint, so the hibyte won't conflict.
	 */

	update #output set action = action | 0x10000000 where colid <> 0

	/*
	 *  BUG 58252  
	 *  Delete the columns that was droped
	 */
	delete from #output where colid not in (0, -1) and col_name(id, colid) is null


	/*
	 * Order output by uid so Public will script before other groups (we need to script privs for public before
	 * other groups, before users; otherwise sysprotects doesn't hold onto things right).  Sub-order is by object id
	 * so we know when we're done with one object and onto the next, then by protecttype to group all GRANTs and
	 * REVOKEs together, and lastly by action (including ORDER_ACTION_BIT so scripting can be more efficient)
	 * because we may have multiple rows for columns.
	 */

	set nocount off
   if (@mode not like N'col%') begin
      /* Mode is not 'column', do the regular stuff */
	   select p.action & ~convert(int, 0x10000000), N'column' = col_name(p.id, p.colid), p.uid, N'username' = user_name(p.uid),
		       p.protecttype, o.name, N'owner' = user_name(o.uid), p.id, N'grantor' = user_name(p.grantor)
             from #output p, dbo.sysobjects o
             where o.id = p.id
             order by p.uid, p.id, p.protecttype, p.action
   end else
   /* Below are spcial cases for column level permissions */
   if (@objname is null) and (@grantee is not null) and (@rollup = 0) begin
      /* 8.0, special path to get column level permissions from all objects on the specified user */
      select N'ObjectName' = o.name, N'Owner' = user_name(o.uid), N'ColumnName' = col_name(p.id, p.colid), o.sysstat & 0x0f, p.id,
             p.action & ~convert(int, 0x10000000), p.protecttype
             from #output p, dbo.sysobjects o
             where p.id = o.id and p.uid = user_id(@grantee) and col_name(p.id, p.colid) is not null
             order by p.uid, p.id, p.protecttype, p.action
	end else if (@objname is not null) and (@grantee is not null) and (@rollup = 0) begin
      /* 8.0, mode 'column', and grantee != null, we want column level permissions on this object for this user */
      select N'column' = col_name(p.id, p.colid), N'owner' = user_name(o.uid), N'username' = user_name(p.uid), o.sysstat & 0x0f, p.id,
             p.action & ~convert(int, 0x10000000), p.protecttype
             from #output p, dbo.sysobjects o
             where o.id = p.id and p.uid = user_id(@grantee) and col_name(p.id, p.colid) is not null
             order by p.uid, p.id, p.protecttype, p.action
   end else if (@objname is not null) and (@grantee is null) and (@rollup = 0) begin
      /* 8.0, mode 'column', and grantee = null, we want column level permissions on this object for all users */
      select N'column' = col_name(p.id, p.colid), N'owner' = user_name(o.uid), N'username' = user_name(p.uid), o.sysstat & 0x0f, p.id,
             p.action & ~convert(int, 0x10000000), p.protecttype
             from #output p, dbo.sysobjects o
             where o.id = p.id and col_name(p.id, p.colid) is not null
             order by p.uid, p.id, p.protecttype, p.action
   end else if (@objname is null) and (@grantee is not null) and (@rollup <> 0) begin
      /* 8.0, roll up version of the special path to get column level permissions from all objects on the specified user */
      select distinct N'ObjectName' = o.name, N'owner' = user_name(o.uid),
             N'Select' = (case when ((p.action & ~convert(int, 0x10000000))=193) then 1 else 0 end),
             N'Update' = (case when ((p.action & ~convert(int, 0x10000000))=197) then 1 else 0 end),
             N'Type' = p.protecttype
             from #output p, dbo.sysobjects o
             where p.id = o.id and p.uid = user_id(@grantee) and col_name(p.id, p.colid) is not null
             order by o.name
   end else if (@objname is not null) and (@grantee is null) and (@rollup <> 0) begin
      /* 8.0, roll up version of the special path to return column level permissions on this object for all users */
      select distinct N'UserName' = user_name(p.uid),
             N'Select' = (case when ((p.action & ~convert(int, 0x10000000))=193) then 1 else 0 end),
             N'Update' = (case when ((p.action & ~convert(int, 0x10000000))=197) then 1 else 0 end),
             N'Type' = p.protecttype
             from #output p, dbo.sysobjects o
             where o.id = p.id and col_name(p.id, p.colid) is not null
             order by user_name(p.uid)
   end else begin
      raiserror 55555 N'Invalid parameter combinations.'
		return 1
   end
go
/* End sp_MSobjectprivs */


exec sp_MS_marksystemobject sp_MSobjectprivs
go

grant execute on sp_MSobjectprivs to public

--------------------------------------------------------------------------------
-- END SQLDMO SECTION
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Changes made to XPSTAR.sql file for SP1
--
-- xp_adsirequest          
-- sp_ActiveDirectory_Obj  
-- xp_GetAdminGroupName	   
-- sp_ActiveDirectory_SCP  
--------------------------------------------------------------------------------


/**************************************************************/
/* xp_terminate_process                                       */
/**************************************************************/
if exists (select * from master.dbo.sysobjects where name = N'xp_terminate_process' and type = N'X')
	exec sp_dropextendedproc N'xp_terminate_process'
go

/**************************************************************/
/* xp_adsirequest                                             */
/**************************************************************/
if exists (select * from sysobjects where name = N'xp_adsirequest' and type = N'X')
    exec sp_dropextendedproc N'xp_adsirequest'
go

print N''
print N'Creating extended stored procedure xp_adsirequest...'
go

exec sp_addextendedproc N'xp_adsirequest',N'xpstar.dll'
go

/**************************************************************/
/* sp_ActiveDirectory_Obj                                     */
/**************************************************************/
if exists (select * from sysobjects where name = N'sp_ActiveDirectory_Obj' and type = N'P')
    drop procedure sp_ActiveDirectory_Obj
go

print N''
print N'Creating procedure sp_ActiveDirectory_Obj...'
go

create proc dbo.sp_ActiveDirectory_Obj
    @Action          nvarchar(10) = N'create',    -- create, update, delete
    @ObjType         nvarchar(15) = N'database',    -- database, publication
    @ObjName         sysname  = null,        -- object name
    @DatabaseName    sysname = null,         -- database name for publication object
    @GUIDName        sysname = null          -- GUID for publication update and delete
as
begin
   /* create : create the object under the current SCP object. */
   /* update : update the object under the SCP object.         */
   /* delete : delete the object under the SCP object.         */

   SET NOCOUNT ON

   DECLARE @isdbowner int
   DECLARE @cmd nvarchar(255)
   DECLARE @commonname nvarchar(300)
   DECLARE @retcode int
   DECLARE @nAction nvarchar(3)
   DECLARE @Tmp nvarchar(10)
   DECLARE @dbname sysname

   DECLARE @retval int
   DECLARE @SQLADSI_COM_ERROR int
   DECLARE @SQLADSI_UNEXP_ERROR int
   DECLARE @SQLADSI_SCP_NOT_FOUND int
   DECLARE @SQLADSI_SVC_ACCT_ERROR int
   DECLARE @SQLADSI_CANNOT_START_HLP int
   DECLARE @SQLADSI_TIMEOUT_WAIT_HLP int
   DECLARE @SQLADSI_AD_NOT_INSTALLED int
   DECLARE @SQLADSI_PROXY_ACCT_ERROR int

   SELECT @SQLADSI_COM_ERROR = 536870913
   SELECT @SQLADSI_UNEXP_ERROR = 536870914
   SELECT @SQLADSI_SCP_NOT_FOUND = 536870915
   SELECT @SQLADSI_SVC_ACCT_ERROR = 536870916
   SELECT @SQLADSI_CANNOT_START_HLP = 536870917
   SELECT @SQLADSI_TIMEOUT_WAIT_HLP = 536870918
   SELECT @SQLADSI_AD_NOT_INSTALLED = 536870919
   SELECT @SQLADSI_PROXY_ACCT_ERROR = 536870920

   /* check permissions
   IF (not is_srvrolemember(N'sysadmin') = 1)
   begin
      raiserror(15003,-1,-1, N'sysadmin')
      return 1
   end
   */

   /* If publication object, we need both object name and database name */
   if ((UPPER(@ObjType) in (N'PUBLICATION')) and ((@ObjName is null) or (@DatabaseName is null)))
   begin
      raiserror(14200, -1, -1, N'@ObjName or @DatabaseName')
      return 1
   end


   /* check parameters */
   if (@Action is null OR UPPER(@Action) not in (N'CREATE', N'UPDATE', N'DELETE'))
   begin
      raiserror(14266, -1, -1, N'@Action', N'CREATE, UPDATE, DELETE')
      return 1
   end
   if (@ObjType is null OR UPPER(@ObjType) not in (N'DATABASE', N'REPOSITORY', N'PUBLICATION'))
   begin
      raiserror(14266, -1, -1, N'@ObjType', N'DATABASE, REPOSITORY, PUBLICATION')
      return 1
   end
   if (@ObjName is null)
   begin
      raiserror(14200, -1, -1, N'@ObjName')
      return 1
   end

   /* If publication object update or delete, we need GUID also */
   if ((UPPER(@ObjType) in (N'PUBLICATION')) and UPPER(@Action) in (N'UPDATE', N'DELETE') and (@GUIDName is null))
   begin
      raiserror(14200, -1, -1, N'@GUIDNName')
      return 1
   end

   if (UPPER(@ObjType) in (N'PUBLICATION'))
      select @dbname = @DatabaseName
   else
      select @dbname = @ObjName

-- Make sure the database exists
--
   if not exists (select * from master.dbo.sysdatabases where name = @dbname)
   begin
      raiserror(15010,-1,-1,@dbname)
      return (1)
   end

   /* Check permissions.  */
   SELECT @cmd = 'USE ' + quotename(@dbname) + ' SELECT @isdbowner = is_member(''db_owner'')'

   EXEC @retcode = sp_executesql @cmd, N'@isdbowner int output', @isdbowner output
   IF @@error <> 0 or @retcode <> 0
      return 1

   IF (is_srvrolemember('sysadmin') <> 1 and isnull(@isdbowner, 0) <> 1)
   BEGIN
      raiserror(21050, 14, -1)
      return 1
   END

   /* common name length check */ 
   if (UPPER(@ObjType) in (N'PUBLICATION'))
       SELECT @commonname = @ObjName + N':' + @DatabaseName
   else
       SELECT @commonname = @ObjName
  
   IF (LEN(@commonname) > 64)
      RAISERROR(14357, -1, -1, @commonname)
       
   select @Tmp = UPPER(@Action)
   if (UPPER(@Tmp) like N'CRE%')
      select @nAction = N'1'
   else if (UPPER(@Tmp) like N'UPD%')
      select @nAction = N'2'
   else if (UPPER(@Tmp) like N'DEL%')
      select @nAction = N'3'

   declare @nObjType nvarchar(3)
   select @Tmp = UPPER(@ObjType)
   if (UPPER(@Tmp) like N'DATAB%')
      select @nObjType = N'2'
   else if (UPPER(@Tmp) like N'REPOS%')
      select @nObjType = N'3'
   else if (UPPER(@Tmp) like N'PUBL%')
      select @nObjType = N'4'

   /* are we running on Windows 2000 or NT4 SP5 with AD enabled?  continue only if TRUE */
   EXECUTE @retval = master.dbo.xp_MSADEnabled
   if (@retval = 0)
   begin
      /* prepare parameters */
      declare @InstanceName sysname
      declare @ServerName sysname
      select @InstanceName = convert(sysname, serverproperty(N'InstanceName'))
      select @ServerName = convert(sysname, serverproperty(N'ServerName'))
      if (@InstanceName is NULL)
         select @InstanceName = N'MSSQLSERVER'

      /* Need to create registry values only if create or update. */
	  if (@nAction <> N'3')
	  begin
	      EXECUTE @retval = master.dbo.xp_MSADSIObjReg @InstanceName, @nAction, @nObjType, @ObjName, @DatabaseName, @ServerName
      end
      if (@retval = 0)
      begin
         /* call xp with the valid parameters, xp_cmdshell expects double quote begin and end */
         DECLARE @args NVARCHAR(512)
         if ((@nObjType like N'4') and (@nAction like N'1'))
         begin
            /* PUBLICATION creation */
            SELECT @args = @InstanceName + N' ' + @nAction +  N' ' + @nObjType + N' '  + quotename(@ObjName, N'"') + N' ' + quotename(@DatabaseName, N'"') 
         end else if ((@nObjType like N'4') and (@nAction not like N'1'))
         begin
            /* PUBLICATION update or delete */
            SELECT @args = @InstanceName + N' ' + @nAction +  N' ' + @nObjType + N' ' + quotename(@ObjName, N'"') + N' ' + quotename(@DatabaseName, N'"') + N' ' + @GUIDName
         end else
         begin
            /* Non PUBLICATION objects */
            SELECT @args = @InstanceName + N' ' + @nAction +  N' ' + @nObjType + N' ' + quotename(@ObjName, N'"')
         end

		 EXECUTE @retval = master.dbo.xp_adsirequest @args
		 if (@retval = 0)
		 begin
	        if (@nAction = N'3')
		    begin
				EXECUTE @retval = master.dbo.xp_MSADSIObjReg @InstanceName, @nAction, @nObjType, @ObjName, @DatabaseName, @ServerName
				if (@retval <> 0)
				begin
                    raiserror(14303, -1, -1, N'sp_ActiveDirectory_Obj')
					return 1
				end
			end
		 end
         else
         begin
            if @retval = @SQLADSI_COM_ERROR 
                RAISERROR(14350, -1, -1)
            else if @retval = @SQLADSI_UNEXP_ERROR 
                RAISERROR(14351, -1, -1)
            else if @retval = @SQLADSI_SCP_NOT_FOUND 
                RAISERROR(14352, -1, -1)
            else if @retval = @SQLADSI_SVC_ACCT_ERROR 
                RAISERROR(14353, -1, -1)
            else if @retval = @SQLADSI_CANNOT_START_HLP 
                RAISERROR(14354, -1, -1)
            else if @retval = @SQLADSI_TIMEOUT_WAIT_HLP 
                RAISERROR(14355, -1, -1)
            else if @retval = @SQLADSI_AD_NOT_INSTALLED 
                RAISERROR(14356, -1, -1)
            else if @retval = @SQLADSI_PROXY_ACCT_ERROR 
                RAISERROR(14358, -1, -1)
   
            /* Failed */
            return 1
         end
      end else
      begin
         raiserror(14303, -1, -1, N'sp_ActiveDirectory_Obj')
         return 1
      end
   end else
   begin
      raiserror(14304, -1, -1, N'sp_ActiveDirectory_Obj')
      return 1
   end
end
go

grant execute on sp_ActiveDirectory_Obj to public
go

/**************************************************************/
/* xp_GetAdminGroupName                                       */
/**************************************************************/
if exists (select * from sysobjects where name = N'xp_GetAdminGroupName' and type = N'X')
    exec sp_dropextendedproc N'xp_GetAdminGroupName'
go

print N''
print N'Creating extended stored procedure xp_GetAdminGroupName...'
go

exec sp_addextendedproc N'xp_GetAdminGroupName',N'xpstar.dll'
go

grant execute on xp_GetAdminGroupName to public
go

/**************************************************************/
/* sp_ActiveDirectory_SCP                                     */
/**************************************************************/
if exists (select * from sysobjects where name = N'sp_ActiveDirectory_SCP' and type = N'P')
    drop procedure sp_ActiveDirectory_SCP
go

print N''
print N'Creating procedure sp_ActiveDirectory_SCP...'
go

create proc dbo.sp_ActiveDirectory_SCP
    @Action  nvarchar(20) = N'create',    -- create_noupdate, create_with_db, create, update, delete, shutdown
    @Startup int = 0                      -- 0 for non-startup, non-zero if called from server startup
as
begin
   /* create_noupdate         : create the SCP object, if it exists already, update it.                                     */
   /*                           create the DB objects only if they don't exists yet.  Do not update the existig DB objects. */
   /* create_with_db          : create the SCP object, if it exsits already, update it.                                     */
   /*                           Create all the DB objects under the SCP object.  If a DB object exists already, update it.  */
   /* create (DEFAULT)        : create the SCP object, if it exists already, update it.                                     */
   /* update                  : update the SCP object.                                                                      */
   /* shutdown                : mark the SCP object to indicate not running, but don't delete it.                           */
   /* delete                  : delete the SCP object and all the objects below it.                                         */

   SET NOCOUNT ON

   DECLARE @retval int
   DECLARE @SQLADSI_COM_ERROR int
   DECLARE @SQLADSI_UNEXP_ERROR int
   DECLARE @SQLADSI_SCP_NOT_FOUND int
   DECLARE @SQLADSI_SVC_ACCT_ERROR int
   DECLARE @SQLADSI_CANNOT_START_HLP int
   DECLARE @SQLADSI_TIMEOUT_WAIT_HLP int
   DECLARE @SQLADSI_AD_NOT_INSTALLED int
   DECLARE @SQLADSI_PROXY_ACCT_ERROR int

   SELECT @SQLADSI_COM_ERROR = 536870913
   SELECT @SQLADSI_UNEXP_ERROR = 536870914
   SELECT @SQLADSI_SCP_NOT_FOUND = 536870915
   SELECT @SQLADSI_SVC_ACCT_ERROR = 536870916
   SELECT @SQLADSI_CANNOT_START_HLP = 536870917
   SELECT @SQLADSI_TIMEOUT_WAIT_HLP = 536870918
   SELECT @SQLADSI_AD_NOT_INSTALLED = 536870919
   SELECT @SQLADSI_PROXY_ACCT_ERROR = 536870920

   /* check permissions */
   IF (not is_srvrolemember(N'sysadmin') = 1)
   begin
      raiserror(15003,-1,-1, N'sysadmin')
      return 1
   end

   /* check parameters */
   if (@Action is null OR UPPER(@Action) not in (N'CREATE', N'UPDATE', N'DELETE', N'SHUTDOWN', N'CREATE_WITH_DB', N'CREATE_NOUPDATE'))
   begin
      raiserror(14266, -1, -1, N'@Action', N'CREATE, UPDATE, DELETE, SHUTDOWN, CREATE_WITH_DB, CREATE_NOUPDATE')
      return 1
   end

   declare @nAction nvarchar(3)
   declare @Tmp nvarchar(10)
   select @Tmp = UPPER(@Action)
   if (UPPER(@Tmp) like N'CRE%')
      select @nAction = N'1'
   else if (UPPER(@Tmp) like N'UPD%')
      select @nAction = N'2'
   else if (UPPER(@Tmp) like N'DEL%')
      select @nAction = N'3'
   else if (UPPER(@Tmp) like N'SHU%')
      select @nAction = N'4'

   /* are we running on Windows 2000 or NT4 SP5 with AD enabled?  continue only if TRUE */
   EXECUTE @retval = master.dbo.xp_MSADEnabled
   if (@retval = 0)
   begin
      /* Get the correct path for xpadsi.exe */
      declare @Data nvarchar(256)
      exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\Setup', N'SQLPath', @param = @Data OUT, @no_output = N'no_output'

      declare @BlankIndex int
      select @BlankIndex = charindex(N' ', @Data)
      if (@BlankIndex is NULL)
          select @BlankIndex = 0

      /* Gather information */
      declare @InstanceName sysname
      declare @ServerName sysname
      select @InstanceName = convert(sysname, serverproperty(N'InstanceName'))
      select @ServerName = convert(sysname, serverproperty(N'ServerName'))
      if (@InstanceName is NULL)
         select @InstanceName = N'MSSQLSERVER'

      /* Need to create registry values only if create or update.  Delete registry when delete */
	  if (@nAction <> N'3')
	  begin
          EXECUTE @retval = master.dbo.xp_MSADSIReg @InstanceName, @nAction, @ServerName
      end
      if (@retval = 0)
      begin
         /* call xp with the valid parameters */
         DECLARE @command NVARCHAR(512)
         DECLARE @nStartup NVARCHAR(5)
         if (@Startup = 0)
            select @nStartup = N'0'
         else
            select @nStartup = N'1'
         if (@BlankIndex <> 0)
            SELECT @command = N'""' + @Data + N'\Binn\' + N'xpadsi.exe' +  N'"" ' + @InstanceName + N' ' + @nAction +  N' 1 ' + @nStartup
         else
            SELECT @command = @Data + N'\Binn\' + N'xpadsi.exe ' + @InstanceName + N' ' + @nAction +  N' 1 ' + @nStartup

         EXECUTE @retval = master.dbo.xp_cmdshell @command
         if (@retval = 0)
         begin
		    /* we successfully delete the SCP and all its children,  let's remove the registry keys/values for them */
	        if (@nAction = N'3')
		    begin
                EXECUTE @retval = master.dbo.xp_MSADSIReg @InstanceName, @nAction, @ServerName
				if (@retval <> 0)
				begin
			        raiserror(14303, -1, -1, N'sp_ActiveDirectory_SCP')
					return 1
				end
			end
            /* Get in only if caller asked for create with DB objects */
            if (UPPER(@Action) like N'CREATE_WITH%') or (UPPER(@Action) like N'CREATE_NOU%')
            begin
               /* After we created the SCP object, we create all the database objects */

               /* Note that for performance reason, we want to create all the registry entries in one connection */
               EXECUTE @retval = master.dbo.xp_MSADSIObjRegDB @InstanceName, @ServerName

               if (UPPER(@Action) like N'CREATE_WITH%')
               begin
                  declare hC cursor for select name from master.dbo.sysdatabases
               end else begin
                  declare hC cursor for select * from msdb.dbo.ADSINewDBs
               end

           	   declare @DBname sysname
	              open hC
           	   fetch next from hC into @DBname

           	   while (@@FETCH_STATUS = 0)
               begin
                  /* Do the AD part, continue even if we got error from one create */
                  if (@BlankIndex <> 0)
                     SELECT @command = N'""' + @Data + N'\Binn\' + N'xpadsi.exe ' + N'" ' + @InstanceName + N' 1 2 ' + N'"' + @DBname + N'""'
                  else
                     SELECT @command = @Data + N'\Binn\' + N'xpadsi.exe ' + @InstanceName + N' 1 2 ' + N'""' + @DBname + N'""'
                  EXECUTE master.dbo.xp_cmdshell @command

          	   	   fetch next from hC into @DBname
           	   end

              	close hC
              	deallocate hC

               /* Get rid of the worker table, which was created by master.dbo.xp_MSADSIObjRegDB */
               drop table msdb.dbo.ADSINewDBs
            end
            return 0
         end else
         begin
            if @retval = @SQLADSI_COM_ERROR 
                RAISERROR(14350, -1, -1)
            else if @retval = @SQLADSI_UNEXP_ERROR 
                RAISERROR(14351, -1, -1)
            else if @retval = @SQLADSI_SCP_NOT_FOUND 
                RAISERROR(14352, -1, -1)
            else if @retval = @SQLADSI_SVC_ACCT_ERROR 
                RAISERROR(14353, -1, -1)
            else if @retval = @SQLADSI_CANNOT_START_HLP 
                RAISERROR(14354, -1, -1)
            else if @retval = @SQLADSI_TIMEOUT_WAIT_HLP 
                RAISERROR(14355, -1, -1)
            else if @retval = @SQLADSI_AD_NOT_INSTALLED 
                RAISERROR(14356, -1, -1)
            else if @retval = @SQLADSI_PROXY_ACCT_ERROR 
                RAISERROR(14358, -1, -1)
            /* Failed */
            return 1
         end
      end else
      begin
         raiserror(14303, -1, -1, N'sp_ActiveDirectory_SCP')
         return 1
      end
   end else
   begin
      raiserror(14359, -1, -1)
      return 1
   end
end
go

grant execute on sp_ActiveDirectory_SCP to public
go

--------------------------------------------------------------------------------
-- END XPSTAR SECTION
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- AGENT stored procedures added after release into instmsdb.sql file
--
-- sp_sqlagent_has_server_access
-- sp_set_sqlagent_properties
-- sp_verify_subsystem
--------------------------------------------------------------------------------

use msdb
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
/* sp_verify_subsystem                                        */
/**************************************************************/
PRINT N''
PRINT N'Creating procedure sp_verify_subsystem...'
go

IF (EXISTS (SELECT * FROM msdb.dbo.sysobjects WHERE (name = N'sp_verify_subsystem') AND (type = 'P')))
  DROP PROCEDURE dbo.sp_verify_subsystem
go

CREATE PROCEDURE dbo.sp_verify_subsystem
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

GRANT EXECUTE ON sp_get_sqlagent_properties  TO PUBLIC
go

/**************************************************************/
/* SP_SET_SQLAGENT_PROPERTIES                                 */
/**************************************************************/

ALTER PROCEDURE dbo.sp_set_sqlagent_properties
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

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


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


use msdb
go

/**************************************************************/
/* sp_post_msx_operation                                      */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_post_msx_operation'
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

GRANT EXECUTE ON sp_post_msx_operation TO PUBLIC
GO


use msdb
go
/**************************************************************/
/* SP_DELETE_TARGETSERVER                                     */
/**************************************************************/
PRINT ''
PRINT 'Creating procedure sp_delete_targetserver'
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


use msdb
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


use msdb
go

/**************************************************************/
/* SP_ENLIST_TSX                                              */
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

grant execute on sp_add_jobstep to public
go

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

grant execute on sp_update_jobstep to public
go

/**************************************************************/
/* xp_sqlagent_msx_account                                                                                   */
/**************************************************************/
use master
go

if exists (select * from master.dbo.sysobjects where name = N'xp_sqlagent_msx_account' and type = N'X')
	exec sp_dropextendedproc N'xp_sqlagent_msx_account'
go

print ''
print N'Creating extended stored procedure xp_sqlagent_msx_account'
go
exec sp_addextendedproc N'xp_sqlagent_msx_account',N'xpstar.dll'
go

use msdb
go

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

go
--------------------------------------------------------------------------------
-- END AGENT SECTION
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Remove public right from xp_SetSQLSecurity
-- This updates script from xpstar.sql
--------------------------------------------------------------------------------
use master
go

if exists (select * from sysobjects
		where name = N'xp_SetSQLSecurity')
	execute dbo.sp_dropextendedproc N'xp_SetSQLSecurity'
go

print N'Creating extended stored procedure xp_SetSQLSecurity'
exec sp_addextendedproc N'xp_SetSQLSecurity',N'xpstar.dll'
go

--------------------------------------------------------------------------------
-- XPWEB stored procedures and table modified for SP3
--
-- changed permissions on msdb..MSwebtasks table (sysadmin can INSERT, UPDATE, 
--    DELETE, public can SELECT only)
-- changed permissions on following stored procedures (ony sysadmin can EXECUTE):
--  sp_makewebtask
--  sp_dropwebtask
--  sp_cleanupwebtask
--------------------------------------------------------------------------------

-- Add mswebtasks table if not there
USE msdb
IF EXISTS (SELECT * FROM sysobjects WHERE name = N'mswebtasks')
BEGIN
   REVOKE INSERT ON mswebtasks FROM PUBLIC
   REVOKE DELETE ON mswebtasks FROM PUBLIC
   REVOKE UPDATE ON mswebtasks FROM PUBLIC
END
go

REVOKE EXECUTE ON sp_insmswebtask FROM PUBLIC
go
REVOKE EXECUTE ON sp_updmswebtask FROM PUBLIC
go


-- Revoke privileges on stored procedures
USE master
go
REVOKE EXECUTE ON sp_makewebtask FROM PUBLIC
go
REVOKE EXECUTE ON sp_dropwebtask FROM PUBLIC
go
REVOKE EXECUTE ON sp_cleanupwebtask FROM PUBLIC
go

--------------------------------------------------------------------------------
-- END XPWEB SECTION
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Change permissions on Repository stored procedures, table, and views
--------------------------------------------------------------------------------

use msdb
go

/***
   Make sure repository tables exist
***/
if exists (select * from sysobjects where type = 'U' AND name = 'RTblIfaceDefs')
begin

	/***
	   Add new security role
	***/
	if not exists (select * from sysusers where name = 'RepositoryUser')
		exec sp_addrole 'RepositoryUser'

	declare @ExecStmt as nvarchar(255)

	/***
	   Remove public role from repository tables
	***/
	DECLARE TmpCursor CURSOR FOR
	select distinct 'revoke all on ' + SQLTableName + ' to public'  from RTblIfaceDefs inner join sysobjects on SQLTableName = name where SQLTableName <> ''
	union
	select 'revoke all on ' + name + ' to public'  from sysobjects where type = 'U' AND name like 'RTbl%'
	 
	OPEN TmpCursor
	FETCH NEXT FROM TmpCursor into @ExecStmt
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    exec sp_executesql @ExecStmt
	    FETCH NEXT FROM TmpCursor into @ExecStmt
	END
	CLOSE TmpCursor
	DEALLOCATE TmpCursor
	 
	/***
	   Grant permissions on new role on repository tables
	***/
	DECLARE TmpCursor CURSOR FOR
	select distinct 'grant all on ' + SQLTableName + ' to RepositoryUser'  from RTblIfaceDefs inner join sysobjects on SQLTableName = name where SQLTableName <> ''
	union
	select 'grant all on ' + name + ' to RepositoryUser'  from sysobjects where type = 'U' AND name like 'RTbl%'
	 
	OPEN TmpCursor
	FETCH NEXT FROM TmpCursor into @ExecStmt
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    exec sp_executesql @ExecStmt
	    FETCH NEXT FROM TmpCursor into @ExecStmt
	END
	CLOSE TmpCursor
	DEALLOCATE TmpCursor
	 
	/***
	   Remove public role from repository stored procedures
	***/
	DECLARE TmpCursor CURSOR FOR
	select 'revoke all on ' + name + ' to public'  from sysobjects where type = 'P' AND name like 'r_i%'
	 
	OPEN TmpCursor
	FETCH NEXT FROM TmpCursor into @ExecStmt
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    exec sp_executesql @ExecStmt
	    FETCH NEXT FROM TmpCursor into @ExecStmt
	END
	CLOSE TmpCursor
	DEALLOCATE TmpCursor
	 
	/***
	   Grant permissions on new role on repository stored procedures
	***/
	DECLARE TmpCursor CURSOR FOR
	select 'grant all on ' + name + ' to RepositoryUser'  from sysobjects where type = 'P' AND name like 'r_i%'
	 
	OPEN TmpCursor
	FETCH NEXT FROM TmpCursor into @ExecStmt
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    exec sp_executesql @ExecStmt
	    FETCH NEXT FROM TmpCursor into @ExecStmt
	END
	CLOSE TmpCursor
	DEALLOCATE TmpCursor
	 
	IF EXISTS (select DatabaseVersion from RTblDatabaseVersion WHERE DatabaseVersion LIKE '3.%')
	BEGIN
		/***
		   Remove public role from repository views (only on V3)
		***/
		EXEC sp_executesql N'DECLARE TmpCursor CURSOR FOR SELECT DISTINCT ''revoke all on '' + ViewName + '' to public''  FROM RTblIfaceDefs WHERE ViewName <> '''''
	 
		OPEN TmpCursor
		FETCH NEXT FROM TmpCursor into @ExecStmt
		WHILE @@FETCH_STATUS = 0
		BEGIN
		    exec sp_executesql @ExecStmt
		    FETCH NEXT FROM TmpCursor into @ExecStmt
		END
		CLOSE TmpCursor
		DEALLOCATE TmpCursor
	
		/***
		   Grant permissions on new role on repository views (only on V3)
		***/
		EXEC sp_executesql N'DECLARE TmpCursor CURSOR FOR SELECT DISTINCT ''grant all on '' + ViewName + '' to RepositoryUser''  FROM RTblIfaceDefs WHERE ViewName <> '''''
	 
		OPEN TmpCursor
		FETCH NEXT FROM TmpCursor into @ExecStmt
		WHILE @@FETCH_STATUS = 0
		BEGIN
		    exec sp_executesql @ExecStmt
		    FETCH NEXT FROM TmpCursor into @ExecStmt
		END
		CLOSE TmpCursor
		DEALLOCATE TmpCursor
	END
 
END

USE master
go

--------------------------------------------------------------------------------
-- End Repository Changes
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- END OF CHANGE SECTION:
-- Turn off marking of system objects.
-- DO NOT ADD ANYTHING AFTER THIS POINT
--------------------------------------------------------------------------------
print N''
go

exec sp_MS_upd_sysobj_category 2
go

exec sp_configure 'allow updates',0
go

reconfigure with override
go

PRINT N''
PRINT N'Done updating database objects'
PRINT N'Finished at ' + convert(nvarchar(25), getdate())
PRINT N''
go


if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MSSetServerProperties')
	drop procedure sp_MSSetServerProperties
go


print N''
print N'Creating sp_MSSetServerProperties'
print N''
go

create proc sp_MSSetServerProperties
   @auto_start    INT   = NULL   -- 1 or 0, while 1 = auto start, 0 = manual start
as
   set nocount on

   -- only sysadmins are allowed to execute this stored procedure
   if( is_srvrolemember(N'sysadmin') = 0 )
   	begin
   	RAISERROR (15003, -1, -1, N'sysadmin')
   	return 1
   	end

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

   -- Write out the values
   IF (@auto_start IS NOT NULL)
   BEGIN
      IF ((PLATFORM() & 0x1) = 0x1) -- NT
         EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                                 N'SYSTEM\CurrentControlSet\Services\MSSQLServer',
                                                 N'Start',
                                                 N'REG_DWORD',
                                                 @auto_start
      ELSE
         RAISERROR(14546, 16, 1, '@auto_start')
   END

go
/* End sp_MSSetServerProperties */


exec sp_MS_marksystemobject sp_MSSetServerProperties
go


if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = 'sp_MSsetalertinfo')
	drop procedure sp_MSsetalertinfo
go


/*-----------------------------------------------------*/
/*-----------------------------------------------------*/
print N''
print N'Creating sp_MSsetalertinfo'
print N''
go
create procedure sp_MSsetalertinfo
	@failsafeoperator nvarchar(255) = null,
	@notificationmethod int = null,
	@forwardingserver nvarchar(255) = null,
	@forwardingseverity int = null,
	@pagertotemplate nvarchar(255) = null,
	@pagercctemplate nvarchar(255) = null,
	@pagersubjecttemplate nvarchar(255) = null,
	@pagersendsubjectonly int = null,
	@failsafeemailaddress nvarchar(255) = null,
	@failsafepageraddress nvarchar(255) = null,
	@failsafenetsendaddress nvarchar(255) = null,
	@forwardalways int = null -- 0 = forward only unhandled events, 1 = always forward events (both subject to @forwardingseverity)
as

   -- only sysadmins are allowed to execute this stored procedure
   if( is_srvrolemember(N'sysadmin') = 0 )
   	begin
   	RAISERROR (15003, -1, -1, N'sysadmin')
   	return 1
   	end

	/* Set all alert info at one go, for performance reasons.  Translate values if needed. */
	if (@pagersendsubjectonly is not null and @pagersendsubjectonly <> 0)
		select @pagersendsubjectonly = 1

	if (@failsafeoperator is not null)
		exec master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'AlertFailSafeOperator', N'REG_SZ', @failsafeoperator
	if (@notificationmethod is not null)
		exec master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'AlertNotificationMethod', N'REG_DWORD', @notificationmethod
	if (@forwardingserver is not null)
		exec master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'AlertForwardingServer', N'REG_SZ', @forwardingserver
	if (@forwardingseverity is not null)
		exec master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'AlertForwardingSeverity', N'REG_DWORD', @forwardingseverity
	if (@pagertotemplate is not null)
		exec master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'AlertPagerToTemplate', N'REG_SZ', @pagertotemplate
	if (@pagercctemplate is not null)
		exec master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'AlertPagerCCTemplate', N'REG_SZ', @pagercctemplate
	if (@pagersubjecttemplate is not null)
		exec master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'AlertPagerSubjectTemplate', N'REG_SZ', @pagersubjecttemplate
	if (@pagersendsubjectonly is not null)
		exec master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'AlertPagerSendSubjectOnly', N'REG_DWORD', @pagersendsubjectonly
	if (@failsafeemailaddress is not null)
		exec master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'AlertFailSafeEmailAddress', N'REG_SZ', @failsafeemailaddress
	if (@failsafepageraddress is not null)
		exec master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'AlertFailSafePagerAddress', N'REG_SZ', @failsafepageraddress
	if (@failsafenetsendaddress is not null)
		exec master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'AlertFailSafeNetSendAddress', N'REG_SZ', @failsafenetsendaddress
	if (@forwardalways is not null)
		exec master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'AlertForwardAlways', N'REG_DWORD', @forwardalways
go
/* End sp_MSgetalertinfo */

exec sp_MS_marksystemobject sp_MSsetalertinfo
go


