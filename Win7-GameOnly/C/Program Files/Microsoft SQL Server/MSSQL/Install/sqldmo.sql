
/**********************************************************************
 * Microsoft SQL Server SQL-DMO scripts, version 8.0.
 * Date created:  3/17/96.
 * Date modified: 7/05/00.
 * Copyright Microsoft Corporation, 1992-2000
 **********************************************************************
 *	This script must be installed for the SQL-DMO (SQLDMO) objects and
 *	the SQL Enterprise Manager to run against a Microsoft SQL Server.
 **********************************************************************/


















/* Preprocessor directives, will be blank space in output .sql file. */











/* For fetching from cursor */















/* 8.0, the new UDF object is uning what UDDT has been using */
/* so we have to assing a new value to UDDT, this has to be consistent with the defines in dmo_itf.h */






































/* status values for these. */







/* bitmask values for same; power(2, DRI_*). */


















/* DRI-generated index masks, to apply to sysindexes.status */






/* sysobjects.category bit that indicates this is an MS-internal object. */


/* sysobjects.category bit for an sp_ that indicates it's a startup proc, or an xp that should ImpersonateClient. */



/* BIT_CLUSTERED indicates the key is clustered. */
/* EXCLUDE REPLICATION value in sysconstraints.status, and system-generated name. */





/* sysobjects.sysstat bits (lower 4) that mask off the object type. */


/* bit for DEFAULTS which are really DRI-created. */


/* bits for sp_MShelpcolumns col_flags - don't conflict with bit_sysgenname for DRIDefaults. */





/* sysdatabases.category bits */



/* sysobjects.category bits (from ntdbms\object.h) */

















/* The parser can't '|' 0x-prefixed types as it thinks they're binary */







/**** daVinci additions ****/

/* sp_MStablekeys @flags bitmask param values. */


/* sp_MShelpindexes @flags bitmask param values. */


/* sp_MStablechecks @flags bitmask param values. */



/* Descending indices definitions, used in core_sql.cxx, key.cpp, and index.cpp */

























/* Internal #defines for SQLDMO. */

/* Current SQLDMO version.  Also must be available to SQLDMO.odl. */
/* #define SQLDMOVERSION_MAJOR             7  */
/* #define SQLDMOVERSION_MINOR             50 */






/* Make sure we use our own; shield SQLDMO from Starfighter changes. */







/* Our max name lengths. */
/* !! All lengths retrieved from server must be rounded UP TO THE NEXT 4-bytes. !! */
/* There must be at least one byte more than server max length, for the NULL byte. */

/* 7.0 Identifier length has been increased from 30 to 128 characters */



















/* Keep for Replication, but changed to SYSNAME length */
































/* 7.0 */



/* Reserve enough space for [] quoting character, and escape character in identifier */




















/* Specail Identifier length for mapping table when scripting from 6.x server, this is the sysname length for 6.x server */







use master
go

print ''
print 'Creating SQLDMO stored procedures...'
print ''

/************* DUMP THE TRANSACTION LOG **************************************/
/* Comment this out if you don't want your log dumped.  If you rerun this    */
/* script periodically, you will run out of transaction log space.           */
print ''
print 'Dumping transaction log...'
print ''
go
dump tran master with no_log
go
/************* END DUMP THE TRANSACTION LOG **********************************/

/********************** Include individual components definitions *********************************/





















































/* From perm.h */















/* Roles */



















/* File Growth */


/* Max. Column length */


/* Default collation, no scripting */


/********************* Delete existing objects *********************************/
print N''
print N'Deleting existing objects...'
print N''
go

if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MShelpcolumns')
	drop procedure sp_MShelpcolumns
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MShelpindex')
	drop procedure sp_MShelpindex
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MShelptype')
	drop procedure sp_MShelptype
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MSdependencies')
	drop procedure sp_MSdependencies
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MStablespace')
	drop procedure sp_MStablespace
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MSindexspace')
	drop procedure sp_MSindexspace
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MSuniquename')
	drop procedure sp_MSuniquename
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MSkilldb')
	drop procedure sp_MSkilldb
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MSobjectprivs')
	drop procedure sp_MSobjectprivs
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MSloginmappings')
	drop procedure sp_MSloginmappings
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MStablekeys')
	drop procedure sp_MStablekeys
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MStablechecks')
	drop procedure sp_MStablechecks
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MStablerefs')
	drop procedure sp_MStablerefs
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MSsettopology')
	drop procedure sp_MSsettopology
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MSmatchkey')
	drop procedure sp_MSmatchkey
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MSforeachdb')
	drop procedure sp_MSforeachdb
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MSforeachtable')
	drop procedure sp_MSforeachtable
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MSforeach_worker')
	drop procedure sp_MSforeach_worker
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MSSQLOLE_version')
	drop procedure sp_MSSQLOLE_version
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MSSQLOLE65_version')
	drop procedure sp_MSSQLOLE65_version
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MSSQLDMO70_version')
	drop procedure sp_MSSQLDMO70_version
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MSSQLDMO75_version')
	drop procedure sp_MSSQLDMO75_version
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MSSQLDMO80_version')
	drop procedure sp_MSSQLDMO80_version
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MSscriptdatabase')
	drop procedure sp_MSscriptdatabase
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MSscriptdb_worker')
	drop procedure sp_MSscriptdb_worker
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MSdbuseraccess')
	drop procedure sp_MSdbuseraccess
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MSdbuserpriv')
	drop procedure sp_MSdbuserpriv
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MShelpfulltextindex')
	drop procedure sp_MShelpfulltextindex
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MShelpfulltextscript')
	drop procedure sp_MShelpfulltextscript
go
/* sp_MSqv have been removed, but we want to keep this query, just in case there are left over from previous build */
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MSqv')
	drop procedure sp_MSqv
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MSSetServerProperties')
	drop procedure sp_MSSetServerProperties
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MSGetServerProperties')
	drop procedure sp_MSGetServerProperties
go
if exists (select * from master.dbo.sysobjects where OBJECTPROPERTY(id, N'IsTableFunction') = 1 and name = N'fn_MSFullText')
	drop function fn_MSFullText
go

if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = N'sp_MSSharedFixedDisk')
	drop procedure sp_MSSharedFixedDisk
go




/********************* Create new objects *********************************/

/* New validation added for 8.0 */
/* if (@@microsoftversion >= SQL80_MINVERSION) begin                                       */
/*	 exec sp_MS_upd_sysobj_category 1                                                       */
/* end else begin                                                                          */
/*	 RAISERROR 55555 'You need a released version of SQL 8.0 to run this SQLDMO script'     */
/* end                                                                                     */
if (@@microsoftversion < 0x08000000) begin
	RAISERROR 55555 N'You need SQL Server 2000 to run this SQLDMO script'
end

/*******************************************************************************/
print N''
print N'Creating sp_MShelpcolumns'
print N''
go
create procedure sp_MShelpcolumns
@tablename nvarchar(517), @flags int = 0, @orderby nvarchar(10) = null, @flags2 int = 0
as

   /* For non-string columns, sp_MShelpcolumns returns the length in syscolumns.length, */
   /* which is defined in BOL as "maximum physical storage length from systypes".       */
   /* For string columns (including types based on string types), sp_MShelpcolumns      */
   /* returns this maximum length in characters (i.e. it returns syscolumns.length      */
   /* adjusted to whether the column is based on char or nchar).                        */

   /*** @flags2 added for DaVinci uses.  If the bit isn't set, use 6.5 ***/
   /*** sp_MShelpcolumns '%s', null, 'id', 1                           ***/

   create table #sphelpcols
      (
      col_name         nvarchar(128)   COLLATE database_default NOT NULL,
      col_id           int                          NOT NULL,
      col_typename     nvarchar(128)   COLLATE database_default NOT NULL,
      col_len          int                          NOT NULL,
      col_prec         int                          NULL,
      col_scale        int                          NULL,
      col_numtype      smallint                     NOT NULL,  /* For DaVinci to get sp_help-type filtering of prec/scale */
      col_null         bit                          NOT NULL,  /* status & 8 */
      col_identity     bit                          NOT NULL,  /* status & 128 */
      col_defname      nvarchar(257)  COLLATE database_default NULL,      /* fully-qual'd default name, or NULL */
      col_rulname      nvarchar(257)  COLLATE database_default NULL,      /* fully-qual'd rule name, or NULL */
      col_basetypename nvarchar(128)   COLLATE database_default NOT NULL,
      col_flags        int                          NULL,      /* COL_* bits */

/* Fix for Raid # 53682 */
      col_seed         nvarchar (40)      COLLATE database_default NULL,
/*	   col_seed			numeric (28)      NULL,  */
      col_increment    nvarchar (40)      COLLATE database_default NULL,
/*	   col_increment	int 				NULL,  */

      col_dridefname   nvarchar(128)   COLLATE database_default NULL,      /* DRI DEFAULT name */
      col_dridefid     int                          NULL,      /* remember the DRI DEFAULT id in syscomments, so we can retrieve it later */
      col_iscomputed   int                          NOT NULL,
      col_objectid     int                          NOT NULL,  /* column object id, need it to get computed text from syscomments */
      col_NotForRepl   bit                          NOT NULL,  /* Not For Replication setting */
      col_fulltext     bit                          NOT NULL,  /* FullTextIndex setting */
      col_AnsiPad      bit                          NULL,      /* Ansi_Padding setting */
      /* following columns are repeating the info from col_defname and col_rulname                  */
      /* because we can not change data in col_defname and col_rulname, since daVinci is using them */
      col_DOwner       nvarchar(128)   COLLATE database_default NULL,      /* non-DRI DEFAULT owner, or NULL */
      col_DName        nvarchar(128)   COLLATE database_default NULL,      /* non-DRI DEFAULT name, or NULL */
      col_ROwner       nvarchar(128)   COLLATE database_default NULL,      /* non-DRI RULE owner, or NULL */
      col_RName        nvarchar(128)   COLLATE database_default NULL,      /* non-DRI RULE name, or NULL */
      col_collation    nvarchar(128)   COLLATE database_default NULL,      /* column level collation, valid for string columns only */
      col_isindexable  int,
      col_language     int,
      )

/** For DaVinci **/
/** Use sp_help filtering of precision/scale (only fordecimal/numeric types; else use NULL). **/


	if @flags is null
		select @flags = 0
	if (@tablename = N'?')
	begin
		print N''
		print N'Usage:  sp_MShelpcolumns @tablename, @flags int = 0'
		print N' where @flags is a bitmask of:'
		print N' 0x0200		= No DRI (ignore Checks, Primary/Foreign/Unique Keys, etc.)'
		print N' 0x0400		= UDDTs --> Base type'
		print N' 0x80000		= TimestampToBinary (convert timestamp cols to binary(8))'
		print N' 0x40000000	= No Identity attribute'
		return 0
	end

	declare @objid int
	select @objid = object_id(@tablename)
	if (@objid is null)
	begin
		RAISERROR (15001, -1, -1, @tablename)
		return 1
	end

	set nocount on

   /* Do not store the computed text in this temp table, because one extra join causes big performance hit */
	/* First load stuff so we can blot off inappropriate info and massage as per @flags */
	insert #sphelpcols
		select c.name, c.colid, st.name,
         case when bt.name in (N'nchar', N'nvarchar') then c.length/2 else c.length end,
			ColumnProperty(@objid, c.name, N'Precision'),
			ColumnProperty(@objid, c.name, N'Scale'),
				-- col_numtype for DaVinci:  use sp_help-type prec/scale filtering for @flags2 & 1
			case when (@flags2 & 1 <> 0 and bt.name in (N'tinyint',N'smallint',N'decimal',N'int',N'real',N'money',N'float',N'numeric',N'smallmoney',N'bigint'))
					then 1 else 0 end,
				-- Nullable
			convert(bit, ColumnProperty(@objid, c.name, N'AllowsNull')),
				-- Identity
			case when (@flags & 0x40000000 = 0) then convert(bit, ColumnProperty(@objid, c.name, N'IsIdentity')) else 0 end,
				-- Non-DRI Default (make sure it's not a DRI constraint).
			case when (c.cdefault = 0) then null when (OBJECTPROPERTY(c.cdefault, N'IsDefaultCnst') <> 0) then null else user_name(d.uid) + N'.' + d.name end,
				-- Non-DRI Rule
			case when (c.domain = 0) then null else user_name(r.uid) + N'.' + r.name end,
				-- Physical base datatype
			bt.name,
				-- Initialize flags to whether it's a length-specifiable type, or a numeric type, or 0.
			case when st.name in (N'char',N'varchar',N'binary',N'varbinary',N'nchar',N'nvarchar') then 0x0001
					when st.name in (N'decimal',N'numeric') then 0x0002
					else 0 end
					-- Will be NULL if column is not UniqueIdentifier.
					+ case isnull(ColumnProperty(@objid, c.name, N'IsRowGuidCol'), 0) when 0 then 0 else 0x0008 end,
				-- Identity seed and increment

/* Fix for Raid # 53682 */
			case when (ColumnProperty(@objid, c.name, N'IsIdentity') <> 0) then CONVERT(nvarchar(40), ident_seed(@tablename)) else null end,
/*			case when (ColumnProperty(@objid, c.name, N'IsIdentity') <> 0) then ident_seed(@tablename) else null end,  */
			case when (ColumnProperty(@objid, c.name, N'IsIdentity') <> 0) then CONVERT(nvarchar(40), ident_incr(@tablename)) else null end,
/*			case when (ColumnProperty(@objid, c.name, N'IsIdentity') <> 0) then ident_incr(@tablename) else null end,  */

				-- DRI Default name
			case when (@flags & 0x0200 = 0 and c.cdefault is not null and (OBJECTPROPERTY(c.cdefault, N'IsDefaultCnst') <> 0))
					then object_name(c.cdefault) else null end,
				-- DRI Default text, if it does not span multiple rows (if it does, SQLDMO will go get them all).
			case when (@flags & 0x0200 = 0 and c.cdefault is not null and (OBJECTPROPERTY(c.cdefault, N'IsDefaultCnst') <> 0))
					then t.id else null end,
         c.iscomputed,
         c.id,
				-- Not For Replication
			convert(bit, ColumnProperty(@objid, c.name, N'IsIdNotForRepl')),
         convert(bit, ColumnProperty(@objid, c.name, N'IsFulltextIndexed')),
         convert(bit, ColumnProperty(@objid, c.name, N'UsesAnsiTrim')),
				-- Non-DRI Default owner and name
			case when (c.cdefault = 0) then null when (OBJECTPROPERTY(c.cdefault, N'IsDefaultCnst') <> 0) then null else user_name(d.uid) end,
			case when (c.cdefault = 0) then null when (OBJECTPROPERTY(c.cdefault, N'IsDefaultCnst') <> 0) then null else d.name end,
				-- Non-DRI Rule owner and name
			case when (c.domain = 0) then null else user_name(r.uid) end,
			case when (c.domain = 0) then null else r.name end,
           -- column level collation
         c.collation,
           -- IsIndexable
         ColumnProperty(@objid, c.name, N'IsIndexable'),
         c.language
		from dbo.syscolumns c
				-- NonDRI Default and Rule filters
			left outer join dbo.sysobjects d on d.id = c.cdefault
			left outer join dbo.sysobjects r on r.id = c.domain
				-- Fully derived data type name
			join dbo.systypes st on st.xusertype = c.xusertype
				-- Physical base data type name
			join dbo.systypes bt on bt.xusertype = c.xtype
				-- DRIDefault text, if it's only one row.
			left outer join dbo.syscomments t on t.id = c.cdefault and t.colid = 1
					and not exists (select * from dbo.syscomments where id = c.cdefault and colid = 2)
		where c.id = @objid
		order by c.colid

	/* Convert any timestamp column to binary(8) if they asked. */
	if (@flags & 0x80000 != 0)
		update #sphelpcols set col_typename = N'binary', col_len = 8, col_flags = col_flags | 0x0001 where col_typename = N'timestamp'

	/* Now see what our flags are, if anything. */
	if (@flags is not null and @flags != 0)
	begin
		if (@flags & 0x0400 != 0)
		begin
			/* Track from xusertype --> b.<base>xtype --> u.xusertype in systypes */
			/* First mask off the things we will set.  The convert() awkwardness is */
			/* necessitated by SQLServer's handling of 0x-prefixed values. */
			declare @typeflagmask int select @typeflagmask = (convert(int, 0x0001) + convert(int, 0x0002))
			update #sphelpcols set col_typename = b.name,
				-- ReInitialize flags to whether it's a length-specifiable type, or a numeric type, or 0.
				col_flags = col_flags & ~@typeflagmask
							+ case when b.name in (N'char',N'varchar',N'binary',N'varbinary',N'nchar',N'nvarchar') then 0x0001
								when b.name in (N'decimal',N'numeric') then 0x0002
								else 0 end
			from #sphelpcols c, dbo.systypes n, dbo.systypes b
				where n.name = col_typename				--// xtype (base type) of name
					and b.xusertype = n.xtype			--// Map it back to where it's xusertype, to get the name
		end
	end

	/* Determine if the column is in the primary key */
	if (@flags & 0x0200 = 0 and (OBJECTPROPERTY(@objid, N'TableHasPrimaryKey') <> 0)) begin
		declare @indid int
		select @indid = indid from dbo.sysindexes i where i.id = @objid and i.status & 0x0800 <> 0
		if (@indid is not null)
			update #sphelpcols set col_flags = col_flags | 0x0004
			from #sphelpcols c, dbo.sysindexkeys i
				where i.id = @objid and i.indid = @indid and i.colid = c.col_id
	end

	/* OK, now put out the data.  @flags2 added for DaVinci; currently only bit 1 (sp_help filtering of prec/scale) is relevant. */
	set nocount off
	if (@orderby is null or @orderby = N'id')
	begin
		select c.col_name, c.col_id, c.col_typename, c.col_len,
					-- Prec/scale only for numeric/decimal
				col_prec = case when (col_basetypename in (N'decimal',N'numeric') or (@flags2 & 1 <> 0 and col_numtype & 1 <> 0))
						then c.col_prec else NULL end,
				col_scale = case when (col_basetypename in (N'decimal',N'numeric') or (@flags2 & 1 <> 0 and col_numtype & 1 <> 0))
						then c.col_scale else NULL end,
				col_basetypename, c.col_defname, c.col_rulname, c.col_null, c.col_identity, c.col_flags,
			   c.col_seed,
            c.col_increment, c.col_dridefname, cn.text, c.col_iscomputed, cm.text, c.col_NotForRepl,
            c.col_fulltext, c.col_AnsiPad, c.col_DOwner, c.col_DName, c.col_ROwner, c.col_RName,
            collation = c.col_collation,
            ColType = case when( col_basetypename in (N'image')) then d.FT_COLNAME else NULL end,   /* FullText column name for image column */
            case when ( c.col_isindexable is null ) then 0 else c.col_isindexable end,
            case when ( c.col_language >= 0 ) then c.col_language else -1 end
		from ((#sphelpcols c
      left outer join dbo.syscomments cm on cm.id = c.col_objectid and cm.number = c.col_id) left outer join dbo.syscomments cn on c.col_dridefid is not null and cn.id = c.col_dridefid)
      left outer join (select distinct FT_COLNAME = scol.name, FT_ID = sdep.number from dbo.syscolumns scol, dbo.sysdepends sdep where
                       scol.colid = sdep.depnumber and
                       sdep.deptype = 1 and
                       scol.id = @objid and
                       sdep.depid = @objid and
                       ColumnProperty(scol.id, scol.name, N'IsTypeForFullTextBlob') = 1) as d on c.col_id = d.FT_ID
		order by c.col_id
	end else begin
		select c.col_name, c.col_id, c.col_typename, c.col_len,
					-- Prec/scale only for numeric/decimal
				col_prec = case when (col_basetypename in (N'decimal',N'numeric') or (@flags2 & 1 <> 0 and col_numtype & 1 <> 0))
						then c.col_prec else NULL end,
				col_scale = case when (col_basetypename in (N'decimal',N'numeric') or (@flags2 & 1 <> 0 and col_numtype & 1 <> 0))
						then c.col_scale else NULL end,
				col_basetypename, c.col_defname, c.col_rulname, c.col_null, c.col_identity, c.col_flags,
			   c.col_seed,
            c.col_increment, c.col_dridefname, cn.text, c.col_iscomputed, cm.text, c.col_NotForRepl,
            c.col_fulltext, c.col_AnsiPad, c.col_DOwner, c.col_DName, c.col_ROwner, c.col_RName,
            collation = c.col_collation,
            ColType = case when( col_basetypename in (N'image')) then d.FT_COLNAME else NULL end,   /* FullText column name for image column */
            case when ( c.col_isindexable is null ) then 0 else c.col_isindexable end,
            case when ( c.col_language >= 0 ) then c.col_language else -1 end
		from ((#sphelpcols c
      left outer join dbo.syscomments cm on cm.id = c.col_objectid and cm.number = c.col_id) left outer join dbo.syscomments cn on c.col_dridefid is not null and cn.id = c.col_dridefid)
      left outer join (select distinct FT_COLNAME = scol.name, FT_ID = sdep.number from dbo.syscolumns scol, dbo.sysdepends sdep where
                       scol.colid = sdep.depnumber and
                       sdep.deptype = 1 and
                       scol.id = @objid and
                       sdep.depid = @objid and
                       ColumnProperty(sdep.id, scol.name, N'IsTypeForFullTextBlob') = 1) as d on c.col_id = d.FT_ID
		order by c.col_name
	end

go
/* End sp_MShelpcolumns */

/*******************************************************************************/
print N''
print N'Creating sp_MShelpindex'
print N''
go
create procedure sp_MShelpindex
@tablename nvarchar(517), @indexname nvarchar(258) = null, @flags int = null
as
   /*** @flags added for DaVinci uses.  If the bit isn't set, use 6.5 ***/
   /*** sp_MShelpindex '%s', null, 1                                  ***/




	create table #tempID
	   (
      cName  nvarchar(132) COLLATE database_default NOT NULL,      /* Index name */
      cInx1  int, cInx2  int, cInx3  int, cInx4  int, cInx5  int, cInx6  int, cInx7  int, cInx8  int,
      cInx9  int, cInx10 int, cInx11 int, cInx12 int, cInx13 int, cInx14 int, cInx15 int, cInx16 int,   /* 1 if DESC  */
      cC1  int, cC2  int, cC3  int, cC4  int, cC5  int, cC6  int, cC7  int, cC8  int,
      cC9  int, cC10 int, cC11 int, cC12 int, cC13 int, cC14 int, cC15 int, cC16 int   /* 1 if Computed column  */
      )

   create table #tempID2
      (
      cName     nvarchar(132) COLLATE database_default NOT NULL,      /* Index name */
      cInx      int,                                  /* Combined info */
      cComputed int                                   /* 1 if on computed column(s) */
      )

   /* @flags is for daVinci */
   if (@flags is null)
      select @flags = 0

   set nocount on
   insert #tempID
      select i.name,
      indexkey_property(object_id(@tablename), i.indid, 1, N'isdescending'),
      indexkey_property(object_id(@tablename), i.indid, 2, N'isdescending'),
      indexkey_property(object_id(@tablename), i.indid, 3, N'isdescending'),
      indexkey_property(object_id(@tablename), i.indid, 4, N'isdescending'),
      indexkey_property(object_id(@tablename), i.indid, 5, N'isdescending'),
      indexkey_property(object_id(@tablename), i.indid, 6, N'isdescending'),
      indexkey_property(object_id(@tablename), i.indid, 7, N'isdescending'),
      indexkey_property(object_id(@tablename), i.indid, 8, N'isdescending'),
      indexkey_property(object_id(@tablename), i.indid, 9, N'isdescending'),
      indexkey_property(object_id(@tablename), i.indid, 10, N'isdescending'),
      indexkey_property(object_id(@tablename), i.indid, 11, N'isdescending'),
      indexkey_property(object_id(@tablename), i.indid, 12, N'isdescending'),
      indexkey_property(object_id(@tablename), i.indid, 13, N'isdescending'),
      indexkey_property(object_id(@tablename), i.indid, 14, N'isdescending'),
      indexkey_property(object_id(@tablename), i.indid, 15, N'isdescending'),
      indexkey_property(object_id(@tablename), i.indid, 16, N'isdescending'),
      columnproperty(object_id(@tablename), index_col(@tablename, i.indid, 1), N'IsComputed'),
      columnproperty(object_id(@tablename), index_col(@tablename, i.indid, 2), N'IsComputed'),
      columnproperty(object_id(@tablename), index_col(@tablename, i.indid, 3), N'IsComputed'),
      columnproperty(object_id(@tablename), index_col(@tablename, i.indid, 4), N'IsComputed'),
      columnproperty(object_id(@tablename), index_col(@tablename, i.indid, 5), N'IsComputed'),
      columnproperty(object_id(@tablename), index_col(@tablename, i.indid, 6), N'IsComputed'),
      columnproperty(object_id(@tablename), index_col(@tablename, i.indid, 7), N'IsComputed'),
      columnproperty(object_id(@tablename), index_col(@tablename, i.indid, 8), N'IsComputed'),
      columnproperty(object_id(@tablename), index_col(@tablename, i.indid, 9), N'IsComputed'),
      columnproperty(object_id(@tablename), index_col(@tablename, i.indid, 10), N'IsComputed'),
      columnproperty(object_id(@tablename), index_col(@tablename, i.indid, 11), N'IsComputed'),
      columnproperty(object_id(@tablename), index_col(@tablename, i.indid, 12), N'IsComputed'),
      columnproperty(object_id(@tablename), index_col(@tablename, i.indid, 13), N'IsComputed'),
      columnproperty(object_id(@tablename), index_col(@tablename, i.indid, 14), N'IsComputed'),
      columnproperty(object_id(@tablename), index_col(@tablename, i.indid, 15), N'IsComputed'),
      columnproperty(object_id(@tablename), index_col(@tablename, i.indid, 16), N'IsComputed')
      from dbo.sysindexes i
      where id = object_id(@tablename) and i.indid > 0 and i.indid < 255
      and (@indexname is null or i.name = @indexname)
      and (indexkey_property(object_id(@tablename), i.indid, 1, N'isdescending') is not null)
      and (i.name is not null)
      order by i.indid

      /* Construct the bit */
      declare @idx int, @isComputed int
      declare @Name nvarchar(132)
      declare @Inx_1 int, @Inx_2 int, @Inx_3 int, @Inx_4 int, @Inx_5 int, @Inx_6 int, @Inx_7 int, @Inx_8 int
      declare @Inx_9 int, @Inx_10 int, @Inx_11 int, @Inx_12 int, @Inx_13 int, @Inx_14 int, @Inx_15 int, @Inx_16 int
      declare @C_1 int, @C_2 int, @C_3 int, @C_4 int, @C_5 int, @C_6 int, @C_7 int, @C_8 int
      declare @C_9 int, @C_10 int, @C_11 int, @C_12 int, @C_13 int, @C_14 int, @C_15 int, @C_16 int
      declare hC cursor global for select * from #tempID
      open hC
      fetch next from hC into @Name, @Inx_1, @Inx_2, @Inx_3, @Inx_4, @Inx_5, @Inx_6, @Inx_7, @Inx_8,
                              @Inx_9, @Inx_10, @Inx_11, @Inx_12, @Inx_13, @Inx_14, @Inx_15, @Inx_16,
                              @C_1, @C_2, @C_3, @C_4, @C_5, @C_6, @C_7, @C_8,
                              @C_9, @C_10, @C_11, @C_12, @C_13, @C_14, @C_15, @C_16
      while (@@FETCH_STATUS = 0)
         begin
         /* descending? */
         select @idx = 0x0000
         select @idx = (case when (@Inx_1 = 1) then @idx | 0x0001 else @idx end), @idx = (case when (@Inx_2 = 1) then @idx | 0x0002 else @idx end), @idx = (case when (@Inx_3 = 1) then @idx | 0x0004 else @idx end), @idx = (case when (@Inx_4 = 1) then @idx | 0x0008 else @idx end), @idx = (case when (@Inx_5 = 1) then @idx | 0x0010 else @idx end), @idx = (case when (@Inx_6 = 1) then @idx | 0x0020 else @idx end), @idx = (case when (@Inx_7 = 1) then @idx | 0x0040 else @idx end), @idx = (case when (@Inx_8 = 1) then @idx | 0x0080 else @idx end),
                @idx = (case when (@Inx_9 = 1) then @idx | 0x0100 else @idx end), @idx = (case when (@Inx_10 = 1) then @idx | 0x0200 else @idx end), @idx = (case when (@Inx_11 = 1) then @idx | 0x0400 else @idx end), @idx = (case when (@Inx_12 = 1) then @idx | 0x0800 else @idx end), @idx = (case when (@Inx_13 = 1) then @idx | 0x1000 else @idx end), @idx = (case when (@Inx_14 = 1) then @idx | 0x2000 else @idx end), @idx = (case when (@Inx_15 = 1) then @idx | 0x4000 else @idx end), @idx = (case when (@Inx_16 = 1) then @idx | 0x8000 else @idx end)
         select @isComputed = 0
         select @isComputed = (case when (@C_1 = 1) then @isComputed | 1 else @isComputed end), @isComputed = (case when (@C_2 = 1) then @isComputed | 1 else @isComputed end), @isComputed = (case when (@C_3 = 1) then @isComputed | 1 else @isComputed end), @isComputed = (case when (@C_4 = 1) then @isComputed | 1 else @isComputed end), @isComputed = (case when (@C_5 = 1) then @isComputed | 1 else @isComputed end), @isComputed = (case when (@C_6 = 1) then @isComputed | 1 else @isComputed end), @isComputed = (case when (@C_7 = 1) then @isComputed | 1 else @isComputed end), @isComputed = (case when (@C_8 = 1) then @isComputed | 1 else @isComputed end),
                @isComputed = (case when (@C_9 = 1) then @isComputed | 1 else @isComputed end), @isComputed = (case when (@C_10 = 1) then @isComputed | 1 else @isComputed end), @isComputed = (case when (@C_11 = 1) then @isComputed | 1 else @isComputed end), @isComputed = (case when (@C_12 = 1) then @isComputed | 1 else @isComputed end), @isComputed = (case when (@C_13 = 1) then @isComputed | 1 else @isComputed end), @isComputed = (case when (@C_14 = 1) then @isComputed | 1 else @isComputed end), @isComputed = (case when (@C_15 = 1) then @isComputed | 1 else @isComputed end), @isComputed = (case when (@C_16 = 1) then @isComputed | 1 else @isComputed end)
         insert #tempID2 select @Name, @idx, @isComputed
         fetch next from hC into @Name, @Inx_1, @Inx_2, @Inx_3, @Inx_4, @Inx_5, @Inx_6, @Inx_7, @Inx_8,
                                 @Inx_9, @Inx_10, @Inx_11, @Inx_12, @Inx_13, @Inx_14, @Inx_15, @Inx_16,
                                 @C_1, @C_2, @C_3, @C_4, @C_5, @C_6, @C_7, @C_8,
                                 @C_9, @C_10, @C_11, @C_12, @C_13, @C_14, @C_15, @C_16
         end
      close hC
      deallocate hC

	set nocount off
   if (@flags <> 0)
   begin
   /* daVinci is calling */
      select i.name, i.status, i.indid, i.OrigFillFactor,
      IndCol1 = index_col(@tablename, i.indid, 1),
      IndCol2 = index_col(@tablename, i.indid, 2),
      IndCol3 = index_col(@tablename, i.indid, 3),
      IndCol4 = index_col(@tablename, i.indid, 4),
      IndCol5 = index_col(@tablename, i.indid, 5),
      IndCol6 = index_col(@tablename, i.indid, 6),
      IndCol7 = index_col(@tablename, i.indid, 7),
      IndCol8 = index_col(@tablename, i.indid, 8),
      IndCol9 = index_col(@tablename, i.indid, 9),
      IndCol10 = index_col(@tablename, i.indid, 10),
      IndCol11 = index_col(@tablename, i.indid, 11),
      IndCol12 = index_col(@tablename, i.indid, 12),
      IndCol13 = index_col(@tablename, i.indid, 13),
      IndCol14 = index_col(@tablename, i.indid, 14),
      IndCol15 = index_col(@tablename, i.indid, 15),
      IndCol16 = index_col(@tablename, i.indid, 16)
      , SegName = s.groupname
      , FullTextKey = IndexProperty(object_id(@tablename), i.name, N'IsFulltextKey')
      , Descending = t.cInx
      , Computed = t.cComputed
      , IsTable = OBJECTPROPERTY(object_id(@tablename), N'IsTable')
      from (dbo.sysindexes i inner join
         dbo.sysfilegroups s on
         i.groupid = s.groupid ), #tempID2 t
      where id = object_id(@tablename) and i.indid > 0 and i.indid < 255 and
      (@indexname is null or i.name = @indexname) and
      (INDEXPROPERTY(object_id(@tablename), i.name, N'IsStatistics') <> 1) and
      (INDEXPROPERTY(object_id(@tablename), i.name, N'IsAutoStatistics') <> 1) and
      (INDEXPROPERTY(object_id(@tablename), i.name, N'IsHypothetical') <> 1) and
      i.name = t.cName
      order by i.indid
   end else begin
      /* select (case when (i.status & 0x0040) != 0 then substring(i.name, 9, (datalength(i.name)/2)-17) else i.name end), i.status, i.indid, i.OrigFillFactor, */
      select i.name, i.status, i.indid, i.OrigFillFactor,
      IndCol1 = index_col(@tablename, i.indid, 1),
      IndCol2 = index_col(@tablename, i.indid, 2),
      IndCol3 = index_col(@tablename, i.indid, 3),
      IndCol4 = index_col(@tablename, i.indid, 4),
      IndCol5 = index_col(@tablename, i.indid, 5),
      IndCol6 = index_col(@tablename, i.indid, 6),
      IndCol7 = index_col(@tablename, i.indid, 7),
      IndCol8 = index_col(@tablename, i.indid, 8),
      IndCol9 = index_col(@tablename, i.indid, 9),
      IndCol10 = index_col(@tablename, i.indid, 10),
      IndCol11 = index_col(@tablename, i.indid, 11),
      IndCol12 = index_col(@tablename, i.indid, 12),
      IndCol13 = index_col(@tablename, i.indid, 13),
      IndCol14 = index_col(@tablename, i.indid, 14),
      IndCol15 = index_col(@tablename, i.indid, 15),
      IndCol16 = index_col(@tablename, i.indid, 16)
      , SegName = s.groupname
      , FullTextKey = IndexProperty(object_id(@tablename), i.name, N'IsFulltextKey')
      , Descending = t.cInx
      , Computed = t.cComputed
      , IsTable = OBJECTPROPERTY(object_id(@tablename), N'IsTable')
      from (dbo.sysindexes i inner join
         dbo.sysfilegroups s on
         i.groupid = s.groupid ), #tempID2 t
      where id = object_id(@tablename) and i.indid > 0 and i.indid < 255
      and (@indexname is null or i.name = @indexname) and
      i.name = t.cName
      order by i.indid
      /* order by i.name */
   end

go
/* End sp_MShelpindex */

/************* DUMP THE TRANSACTION LOG **************************************/
/* Comment this out if you don't want your log dumped.  If you rerun this    */
/* script periodically, you will run out of transaction log space.           */
print N''
print N'Dumping transaction log...'
print N''
go
dump tran master with no_log
go
/************* END DUMP THE TRANSACTION LOG **********************************/

/*******************************************************************************/
print N''
print N'Creating sp_MShelptype'
print N''
go
create procedure sp_MShelptype
@typename nvarchar(517) = null, @flags nvarchar(10) = null
as

	/* Need a temp table so we can ownerqualify nonNULL rules/defaults. */
	create table #sphelptype (
		dt_xusertype   int  NULL,
		dt_basetype    nvarchar(128) COLLATE database_default NULL,
		dt_rul         int  NULL,
		dt_def         int  NULL,

		dt_rulowner    nvarchar(128) COLLATE database_default NULL,
		dt_rulname     nvarchar(128) COLLATE database_default NULL,
		dt_defowner    nvarchar(128) COLLATE database_default NULL,
		dt_defname     nvarchar(128) COLLATE database_default NULL,
		dt_flags       int  NULL
	)

	if (@typename = N'?')
	begin
		print N''
		print N'Usage:  sp_MShelptype @typeename = null, @flags nvarchar(10) = null'
		print N' where @flags is either:'
		print N' sdt		= look in system datatypes'
		print N' uddt  	= look in user defined datatypes'
		print N' null	= look wherever its found'
		print N''
		return 0
	end

	/* Catch typos... */
	if (@flags is not null and @flags not in (N'sdt', N'uddt'))
		select @flags = null

	/* Find out what type we're gonna be looking in, if they gave us a name. */
	if (@typename is not null)
	begin
		declare @xusertype int
		select @xusertype = xusertype from dbo.systypes where name = @typename
		if (@xusertype is not null)
		begin
			if (@xusertype < 257)
			begin
				if (@flags is null)
					select @flags = N'sdt'
				if (@flags != N'sdt')
					select @xusertype = null
			end else begin
				if (@flags is null)
					select @flags = N'uddt'
				if (@flags != N'uddt')
					select @xusertype = null
			end
		end
		if (@xusertype is null)
		begin
			RAISERROR (15001, -1, -1, @typename)
			return 1
		end
	end

	/* Now go get the info, depending on the type they gave us. */
	if (@flags is null or @flags = N'sdt')
	begin
		/* Exclude the 'xxxxn' dblib-specific nullable types, and hardcode a check for variable length and numeric usertypes. */
      /* 7.0 ifvarlen_max returns length for all the datatypes */
		select 	SystemDatatypeName = t.name,
				ifvarlen_max = y.length,
					-- timestamp allows nulls even though the system tables say it doesn't.
				allownulls = case when t.name in (N'timestamp') then 1 else t.allownulls end,
				isnumeric = case when t.name in (N'decimal', N'numeric') then 1 else 0 end,
				allowidentity = case when t.name in (N'decimal', N'int', N'numeric', N'smallint', N'tinyint', N'bigint') then 1 else 0 end,
            variablelength = t.variable,
            max_len = t.length, prec_len = t.prec,
            collation = t.collation
         from dbo.systypes t, dbo.systypes y
         where t.xusertype < 257 and t.name not in (N'datetimn', N'decimaln', N'floatn', N'intn', N'moneyn', N'numericn') and (@typename is null or t.name = @typename)
         and y.xusertype =* t.xusertype and y.name in ( N'char', N'varchar', N'binary', N'varbinary', N'nchar', N'nvarchar' )
			order by t.name
	end

	if (@flags is null or @flags = N'uddt')
	begin
		set nocount on
		insert #sphelptype (dt_xusertype, dt_basetype, dt_rul, dt_def, dt_flags)
			select t.xusertype,
			(select distinct b.name from dbo.systypes b where b.xtype = t.xtype and b.xusertype < 257 and b.name not in (N'sysname', N'timestamp')),
			t.domain, t.tdefault, 0
			from dbo.systypes t
			where t.xusertype > 256 and (@typename is null or t.name = @typename)

		/* Make a nice, presentable qualified rule/default name for those which are non-null */
      update #sphelptype set dt_defowner = user_name(d.uid)
            from #sphelptype c, dbo.sysobjects d where c.dt_def is not null and d.id = c.dt_def
      update #sphelptype set dt_defname = d.name
            from #sphelptype c, dbo.sysobjects d where c.dt_def is not null and d.id = c.dt_def

      update #sphelptype set dt_rulowner = user_name(r.uid)
            from #sphelptype c, dbo.sysobjects r where c.dt_rul is not null and r.id = c.dt_rul
      update #sphelptype set dt_rulname =  r.name
            from #sphelptype c, dbo.sysobjects r where c.dt_rul is not null and r.id = c.dt_rul

		/* For scripting, set the dt_flags -- these apply to the BASE datatype. */
		update #sphelptype set dt_flags = dt_flags | 0x0001 where dt_basetype in ( N'char', N'varchar', N'binary', N'varbinary', N'nchar', N'nvarchar')
		update #sphelptype set dt_flags = dt_flags | 0x0002 where dt_basetype in (N'numeric', N'decimal')

		set nocount off
		select distinct UserDatatypeName = t.name,
				owner = user_name(t.uid),
				-- The subquery fails if the current db is of a different collation from tempdb.
				-- Also, not user why the subquery is being used in the 1st place
				-- basetypename = (select distinct b.name from dbo.systypes b where b.name = s.dt_basetype),
				basetypename = dt_basetype,
				defaultname = dt_defname,
				rulename = dt_rulname,
				tid = t.xusertype,
				length = case when s.dt_basetype in (N'char', N'varchar', N'binary', N'varbinary', N'nchar', N'nvarchar') then t.length else 0 end,
				nullable = t.allownulls,
				dt_prec = case when s.dt_basetype in (N'numeric', N'decimal') then t.prec else null end,
				dt_scale = case when s.dt_basetype in (N'numeric', N'decimal') then t.scale else null end,
				dt_flags,
				allowidentity = case when (s.dt_basetype in (N'decimal', N'int', N'numeric', N'smallint', N'tinyint', N'bigint') and t.scale = 0) then 1 else 0 end,
            variablelength = t.variable,
            /* char count for string datatype, byte count for others */
				maxlen = case when s.dt_basetype in (N'char', N'varchar', N'binary', N'varbinary', N'nchar', N'nvarchar') then t.prec else t.length end,
            defaultowner = dt_defowner,
            ruleowner = dt_rulowner,
            collation = t.collation
			from dbo.systypes t, #sphelptype s
			where t.xusertype > 256 and (@typename is null or t.name = @typename)
				and dt_xusertype = t.xusertype
			order by t.name
	end
go
/* End sp_MShelptype */

/*******************************************************************************/
print N''
print N'Creating sp_MSdependencies'
print N''
go

create procedure sp_MSdependencies
@objname nvarchar(517) = null, @objtype int = null, @flags int = 0x01fd, @objlist nvarchar(128) = null, @intrans int = null
as
    set deadlock_priority low
    
	create table #t1 (
		tid				int				NULL,
		ttype			smallint		NULL,
		tcat			smallint		NULL,
		pid				int				NULL,
		ptype			smallint		NULL,
		pcat			smallint		NULL,
		bDone			smallint		NULL
	)
	create table #t2 (
		tid				int				NULL,
		ttype			smallint		NULL,
		tcat			smallint		NULL,
		pid				int				NULL,
		ptype			smallint		NULL,
		pcat			smallint		NULL,
		bDone			smallint		NULL
	)
	create table #tempudt (
		dtype			int				NOT NULL
	)

	/* Worktables we'll use for optimization. */
	create table #t3 (
		tid				int				NOT NULL
	)
	create table #t4 (
		tid				int				NOT NULL
	)
	/* create clustered index #ci_t3 on #t3(tid) with allow_dup_row */
	/* create clustered index #ci_t4 on #t4(tid) with allow_dup_row */
	create clustered index #ci_t3 on #t3(tid)
	create clustered index #ci_t4 on #t4(tid)
	create table #temptrig(
		id				int				NOT NULL,
		deltrig			int				NOT NULL,
		sysstat			smallint		NOT NULL,
		category		int				NOT NULL
	)
	/* create clustered index #ci_temptrig on #temptrig (deltrig) with allow_dup_row */
	create clustered index #ci_temptrig on #temptrig (deltrig)

   /* 8.0 The new UDF is taking 0x0001, and we have to re-assign UDDT */
	if (@objname = N'?')
	begin
		print N'sp_MSobject_dependencies name = NULL, type = NULL, flags = 0x01fd'
		print N'  name:  name or null (all objects of type)'
		print N'  type:  type number (see below) or null'
		print N'	  if both null, get all objects in database'
		print N'  flags is a bitmask of the following values:'
		print N'	  0x10000  = return multiple parent/child rows per object'
		print N'	  0x20000  = descending return order'
		print N'	  0x40000  = return children instead of parents'
		print N'	  0x80000  = Include input object in output result set'
		print N'	  0x100000 = return only firstlevel (immediate) parents/children'
		print N'	  0x200000 = return only DRI dependencies'
		print N'	  power(2, object type number(s))  to return in results set:'
		print N'		  0 (1  	- 0x0001)	 - UDF'
		print N'		  1 (2  	- 0x0002)	 - system tables or MS-internal objects'
		print N'		  2 (4  	- 0x0004)	 - view'
		print N'		  3 (8  	- 0x0008)	 - user table'
		print N'		  4 (16		- 0x0010)	 - procedure'
		print N'		  5 (32		- 0x0020)	 - log'
		print N'		  6 (64 	- 0x0040)	 - default'
		print N'		  7 (128	- 0x0080)	 - rule'
		print N'		  8 (256	- 0x0100)	 - trigger'
		print N'		  12 (1024	- 0x0400) - uddt'
		print N'	  shortcuts:'
		print N'		  29	 (0x011c) - trig, view, user table, procedure'
		print N'		  448	(0x00c1) - rule, default, datatype'
		print N'		  4606 (0x11fd) - all but systables/objects'
		print N'		  4607 (0x11ff) - all'
		return 0
	end

	/* If this proc is called in a tight loop, it tends to fill up the log in a small tempdb too fast */
	/* for the trunc. log on chkpt thread to keep up.  So help it out here.                           */
   /* I can do this only if the current login has the proper permission to dump tempdb               */
   /* In order to find out this information, I need to switch to tempdb                              */
	declare @origdb nvarchar(128)
   declare @tempdbName nvarchar(258)
	select @origdb = db_name()
   SELECT @tempdbName = REPLACE(@origdb, N']', N']]')

   /* dump tran only if we are not in a transaction */
   if ( @intrans is null )
      exec (N'if (has_dbaccess(''tempdb'') = 1) begin use tempdb if (permissions() & 0x80 <> 0) dump tran tempdb with no_log use [' + @tempdbName + N'] end')

	/* If they want SQLDMODep_DRIOnly, remove all but usertable objects from @flags */
	if (@flags & 0x200000 <> 0)
		select @flags = (@flags & ~convert(int, 0x05ff)) | power(2, 3)

	if (@objtype in (12, 5, 6, 7))
	begin
		/* Print only, do not raiserror as we may be calling this blindly and this is not a real error. */
		print N'Rules, defaults, and datatypes do not have dependencies.'
		return (0)
	end

	/*
	 * Create #t1 and #t2 as temp object holding areas.  Columns are:
	 *	 tid		- temp object id
	 *	 ttype	 - temp object type
	 *	 pid		- parent or child object id
	 *	 ptype	 - parent or child object type
	 *	 bDone	 - NULL means dependencies not yet evaluated, else nonNULL.
	 */
	declare @curid int, @curcat int, @rowsaffected int
	declare @allobjs int
	declare @delinputobj int
	select @allobjs = 0, @delinputobj = 0, @curid = NULL, @curcat = NULL

	/*
	 * If both name and type are null, this means get every object in the
	 * database matching the specification they passed in.  Otherwise,
	 * find the passed object or all objects of the passed type.  Start off
	 * loading parent info (pid, tid); these will be put into child as needed.
	 * If Objlist is specified we simply load its contents into #t1.
	 */
	if (@objlist is not null)
	begin
		declare @mscategory nvarchar(12)
		select @mscategory = ltrim(str(convert(int, 0x0002)))

		exec(N'insert #t1 (pid, ptype, pcat) select l.objid, l.objtype, o.category &' +  @mscategory +
				N' from ' + @objlist + N' l, dbo.sysobjects o where o.id = l.objid ')
	end else begin
		if (@objname is null and @objtype is null)
		begin
			set nocount on
			select @allobjs = 1
			insert #t1 (pid, ptype, pcat) select o.id, o.sysstat & 0x0f, o.category & 0x0002 from dbo.sysobjects o
				where ((power(2, o.sysstat & 0x0f) & 0x05ff) <> 0) and (OBJECTPROPERTY(o.id, N'IsDefaultCnst') <> 1 and OBJECTPROPERTY(o.id, N'IsRule') <> 1 )
		end else begin
			if (@objname is not null)
			begin
				select @curid = id, @objtype = o.sysstat & 0x0f, @curcat = o.category & 0x0002 from dbo.sysobjects o where id = object_id(@objname)
				if (@curid is null)
				begin
					RAISERROR (15001, -1, -1, @objname)
					return 1
				end
				if (@flags & 0x80000 = 0)
					select @delinputobj = @curid
			end

			set nocount on
			if (@curid is null)
				insert #t1 (pid, ptype, pcat) select o.id, o.sysstat & 0x0f, o.category & 0x0002 from dbo.sysobjects o
					where o.sysstat & 0x0f = @objtype
			else
				insert #t1 (pid, ptype, pcat) values (@curid, @objtype, @curcat)
		end
	end
	/*
	 * All initial objects are loaded as parents/children.  Now we loop, creating
	 * rows of child/parent relationships.  Use #t2 as a temp area for the selects
	 * to simulate recursion; when they find no rows, we're done with this step.
	 *
	 * Note that triggers are weird; they're part of a table definition but can
	 * also reference other tables, so we need to evaluate them both ways.  SQL
	 * Server stores the table for a trigger object as its deltrig; if a trigger
	 * references another table, that relationship is stored in sysdepends.
	 * This peculiarity of triggers requires separating the object-retrieval pass
	 * from the creation-sequence pass (below).  Also, the fact that trigger tables
	 * are stored in a non-indexed column (deltrig) requires us to use a worktable
	 * if we're returning triggers, so we don't continually tablescan sysobjects.
	 */

	if (@flags & power(2, 8) != 0)
		insert #temptrig select d.id, d.deltrig, d.sysstat, d.category from dbo.sysobjects d where OBJECTPROPERTY(d.id, N'IsTrigger') = 1

	while (select count(*) from #t1 where bDone is null) > 0
	begin
		/*
		 * Remove Microsoft-internal or other system objects from #t1, unless
		 * @flags specified including system tables.  We do this here so that
		 * cascaded system dependencies are not included unless specifically
		 * requested.  For other restrictions, we wait until below so that all
		 * cascaded object types are fully evaluated.
		 */
		if (@flags & power(2, 1) = 0)
			delete #t1 where ttype = 1 or tcat = 0x0002 or pcat = 0x0002

		if (@flags & 0x40000 != 0)
		begin
			if (@flags & 0x200000 = 0) begin
				/* Table --> Triggers */
				if (@flags & power(2, 8) != 0)
					insert #t2 (tid, ttype, tcat, pid, ptype, pcat)
						select distinct t.pid, t.ptype, t.pcat, o.id, o.sysstat & 0x0f, o.category & 0x0002 from #t1 t, #temptrig o
							where t.bDone is null and t.ptype = 3 and o.deltrig = t.pid

				/* Object --> sysdepends children */
				insert #t2 (tid, ttype, tcat, pid, ptype, pcat)
					select distinct t.pid, t.ptype, t.pcat, d.id, o.sysstat & 0x0f, o.category & 0x0002
					from #t1 t, dbo.sysdepends d, dbo.sysobjects o
					where t.bDone is null and d.depid = t.pid and d.id = o.id
			end

			/* Object --> sysreferences children (FK tables referencing this one) */
			insert #t2 (tid, ttype, tcat, pid, ptype, pcat)
				select distinct t.pid, t.ptype, t.pcat, r.fkeyid, o.sysstat & 0x0f, o.category & 0x0002
				from #t1 t, dbo.sysreferences r, dbo.sysobjects o
				where t.bDone is null and r.rkeyid = t.pid and r.fkeyid = o.id
		end else begin
			if (@flags & 0x200000 = 0) begin
				/* Trigger --> Table */
				if (@flags & power(2, 3) != 0)
					insert #t2 (tid, ttype, tcat, pid, ptype, pcat)
						select distinct t.pid, t.ptype, t.pcat, o.deltrig, u.sysstat & 0x0f, u.category & 0x0002
							  from #t1 t, dbo.sysobjects o, dbo.sysobjects u
							where t.bDone is null and t.ptype = 8 and o.id = t.pid and o.deltrig != 0 and u.id = o.deltrig

				/* Object --> sysdepends parents */
				insert #t2 (tid, ttype, tcat, pid, ptype, pcat)
					select distinct t.pid, t.ptype, t.pcat, d.depid, o.sysstat & 0x0f, o.category & 0x0002
					from #t1 t, dbo.sysdepends d, dbo.sysobjects o
					where t.bDone is null and d.id = t.pid and d.depid = o.id
			end

			/* Object --> sysreferences parents (PK/UQ tables referenced by one) */
			insert #t2 (tid, ttype, tcat, pid, ptype, pcat)
				select distinct t.pid, t.ptype, t.pcat, r.rkeyid, o.sysstat & 0x0f, o.category & 0x0002
				from #t1 t, dbo.sysreferences r, dbo.sysobjects o
				where t.bDone is null and r.fkeyid = t.pid and r.rkeyid = o.id
		end

		/*
		 * We have this generation of parents in #t2, so clear the current
		 * child generation's bDone flags.  Then insert from #t2; the current
		 * parent generation becomes the next loop's child generation, with
		 * bDone = null until next loop's dependencies are selected.
		 */
		update #t1 set bDone = 1
		insert #t1 select * from #t2 where #t2.tid not in
			(select tid from #t1 where #t1.tid = #t2.tid and #t1.pid = #t2.pid)
		truncate table #t2

		/* If they only want one level, we're done.	*/
		if (@flags & 0x100000 <> 0)
			update #t1 set bDone = 1
	end

	/*
	 * The inner loop above did not put parents with no parents into the
	 * child (tid) list.  Do that now, then remove all rows where tid is
	 * NULL, because these were initial objects which now have a tid row.
	 * Just in case, remove self-refs from #t1, and also remove rows from #t1
	 * with NULL pid if a row exists for that tid where the pid is nonNULL.
	 * Avoid nested self-joins by using worktables.
	 */
	truncate table #t3
	insert #t3 select tid from #t1 where tid is not null
		and tid <> pid				-- make sure self-refs with no other refs go in child list
	/* update statistics #t3 #ci_t3 */
	insert #t1 (tid, ttype, tcat, bDone) select distinct pid, ptype, pcat, 0 from #t1 t
		where t.pid is not null and not exists (select * from #t3 where tid = t.pid)
	delete #t1 where tid = pid		-- now remove self-refs

	/*
	 * Because triggers can go in both directions, we'll need to check for
	 * circular dependencies on parent evaluation.  Since any tables referenced
	 * by the trigger must exist before the trigger can be created, remove rows
	 * where the trigger is the parent.
	 */
	if (@flags & 0x40000 = 0)
		delete #t1 where ptype = 8

	truncate table #t3
	insert #t3 select tid from #t1 where tid is not null and pid is not null
	/* update statistics #t3 #ci_t3 */
	delete #t1 where #t1.tid is null or #t1.tid = #t1.pid
		or (#t1.pid is null and exists (select * from #t3 where tid = #t1.tid))

	/*
	 * If we're to get all objects, get all UDDTs (which aren't in dbo.sysobjects)
	 * and Rules/Defaults, assuming we're returning those types.
	 */
	if (@allobjs <> 0)
	begin
		if (@flags & power(2, 12) != 0)
			insert #tempudt
				select xusertype from dbo.systypes where xusertype > 256
		if (@flags & (power(2, 7) | power(2, 6)) != 0)
			insert #t2 (tid, ttype, tcat)
				select id, sysstat & 0x0f, 0 from dbo.sysobjects
				where (OBJECTPROPERTY(id, N'IsRule') = 1 or OBJECTPROPERTY(id, N'IsDefault') = 1)
				and category & 0x0800 = 0
	end else begin
		/*
		 * Not getting all objects.  Get any datatypes that
		 * are referenced by objects in #t1.  We don't care about specific
		 * datatype dependencies, we just want to know which ones are needed.
		 */
		if (@flags & power(2, 12) != 0)
			insert #tempudt select distinct xusertype from dbo.syscolumns
				where xusertype > 256 and id in (select tid from #t1)

		/*
		 * Load rules and defaults needed by datatypes and other #t1 objects
		 * into #t2.  Don't track specific object dependencies with these;
		 * we just want to know which ones are needed.  For defaults only, eliminate
		 * those which are constraints.
		 */
		if (@flags & power(2, 7) != 0)
		begin
			insert #t2 (tid, ttype, tcat)
				select distinct s.domain, 7, 0 from dbo.systypes s, #tempudt t
					where s.domain != 0 and s.xusertype = t.dtype
						and s.domain not in (select tid from #t1)
			insert #t2 (tid, ttype, tcat)
				select distinct s.domain, 7, 0 from dbo.syscolumns s, #t1 t
					where s.domain != 0 and s.id = t.tid
						and s.domain not in (select tid from #t1)
		end
		if (@flags & power(2, 6) != 0)
		begin
			insert #t2 (tid, ttype, tcat)
				select distinct s.tdefault, 6, 0 from dbo.systypes s, #tempudt t
					where s.tdefault != 0 and s.xusertype = t.dtype
						and s.tdefault not in (select tid from #t1)
						and s.tdefault not in (select id from dbo.sysobjects where category & 0x0800 != 0)
			insert #t2 (tid, ttype, tcat)
				select distinct s.cdefault, 6, 0 from dbo.syscolumns s, #t1 t
					where s.cdefault != 0 and s.id = t.tid
						and s.cdefault not in (select tid from #t1)
						and s.cdefault not in (select id from dbo.sysobjects where category & 0x0800 != 0)
		end
	end		/* Not getting all objects */

	/*
	 * Now that we've got all objects we want, eliminate those we don't
	 * want to return.  If @inputobj and they don't want it returned,
	 * remove it from the table.  Then eliminate object types they don't
	 * want returned.  Make sure that in doing so we retain all parent
	 * objects of the types we do want -- it is possible at this point
	 * that a tid we want has no rows except those with pids we don't want.
	 */
	if (@flags & 0x05ff != 0x05ff or @delinputobj != 0)
	begin
		delete #t1 where @flags & power(2, ttype) = 0 or tid = @delinputobj

		/*
		 * Be sure that the insert does not duplicate rows that will survive the
		 * following delete -- these are rows where the pid is not @delinputobj
		 * and ptype is either null or a type we'll keep (if ptype is null then
		 * pid hasn't been set so no need for more complex checking).
		 */
		insert #t1 (tid, ttype, tcat) select distinct tid, ttype, tcat from #t1
			where (@flags & power(2, ptype) = 0 or pid = @delinputobj)
				and tid not in (select tid from #t1 where ptype is null or
					(pid != @delinputobj and @flags & power(2, ptype) != 0))
		delete #t1 where @flags & power(2, ptype) = 0 or pid = @delinputobj
	end

	/*
	 * To determine creation order, find all objects which are not yet bDone
	 * and have no parents or whose parents are all bDone, and set their bDone
	 * to the next @curid.  This will leave bDone as the ascending order in
	 * which objects must be created (topological sort).  Again, use worktables
	 * to remove nested self-joins.
	 */
	update #t1 set bDone = 0
	select @curid = 1, @rowsaffected = 1
	while (@rowsaffected <> 0)
	begin
		if (@flags & 0x40000 != 0) begin
			truncate table #t3
			insert #t3 select pid from #t1 where pid is not null and bDone = 0
			/* update statistics #t3 #ci_t3 */
			update #t1 set bDone = @curid where bDone = 0 and tid not in (select tid from #t3)
		end else begin
			truncate table #t3
			truncate table #t4
			insert #t3 select tid from #t1 where bDone = 0				/* Parents not yet done */
			/* update statistics #t3 #ci_t3 */
			insert #t4 select tid from #t1								/* TIDs with (parents not yet done) */
				where pid is not null and pid in (select tid from #t3)
			/* update statistics #t4 #ci_t4 */
			update #t1 set #t1.bDone = @curid where #t1.bDone = 0 		/* TIDs who are not (TIDs with (parents not yet done)) */
				and not exists (select * from #t4 where tid = #t1.tid)
		end
		select @rowsaffected = @@rowcount, @curid = @curid + 1
	end

	/* For SQL60 only, we need to check circular dependencies (DRI for tables is the only way to get them). */
	/* This will have occurred if we still have any rows in #t1 where bDone = 0, after the above loop. */
	/*
	 * At this point, these are indirect (a->b->...->a), and can only be created by:
	 * 	create table a; create table b ref a; alter table a ref b
	 * There is thus no way to create the tables in a single pass.  Further, the ALTER
	 * TABLE B must be done AFTER data has been added (else the PK/FK will fail).
	 * Therefore, the two-step model of
	 *  - Create tables (and other objects)
	 *  - Transfer data
	 * does not work, so assume anyone doing this will do it in three passes (e.g. ScriptTransfer):
	 *  - Create tables (and other objects) but no references (also defer some indexing, for perfomance)
	 *  - Transfer data
	 *  - Create references (and deferred indexing)
	 * and just set bDone for everything remaining to @curid.
	 */
	if exists (select * from #t1 where bDone = 0) begin
		--select "Circular Dependencies", object_name(tid) from #t1 where bDone = 0
		--RAISERROR (14300, -1, -1)
		--return 1
		update #t1 set bDone = @curid where bDone = 0
	end

	/*
	 * Finally, return the objects.  Rules/Defaults must be created first so they're returned first,
	 * followed by UDDTs. followed by all other (sysdepends/DRI) dependencies.  @curid is the bDone
	 * value; we need to increment the #t1 value so our multi-result-set is in the proper sequence.
	 * Of course, these never have parents, so don't return them if asking for children.
	 */
	if (@flags & 0x40000 = 0) begin
		select @curid = 1
		if ((@flags & (power(2, 7) | power(2, 6)) != 0) and exists (select * from #t2)) begin
			update #t1 set bDone = bDone + 1
			select distinct oType = power(2, o.sysstat & 0x0f), oRuleDefName = o.name, oOwner = user_name(o.uid), oSequence = convert(smallint, @curid)
				from dbo.sysobjects o, #t2 t
				where o.id = t.tid
				order by power(2, o.sysstat & 0x0f), o.name
			select @curid = @curid + 1
		end
		if ((@flags & power(2, 12) != 0) and exists (select * from #tempudt)) begin
			update #t1 set bDone = bDone + 1
			select distinct oType = power(2, 12), oUDDTName = c.name, oOwner = user_name(c.uid), oSequence = convert(smallint, @curid)
				from dbo.systypes c, #tempudt t, dbo.sysobjects p
				where c.xusertype = t.dtype
				order by c.name
			select @curid = @curid + 1
		end
	end

	/*
	 * Select dependency-style objects, returning parents if desired.
	 * Normally sorting is in terms of who must be created first, i.e. ascending:  parent-->child-->grandchild.
	 * Descending order (child-->parent-->grandparent) would be used for a graphical-dependencies evaluator showing
	 * the parents.  Therefore we invert bDone if descending sort.  bDone is 1-based; min + max - bDone gives inversion.
	 * Note:  Always return at least this empty set.
	 */
	if (@flags & 0x20000 != 0) begin
		select @curid = max(bDone) + min(bDone) from #t1
		update #t1 set bDone = convert(smallint, @curid) - bDone
	end
	if (@flags & 0x10000 != 0)
		select distinct oType = power(2, o.sysstat & 0x0f), oObjName = o.name, oOwner = user_name(o.uid),
/*				RelType = power(2, p.sysstat & OBJTYPE_BITS), RelName = p.name, RelOwner = user_name(p.uid), */
				RelType = case when (p.name is not null) then power(2, p.sysstat & 0x0f) else 0 end, RelName = p.name, RelOwner = user_name(p.uid),
				oSequence = t.bDone
			from dbo.sysobjects o, dbo.sysobjects p, #t1 t
			where o.id = t.tid and p.id =* t.pid
			order by t.bDone, power(2, o.sysstat & 0x0f), o.name
	else
		select distinct oType = power(2, o.sysstat & 0x0f), oObjName = o.name, oOwner = user_name(o.uid),
				oSequence = t.bDone
			from dbo.sysobjects o, #t1 t
			where o.id = t.tid
			order by t.bDone, power(2, o.sysstat & 0x0f), o.name

go
/* End sp_MSdependencies */

/************* DUMP THE TRANSACTION LOG **************************************/
/* Comment this out if you don't want your log dumped.  If you rerun this    */
/* script periodically, you will run out of transaction log space.           */
print N''
print N'Dumping transaction log...'
print N''
go
dump tran master with no_log
go
/************* END DUMP THE TRANSACTION LOG **********************************/

/*******************************************************************************/
print N''
print N'Creating sp_MStablespace'
print N''
go

create procedure sp_MStablespace
@name nvarchar(517), @id int = null
as
	declare @rows int, @datasizeused int, @indexsizeused int, @pagesize int
	declare @dbname nvarchar(128)
	select @dbname = db_name()

	if (@id is null)
		select @id = id from dbo.sysobjects where id = object_id(@name) and (OBJECTPROPERTY(id, N'IsTable') = 1)
	if (@id is null)
	begin
		RAISERROR (15009, -1, -1, @name, @dbname)
		return 1
	end

	/* rows */
	SELECT @rows = convert(int, rowcnt)
		FROM dbo.sysindexes
		WHERE indid < 2 and id = @id

	/* data */
	SELECT @datasizeused =
	(SELECT sum(dpages)
	 FROM dbo.sysindexes
	 WHERE indid < 2 and id = @id)
	+
	(SELECT isnull(sum(used), 0)
	 FROM dbo.sysindexes
	 WHERE indid = 255 and id = @id)

   /* Do not consider 2 < indid < 255 rows, those are nonclustered indices, and the space used by them are included by indid = 0(table) */
   /* or indid = 1(clustered index) already.  indid = 0(table) and = 1(clustered index) are mutual exclusive */
	/* index */
	SELECT @indexsizeused =
	(SELECT sum(used)
	 FROM dbo.sysindexes
	 WHERE indid in (0, 1, 255) and id = @id)
	 - @datasizeused

	/* Pagesize on this server (sysindexes stores size info in pages) */
	select @pagesize = v.low / 1024 from master..spt_values v where v.number=1 and v.type=N'E'

	select Rows = @rows, DataSpaceUsed = @datasizeused * @pagesize, IndexSpaceUsed = @indexsizeused * @pagesize
go

/* End sp_MStablespace */

/*******************************************************************************/
print N''
print N'Creating sp_MSindexspace'
print N''
go

CREATE PROCEDURE sp_MSindexspace
	@tablename nvarchar(517), @index_name nvarchar(258) = NULL
AS
BEGIN

    CREATE TABLE #IndexSizeTemp (
		IndexID    tinyint  NOT NULL,
		IndexName  nvarchar(128) COLLATE database_default  NOT NULL,
		IndexSize  int  NOT NULL,
		Comments   nvarchar(28)  COLLATE database_default NOT NULL
	)

  DECLARE @table_id int
  DECLARE @index_id int
  DECLARE @msg nvarchar(2000)
  DECLARE @pagesize int
  select @pagesize = v.low / 1024 from master..spt_values v where v.number=1 and v.type=N'E'

  /* Make sure @tablename is local to the current database */

  /* Make sure that @tablename and @index_name exist, we are checking table instead of UserTable */
  SELECT @table_id = id
  FROM dbo.sysobjects
  WHERE (id = object_id(@tablename))
    AND ((OBJECTPROPERTY(id, N'IsTable') = 1) OR (OBJECTPROPERTY(id, N'IsView') = 1))
  IF (@table_id is NULL)
  BEGIN
    RAISERROR (15001, -1, -1, @tablename)
    RETURN(1)
  END
  IF (@index_name is not NULL)
  BEGIN
    SELECT @index_id = indid
    FROM dbo.sysindexes
    WHERE (name = @index_name)
      AND (id = object_id(@tablename))
    IF (@index_id is NULL)
    BEGIN
      SELECT @msg = @tablename + N'.' + @index_name
      RAISERROR (15001, -1, -1, @msg)
      RETURN(1)
    END
  END
  /* Ok, we're good to go */
  IF (user_id() = 1)
    CHECKPOINT
  IF (@index_name is NULL)
  BEGIN
    INSERT INTO #IndexSizeTemp
    SELECT indid, name, 0, N''
    FROM dbo.sysindexes
    WHERE (id = object_id(@tablename))
      AND ((indid > 0) AND (indid < 255))
    UPDATE #IndexSizeTemp
    SET IndexSize = used * @pagesize,
        Comments = N'(None)'
    FROM dbo.sysindexes si, #IndexSizeTemp ist
    WHERE (id = object_id(@tablename))
      AND (indid > 1) AND (indid < 255)
      AND (si.indid = ist.IndexID)
    UPDATE #IndexSizeTemp
    SET IndexSize = (used - dpages - isnull((SELECT sum(used)
                                             FROM dbo.sysindexes
                                             WHERE (indid > 1) AND (indid < 255)
                                               AND (id = object_id(@tablename))), 0)) * @pagesize,
        Comments = N'Size excludes actual data.'
    FROM dbo.sysindexes si, #IndexSizeTemp ist
    WHERE (id = object_id(@tablename))
      AND (indid = 1)
      AND (si.indid = ist.IndexID)
    SELECT N'Index ID' = IndexID, N'Index Name' = IndexName, N'Size (KB)' = IndexSize, Comments
    FROM #IndexSizeTemp
    ORDER BY IndexID
    DROP TABLE #IndexSizeTemp
  END
  ELSE
  BEGIN
    DECLARE @indid int
    SELECT @indid = indid
    FROM dbo.sysindexes
    WHERE (id = object_id(@tablename))
      AND (name = @index_name)
    /* The non-clustered index case */
    IF ((@indid > 1) AND (@indid < 255))
    BEGIN
      SELECT N'Size (KB)' = used * @pagesize
      FROM dbo.sysindexes
      WHERE (id = object_id(@tablename))
        AND (name = @index_name)
      RETURN(0)
    END
    /* The clustered index case */
    IF (@indid = 1)
    BEGIN
      SELECT N'Size (KB)' =
             (used - dpages - isnull((SELECT sum(used)
                                      FROM dbo.sysindexes
                                      WHERE (indid > 1) AND (indid < 255)
                                        AND (id = object_id(@tablename))
                                        AND (name = @index_name)), 0)) * @pagesize
      FROM dbo.sysindexes
      WHERE (id = object_id(@tablename))
        AND (name = @index_name)
    END
  END
  RETURN(0)
END
go
/* End sp_MSindexspace */

/*-----------------------------------------------------*/
/*-----------------------------------------------------*/
print N''
print N'Creating sp_MStablerefs'
print N''
go

create procedure sp_MStablerefs
	@tablename nvarchar(517),					
	@type nvarchar(20) = N'actualtables',		
	@direction nvarchar(20) = N'primary',		
	@reftable nvarchar(517) = null,			
   @flags int = 0
as
   /* tablename: table whose references are being evaluated */
   /* type     : '[actual | all][tables | keys | keycols]'; all candidates, or only those actually referenced */
   /* direction: look for references from @tablename to 'primary' table(s), or to @tablename from 'foreign' table(s) */
   /* reftable : limit scope to this table, if non-null */
   /*** @flags added for DaVinci uses.  If the bit isn't set, use 6.5 ***/
   /*** sp_MStablerefs '%s', null, 'both'                             ***/

	create table #sprefs (
		id					int				NOT NULL, 	/* id of reftable */
		constid				int				NULL, 		/* id of key */
		referenced			bit				NOT NULL	/* well, is it? */
	)

	/* @flags is for daVinci */
	if (@flags is null)
		select @flags = 0

	if (@tablename = N'?') begin
		PRINT N''
		PRINT N'sp_MStablerefs:'
		PRINT N'@tablename nvarchar(257),					/* table whose references are being evaluated */'
		PRINT N'@type nvarchar(20) = [actualtables],		/* [[actual | all][tables | keys | keycols]]; all candidates, or only those actually referenced */'
		PRINT N'@direction nvarchar(20) = [primary],		/* look for references from @tablename to [primary] or to @tablename from [foreign], or [both] */'
		PRINT N'@reftable nvarchar(257) = null				/* limit scope to this table, if non-null */'
		return 0
	end

	if (lower(@direction) = N'both') begin
		select
         N'PK_Table' = PKT.name,
         N'FK_Table' = FKT.name,
         N'Constraint' = object_name(r.constid),
			c.status,
			cKeyCol1 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey1)),
			cKeyCol2 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey2)),
			cKeyCol3 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey3)),
			cKeyCol4 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey4)),
			cKeyCol5 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey5)),
			cKeyCol6 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey6)),
			cKeyCol7 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey7)),
			cKeyCol8 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey8)),
			cKeyCol9 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey9)),
			cKeyCol10 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey10)),
			cKeyCol11 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey11)),
			cKeyCol12 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey12)),
			cKeyCol13 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey13)),
			cKeyCol14 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey14)),
			cKeyCol15 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey15)),
			cKeyCol16 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey16)),
			cRefCol1 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey1)),
			cRefCol2 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey2)),	
			cRefCol3 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey3)),
			cRefCol4 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey4)),
			cRefCol5 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey5)),
			cRefCol6 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey6)),
			cRefCol7 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey7)),
			cRefCol8 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey8)),
			cRefCol9 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey9)),
			cRefCol10 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey10)),
			cRefCol11 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey11)),
			cRefCol12 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey12)),
			cRefCol13 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey13)),
			cRefCol14 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey14)),
			cRefCol15 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey15)),
			cRefCol16 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey16)),
			N'PK_Table_Owner' = user_name(PKT.uid),
			N'FK_Table_Owner' = user_name(FKT.uid),
         N'DeleteCascade' = OBJECTPROPERTY( r.constid, N'CnstIsDeleteCascade'),
         N'UpdateCascade' = OBJECTPROPERTY( r.constid, N'CnstIsUpdateCascade')
      from dbo.sysreferences r, dbo.sysconstraints c, dbo.sysobjects PKT, dbo.sysobjects FKT
      where r.constid = c.constid and (@tablename is null or
         (r.rkeyid = object_id(@tablename) or r.fkeyid = object_id(@tablename)))
      and PKT.id = r.rkeyid and FKT.id = r.fkeyid
      return 0
	end /* @direction = 'both' */

	declare @id int, @refid int
	select @id = object_id(@tablename), @refid = object_id(@reftable)
	if (@tablename is not null and @id is null) begin
		RAISERROR (15001, -1, -1, @tablename)
		return 1
	end
	if (@reftable is not null and @refid is null) begin
		RAISERROR (15001, -1, -1, @reftable)
		return 1
	end

	declare @dotables bit, @doall bit, @doprimary bit, @docols bit
	select 	@dotables = case when (@type like N'allt%' or @type like N'actualt%') then 1 else 0 end,
			@doall = case when (@type like N'all%') then 1 else 0 end,
			@doprimary = case when (@direction like N'p%') then 1 else 0 end,
			@docols = case when (@type like N'%keycol%') then 1 else 0 end

	/* If a specific @tablename specified, see if it has the kind of keys we want. */
	/* If asking for references from @tablename to 'primary', we must have an FKEY; */
	/* if asking for references to @tablename from 'foreign', we must have an active REFerence. */
	if (@id is not null) begin
		declare @wantkeytype int
		select @wantkeytype = case @doprimary when 1 then 0x4 else 0x8 end
		if not exists (select * from dbo.sysobjects where id = @id and category & @wantkeytype <> 0)
			goto ReturnSet
	end

	if (@dotables = 1) begin
		if (@doprimary = 1) begin
			/* Get all candidate tables (those with Primary/Unique keys in sysconstraints). */
			insert #sprefs
				select distinct id, null, 0 from dbo.sysconstraints where status & 0x0f in (1, 2)

			/* Update the referenced bit if this table references it. */
			update #sprefs set referenced = 1
				where id in (select rkeyid from dbo.sysreferences where fkeyid = @id)
		end else begin
			/* All user tables are foreign-key candidate tables. */
			insert #sprefs
				select distinct id, null, 0 from dbo.sysobjects where OBJECTPROPERTY(id, N'IsUserTable') = 1

			/* Update the referenced bit if it references this table. */
			update #sprefs set referenced = 1
				where id in (select fkeyid from dbo.sysreferences where rkeyid = @id)
		end	/* direction */

	end else begin	/* keys */
		if (@doprimary = 1) begin
			/* Get all candidate tables (those with Primary/Unique keys in sysconstraints) and the keys. */
			insert #sprefs
				select distinct id, constid, 0 from dbo.sysconstraints where status & 0x0f in (1, 2)

			/* Follow r.rkeyindid back to sysindexes to get the name and then 'rconstid' to see if this table references it. */
         update #sprefs set referenced = 1 from #sprefs s, dbo.sysreferences r, dbo.sysindexes i
            where r.fkeyid = @id
            and i.id = r.rkeyid and i.indid = r.rkeyindid and i.status & 0x1800 <> 0
            and s.constid = object_id(N'[' + REPLACE(i.name, N']', N']]') + N']')

		end else begin
			/* First add tables with FOREIGN keys defined. */
			insert #sprefs
				select distinct id, constid, 0 from dbo.sysconstraints where status & 0x0f in (3)

			/* All user tables are foreign-key candidate tables, so add any tables we haven't yet, if @doall. */
			/* (This would be used for 'push' key definition; defining FK's from the standpoint of the PK table). */
			insert #sprefs
				select distinct id, null, 0 from dbo.sysobjects where OBJECTPROPERTY(id, N'IsUserTable') = 1
					and @doall = 1 and id not in (select id from #sprefs)

			/* Update the referenced bit if it references this table. */
			update #sprefs set referenced = 1
				where constid in (select constid from dbo.sysreferences where rkeyid = @id)
		end	/* direction */
	end	/* tables or keys */
	
	/* Exclude system and MS-internal objects, or tables/keys that aren't in the @reftable we want, if any specified. */
	delete #sprefs where id in (select id from dbo.sysobjects where OBJECTPROPERTY(id, N'IsUserTable') <> 1 or category & 0x0002 <> 0)
			or (@refid is not null and id != @refid)

	/* Output */
ReturnSet:
	if (@docols = 0) begin
		if (@tablename is not null) begin
            select candidate_table = N'[' + REPLACE(user_name(o.uid), N']', N']]') + N']' + N'.' + N'[' + REPLACE(object_name(o.id), N']', N']]') + N']',
               candidate_key = case @dotables when 1 then N'N/A' else object_name(s.constid) end, s.referenced
               from #sprefs s, dbo.sysobjects o where o.id = s.id and (@doall = 1 or s.referenced = 1)
               order by object_name(o.id), user_name(o.uid), object_name(s.constid)
      end else begin
            select candidate_table = N'[' + REPLACE(user_name(o.uid), N']', N']]') + N']' + N'.' + N'[' + REPLACE(object_name(o.id), N']', N']]') + N']',
               candidate_key = case @dotables when 1 then N'N/A' else object_name(s.constid) end
               from #sprefs s, dbo.sysobjects o where o.id = s.id
               order by object_name(o.id), user_name(o.uid), object_name(s.constid)
      end
	end else begin	/* @docols = 1 */
		/* This is currently just implemented for 'nonNULLtablename', 'actualkeycols', 'foreign'. */
         select candidate_table = N'[' + REPLACE(user_name(o.uid), N']', N']]') + N']' + N'.' + N'[' + REPLACE(object_name(o.id), N']', N']]') + N']',
               candidate_key = object_name(s.constid),
               cKeyCol1 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey1)),
               cKeyCol2 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey2)),
               cKeyCol3 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey3)),
               cKeyCol4 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey4)),
               cKeyCol5 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey5)),
               cKeyCol6 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey6)),
               cKeyCol7 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey7)),
               cKeyCol8 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey8)),
               cKeyCol9 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey9)),
               cKeyCol10 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey10)),
               cKeyCol11 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey11)),
               cKeyCol12 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey12)),
               cKeyCol13 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey13)),
               cKeyCol14 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey14)),
               cKeyCol15 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey15)),
               cKeyCol16 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey16))
            from #sprefs s, dbo.sysobjects o, dbo.sysreferences r
            where o.id = s.id and r.constid = s.constid and s.referenced = 1
            order by object_name(o.id), user_name(o.uid), object_name(s.constid)
	end
go
/* End sp_MStablerefs */


/*******************************************************************************/
print N''
print N'Creating sp_MStablekeys'
print N''
go

create procedure sp_MStablekeys
@tablename nvarchar(776) = null, @colname nvarchar(258) = null, @type int = null, @keyname nvarchar(517) = null, @flags int = null
as



	create table #tempID
	   (
      cName nvarchar(132) COLLATE database_default NOT NULL,      /* Index name */
      cPK1  int, cPK2  int, cPK3  int, cPK4  int, cPK5  int, cPK6  int, cPK7  int, cPK8  int,
      cPK9  int, cPK10 int, cPK11 int, cPK12 int, cPK13 int, cPK14 int, cPK15 int, cPK16 int    /* 1 if DESC  */
      )

   create table #tempID2
      (
      cPKName  nvarchar(132) COLLATE database_default NOT NULL,      /* PK name */
      cPK      int                                   /* Combined info for PK */
      )

	create table #spkeys
	(
		cType          tinyint NOT NULL, /* key Type */
		cName          nvarchar(258) COLLATE database_default NOT NULL, /* key Name */
		cFlags         int  NULL,  /* e.g., 1 = clustered for PK/Unique */
		cColCount      int  NULL,  /* number of columns (or column pairs) in the key */
		cFillFactor    tinyint NULL, /* Fill factor of index creation */
		cRefTable      nvarchar(520) COLLATE database_default NULL,		/* owner-qual Referenced table name for FKs */
		cRefKey        nvarchar(260)  COLLATE database_default NULL,		/* name of referenced key in referenced table */
			-- Note:  cConstID replaces the column list used in 6.0, for speed.
			-- The output set MUST replace this with either index_col(@tablename, cIndexID, 1-16) and NULL * 16
			-- (for PK/UQ) UNION col_name(r.fkeyid, r.fkey1-16) and col_name(r.rkeyid, r.rkey1-16), for SQLDMO,
			-- and these MUST BE nvarchar(132) for alignment in the SQLDMO cache structure!
		cConstID       int  NULL, /* Reference constraint ID, if Foreign Key  */
		cIndexID       int  NULL, /* ID of this key's index, if PK/UQ */
		cGroupName     sysname COLLATE database_default  NULL,  /* FileGroup name of this key, if PK/UQ */
		cDisabled      int  NULL,  /* 0 if enabled, 1 if disabled */
		cPrimaryFG     int  NULL,  /* 1 if primary FG, 0 otherwise */
      cDeleteCascade int  NULL,    /* 1 if it is a foreign key constraint with a cascade delete */
      cUpdateCascade int  NULL     /* 1 if it is a foreign key constraint with a cascade update */
	)

	/* This proc returns the table's DRI keys.  @type is the type(s) of key(s) to return. */
	/* Make sure @type is only the key types (DRI_PRIMARYKEY, DRI_UNIQUE, DRI_REFERENCE). */
	if (@type is null)
		select @type = 0x000e
	else
		select @type = @type & 0x000e

	/* Flags usage:  For daVinci, to pass call thru to sp_MStablerefs. */
	if (@flags is null)
		select @flags = 0

	set nocount on
	declare @cType int, @cName nvarchar(258), @cFlags int, @cRefTable nvarchar(520), @fillfactor tinyint
	declare @objid int, @constid int, @indid int, @keycnt int, @q1 nvarchar(2000), @q2 nvarchar(2000), @objtype int, @groupname sysname
	declare @haskeytypes int, @wantkeytypes int
   declare @cDisabled int, @PrimaryFG int, @cDeleteCascade int, @cUpdateCascade int

	/* First see if @keyname was defined, and override @tablename and @type if so. */
	if (@keyname is not null)
	begin
         select @objid = id, @type = power(2, status & 0x0f) from dbo.sysconstraints where constid = object_id(@keyname)
         if (@objid is null)	begin
            RAISERROR (15001, -1, -1, @keyname)
            return 1
         end
         /* Now get the tablename for the index_col below */
         select @tablename = N'[' + REPLACE(user_name(uid), N']', N']]') + N']' + N'.' + N'[' + REPLACE(name, N']', N']]') + N']' from dbo.sysobjects where id = @objid
	end else begin
		/* Want all keys for this table (of @type type). */
		select @objid = id, @objtype = (case when OBJECTPROPERTY(id, N'IsTable') = 1 then 1 else 0 end), @haskeytypes = category & 0x0604
			from dbo.sysobjects where id = object_id(@tablename)
		if (@objid is null)	begin
			RAISERROR (15001, -1, -1, @tablename)
			return 1
		end
		if (@objtype <> 1)	begin
			RAISERROR (15218, -1, -1, @tablename)
			return 1
		end
		if @colname is not null and not exists (select * from dbo.syscolumns where id = @objid and name = @colname) begin
			RAISERROR (15253, -1, -1, @colname, @tablename)
			return 1
		end

		/* Skip cursor opening if we don't have any keys (of the type wanted); return a set anyway, for the cache. */
		if (@haskeytypes = 0)
			goto ReturnSet

		/* Map from the input bitmask to the category bitmask */
		select @wantkeytypes = 0
		if ((@type & power(2, 1)) <> 0)
			select @wantkeytypes = @wantkeytypes | 0x200
		if ((@type & power(2, 2)) <> 0)
			select @wantkeytypes = @wantkeytypes | 0x400
		if ((@type & power(2, 3)) <> 0)
			select @wantkeytypes = @wantkeytypes | 0x4
		if ((@haskeytypes & @wantkeytypes) = 0)
			goto ReturnSet
	end

	/* Preprocessor won't replace within quotes so have to use str(). */
	declare @sysgenname nvarchar(12), @pkstr nvarchar(12), @uqstr nvarchar(12), @fkstr nvarchar(12), @objtypebits nvarchar(12)
	select @sysgenname = ltrim(str(convert(int, 0x00020000)))
	select @pkstr = ltrim(str(convert(int, 1)))
	select @uqstr = ltrim(str(convert(int, 2)))
	select @fkstr = ltrim(str(convert(int, 3)))
	select @objtypebits = ltrim(str(convert(int, 0x0f)))

	/* Other ints we need strings for */
	declare @objidstr nvarchar(12), @typestr nvarchar(12)
	select @objidstr = ltrim(str(@objid))
	select @typestr = ltrim(str(@type))

	/* Qualifying key name. */
	declare @qualkeyname nvarchar(100)
	select @qualkeyname = null
	if (@keyname is not null) begin
      select @qualkeyname = N' and constid = object_id(''' + @keyname + N''')'
   end

	/*********************/
	/* Main cursor loop. */
	/*********************/
/*	exec(N'declare hC insensitive cursor for select constid, status & ' + @objtypebits + N', status & ' + @sysgenname + */
	exec(N'declare hC cursor global for select constid, status & ' + @objtypebits + N', status & ' + @sysgenname +
			N' from dbo.sysconstraints where id = ' + @objidstr + N' and (' + @typestr + N' & power(2, status & 0x0f) != 0) ' + @qualkeyname)
	open hC
	fetch hC into @constid, @cType, @cFlags
	while (@@fetch_status >= 0) begin
		if (object_name(@constid) is null) begin
			raiserror 55555 N'Assert failed:  object_name(@constid) is null in sp_MStablekeys (pk/uq)'
			return 1
		end

		/* DRI_PRIMARYKEY, DRI_UNIQUE */
		if (@cType in (1, 2)) begin
			/* Get the index id enforcing this constraint. */
			select @indid = i.indid, @cName = o.name, @fillfactor = i.OrigFillFactor,
					@cFlags = @cFlags | (case indid when 1 then 0x00000001 else 0 end),		/* test for clustered index */
               /* clustered index keys are part of non-clustered index key list, which cause incorrect sysindexes.keycnt */
					@keycnt = case indid when 1 then keycnt else (select count(x.id) from dbo.sysindexkeys x where i.indid = x.indid and x.id = @objid) end,
               @groupname = f.groupname,
               @PrimaryFG = FILEGROUPPROPERTY( f.groupname, N'IsPrimaryFG' )
				from dbo.sysindexes i, dbo.sysobjects o, dbo.sysfilegroups f
            /* Use '=' instead of 'LIKE' in comparision, so we can handle wide card character correctly */
				where o.id = @constid and i.name = o.name and i.status & 0x1800 <> 0 and i.groupid = f.groupid
			if (@indid is null) begin
				raiserror 77777 N'Assert failed:  @indid is null in sp_MStablekeys (pk/uq)'
				return 1
			end

			insert #spkeys values (@cType, @cName, @cFlags, @keycnt, @fillfactor, null, null, null, @indid, @groupname, 0, @PrimaryFG, 0, 0)
		end

		/* DRI_REFERENCE */
		else if (@cType in (3)) begin
			/* Get the key column information from sysreferences. */
         select @keycnt = r.keycnt, @cName = object_name(r.constid), @cRefTable = N'[' + user_name(o.uid) + N']' + N'.' + N'[' + o.name + N']',
               @cDisabled = OBJECTPROPERTY( r.constid, N'CnstIsDisabled' ),
               @cDeleteCascade = OBJECTPROPERTY( r.constid, N'CnstIsDeleteCascade'),
               @cUpdateCascade = OBJECTPROPERTY( r.constid, N'CnstIsUpdateCascade')
            from dbo.sysreferences r, dbo.sysobjects o where r.constid = @constid and o.id = r.rkeyid

			/* Follow r.rkeyindid back to sysindexes to get the ref key name. */
			declare @cRefKey nvarchar(132)
			select @cRefKey = i.name, @cFlags = c.status from dbo.sysreferences r, dbo.sysindexes i, dbo.sysconstraints c
				where c.constid = r.constid and r.constid = @constid
				and i.id = r.rkeyid and i.indid = r.rkeyindid and i.status & 0x1800 <> 0

			/* Load our temp table. */
			insert #spkeys values (@cType, @cName, @cFlags, @keycnt, null, @cRefTable, @cRefKey, @constid, null, null, @cDisabled, 0, @cDeleteCascade, @cUpdateCascade)
		end		/* Key type */

		/* Get the next row. */
		fetch hC into @constid, @cType, @cFlags
	end			/* PRIMARY/UNIQUE */
	deallocate hC

   /* Work on the descending information */
   set nocount on
   insert #tempID
      select cName,
      indexkey_property(object_id(@tablename), cIndexID, 1, N'isdescending'),
      indexkey_property(object_id(@tablename), cIndexID, 2, N'isdescending'),
      indexkey_property(object_id(@tablename), cIndexID, 3, N'isdescending'),
      indexkey_property(object_id(@tablename), cIndexID, 4, N'isdescending'),
      indexkey_property(object_id(@tablename), cIndexID, 5, N'isdescending'),
      indexkey_property(object_id(@tablename), cIndexID, 6, N'isdescending'),
      indexkey_property(object_id(@tablename), cIndexID, 7, N'isdescending'),
      indexkey_property(object_id(@tablename), cIndexID, 8, N'isdescending'),
      indexkey_property(object_id(@tablename), cIndexID, 9, N'isdescending'),
      indexkey_property(object_id(@tablename), cIndexID, 10, N'isdescending'),
      indexkey_property(object_id(@tablename), cIndexID, 11, N'isdescending'),
      indexkey_property(object_id(@tablename), cIndexID, 12, N'isdescending'),
      indexkey_property(object_id(@tablename), cIndexID, 13, N'isdescending'),
      indexkey_property(object_id(@tablename), cIndexID, 14, N'isdescending'),
      indexkey_property(object_id(@tablename), cIndexID, 15, N'isdescending'),
      indexkey_property(object_id(@tablename), cIndexID, 16, N'isdescending')
      from #spkeys
		order by cType, cName

   /* Construct the bit */
   declare @idx int
   declare @Name nvarchar(132)
   declare @Inx_1 int, @Inx_2 int, @Inx_3 int, @Inx_4 int, @Inx_5 int, @Inx_6 int, @Inx_7 int, @Inx_8 int
   declare @Inx_9 int, @Inx_10 int, @Inx_11 int, @Inx_12 int, @Inx_13 int, @Inx_14 int, @Inx_15 int, @Inx_16 int

   declare hCur cursor global for select * from #tempID
   open hCur
   fetch next from hCur into @Name, @Inx_1, @Inx_2, @Inx_3, @Inx_4, @Inx_5, @Inx_6, @Inx_7, @Inx_8,
                             @Inx_9, @Inx_10, @Inx_11, @Inx_12, @Inx_13, @Inx_14, @Inx_15, @Inx_16
   while (@@FETCH_STATUS = 0)
      begin
      select @idx = 0x0000
      select @idx = (case when (@Inx_1 = 1) then @idx | 0x0001 else @idx end), @idx = (case when (@Inx_2 = 1) then @idx | 0x0002 else @idx end), @idx = (case when (@Inx_3 = 1) then @idx | 0x0004 else @idx end), @idx = (case when (@Inx_4 = 1) then @idx | 0x0008 else @idx end), @idx = (case when (@Inx_5 = 1) then @idx | 0x0010 else @idx end), @idx = (case when (@Inx_6 = 1) then @idx | 0x0020 else @idx end), @idx = (case when (@Inx_7 = 1) then @idx | 0x0040 else @idx end), @idx = (case when (@Inx_8 = 1) then @idx | 0x0080 else @idx end),
             @idx = (case when (@Inx_9 = 1) then @idx | 0x0100 else @idx end), @idx = (case when (@Inx_10 = 1) then @idx | 0x0200 else @idx end), @idx = (case when (@Inx_11 = 1) then @idx | 0x0400 else @idx end), @idx = (case when (@Inx_12 = 1) then @idx | 0x0800 else @idx end), @idx = (case when (@Inx_13 = 1) then @idx | 0x1000 else @idx end), @idx = (case when (@Inx_14 = 1) then @idx | 0x2000 else @idx end), @idx = (case when (@Inx_15 = 1) then @idx | 0x4000 else @idx end), @idx = (case when (@Inx_16 = 1) then @idx | 0x8000 else @idx end)
      insert #tempID2 select @Name, @idx

      fetch next from hCur into @Name, @Inx_1, @Inx_2, @Inx_3, @Inx_4, @Inx_5, @Inx_6, @Inx_7, @Inx_8,
                                @Inx_9, @Inx_10, @Inx_11, @Inx_12, @Inx_13, @Inx_14, @Inx_15, @Inx_16
      end
   close hCur
   deallocate hCur
   set nocount off


	/* Now output the data */
ReturnSet:
	set nocount off
	select cType, cName, cFlags, cColCount, cFillFactor, cRefTable, cRefKey,
			cKeyCol1 = convert(nvarchar(132), index_col(@tablename, cIndexID, 1)),
			cKeyCol2 = convert(nvarchar(132), index_col(@tablename, cIndexID, 2)),	
			cKeyCol3 = convert(nvarchar(132), index_col(@tablename, cIndexID, 3)),
			cKeyCol4 = convert(nvarchar(132), index_col(@tablename, cIndexID, 4)),
			cKeyCol5 = convert(nvarchar(132), index_col(@tablename, cIndexID, 5)),
			cKeyCol6 = convert(nvarchar(132), index_col(@tablename, cIndexID, 6)),	
			cKeyCol7 = convert(nvarchar(132), index_col(@tablename, cIndexID, 7)),
			cKeyCol8 = convert(nvarchar(132), index_col(@tablename, cIndexID, 8)),
			cKeyCol9 = convert(nvarchar(132), index_col(@tablename, cIndexID, 9)),
			cKeyCol10 = convert(nvarchar(132), index_col(@tablename, cIndexID, 10)),
			cKeyCol11 = convert(nvarchar(132), index_col(@tablename, cIndexID, 11)),
			cKeyCol12 = convert(nvarchar(132), index_col(@tablename, cIndexID, 12)),
			cKeyCol13 = convert(nvarchar(132), index_col(@tablename, cIndexID, 13)),
			cKeyCol14 = convert(nvarchar(132), index_col(@tablename, cIndexID, 14)),	
			cKeyCol15 = convert(nvarchar(132), index_col(@tablename, cIndexID, 15)),
			cKeyCol16 = convert(nvarchar(132), index_col(@tablename, cIndexID, 16)),
			cRefCol1 = convert(nvarchar(132), null),
			cRefCol2 = convert(nvarchar(132), null),
			cRefCol3 = convert(nvarchar(132), null),
			cRefCol4 = convert(nvarchar(132), null),
			cRefCol5 = convert(nvarchar(132), null),
			cRefCol6 = convert(nvarchar(132), null),
			cRefCol7 = convert(nvarchar(132), null),
			cRefCol8 = convert(nvarchar(132), null),
			cRefCol9 = convert(nvarchar(132), null),
			cRefCol10 = convert(nvarchar(132), null),
			cRefCol11 = convert(nvarchar(132), null),
			cRefCol12 = convert(nvarchar(132), null),
			cRefCol13 = convert(nvarchar(132), null),
			cRefCol14 = convert(nvarchar(132), null),
			cRefCol15 = convert(nvarchar(132), null),
			cRefCol16 = convert(nvarchar(132), null),
			cIndexID,
			cGroupName,
         cDisabled,
	      cPrimaryFG,
         cDeleteCascade,
         cUpdateCascade,
         Descending = t.cPK
		from #spkeys, #tempID2 t where cType in (1, 2)
         and cName = t.cPKName
			and (@colname is null or
				index_col(@tablename, cIndexID, 1) = @colname or
				index_col(@tablename, cIndexID, 2) = @colname or
				index_col(@tablename, cIndexID, 3) = @colname or
				index_col(@tablename, cIndexID, 4) = @colname or
				index_col(@tablename, cIndexID, 5) = @colname or
				index_col(@tablename, cIndexID, 6) = @colname or
				index_col(@tablename, cIndexID, 7) = @colname or
				index_col(@tablename, cIndexID, 8) = @colname or
				index_col(@tablename, cIndexID, 9) = @colname or
				index_col(@tablename, cIndexID, 10) = @colname or
				index_col(@tablename, cIndexID, 11) = @colname or
				index_col(@tablename, cIndexID, 12) = @colname or
				index_col(@tablename, cIndexID, 13) = @colname or
				index_col(@tablename, cIndexID, 14) = @colname or
				index_col(@tablename, cIndexID, 15) = @colname or
				index_col(@tablename, cIndexID, 16) = @colname
			)
		UNION
		select c.cType, c.cName, c.cFlags, c.cColCount, c.cFillFactor, c.cRefTable, c.cRefKey,
			cKeyCol1 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey1)),
			cKeyCol2 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey2)),
			cKeyCol3 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey3)),
			cKeyCol4 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey4)),
			cKeyCol5 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey5)),
			cKeyCol6 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey6)),
			cKeyCol7 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey7)),
			cKeyCol8 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey8)),
			cKeyCol9 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey9)),
			cKeyCol10 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey10)),
			cKeyCol11 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey11)),
			cKeyCol12 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey12)),
			cKeyCol13 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey13)),
			cKeyCol14 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey14)),
			cKeyCol15 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey15)),
			cKeyCol16 = convert(nvarchar(132), col_name(r.fkeyid, r.fkey16)),
			cRefCol1 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey1)),
			cRefCol2 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey2)),	
			cRefCol3 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey3)),
			cRefCol4 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey4)),
			cRefCol5 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey5)),
			cRefCol6 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey6)),
			cRefCol7 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey7)),
			cRefCol8 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey8)),
			cRefCol9 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey9)),
			cRefCol10 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey10)),
			cRefCol11 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey11)),
			cRefCol12 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey12)),
			cRefCol13 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey13)),
			cRefCol14 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey14)),
			cRefCol15 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey15)),
			cRefCol16 = convert(nvarchar(132), col_name(r.rkeyid, r.rkey16)),
			cIndexID,
			cGroupName,
         cDisabled,
	      cPrimaryFG,
         cDeleteCascade,
         cUpdateCascade,
         0
		from #spkeys c, dbo.sysreferences r where c.cType = 3 and r.constid = c.cConstID
			and (@colname is null or
				col_name(r.fkeyid, r.fkey1) = @colname or
				col_name(r.fkeyid, r.fkey2) = @colname or
				col_name(r.fkeyid, r.fkey3) = @colname or
				col_name(r.fkeyid, r.fkey4) = @colname or
				col_name(r.fkeyid, r.fkey5) = @colname or
				col_name(r.fkeyid, r.fkey6) = @colname or
				col_name(r.fkeyid, r.fkey7) = @colname or
				col_name(r.fkeyid, r.fkey8) = @colname or
				col_name(r.fkeyid, r.fkey9) = @colname or
				col_name(r.fkeyid, r.fkey10) = @colname or
				col_name(r.fkeyid, r.fkey11) = @colname or
				col_name(r.fkeyid, r.fkey12) = @colname or
				col_name(r.fkeyid, r.fkey13) = @colname or
				col_name(r.fkeyid, r.fkey14) = @colname or
				col_name(r.fkeyid, r.fkey15) = @colname or
				col_name(r.fkeyid, r.fkey16) = @colname
			)
		order by cType, cName

	if (@flags & 1 <> 0)
		exec sp_MStablerefs @tablename, N'actualkeycols', N'foreign'

go
/* End sp_MStablekeys */

/*-----------------------------------------------------*/
/*-----------------------------------------------------*/
print N''
print N'Creating sp_MStablechecks'
print N''
go

create procedure sp_MStablechecks
	@tablename nvarchar(517), @flags int = null
as
   /*** @flags added for DaVinci uses.  If the bit isn't set, use 6.5 ***/
   /*** sp_MStablechecks '%s'                                        ***/

	declare @id int
	select @id = object_id(@tablename)
	if (@id is null) begin
		RAISERROR (15001, -1, -1, @tablename)
		return 1
	end

	/* @flags is for daVinci. */
	if (@flags is null)
		select @flags = 0

	/* We'll put out the check text if it's all in one row (most likely); otherwise leave it */
	/* blank for refetching in its entirety via sp_helptext, unless @flags wants it anyway. */
	select object_name(t.id),
		case when (@flags & 1 <> 0 or not exists (select * from dbo.syscomments where id = t.id and colid = 2))
				then t.text else null end,
		c.status & (convert(int, 0x00200000) | convert(int, 0x00020000) | convert(int, 0x00004000)),
      OBJECTPROPERTY( t.id, N'CnstIsDisabled' )
	from dbo.syscomments t, dbo.sysconstraints c
	where t.id = c.constid and c.id = @id and c.status & 0x0f = 4
		and (@flags & 1 <> 0 or t.colid = 1)
	order by object_name(t.id), t.colid
go
/* End sp_MStablechecks */

/*-----------------------------------------------------*/
/*-----------------------------------------------------*/
print N''
print N'Creating sp_MSsettopology'
print N''
go

/* Need this because it will set sysservers columns. */
sp_configure N'allow updates', 1
go
reconfigure with override
go

create procedure sp_MSsettopology
	@server nvarchar(258), @X int, @Y int
as
	update master.dbo.sysservers set topologyx = @X, topologyy = @Y
		where srvname = @server
	if (@@rowcount = 0) begin
		RAISERROR (15015, -1, -1, @server)
		return 1
	end
	return 0
go
/* End sp_MSsettopology */

sp_configure N'allow updates', 0
go
reconfigure with override
go

/*-----------------------------------------------------*/
/*-----------------------------------------------------*/
print N''
print N'Creating sp_MSmatchkey'
print N''
go

create proc sp_MSmatchkey
	@tablename nvarchar(517),
	@col1 nvarchar(258),
	@col2 nvarchar(258) = null,
	@col3 nvarchar(258) = null,
	@col4 nvarchar(258) = null,
	@col5 nvarchar(258) = null,
	@col6 nvarchar(258) = null,
	@col7 nvarchar(258) = null,
	@col8 nvarchar(258) = null,
	@col9 nvarchar(258) = null,
	@col10 nvarchar(258) = null,
	@col11 nvarchar(258) = null,
	@col12 nvarchar(258) = null,
	@col13 nvarchar(258) = null,
	@col14 nvarchar(258) = null,
	@col15 nvarchar(258) = null,
	@col16 nvarchar(258) = null
as

	create table #t1 (		/* Join into this... */
		i					int				NOT NULL,
		name				nvarchar(258)	 COLLATE database_default   NULL
	)

	create table #i1 (
		i					int				NOT NULL
	)

	declare @id int, @ii int, @colnotfound nvarchar(258), @keycnt int
	select @id = object_id(@tablename)
	if (@id is null) begin
		RAISERROR (15001, -1, -1, @tablename)
		return 1
	end
	select @ii = 1
	insert #t1 values (1, @col1)
	insert #t1 values (2, @col2)
	insert #t1 values (3, @col3)
	insert #t1 values (4, @col4)
	insert #t1 values (5, @col5)
	insert #t1 values (6, @col6)
	insert #t1 values (7, @col7)
	insert #t1 values (8, @col8)
	insert #t1 values (9, @col9)
	insert #t1 values (10, @col10)
	insert #t1 values (11, @col11)
	insert #t1 values (12, @col12)
	insert #t1 values (13, @col13)
	insert #t1 values (14, @col14)
	insert #t1 values (15, @col15)
	insert #t1 values (16, @col16)
	delete #t1 where name is null

	select @colnotfound = min(name) from #t1 where name not in (select name from dbo.syscolumns where id = @id)
	if (@colnotfound is not null) begin
		RAISERROR (15253, -1, -1, @colnotfound, @tablename)
		return 1
	end
	select @ii = 1, @keycnt = count(*) from #t1

	/* Load all indexes which have the matching number of columns into a temp table, then eliminate those which don't qualify. */
	/* Remember the RID in the nc index is counted as a key */
	insert #i1 select indid from dbo.sysindexes where status & 0x1800 <> 0
		and id = @id and keycnt - (case indid when 1 then 0 else 1 end) = @keycnt
	while (@ii <= @keycnt) begin
		delete #i1 from #i1 i, #t1 t where t.i = @ii and index_col(@tablename, i.i, t.i) <> t.name
		select @ii = @ii + 1
	end

	/* The qualifying key will be the lowest indid (or the ONLY indid, if we disallow duplicate indexes), if any remain. */
	select name from dbo.sysindexes where id = @id and indid = (select min(i) from #i1)
go
/* End sp_MSmatchkey */

/*-----------------------------------------------------*/
/*-----------------------------------------------------*/
print N''
print N'Creating sp_MSforeach_worker'
print N''
go

/*
 * This is the worker proc for all of the "for each" type procs.  Its function is to read the
 * next replacement name from the cursor (which returns only a single name), plug it into the
 * replacement locations for the commands, and execute them.  It assumes the cursor "hCForEach"
 * has already been opened by its caller.
 */
create proc sp_MSforeach_worker
	@command1 nvarchar(2000), @replacechar nchar(1) = N'?', @command2 nvarchar(2000) = null, @command3 nvarchar(2000) = null
as

	create table #qtemp (	/* Temp command storage */
		qnum				int				NOT NULL,
		qchar				nvarchar(2000)	COLLATE database_default NULL
	)

	set nocount on
	declare @name nvarchar(517), @namelen int, @q1 nvarchar(2000), @q2 nvarchar(2000)
   declare @q3 nvarchar(2000), @q4 nvarchar(2000), @q5 nvarchar(2000)
	declare @q6 nvarchar(2000), @q7 nvarchar(2000), @q8 nvarchar(2000), @q9 nvarchar(2000), @q10 nvarchar(2000)
	declare @cmd nvarchar(2000), @replacecharindex int, @useq tinyint, @usecmd tinyint, @nextcmd nvarchar(2000)
   declare @namesave nvarchar(517), @nametmp nvarchar(517), @nametmp2 nvarchar(258)

	open hCForEach
	fetch hCForEach into @name

	/* Loop for each database */
	while (@@fetch_status >= 0) begin
		/* Initialize. */

      /* save the original dbname */
      select @namesave = @name
		select @useq = 1, @usecmd = 1, @cmd = @command1, @namelen = datalength(@name)
		while (@cmd is not null) begin		/* Generate @q* for exec() */
			/*
			 * Parse each @commandX into a single executable batch.
			 * Because the expanded form of a @commandX may be > OSQL_MAXCOLLEN_SET, we'll need to allow overflow.
			 * We also may append @commandX's (signified by '++' as first letters of next @command).
			 */
			select @replacecharindex = charindex(@replacechar, @cmd)
			while (@replacecharindex <> 0) begin

            /* 7.0, if name contains ' character, and the name has been single quoted in command, double all of them in dbname */
            /* if the name has not been single quoted in command, do not doulbe them */
            /* if name contains ] character, and the name has been [] quoted in command, double all of ] in dbname */
            select @name = @namesave
            select @namelen = datalength(@name)
            declare @tempindex int
            if (substring(@cmd, @replacecharindex - 1, 1) = N'''') begin
               /* if ? is inside of '', we need to double all the ' in name */
               select @name = REPLACE(@name, N'''', N'''''')
            end else if (substring(@cmd, @replacecharindex - 1, 1) = N'[') begin
               /* if ? is inside of [], we need to double all the ] in name */
               select @name = REPLACE(@name, N']', N']]')
            end else if ((@name LIKE N'%].%]') and (substring(@name, 1, 1) = N'[')) begin
               /* ? is NOT inside of [] nor '', and the name is in [owner].[name] format, handle it */
               /* !!! work around, when using LIKE to find string pattern, can't use '[', since LIKE operator is treating '[' as a wide char */
               select @tempindex = charindex(N'].[', @name)
               select @nametmp  = substring(@name, 2, @tempindex-2 )
               select @nametmp2 = substring(@name, @tempindex+3, len(@name)-@tempindex-3 )
               select @nametmp  = REPLACE(@nametmp, N']', N']]')
               select @nametmp2 = REPLACE(@nametmp2, N']', N']]')
               select @name = N'[' + @nametmp + N'].[' + @nametmp2 + ']'
            end else if ((@name LIKE N'%]') and (substring(@name, 1, 1) = N'[')) begin
               /* ? is NOT inside of [] nor '', and the name is in [name] format, handle it */
               /* j.i.c., since we should not fall into this case */
               /* !!! work around, when using LIKE to find string pattern, can't use '[', since LIKE operator is treating '[' as a wide char */
               select @nametmp = substring(@name, 2, len(@name)-2 )
               select @nametmp = REPLACE(@nametmp, N']', N']]')
               select @name = N'[' + @nametmp + N']'
            end
            /* Get the new length */
            select @namelen = datalength(@name)

            /* start normal process */
				if (datalength(@cmd) + @namelen - 1 > 2000) begin
					/* Overflow; put preceding stuff into the temp table */
					if (@useq > 9) begin
						raiserror 55555 N'sp_MSforeach_worker assert failed:  command too long'
						close hCForEach
						deallocate hCForEach
						return 1
					end
					if (@replacecharindex < @namelen) begin
						/* If this happened close to beginning, make sure expansion has enough room. */
						/* In this case no trailing space can occur as the row ends with @name. */
						select @nextcmd = substring(@cmd, 1, @replacecharindex)
						select @cmd = substring(@cmd, @replacecharindex + 1, 2000)
						select @nextcmd = stuff(@nextcmd, @replacecharindex, 1, @name)
						select @replacecharindex = charindex(@replacechar, @cmd)
						insert #qtemp values (@useq, @nextcmd)
						select @useq = @useq + 1
						continue
					end
					/* Move the string down and stuff() in-place. */
					/* Because varchar columns trim trailing spaces, we may need to prepend one to the following string. */
					/* In this case, the char to be replaced is moved over by one. */
					insert #qtemp values (@useq, substring(@cmd, 1, @replacecharindex - 1))
					if (substring(@cmd, @replacecharindex - 1, 1) = N' ') begin
						select @cmd = N' ' + substring(@cmd, @replacecharindex, 2000)
						select @replacecharindex = 2
					end else begin
						select @cmd = substring(@cmd, @replacecharindex, 2000)
						select @replacecharindex = 1
					end
					select @useq = @useq + 1
				end
				select @cmd = stuff(@cmd, @replacecharindex, 1, @name)
				select @replacecharindex = charindex(@replacechar, @cmd)
			end

			/* Done replacing for current @cmd.  Get the next one and see if it's to be appended. */
			select @usecmd = @usecmd + 1
			select @nextcmd = case (@usecmd) when 2 then @command2 when 3 then @command3 else null end
			if (@nextcmd is not null and substring(@nextcmd, 1, 2) = N'++') begin
				insert #qtemp values (@useq, @cmd)
				select @cmd = substring(@nextcmd, 3, 2000), @useq = @useq + 1
				continue
			end

			/* Now exec() the generated @q*, and see if we had more commands to exec().  Continue even if errors. */
			/* Null them first as the no-result-set case won't. */
			select @q1 = null, @q2 = null, @q3 = null, @q4 = null, @q5 = null, @q6 = null, @q7 = null, @q8 = null, @q9 = null, @q10 = null
			select @q1 = qchar from #qtemp where qnum = 1
			select @q2 = qchar from #qtemp where qnum = 2
			select @q3 = qchar from #qtemp where qnum = 3
			select @q4 = qchar from #qtemp where qnum = 4
			select @q5 = qchar from #qtemp where qnum = 5
			select @q6 = qchar from #qtemp where qnum = 6
			select @q7 = qchar from #qtemp where qnum = 7
			select @q8 = qchar from #qtemp where qnum = 8
			select @q9 = qchar from #qtemp where qnum = 9
			select @q10 = qchar from #qtemp where qnum = 10
			truncate table #qtemp
			exec (@q1 + @q2 + @q3 + @q4 + @q5 + @q6 + @q7 + @q8 + @q9 + @q10 + @cmd)
			select @cmd = @nextcmd, @useq = 1
		end /* while @cmd is not null, generating @q* for exec() */

		/* All commands done for this name.  Go to next one. */
		fetch hCForEach into @name
	end /* while FETCH_SUCCESS */
	close hCForEach
	deallocate hCForEach
	return 0
go

/* End sp_MSforeach_worker */

/*-----------------------------------------------------*/
/*-----------------------------------------------------*/
print N''
print N'Creating sp_MSforeachdb'
print N''
go

/*
 * The following table definition will be created by SQLDMO at start of each connection.
 * We don't create it here temporarily because we need it in Exec() or upgrade won't work.
 */

create proc sp_MSforeachdb
	@command1 nvarchar(2000), @replacechar nchar(1) = N'?', @command2 nvarchar(2000) = null, @command3 nvarchar(2000) = null,
	@precommand nvarchar(2000) = null, @postcommand nvarchar(2000) = null
as
    set deadlock_priority low
    
	/* This proc returns one or more rows for each accessible db, with each db defaulting to its own result set */
	/* @precommand and @postcommand may be used to force a single result set via a temp table. */

	/* Preprocessor won't replace within quotes so have to use str(). */
	declare @inaccessible nvarchar(12), @invalidlogin nvarchar(12), @dbinaccessible nvarchar(12)
	select @inaccessible = ltrim(str(convert(int, 0x03e0), 11))
	select @invalidlogin = ltrim(str(convert(int, 0x40000000), 11))
	select @dbinaccessible = N'0x80000000'		/* SQLDMODbUserProf_InaccessibleDb; the negative number doesn't work in convert() */

	if (@precommand is not null)
		exec(@precommand)

	declare @origdb nvarchar(128)
	select @origdb = db_name()

	/* If it's a single user db and there's an entry for it in sysprocesses who isn't us, we can't use it. */
   /* Create the select */
	exec(N'declare hCForEach cursor global for select name from master.dbo.sysdatabases d ' +
			N' where (d.status & ' + @inaccessible + N' = 0)' +
			N' and ((DATABASEPROPERTY(d.name, ''issingleuser'') = 0 and (has_dbaccess(d.name) = 1)) or ' +
			N' ( DATABASEPROPERTY(d.name, ''issingleuser'') = 1 and not exists ' +
			N' (select * from master.dbo.sysprocesses p where dbid = d.dbid and p.spid <> @@spid)))' )

	declare @retval int
	select @retval = @@error
	if (@retval = 0)
		exec @retval = sp_MSforeach_worker @command1, @replacechar, @command2, @command3

	if (@retval = 0 and @postcommand is not null)
		exec(@postcommand)

   declare @tempdb nvarchar(258)
   SELECT @tempdb = REPLACE(@origdb, N']', N']]')
   exec (N'use ' + N'[' + @tempdb + N']')

	return @retval
go
/* End sp_MSforeachdb */

/*-----------------------------------------------------*/
/*-----------------------------------------------------*/
print N''
print N'Creating sp_MSforeachtable'
print N''
go

create proc sp_MSforeachtable
	@command1 nvarchar(2000), @replacechar nchar(1) = N'?', @command2 nvarchar(2000) = null,
   @command3 nvarchar(2000) = null, @whereand nvarchar(2000) = null,
	@precommand nvarchar(2000) = null, @postcommand nvarchar(2000) = null
as
	/* This proc returns one or more rows for each table (optionally, matching @where), with each table defaulting to its own result set */
	/* @precommand and @postcommand may be used to force a single result set via a temp table. */

	/* Preprocessor won't replace within quotes so have to use str(). */
	declare @mscat nvarchar(12)
	select @mscat = ltrim(str(convert(int, 0x0002)))

	if (@precommand is not null)
		exec(@precommand)

	/* Create the select */
   exec(N'declare hCForEach cursor global for select ''['' + REPLACE(user_name(uid), N'']'', N'']]'') + '']'' + ''.'' + ''['' + REPLACE(object_name(id), N'']'', N'']]'') + '']'' from dbo.sysobjects o '
         + N' where OBJECTPROPERTY(o.id, N''IsUserTable'') = 1 ' + N' and o.category & ' + @mscat + N' = 0 '
         + @whereand)
	declare @retval int
	select @retval = @@error
	if (@retval = 0)
		exec @retval = sp_MSforeach_worker @command1, @replacechar, @command2, @command3

	if (@retval = 0 and @postcommand is not null)
		exec(@postcommand)

	return @retval
go
/* End sp_MSforeachtable */

/*******************************************************************************/

print N''
print N'Creating sp_MSloginmappings'
print N''
go



create proc sp_MSloginmappings
	@loginname nvarchar(258) = null, @flags int = 0
as

	create table #loginmappings(
		LoginName  nvarchar(128) NULL,
		DBName     nvarchar(128) NULL,
		UserName   nvarchar(128) NULL,
		AliasName  nvarchar(128) NULL
	)

	/*
	 * @flags bits:
	 *		0x01	- current db only
	 */
	/*
	 * Added @dbname so dbo can see everyone in current database.
	 * Use hacky 4.21 syntax so it will run there, instead of a case..when.
	 */
	declare @checkmultilogin int
	select @checkmultilogin = 1
	if ((@flags & 0x01 <> 0) and user_id() = 1)
		select @checkmultilogin = 0

	declare @logincount int
	select @logincount = 0
	if (@loginname is not null)
		select @logincount = count(*) from dbo.syslogins where loginname = @loginname

	/* Gotta be sa or dbo to see other than just current login. */
	declare @numlogins int, @whereloginname nvarchar(258), @name nvarchar(258), @retval int
	if (@loginname is null)
		select @numlogins = 2
	else
		select @numlogins = count(*) from dbo.syslogins where loginname = @loginname

	if (@numlogins = 0) begin
		RAISERROR (15007, -1, -1, @loginname)		/* Login not found */
		return 1
	end
	if (@checkmultilogin <> 0) begin
      /* We do not want to allow everybody to execute this SP */
		if (is_member(N'db_ddladmin') <> 1 and is_member(N'db_owner') <> 1 and is_member(N'db_accessadmin') <> 1 and is_member(N'db_securityadmin') <> 1 and (@numlogins > 1 or suser_sid() <> suser_sid(@loginname))) begin
			RAISERROR (14301, -1, -1, N'')				/* Only sa can see other than the current login */
			return 1
		end
	end
	if (@loginname is not null)
		select @whereloginname = N' and loginname = ''' + @loginname + N''''
   else
      select @whereloginname = N' '

	/*
	 * This proc returns a result set with one or more rows for each database for which a login is a user or aliased to one.
	 * If loginname is specified, the results are limited to that login.  First load a temp table with all logins that are
	 * in a db, then add those which aren't mapped to any db.
	 */
	if (@flags & 0x01 <> 0) begin
		INSERT #loginmappings select l.loginname, db_name(), u.name, null from master.dbo.syslogins l, dbo.sysusers u where l.sid = u.sid and l.loginname is not NULL
		/*
		 * We only allow multi-db on a 6.x server because dynamic exec() didn't exist before then,
		 * hence there is no way to loop thru every database.  This is caught in SQLDMO so no
		 * need for error message here; we'll just return no result sets.
		 */
	end else begin
		exec @retval = sp_MSforeachdb
			N'use [?] INSERT #loginmappings select l.loginname, db_name(), u.name, null from master.dbo.syslogins l, dbo.sysusers u where l.sid = u.sid and l.loginname is not NULL'
		if (@retval <> 0)
			return 1
		insert #loginmappings select l.loginname, null, null, null from master.dbo.syslogins l where l.loginname not in (select LoginName from #loginmappings) and l.loginname is not NULL
	end

	/*
	 * Now bring them out by loginname, each in its own result set.
	 * If this is for all logins, we'll return all logins; if for curdb,
	 * only those in #loginmappings (i.e. only those mapped in curdb).
	 */
	exec(N'declare hCForEachLogin cursor global for select loginname from master.dbo.syslogins where loginname is not NULL ' + @whereloginname + N' order by loginname')
	if (@@error = 0)
		open hCForEachLogin
	if (@@error <> 0)
		return @@error
	fetch hCForEachLogin into @name
	while (@@fetch_status >= 0) begin
      /* Use '=' instead of 'LIKE' in comparision, so we can handle wide card character correctly */
		if ((@flags & 0x01 = 0) or exists (select * from #loginmappings where LoginName = @name))
			select * from #loginmappings where LoginName = @name
		fetch hCForEachLogin into @name
	end /* FETCH_SUCCESS */
	close hCForEachLogin
	deallocate hCForEachLogin
	return @@error
go
/* End sp_MSloginmappings */

/*******************************************************************************/
print N''
print N'Creating sp_MSuniquename'
print N''
go

create procedure sp_MSuniquename
	@seed nvarchar(128), @start int = null
as
	/* Return a unique name for sysobjects, based on a passed-in seed. */
	set nocount on
	declare @i int, @append nvarchar(10), @seedlen int, @temp nvarchar(128), @recalcseedlen int, @seedcharlen int
	select @i = 1, @seedlen = datalength(@seed), @recalcseedlen = 1, @seedcharlen = 0
	if (@start is not null and @start >= 0)
		select @i = @start
	while 1 < 2
	begin
		/* This is probably overkill, but start at max length of seed name, leaving room under OSQL_DBLSYSNAME_SET for @append. */
		/* We'll work our way back along the string if more room needed (pathological user). */
		select @append = ltrim(str(@i)) + N'__' + ltrim(str(@@spid))
		if (@recalcseedlen = @i or @seedcharlen = 0)
		begin
			while @recalcseedlen <= @i
				select @recalcseedlen = @recalcseedlen * 10
			select @seedcharlen = @seedlen
			if ((@seedlen + datalength(@append)) > 128) begin
				select @seedlen = 128 - datalength(@append)

				/* Get the charlen of this datalength for the substring() call. */
				select @seedcharlen = @seedlen
			   /* exec sp_GetMBCSCharLen @seed, @seedlen, @seedcharlen out */
			end		/* Recalc seedlen */
		end		/* Check seedlen */

		select @temp = substring(@seed, 1, @seedcharlen) + @append

		/* If I don't set a limit somewhere, it's gonna look hung -- I'd rather get a nonunique error. */
		if object_id(@temp) is null or @i > 999999		/* if increased, watch out for overflow of @recalcseedlen */
		begin
			set nocount off
			select Name = @temp, Next = @i + 1
			return 0
		end
		select @i = @i + 1
	end
go
/* End sp_MSuniquename */

/*******************************************************************************/
print N''
print N'Creating sp_MSkilldb'
print N''
go

sp_configure updat, 1
go
reconfigure with override
go

create proc sp_MSkilldb
	@dbname nvarchar(258)
as
	if (@@trancount > 0) begin
		RAISERROR (15002, -1, -1, N'sp_MSkilldb')
		return 1
	end

	if (is_member(N'db_owner') <> 1 and is_member(N'db_ddladmin') <> 1) begin
		RAISERROR (15003, -1, -1, N'')
		return 1
	end

	/* Set this db to suspect, then let dbcc dbrepair kill it for us. */
	update master.dbo.sysdatabases set status = status | 0x0100
		where name = @dbname
	if (@@rowcount = 0) begin
		declare @len int
		select @len = datalength(@dbname)
		RAISERROR (2702, -1, -1, @len, @dbname)
		return 1
	end
	dbcc dbrepair(@dbname, dropdb)
	return 0
go

sp_configure updat, 0
go
reconfigure with override
go

/* End sp_MSkilldb */

/*******************************************************************************/
print N''
print N'Creating sp_MSobjectprivs'
print N''
go

create proc sp_MSobjectprivs
	@objname nvarchar(776) = null,
	@mode nvarchar(10) = N'object',	
	@objid int = null,				
	@srvpriv int = null,			
	@prottype int = null,			
	@grantee nvarchar(258) = null,		
   @flags int = 0,
   @rollup int = 0
as

	create table #objs(
		id  int NOT NULL
	)

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
	 *  BUG 235637  
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

/*******************************************************************************/
/* Need to create the version proc here so we can set its category bit */
print N''
print N'Creating sp_MSSQLDMO80_version'
print N''
go

create procedure sp_MSSQLDMO80_version
as
	/* Values for this are same as @@microsoftversion */
   /* @@microsoftversion format is 0xaaiibbbb (aa = major, ii = minor, bb[bb] = build #) */
	declare @i int
	select @i = 0x08000000	/* Must be in hex! */

	/* Select the numeric value, and a conversion to make it readable */
	select N'Microsoft SQLDMO Scripts' = @i, N'Version' = convert(binary(4), @i)
go

/*
 * The following three scripts must retain the SQLOLE nomenclature as we provide them to be an informative
 * notification to downlevel connections.
 */
create procedure sp_MSSQLDMO70_version
as
	RAISERROR 55555 N'You must upgrade your SQL Enterprise Manager and SQL-DMO (SQLOLE) to SQL Server 2000 (SQLDMO) to connect to this server.'
   return 1
go


create procedure sp_MSSQLOLE65_version
as
	RAISERROR 55555 N'You must upgrade your SQL Enterprise Manager and SQL-DMO (SQLOLE) to SQL Server 2000 (SQLDMO) to connect to this server.'
   return 1
go

create procedure sp_MSSQLOLE_version
as
	RAISERROR 55555 N'You must upgrade your SQL Enterprise Manager and SQL-DMO (SQLOLE) to SQL Server 2000 (SQLDMO) to connect to this server.'
   return 1
go

/*******************************************************************************/
print N''
print N'Creating sp_MSscriptdatabase'
print N''
go
create procedure sp_MSscriptdatabase
@dbname nvarchar(258)
as
   /* verify */
   declare @id int
   select @id = dbid from master.dbo.sysdatabases where name = @dbname
   if (@id is null)
   begin
      RAISERROR (15001, -1, -1, @dbname)
      return 1
   end

   /* Ready to get to work */
   declare @dbTempname nvarchar(258)
   SELECT @dbTempname = REPLACE(@dbname, N']', N']]')
   exec (N'[' + @dbTempname + N']' + N'..sp_MSscriptdb_worker ')
go
/* End sp_MSscriptdatabase */

/*******************************************************************************/
print N''
print N'Creating sp_MSscriptdb_worker'
print N''
go
create procedure sp_MSscriptdb_worker
as

	create table #tempFG
	(
     cDefault     int,                                  /* 1 for default FG, 0 for user defined */
     cDBFile      int,                                  /* 1 for DB file, 0 for Log file */
	  cSize        int,                                  /* in 8K page */
	  cMaxSize     int,
	  cGrowth      int,
     cGrowthType  int,                                  /* 1 for GrowthInMB, 0 for GrowthInPercent */
     cFGName      nvarchar(132) COLLATE database_default NOT NULL,      /* FG name */
	  cName        nvarchar(132) COLLATE database_default NOT NULL,      /* Logical */
	  cFileName    nvarchar(264) COLLATE database_default NOT NULL,     /* Physical */
	)

	create table #tempID
   (
		cGroupID int
	)

	set nocount on

   declare @PageSize int;
   select @PageSize = (low/1024) from master..spt_values where number = 1 and type = N'E'

   /* Default FileGroup first, which should cover all the log files */
   /* This one to pick up all the db files in Primary file group, while group id = 1 */
   insert #tempFG select 1, 1, convert(int, ceiling(((convert(float, o.size) * @PageSize)/1024))), (case when (o.maxsize < 1) then o.maxsize else convert(int, ceiling(((convert(float, o.maxsize) * @PageSize)/1024))) end), o.growth, (case when (o.status & 0x100000 = 0) then 1 else 0 end), g.groupname, RTRIM(o.name), RTRIM(o.filename) from dbo.sysfiles o, dbo.sysfilegroups g where g.groupid = 1 and g.groupid = o.groupid and (o.status & 0x40) = 0
   /* This one to pick up all the log files in Primary file group, while group id = 0, note that group id 0 does not exist in sysfilegroups */
   insert #tempFG select 1, 0, (o.size * @PageSize)/1024, (case when (o.maxsize < 1) then o.maxsize else convert(int, ceiling(((convert(float, o.maxsize) * @PageSize)/1024))) end), o.growth, (case when (o.status & 0x100000 = 0) then 1 else 0 end), N'PRIMARY', RTRIM(o.name), RTRIM(o.filename) from dbo.sysfiles o where o.groupid = 0 and (o.status & 0x40) <> 0
   /* Other FileGroups, we should have DBFiles, no log files */

   insert #tempID select groupid from dbo.sysfilegroups where groupid <> 1

   declare @FGid int
	exec(N'declare hC cursor global for select cGroupID from #tempID')
	open hC
	fetch hC into @FGid
	while (@@fetch_status >= 0) begin
      insert #tempFG select 0, 1, (o.size * @PageSize)/1024, (case when (o.maxsize < 1) then o.maxsize else convert(int, ceiling(((convert(float, o.maxsize) * @PageSize)/1024))) end), o.growth, (case when (o.status & 0x100000 = 0) then 1 else 0 end), g.groupname, RTRIM(o.name), RTRIM(o.filename) from dbo.sysfiles o, dbo.sysfilegroups g where g.groupid = @FGid and g.groupid = o.groupid and (o.status & 0x40) = 0
      fetch hC into @FGid
   end
	deallocate hC

   select * from #tempFG
   DROP TABLE #tempFG

go
/* End sp_MSscriptdb_worker */

/*******************************************************************************/
/*******************************************************************************/
/* exec sp_MSdbuseraccess 'perm', 'dbname' -- selecting priv bit from specified db                       */
/* exec sp_MSdbuseraccess 'db', 'dbname'   -- select databases, need to change db if dbname is specified */
/* exec sp_MSdbuseraccess 'init', 'dbname' -- noop                                                       */
/*******************************************************************************/
print N''
print N'Creating sp_MSdbuseraccess'
print N''
go

create proc sp_MSdbuseraccess
	@mode nvarchar(10) = N'perm', @qual nvarchar(128) = N'%'
as
   set deadlock_priority low
   
   create table #TmpDbUserProfile (
      dbid        int NOT NULL PRIMARY KEY,
      accessperms int NOT NULL
      )

   create table #TmpOut (
      name        nvarchar(132) NOT NULL,
      version     smallint,
      crdate      datetime,
      owner       nvarchar(132),
      dbid        smallint NOT NULL,
      status      int,
      category    int,
      status2     int,
      fulltext    int,
      )

   set nocount on

   declare @accessbit int
	if (lower(@mode) like N'perm%') begin
      /* verify */
      declare @id int, @stat int, @inval int
      select @id = dbid, @stat = status from master.dbo.sysdatabases where name = @qual
      if (@id is null) begin
         RAISERROR (15001, -1, -1, @qual)
         return 1
      end

      /* Can we access this db? */
      declare @single int
      select @single = DATABASEPROPERTY( @qual, N'issingleuser' )
/*      if ((@single <> 0) or ((@stat & SQLDMODBStat_Inaccessible) <> 0)) begin  */
      if ((@single <> 0) or
         (DATABASEPROPERTY(@qual, N'isdetached') <> 0) or
         (DATABASEPROPERTY(@qual, N'isshutdown') <> 0) or
         (DATABASEPROPERTY(@qual, N'issuspect') <> 0) or
         (DATABASEPROPERTY(@qual, N'isoffline') <> 0) or
         (DATABASEPROPERTY(@qual, N'isinload') <> 0) or
         (DATABASEPROPERTY(@qual, N'isinrecovery') <> 0) or
         (DATABASEPROPERTY(@qual, N'isnotrecovered') <> 0)) begin
         select @inval = 0x80000000
         select @inval
         return 0
      end
      select @accessbit = has_dbaccess(@qual)
      if ( @accessbit <> 1) begin
         select @inval = 0x40000000
         select @inval
         return 0
      end

      /** OK, we can access this db, need to go to the specified database to get priv bit **/
      declare @dbTempname nvarchar(258)
      declare @tempindex int
      SELECT @dbTempname = REPLACE(@qual, N']', N']]')
      exec (N'[' + @dbTempname + N']' + N'..sp_MSdbuserpriv ')
      return 0
   end

   /* If 'db', we want to know if what kind of access we have to the specified databases */
   /* If we are not in master, then we are selecting single database, we want to correct role bit to save round trip */
   if (lower(@mode) like N'db%') begin
      /* Make sure we're either in master or only doing it to current db. */
      declare @dbrole int
      select @dbrole = 0x0000

      if (db_id() <> 1)
         select @qual = db_name()

      /* If dbname contains ', double it for the cursor, since cursor statement is inside of '' */
      declare @qual2 nvarchar(517)
      SELECT @qual2 = REPLACE(@qual, N'''', N'''''')

      /* Preprocessor won't replace within quotes so have to use str(). */
      declare @invalidlogin nvarchar(12)
      select @invalidlogin = ltrim(str(convert(int, 0x40000000), 11))
      declare @inaccessible nvarchar(12)
      select @inaccessible = ltrim(str(convert(int, 0x80000000), 11))

      /* We can't 'use' a database with a version below the minimum. */
      /* SQL6.0 minimum is 406; SQL65 requires 408.  SQL70 database version is 408 now, it might change later */
      declare @mindbver smallint
      if (@@microsoftversion >= 0x07000000)
         select @mindbver = 408
      else
         select @mindbver = 406

      /* Select all matching databases -- we want an entry even for inaccessible ones. */
      declare @dbid smallint, @dbidstr nvarchar(12), @dbstat int, @dbname nvarchar(258), @dbver smallint
      declare @dbbits int, @dbbitstr nvarchar(12)

      /* !!! work around here, if name contains '[', LIKE operator can't find it, since LIKE operator it treating '[' as a wild char */
      /* !!! but @qual2 might be '%', then = operator does not work */
      declare @temp int
      select @tempindex = charindex(N'[', @qual2)
      if (@tempindex <> 0)
         exec(N'declare hCdbs cursor global for select name, dbid, status, version from master.dbo.sysdatabases where name = N''' + @qual2 + N'''')
      else
         exec(N'declare hCdbs cursor global for select name, dbid, status, version from master.dbo.sysdatabases where name like N''' + @qual2 + N'''')

      open hCdbs

      /* Loop for each database, and if it's accessible, recursively call ourselves to add it. */
      fetch hCdbs into @dbname, @dbid, @dbstat, @dbver
      while (@@fetch_status >= 0) begin
         /* Preprocessor won't replace within quotes so have to use str(). */
         select @dbidstr = ltrim(str(convert(int, @dbid)))

         /* If it's a single user db and there's an entry for it in sysprocesses who isn't us, we can't use it. */
         declare @single_lockedout int
         select @single_lockedout = DATABASEPROPERTY( @dbname, N'issingleuser' )
         if (@single_lockedout <> 0)
            select @single_lockedout = 0 where not exists
               (select * from master.dbo.sysprocesses p where dbid = @dbid and p.spid <> @@spid)

         /* First see if the db is accessible (not in load, recovery, offline, single-use with another user besides us, etc.) */
/*         if ((@single_lockedout <> 0) or ((@dbstat & SQLDMODBStat_Inaccessible) <> 0) or (@dbver < @mindbver)) begin   */
         if ((@single_lockedout <> 0) or
            (@dbver < @mindbver) or
            (DATABASEPROPERTY(@dbname, N'isdetached') <> 0) or
            (DATABASEPROPERTY(@dbname, N'isshutdown') <> 0) or
            (DATABASEPROPERTY(@dbname, N'issuspect') <> 0) or
            (DATABASEPROPERTY(@dbname, N'isoffline') <> 0) or
            (DATABASEPROPERTY(@dbname, N'isinload') <> 0) or
            (DATABASEPROPERTY(@dbname, N'isinrecovery') <> 0) or
            (DATABASEPROPERTY(@dbname, N'isnotrecovered') <> 0) ) begin
            /* Inaccessible, but we can set dbo if we're sa or suser_id() is db owner sid. */
            exec (N'insert #TmpDbUserProfile values (' + @dbidstr + N', ' + @inaccessible + N')')
            end
         else begin
            /* Find out whether the current user has access to the database */
            select @accessbit = has_dbaccess(@dbname)
            if ( @accessbit <> 1) begin
               exec (N'insert #TmpDbUserProfile values (' + @dbidstr + N', ' + @invalidlogin + N')')
               end
            else begin
               /* Yes, current user does have access to this database, we are not trying to get priv at this point */
               select @dbbits = 0x03ff
               select @dbbitstr = ltrim(convert(nvarchar(12), @dbbits))
               exec (N'insert #TmpDbUserProfile values (' + @dbidstr + N', ' + @dbbitstr + N')')
               end
            end

         fetch hCdbs into @dbname, @dbid, @dbstat, @dbver
      end /* while FETCH_SUCCESS */
      close hCdbs
      deallocate hCdbs

      /* Select sysdatabases info into temp table first to avoid deadlock in restore process */
      if (@tempindex <> 0)
         insert #TmpOut
         select o.name, o.version, o.crdate, suser_sname(o.sid), o.dbid, o.status, o.category, o.status2, DatabaseProperty(o.name, N'isfulltextenabled')
            from master.dbo.sysdatabases o where o.name = @qual
      else
         insert #TmpOut
         select o.name, o.version, o.crdate, suser_sname(o.sid), o.dbid, o.status, o.category, o.status2, DatabaseProperty(o.name, N'isfulltextenabled')
            from master.dbo.sysdatabases o where o.name like @qual

      /* 1. If on all databases, then dbrole is dummy, need to get it later */
      /* 2. Do not double the ' character(s) in database name */
      /* 3. To speed up connection, accessperms column only indicate whether the login user can access the db, it does not contain */
      /*    permission info, we will retrieve the permission info through sp_MSdbuserpriv when necessary */
      /* !!! work around here, if name contains '[', LIKE operator can't find it, since LIKE operator it treating '[' as a wild char */
      /* !!! but @qual2 might be '%', then = operator does not work */
      if (@tempindex <> 0)
         select o.name, o.version, o.crdate, o.owner, o.dbid, lSize = 0, NonDbo = 0, Status = o.status, spaceavail = 0,
            LogOnSepDev = 1, o.category, t.accessperms, @dbrole, o.fulltext, o.status2,
            collation = convert(sysname, databasepropertyex(o.name, N'collation'))
            from #TmpOut o left outer join #TmpDbUserProfile t on t.dbid = o.dbid where o.name = @qual order by o.name
      else
         select o.name, o.version, o.crdate, o.owner, o.dbid, lSize = 0, NonDbo = 0, Status = o.status, spaceavail = 0,
            LogOnSepDev = 1, o.category, t.accessperms, @dbrole, o.fulltext, o.status2,
            collation = convert(sysname, databasepropertyex(o.name, N'collation'))
            from #TmpOut o left outer join #TmpDbUserProfile t on t.dbid = o.dbid where o.name like @qual order by o.name

      DROP TABLE #TmpDbUserProfile
      DROP TABLE #TmpOut
      return 0
   end
go
/* End sp_MSdbuseraccess */


/*******************************************************************************/
/* exec sp_MSdbuserpriv 'serv'  -- selecting the server (master db) user profile, just create db priv, if sa, 7 */
/* exec sp_MSdbuserpriv 'role'  -- selecting role membership for current db                                     */
/* exec sp_MSdbuserpriv 'ver'   -- selectversion70                                                              */
/* exec sp_MSdbuserpriv 'perm'  -- selecting user priv bit for the current db                                   */
/*******************************************************************************/
print N''
print N'Creating sp_MSdbuserpriv'
print N''
go

create proc sp_MSdbuserpriv
	@mode nvarchar(10) = N'perm'
as

/* Order of privilege evaluation is:  user granted/revoked, then group granted/revoked, then public granted/revoked */









   set nocount on
   declare @bits int, @status int, @prot int, @perms int
   declare @dbrole int, @dbrolestr nvarchar(12)

   /* If 'srv', we're selecting the server (master db) user profile - currently, just create db priv. */
   if (lower(@mode) like N'serv%')
      begin
      select @bits = 0x0000
      if (user_id() = 1 or is_srvrolemember(N'sysadmin') = 1 or is_member(N'db_owner') = 1)
         begin
         /* sa has everything */
         select @bits = 0x0007
         end
      else begin
         if ((PERMISSIONS() & 1) > 0)
            SELECT @bits = @bits | 0x0002
         if ((PERMISSIONS(OBJECT_ID(N'sp_addextendedproc')) & 32) > 0)
            SELECT @bits = @bits | 0x0004
         end
      select @bits
      return 0
      end

   /* If 'perm', we're selecting the current database priv and role membership for the login user. */
	if (lower(@mode) like N'role%' or lower(@mode) like N'ver%' or lower(@mode) like N'perm%')
      begin
      if (user_id() = 1 or is_srvrolemember(N'sysadmin') = 1 or is_member(N'db_owner') = 1)
         begin
         /* sa/Dbo has everything. */
         select @bits = 0x03ff
         end
      else begin
         /* Not dbo so get individual privileges */
         select @bits = 0x0000, @perms = PERMISSIONS(), @status = status from dbo.sysusers where uid = user_id()

         if ((@perms & 2) > 0)
            SELECT @bits = @bits | 0x0002
         if ((@perms & 8) > 0)
            SELECT @bits = @bits | 0x0004
         if ((@perms & 4) > 0)
            SELECT @bits = @bits | 0x0008
         if ((@perms & 64) > 0)
            SELECT @bits = @bits | 0x0010
         if ((@perms & 32) > 0)
            SELECT @bits = @bits | 0x0020
         if ((@perms & 128) > 0)
            SELECT @bits = @bits | 0x0040
         if ((@perms & 16) > 0)
            SELECT @bits = @bits | 0x0080
         if ((@perms & 256) > 0)
            SELECT @bits = @bits | 0x0100
         if ((@perms & 512) > 0)
            SELECT @bits = @bits | 0x0200
         end

      /* Get both Server and Database Role information */
      select @dbrole = 0x0000
      /* Server Roles */
      select @dbrole = (case when (is_srvrolemember(N'dbcreator') = 1) then @dbrole | 0x0001 else @dbrole end),
             @dbrole = (case when (is_srvrolemember(N'diskadmin') = 1) then @dbrole | 0x0002 else @dbrole end),
             @dbrole = (case when (is_srvrolemember(N'processadmin') = 1) then @dbrole | 0x0004 else @dbrole end),
             @dbrole = (case when (is_srvrolemember(N'securityadmin') = 1) then @dbrole | 0x0008 else @dbrole end),
             @dbrole = (case when (is_srvrolemember(N'serveradmin') = 1) then @dbrole | 0x0010 else @dbrole end),
             @dbrole = (case when (is_srvrolemember(N'setupadmin') = 1) then @dbrole | 0x0020 else @dbrole end),
             @dbrole = (case when (is_srvrolemember(N'sysadmin') = 1) then @dbrole | 0x0040 else @dbrole end),
             @dbrole = (case when (is_srvrolemember(N'bulkadmin') = 1) then @dbrole | 0x10000 else @dbrole end),
      /* Database Roles */
             @dbrole = (case when (is_member(N'db_accessadmin') = 1) then @dbrole | 0x0080 else @dbrole end),
             @dbrole = (case when (is_member(N'db_datareader') = 1) then @dbrole | 0x0100 else @dbrole end),
             @dbrole = (case when (is_member(N'db_ddladmin') = 1) then @dbrole | 0x0200 else @dbrole end),
             @dbrole = (case when (is_member(N'db_denydatareader') = 1) then @dbrole | 0x0400 else @dbrole end),
             @dbrole = (case when (is_member(N'db_denydatawriter') = 1) then @dbrole | 0x0800 else @dbrole end),
             @dbrole = (case when (is_member(N'db_backupoperator') = 1) then @dbrole | 0x1000 else @dbrole end),
             @dbrole = (case when (is_member(N'db_owner') = 1) then @dbrole | 0x2000 else @dbrole end),
             @dbrole = (case when (is_member(N'db_securityadmin') = 1) then @dbrole | 0x4000 else @dbrole end),
             @dbrole = (case when (is_member(N'db_datawriter') = 1) then @dbrole | 0x8000 else @dbrole end)

      if (lower(@mode) like N'ver%')
         begin
/* 7.0
         select @@version, N'login_id' = convert(int, suser_sid()), N'pagesize' = v.low, N'highbit' = v2.low, N'highbyte' = v3.low,
            N'casesens' = (case when (N'A' != N'a') then 1 else 0 end), @@spid, @@servername, is_srvrolemember(N'sysadmin'), @dbrole
            from master..spt_values v,master..spt_values v2,master..spt_values v3 where v.number=1 and v.type=N'E' and v2.number=2
            and v2.type=N'E' and v3.number=3 and v3.type=N'E'
*/
         select @@version, N'login_id' = convert(int, suser_sid()), N'pagesize' = v.low, N'highbit' = v2.low, N'highbyte' = v3.low,
            N'casesens' = (case when (N'A' != N'a') then 1 else 0 end), @@spid, convert(sysname, serverproperty(N'servername')),
            is_srvrolemember(N'sysadmin'), @dbrole,
            N'InstanceName' = convert(sysname, serverproperty(N'instancename')),
            N'PID' = convert(int, serverproperty(N'processid'))
            from master..spt_values v,master..spt_values v2,master..spt_values v3 where v.number=1 and v.type=N'E' and v2.number=2
            and v2.type=N'E' and v3.number=3 and v3.type=N'E'
         end
      else if (lower(@mode) like N'role%')
         begin
         select @dbrole
         end
      else if (lower(@mode) like N'perm%')
         begin
         select @bits
         end
      return 0
      end
go
/* End sp_MSdbuserpriv */


/*******************************************************************************/
print N''
print N'Creating sp_MShelpfulltextindex'
print N''
go

create proc sp_MShelpfulltextindex
   @tablename nvarchar(517)
as

	create table #sphelpft
      (
  	   ind_name   nvarchar(128) COLLATE database_default NOT NULL,
      col1       nvarchar(128) COLLATE database_default,
      col2       nvarchar(128) COLLATE database_default,
      col3       nvarchar(128) COLLATE database_default,
      col4       nvarchar(128) COLLATE database_default,
      col5       nvarchar(128) COLLATE database_default,
      col6       nvarchar(128) COLLATE database_default,
      col7       nvarchar(128) COLLATE database_default,
      col8       nvarchar(128) COLLATE database_default,
      col9       nvarchar(128) COLLATE database_default,
      col10      nvarchar(128) COLLATE database_default,
      col11      nvarchar(128) COLLATE database_default,
      col12      nvarchar(128) COLLATE database_default,
      col13      nvarchar(128) COLLATE database_default,
      col14      nvarchar(128) COLLATE database_default,
      col15      nvarchar(128) COLLATE database_default,
      col16      nvarchar(128) COLLATE database_default
      )

   set nocount on

   /* all the possible full text unique indexes */
   declare @objid int
   select @objid = object_id(@tablename, N'local')
  	insert #sphelpft
         select i.name,
         columnproperty( @objid, index_col(@tablename, i.indid, 1), N'AllowsNull'),
         columnproperty( @objid, index_col(@tablename, i.indid, 2), N'AllowsNull'),
         columnproperty( @objid, index_col(@tablename, i.indid, 3), N'AllowsNull'),
         columnproperty( @objid, index_col(@tablename, i.indid, 4), N'AllowsNull'),
         columnproperty( @objid, index_col(@tablename, i.indid, 5), N'AllowsNull'),
         columnproperty( @objid, index_col(@tablename, i.indid, 6), N'AllowsNull'),
         columnproperty( @objid, index_col(@tablename, i.indid, 7), N'AllowsNull'),
         columnproperty( @objid, index_col(@tablename, i.indid, 8), N'AllowsNull'),
         columnproperty( @objid, index_col(@tablename, i.indid, 9), N'AllowsNull'),
         columnproperty( @objid, index_col(@tablename, i.indid, 10), N'AllowsNull'),
         columnproperty( @objid, index_col(@tablename, i.indid, 11), N'AllowsNull'),
         columnproperty( @objid, index_col(@tablename, i.indid, 12), N'AllowsNull'),
         columnproperty( @objid, index_col(@tablename, i.indid, 13), N'AllowsNull'),
         columnproperty( @objid, index_col(@tablename, i.indid, 14), N'AllowsNull'),
         columnproperty( @objid, index_col(@tablename, i.indid, 15), N'AllowsNull'),
         columnproperty( @objid, index_col(@tablename, i.indid, 16), N'AllowsNull')
         from dbo.sysindexes i where
         @objid = i.id and
         IndexProperty(@objid, i.name, N'IsUnique') = 1 and
         IndexProperty(@objid, i.name, N'UserKeyCount') = 1 and
         /* 450 byte MAX */
         exists (select * from dbo.syscolumns where id = @objid and name = Index_col(@tablename, IndexProperty(@objid, i.name, N'IndexId'), 1)
                 and length <= 450)

   /* Now we need to filter out the indexes which the associated key(s) are nullable */
   /* Each index can have up to 16 associated keys, all of them need to be non-nullalbe for the index to be qualified as a full text index */
   delete #sphelpft where col1 = 1 or col2 = 1 or col3 = 1 or col4 = 1 or col5 = 1 or col6 = 1 or col7 = 1 or col8 = 1 or
                          col9 = 1 or col10 = 1 or col11 = 1 or col12 = 1 or col13 = 1 or col14 = 1 or col15 = 1 or col16 = 1

   select ind_name from #sphelpft
   DROP TABLE #sphelpft

go
/* End sp_MShelpfulltextindex */

/*******************************************************************************/
print N''
print N'Creating sp_MShelpfulltextscript'
print N''
go

create proc sp_MShelpfulltextscript
   @tablename nvarchar(517)
as
   set nocount on

	declare @objid int
	select @objid = object_id(@tablename)
	if (@objid is null)
	begin
		RAISERROR (15001, -1, -1, @tablename)
		return 1
	end

   /* prepare the information for fulltext index scripting */
   declare @activate    int
   select @activate = OBJECTPROPERTY(@objid, N'TableFulltextCatalogId')
	if (@activate <> 0)
      begin
      declare @uniqueindex nvarchar(128)
      declare @catname     nvarchar(128)

      /* get unique index name */
      select @uniqueindex = i.name from dbo.sysindexes i where @objid = i.id and IndexProperty(@objid, i.name, N'IsFulltextKey') = 1
      /* get catalog name */
      select @catname = f.name from dbo.sysfulltextcatalogs f, dbo.sysobjects o where f.ftcatid = o.ftcatid and o.id = @objid
      if (@uniqueindex is not null and @catname is not null)
         begin
         /* is this table fulltext index activated? */
         select @activate = OBJECTPROPERTY(@objid, N'TableHasActiveFulltextIndex')
         select @uniqueindex, @catname, @activate
         end
      end

go
/* End sp_MShelpfulltextscript */

/*******************************************************************************/
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

/*******************************************************************************/
print N''
print N'Creating sp_MSGetServerProperties'
print N''
go

create proc sp_MSGetServerProperties
as
   set nocount on

   DECLARE @auto_start                  INT
   DECLARE @startup_account             NVARCHAR(100)

   -- Read the values from the registry
   IF ((PLATFORM() & 0x1) = 0x1) -- NT
   BEGIN
      EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                             N'SYSTEM\CurrentControlSet\Services\MSSQLServer',
                                             N'Start',
                                             @auto_start OUTPUT,
                                             N'no_output'
      EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE',
                                             N'SYSTEM\CurrentControlSet\Services\MSSQLServer',
                                             N'ObjectName',
                                             @startup_account OUTPUT,
                                             N'no_output'
   END ELSE
   BEGIN
      SELECT @auto_start = 3 -- Manual start
      SELECT @startup_account = NULL
   END

   -- Return the values to the client
   SELECT auto_start = CASE @auto_start
                       WHEN 2 THEN 1 -- 2 means auto-start
                       WHEN 3 THEN 0 -- 3 means don't auto-start
                       ELSE 0        -- Safety net
                       END,
          startup_account = @startup_account

go
/* End sp_MSGetServerProperties */


/*******************************************************************************/
print N''
print N'Creating fn_MSFullText'
print N''
go

create function fn_MSFullText()
returns @retTab table(LCID int)
as
begin
   declare @tempLang table(LCID int)
   insert @tempLang values (2052)  /* Chinese_Simplified */
   insert @tempLang values (1028)  /* Chinese_Traditional */
   insert @tempLang values (1043)  /* Dutch */
   insert @tempLang values (2057)  /* English_UK */
   insert @tempLang values (1033)  /* English_US */
   insert @tempLang values (1036)  /* French */
   insert @tempLang values (1031)  /* German */
   insert @tempLang values (1040)  /* Italian */
   insert @tempLang values (1041)  /* Japanese */
   insert @tempLang values (1042)  /* Korean */
   insert @tempLang values (0)     /* Neutral */
   insert @tempLang values (1053)  /* Swedish_Default */

   insert @retTab select * from @tempLang
return
end
go
/* End fn_MSFullText */


/*******************************************************************************/
print N''
print N'Creating sp_MSSharedFixedDisk'
print N''
go

create proc sp_MSSharedFixedDisk
as
   set nocount on

   create table #Tmp1
      (
      name         nvarchar(132),
      low          int,
      high         int,
      media        int,
      )
   create table #Tmp2
      (
      drivename    nvarchar(132),
      )
   declare @DriveName nvarchar(132)

   declare hC cursor global for select * from ::fn_servershareddrives()
   open hC
   fetch next from hC into @DriveName
   while (@@FETCH_STATUS = 0)
      begin
      insert #Tmp2 select @DriveName
      fetch next from hC into @DriveName
      end
   close hC
   deallocate hC

   insert into #Tmp1
   execute master.dbo.xp_availablemedia 15

   select 'name' = name, 'low free' = low, 'high free' = high, 'media type' = media from #Tmp1, #Tmp2
          where (SUBSTRING(#Tmp1.name, 1, 1)) like (SUBSTRING(#Tmp2.drivename, 1, 1))

go
/* End sp_MSSharedFixedDisk */


/********************* Grant privileges *********************************/
print N''
print N'Granting execute permissions on procedures'
print N''
go

/**  Mark all the SPs as system objects **/
exec sp_MS_marksystemobject sp_MShelpcolumns
go
exec sp_MS_marksystemobject sp_MShelpindex
go
exec sp_MS_marksystemobject sp_MShelptype
go
exec sp_MS_marksystemobject sp_MSdependencies
go
exec sp_MS_marksystemobject sp_MStablespace
go
exec sp_MS_marksystemobject sp_MSindexspace
go
exec sp_MS_marksystemobject sp_MStablerefs
go
exec sp_MS_marksystemobject sp_MStablekeys
go
exec sp_MS_marksystemobject sp_MStablechecks
go
exec sp_MS_marksystemobject sp_MSsettopology
go
exec sp_MS_marksystemobject sp_MSmatchkey
go
exec sp_MS_marksystemobject sp_MSforeach_worker
go
exec sp_MS_marksystemobject sp_MSforeachdb
go
exec sp_MS_marksystemobject sp_MSforeachtable
go
exec sp_MS_marksystemobject sp_MSloginmappings
go
exec sp_MS_marksystemobject sp_MSuniquename
go
exec sp_MS_marksystemobject sp_MSkilldb
go
exec sp_MS_marksystemobject sp_MSobjectprivs
go
exec sp_MS_marksystemobject sp_MSSQLDMO80_version
go
exec sp_MS_marksystemobject sp_MSSQLDMO70_version
go
exec sp_MS_marksystemobject sp_MSSQLOLE65_version
go
exec sp_MS_marksystemobject sp_MSSQLOLE_version
go
exec sp_MS_marksystemobject sp_MSscriptdatabase
go
exec sp_MS_marksystemobject sp_MSscriptdb_worker
go
exec sp_MS_marksystemobject sp_MSdbuseraccess
go
exec sp_MS_marksystemobject sp_MSdbuserpriv
go
exec sp_MS_marksystemobject sp_MShelpfulltextindex
go
exec sp_MS_marksystemobject sp_MShelpfulltextscript
go
exec sp_MS_marksystemobject sp_MSSetServerProperties
go
exec sp_MS_marksystemobject sp_MSGetServerProperties
go
exec sp_MS_marksystemobject fn_MSFullText
go
exec sp_MS_marksystemobject sp_MSSharedFixedDisk
go

grant execute on sp_MShelpcolumns to public
grant execute on sp_MShelpindex to public
grant execute on sp_MShelptype to public
grant execute on sp_MSdependencies to public
grant execute on sp_MStablespace to public
grant execute on sp_MSindexspace to public
grant execute on sp_MSuniquename to public
grant execute on sp_MSkilldb to public
grant execute on sp_MSobjectprivs to public
grant execute on sp_MSloginmappings to public
grant execute on sp_MStablekeys to public
grant execute on sp_MStablechecks to public
grant execute on sp_MStablerefs to public
grant execute on sp_MSsettopology to public
grant execute on sp_MSmatchkey to public
grant execute on sp_MSforeachdb to public
grant execute on sp_MSforeachtable to public
grant execute on sp_MSforeach_worker to public
grant execute on sp_MSSQLOLE_version to public
grant execute on sp_MSSQLOLE65_version to public
grant execute on sp_MSSQLDMO70_version to public
grant execute on sp_MSSQLDMO80_version to public
grant execute on sp_MSscriptdatabase to public
grant execute on sp_MSscriptdb_worker to public
grant execute on sp_MSdbuseraccess to public
grant execute on sp_MSdbuserpriv to public
grant execute on sp_MShelpfulltextindex to public
grant execute on sp_MShelpfulltextscript to public
grant execute on sp_MSGetServerProperties to public
grant select  on fn_MSFullText to public
grant execute on sp_MSSharedFixedDisk to public

go

















/********************* Delete existing objects *********************************/
print ''
print 'Deleting existing objects...'
print ''
go

if exists (select * from master..sysobjects where sysstat & 0x0f = 4 and name = 'sp_MSfilterclause')
	drop procedure sp_MSfilterclause
go

/********************* Create new objects *********************************/

print ''
print 'Creating sp_MSfilterclause'
print ''
go

create procedure sp_MSfilterclause
	@publication nvarchar(258), @article nvarchar(258)
as
	/* Return a text column as multiple readtexts of maxcol length */
	declare @pubid int, @artid int
	select @pubid = pubid from syspublications where name = @publication
	if (@pubid is null) begin
		RAISERROR (15001, 11, -1, @publication)
		return 1
	end
	select @artid = artid from sysarticles where name = @article and pubid = @pubid
	if (@artid is null) begin
		RAISERROR (15001, 11, -1, @article)
		return 1
	end

	declare @val varbinary(16), @len int, @ii int, @chunk int
	-- filter clause is in unicode, the length is a half of the number of bytes.
	select @val = textptr(filter_clause), @len = datalength(filter_clause)/2 from sysarticles where artid = @artid and pubid = @pubid
	select @ii = 0, @chunk = 255

	/* Get all the rows of an maxcol size */
	while @len > @chunk begin
		readtext sysarticles.filter_clause @val @ii @chunk
		select @ii = @ii + @chunk, @len = @len - @chunk
	end

	/* Get the last chunk */
	if (@len > 0)
		readtext sysarticles.filter_clause @val @ii @len
	return 0
go
/* End sp_MSfilterclause */

/*-----------------------------------------------------*/
/*-----------------------------------------------------*/

/********************* Grant privileges *********************************/
print ''
print 'Granting execute permissions on procedures'
print ''
go

exec sp_MS_marksystemobject sp_MSfilterclause
go

grant execute on sp_MSfilterclause to public














/********************* Delete existing objects *********************************/
print N''
print N'Deleting existing objects...'
print N''
go

if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = 'sp_MSgetalertinfo')
	drop procedure sp_MSgetalertinfo
go
if exists (select * from master.dbo.sysobjects where (OBJECTPROPERTY(id, N'IsProcedure') = 1 or OBJECTPROPERTY(id, N'IsExtendedProc') = 1) and name = 'sp_MSsetalertinfo')
	drop procedure sp_MSsetalertinfo
go

/********************* Create new objects *********************************/

print N''
print N'Creating sp_MSgetalertinfo'
print N''
go
create procedure sp_MSgetalertinfo
	@includeaddresses bit = 0
as
	/* Return all alert info at one go, for performance reasons. */
	declare @FailSafeOperator nvarchar(255)
	declare @NotificationMethod int
	declare @ForwardingServer nvarchar(255)
	declare @ForwardingSeverity int
	declare @ForwardAlways int
	declare @PagerToTemplate nvarchar(255)
	declare @PagerCCTemplate nvarchar(255)
	declare @PagerSubjectTemplate nvarchar(255)
	declare @PagerSendSubjectOnly int
	declare @FailSafeEmailAddress nvarchar(255)
	declare @FailSafePagerAddress nvarchar(255)
	declare @FailSafeNetSendAddress nvarchar(255)

	exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'AlertFailSafeOperator', @param = @FailSafeOperator OUT, @no_output = N'no_output'
	exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'AlertNotificationMethod', @param = @NotificationMethod OUT, @no_output = N'no_output'
	exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'AlertForwardingServer', @param = @ForwardingServer OUT, @no_output = N'no_output'
	exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'AlertForwardingSeverity', @param = @ForwardingSeverity OUT, @no_output = N'no_output'
	exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'AlertForwardAlways', @param = @ForwardAlways OUT, @no_output = N'no_output'
	exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'AlertPagerToTemplate', @param = @PagerToTemplate OUT, @no_output = N'no_output'
	exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'AlertPagerCCTemplate', @param = @PagerCCTemplate OUT, @no_output = N'no_output'
	exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'AlertPagerSubjectTemplate', @param = @PagerSubjectTemplate OUT, @no_output = N'no_output'
	exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'AlertPagerSendSubjectOnly', @param = @PagerSendSubjectOnly OUT, @no_output = N'no_output'

	if (@includeaddresses <> 0) begin
		exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'AlertFailSafeEmailAddress', @param = @FailSafeEmailAddress OUT, @no_output = N'no_output'
		exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'AlertFailSafePagerAddress', @param = @FailSafePagerAddress OUT, @no_output = N'no_output'
		exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'AlertFailSafeNetSendAddress', @param = @FailSafeNetSendAddress OUT, @no_output = N'no_output'
	end

	select
		AlertFailSafeOperator = @FailSafeOperator,
		AlertNotificationMethod = @NotificationMethod,
		AlertForwardingServer = @ForwardingServer,
		AlertForwardingSeverity = @ForwardingSeverity,
		AlertPagerToTemplate = @PagerToTemplate,
		AlertPagerCCTemplate = @PagerCCTemplate,
		AlertPagerSubjectTemplate = @PagerSubjectTemplate,
		AlertPagerSendSubjectOnly = @PagerSendSubjectOnly,
		AlertForwardAlways = ISNULL(@ForwardAlways, 0)

	if (@includeaddresses <> 0)
		select
			AlertFailSafeEmailAddress = @FailSafeEmailAddress,
			AlertFailSafePagerAddress = @FailSafePagerAddress,
			AlertFailSafeNetSendAddress = @FailSafeNetSendAddress
go
/* End sp_MSgetalertinfo */

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

/********************* Grant privileges *********************************/
print N''
print N'Granting execute permissions on procedures'
print N''
go

exec sp_MS_marksystemobject sp_MSgetalertinfo
go
exec sp_MS_marksystemobject sp_MSsetalertinfo
go

grant execute on sp_MSgetalertinfo to public


/********************** Verify object creation and update category bit for objects *********************************/





print ''
print 'Updating category for objects created by SQLDMO70.sql.'
print ''
go

sp_configure 'allow updates', 1
go
reconfigure with override
go

/* if (@@microsoftversion >= SQL70_MINVERSION) begin                                      */
/* 	exec sp_MS_upd_sysobj_category 2                                                    */
/* end else begin                                                                         */
/* 	RAISERROR 55555 'You need a released version of SQL 8.0 to run this SQLDMO script'  */
/* end                                                                                    */
if (@@microsoftversion < 0x08000000) begin
	RAISERROR 55555 'You need a released version of SQL 8.0 to run this SQLDMO script'
end
go

sp_configure 'allow updates', 0
go
reconfigure with override
go

if (object_id('sp_MSSQLDMO80_version') is not null) begin
	print ''
	print ''
	print ' Successful installation.'
	exec sp_MSSQLDMO80_version
end

/************* DUMP THE TRANSACTION LOG **************************************/
/* Comment this out if you don't want your log dumped.  If you rerun this    */
/* script periodically, you will run out of transaction log space.           */
print ''
print 'Dumping transaction log...'
print ''
go
dump tran master with no_log
go
checkpoint
go
/************* END DUMP THE TRANSACTION LOG **********************************/

