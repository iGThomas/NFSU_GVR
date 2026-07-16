/*
** Copyright Microsoft, Inc. 1994 - 2000
** All Rights Reserved.
*/
-- - ---------- MSSQL 7.0  ANSIVIEW.SQL 1992 System Views
set nocount on
go
use master		-- THESE NOW EXIST IN MASTER ONLY!
go

-- THESE ARE "SYSTEM" OBJECTS --
exec sp_configure 'allow', 1
reconfigure with override
go
exec sp_MS_upd_sysobj_category 1
go

-- INFORMATION_SCHEMA login no longer exists...
-- INFORMATION_SCHEMA user is added by hand here:
if user_id('INFORMATION_SCHEMA') is NULL
	INSERT sysusers VALUES (3, 0, 'INFORMATION_SCHEMA', NULL, 0x00, getdate(), getdate(), 0, NULL)
go
-- NO NEED TO GRANT CREATE VIEW TO INFORMATION_SCHEMA

if object_id('INFORMATION_SCHEMA.SCHEMATA', 'V') is not NULL
	drop view INFORMATION_SCHEMA.SCHEMATA

if object_id('INFORMATION_SCHEMA.TABLES', 'V') is not NULL
	drop view INFORMATION_SCHEMA.TABLES

if object_id('INFORMATION_SCHEMA.TABLE_CONSTRAINTS', 'V') is not NULL
	drop view INFORMATION_SCHEMA.TABLE_CONSTRAINTS

if object_id('INFORMATION_SCHEMA.TABLE_PRIVILEGES', 'V') is not NULL
	drop view INFORMATION_SCHEMA.TABLE_PRIVILEGES

if object_id('INFORMATION_SCHEMA.COLUMNS', 'V') is not NULL
	drop view INFORMATION_SCHEMA.COLUMNS

if object_id('INFORMATION_SCHEMA.COLUMN_DOMAIN_USAGE', 'V') is not NULL
	drop view INFORMATION_SCHEMA.COLUMN_DOMAIN_USAGE

if object_id('INFORMATION_SCHEMA.COLUMN_PRIVILEGES', 'V') is not NULL
	drop view INFORMATION_SCHEMA.COLUMN_PRIVILEGES

if object_id('INFORMATION_SCHEMA.DOMAINS', 'V') is not NULL
	drop view INFORMATION_SCHEMA.DOMAINS

if object_id('INFORMATION_SCHEMA.DOMAIN_CONSTRAINTS', 'V') is not NULL
	drop view INFORMATION_SCHEMA.DOMAIN_CONSTRAINTS

if object_id('INFORMATION_SCHEMA.KEY_COLUMN_USAGE', 'V') is not NULL
	drop view INFORMATION_SCHEMA.KEY_COLUMN_USAGE

if object_id('INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS', 'V') is not NULL
	drop view INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS

if object_id('INFORMATION_SCHEMA.CHECK_CONSTRAINTS', 'V') is not NULL
	drop view INFORMATION_SCHEMA.CHECK_CONSTRAINTS

if object_id('INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE', 'V') is not NULL
	drop view INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE

if object_id('INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE', 'V') is not NULL
	drop view INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE

if object_id('INFORMATION_SCHEMA.VIEWS', 'V') is not NULL
	drop view INFORMATION_SCHEMA.VIEWS

if object_id('INFORMATION_SCHEMA.VIEW_TABLE_USAGE', 'V') is not NULL
	drop view INFORMATION_SCHEMA.VIEW_TABLE_USAGE

if object_id('INFORMATION_SCHEMA.VIEW_COLUMN_USAGE', 'V') is not NULL
	drop view INFORMATION_SCHEMA.VIEW_COLUMN_USAGE

if object_id('INFORMATION_SCHEMA.ROUTINES', 'V') is not NULL
	drop view INFORMATION_SCHEMA.ROUTINES

if object_id('INFORMATION_SCHEMA.PARAMETERS', 'V') is not NULL
	drop view INFORMATION_SCHEMA.PARAMETERS

if object_id('INFORMATION_SCHEMA.ROUTINE_COLUMNS', 'V') is not NULL
	drop view INFORMATION_SCHEMA.ROUTINE_COLUMNS
go


raiserror(15339,-1,-1,'INFORMATION_SCHEMA.SCHEMATA')
go

--Identifies schmata owned by current users, databases current users has permissions in
create view INFORMATION_SCHEMA.SCHEMATA
 as
select
	db.name						as CATALOG_NAME
	,USER_NAME()				as SCHEMA_NAME
	,USER_NAME()				as SCHEMA_OWNER
	,convert(sysname, NULL)		as DEFAULT_CHARACTER_SET_CATALOG
	,convert(sysname, NULL)		as DEFAULT_CHARACTER_SET_SCHEMA
	,a_cha.name					as DEFAULT_CHARACTER_SET_NAME
FROM
	master.dbo.sysdatabases 		db,
	master.dbo.syscharsets		a_cha --charset/1001, not sortorder.
WHERE
	a_cha.type = 1001 --- type is charset
	AND a_cha.id = convert(tinyint, DatabasePropertyEx(db.name, 'sqlcharset'))
go

grant select on INFORMATION_SCHEMA.SCHEMATA to public
go

raiserror(15339,-1,-1,'INFORMATION_SCHEMA.TABLES')
go
--Identifies tables accessible to the current user
create view INFORMATION_SCHEMA.TABLES
as 
select  distinct
	db_name()			as TABLE_CATALOG
	,user_name(o.uid)	as TABLE_SCHEMA
	,o.name				as TABLE_NAME
	,case o.xtype
		when 'U' then 'BASE TABLE'
		when 'V' then 'VIEW'
	end					as TABLE_TYPE
from
	sysobjects o
where
	o.xtype in ('U', 'V') and
	permissions(o.id) != 0
go

grant select on INFORMATION_SCHEMA.TABLES to public
go

raiserror(15339,-1,-1,'INFORMATION_SCHEMA.TABLE_CONSTRAINTS')
go
--Identifies table constraints for tables where the current user has any permissions on object.
create view INFORMATION_SCHEMA.TABLE_CONSTRAINTS
 as
 select
	db_name()				as CONSTRAINT_CATALOG
	,user_name(c_obj.uid)	as CONSTRAINT_SCHEMA
	,c_obj.name				as CONSTRAINT_NAME
	,db_name()				as TABLE_CATALOG
	,user_name(t_obj.uid)	as TABLE_SCHEMA
	,t_obj.name				as TABLE_NAME
	,case c_obj.xtype
					when 'C' then	'CHECK'
					when 'UQ' then	'UNIQUE'
					when 'PK' then	'PRIMARY KEY'
					when 'F' then	'FOREIGN KEY'
		 		  end		as CONSTRAINT_TYPE
	,'NO'					as IS_DEFERRABLE
	,'NO'					as INITIALLY_DEFERRED
from
	sysobjects	c_obj
	,sysobjects	t_obj
where
	permissions(t_obj.id) != 0
	and t_obj.id	= c_obj.parent_obj
	and c_obj.xtype	in ('C' ,'UQ' ,'PK' ,'F')
go

grant select on INFORMATION_SCHEMA.TABLE_CONSTRAINTS to public
go

raiserror(15339,-1,-1,'INFORMATION_SCHEMA.TABLE_PRIVILEGES')
go
--Identifies privileges granted to or by the current user
create view INFORMATION_SCHEMA.TABLE_PRIVILEGES
 as
select	
	user_name(p.grantor)	as GRANTOR
	,user_name(p.uid)		as GRANTEE
	,db_name()				as TABLE_CATALOG
	,user_name(o.uid)		as TABLE_SCHEMA
	,o.name					as TABLE_NAME
	,case p.action		
		when 26  then 'REFERENCES'
		when 193 then 'SELECT'
		when 195 then 'INSERT'
		when 196 then 'DELETE'
		when 197 then 'UPDATE'
	end						as PRIVILEGE_TYPE
	,case 
		when p.protecttype = 205 then 'NO'
		else 'YES'
	end						as IS_GRANTABLE
 from 
	sysprotects p, 
	sysobjects o
where  
	(is_member(user_name(p.uid)) = 1
	or
		p.grantor = user_id())
 	and (p.protecttype = 204 or 	/*grant exists without same grant with grant */
	(p.protecttype = 205
		and not exists(select * from sysprotects p2
				where p2.id = p.id and
				p2.uid = p.uid and 
				p2.action = p.action and 
				p2.columns = p.columns and
				p2.grantor = p.grantor and
				p2.protecttype = 204)))
 	and p.action in (26,193,195,196,197)
 	and p.id = o.id
	and o.xtype in ('U', 'V')
 	and 0 != (permissions(o.id) &
		case p.action
			when 26  then 	4		/*REFERENCES basebit on all columns	*/		
			when 193 then 	1		/*SELECT basebit on all columns	*/		
			when 195 then 	8		/*INSERT basebit */
			when 196 then 	16		/*DELETE basebit */
			when 197 then 	2		/*UPDATE basebit on all columns	*/
		end)
go

grant select on INFORMATION_SCHEMA.TABLE_PRIVILEGES to public
go

raiserror(15339,-1,-1,'INFORMATION_SCHEMA.COLUMNS')
go

--Displays columns accessable to the current user
create view INFORMATION_SCHEMA.COLUMNS
 as
select 
	db_name()						as TABLE_CATALOG
	,user_name(obj.uid)				as TABLE_SCHEMA
	,obj.name						as TABLE_NAME
	,col.name						as COLUMN_NAME
	,col.colid						as ORDINAL_POSITION
	,com.text						as COLUMN_DEFAULT
	,case col.isnullable 
		when 1 then 'YES'
		else        'No '
	end								as IS_NULLABLE
	,spt_dtp.LOCAL_TYPE_NAME		as DATA_TYPE
	,convert(int, 
	   OdbcPrec(col.xtype, col.length, col.xprec) 
	   + spt_dtp.charbin)			as CHARACTER_MAXIMUM_LENGTH
	,convert(int, spt_dtp.charbin + 
	   case when spt_dtp.LOCAL_TYPE_NAME in ('nchar', 'nvarchar', 'ntext')
		 then  2*OdbcPrec(col.xtype, col.length, col.xprec) 
		 else  OdbcPrec(col.xtype, col.length, col.xprec) 
	   end)							as CHARACTER_OCTET_LENGTH
	,nullif(col.xprec, 0)			as NUMERIC_PRECISION
	,spt_dtp.RADIX					as NUMERIC_PRECISION_RADIX
	,col.scale						as NUMERIC_SCALE
	,spt_dtp.SQL_DATETIME_SUB		as DATETIME_PRECISION
	,convert(sysname, NULL)			as CHARACTER_SET_CATALOG
	,convert(sysname, NULL)			as CHARACTER_SET_SCHEMA
	,convert(sysname, case
		when spt_dtp.LOCAL_TYPE_NAME in 
 		('char', 'varchar', 'text')
			then a_cha.name
		when spt_dtp.LOCAL_TYPE_NAME in 
 		('nchar', 'nvarchar', 'ntext')
			then N'Unicode'
		else NULL
	end)							as CHARACTER_SET_NAME
	,convert(sysname, NULL)			as COLLATION_CATALOG
	,convert(sysname, NULL)			as COLLATION_SCHEMA
	,col.collation					as COLLATION_NAME
	,convert(sysname, case when typ.xusertype > 256  
		then DB_NAME()
	 else NULL
	end)								as DOMAIN_CATALOG
	,convert(sysname, case when typ.xusertype > 256  
			then USER_NAME(obj.uid)
		else NULL
	end)								as DOMAIN_SCHEMA
	,convert(sysname, case when typ.xusertype > 256  
			then typ.name
		else NULL
	end)								as DOMAIN_NAME
FROM
	sysobjects obj,
	master.dbo.spt_datatype_info spt_dtp,
	systypes typ,
	syscolumns col
	LEFT OUTER JOIN syscomments com on col.cdefault = com.id
		AND com.colid = 1,
	master.dbo.syscharsets		a_cha --charset/1001, not sortorder.
WHERE
	permissions(obj.id, col.name) != 0
	AND obj.id = col.id
	AND typ.xtype = spt_dtp.ss_dtype
	AND (spt_dtp.ODBCVer is null or spt_dtp.ODBCVer = 2)
	AND obj.xtype in ('U', 'V')
	AND col.xusertype = typ.xusertype
	AND (spt_dtp.AUTO_INCREMENT is null or spt_dtp.AUTO_INCREMENT = 0)
	AND	a_cha.id = isnull(convert(tinyint, CollationPropertyFromID(col.collationid, 'sqlcharset')),
			convert(tinyint, ServerProperty('sqlcharset'))) -- make sure there's one and only one row selected for each column
go

grant select on INFORMATION_SCHEMA.COLUMNS to public
go

raiserror(15339,-1,-1,'INFORMATION_SCHEMA.COLUMN_DOMAIN_USAGE')
go

--Identifies columns that have a user defined datatype where the
--current user has some permissions on table
create view INFORMATION_SCHEMA.COLUMN_DOMAIN_USAGE
 as
select
	db_name()			as DOMAIN_CATALOG
	,user_name(typ.uid)	as DOMAIN_SCHEMA
	,typ.name			as DOMAIN_NAME
	,db_name()			as TABLE_CATALOG
	,user_name(obj.uid)	as TABLE_SCHEMA
	,obj.name			as TABLE_NAME
	,col.name			as COLUMN_NAME
FROM
	sysobjects obj
	,syscolumns col
	,systypes typ 
WHERE
	permissions(obj.id) != 0
	AND obj.id = col.id
	AND col.xusertype = typ.xusertype
	AND typ.xusertype > 256	-- UDF Type

go

grant select on INFORMATION_SCHEMA.COLUMN_DOMAIN_USAGE to public
go

raiserror(15339,-1,-1,'INFORMATION_SCHEMA.COLUMN_PRIVILEGES')
go

--Identifies privileges granted to or by current user
create view INFORMATION_SCHEMA.COLUMN_PRIVILEGES
 as
select
    user_name(p.grantor)    as GRANTOR
    ,user_name(p.uid)               as GRANTEE
    ,db_name()                              as TABLE_CATALOG
    ,user_name(o.uid)               as TABLE_SCHEMA
    ,o.name                                 as TABLE_NAME
    ,c.name                                 as COLUMN_NAME
    ,case p.action
            when 193 then 'SELECT'
            when 197 then 'UPDATE'
            else 'REFERENCES'
    end                                             as PRIVILEGE_TYPE
    ,case
            when p.protecttype = 205 then 'NO'
            else 'YES'
    end                                             as IS_GRANTABLE
 from
    sysprotects p,
    sysobjects o,
    syscolumns c
where 
    (is_member(user_name(p.uid)) = 1
    or
            p.grantor = user_id())
    and (p.protecttype = 204 or     /*grant exists without same grant with grant */
    (p.protecttype = 205
            and not exists(select * from sysprotects p2
                            where p2.id = p.id and
                            p2.uid = p.uid and
                            p2.action = p.action and
                            p2.columns = p.columns and
                            p2.grantor = p.grantor and
                            p2.protecttype = 204)))
    and p.action in (26,193,197)
    and p.id = o.id
    and o.xtype in ('U', 'V')
    and o.id = c.id
    and
	(((convert(tinyint,substring(p.columns,1,1))&1) = 0
			and
	(convert(int,substring(p.columns,c.colid/8+1,1))&power(2,c.colid&7)) != 0)
		or
	((convert(tinyint,substring(p.columns,1,1))&1) != 0
			and 
	(convert(int,substring(p.columns,c.colid/8+1,1))&power(2,c.colid&7)) = 0))
    and 0 != (permissions
            (o.id, c.name) &
            case p.action
                    when 26  then 4         /*REFERENCES basebit    */
                    when 193 then 1         /*SELECT basebit        */
                    when 197 then 2         /*UPDATE basebit        */
                    end)
go

grant select on INFORMATION_SCHEMA.COLUMN_PRIVILEGES to public
go

raiserror(15339,-1,-1,'INFORMATION_SCHEMA.DOMAINS')
go

--Identifies user defined datatype accessible to current user.
create view INFORMATION_SCHEMA.DOMAINS
 as
select
	DB_NAME()						as DOMAIN_CATALOG
	,USER_NAME(typ.uid)				as DOMAIN_SCHEMA
	,typ.name						as DOMAIN_NAME
	,spt_dtp.LOCAL_TYPE_NAME		as DATA_TYPE
	,convert(int, 
	   OdbcPrec(typ.xtype, typ.length, typ.xprec) 
	   + spt_dtp.charbin)			as CHARACTER_MAXIMUM_LENGTH
	,convert(int, spt_dtp.charbin + 
	   case when spt_dtp.LOCAL_TYPE_NAME in ('nchar', 'nvarchar', 'ntext')
		 then  2*OdbcPrec(typ.xtype, typ.length, typ.xprec) 
		 else  OdbcPrec(typ.xtype, typ.length, typ.xprec) 
	   end)							as CHARACTER_OCTET_LENGTH
	,convert(sysname, NULL)			as COLLATION_CATALOG
	,convert(sysname, NULL)			as COLLATION_SCHEMA
	,typ.collation					as COLLATION_NAME
	,convert(sysname, NULL)			as CHARACTER_SET_CATALOG
	,convert(sysname, NULL)			as CHARACTER_SET_SCHEMA
	,convert(sysname, case
		when spt_dtp.LOCAL_TYPE_NAME in 
 		('char', 'varchar', 'text')
			then a_cha.name
		when spt_dtp.LOCAL_TYPE_NAME in 
 		('nchar', 'nvarchar', 'ntext')
			then N'Unicode'
		else NULL
	end)							as CHARACTER_SET_NAME
	,nullif(typ.xprec, 0)			as NUMERIC_PRECISION
	,spt_dtp.RADIX					as NUMERIC_PRECISION_RADIX
	,convert(int, typ.scale)		as NUMERIC_SCALE
	,spt_dtp.SQL_DATETIME_SUB		as DATETIME_PRECISION
	,com.text						as DOMAIN_DEFAULT
FROM
	master.dbo.spt_datatype_info spt_dtp,
	systypes typ LEFT OUTER JOIN syscomments com
	 	on typ.tdefault = com.id AND com.colid = 1,
	master.dbo.syscharsets		a_cha --charset/1001, not sortorder.
WHERE
	 typ.xtype = spt_dtp.ss_dtype
	AND (spt_dtp.ODBCVer is null or spt_dtp.ODBCVer = 2)	-- Use 7.0 entries
    AND (spt_dtp.AUTO_INCREMENT is null or spt_dtp.AUTO_INCREMENT = 0)	-- Remove auto increment types
	AND a_cha.type = 1001 					--- type is charset
	AND a_cha.id = convert(tinyint, ServerProperty('sqlcharset'))
	AND typ.xusertype > 256					-- UDF Type
go

grant select on INFORMATION_SCHEMA.DOMAINS to public
go

raiserror(15339,-1,-1,'INFORMATION_SCHEMA.DOMAIN_CONSTRAINTS')
go

--Identifies user defined datatype accessible to current user, that have constraints
create view INFORMATION_SCHEMA.DOMAIN_CONSTRAINTS
 as
select
	DB_NAME()			as CONSTRAINT_CATALOG
	,USER_NAME(obj.uid)	as CONSTRAINT_SCHEMA
	,obj.name			as CONSTRAINT_NAME
	,DB_NAME()			as DOMAIN_CATALOG
	,USER_NAME(typ.uid)	as DOMAIN_SCHEMA
	,typ.name			as DOMAIN_NAME
	,'NO'				as IS_DEFERRABLE
	,'NO'				as INITIALLY_DEFERRED
FROM
	sysobjects obj,
	systypes typ 
WHERE
	obj.xtype = 'R'
	and obj.id = typ.domain
	AND typ.xusertype > 256	-- UDF Type
go

grant select on INFORMATION_SCHEMA.DOMAIN_CONSTRAINTS to public
go

raiserror(15339,-1,-1,'INFORMATION_SCHEMA.KEY_COLUMN_USAGE')
go

--Identifies columns which have constrained keys where the current user
--has any permissions on that table.
create view INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
 as
 select
	db_name()				as CONSTRAINT_CATALOG
	,user_name(c_obj.uid)	as CONSTRAINT_SCHEMA
	,c_obj.name				as CONSTRAINT_NAME
	,db_name()				as TABLE_CATALOG
	,user_name(t_obj.uid)	as TABLE_SCHEMA
	,t_obj.name				as TABLE_NAME
	,col.name				as COLUMN_NAME
	,case col.colid	
		when ref.fkey1 then 1			
		when ref.fkey2 then 2			
		when ref.fkey3 then 3			
		when ref.fkey4 then 4			
		when ref.fkey5 then 5			
		when ref.fkey6 then 6			
		when ref.fkey7 then 7			
		when ref.fkey8 then 8			
		when ref.fkey9 then 9			
		when ref.fkey10 then 10			
		when ref.fkey11 then 11			
		when ref.fkey12 then 12			
		when ref.fkey13 then 13			
		when ref.fkey14 then 14			
		when ref.fkey15 then 15			
		when ref.fkey16 then 16
	end						as ORDINAL_POSITION
from
	sysobjects	c_obj
	,sysobjects	t_obj
	,syscolumns	col
	,sysreferences  ref
where
	permissions(t_obj.id) != 0
	and c_obj.xtype	in ('F ')
	and t_obj.id	= c_obj.parent_obj
	and t_obj.id	= col.id
	and col.colid   in 
	(ref.fkey1,ref.fkey2,ref.fkey3,ref.fkey4,ref.fkey5,ref.fkey6,
	ref.fkey7,ref.fkey8,ref.fkey9,ref.fkey10,ref.fkey11,ref.fkey12,
	ref.fkey13,ref.fkey14,ref.fkey15,ref.fkey16)
	and c_obj.id	= ref.constid
union
 select
	db_name()				as CONSTRAINT_CATALOG
	,user_name(c_obj.uid)	as CONSTRAINT_SCHEMA
	,i.name					as CONSTRAINT_NAME
	,db_name()				as TABLE_CATALOG
	,user_name(t_obj.uid)	as TABLE_SCHEMA
	,t_obj.name				as TABLE_NAME
	,col.name				as COLUMN_NAME
	,v.number				as ORDINAL_POSITION
from
	sysobjects		c_obj
	,sysobjects		t_obj
	,syscolumns		col
	,master.dbo.spt_values 	v
	,sysindexes		i
where
	permissions(t_obj.id) != 0
	and c_obj.xtype	in ('UQ' ,'PK')
	and t_obj.id	= c_obj.parent_obj
	and t_obj.xtype  = 'U'
	and t_obj.id	= col.id
	and col.name	= index_col(t_obj.name,i.indid,v.number)
	and t_obj.id	= i.id
	and c_obj.name  = i.name
	and v.number 	> 0 
 	and v.number 	<= i.keycnt 
 	and v.type 	= 'P'
go

grant select on INFORMATION_SCHEMA.KEY_COLUMN_USAGE to public
go

raiserror(15339,-1,-1,'INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS')
go

--Identifies foreign constraints where the current user has
--any permissions on the object
create view INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS
 as
 select
	db_name()				as CONSTRAINT_CATALOG
	,user_name(fc_obj.uid)	as CONSTRAINT_SCHEMA
	,fc_obj.name			as CONSTRAINT_NAME
	,db_name()				as UNIQUE_CONSTRAINT_CATALOG
	,user_name(pc_obj.uid)	as UNIQUE_CONSTRAINT_SCHEMA
	,i.name					as UNIQUE_CONSTRAINT_NAME
	,'NONE'					as MATCH_OPTION
	,CASE WHEN (ObjectProperty(r.constid, 'CnstIsUpdateCascade')=1) THEN 
		'CASCADE' ELSE 'NO ACTION' END as UPDATE_RULE
	,CASE WHEN (ObjectProperty(r.constid, 'CnstIsDeleteCascade')=1) THEN 
		'CASCADE' ELSE 'NO ACTION' END as DELETE_RULE
from	
	sysobjects	fc_obj
	,sysreferences	r
	,sysindexes	i
	,sysobjects	pc_obj
where 
	permissions(fc_obj.parent_obj) != 0
	and fc_obj.xtype	= 'F'
	and r.constid		= fc_obj.id
	and r.rkeyid		= i.id
	and r.rkeyindid 	= i.indid
	and r.rkeyid		= pc_obj.id
go

grant select on INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS to public
go

raiserror(15339,-1,-1,'INFORMATION_SCHEMA.CHECK_CONSTRAINTS')
go

--Identifies check constraints where the current user has any
--permissions on the table object 
create view INFORMATION_SCHEMA.CHECK_CONSTRAINTS
as
select
	db_name()				as CONSTRAINT_CATALOG
	,user_name(c_obj.uid)	as CONSTRAINT_SCHEMA
	,c_obj.name				as CONSTRAINT_NAME
	,com.text				as CHECK_CLAUSE
from
	sysobjects	c_obj
	,syscomments	com
where
	permissions(c_obj.parent_obj) != 0
	and c_obj.id	= com.id
	and c_obj.xtype	= 'C'
go

grant select on INFORMATION_SCHEMA.CHECK_CONSTRAINTS to public
go

raiserror(15339,-1,-1,'INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE')
go

--Identifies tables that have constraints where the
--current user has any permissions on the table
create view INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
 as
 select
	db_name()				as TABLE_CATALOG
	,user_name(t_obj.uid)	as TABLE_SCHEMA
	,t_obj.name				as TABLE_NAME
	,db_name()				as CONSTRAINT_CATALOG
	,user_name(c_obj.uid)	as CONSTRAINT_SCHEMA
	,c_obj.name				as CONSTRAINT_NAME
from
	sysobjects	c_obj
	,sysobjects	t_obj
where
	permissions(t_obj.id) != 0
	and t_obj.id	= c_obj.parent_obj
	and c_obj.xtype	in ('C' ,'UQ' ,'PK' ,'F')
go

grant select on INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE to public
go

raiserror(15339,-1,-1,'INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE')
go

--Identifies tables and columns that have constraints and the current
--user has any permissions on the column
create view INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE
(
TABLE_CATALOG
,TABLE_SCHEMA
,TABLE_NAME
,COLUMN_NAME
,CONSTRAINT_CATALOG
,CONSTRAINT_SCHEMA
,CONSTRAINT_NAME
)
 as
 select
	KCU.TABLE_CATALOG	/*TABLE_CATALOG*/
	,KCU.TABLE_SCHEMA 	/*TABLE_SCHEMA*/
	,KCU.TABLE_NAME 	/*TABLE_NAME*/
	,KCU.COLUMN_NAME 	/*COLUMN_NAME*/
	,KCU.CONSTRAINT_CATALOG/*CONSTRAINT_CATALOG*/
	,KCU.CONSTRAINT_SCHEMA /*CONSTRAINT_SCHEMA*/
	,KCU.CONSTRAINT_NAME 	/*CONSTRAINT_NAME*/
from	
	INFORMATION_SCHEMA.KEY_COLUMN_USAGE KCU
UNION
 select
	db_name()			/*TABLE_CATALOG*/
	,user_name(t_obj.uid)/*TABLE_SCHEMA*/
	,t_obj.name			/*TABLE_NAME*/
	,cols.name			/*COLUMN_NAME*/
	,db_name()			/*CONSTRAINT_CATALOG*/
	,user_name(c_obj.uid)/*CONSTRAINT_SCHEMA*/
	,c_obj.name			/*CONSTRAINT_NAME*/
from	
	sysobjects	t_obj
	,sysobjects	c_obj
	,syscolumns cols	
where
	permissions(t_obj.id) != 0
	and t_obj.id	= c_obj.parent_obj
	and c_obj.xtype	= 'C'
	and c_obj.info	= cols.colid
	and cols.id		= c_obj.parent_obj
UNION
select
	db_name()		/*TABLE_CATALOG*/
	,user_name(t_obj.uid)	/*TABLE_SCHEMA*/
	,t_obj.name		/*TABLE_NAME*/
	,col.name		/*COLUMN_NAME*/
	,db_name()		/*CONSTRAINT_CATALOG*/
	,user_name(r_obj.uid)	/*CONSTRAINT_SCHEMA*/
	,r_obj.name		/*CONSTRAINT_NAME*/
FROM
	sysobjects t_obj
	,syscolumns col
	,systypes typ 
	,sysobjects  r_obj
WHERE
	permissions(t_obj.id) != 0
	AND t_obj.id = col.id
	AND col.xusertype = typ.xusertype
	AND typ.xusertype > 256	-- UDF Type
	AND typ.domain = r_obj.id
	AND r_obj.xtype = 'R'
go

grant select on INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE to public
go

raiserror(15339,-1,-1,'INFORMATION_SCHEMA.VIEWS')
go

-- Displays views accessable to current user
create view INFORMATION_SCHEMA.VIEWS
 as
 select
	db_name()				as TABLE_CATALOG
	,user_name(obj.uid)		as TABLE_SCHEMA
	,obj.name				as TABLE_NAME
	,case
		when exists (select * 
			from syscomments com3
			where com3.id = obj.id
			and com3.colid > 1)	then convert(nvarchar(4000), NULL)
		else com.text
	end						as VIEW_DEFINITION
	,case
	    when exists (select *
			from syscomments com2
			where com2.id = obj.id 
			and CHARINDEX('WITH CHECK OPTION', 			
			upper(com2.text)) > 0)  then 'CASCADE'
		else 'NONE'
	end						as CHECK_OPTION
	,'NO'					as IS_UPDATABLE
from
	sysobjects obj
	,syscomments com
where   
	permissions(obj.id) != 0
	and obj.xtype	= 'V'
	and obj.id      = com.id
	and com.colid	= 1
go

grant select on INFORMATION_SCHEMA.VIEWS to public
go

raiserror(15339,-1,-1,'INFORMATION_SCHEMA.VIEW_TABLE_USAGE')
go

-- Identifies views and the tables used in their definition which are
-- owned where the current user has any permissions on the view    
create view INFORMATION_SCHEMA.VIEW_TABLE_USAGE
 as
select distinct
	db_name()				as VIEW_CATALOG
	,user_name(v_obj.uid)	as VIEW_SCHEMA 
	,v_obj.name				as VIEW_NAME
	,db_name()				as TABLE_CATALOG
	,user_name(t_obj.uid)	as TABLE_SCHEMA
	,t_obj.name				as TABLE_NAME
from
	 sysobjects	t_obj
	,sysobjects	v_obj
	,sysdepends	dep	
where
	permissions(v_obj.id) != 0
	and v_obj.xtype	= 'V'
	and dep.id 	= v_obj.id
	and dep.depid	= t_obj.id

go

grant select on INFORMATION_SCHEMA.VIEW_TABLE_USAGE to public
go

raiserror(15339,-1,-1,'INFORMATION_SCHEMA.VIEW_COLUMN_USAGE')
go

-- Identifies views and the columns used in their definition where the
--current user has any permissions on the view
create view INFORMATION_SCHEMA.VIEW_COLUMN_USAGE
 as
select
	db_name()				as VIEW_CATALOG
	,user_name(v_obj.uid)	as VIEW_SCHEMA
	,v_obj.name				as VIEW_NAME
	,db_name()				as TABLE_CATALOG
	,user_name(t_obj.uid)	as TABLE_SCHEMA
	,t_obj.name				as TABLE_NAME
	,col.name				as COLUMN_NAME 
from
	 sysobjects	t_obj
	,sysobjects	v_obj
	,sysdepends	dep
	,syscolumns col
			
where
	permissions(v_obj.id) != 0
	and v_obj.xtype	= 'V'
	and dep.id	= v_obj.id
	and dep.depid	= t_obj.id
	and t_obj.id	= col.id
	and dep.depnumber	= col.colid
go

grant select on INFORMATION_SCHEMA.VIEW_COLUMN_USAGE to public
go

raiserror(15339,-1,-1,'INFORMATION_SCHEMA.ROUTINES')
go

create view INFORMATION_SCHEMA.ROUTINES
	as
SELECT
	SPECIFIC_CATALOG			= db_name(),
	SPECIFIC_SCHEMA				= user_name(o.uid),
	SPECIFIC_NAME				= o.name,
	ROUTINE_CATALOG				= db_name(),
	ROUTINE_SCHEMA				= user_name(o.uid),
	ROUTINE_NAME				= o.name,
	ROUTINE_TYPE				= convert(nvarchar(20), CASE
									WHEN o.xtype='P' THEN 'PROCEDURE'
									ELSE 'FUNCTION' END),
	MODULE_CATALOG				= convert(sysname,null),
	MODULE_SCHEMA				= convert(sysname,null),
	MODULE_NAME					= convert(sysname,null),
	UDT_CATALOG					= convert(sysname,null),
	UDT_SCHEMA					= convert(sysname,null),
	UDT_NAME					= convert(sysname,null),
	DATA_TYPE					= case when o.xtype IN ('TF', 'IF') then N'TABLE' else spt_dtp.LOCAL_TYPE_NAME end,
	CHARACTER_MAXIMUM_LENGTH	= convert(int, OdbcPrec(c.xtype, c.length, c.xprec) + spt_dtp.charbin),
	CHARACTER_OCTET_LENGTH		= convert(int, spt_dtp.charbin + 
											   case when spt_dtp.LOCAL_TYPE_NAME in ('nchar', 'nvarchar', 'ntext')
												  then  2*OdbcPrec(c.xtype, c.length, c.xprec) 
											      else  OdbcPrec(c.xtype, c.length, c.xprec) 
											   end),
	COLLATION_CATALOG			= convert(sysname, null),
	COLLATION_SCHEMA			= convert(sysname, null),
	COLLATION_NAME				= c.collation,
	CHARACTER_SET_CATALOG		= convert(sysname, null),
	CHARACTER_SET_SCHEMA		= convert(sysname, null),
	CHARACTER_SET_NAME			= convert(sysname, case 
									when spt_dtp.LOCAL_TYPE_NAME in ('char', 'varchar', 'text')
										then a_cha.name
									when spt_dtp.LOCAL_TYPE_NAME in ('nchar', 'nvarchar', 'ntext')
										then N'Unicode'
									else NULL 
								  end),	
	NUMERIC_PRECISION			= c.xprec,
	NUMERIC_PRECISION_RADIX		= spt_dtp.RADIX,
	NUMERIC_SCALE				= c.scale,
	DATETIME_PRECISION			= spt_dtp.SQL_DATETIME_SUB,
	INTERVAL_TYPE				= convert(nvarchar(30),null),
	INTERVAL_PRECISION			= convert(smallint,null),
	TYPE_UDT_CATALOG			= convert(sysname,null),
	TYPE_UDT_SCHEMA				= convert(sysname,null),
	TYPE_UDT_NAME 				= convert(sysname,null),
	SCOPE_CATALOG 				= convert(sysname,null),
	SCOPE_SCHEMA 				= convert(sysname,null),
	SCOPE_NAME					= convert(sysname,null),
	MAXIMUM_CARDINALITY			= convert(bigint,null),
	DTD_IDENTIFIER				= convert(sysname,null),
	ROUTINE_BODY				= convert(nvarchar(30), 'SQL'),
	ROUTINE_DEFINITION			= convert(nvarchar(4000),
			(SELECT TOP 1 CASE WHEN encrypted = 1 THEN NULL ELSE com.text END
				FROM syscomments com WHERE com.id=o.id AND com.number<=1 AND com.colid = 1)),
	EXTERNAL_NAME				= convert(sysname,null),
	EXTERNAL_LANGUAGE			= convert(nvarchar(30),null),
	PARAMETER_STYLE				= convert(nvarchar(30),null),
	IS_DETERMINISTIC			= convert(nvarchar(10),
									CASE WHEN ObjectProperty(o.id, 'IsDeterministic')=1
									THEN 'YES' ELSE 'NO' END),
	SQL_DATA_ACCESS				= convert(nvarchar(30), CASE
									WHEN o.xtype='P' THEN 'MODIFIES'
									ELSE 'READS' END),
	IS_NULL_CALL				= convert(nvarchar(10),null),
	SQL_PATH					= convert(sysname,null),
	SCHEMA_LEVEL_ROUTINE		= convert(nvarchar(10),'YES'),
	MAX_DYNAMIC_RESULT_SETS		= convert(smallint, CASE
									WHEN o.xtype='P' THEN -1 ELSE 0 END),
	IS_USER_DEFINED_CAST		= convert(nvarchar(10),'NO'),
	IS_IMPLICITLY_INVOCABLE		= convert(nvarchar(10),'NO'),
	CREATED						= o.crdate,
	LAST_ALTERED				= o.crdate
FROM
	sysobjects o LEFT OUTER JOIN 
		(syscolumns c JOIN master.dbo.spt_datatype_info spt_dtp
		ON c.xtype = spt_dtp.ss_dtype
			AND (spt_dtp.ODBCVer is null or spt_dtp.ODBCVer = 2)
			AND (spt_dtp.AUTO_INCREMENT is null or spt_dtp.AUTO_INCREMENT = 0)
		)
	ON (o.id = c.id AND c.number = 0 AND c.colid = 0),
	master.dbo.syscharsets		a_cha --charset/1001, not sortorder.
where
	o.xtype IN ('P','FN','TF', 'IF')
	AND permissions(o.id) != 0
	AND	a_cha.id = isnull(convert(tinyint, CollationProperty(c.collation, 'sqlcharset')),
			convert(tinyint, ServerProperty('sqlcharset'))) -- make sure there's one and only one row selected for each column
go

grant select on INFORMATION_SCHEMA.ROUTINES to public
go

raiserror(15339,-1,-1,'INFORMATION_SCHEMA.PARAMETERS')
go

create view INFORMATION_SCHEMA.PARAMETERS
	as
SELECT
	SPECIFIC_CATALOG			= db_name(),
	SPECIFIC_SCHEMA				= user_name(o.uid),
	SPECIFIC_NAME				= o.name,
	ORDINAL_POSITION			= c.colid,
	PARAMETER_MODE				= convert(nvarchar(10), CASE
									WHEN c.colid=0 THEN 'OUT'
									WHEN ColumnProperty(c.id, c.name, 'IsOutParam')=1 THEN 'INOUT'
									ELSE 'IN' END),
	IS_RESULT					= convert(nvarchar(10), CASE
									WHEN c.colid=0 THEN 'YES' ELSE 'NO' END),
	AS_LOCATOR					= convert(nvarchar(10),'NO'),
	PARAMETER_NAME				= c.name,
	DATA_TYPE					= spt_dtp.LOCAL_TYPE_NAME,
	CHARACTER_MAXIMUM_LENGTH	= convert(int, OdbcPrec(c.xtype, c.length, c.xprec) + spt_dtp.charbin),
	CHARACTER_OCTET_LENGTH		= convert(int, spt_dtp.charbin + 
											   case when spt_dtp.LOCAL_TYPE_NAME in ('nchar', 'nvarchar', 'ntext')
												  then  2*OdbcPrec(c.xtype, c.length, c.xprec) 
											      else  OdbcPrec(c.xtype, c.length, c.xprec) 
											   end),
	COLLATION_CATALOG			= convert(sysname,null),
	COLLATION_SCHEMA			= convert(sysname,null),
	COLLATION_NAME				= c.collation,
	CHARACTER_SET_CATALOG		= convert( sysname, null),
	CHARACTER_SET_SCHEMA		= convert( sysname, null),
	CHARACTER_SET_NAME			= convert( sysname, case 
									when spt_dtp.LOCAL_TYPE_NAME in ('char', 'varchar', 'text')
										then a_cha.name
									when spt_dtp.LOCAL_TYPE_NAME in ('nchar', 'nvarchar', 'ntext')
										then N'Unicode'
									else NULL 
								  end),	
	NUMERIC_PRECISION			= c.xprec,
	NUMERIC_PRECISION_RADIX		= spt_dtp.RADIX,
	NUMERIC_SCALE				= c.scale,
	DATETIME_PRECISION			= spt_dtp.SQL_DATETIME_SUB,
	INTERVAL_TYPE				= convert(nvarchar(30),null),
	INTERVAL_PRECISION			= convert(smallint,null),
	USER_DEFINED_TYPE_CATALOG	= convert(sysname,null),
	USER_DEFINED_TYPE_SCHEMA	= convert(sysname,null),
	USER_DEFINED_TYPE_NAME		= convert(sysname,null),
	SCOPE_CATALOG 				= convert(sysname,null),
	SCOPE_SCHEMA 				= convert(sysname,null),
	SCOPE_NAME					= convert(sysname,null)
FROM
	sysobjects o,
	syscolumns c JOIN master.dbo.spt_datatype_info spt_dtp
		ON c.xtype = spt_dtp.ss_dtype
			AND (spt_dtp.ODBCVer is null or spt_dtp.ODBCVer = 2)
			AND (spt_dtp.AUTO_INCREMENT is null or spt_dtp.AUTO_INCREMENT = 0),
	master.dbo.syscharsets		a_cha --charset/1001, not sortorder.
where
	o.xtype IN ('P','FN','TF', 'IF')
	AND o.id = c.id AND (c.number = 1 OR (c.number = 0 AND o.xtype = 'FN'))
	AND permissions(o.id) != 0
	AND	a_cha.id = isnull(convert(tinyint, CollationProperty(c.collation, 'sqlcharset')),
			convert(tinyint, ServerProperty('sqlcharset'))) -- make sure there's one and only one row selected for each column
go

grant select on INFORMATION_SCHEMA.PARAMETERS to public
go

raiserror(15339,-1,-1,'INFORMATION_SCHEMA.ROUTINE_COLUMNS')
go

create view INFORMATION_SCHEMA.ROUTINE_COLUMNS
	as
SELECT
	TABLE_CATALOG				= db_name(),
	TABLE_SCHEMA				= user_name(o.uid),
	TABLE_NAME					= o.name,
	COLUMN_NAME					= c.name,
	ORDINAL_POSITION			= c.colid,
	COLUMN_DEFAULT				= convert(nvarchar(4000),null),
	IS_NULLABLE					= convert(varchar(3), CASE WHEN c.isnullable=1
									THEN 'YES' ELSE 'NO' END),
	DATA_TYPE					= spt_dtp.LOCAL_TYPE_NAME,
	CHARACTER_MAXIMUM_LENGTH	= convert(int, OdbcPrec(c.xtype, c.length, c.xprec) + spt_dtp.charbin),
	CHARACTER_OCTET_LENGTH		= convert(int, spt_dtp.charbin + 
											   case when spt_dtp.LOCAL_TYPE_NAME in ('nchar', 'nvarchar', 'ntext')
												  then  2*OdbcPrec(c.xtype, c.length, c.xprec) 
											      else  OdbcPrec(c.xtype, c.length, c.xprec) 
											   end),
	NUMERIC_PRECISION			= c.xprec,
	NUMERIC_PRECISION_RADIX		= spt_dtp.RADIX,
	NUMERIC_SCALE				= c.scale,
	DATETIME_PRECISION			= spt_dtp.SQL_DATETIME_SUB,
	CHARACTER_SET_CATALOG		= convert( sysname, null),
	CHARACTER_SET_SCHEMA		= convert( sysname, null),
	CHARACTER_SET_NAME			= convert( sysname, case 
									when spt_dtp.LOCAL_TYPE_NAME in ('char', 'varchar', 'text')
										then a_cha.name
									when spt_dtp.LOCAL_TYPE_NAME in ('nchar', 'nvarchar', 'ntext')
										then N'Unicode'
									else NULL 
								  end),	
	COLLATION_CATALOG			= convert(sysname, null),
	COLLATION_SCHEMA			= convert(sysname, null),
	COLLATION_NAME				= c.collation,
	DOMAIN_CATALOG				= convert(sysname,CASE WHEN c.xusertype > 256
									THEN db_name() ELSE null END),
	DOMAIN_SCHEMA				= convert(sysname,CASE WHEN c.xusertype > 256
									THEN user_name(o.uid) ELSE null END),
	DOMAIN_NAME					= convert(sysname,CASE WHEN c.xusertype > 256
									THEN type_name(xusertype) ELSE null END)

FROM
	sysobjects o,
	syscolumns c JOIN master.dbo.spt_datatype_info spt_dtp
		ON c.xtype = spt_dtp.ss_dtype
			AND (spt_dtp.ODBCVer is null or spt_dtp.ODBCVer = 2)
			AND (spt_dtp.AUTO_INCREMENT is null or spt_dtp.AUTO_INCREMENT = 0),
	master.dbo.syscharsets		a_cha --charset/1001, not sortorder.
where
	o.xtype IN ('TF','IF')
	AND o.id = c.id AND c.number = 0
	AND permissions(o.id) != 0
	AND	a_cha.id = isnull(convert(tinyint, CollationProperty(c.collation, 'sqlcharset')),
			convert(tinyint, ServerProperty('sqlcharset'))) -- make sure there's one and only one row selected for each column
go

grant select on INFORMATION_SCHEMA.ROUTINE_COLUMNS to public
go



-- END OF "SYSTEM" OBJECT CREATION --
exec sp_MS_upd_sysobj_category 2
go
exec sp_configure 'allow', 0
reconfigure with override
go
