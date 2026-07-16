/*------------------------------------------------------------------------------

80SP1_TOOLS.SQL

THIS SCRIPT TAKES THE TOOLS STORED PROCS FROM 8.0 to SP1.

Changes in this file reflects changes in the following files:
	INSTMSDB.SQL
	SQLDMO.SQL
	XPSTAR.SQL
	SQLTRACE.SQL
	WEB.SQL

Notes:

------------------------------------------------------------------------------*/

PRINT N''
PRINT N'Updating database objects, executing 80SP1-TOOLS.SQL'
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
    EXECUTE master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
                                            N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
                                            N'SysAdminOnly',
                                            N'REG_DWORD',
                                            @sysadmin_only
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

--------------------------------------------------------------------------------
-- END AGENT SECTION
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- END OF FILE: Turn off marking of system objects.
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
