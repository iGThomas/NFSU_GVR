
/*
** U_Tables.CQL    --- 1996/09/16 12:22
** Copyright Microsoft, Inc. 1994 - 2000
** All Rights Reserved.
*/

go
use master
go
backup tran master with no_log
go
set nocount on
go

declare @vdt varchar(99)
select  @vdt = convert(varchar,getdate(),113)
raiserror('Starting u_Tables.SQL at  %s',0,1,@vdt) with nowait
raiserror('This file creates all the ''SPT_'' tables.',0,1)
go

--------------------------------------
exec sp_MS_upd_sysobj_category 1
go
--------------------------------------

if object_id('spt_monitor','U') IS NOT NULL
	begin
	print 'drop table spt_monitor ....'
	drop table spt_monitor
	end

if object_id('spt_values','U') IS NOT NULL
	begin
	print 'drop table spt_values ....'
	drop table spt_values
	end

--------------------------------------------------
if object_id('spt_fallback_usg','U') IS NOT NULL
	begin
	print 'drop table spt_fallback_usg ....'
	drop table spt_fallback_usg
	end

if object_id('spt_fallback_dev','U') IS NOT NULL
	begin
	print 'drop table spt_fallback_dev'
	drop table spt_fallback_dev
	end

if object_id('spt_fallback_db','U') IS NOT NULL
	begin
	print 'drop table spt_fallback_db'
	drop table spt_fallback_db
	end
go

backup tran master with no_log
go



------------------------------------------------------------------
------------------------------------------------------------------


raiserror(15339,-1,-1,'spt_monitor')
go

create table spt_monitor
(
	lastrun		datetime	NOT NULL,
	cpu_busy	int		NOT NULL,
	io_busy		int		NOT NULL,
	idle		int		NOT NULL,
	pack_received	int		NOT NULL,
	pack_sent	int		NOT NULL,
	connections	int		NOT NULL,
	pack_errors	int		NOT NULL,
	total_read	int		NOT NULL,
	total_write 	int		NOT NULL,
	total_errors 	int		NOT NULL
)
go


---------------------------------------

raiserror(15339,-1,-1,'spt_values')
go
create table spt_values
(
name	nvarchar(35)	    NULL,
number	int		NOT NULL,
type	nchar(3)		NOT NULL, --Make these unique to aid GREP (e.g. SOP, not SET or S).
low	int		    NULL,
high	int		    NULL,
status	int		    NULL  DEFAULT 0
)
go


print ''
print 'create indexes on spt_values ....'
go

-- 'J','S','P' (maybe 'Z' too?)  challenge uniqueness.
create Unique Clustered index spt_valuesclust on spt_values(type ,number ,name)
go

create Nonclustered index ix2_spt_values_nu_nc on spt_values(number, type)
go


----+----1----+----2----+----3----+----4----+----5----+----6----+----7----+

raiserror(15339,-1,-1,'spt_fallback_db')
go
create table spt_fallback_db
   (
    xserver_name           character varying(30)      not null
   ,xdttm_ins              datetime                   not null
   ,xdttm_last_ins_upd     datetime                   not null
   ,xfallback_dbid         smallint                       null

   ,name                   character varying(30)      not null
   ,dbid                   smallint                   not null
   ,status                 smallint                   not null
   ,version                smallint                   not null
   )
go

/****
--Nice-to-have the uniqueness check, but extra 16 Mb in master db too precious.
create unique Clustered
   index    idx1
   on       spt_fallback_db
      (
       xserver_name
      ,name
      )
--g o
****/

----+----1----+----2----+----3----+----4----+----5----+----6----+----7----+

raiserror(15339,-1,-1,'spt_fallback_dev')
go
create table spt_fallback_dev
   (
    xserver_name           character varying(30)      not null
   ,xdttm_ins              datetime                   not null
   ,xdttm_last_ins_upd     datetime                   not null
   ,xfallback_low          integer                        null
   ,xfallback_drive        character(2)                   null

   ,low                    integer                    not null
   ,high                   integer                    not null
   ,status                 smallint                   not null
   ,name                   character varying(30)      not null
   ,phyname                character varying(127)     not null
   )
go

/****
create unique Clustered
   index    idx1
   on       spt_fallback_dev
      (
       xserver_name
      ,name
      )
--g o
****/

----+----1----+----2----+----3----+----4----+----5----+----6----+----7----+

raiserror(15339,-1,-1,'spt_fallback_usg')
go
create table spt_fallback_usg
   (
    xserver_name           character varying(30)      not null
   ,xdttm_ins              datetime                   not null
   ,xdttm_last_ins_upd     datetime                   not null
   ,xfallback_vstart       integer                        null

   ,dbid                   smallint                   not null
   ,segmap                 integer                    not null
   ,lstart                 integer                    not null
   ,sizepg                 integer                    not null
   ,vstart                 integer                    not null
   )
go

/****
create unique Clustered
   index    idx1
   on       spt_fallback_usg
      (
       xserver_name
      ,dbid
      ,lstart
      )
--go
****/


------------------------------------------------------------------
------------------------------------------------------------------

raiserror('Grant Select on spt_ ....',0,1)
go

grant select on spt_values  to public
grant select on spt_monitor to public

grant select on spt_fallback_db to public
grant select on spt_fallback_dev to public
grant select on spt_fallback_usg to public
go



------------------------------------------------------------------
------------------------------------------------------------------


raiserror('Insert into spt_monitor ....',0,1)
go

insert into spt_monitor
	select
	lastrun = getdate(),
	cpu_busy = @@cpu_busy,
	io_busy = @@io_busy,
	idle = @@idle,
	pack_received = @@pack_received,
	pack_sent = @@pack_sent,
	connections = @@connections,
	pack_errors = @@packet_errors,
	total_read = @@total_read,
	total_write = @@total_write,
	total_errors = @@total_errors
go



-- Caution, 'Z  ' is used by sp_helpsort, though no 'Z  ' rows are inserted by this file.

print ''
print 'Insert into spt_values ....'
go

raiserror('Insert spt_values.type=''A  '' ....',0,1)
go
insert into spt_values (name, number, type)
	values ('rpc', 1, 'A')
insert into spt_values (name, number, type)
	values ('pub', 2, 'A')
insert into spt_values (name, number, type)
	values ('sub', 4, 'A')
insert into spt_values (name, number, type)
	values ('dist', 8, 'A')
insert into spt_values (name, number, type)
	values ('dpub', 16, 'A')
insert into spt_values (name, number, type)
	values ('rpc out', 64, 'A')
insert into spt_values (name, number, type)
	values ('data access', 128, 'A')
insert into spt_values (name, number, type)
	values ('collation compatible', 256, 'A')
insert into spt_values (name, number, type)
	values ('system', 512, 'A')
insert into spt_values (name, number, type)
	values ('use remote collation', 1024, 'A')
insert into spt_values (name, number, type)
	values ('lazy schema validation', 2048, 'A')
-- NOTE: PLEASE UPDATE ntdbms\include\systabre.h WHEN USING
--  ADDITIONAL SYSSERVER STATUS BITS! (enum ESrvStatusBits)
go


raiserror('Insert spt_values.type=''B  '' ....',0,1)
go
insert spt_values (name, number, type)
	values ('YES OR NO', -1, 'B')
insert spt_values (name, number, type)
	values ('no', 0, 'B')
insert spt_values (name, number, type)
	values ('yes', 1, 'B')
insert spt_values (name, number, type)
	values ('none', 2, 'B')
go

-- NOTE: spt_values.name when type = 'C' CANNOT BE LONGER THAN 30 CHARS!
-- (otherwise it breaks TPCC master.exe)
raiserror('Insert spt_values.type=''C  '' ....',0,1)
go
insert spt_values(name, number, type)
        values ('CONFIGURATION OPTIONS', 0, 'C') -- 1=Dynamic, 2=Advanced

insert spt_values(name, number, type, low, high,status)
	values ('recovery interval (min)', 101, 'C', 0, 32767 ,0)

insert spt_values(name, number, type, low, high,status)
	values ('allow updates', 102, 'C', 0, 1 ,0)

insert spt_values(name, number, type, low, high,status)
	values ('user connections', 103, 'C', 0, @@max_connections ,0)

insert spt_values(name, number, type, low, high,status)
	values ('locks', 106, 'C', 5000, 2147483647 ,0)

insert spt_values(name, number, type, low, high,status)
	values ('open objects', 107, 'C', 0, 2147483647 ,0)

insert spt_values(name, number, type, low, high,status)
	values ('fill factor (%)', 109, 'C', 0, 100 ,0)

insert spt_values(name, number, type, low, high,status)
	values ('nested triggers', 115, 'C', 0, 1 ,0)

insert spt_values(name, number, type, low, high,status)
	values ('remote access', 117, 'C', 0, 1 ,0)

insert spt_values(name, number, type, low, high,status)
	values ('default language', 124, 'C', 0, 9999 ,0)

insert into spt_values(name, number, type, low, high,status)
	values ('max worker threads', 503, 'C', 32, 32767 ,0)

insert spt_values(name, number, type, low, high,status)
	values ('network packet size (B)', 505, 'C', 512, 65536 ,0)

insert spt_values(name, number, type, low, high,status)
	values ('show advanced options', 518, 'C', 0, 1 ,0)

insert into spt_values (name ,number ,type ,low ,high ,status)
	values ('remote proc trans', 542, 'C', 0, 1, 0)

insert spt_values(name, number, type, low, high,status)
	values ('c2 audit mode', 544, 'C', 0, 1 ,2)

insert spt_values (name, number, type, low, high,status)
	values ('default full-text language', 1126, 'C', 0, 2147483647, 0)

insert spt_values (name, number, type, low, high,status)
	values ('two digit year cutoff', 1127, 'C', 1753, 9999, 0)

insert spt_values(name, number, type, low, high,status)
	values ('index create memory (KB)', 1505, 'C', 704, 2147483647 ,0)

insert spt_values(name, number, type, low, high,status)
	values ('priority boost', 1517, 'C', 0, 1 ,0)

insert spt_values(name, number, type, low, high,status)
	values ('remote login timeout (s)', 1519, 'C', 0, 2147483647 ,0)

insert spt_values(name, number, type, low, high,status)
	values ('remote query timeout (s)', 1520, 'C', 0, 2147483647 ,0)

insert into spt_values(name, number, type, low, high,status)
	values ('cursor threshold', 1531, 'C', -1, 2147483647 ,0)

insert spt_values(name, number, type, low, high,status)
	values ('set working set size', 1532, 'C', 0, 1 ,0)

insert spt_values(name, number, type, low, high,status)
	values ('user options'  --Most on/off style SET options
          ,1534, 'C', 0
          ,0x7fff ,1)

insert spt_values(name, number, type, low, high,status)
	values ('affinity mask', 1535, 'C', -2147483648, 2147483647, 0)

insert spt_values(name, number, type, low, high,status)
	values ('max text repl size (B)', 1536, 'C', 0, 2147483647, 0)

insert spt_values(name, number, type, low, high,status)
	values ('media retention', 1537, 'C', 0, 365 ,0)

insert spt_values(name, number, type, low, high,status)
	values ('cost threshold for parallelism', 1538, 'C', 0, 32767, 0)

insert spt_values(name, number, type, low, high,status)
	values ('max degree of parallelism', 1539, 'C', 0, 32, 0)

insert spt_values(name, number, type, low, high,status)
	values ('min memory per query (KB)', 1540, 'C', 512, 2147483647, 0)

insert spt_values(name, number, type, low, high,status)
	values ('query wait (s)', 1541, 'C', -1, 2147483647, 0)

insert spt_values(name, number, type, low, high,status)
	values ('min server memory (MB)', 1543, 'C', 0,  2147483647, 0)

insert spt_values(name, number, type, low, high,status)
	values ('max server memory (MB)', 1544, 'C', 4,  2147483647, 0)

insert spt_values(name, number, type, low, high,status)
	values ('query governor cost limit', 1545, 'C', 0,  2147483647, 0)

insert spt_values(name, number, type, low, high,status)
	values ('lightweight pooling', 1546, 'C', 0,  1, 0)

insert spt_values(name, number, type, low, high,status)
	values ('scan for startup procs', 1547, 'C', 0,  1, 0)

insert spt_values(name, number, type, low, high,status)
	values ('awe enabled', 1548, 'C', 0,  1, 0)
go

insert spt_values(name, number, type, low, high,status)
	values ('affinity64 mask', 1549, 'C', -2147483648, 2147483647, 0)
go

insert spt_values(name, number, type, low, high,status)
	values ('Cross DB Ownership Chaining', 400, 'C', 0, 1, 0)
go
-- types 'D'(sysdatabase.status) and 'DC'(sysdatabase.category)
-- and 'D2'(sysdatabases.status2) are options settable by sp_dboption

raiserror('Insert spt_values.type=''D  '' ....',0,1)
go
---- If you add a bit here make sure you add the value to the value of the ALL SETTABLE DB status option if it is settable with sp_dboption.

insert spt_values (name, number, type)
	values ('DATABASE STATUS', 0, 'D')
--These bits come from sysdatabases.status.
insert spt_values (name, number, type)
	values ('autoclose', 1, 'D')
insert spt_values (name, number, type)
	values ('select into/bulkcopy', 4, 'D')
insert spt_values (name, number, type)
	values ('trunc. log on chkpt.', 8, 'D')
insert spt_values (name, number, type)
	values ('torn page detection', 16, 'D')
insert spt_values (name, number, type)
	values ('loading', 32, 'D')  -- Had been "don't recover".
insert spt_values (name, number, type)
	values ('pre recovery', 64, 'D') -- not settable
insert spt_values (name, number, type)
	values ('recovering', 128, 'D') -- not settable
insert spt_values (name, number, type)
	values ('not recovered', 256, 'D')  -- suspect - not settable
insert into spt_values(name, number, type, low, high)
	values ('offline', 512, 'D', 0, 1)
insert spt_values (name, number, type)
	values ('read only', 1024, 'D')
insert spt_values (name, number, type)
	values ('dbo use only', 2048, 'D')
insert spt_values (name, number, type)
	values ('single user', 4096, 'D')
insert spt_values (name, number, type)
	values ('emergency mode', 32768, 'D') -- not settable
insert spt_values (name, number, type)
	values ('autoshrink',  4194304, 'D')
insert spt_values (name, number, type) -- not settable
	values ('missing files',  0x40000, 'D')
insert spt_values (name, number, type) -- not settable
	values ('cleanly shutdown',  0x40000000, 'D')
insert spt_values (name, number, type)
	values ('ALL SETTABLE OPTIONS', 4202013, 'D')
go


insert spt_values (name, number, type)
	values ('DATABASE OPTIONS', 0, 'D2')
--These bits come from sysdatabases.status2.
insert spt_values (name, number, type)
	values ('db chaining', 0x400, 'D2')
insert spt_values (name, number, type)
	values ('numeric roundabort', 0x800, 'D2')
insert spt_values (name, number, type)
	values ('arithabort', 0x1000, 'D2')
insert spt_values (name, number, type)
	values ('ANSI padding', 0x2000, 'D2')
insert spt_values (name, number, type)
	values ('ANSI null default', 0x4000, 'D2')
insert spt_values (name, number, type)
	values ('concat null yields null', 0x10000, 'D2')
insert spt_values (name, number, type)
	values ('recursive triggers', 0x20000, 'D2')
insert spt_values (name, number, type)
	values ('default to local cursor',  0x100000, 'D2')
insert spt_values (name, number, type)
	values ('quoted identifier', 0x800000, 'D2')
insert spt_values (name, number, type)
	values ('auto create statistics', 0x1000000, 'D2')
insert spt_values (name, number, type)
	values ('cursor close on commit', 0x2000000, 'D2')
insert spt_values (name, number, type)
	values ('ANSI nulls', 0x4000000, 'D2')
insert spt_values (name, number, type)
	values ('ANSI warnings', 0x10000000, 'D2')
insert spt_values (name, number, type) -- not user settable
	values ('full text enabled', 0x20000000, 'D2')
insert spt_values (name, number, type)
	values ('auto update statistics', 0x40000000, 'D2')



-- Sum of bits of all settable DB status options,
-- update when adding such options or modifying existing options to be settable.
insert spt_values (name, number, type)
	values ('ALL SETTABLE OPTIONS', 1469267968|0x800|0x1000|0x2000|0x400, 'D2')
go

raiserror('Insert spt_values.type=''DC '' ....',0,1)
go
---- If you add a bit here make sure you add the value to the value of the ALL SETTABLE DB category option if it is settable with sp_dboption.

insert spt_values (name, number, type)
	values ('DATABASE CATEGORY', 0, 'DC')

--These bits come from sysdatabases.category.
insert spt_values (name, number, type)
	values ('published', 1, 'DC')
insert spt_values (name, number, type)
	values ('subscribed', 2, 'DC')
insert spt_values (name, number, type)
	values ('merge publish', 4, 'DC')

--These are not settable by sp_dboption
insert spt_values (name, number, type)
	values ('Distributed', 16, 'DC')

--Sum of bits of all settable options, update when adding such options or modifying existing options to be settable.
insert spt_values (name, number, type)
	values ('ALL SETTABLE OPTIONS', 7, 'DC')
go

--UNDONE: Are these obsolete?
--raiserror('Insert spt_values.type=''DBV'' ....',0,1)
--go
--insert into spt_values (name ,number ,type,low,high)
--	values ('SYSDATABASES.VERSION', 0, 'DBV',-1,-1) --- dbcc getvalue('current_version') into @@error
--insert into spt_values (name ,number ,type,low,high)
--	values ('4.2' ,199307 ,'DBV',1,1)  --WinNT version
--insert into spt_values (name ,number ,type,low,high)
--	values ('6.0' ,199506 ,'DBV',400,406) --Betas thru Release range was 400-406.
--insert into spt_values (name ,number ,type,low,high)
--	values ('6.5' ,199604 ,'DBV',407,408) --First beta already had 408.

--declare @dbver int
--dbcc getvalue('current_version')
--select @dbver = @@error
--insert into spt_values (name ,number ,type,low,high)
--	values ('7.0' ,199707 ,'DBV',409 ,@dbver)
--go



raiserror('Insert spt_values.type=''E  '' ....',0,1)
go
--Set the machine type
--spt_values.low is the number of bytes in a page for the particular machine.
insert spt_values (name, number, type, low)
	values ('SQLSERVER HOST TYPE', 0, 'E', 0)
go
--Set the platform specific entries.
--spt_values.low is the number of bytes in a page.
insert into spt_values (name, number, type, low)
	values ('WINDOWS/NT', 1, 'E', 8192)

/* Value to set and clear the high bit for int datatypes for os/2.
** Would like to enter -2,147,483,648 to avoid byte order issues, but
** the server won't take it, even in exponential notation.
*/
insert into spt_values (name, number, type, low)
	values ('int high bit', 2, 'E', 0x80000000)

/* Value which gives the byte position of the high byte for int datatypes for
** os/2.  This value was changed from 4 (the usual Intel 80x86 order) to 1
** when binary convert routines were changed to reverse the byte order.  So
** this value is accurate ONLY when ints are converted to binary datatype.
*/
insert into spt_values (name, number, type, low)
	values ('int4 high byte', 3, 'E', 1)
go


raiserror('Insert spt_values.type=''F  '' ....',0,1)
go
insert spt_values (name, number, type)
	values ('SYSREMOTELOGINS TYPES', -1, 'F')
insert spt_values (name, number, type)
	values ('', 0, 'F')
insert spt_values (name, number, type)
	values ('trusted', 1, 'F')
go
insert spt_values (name, number, type)
	values ('SYSREMOTELOGINS TYPES (UPDATE)', -1, 'F_U')
insert spt_values (name, number, type)
	values ('', 0, 'F_U')
insert spt_values (name, number, type)
	values ('trusted', 16, 'F_U')
go



raiserror('Insert spt_values.type=''G  '' ....',0,1)
go
insert spt_values (name, number, type)
	values ('GENERAL MISC. STRINGS', 0, 'G')
insert spt_values (name, number, type)
	values ('SQL Server Internal Table', 0, 'G')
go


raiserror('Insert spt_values.type=''I  '' ....',0,1)
go
insert spt_values (name, number, type)
	values ('INDEX TYPES', 0, 'I')
insert spt_values (name, number, type)
	values ('nonclustered', 0, 'I')
insert spt_values (name, number, type)
	values ('ignore duplicate keys', 1, 'I')
insert spt_values (name, number, type)
	values ('unique', 2, 'I')
insert spt_values (name, number, type)
	values ('ignore duplicate rows', 4, 'I')
insert spt_values (name, number, type)
	values ('clustered', 16, 'I')
insert spt_values (name, number, type)
	values ('hypothetical', 32, 'I')
insert spt_values (name, number, type)
	values ('statistics', 64, 'I')
insert spt_values (name, number, type)
	values ('auto create', 8388608, 'I')
insert spt_values (name, number, type)
        values ('stats no recompute', 16777216, 'I')

--ref integ
insert into spt_values (name, number, type, low, high)
	values ('primary key', 2048, 'I', 0, 1)
insert into spt_values (name, number, type, low, high)
	values ('unique key', 4096, 'I', 0, 1)
go


--Adding listing of physical types that are compatible.
raiserror('Insert spt_values.type=''J  '' ....',0,1)
go
insert spt_values (name, number, type)
	values ('COMPATIBLE TYPES', 0, 'J')
insert spt_values (name, number, low, type)
	values ('binary', 1, 45, 'J')
insert spt_values (name, number, low, type)
	values ('varbinary', 1, 37, 'J')
insert spt_values (name, number, low, type)
	values ('bit', 2, 50, 'J')
insert spt_values (name, number, low, type)
	values ('char', 3, 47, 'J')
insert spt_values (name, number, low, type)
	values ('varchar', 3, 39, 'J')
insert spt_values (name, number, low, type)
	values ('datetime', 4, 61, 'J')
insert spt_values (name, number, low, type)
	values ('datetimn', 4, 111, 'J')
insert spt_values (name, number, low, type)
	values ('smalldatetime', 4, 58, 'J')
insert spt_values (name, number, low, type)
	values ('float', 5, 62, 'J')
insert spt_values (name, number, low, type)
	values ('floatn', 5, 109, 'J')
insert spt_values (name, number, low, type)
	values ('real', 5, 59, 'J')
insert spt_values (name, number, low, type)
	values ('int', 6, 56, 'J')
insert spt_values (name, number, low, type)
	values ('intn', 6, 38, 'J')
insert spt_values (name, number, low, type)
	values ('smallint', 6, 52, 'J')
insert spt_values (name, number, low, type)
	values ('tinyint', 6, 48, 'J')
insert spt_values (name, number, low, type)
	values ('money', 7, 60, 'J')
insert spt_values (name, number, low, type)
	values ('moneyn', 7, 110, 'J')
insert spt_values (name, number, low, type)
	values ('smallmoney', 7, 122, 'J')
go


--?!?! obsolete, old syskeys table.
raiserror('Insert spt_values.type=''K  '' ....',0,1)
go
insert spt_values (name, number, type)
	values ('SYSKEYS TYPES', 0, 'K')
insert spt_values (name, number, type)
	values ('primary', 1, 'K')
insert spt_values (name, number, type)
	values ('foreign', 2, 'K')
insert spt_values (name, number, type)
	values ('common', 3, 'K')
go


raiserror('Insert spt_values.type=''L  '' ....',0,1)
-- See also 'SFL' type.
go
insert spt_values(name, number, type)
  values ('LOCK TYPES', 0, 'L')
insert spt_values(name, number, type)
  values ('NULL', 1, 'L')
insert spt_values(name, number, type)
  values ('Sch-S', 2, 'L')
insert spt_values(name, number, type)
  values ('Sch-M', 3, 'L')
insert spt_values(name, number, type)
  values ('S', 4, 'L')
insert spt_values(name, number, type)
  values ('U', 5, 'L')
insert spt_values(name, number, type)
  values ('X', 6, 'L')
insert spt_values(name, number, type)
  values ('IS', 7, 'L')
insert spt_values(name, number, type)
  values ('IU', 8, 'L')
insert spt_values(name, number, type)
  values ('IX', 9, 'L')
insert spt_values(name, number, type)
  values ('SIU', 10, 'L')
insert spt_values(name, number, type)
  values ('SIX', 11, 'L')
insert spt_values(name, number, type)
  values ('UIX', 12, 'L')
insert spt_values(name, number, type)
  values ('BU', 13, 'L')
insert spt_values(name, number, type)
  values ('RangeS-S', 14, 'L')
insert spt_values(name, number, type)
  values ('RangeS-U', 15, 'L')
insert spt_values(name, number, type)
  values ('RangeIn-Null', 16, 'L')
insert spt_values(name, number, type)
  values ('RangeIn-S', 17, 'L')
insert spt_values(name, number, type)
  values ('RangeIn-U', 18, 'L')
insert spt_values(name, number, type)
  values ('RangeIn-X', 19, 'L')
insert spt_values(name, number, type)
  values ('RangeX-S', 20, 'L')
insert spt_values(name, number, type)
  values ('RangeX-U', 21, 'L')
insert spt_values(name, number, type)
  values ('RangeX-X', 22, 'L')
go

-- Lock Resources.
--
raiserror('Insert spt_values.type=''LR '' ....',0,1)
go
insert spt_values(name, number, type)
  values ('LOCK RESOURCES', 0, 'LR')
insert spt_values(name, number, type)
  values ('NUL', 1, 'LR')
insert spt_values(name, number, type)
  values ('DB', 2, 'LR')
insert spt_values(name, number, type)
  values ('FIL', 3, 'LR')
insert spt_values(name, number, type)
  values ('IDX', 4, 'LR')
insert spt_values(name, number, type)
  values ('TAB', 5, 'LR')
insert spt_values(name, number, type)
  values ('PAG', 6, 'LR')
insert spt_values(name, number, type)
  values ('KEY', 7, 'LR')
insert spt_values(name, number, type)
  values ('EXT', 8, 'LR')
insert spt_values(name, number, type)
  values ('RID', 9, 'LR')
insert spt_values(name, number, type)
  values ('APP', 10, 'LR')
go

-- Lock Request Status Values
--
raiserror('Insert spt_values.type=''LS '' ....',0,1)
go
insert spt_values(name, number, type)
  values ('LOCK REQ STATUS', 0, 'LS')
insert spt_values(name, number, type)
  values ('GRANT', 1, 'LS')
insert spt_values(name, number, type)
  values ('CNVT', 2, 'LS')
insert spt_values(name, number, type)
  values ('WAIT', 3, 'LS')
go

-- Lock Owner Values
--
raiserror('Insert spt_values.type=''LO '' ....',0,1)
go
insert spt_values(name, number, type)
  values ('LOCK REQ STATUS', 0, 'LO')
insert spt_values(name, number, type)
  values ('Xact', 1, 'LO')
insert spt_values(name, number, type)
  values ('Crsr', 2, 'LO')
insert spt_values(name, number, type)
  values ('Sess', 3, 'LO')
go

-- --- 'O' in 6.5, but gone in Sphinx (sysobjects.sysstat) OBSOLETE ?!?!
raiserror('Insert spt_values.type=''O  '' ....',0,1)
go
/*
**  These values define the object type.  The number made from the low
**  4 bits in sysobjects.sysstats indicates the type of object.
*/
insert spt_values (name, number, type)
	values ('OBJECT TYPES', 0, 'O')
insert spt_values (name, number, type)
	values ('system table', 1, 'O')
insert spt_values (name, number, type)
	values ('view', 2, 'O')
insert spt_values (name, number, type)
	values ('user table', 3, 'O')
insert spt_values (name, number, type)
	values ('stored procedure',4, 'O')
--no number 5
insert spt_values (name, number, type)
	values ('default', 6, 'O')
insert spt_values (name, number, type)
	values ('rule', 7, 'O')
insert spt_values (name, number, type)
	values ('trigger', 8, 'O')
insert spt_values (name, number, type)
	values ('replication filter stored procedure', 12, 'O')
go



-- --- 'O9T' sysobjects.type, for reports like sp_help (violate 1NF in name column).
--     These rows new in 7.0 (old 'O' for sysstat are gone).
--     Use  substring(v.name,1,2)  and  substring(v.name,5,31)
raiserror('Insert spt_values.type=''O9T'' ....',0,1)
go
insert into spt_values (name ,number ,type ,low ,high ,status)
	values ('sysobjects.type, reports'            ,0  ,'O9T' ,0 ,0 ,0)
                 ----+----1----+----2----+----3----+
insert into spt_values (name ,number ,type ,low ,high ,status)
	values ('AP: application'                     ,-1 ,'O9T' ,0 ,0 ,0)
insert into spt_values (name ,number ,type ,low ,high ,status)
	values ('C : check cns'                       ,-1 ,'O9T' ,0 ,0 ,0)
insert into spt_values (name ,number ,type ,low ,high ,status)
	values ('D : default (maybe cns)'             ,-1 ,'O9T' ,0 ,0 ,0)
insert into spt_values (name ,number ,type ,low ,high ,status)
	values ('F : foreign key cns'                 ,-1 ,'O9T' ,0 ,0 ,0)
insert into spt_values (name ,number ,type ,low ,high ,status)
	values ('IF: inline function'                 ,-1 ,'O9T' ,0 ,0 ,0)
insert into spt_values (name ,number ,type ,low ,high ,status)
	values ('L : log'                             ,-1 ,'O9T' ,0 ,0 ,0)
insert into spt_values (name ,number ,type ,low ,high ,status)
	values ('P : stored procedure'                ,-1 ,'O9T' ,0 ,0 ,0)
insert into spt_values (name ,number ,type ,low ,high ,status)
    values ('FN: scalar function'                 ,-1 ,'O9T' ,0 ,0 ,0)
insert into spt_values (name ,number ,type ,low ,high ,status)
	values ('PK: primary key cns'                 ,-1 ,'O9T' ,0 ,0 ,0)
insert into spt_values (name ,number ,type ,low ,high ,status)
	values ('R : rule'                            ,-1 ,'O9T' ,0 ,0 ,0)
insert into spt_values (name ,number ,type ,low ,high ,status)
	values ('RF: replication filter proc'         ,-1 ,'O9T' ,0 ,0 ,0)
insert into spt_values (name ,number ,type ,low ,high ,status)
	values ('S : system table'                    ,-1 ,'O9T' ,0 ,0 ,0)
insert into spt_values (name ,number ,type ,low ,high ,status)
    values ('TF: table function'                  ,-1 ,'O9T' ,0 ,0 ,0)
insert into spt_values (name ,number ,type ,low ,high ,status)
	values ('TR: trigger'                         ,-1 ,'O9T' ,0 ,0 ,0)
insert into spt_values (name ,number ,type ,low ,high ,status)
	values ('U : user table'                      ,-1 ,'O9T' ,0 ,0 ,0)
insert into spt_values (name ,number ,type ,low ,high ,status)
	values ('UQ: unique key cns'                  ,-1 ,'O9T' ,0 ,0 ,0)
insert into spt_values (name ,number ,type ,low ,high ,status)
	values ('V : view'                            ,-1 ,'O9T' ,0 ,0 ,0)
insert into spt_values (name ,number ,type ,low ,high ,status)
	values ('X : extended stored proc'            ,-1 ,'O9T' ,0 ,0 ,0)
go



--Adding bit position information  ''P''  (helpful with sysprotects.columns).
raiserror('Insert spt_values.type=''P  '' ....',0,1)
go
---- Cannot insert a header/dummy description row for type='P  ' (Bit Position rows).

insert spt_values (name ,number ,type ,low ,high ,status) values (null ,0 ,'P  ' ,1 ,0x00000001 ,0)
insert spt_values (name ,number ,type ,low ,high ,status) values (null ,1 ,'P  ' ,1 ,0x00000002 ,0)
insert spt_values (name ,number ,type ,low ,high ,status) values (null ,2 ,'P  ' ,1 ,0x00000004 ,0)
insert spt_values (name ,number ,type ,low ,high ,status) values (null ,3 ,'P  ' ,1 ,0x00000008 ,0)

insert spt_values (name ,number ,type ,low ,high ,status) values (null ,4 ,'P  ' ,1 ,0x00000010 ,0)
insert spt_values (name ,number ,type ,low ,high ,status) values (null ,5 ,'P  ' ,1 ,0x00000020 ,0)
insert spt_values (name ,number ,type ,low ,high ,status) values (null ,6 ,'P  ' ,1 ,0x00000040 ,0)
insert spt_values (name ,number ,type ,low ,high ,status) values (null ,7 ,'P  ' ,1 ,0x00000080 ,0)

go

-- 'P  ' continued....
declare
	 @number_track		integer
	,@char_number_track	varchar(12)

select	 @number_track		= 7
select	 @char_number_track	= convert(varchar,@number_track)

while @number_track <= 127
	begin

	raiserror('type=''P  '' ,@number_track=%d' ,0,1 ,@number_track)

	EXECUTE(
	'
	insert spt_values (name ,number ,type ,low ,high ,status)
	  select
		 null

		,(select	 max(c_val.number)
			from	 spt_values	c_val
			where	 c_val.type = ''P  ''
			and	 c_val.number between 0 and ' + @char_number_track + '
		 )
			+ a_val.number + 1

		,''P  ''

		,(select	 max(b_val.low)
			from	 spt_values	b_val
			where	 b_val.type = ''P  ''
			and	 b_val.number between 0 and ' + @char_number_track + '
		 )
			+ 1 + (a_val.number / 8)

		,a_val.high
		,0
	    from
		 spt_values	a_val
	    where
		 a_val.type = ''P  ''
	    and	 a_val.number between 0 and ' + @char_number_track + '
	')


	select @number_track = ((@number_track + 1) * 2) - 1
	select @char_number_track = convert(varchar,@number_track)

	end --loop

go


--sysobjects.userstat in 6.5 and backward.  Obsolete ?!?!
raiserror('Insert spt_values.type=''R  '' ....',0,1)
go
/*
**  These values translate the object type's userstat bits.  If the high
**  bit is set for a sproc, then it's a report.
*/
insert spt_values (name, number, type)
	values ('REPORT TYPES', 0, 'R')
insert spt_values (name, number, type)
	values ('', 0, 'R')
insert spt_values (name, number, type)
	values (' (rpt)', -32768, 'R')
go



raiserror('Insert spt_values.type=''SFL'' ....',0,1)
---------------------------------------
-- StarFighter Lock Description Strings
---------------------------------------
go
insert spt_values(name, number, type)
  values ('SF LOCK TYPES', 0, 'SFL')
insert spt_values(name, number, type)
  values ('Extent Lock - Exclusive', 8, 'SFL')
insert spt_values(name, number, type)
  values ('Extent Lock - Update', 9, 'SFL')
insert spt_values(name, number, type)
  values ('Extent Lock - Next', 11, 'SFL')
insert spt_values(name, number, type)
  values ('Extent Lock - Previous', 12, 'SFL')
go



--type=''SOP'' rows for SET Options status info.   See sp_help_setopts, @@options, and config=1534 (''user options'').
raiserror('Insert spt_values.type=''SOP'' ....',0,1)
go
--status&1=1 means configurable via 'user options'.
insert into spt_values (name ,number ,type ,status) values
      ('@@OPTIONS' ,0 ,'SOP' ,0)

insert into spt_values (name ,number ,type ,status) values
      ('disable_def_cnst_check'  ,1 ,'SOP' ,1)

insert into spt_values (name ,number ,type ,status) values
      ('implicit_transactions'   ,2 ,'SOP' ,1)

insert into spt_values (name ,number ,type ,status) values
      ('cursor_close_on_commit'  ,4 ,'SOP' ,1)

insert into spt_values (name ,number ,type ,status) values
      ('ansi_warnings'           ,8 ,'SOP' ,1)

insert into spt_values (name ,number ,type ,status) values
      ('ansi_padding'            ,16 ,'SOP' ,1)

insert into spt_values (name ,number ,type ,status) values
      ('ansi_nulls'              ,32 ,'SOP' ,1)

insert into spt_values (name ,number ,type ,status) values
      ('arithabort'              ,64 ,'SOP' ,1)

insert into spt_values (name ,number ,type ,status) values
      ('arithignore'             ,128 ,'SOP' ,1)

insert into spt_values (name ,number ,type ,status) values
      ('quoted_identifier'       ,256 ,'SOP' ,1)

insert into spt_values (name ,number ,type ,status) values
      ('nocount'                 ,512 ,'SOP' ,1)

--Mutually exclusive when ON.
insert into spt_values (name ,number ,type ,status) values
      ('ansi_null_dflt_on'       ,1024 ,'SOP' ,1)
insert into spt_values (name ,number ,type ,status) values
      ('ansi_null_dflt_off'      ,2048 ,'SOP' ,1)

insert into spt_values (name ,number ,type ,status) values
      ('concat_null_yields_null' ,0x1000 ,'SOP' ,1)

insert into spt_values (name ,number ,type ,status) values
      ('numeric_roundabort'      ,0x2000 ,'SOP' ,1)

insert into spt_values (name ,number ,type ,status) values
      ('xact_abort'			     ,0x4000 ,'SOP' ,1)
go


--Adding sysprotects.action AND protecttype values: thus 'T  ' overloaded but just happens to not share any one integer.
raiserror('Insert spt_values.type=''T  '' ....',0,1)
go
insert spt_values(name, number, type)
  values ('SYSPROTECTS.ACTION', 0, 'T')
insert spt_values(name, number, type)
  values ('References', 26, 'T')
insert spt_values(name, number, type)
  values ('Create Function', 178, 'T')
insert spt_values(name, number, type)
  values ('Select', 193, 'T')          --- action
insert spt_values(name, number, type)
  values ('Insert', 195, 'T')  --- Covers BCPin and LoadTable.
insert spt_values(name, number, type)
  values ('Delete', 196, 'T')
insert spt_values(name, number, type)
  values ('Update', 197, 'T')
insert spt_values(name, number, type)
  values ('Create Table', 198, 'T')
insert spt_values(name, number, type)
  values ('Create Database', 203, 'T')

insert spt_values(name, number, type)
  values ('Grant_WGO', 204, 'T')
insert spt_values(name, number, type)
  values ('Grant', 205, 'T')           --- protecttype
insert spt_values(name, number, type)
  values ('Deny', 206, 'T')

insert spt_values(name, number, type)
  values ('Create View', 207, 'T')
insert spt_values(name, number, type)
  values ('Create Procedure', 222, 'T')
insert spt_values(name, number, type)
  values ('Execute', 224, 'T')
insert spt_values(name, number, type)
  values ('Backup Database', 228, 'T')
insert spt_values(name, number, type)
  values ('Create Default', 233, 'T')
insert spt_values(name, number, type)
  values ('Backup Transaction', 235, 'T')
insert spt_values(name, number, type)
  values ('Create Rule', 236, 'T')

insert spt_values(name, number, type)
  values ('Cross DB Ownership Chaining', 158, 'T')
go

raiserror('Insert spt_values.type=''V  '' ....',0,1)
go
insert spt_values (name, number, type)
	values ('SYSDEVICES STATUS', 0, 'V')
insert spt_values (name, number, type)
	values ('default disk', 1, 'V')
insert spt_values (name, number, type)
	values ('physical disk', 2, 'V')
insert spt_values (name, number, type)
	values ('logical disk', 4, 'V')
insert spt_values (name, number, type)
	values ('skip header', 8, 'V')
insert spt_values (name, number, type)
	values ('backup device', 16, 'V')
insert spt_values (name, number, type)
	values ('serial writes', 32, 'V')
insert into spt_values(name, number, type, low, high)
	values ('read only', 4096, 'V', 0, 1)
insert into spt_values(name, number, type, low, high)
	values ('deferred', 8192, 'V', 0, 1)
go


-- Values for fixed server roles.
raiserror('Insert spt_values.type=''SRV'' ...',0,1)
go
-- sysadmin
insert spt_values(name, number, type, low)
  values ('System Administrators', 16, 'SRV', -1)
insert spt_values(name, number, type, low)
  values ('sysadmin', 16, 'SRV', 0)
insert spt_values(name, number, type, low)
  values ('Raiserror With Log', 16, 'SRV', 1)
insert spt_values(name, number, type, low)
  values ('Constraints on System tables', 16, 'SRV', 2)
insert spt_values(name, number, type, low)
  values ('dbcc traceon/off', 16, 'SRV', 3)
insert spt_values(name, number, type, low)
  values ('dbcc setioweight', 16, 'SRV', 4)
insert spt_values(name, number, type, low)
  values ('dbcc setcpuweight', 16, 'SRV', 5)
insert spt_values(name, number, type, low)
  values ('dbcc showoptweights', 16, 'SRV', 6)
insert spt_values(name, number, type, low)
  values ('dbcc change ''on'' rules', 16, 'SRV', 7)
insert spt_values(name, number, type, low)
  values ('dbcc inputbuffer', 16, 'SRV', 8)
insert spt_values(name, number, type, low)
  values ('USE to a suspect database', 16, 'SRV', 9)
insert spt_values(name, number, type, low)
  values ('Create/delete/modify system tables', 16, 'SRV', 10)
insert spt_values(name, number, type, low)
  values ('Create indices on system tables', 16, 'SRV', 11)
insert spt_values(name, number, type, low)
  values ('Complete SETUSER SQL user', 16, 'SRV', 13)
insert spt_values(name, number, type, low)
  values ('Add extended procedures', 16, 'SRV', 14)
insert spt_values(name, number, type, low)
  values ('Add member to sysadmin', 16, 'SRV', 15)
insert spt_values(name, number, type, low)
  values ('sp_altermessage', 16, 'SRV', 16)
insert spt_values(name, number, type, low)
  values ('sp_dboption update part', 16, 'SRV', 17)
insert spt_values(name, number, type, low)
  values ('sp_updatestats', 16, 'SRV', 18)
insert spt_values(name, number, type, low)
  values ('sp_password', 16, 'SRV', 19)
insert spt_values(name, number, type, low)
  values ('sp_change_users_login', 16, 'SRV', 20)
insert spt_values(name, number, type, low)
  values ('sp_changedbowner', 16, 'SRV', 21)
insert spt_values(name, number, type, low)	-- backward-compat only
  values ('sp_adduser', 16, 'SRV', 22)
insert spt_values(name, number, type, low)
  values ('BULK INSERT', 16, 'SRV', 23)
insert spt_values(name, number, type, low)
  values ('DBCC ShrinkDatabase', 16, 'SRV', 24)
insert spt_values(name, number, type, low)
  values ('DBCC ShrinkFile', 16, 'SRV', 25)
insert spt_values(name, number, type, low)
  values ('sp_dropremotelogin', 16, 'SRV', 26)
insert spt_values(name, number, type, low)
  values ('sp_fulltext_service', 16, 'SRV', 27)
insert spt_values(name, number, type, low)
  values ('sp_remoteoption', 16, 'SRV', 28)
insert spt_values(name, number, type, low)
  values ('dbcc outputbuffer', 16, 'SRV', 29)
insert spt_values(name, number, type, low)
  values ('dbcc checkfilegroup', 16, 'SRV', 30)
insert spt_values(name, number, type, low)
  values ('dbcc checkdb', 16, 'SRV', 31)
insert spt_values(name, number, type, low)
  values ('dbcc checkident', 16, 'SRV', 32)
insert spt_values(name, number, type, low)
  values ('dbcc checktable', 16, 'SRV', 33)
insert spt_values(name, number, type, low)
  values ('dbcc dbreindex', 16, 'SRV', 34)
insert spt_values(name, number, type, low)
  values ('dbcc proccache', 16, 'SRV', 35)
insert spt_values(name, number, type, low)
  values ('dbcc show_statistics', 16, 'SRV', 36)
insert spt_values(name, number, type, low)
  values ('dbcc showcontig', 16, 'SRV', 37)
insert spt_values(name, number, type, low)
  values ('dbcc pintable', 16, 'SRV', 38)
insert spt_values(name, number, type, low)
  values ('dbcc dropcleanbuffers', 16, 'SRV', 39)

-- securityadmin
insert spt_values(name, number, type, low)
  values ('Security Administrators', 32, 'SRV', -1)
insert spt_values(name, number, type, low)
  values ('securityadmin', 32, 'SRV', 0)
insert spt_values(name, number, type, low)
  values ('sp_grantlogin', 32, 'SRV', 1)
insert spt_values(name, number, type, low)
  values ('sp_revokelogin', 32, 'SRV', 2)
insert spt_values(name, number, type, low)
  values ('sp_denylogin', 32, 'SRV', 3)
insert spt_values(name, number, type, low)
  values ('sp_addlogin', 32, 'SRV', 4)
insert spt_values(name, number, type, low)
  values ('sp_droplogin', 32, 'SRV', 5)
insert spt_values(name, number, type, low)
  values ('Read the error log', 32, 'SRV', 6)
insert spt_values(name, number, type, low)
  values ('Add member to securityadmin', 32, 'SRV', 7)
insert spt_values(name, number, type, low)
  values ('Grant/deny/revoke CREATE DATABASE', 32, 'SRV', 8)
insert spt_values(name, number, type, low)
  values ('sp_helplogins', 32, 'SRV', 9)
insert spt_values(name, number, type, low)
  values ('sp_password', 32, 'SRV', 10)
insert spt_values(name, number, type, low)
  values ('sp_defaultdb', 32, 'SRV', 11)
insert spt_values(name, number, type, low)
  values ('sp_defaultlanguage', 32, 'SRV', 12)
insert spt_values(name, number, type, low)
  values ('sp_addlinkedsrvlogin', 32, 'SRV', 13)
insert spt_values(name, number, type, low)
  values ('sp_droplinkedsrvlogin', 32, 'SRV', 14)
insert spt_values(name, number, type, low)
  values ('sp_dropremotelogin', 32, 'SRV', 15)
insert spt_values(name, number, type, low)
  values ('sp_remoteoption (update)', 32, 'SRV', 16)

-- serveradmin
insert spt_values(name, number, type, low)
  values ('Server Administrators', 64, 'SRV', -1)
insert spt_values(name, number, type, low)
  values ('serveradmin', 64, 'SRV', 0)
insert spt_values(name, number, type, low)
  values ('RECONFIGURE', 64, 'SRV', 1)
insert spt_values(name, number, type, low)
  values ('SHUTDOWN', 64, 'SRV', 2)
insert spt_values(name, number, type, low)
  values ('Add member to serveradmin', 64, 'SRV', 3)
insert spt_values(name, number, type, low)
  values ('sp_fulltext_service', 64, 'SRV', 4)
insert spt_values(name, number, type, low)
  values ('sp_configure', 64, 'SRV', 5)
insert spt_values(name, number, type, low)
  values ('sp_tableoption', 64, 'SRV', 6)
insert spt_values(name, number, type, low)
  values ('dbcc freeproccache', 64, 'SRV', 7)

-- setupadmin
insert spt_values(name, number, type, low)
  values ('Setup Administrators', 128, 'SRV', -1)
insert spt_values(name, number, type, low)
  values ('setupadmin', 128, 'SRV', 0)
insert spt_values(name, number, type, low)
  values ('Add member to setupadmin', 128, 'SRV', 1)
insert spt_values(name, number, type, low)
  values ('Add/drop/configure linked servers', 128, 'SRV', 2)
insert spt_values(name, number, type, low)
  values ('Mark a stored procedure as startup', 128, 'SRV', 3)

-- processadmin
insert spt_values(name, number, type, low)
  values ('Process Administrators', 256, 'SRV', -1)
insert spt_values(name, number, type, low)
  values ('processadmin', 256, 'SRV', 0)
insert spt_values(name, number, type, low)
  values ('KILL', 256, 'SRV', 1)
insert spt_values(name, number, type, low)
  values ('Add member to processadmin', 256, 'SRV', 2)

-- diskadmin
insert spt_values(name, number, type, low)
  values ('Disk Administrators', 512, 'SRV', -1)
insert spt_values(name, number, type, low)
  values ('diskadmin', 512, 'SRV', 0)
insert spt_values(name, number, type, low)
  values ('DISK INIT', 512, 'SRV', 1)
insert spt_values(name, number, type, low)
  values ('Add member to diskadmin', 512, 'SRV', 6)
insert spt_values(name, number, type, low)
  values ('sp_addumpdevice', 512, 'SRV', 7)
insert spt_values(name, number, type, low)
  values ('sp_diskdefault', 512, 'SRV', 8)
insert spt_values(name, number, type, low)
  values ('sp_dropdevice', 512, 'SRV', 9)

-- dbcreator
insert spt_values(name, number, type, low)
  values ('Database Creators', 1024, 'SRV', -1)
insert spt_values(name, number, type, low)
  values ('dbcreator', 1024, 'SRV', 0)
insert spt_values(name, number, type, low)
  values ('CREATE DATABASE', 1024, 'SRV', 1)
insert spt_values(name, number, type, low)
  values ('ALTER DATABASE', 1024, 'SRV', 2)
insert spt_values(name, number, type, low)
  values ('Add member to dbcreator', 1024, 'SRV', 3)
insert spt_values(name, number, type, low)
  values ('Extend database', 1024, 'SRV', 4)
insert spt_values(name, number, type, low)
  values ('sp_renamedb', 1024, 'SRV', 5)
insert spt_values(name, number, type, low)
  values ('RESTORE DATABASE', 1024, 'SRV', 6)
insert spt_values(name, number, type, low)
  values ('RESTORE LOG', 1024, 'SRV', 7)
insert spt_values(name, number, type, low)
  values ('DROP DATABASE', 1024, 'SRV', 8)
go

-- bulkadmin
insert spt_values(name, number, type, low)
  values ('Bulk Insert Administrators', 4096, 'SRV', -1)
insert spt_values(name, number, type, low)
  values ('bulkadmin', 4096, 'SRV', 0)
insert spt_values(name, number, type, low)
  values ('BULK INSERT', 4096, 'SRV', 1)
insert spt_values(name, number, type, low)
  values ('Add member to bulkadmin', 4096, 'SRV', 1)
go


-- Values for fixed db roles.
raiserror('Insert spt_values.type=''DBR'' ...',0,1)
go

-- db_owner
-- Note: names are nvarchar(35) currently.
insert spt_values(name, number, type, low)
  values ('DB Owners', 16384, 'DBR', -1)
insert spt_values(name, number, type, low)
  values ('EXECUTE any procedure', 16384, 'DBR', 1)
insert spt_values(name, number, type, low)
  values ('sp_change_users_login', 16384, 'DBR', 2)
insert spt_values(name, number, type, low)
  values ('Add/drop to/from db_accessadmin', 16384, 'DBR', 3)
insert spt_values(name, number, type, low)
  values ('Add/drop to/from db_owner', 16384, 'DBR', 4)
insert spt_values(name, number, type, low)
  values ('Add/drop to/from db_securityadmin', 16384, 'DBR', 5)
insert spt_values(name, number, type, low)
  values ('Add/drop to/from db_ddladmin', 16384, 'DBR', 6)
insert spt_values(name, number, type, low)
  values ('Add/drop to/from db_backupoperator', 16384, 'DBR', 7)
insert spt_values(name, number, type, low)
  values ('Add/drop to/from db_datareader', 16384, 'DBR', 8)
insert spt_values(name, number, type, low)
  values ('Add/drop to/from db_datawriter', 16384, 'DBR', 9)
insert spt_values(name, number, type, low)
  values ('Add/drop to/from db_denydatareader', 16384, 'DBR', 10)
insert spt_values(name, number, type, low)
  values ('Add/drop to/from db_denydatawriter', 16384, 'DBR', 11)
insert spt_values(name, number, type, low)
  values ('dbcc checkalloc', 16384, 'DBR', 12)
insert spt_values(name, number, type, low)
  values ('sp_fulltext_catalog', 16384, 'DBR', 13)
insert spt_values(name, number, type, low)
  values ('sp_fulltext_database', 16384, 'DBR', 14)
insert spt_values(name, number, type, low)
  values ('sp_fulltext_table', 16384, 'DBR', 15)
insert spt_values(name, number, type, low)
  values ('dbcc checkdb', 16384, 'DBR', 16)
insert spt_values(name, number, type, low)
  values ('dbcc checkfilegroup', 16384, 'DBR', 17)
insert spt_values(name, number, type, low)
  values ('dbcc checkident', 16384, 'DBR', 18)
insert spt_values(name, number, type, low)
  values ('dbcc checktable', 16384, 'DBR', 19)
insert spt_values(name, number, type, low)
  values ('dbcc dbreindex', 16384, 'DBR', 20)
insert spt_values(name, number, type, low)
  values ('dbcc proccache', 16384, 'DBR', 21)
insert spt_values(name, number, type, low)
  values ('dbcc show_statistics', 16384, 'DBR', 22)
insert spt_values(name, number, type, low)
  values ('dbcc showcontig', 16384, 'DBR', 23)
insert spt_values(name, number, type, low)
  values ('dbcc shrinkdatabase', 16384, 'DBR', 24)
insert spt_values(name, number, type, low)
  values ('dbcc shrinkfile', 16384, 'DBR', 25)
insert spt_values(name, number, type, low)
  values ('sp_refreshview', 16384, 'DBR', 26)
insert spt_values(name, number, type, low)
  values ('sp_dbcmptlevel', 16384, 'DBR', 27)
insert spt_values(name, number, type, low)
  values ('sp_dboption (update)', 16384, 'DBR', 28)
insert spt_values(name, number, type, low)
  values ('dbcc updateusage', 16384, 'DBR', 29)

-- db_accessadmin
insert spt_values(name, number, type, low)
  values ('DB Access Administrators', 16385, 'DBR', -1)
insert spt_values(name, number, type, low)
  values ('sp_grantdbaccess', 16385, 'DBR', 1)
insert spt_values(name, number, type, low)
  values ('sp_revokedbaccess', 16385, 'DBR', 2)
insert spt_values(name, number, type, low)
  values ('sp_dropuser', 16385, 'DBR', 3)
insert spt_values(name, number, type, low)
  values ('sp_addalias', 16385, 'DBR', 4)
insert spt_values(name, number, type, low)
  values ('sp_dropalias', 16385, 'DBR', 5)

-- db_securityadmin
insert spt_values(name, number, type, low)
  values ('DB Security Administrators', 16386, 'DBR', -1)
insert spt_values(name, number, type, low)
  values ('sp_addrolemember', 16386, 'DBR', 1)
insert spt_values(name, number, type, low)
  values ('sp_droprolemember', 16386, 'DBR', 2)
insert spt_values(name, number, type, low)
  values ('sp_addrole', 16386, 'DBR', 3)
insert spt_values(name, number, type, low)
  values ('sp_droprole', 16386, 'DBR', 4)
insert spt_values(name, number, type, low)
  values ('GRANT', 16386, 'DBR', 5)
insert spt_values(name, number, type, low)
  values ('REVOKE', 16386, 'DBR', 6)
insert spt_values(name, number, type, low)
  values ('DENY', 16386, 'DBR', 7)
insert spt_values(name, number, type, low)
  values ('sp_addapprole', 16386, 'DBR', 8)
insert spt_values(name, number, type, low)
  values ('sp_dropapprole', 16386, 'DBR', 9)
insert spt_values(name, number, type, low)
  values ('sp_approlepassword', 16386, 'DBR', 10)
insert spt_values(name, number, type, low)
  values ('sp_changeobjectowner', 16386, 'DBR', 11)
insert spt_values(name, number, type, low)
  values ('sp_changegroup', 16386, 'DBR', 12)
insert spt_values(name, number, type, low)
  values ('sp_dropgroup', 16386, 'DBR', 13)
insert spt_values(name, number, type, low)
  values ('sp_addgroup', 16386, 'DBR', 14)

-- db_ddladmin
insert spt_values(name, number, type, low)
  values ('DB DDL Administrators', 16387, 'DBR', -1)
insert spt_values(name, number, type, low)
  values ('All DDL but GRANT, REVOKE, DENY', 16387, 'DBR', 1)
insert spt_values(name, number, type, low)
  values ('REFERENCES permission on any table', 16387, 'DBR', 2)
insert spt_values(name, number, type, low)
  values ('sp_recompile', 16387, 'DBR', 3)
insert spt_values(name, number, type, low)
  values ('sp_tableoption', 16387, 'DBR', 4)
insert spt_values(name, number, type, low)
  values ('sp_rename', 16387, 'DBR', 5)
insert spt_values(name, number, type, low)
  values ('sp_changeobjectowner', 16387, 'DBR', 6)
insert spt_values(name, number, type, low)
  values ('sp_fulltext_column', 16387, 'DBR', 7)
insert spt_values(name, number, type, low)
  values ('sp_fulltext_table', 16387, 'DBR', 8)
insert spt_values(name, number, type, low)
  values ('TRUNCATE TABLE', 16387, 'DBR', 9)
insert spt_values(name, number, type, low)
  values ('dbcc show_statistics', 16387, 'DBR', 10)
insert spt_values(name, number, type, low)
  values ('dbcc showcontig', 16387, 'DBR', 11)
insert spt_values(name, number, type, low)
  values ('dbcc cleantable', 16387, 'DBR', 12)



-- db_backupoperator
insert spt_values(name, number, type, low)
  values ('DB Backup Operator', 16389, 'DBR', -1)
insert spt_values(name, number, type, low)
  values ('CHECKPOINT', 16389, 'DBR', 1)
insert spt_values(name, number, type, low)
  values ('BACKUP LOG', 16389, 'DBR', 2)
insert spt_values(name, number, type, low)
  values ('BACKUP DATABASE', 16389, 'DBR', 3)


-- db_datareader
insert spt_values(name, number, type, low)
  values ('DB Data Reader', 16390, 'DBR', -1)
insert spt_values(name, number, type, low)
  values ('SELECT permission on any object', 16390, 'DBR', 1)

-- db_datawriter
insert spt_values(name, number, type, low)
  values ('DB Data Writer', 16391, 'DBR', -1)
insert spt_values(name, number, type, low)
  values ('INSERT permission on any object', 16391, 'DBR', 1)
insert spt_values(name, number, type, low)
  values ('UPDATE permission on any object', 16391, 'DBR', 2)
insert spt_values(name, number, type, low)
  values ('DELETE permission on any object', 16391, 'DBR', 3)

-- db_denydatareader
insert spt_values(name, number, type, low)
  values ('DB Deny Data Reader', 16392, 'DBR', -1)
insert spt_values(name, number, type, low)
  values ('No SELECT permission on any object', 16392, 'DBR', 1)

-- db_denydatawriter
insert spt_values(name, number, type, low)
  values ('DB Deny Data Writer', 16393, 'DBR', -1)
insert spt_values(name, number, type, low)
  values ('No INSERT permission on any object', 16393, 'DBR', 1)
insert spt_values(name, number, type, low)
  values ('No UPDATE permission on any object', 16393, 'DBR', 2)
insert spt_values(name, number, type, low)
  values ('No DELETE permission on any object', 16393, 'DBR', 3)
go


update statistics spt_values
go

------------------------------------------------------------------
go
exec sp_MS_upd_sysobj_category 2
go
------------------------------------------------------------------

/********
if object_id('sp_configure','P') IS NOT NULL
	begin
		exec sp_configure 'allow updates',0
		reconfigure with override
	end
********/
go

declare @vdt varchar(99)
select  @vdt = convert(varchar,getdate(),113)
raiserror('Finishing at  %s',0,1,@vdt)
go

backup tran master with no_log
go
checkpoint
go
print 'End of .SQL file.'
go
-- -




