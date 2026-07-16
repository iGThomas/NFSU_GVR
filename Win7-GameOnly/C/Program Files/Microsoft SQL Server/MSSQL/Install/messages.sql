--Messages.sql  Doc edit of messages 6/6/2000- Final Edit Pass

/*
** Messages.SQL		1996/07/03 13:44
**
** DO NOT ADD NEW MESSAGES DIRECTLY TO THIS FILE. Add them to msgwork.sql instead.
** SQL UE will edit the messages and propogate them to this file.
** Obsolete messages should be deleted directly from this file, however.
**
**    Please coordinate new range reservations through SQLEvent\SQLEvent.MC file!
**
** (For Sphinx, post BldMastr.exe)
**
** Copyright Microsoft, Inc. 1994 - 2000
** All Rights Reserved.
*/

DBCC TraceOff(3643) --Ensure sysdatabases.version for master db row shows proper value.
go
use master
go
backup Transaction master with no_log
go
Checkpoint
go
set nocount on
set implicit_transactions off
go

---- Output the filename and datetime.

declare @vdt varchar(99)
select  @vdt = convert(varchar,getdate(),113)
raiserror('Starting Install\Messages.SQL at  %s',0,1,@vdt) with nowait

raiserror(' ',0,1)
raiserror('Making sure that updates to system tables are allowed.',0,1) with nowait
go

---- Ensure we can update system catalog tables.

declare  @dbcc_current_version	integer
	,@int1			integer
dbcc getvalue('current_version')
select @dbcc_current_version = @@error

if (     object_id('sp_configure','P') IS NOT NULL
    AND  @dbcc_current_version = (select version from sysdatabases where name='master')
    AND  1 <> (select value from syscurconfigs where config = 102)
   )
	begin
	exec @int1 = sp_configure 'allow updates',1
	if @@error <> 0 or @int1 <> 0
		raiserror('Bad sp_configure exec at top of Messages.SQL, killing spid.'
			,22,127) with log
	reconfigure with override
	end
go


---- Make sure server was started in single user mode or that sp_configure was used to enable updates to system tables.

if (select value from syscurconfigs where config = 102) <> 1
	raiserror ('Cannot run Messages.SQL unless updates to system tables are enabled.  Shutdown server and restart with the ''-m'' option or use sp_configure to enable updates to system tables.'
		,22,127) with log
go

backup Transaction master with no_log
Checkpoint
go

-- DELETE EXISTING SYSTEM MESSAGES (1-49999)
DELETE sysmessages WHERE error BETWEEN 1 AND 49999
go

backup Transaction master with no_log
go

set nocount on
go

--- INSERT NEW SYSTEM MESSAGES (backup TRAN every so often)
raiserror(' ',0,1)
raiserror('Adding system error messages.',0,1) with nowait
GO


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1 ,10 ,0 ,'Version date of last upgrade: 10/11/90.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21 ,10 ,0 ,'Warning: Fatal error %d occurred at %S_DATE. Note the error and time, and contact your system administrator.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(102 ,15 ,0 ,'Incorrect syntax near ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(103 ,15 ,0 ,'The %S_MSG that starts with ''%.*ls'' is too long. Maximum length is %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(104 ,15 ,0 ,'ORDER BY items must appear in the select list if the statement contains a UNION operator.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(105 ,15 ,0 ,'Unclosed quotation mark before the character string ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(106 ,16 ,0 ,'Too many table names in the query. The maximum allowable is %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(107 ,15 ,0 ,'The column prefix ''%.*ls'' does not match with a table name or alias name used in the query.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(108 ,15 ,0 ,'The ORDER BY position number %ld is out of range of the number of items in the select list.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(109 ,15 ,0 ,'There are more columns in the INSERT statement than values specified in the VALUES clause. The number of values in the VALUES clause must match the number of columns specified in the INSERT statement.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(110 ,15 ,0 ,'There are fewer columns in the INSERT statement than values specified in the VALUES clause. The number of values in the VALUES clause must match the number of columns specified in the INSERT statement.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(111 ,15 ,0 ,'''%ls'' must be the first statement in a query batch.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(112 ,15 ,0 ,'Variables are not allowed in the %ls statement.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(113 ,15 ,0 ,'Missing end comment mark ''*/''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(114 ,15 ,0 ,'Browse mode is invalid for a statement that assigns values to a variable.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(116 ,15 ,0 ,'Only one expression can be specified in the select list when the subquery is not introduced with EXISTS.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(117 ,15 ,0 ,'The %S_MSG name ''%.*ls'' contains more than the maximum number of prefixes. The maximum is %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(118 ,15 ,0 ,'Only members of the sysadmin role can specify the %ls option for the %ls statement.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(119 ,15 ,0 ,'Must pass parameter number %d and subsequent parameters as ''@name = value''. After the form ''@name = value'' has been used, all subsequent parameters must be passed in the form ''@name = value''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(120 ,15 ,0 ,'The select list for the INSERT statement contains fewer items than the insert list. The number of SELECT values must match the number of INSERT columns.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(121 ,15 ,0 ,'The select list for the INSERT statement contains more items than the insert list. The number of SELECT values must match the number of INSERT columns.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(122 ,15 ,0 ,'The %ls option is allowed only with %ls syntax.' ,1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(123 ,15 ,0 , 'Batch/procedure exceeds maximum length of %d characters.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(124 ,15 ,0 ,'CREATE PROCEDURE contains no statements.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(125 ,15 ,0 ,'Case expressions may only be nested to level %d.' ,1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(128 ,15 ,0 ,'The name ''%.*ls'' is not permitted in this context. Only constants, expressions, or variables allowed here. Column names are not permitted.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(129 ,15 ,0 ,'Fillfactor %d is not a valid percentage; fillfactor must be between 1 and 100.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(130 ,16 ,0 ,'Cannot perform an aggregate function on an expression containing an aggregate or a subquery.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(131 ,15 ,0 ,'The size (%d) given to the %S_MSG ''%.*ls'' exceeds the maximum allowed for any data type (%d).' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(132 ,15 ,0 ,'The label ''%.*ls'' has already been declared. Label names must be unique within a query batch or stored procedure.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(133 ,15 ,0 ,'A GOTO statement references the label ''%.*ls'' but the label has not been declared.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(134 ,15 ,0 ,'The variable name ''%.*ls'' has already been declared. Variable names must be unique within a query batch or stored procedure.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(135 ,15 ,0 ,'Cannot use a BREAK statement outside the scope of a WHILE statement.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(136 ,15 ,0 ,'Cannot use a CONTINUE statement outside the scope of a WHILE statement.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(137 ,15 ,0 ,'Must declare the variable ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(138 ,15 ,0 ,'Correlation clause in a subquery not permitted.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(139 ,15 ,0 ,'Cannot assign a default value to a local variable.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(140 ,15 ,0 ,'Can only use IF UPDATE within a CREATE TRIGGER statement.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(141 ,15 ,0 ,'A SELECT statement that assigns a value to a variable must not be combined with data-retrieval operations.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(142 ,15 ,0 ,'Incorrect syntax for definition of the ''%ls'' constraint.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(143 ,15 ,0 ,'A COMPUTE BY item was not found in the order by list. All expressions in the compute by list must also be present in the order by list.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(144 ,15 ,0 ,'Cannot use an aggregate or a subquery in an expression used for the group by list of a GROUP BY clause.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(145 ,15 ,0 ,'ORDER BY items must appear in the select list if SELECT DISTINCT is specified.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(146 ,15 ,0 ,'Could not allocate ancillary table for a subquery. Maximum number of tables in a query (%d) exceeded.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(147 ,15 ,0 ,'An aggregate may not appear in the WHERE clause unless it is in a subquery contained in a HAVING clause or a select list, and the column being aggregated is an outer reference.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(148 ,15 ,0 ,'Incorrect time syntax in time string ''%.*ls'' used with WAITFOR.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(149 ,15 ,0 ,'Time value ''%.*ls'' used with WAITFOR is not a valid value. Check date/time syntax.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(150 ,15 ,0 ,'Both terms of an outer join must contain columns.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(151 ,15 ,0 ,'''%.*ls'' is an invalid money value.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(153 ,15 ,0 ,'Invalid usage of the option %.*ls in the %ls statement.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(154 ,15 ,0 ,'%S_MSG is not allowed in %S_MSG.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(155 ,15 ,0 ,'''%.*ls'' is not a recognized %ls option.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(156 ,15 ,0 ,'Incorrect syntax near the keyword ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(157 ,15 ,0 ,'An aggregate may not appear in the set list of an UPDATE statement.' ,1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(159 ,15 ,0 ,'For DROP INDEX, you must give both the table and the index name, in the form tablename.indexname.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(160 ,15 ,0 ,'Rule does not contain a variable.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(161 ,15 ,0 ,'Rule contains more than one variable.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(163 ,15 ,0 ,'The compute by list does not match the order by list.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(164 ,15 ,0 ,'GROUP BY expressions must refer to column names that appear in the select list.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(165 ,16 ,0 ,'Privilege %ls may not be granted or revoked.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(166 ,15 ,0 ,'''%ls'' does not allow specifying the database name as a prefix to the object name.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(167 ,16 ,0 ,'Cannot create a trigger on a temporary object.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(168 ,15 ,0 ,'The %S_MSG ''%.*ls'' is out of the range of computer representation (%d bytes).' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(169 ,15 ,0 ,'A column has been specified more than once in the order by list. Columns in the order by list must be unique.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(170 ,15 ,0 ,'Line %d: Incorrect syntax near ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(171 ,15 ,0 ,'Cannot use SELECT INTO in browse mode.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(172 ,15 ,0 ,'Cannot use HOLDLOCK in browse mode.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(173 ,15 ,0 ,'The definition for column ''%.*ls'' must include a data type.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(174 ,15 ,0 ,'The %ls function requires %d arguments.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(177 ,15 ,0 ,'The IDENTITY function can only be used when the SELECT statement has an INTO clause.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(178 ,15 ,0 ,'A RETURN statement with a return value cannot be used in this context.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(179 ,15 ,0 ,'Cannot use the OUTPUT option when passing a constant to a stored procedure.' ,1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(180 ,15 ,0 ,'There are too many parameters in this %ls statement. The maximum number is %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(181 ,15 ,0 ,'Cannot use the OUTPUT option in a DECLARE statement.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(182 ,15 ,0 ,'Table and column names must be supplied for the READTEXT or WRITETEXT utility.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(183 ,15 ,0 ,'The scale (%d) for column ''%.*ls'' must be within the range %d to %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(185 ,15 ,0 ,'Data stream is invalid for WRITETEXT statement in bulk form.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(186 ,15 ,0 ,'Data stream missing from WRITETEXT statement.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(188 ,15 ,0 ,'Cannot specify a log device in a CREATE DATABASE statement without also specifying at least one non-log device.' ,1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(189 ,15 ,0 ,'The %ls function requires %d to %d arguments.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(191 ,15 ,0 ,'Some part of your SQL statement is nested too deeply. Rewrite the query or break it up into smaller queries.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(192 ,16 ,0 ,'The scale must be less than or equal to the precision.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(193 ,15 ,0 ,'The object or column name starting with ''%.*ls'' is too long. The maximum length is %d characters.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(194 ,15 ,0 ,'A SELECT INTO statement cannot contain a SELECT statement that assigns values to a variable.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(195 ,15 ,0 ,'''%.*ls'' is not a recognized %S_MSG.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(196 ,15 ,0 ,'SELECT INTO must be the first query in an SQL statement containing a UNION operator.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(197 ,15 ,0 ,'EXECUTE cannot be used as a source when inserting into a table variable.', 1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(198 ,15 ,0 ,'Browse mode is invalid for statements containing a UNION operator.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(199 ,15 ,0 ,'An INSERT statement cannot contain a SELECT statement that assigns values to a variable.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(201 ,16 ,0 ,'Procedure ''%.*ls'' expects parameter ''%.*ls'', which was not supplied.' ,1033)

insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(202,16,1,'Invalid type ''%s'' for WAITFOR. Supported data types are CHAR/VARCHAR, NCHAR/NVARCHAR, and DATETIME. WAITFOR DELAY supports the INT and SMALLINT data types.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(203 ,16 ,0 ,'The name ''%.*ls'' is not a valid identifier.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(204 ,20 ,0 ,'Normalization error in node %ls.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(205 ,16 ,0 ,'All queries in an SQL statement containing a UNION operator must have an equal number of expressions in their target lists.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(206 ,16 ,0 ,'Operand type clash: %ls is incompatible with %ls' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(207 ,16 ,0 ,'Invalid column name ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(208 ,16 ,0 ,'Invalid object name ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(209 ,16 ,0 ,'Ambiguous column name ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(210 ,16 ,0 ,'Syntax error converting datetime from binary/varbinary string.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(211, 23, 1, 'Possible schema corruption. Run DBCC CHECKCATALOG.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(212 ,16 ,0 ,'Expression result length exceeds the maximum. %d max, %d found.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(213 ,16 ,0 ,'Insert Error: Column name or number of supplied values does not match table definition.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(214, 16, 0,'Procedure expects parameter ''%ls'' of type ''%ls''.',1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(217, 16, 0, 'Maximum stored procedure, function, trigger, or view nesting level exceeded (limit %d).', 1033 )



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(220 ,16 ,0 ,'Arithmetic overflow error for data type %ls, value = %ld.' ,1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(221 ,10 ,0 ,'FIPS Warning: Implicit conversion from %ls to %ls.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(223 ,11 ,0 ,'Object ID %ld specified as a default for table ID %ld, column ID %d is missing or not of type default.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(224 ,11 ,0 ,'Object ID %ld specified as a rule for table ID %ld, column ID %d is missing or not of type default.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(226 ,16 ,0 ,'%ls statement not allowed within multi-statement transaction.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(229 ,14 ,0 ,'%ls permission denied on object ''%.*ls'', database ''%.*ls'', owner ''%.*ls''.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(230 ,14 ,0 ,'%ls permission denied on column ''%.*ls'' of object ''%.*ls'', database ''%.*ls'', owner ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(231 ,11 ,0 ,'No such default. ID = %ld, database ID = %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(232 ,16 ,0 ,'Arithmetic overflow error for type %ls, value = %f.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(233 ,16 ,0 ,'The column ''%.*ls'' in table ''%.*ls'' cannot be null.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(234 ,16 ,0 ,'There is insufficient result space to convert a money value to %ls.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(235 ,16 ,0 ,'Cannot convert a char value to money. The char value has incorrect syntax.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(236 ,16 ,0 ,'The conversion from char data type to money resulted in a money overflow error.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(237 ,16 ,0 ,'There is insufficient result space to convert a money value to %ls.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(238 ,16 ,0 ,'There is insufficient result space to convert the %ls value (= %d) to the money data type.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(241 ,16 ,0 ,'Syntax error converting datetime from character string.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(242 ,16 ,0 ,'The conversion of a char data type to a datetime data type resulted in an out-of-range datetime value.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(243 ,16 ,0 ,'Type %.*ls is not a defined system type.' ,1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(244 ,16 ,0 ,'The conversion of the %ls value ''%.*ls'' overflowed an %hs column. Use a larger integer column.' ,1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(245 ,16 ,0 ,'Syntax error converting the %ls value ''%.*ls'' to a column of data type %ls.' ,1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(248 ,16 ,0 ,'The conversion of the %ls value ''%.*ls'' overflowed an int column. Maximum integer value exceeded.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(251 ,16 ,0 ,'Could not allocate ancillary table for query optimization. Maximum number of tables in a query (%d) exceeded.' ,1033)
Go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(256 ,16 ,0 ,'The data type %ls is invalid for the %ls function. Allowed types are: char/varchar, nchar/nvarchar, and binary/varbinary.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(257 ,16 ,0 ,'Implicit conversion from data type %ls to %ls is not allowed. Use the CONVERT function to run this query.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(259 ,16 ,0 ,'Ad hoc updates to system catalogs are not enabled. The system administrator must reconfigure SQL Server to allow this.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(260 ,16 ,0 ,'Disallowed implicit conversion from data type %ls to data type %ls, table ''%.*ls'', column ''%.*ls''. Use the CONVERT function to run this query.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(261 ,16 ,0 ,'''%.*ls'' is not a recognized function.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(262 ,16 ,0 ,'%ls permission denied in database ''%.*ls''.' ,1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(263 ,16 ,0 ,'Must specify table to select from.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(264 ,16 ,0 ,'Column name ''%.*ls'' appears more than once in the result column list.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(266 ,16 ,0 ,'Transaction count after EXECUTE indicates that a COMMIT or ROLLBACK TRANSACTION statement is missing. Previous count = %ld, current count = %ld.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(267 ,16 ,0 ,'Object ''%.*ls'' cannot be found.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(268 ,16 ,0 ,'Cannot run SELECT INTO in this database. The database owner must run sp_dboption to enable this option.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(270 ,16 ,0 ,'Object ''%.*ls'' cannot be modified.' ,1033)

insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(271 ,16 ,0 ,'Column ''%.*ls'' cannot be modified because it is a computed column.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(272 ,16 ,0 ,'Cannot update a timestamp column.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(273 ,16 ,0 ,'Cannot insert a non-null value into a timestamp column. Use INSERT with a column list or with a default of NULL for the timestamp column.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(278 ,16 ,0 ,'The text, ntext, and image data types cannot be used in a GROUP BY clause.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(279 ,16 ,0 ,'The text, ntext, and image data types are invalid in this subquery or aggregate expression.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(280 ,16 ,0 ,'Only text, ntext, and image columns are valid with the TEXTPTR function.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(281 ,16 ,0 ,'%d is not a valid style number when converting from %ls to a character string.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(282 ,10 ,0 ,'The ''%.*ls'' procedure attempted to return a status of NULL, which is not allowed. A status of 0 will be returned instead.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(283, 16, 0, 'READTEXT cannot be used on inserted or deleted tables within an INSTEAD OF trigger.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(284 ,16 ,0 ,'Rules cannot be bound to text, ntext, or image data types.' ,1033)

Go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(285 ,16 ,0 ,'The READTEXT, WRITETEXT, and UPDATETEXT statements cannot be used with views or functions.' ,1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(286 ,16 ,0 ,'The logical tables INSERTED and DELETED cannot be updated.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(287 ,16 ,0 ,'The %ls statement is not allowed within a trigger.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(288 ,16 ,0 ,'The PATINDEX function operates on char, nchar, varchar, nvarchar, text, and ntext data types only.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(291, 16, 0, 'CAST or CONVERT: invalid attributes specified for type ''%.*ls''', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(292 ,16 ,0 ,'There is insufficient result space to convert a smallmoney value to %ls.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(293 ,16 ,0 ,'Cannot convert char value to smallmoney. The char value has incorrect syntax.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(294 ,16 ,0 ,'The conversion from char data type to smallmoney data type resulted in a smallmoney overflow error.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(295 ,16 ,0 ,'Syntax error converting character string to smalldatetime data type.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(296 ,16 ,0 ,'The conversion of char data type to smalldatetime data type resulted in an out-of-range smalldatetime value.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(298 ,16 ,0 ,'The conversion from datetime data type to smalldatetime data type resulted in a smalldatetime overflow error.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(299 ,16 ,0 ,'The DATEADD function was called with bad type %ls.' ,1033)

GO

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(301 ,16 ,0 ,'Query contains an outer-join request that is not permitted.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(303 ,16 ,0 ,'The table ''%.*ls'' is an inner member of an outer-join clause. This is not allowed if the table also participates in a regular join clause.' ,1033)

--Raid 231813 fix
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(306 ,16 ,0 ,'The text, ntext, and image data types cannot be compared or sorted, except when using IS NULL or LIKE operator.' ,1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(307 ,16 ,0 ,'Index ID %d on table ''%.*ls'' (specified in the FROM clause) does not exist.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(308 ,16 ,0 ,'Index ''%.*ls'' on table ''%.*ls'' (specified in the FROM clause) does not exist.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(311  ,16 ,0 ,'Cannot use text, ntext, or image columns in the ''inserted'' and ''deleted'' tables.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(312, 16, 0, 'Cannot reference text, ntext, or image columns in a filter stored procedure.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(313, 16, 0, 'An insufficient number of arguments were supplied for the procedure or function %.*ls.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(314, 16, 0, 'Cannot use GROUP BY ALL with the special tables INSERTED or DELETED.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(401 ,16 ,0 ,'Unimplemented statement or expression %ls.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(403 ,16 ,0 ,'Invalid operator for data type. Operator equals %ls, type equals %ls.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(409 ,16 ,0 ,'The %ls operation cannot take a %ls data type as an argument.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(410 ,20 ,0 ,'COMPUTE clause #%d ''BY'' expression #%d is not in the order by list.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(411 ,20 ,0 ,'COMPUTE clause #%d, aggregate expression #%d is not in the select list.' ,1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(420 ,16 ,0 ,'The text, ntext, and image data types cannot be used in an ORDER BY clause.' ,1033)


Go


---- These are new messages for CONSTRAINT COMPILE, Messages 424 - 440 (excluding 425, 426)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(425 ,16 ,0 ,'Data type %ls of receiving variable is not equal to the data type %ls of column ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(426 ,16 ,0 ,'The length %d of the receiving variable is less than the length %d of the column ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(427 ,20 ,0 ,'Could not load sysprocedures entries for constraint ID %d in database ID %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(428 ,20 ,0 ,'Could not find row in sysconstraints for constraint ID %d in database ID %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(429 ,20 ,0 ,'Could not find new constraint ID %d in sysconstraints, database ID %d, at compile time.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(430 ,20 ,0 ,'Could not resolve table name for object ID %d, database ID %d, when compiling foreign key.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(431 ,19 ,0 ,'Could not bind foreign key constraint. Too many tables involved in the query.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(433 ,20 ,0 ,'Could not find CHECK constraint for ''%.*ls'', although the table is flagged as having one.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(436 ,20 ,0 ,'Could not open referenced table ID %d in database ID %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(437 ,20 ,0 ,'Could not resolve the referenced column name in table ID %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(438 ,20 ,0 ,'Could not resolve the referencing column name in table ID %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(439 ,20 ,0 ,'Could not find FOREIGN KEY constraints for table ''%.*ls'' in database ID %d although the table is flagged as having them.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(441 ,16 ,0 ,'Cannot use the ''%ls'' function on a remote data source.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(443, 16, 0, 'Invalid use of ''%s'' within a function.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(444, 16, 0, 'Select statements included within a function cannot return data to a client.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(445, 16, 0, 'COLLATE clause cannot be used on expressions containing a COLLATE clause.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(446, 16, 0, 'Cannot resolve collation conflict for %ls operation.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(447, 16, 0, 'Expression type %ls is invalid for COLLATE clause. ', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(448, 16, 0, 'Invalid collation ''%.*ls''.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(449, 16, 0, 'Collation conflict caused by collate clauses with different collation ''%.*ls'' and ''%.*ls''.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(450, 16, 0, 'Code page translations are not supported for the text data type. From: %d To: %d.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(451, 16, 0, 'Cannot resolve collation conflict for column %d in %ls statement.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(452, 16, 0, 'COLLATE clause cannot be used on user-defined data types.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(453, 16, 0, 'Collation ''%.*ls'' is supported on Unicode data types only and cannot be set at the database or server level.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(455, 16, 0, 'The last statement included within a function must be a return statement.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(456, 16, 0, 'Implicit conversion of %ls value to %ls cannot be performed because the resulting collation is unresolved due to collation conflict.', 1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(457, 16, 0, 'Implicit conversion of %ls value to %ls cannot be performed because the collation of the value is unresolved due to a collation conflict.', 1033)
go
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (502, 16, 128, 'The SQL Debugging Interface (SDI) requires that SQL Server, when started as a service, must not log on as System Account. Reset to log on as user account using Control Panel.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (503, 16, 128, 'Unable to send symbol information to debugger on %ls for connection %d. Debugging disabled.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (504, 16, 128, 'Unable to connect to debugger on %ls (Error = 0x%08x). Ensure that client-side components, such as SQLDBREG.EXE, are installed and registered on %.*ls. Debugging disabled for connection %d.', 1033)
go
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(505 ,16 ,0 ,'Current user account was invoked with SETUSER. Changing databases is not allowed.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(506 ,16 ,0 ,'Invalid escape character ''%.*ls'' was specified in a LIKE predicate.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(507 ,16 ,0 ,'Invalid argument for SET ROWCOUNT. Must be a non-null non-negative integer.' ,1033)
go
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (508, 16, 128, 'Unable to connect to debugger on %ls (Error = 0x%08x). Ensure that client-side components, such as SQLLE.DLL, are installed and registered on %.*ls. Debugging disabled for connection %d.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(509 ,11 ,0 ,'User name ''%.*ls'' not found.' ,1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(510, 16, 0, 'Cannot create a worktable row larger than allowable maximum. Resubmit your query with the ROBUST PLAN hint.', 1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(511,16,0,'Cannot create a row of size %d which is greater than the allowable maximum of %d.',
	1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(512 ,16 ,0 ,'Subquery returned more than 1 value. This is not permitted when the subquery follows =, !=, <, <= , >, >= or when the subquery is used as an expression.' ,1033)

Go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(513 ,16 ,0 ,'A column insert or update conflicts with a rule imposed by a previous CREATE RULE statement. The statement was terminated. The conflict occurred in database ''%.*ls'', table ''%.*ls'', column ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (514, 16, 128, 'Unable to communicate with debugger on %ls (Error = 0x%08x). Debugging disabled for connection %d.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(515 ,16 ,0 ,'Cannot insert the value NULL into column ''%.*ls'', table ''%.*ls''; column does not allow nulls. %ls fails.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (516, 16, 128, 'Attempt to initialize OLE library failed. Check for correct versions of OLE DLLs on this machine.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(517 ,16 ,0 ,'Adding a value to a ''%ls'' column caused overflow.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(518 ,16 ,0 ,'Cannot convert data type %ls to %ls.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (520, 16, 0, 'SQL Server no longer supports version %d of the SQL Debugging Interface (SDI).', 1033)
go
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(528 ,20 ,0 ,'System error detected during attempt to use the ''upsleep'' system function.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(529 ,16 ,0 ,'Explicit conversion from data type %ls to %ls is not allowed.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(532 ,16 ,0 ,'The timestamp (changed to %S_TS) shows that the row has been updated by another user.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(535 ,16 ,0 ,'Difference of two datetime columns caused overflow at runtime.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(536 ,16 ,0 ,'Invalid length parameter passed to the substring function.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(538 ,16 ,0 ,'Cannot find ''%.*ls''. This language may have been dropped. Contact your system administrator.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(542 ,16 ,0 ,'An invalid datetime value was encountered. Value exceeds the year 9999.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(544 ,16 ,0 ,'Cannot insert explicit value for identity column in table ''%.*ls'' when IDENTITY_INSERT is set to OFF.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(545 ,16 ,0 ,'Explicit value must be specified for identity column in table ''%.*ls'' when IDENTITY_INSERT is set to ON.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(547 ,16 ,0 ,'%ls statement conflicted with %ls %ls constraint ''%.*ls''. The conflict occurred in database ''%.*ls'', table ''%.*ls''%ls%.*ls%ls.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (548 ,16 ,0 ,'The identity range managed by replication is full and must be updated by a replication agent. The %ls conflict occurred in database ''%.*ls'', table ''%.*ls''%ls%.*ls%ls. Sp_adjustpublisheridentityrange can be called to get a new identity range.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(550 ,16 ,0 ,'The attempted insert or update failed because the target view either specifies WITH CHECK OPTION or spans a view that specifies WITH CHECK OPTION and one or more rows resulting from the operation did not qualify under the CHECK OPTION constraint.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(551 ,16 ,0 ,'The checksum has changed to %d. This shows that the row has been updated by another user.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (552, 16, 0, 'CryptoAPI function ''%ls'' failed. Error 0x%x: %ls', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(555 ,16 ,0 ,'User-defined functions are not yet enabled.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(556 ,16 ,0 ,'INSERT EXEC failed because the stored procedure altered the schema of the target table.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(557, 16, 0, 'Only functions and extended stored procedures can be executed from within a function.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(558, 16, 0, 'Remote function calls are not allowed within a function.',1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (561 ,16 ,0 ,'Failed to access file ''%.*ls''' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (562 ,16 ,0 ,'Failed to access file ''%.*ls''. Files can be accessed only through shares' ,1033)
go


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(563 , 14 ,0 ,'The transaction for the INSERT EXEC statement has been rolled back. The INSERT EXEC operation will be terminated.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (564, 16, 1, 'Attempted to create a record with a fixed length of ''%d''. Maximum allowable fixed length is ''%d''.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(565 ,18 ,0 ,'The server encountered a stack overflow during compile time.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (566, 21, 0, 'Error writing audit trace.  SQL Server is shutting down.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(567, 16, 1, 'File ''%.*ls'' either does not exist or is not a recognizable trace file. Or there was an error opening the file.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(568, 16, 1, 'Server encountered an error ''%.*ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(569, 16, 0, 'The handle passed to fn_get_sql was invalid.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(570, 16, 0, 'INSTEAD OF triggers do not support direct recursion. Trigger execution failed.', 1033)

GO
raiserror('sysmessages.error>=600 ....',0,1) with nowait
GO
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(601,12,0,'Could not continue scan with NOLOCK due to data movement.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(602 ,21 ,0 ,'Could not find row in sysindexes for database ID %d, object ID %ld, index ID %d. Run DBCC CHECKTABLE on sysindexes.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(604 ,21 ,0 ,'Could not find row in sysobjects for object ID %ld in database ''%.*ls''. Run DBCC CHECKTABLE on sysobjects.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(605 ,21 ,0 ,'Attempt to fetch logical page %S_PGID in database ''%.*ls'' belongs to object ''%.*ls'', not to object ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(607 ,21 ,0 ,'Insufficient room was allocated for search arguments in the session descriptor for object ''%.*ls''. Only %d search arguments were anticipated.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(615 ,21 ,0 ,'Could not find database table ID %d, name ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(617 ,20 ,0 ,'Descriptor for object ID %ld in database ID %d not found in the hash table during attempt to unhash it.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(618 ,21 ,0 ,'A varno of %d was passed to the opentable system function. The largest valid value is %d.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(622,16,0,'Filegroup ''%.*ls'' has no files assigned to it. Tables, indexes, and text, ntext, and image columns cannot be populated on this filegroup until a file is added.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(623 ,21 ,0 ,'Could not retrieve row from page by RID because logical page %S_PGID is not a data page. %S_RID. %S_PAGE.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(624 ,21 ,0 ,'Could not retrieve row from page by RID because the requested RID has a higher number than the last RID on the page. %S_RID.%S_PAGE, DBID %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(625 ,21 ,0 ,'Cannot retrieve row from page %S_PGID by RID because the slotid (%d) is not valid.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(626,16,0,'Cannot use ROLLBACK with a savepoint within a distributed transaction.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(627,16,0,'Cannot use SAVE TRANSACTION within a distributed transaction.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(628 ,13 ,0 ,'Cannot issue SAVE TRANSACTION when there is no active transaction.' ,1033)
GO
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(635 ,20 ,0 ,'Process %d tried to remove DES resource lock %S_DES, which it does not hold.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(637 ,20 ,0 ,'Index shrink program returned invalid status of 0.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(639 ,21 ,0 ,'Could not fetch logical page %S_PGID, database ID %d. The page is not currently allocated.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(644 ,21 ,0 ,'Could not find the index entry for RID ''%.*hs'' in index page %S_PGID, index ID %d, database ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(649 ,21 ,0 ,'Could not find the clustered index entry for page %S_PGID, object ID %ld, status 0x%x. Index page %S_PGID, in database ''%.*ls'', was searched for this entry.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(650, 16, 0, 'You can only specify the READPAST lock in the READ COMMITTED or REPEATABLE READ isolation levels.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(651, 16, 0, 'Cannot use %hs granularity hint on table ''%.*ls'' because locking at the specified granularity is inhibited.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(652, 16, 0, 'Index ID %d for table ''%.*ls'' resides on a read-only filegroup which cannot be modified.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(653, 20, 0, 'Two buffers are conflicting for the same keep slot in table ''%.*ls''.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(654, 20, 0, 'No slots are free to keep buffers for table ''%.*ls''.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(655, 20, 0, 'Expected to find buffer in keep slot for table ''%.*ls''.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(666, 16,0, 'Maximum system-generated unique value for a duplicate group exceeded for table ID %d, index ID %d. Dropping and re-creating the index may fix the problem; otherwise use another clustering key.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(667,16,0,'Index %d for table ''%.*ls'' resides on offline filegroup that cannot be accessed.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(701 ,19 ,0 ,'There is insufficient system memory to run this query.' ,1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(708,10,1,'Warning: Due to low virtual memory, special reserved memory used %d times since startup. Increase virtual memory on server.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(802, 17,0 ,'No more buffers can be stolen.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(804 ,20 ,0 ,'Could not find buffer 0x%lx holding logical page %S_PGID in the SDES 0x%lx kept buffer pool for object ''%.*ls''.' ,1033)

Go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(809 ,20 ,0 ,'Buffer 0x%lx, allocation page %S_PGID, in database ''%.*ls'' is not in allocation buffer pool in PSS (process status structure). Contact Technical Support.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(813 ,20 ,0 ,'Logical page %S_PGID in database ID %d is already hashed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(816 ,20 ,0 ,'Process ID %d tried to remove a buffer resource lock %S_BUF that it does not hold in SDES %S_SDES. Contact Technical Support.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(818 ,19 ,0 ,'There is no room to hold the buffer resource lock %S_BUF in SDES %S_SDES. Contact Technical Support.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(821 ,20 ,0 ,'Could not unhash buffer at 0x%lx with a buffer page number of %S_PGID and database ID %d with HASHED status set. The buffer was not found. %S_PAGE.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(822 ,21 ,0 ,'Could not start I/O for request %S_BLKIOPTR.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(823 ,24 ,0 ,'I/O error %ls detected during %S_MSG at offset %#016I64x in file ''%ls''.' ,1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(834 ,21 ,0 ,'The bufclean system function was called on dirty buffer (page %S_PGID, stat %#x/%#x, objid %#x, sstat%#x).' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(840 ,17 ,0 ,'Device ''%.*ls'' (physical name ''%.*ls'', virtual device number %d) is not available. Contact the system administrator for assistance.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (844 ,10 ,1 ,'Time out occurred while waiting for buffer latch type %d, bp %#x, page %S_PGID, stat %#x, object ID %d:%d:%d, waittime %d. Continuing to wait.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (845 ,17 ,1 ,'Time-out occurred while waiting for buffer latch type %d for page %S_PGID, database ID %d.' ,1033)

GO
backup Transaction master with no_log
GO

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(901 ,21 ,0 ,'Could not find descriptor for database ID %d, object ID %ld in hash table after hashing it.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(902 ,16 ,0 ,'To change the %ls, the database must be in state in which a checkpoint can be executed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(903 ,22 ,0 ,'Could not find row in sysindexes for clustered index on system catalog %ld in database ID %d. This index should exist in all databases. Run DBCC CHECKTABLE on sysindexes in the database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(906 ,22 ,0 ,'Could not locate row in sysobjects for system catalog ''%.*ls'' in database ''%.*ls''. This system catalog should exist in all databases. Run DBCC CHECKTABLE on sysobjects in this database.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(911 ,16 ,0 ,'Could not locate entry in sysdatabases for database ''%.*ls''. No entry found with that name. Make sure that the name is entered correctly.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(913 ,22 ,0 ,'Could not find database ID %d. Database may not be activated yet or may be in transition.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(916 ,14 ,0 ,'Server user ''%.*ls'' is not a valid user in database ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(921 ,14 ,0 ,'Database ''%.*ls'' has not been recovered yet. Wait and try again.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(922 ,14 ,0 ,'Database ''%.*ls'' is being recovered. Waiting until recovery is finished.' ,1033)

Go

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(923, 14, 0, 'Database ''%.*ls'' is in restricted mode. Only the database owner and members of the dbcreator and sysadmin roles can access it.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(924 ,14 ,0 ,'Database ''%.*ls'' is already open and can only have one user at a time.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(925 ,19 ,0 ,'Maximum number of databases used for each query has been exceeded. The maximum allowed is %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(926 ,14 ,0 ,'Database ''%.*ls'' cannot be opened. It has been marked SUSPECT by recovery. See the SQL Server errorlog for more information.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(927 ,14 ,0 ,'Database ''%.*ls'' cannot be opened. It is in the middle of a restore.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(929 ,20 ,0 ,'Attempting to close a database that is not already open. Contact Technical Support.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(941 ,14 ,0 ,'Cannot open database ''%.*ls''. It has not been upgraded to the latest format.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(942 ,14 ,0 ,'Database ''%.*ls'' cannot be opened because it is offline.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(943 ,14 ,0 ,'Database ''%.*ls'' cannot be opened because its version (%d) is later than the current server version (%d).' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(944 ,10 ,0 ,'Converting database ''%.*ls'' from version %d to the current version %d.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(945 ,16 ,0 ,'Database ''%.*ls'' cannot be opened due to inaccessible files or insufficient memory or disk space.  See the SQL Server errorlog for details.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(946 ,14 ,0 ,'Cannot open database ''%.*ls'' version %d. Upgrade the database to the latest version.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (947, 16, 128, 'Error while closing database ''%.*ls'' cleanly.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(948,14,0,'Database ''%.*ls'' cannot be upgraded. Database is version %d and this server supports version %d.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(949,16,1,'tempdb is skipped. You cannot run a query that requires tempdb' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(950, 14, 1, 'Database ''%.*ls'' cannot be upgraded  - database has a version (%d) earlier  than SQL Server 7.0(%d).', 1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (951, 10, 1, 'Database ''%.*ls'' running the upgrade step from version %d to version %d.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(952, 16, 1, 'Database ''%.*ls'' is in transition. Try the statement later.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (953, 16, 0, 'Warning: Index ''%ls'' on ''%ls'' in database ''%ls'' may be corrupt because of expression evaluation changes in this release. Drop and re-create the index.', 1033)

GO
raiserror('sysmessages.error>=1000 ....',0,1) with nowait
GO

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1001 ,16 ,0 ,'Line %d: Length or precision specification %d is invalid.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1002 ,16 ,0 ,'Line %d: Specified scale %d is invalid.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1003 ,15 ,0 ,'Line %d: %ls clause allowed only for %ls.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1004 ,16 ,0 ,'Invalid column prefix ''%.*ls'': No table name specified' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1005 ,15 ,0 ,'Line %d: Invalid procedure number (%d). Must be between 1 and 32767.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1006 ,15 ,0 ,'CREATE TRIGGER contains no statements.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1007 ,15 ,0 ,'The %S_MSG ''%.*ls'' is out of the range for numeric representation (maximum precision 38).' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1008 ,15 ,0 ,'The SELECT item identified by the ORDER BY number %d contains a variable as part of the expression identifying a column position. Variables are only allowed when ordering by an expression referencing a column name.' ,1033)

insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(1010,15,0,'Invalid escape character ''%.*ls''.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1011 ,15 ,0 ,'The correlation name ''%.*ls'' is specified multiple times in a FROM clause.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1012 ,15 ,0 ,'The correlation name ''%.*ls'' has the same exposed name as table ''%.*ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1013 ,15 ,0 ,'Tables or functions ''%.*ls'' and ''%.*ls'' have the same exposed names. Use correlation names to distinguish them.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(1014, 15, 0, 'TOP clause contains an invalid value.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1015 ,15 ,0 ,'An aggregate cannot appear in an ON clause unless it is in a subquery contained in a HAVING clause or select list, and the column being aggregated is an outer reference.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1016 ,15 ,0 ,'Outer join operators cannot be specified in a query containing joined tables.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1019 ,15 ,0 ,'Invalid column list after object name in GRANT/REVOKE statement.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1020 ,15 ,0 ,'Column list cannot be specified for object-level permissions.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1021 ,10 ,0 ,'FIPS Warning: Line %d has the non-ANSI statement ''%ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1022 ,10 ,0 ,'FIPS Warning: Line %d has the non-ANSI clause ''%ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1023 ,15 ,0 ,'Invalid parameter %d specified for %ls.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1024 ,10 ,0 ,'FIPS Warning: Line %d has the non-ANSI function ''%ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1025 ,10 ,0 ,'FIPS Warning: The length of identifier ''%.*ls'' exceeds 18.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1027 ,15 ,0 ,'Too many expressions are specified in the GROUP BY clause. The maximum number is %d when either CUBE or ROLLUP is specified.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1028 ,15 ,0 ,'The CUBE and ROLLUP options are not allowed in a GROUP BY ALL clause.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1029 ,15 ,0 ,'Browse mode is invalid for subqueries and derived tables.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(1031, 15, 0, 'Percent values must be between 0 and 100.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(1032, 16, 0, 'Cannot use the column prefix ''%.*ls''. This must match the object in the UPDATE clause ''%.*ls''.', 1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(1033, 16, 0, 'The ORDER BY clause is invalid in views, inline functions, derived tables, and subqueries, unless TOP is also specified.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1035, 15, 0, 'Incorrect syntax near ''%.*ls'', expected ''%.*ls''.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1036, 15, 0, 'File option %hs is required in this CREATE/ALTER DATABASE statement.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1037, 15, 0, 'The CASCADE, WITH GRANT or AS options cannot be specified with statement permissions.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1038,15 ,0 ,'Cannot use empty object or column names. Use a single space if necessary.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1039, 16, 1, 'Option ''%.*ls'' is specified more than once.' ,1033)
go

insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(1040,15,0,'Mixing old and new syntax in CREATE/ALTER DATABASE statement is not allowed.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(1041,15,0,'Option %.*ls is not allowed for a LOG file.',1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(1042,15,0,'Conflicting %ls optimizer hints specified.',1033)

insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(1043,15,2,'''%hs'' is not yet implemented.',1033)

insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(1044,15,0,'Cannot use an existing function name to specify a stored procedure name.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(1045,15,0,'Aggregates are not allowed in this context. Only scalar expressions are allowed.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(1046,15,0,'Subqueries are not allowed in this context. Only scalar expressions are allowed.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(1047,15,0,'Conflicting locking hints specified.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(1048,15,0,'Conflicting cursor options %ls and %ls.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(1049,15,0,'Mixing old and new syntax to specify cursor options is not allowed.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1050 ,15 ,0 ,'This syntax is only allowed within the stored procedure sp_executesql.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1051 ,15 ,0 ,'Cursor parameters in a stored procedure must be declared with OUTPUT and VARYING options, and they must be specified in the order CURSOR VARYING OUTPUT.' ,1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
        values
        (1052,15,0,'Conflicting %ls options %ls and %ls.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
        values
        (1053,15,0,'For DROP STATISTICS, you must give both the table and the column name in the form ''tablename.column''.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1054 ,15 ,0 ,'Syntax ''%ls'' is not allowed in schema-bound objects.' ,1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1055,15 ,0 ,'''%.*ls'' is an invalid name because it contains a NULL character.' ,1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(1056,15,0,'The maximum number of elements in the select list is %d and you have supplied %d.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(1057 ,15 ,0 ,'The IDENTITY function cannot be used with a SELECT INTO statement containing a UNION operator.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1058 ,15 ,0 ,'Cannot specify both READ_ONLY and FOR READ ONLY on a cursor declaration.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1059 ,15 ,0 ,'Cannot set or reset the %ls option within a procedure.' ,1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(1060,15 ,0 ,'The number of rows in the TOP clause must be an integer.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1061 ,16 ,0 ,'The text/ntext/image constants are not yet implemented.' ,1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(1062 ,16 ,0 ,'The TOP N WITH TIES clause is not allowed without a corresponding ORDER BY clause.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1063 ,16 ,0 ,'A filegroup cannot be added using ALTER DATABASE ADD FILE. Use ALTER DATABASE ADD FILEGROUP.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1064 ,16 ,0 ,'A filegroup cannot be used with log files.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1065 ,15 ,0 ,'The NOLOCK, READUNCOMMITTED, and READPAST lock hints are only allowed in a SELECT statement.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1066 ,10 ,0 ,'Warning. Line %d: The option ''%ls'' is obsolete and has no effect.' ,1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(1067,15,2,'The SET SHOWPLAN statements must be the only statements in the batch.',1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(1068 ,16 ,0 ,'Only one list of index hints per table is allowed.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(1069 ,16 ,0 ,'Index hints are only allowed in a FROM clause.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(1070, 15, 0, 'CREATE INDEX option ''%.*ls'' is no longer supported.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1071 ,16 ,0 ,'Cannot specify a JOIN algorithm with a remote JOIN.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1072 ,16 ,0 ,'A REMOTE hint can only be specified with an INNER JOIN clause.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (1073 ,15 ,0 ,'''%.*ls'' is not a recognized cursor option for cursor %.*ls.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1074, 15, 0, 'Creation of temporary functions is not allowed.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1075, 15, 0, 'RETURN statements in scalar valued functions must include an argument.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1076 ,15 ,1 ,'Function ''%s'' requires at least %d argument(s).' ,1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
   	(1077, 15, 1, 'INSERT into an identity column not allowed on table variables.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(1078, 15, 0, '''%.*ls %.*ls'' is not a recognized option.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1079 ,15 ,0 ,'A variable cannot be used to specify a search condition in a fulltext predicate when accessed through a cursor.' ,1033)


GO

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1101 ,17 ,128 ,'Could not allocate new page for database ''%.*ls''. There are no more pages available in filegroup %.*ls. Space can be created by dropping objects, adding additional files, or allowing file growth.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1102 ,22 ,0 ,'IAM page %S_PGID for object ID %ld is incorrect. The %S_MSG ID on page is %ld; should be %ld. The entry in sysindexes may be incorrect or the IAM page may contain an error.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1103 ,21 ,0 ,'Allocation page %S_PGID in database ''%.*ls'' has different segment ID than that of the object which is being allocated to. Run DBCC CHECKALLOC.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1105 ,17 ,128 ,'Could not allocate space for object ''%.*ls'' in database ''%.*ls'' because the ''%.*ls'' filegroup is full.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1109 ,21 ,0 ,'Could not read allocation page %S_PGID because either the object ID (%ld) is not correct, or the page ID (%S_PGID) is not correct.' ,1033)


GO

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1201 ,20 ,0 ,'The page_lock system function was called with a mode %d that is not permitted.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(1203,20,0,'Process ID %d attempting to unlock unowned resource %.*ls.', 1033)
--1204 revised per Raid 222067
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1204 ,19 ,0 ,'The SQL Server cannot obtain a LOCK resource at this time. Rerun your statement when there are fewer active users or ask the system administrator to check the SQL Server lock and memory configuration.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1205, 13, 0, 'Transaction (Process ID %d) was deadlocked on %.*ls resources with another process and has been chosen as the deadlock victim. Rerun the transaction.', 1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1206,18 ,0 ,'Transaction manager has canceled the distributed transaction.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1211 ,13 ,0 ,'Process ID %d was chosen as the deadlock victim with P_BACKOUT bit set.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(1220,17,0,'No more lock classes available from transaction.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(1221,20,0,'Invalid lock class for release call.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(1222,13,0,'Lock request time out period exceeded.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1223, 16, 0, 'Attempting to release application lock ''%.*ls'' that is not currently held.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(1229,10,0, 'Process ID %d:%d owns resources that are blocking processes on Scheduler %d.', 1033)

GO

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1501 ,20 ,0 ,'Sort failure.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1505 ,14 ,0 ,'CREATE UNIQUE INDEX terminated because a duplicate key was found for index ID %d. Most significant primary key is ''%S_KEY''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1507 ,10 ,0 ,'Warning: Deleted duplicate row. Primary key is ''%S_KEY''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1508 ,14 ,0 ,'CREATE INDEX terminated because a duplicate row was found. Primary key is ''%S_KEY''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1509 ,20 ,0 ,'Row compare failure.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1510 ,17 ,0 ,'Sort failed. Out of space or locks in database ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1511 ,20 ,0 ,'Sort cannot be reconciled with transaction log.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1522 ,20 ,0 ,'Sort failure. Prevented overwriting of allocation page in database ''%.*ls'' by terminating sort.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1523 ,20 ,0 ,'Sort failure. Prevented incorrect extent deallocation by aborting sort.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1528 ,21 ,0 ,'Character data comparison failure. An unrecognized Sort-Map-Element type (%d) was found in the server-wide default sort table at SMEL entry [%d].' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1529 ,21 ,0 ,'Character data comparison failure. A list of Sort-Map-Elements from the server-wide default sort table does not end properly. This list begins at SMEL entry [%d].' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1530 ,16 ,0 ,'CREATE INDEX with DROP_EXISTING was aborted because a row was out of order. Most significant offending primary key is ''%S_KEY''. Explicitly drop and create the index instead.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1531 ,16 ,0 ,'The SORTED_DATA_REORG option cannot be used for a nonclustered index if the keys are not unique within the table. CREATE INDEX was aborted because of duplicate keys. Primary key is ''%S_KEY''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1532 ,20 ,0 ,'New sort run starting on page %S_PGID found extent not marked as shared.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1533 ,20 ,0 ,'Cannot share extent %S_PGID among more than eight sort runs.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1534 ,20 ,0 ,'Extent %S_PGID not found in shared extent directory.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1535 ,20 ,0 ,'Cannot share extent %S_PGID with shared extent directory full.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1536 ,20 ,0 ,'Cannot build a nonclustered index on a memory-only work table.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1537 ,20 ,0 ,'Cannot suspend a sort not in row input phase.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1538 ,20 ,0 ,'Cannot insert into a sort not in row input phase.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (1540 ,16 ,0 ,'Cannot sort a row of size %d, which is greater than the allowable maximum of %d.' ,1033)

Go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1619 ,21 ,0 ,'Could not open tempdb. Cannot continue.' ,1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1701 ,16 ,0 ,'Creation of table ''%.*ls'' failed because the row size would be %d, including internal overhead. This exceeds the maximum allowable table row size, %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1702 ,16 ,0 ,'CREATE TABLE failed because column ''%.*ls'' in table ''%.*ls'' exceeds the maximum of %d columns.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1703 ,17 ,0 ,'Could not allocate disk space for a work table in database ''%.*ls''. You may be able to free up space by using BACKUP LOG, or you may want to extend the size of the database by using ALTER DATABASE.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1704 ,16 ,0 ,'Only members of the sysadmin role can create the system table ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1705 ,16 ,0 ,'You must create system table ''%.*ls'' in the master database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1706 ,16 ,0 ,'System table ''%.*ls'' was not created, because ad hoc updates to system catalogs are not enabled.' ,1033)

--updated 1708 6/5
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1708 ,10 ,0 ,'Warning: The table ''%.*ls'' has been created but its maximum row size (%d) exceeds the maximum number of bytes per row (%d). INSERT or UPDATE of a row in this table will fail if the resulting row length exceeds %d bytes.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1709 ,16 ,0 ,'Cannot use TEXTIMAGE_ON when a table has no text, ntext, or image columns.' ,1033)



Go

---- These are new messages for ADD CONSTRAINT,  Messages 1750 - 1784


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1750 ,10 ,0 ,'Could not create constraint. See previous errors.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1752 ,16 ,0 ,'Could not create DEFAULT for column ''%.*ls'' as it is not a valid column in the table ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1753 ,16 ,0 ,'Column ''%.*ls.%.*ls'' is not the same length as referencing column ''%.*ls.%.*ls'' in foreign key ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1754 ,16 ,0 ,'Defaults cannot be created on columns with an IDENTITY attribute. Table ''%.*ls'', column ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1755 ,16 ,0 ,'Defaults cannot be created on columns of data type timestamp. Table ''%.*ls'', column ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1756 ,10 ,0 ,'Skipping FOREIGN KEY constraint ''%.*ls'' definition for temporary table.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1757, 16, 0, 'Column ''%.*ls.%.*ls'' is not of same collation as referencing column ''%.*ls.%.*ls'' in foreign key ''%.*ls''.', 1033)

go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1759 ,16 ,0 ,'Invalid column ''%.*ls'' is specified in a constraint or computed-column definition.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1760 ,16 ,0 ,'Constraints of type %ls cannot be created on columns of type %ls.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1763 ,16 ,0 ,'Cross-database foreign key references are not supported. Foreign key ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1766 ,16 ,0 ,'Foreign key references to temporary tables are not supported. Foreign key ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1767 ,16 ,0 ,'Foreign key ''%.*ls'' references invalid table ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1768 ,16 ,0 ,'Foreign key ''%.*ls'' references object ''%.*ls'' which is not a user table.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1769 ,16 ,0 ,'Foreign key ''%.*ls'' references invalid column ''%.*ls'' in referencing table ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1770 ,16 ,0 ,'Foreign key ''%.*ls'' references invalid column ''%.*ls'' in referenced table ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1772 ,16 ,0 ,'Foreign key ''%.*ls'' defines an invalid relationship between a user table and system table.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1773 ,16 ,0 ,'Foreign key ''%.*ls'' has implicit reference to object ''%.*ls'' which does not have a primary key defined on it.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1774 ,16 ,0 ,'The number of columns in the referencing column list for foreign key ''%.*ls'' does not match those of the primary key in the referenced table ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1776 ,16 ,0 ,'There are no primary or candidate keys in the referenced table ''%.*ls'' that match the referencing column list in the foreign key ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1777 ,14 ,0 ,'User does not have correct permissions on referenced table ''%.*ls'' to create foreign key ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1778 ,16 ,0 ,'Column ''%.*ls.%.*ls'' is not the same data type as referencing column ''%.*ls.%.*ls'' in foreign key ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1779 ,16 ,0 ,'Table ''%.*ls'' already has a primary key defined on it.' ,1033)

Go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1780 ,20 ,0 ,'Could not find column ID %d in syscolumns for object ID %d in database ID %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1781 ,16 ,0 ,'Column already has a DEFAULT bound to it.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1784, 16, 1, 'Cannot create the foreign key ''%.*ls'' because the referenced column ''%.*ls.%.*ls'' is a computed column.' ,1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (1785, 16, 0, 'Introducing FOREIGN KEY constraint ''%.*ls'' on table ''%.*ls'' may cause cycles or multiple cascade paths. Specify ON DELETE NO ACTION or ON UPDATE NO ACTION, or modify other FOREIGN KEY constraints.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (1786, 16, 0,'Either column ''%.*ls.%.*ls'' or referencing column ''%.*ls.%.*ls'' in foreign key ''%.*ls'' is a timestamp column. This data type cannot be used with cascading referential integrity constraints.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (1787, 16, 0,'Cannot define foreign key constraint ''%.*ls'' with cascaded DELETE or UPDATE on table ''%.*ls'' because the table has an INSTEAD OF DELETE or UPDATE TRIGGER defined on it.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1788 ,16 ,0 ,'Cascading foreign key ''%.*ls'' cannot be created where the referencing column ''%.*ls.%.*ls'' is an identity column.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1789 ,16 ,0 ,'Cannot use CHECKSUM(*) in a computed column definition.', 1033)
go

GO
backup Transaction master with no_log
GO

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1801 ,16 ,0 ,'Database ''%.*ls'' already exists.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1802 ,11 ,0 ,'CREATE DATABASE failed. Some file names listed could not be created. Check previous errors.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1803 ,17 ,0 ,'CREATE DATABASE failed. Could not allocate enough disk space for a new database on the named disks. Total space allocated must be at least %d MB to accommodate a copy of the model database.' ,1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1804 ,10 ,0 ,'There is no disk named ''%.*ls''. Checking other disk names.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1805 ,10 ,0 ,'The CREATE DATABASE process is allocating %.2f MB on disk ''%.*ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1806, 16, 0, 'CREATE DATABASE failed. The default collation of database ''%.*ls'' cannot be set to ''%.*ls''.', 1033)
go


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1807 ,17 ,0 ,'Could not obtain exclusive lock on database ''%.*ls''. Retry the operation later.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1808 ,21 ,0 ,'Default devices are not supported.' ,1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1809 ,10 ,0 ,'To achieve optimal performance, update all statistics on the ''%.*ls'' database by running sp_updatestats.' ,1033)
Go


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1811 ,16 ,0 ,'''%.*ls'' is the wrong type of device for CREATE DATABASE or ALTER DATABASE. Check sysdevices. The statement is aborted.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1812, 16, 0, 'CREATE DATABASE failed. COLLATE clause cannot be used with the FOR ATTACH option.', 1033)

go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1813 ,16 ,0 ,'Could not open new database ''%.*ls''. CREATE DATABASE is aborted.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1814 ,10 ,0 ,'Could not create tempdb. If space is low, extend the amount of space and restart.' ,1033)


insert into sysmessages 
	values
	(1818, 16, 0, 'Primary log file ''%ls'' is missing and the database was not cleanly shut down so it cannot be rebuilt.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(1819,10,0,'Could not create default log file because the name was too long.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1820 ,16 ,0 ,'Disk ''%.*ls'' is already completely used by other databases. It can be expanded with DISK RESIZE.', 1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(1826,16,1,'User-defined filegroups are not allowed on ''%hs''.',
	1033)
insert into sysmessages 
	values
	(1827, 16, 0, 'CREATE/ALTER DATABASE failed because the resulting cumulative database size would exceed your licensed limit of %d MB per %S_MSG.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1828 ,16 ,0 ,'The file named ''%.*ls'' is already in use. Choose another name.',1033)
insert into sysmessages 
	values
	(1829, 16, 0, 'The FOR ATTACH option requires that at least the primary file be specified.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1830 ,16 ,0 ,'The files ''%.*ls'' and ''%.*ls'' are both primary files. A database can only have one primary file.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1832 ,20 ,0 ,'Could not attach database ''%.*ls'' to file ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1833,16,0,'File ''%ls'' cannot be reused until after the next BACKUP LOG operation.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1834,16,0, 'The file ''%ls'' cannot be overwritten.  It is being used by database ''%.*ls''.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(1835, 16, 1, 'Unable to create/attach any new database because the number of existing databases has reached the maximum number allowed: %d.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(1836, 10, 0, 'Could not create default data file because the name was too long.', 1033)

go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1901 ,16 ,0 ,'Column ''%.*ls''. Cannot create index on a column of bit data type.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1902 ,16 ,0 ,'Cannot create more than one clustered index on table ''%.*ls''. Drop the existing clustered index ''%.*ls'' before creating another.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1903 ,16 ,0 ,'Index keys are too large. The %d bytes needed to represent the keys for index %d exceeds the size limit of %d bytes.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1904, 16, 0, 'Cannot specify more than %d column names for statistics or index key list. %d specified.' ,1033)


go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1905 ,21 ,0 ,'Could not find ''zero'' row for index ''%.*ls'' the table in sysindexes.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1906 ,11 ,0 ,'Cannot create an index on ''%.*ls'', because this table does not exist in database ''%.*ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1907, 16, 1, 'Cannot re-create index ''%.*ls''. The new index definition does not match the constraint being enforced by the existing index.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1909 ,16 ,0 ,'Cannot use duplicate column names in index key list. Column name ''%.*ls'' listed more than once.' ,1033)

Go
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (1910 ,16 ,0 ,'Cannot create more than %d nonclustered indices or column statistics on one table.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1911 ,16 ,0 ,'Column name ''%.*ls'' does not exist in the target table.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1913 ,16 ,0 ,'There is already an index on table ''%.*ls'' named ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1914 ,16 ,0 ,'Index cannot be created on object ''%.*ls'' because the object is not a user table or view.', 1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1916 ,16 ,0 ,'CREATE INDEX options %ls and %ls are mutually exclusive.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(1918,10,0,'Index (ID = %d) is being rebuilt.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1919 ,16 ,0 ,'Column ''%.*ls''. Cannot create index on a column of text, ntext, or image data type.' ,1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (1920,10,1,'Skipping rebuild of index ID %d, which is on a read-only filegroup.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(1921,16,0,'Invalid filegroup ''%.*ls'' specified.', 1033)
GO
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(1922,16,0,'Filegroup ''%.*ls'' has no files assigned to it. Tables, indexes, and text, ntext, and image columns cannot be created on this filegroup.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1923 ,10 ,0 ,'The clustered index has been dropped.',1033)
insert into sysmessages 
	values
	(1924, 16, 0, 'Filegroup ''%.*ls'' is read-only.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(1925, 16, 0, 'Cannot convert a clustered index to a nonclustered index using the DROP_EXISTING option.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(1926,16,1,'Cannot create a clustered index because nonclustered index ID %d is on a read-only filegroup.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(1927 ,16 ,0 ,'There are already statistics on table ''%.*ls'' named ''%.*ls''.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(1928 ,16 ,0 ,'Cannot create statistics on table ''%.*ls'' because this table does not exist in database ''%.*ls''.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(1929 ,16 ,0 ,'Statistics cannot be created on object ''%.*ls'' because the object is not a user table or view.', 1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1931,16,0,'Filegroup ''%.*ls'' is offline.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1932,16,0,'Cannot create a clustered index because nonclustered index ID %d is on an offline filegroup.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1933, 16, 1, 'Cannot create index because the key column ''%.*ls'' is non-deterministic or imprecise.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1934, 16, 1, '%ls failed because the following SET options have incorrect settings: ''%.*ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1935, 16, 1, 'Cannot create index. Object ''%.*ls'' was created with the following SET options off: ''%.*ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1936, 16, 1, 'Cannot %ls the %S_MSG ''%.*ls''. It contains one or more disallowed constructs.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1937, 16, 1, 'Cannot index the view ''%.*ls''. It references another view or function ''%.*ls''.' ,1033)
go


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1938, 16, 1, 'Index cannot be created on %S_MSG ''%.*ls'' because the underlying object ''%.*ls'' has a different owner.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1939, 16, 1, 'Cannot create %S_MSG on view ''%.*ls'' because the view is not schema bound.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1940, 16, 1, 'Cannot create %S_MSG on view ''%.*ls''. It does not have a unique clustered index.' ,1033)




insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1941, 16, 1, 'Nonunique clustered index cannot be created on view ''%.*ls'' because only unique clustered indexes are allowed.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1942, 16, 1, 'Index cannot be created on view ''%.*ls'' because the view contains text, ntext or image columns.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1943, 16, 1, 'Index cannot be created on view ''%.*ls'' because the view has one or more nondeterministic expressions.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1944, 16, 1, 'Index ''%.*ls'' was not created. This index has a key length of at least %d bytes. The maximum permissible key length is %d bytes.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
values
	(1945, 16, 1, 'Warning! The maximum key length is %d bytes. The index ''%.*ls'' has maximum length of %d bytes. For some combination of large values, the insert/update operation will fail.', 1033)
go
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
values
(1946, 16, 1, 'Operation failed. The index entry of length %d bytes for the index ''%.*ls'' exceeds the maximum length of %d bytes.', 1033)


go
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1947 ,16 ,0 ,'Index cannot be created on view ''%.*ls'' because the view contains a self-join on ''%.*ls''.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (1948, 16, 1, 'Duplicate index names ''%.*ls'' and ''%.*ls'' detected on table ''%.*ls''.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1949, 16, 1, 'Index on view ''%.*ls'' cannot be created because function ''%s'' yields nondeterministic results.', 1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1950, 16, 1, 'Index on view ''%.*ls'' cannot be created because the view contains an imprecise expression in a GROUP BY clause', 1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1951, 16, 1, 'Index on view ''%.*ls'' cannot be created because the view contains an imprecise expression in the WHERE clause.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1952, 16, 1, 'Index on view ''%.*ls'' cannot be created because the view contains an imprecise expression in a join.', 1033)


go
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1953, 16, 1, 'Index on view ''%.*ls'' cannot be created because some arguments are missing in a built-in function.', 1033)




insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1954, 16, 1, 'Index on view ''%.*ls'' cannot be created because the view uses a column bound to a rule.', 1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1955, 16, 1, 'Index on view ''%.*ls'' cannot be created because the view contains a nondeterministic computed column.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1956, 16, 1, 'Index on view ''%.*ls'' cannot be created because the view uses a nondeterministic user-defined function.', 1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1957, 16, 1, 'Index on view ''%.*ls'' cannot be created because the view requires a conversion involving dates or variants.', 1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
    (1958, 16, 0,'This edition of SQL Server does not support indexed views.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(1959, 16 ,0 ,'Cannot create an index on a view or computed column because the compatibility level of this database is less than 80.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (1960 ,16 ,0 ,'Cannot create a non-unique clustered index on a table after it is published for transactional replication. Drop all publications that include this table before creating the index.' ,1033)


GO
raiserror('sysmessages.error>=2000 ....',0,1) with nowait
GO

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2001 ,10 ,0 ,'Cannot use duplicate parameter names. Parameter name ''%.*ls'' listed more than once.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2004 ,16 ,0 ,'Procedure ''%.*ls'' has already been created with group number %d. Create procedure with an unused group number.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2007 ,11 ,0 ,'Cannot add rows to sysdepends for the current stored procedure because it depends on the missing object ''%.*ls''. The stored procedure will still be created.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2008 ,16 ,0 ,'The object ''%.*ls'' is not a procedure so you cannot create another procedure under that group name.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2009 ,10 ,0 ,'Procedure ''%.*ls'' was created despite delayed name resolution warnings (if any).' , 1033)

GO
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(2010 ,16 ,0 ,'Cannot perform alter on %.*ls because it is an incompatible object type.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2011 ,16 ,0 ,'Index hints cannot be specified within a schema-bound object.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2012 ,16 ,0 ,'User-defined variables cannot be declared within a schema-bound object.', 1033)

go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2106 ,11 ,0 ,'Cannot create a trigger on table ''%.*ls'', because this table does not exist in database ''%.*ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2108 ,16 ,0 ,'Cannot create a trigger on table ''%.*ls'' because you can only create a trigger on a table in the current database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2110 ,16 ,0 ,'Cannot alter trigger ''%.*ls'' for table ''%.*ls'' because this trigger does not belong to this table.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2111, 16, 1, 'Cannot %s trigger ''%.*ls'' for %S_MSG ''%.*ls'' because an INSTEAD OF %s trigger already exists.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2112, 16, 1, 'Cannot %s trigger ''%.*ls'' for view ''%.*ls'' because it is defined with the CHECK OPTION.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2113, 16, 1, 'Cannot %s INSTEAD OF DELETE or UPDATE TRIGGER ''%.*ls'' on table ''%.*ls'' because the table has a FOREIGN KEY with cascaded DELETE or UPDATE.' , 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2114, 16, 1, 'Column ''%.*ls'' cannot be used in an IF UPDATE clause because it is a computed column.', 1033)



go


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2501 ,16 ,0 ,'Could not find a table or object named ''%.*ls''. Check sysobjects.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2502,16,0,'Could not start transaction.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2503,10,0,'Successfully deleted the physical file ''%ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2504,16,0,'Could not delete the physical file ''%ls''. The DeleteFile system function returned error %ls.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2505,16,0,'The device ''%.*ls'' does not exist. Use sp_helpdevice to show available devices.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2506 ,16 ,0 ,'Could not find a table or object name ''%.*ls'' in database ''%.*ls''.' ,1033)
go


insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(2511,16,0,'Table error: Object ID %d, Index ID %d. Keys out of order on page %S_PGID, slots %d and %d.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2512 ,16 ,1 ,'Table error: Object ID %d, Index ID %d. Duplicate keys on page %S_PGID slot %d and page %S_PGID slot %d.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2513 ,16 ,0 ,'Table error: Object ID %ld (object ''%.*ls'') does not match between ''%.*ls'' and ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2514,16,0,'Table error: Data type %ld (type ''%.*ls'') does not match between ''%.*ls'' and ''%.*ls''.' ,1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2515,16,0,'Page %S_PGID, object ID %d, index ID %d has been modified but is not marked modified in the differential backup bitmap.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2516,16,0,'The differential bitmap was invalidated for database %.*ls. A full database backup is required before a differential backup can be performed.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2517 ,16 ,1 ,'The minimally logged operation status has been turned on for database %.*ls. Rerun backup log operations to ensure that all data has been secured.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2519 ,16 ,1 ,'Unable to process table %.*ls because filegroup %.*ls is invalid.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2520 ,16 ,0 ,'Could not find database ''%.*ls''. Check sysdatabases.' ,1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(2521,16,0,'Could not find database ID %d. Check sysdatabases.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2522 ,16 ,1 ,'Unable to process index %.*ls of table %.*ls because filegroup %.*ls is invalid.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2523 ,16 ,1 ,'Filegroup %.*ls is invalid.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2524 ,16 ,1 ,'Unable to process table %.*ls because filegroup %.*ls is offline.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2525 ,16 ,1 ,'Database file %.*ls is offline.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2526 ,16 ,0 ,'Incorrect DBCC statement. Check the documentation for the correct DBCC syntax and options.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2527 ,16 ,1 ,'Unable to process index %.*ls of table %.*ls because filegroup %.*ls is offline.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2528 ,10 ,0 ,'DBCC execution completed. If DBCC printed error messages, contact your system administrator.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2529 ,16 ,1 ,'Filegroup %.*ls is offline.' ,1033)

Go
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2530 ,16 ,1 ,'Secondary index entries were missing or did not match the data in the table.  Use the WITH TABLOCK option and run the command again to display the failing records.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2531 ,16 ,1 ,'Table error: Object ID %d, index ID %d B-tree level mismatch, page %S_PGID. Level %d does not match level %d from previous %S_PGID.' ,1033)

insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(2532,16,0,'DBCC SHRINKFILE could not shrink file %ls. Log files are not supported.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2533, 16, 1, 'Table error: Page %S_PGID allocated to object ID %d, index ID %d was not seen.  Page may be invalid or have incorrect object ID information in its header.', 1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2534, 16, 1, 'Table error: Page %S_PGID with object ID %d, index ID %d in its header is allocated by another object.', 1033)

insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(2535,16,0,'Table error: Page %S_PGID is allocated to object ID %d, index ID %d, not to object ID %d, index ID %d found in page header.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2536 ,10 ,0 ,'DBCC results for ''%.*ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2537 ,16 ,1 ,'Table error: Object ID %d, index ID %d, page %S_PGID, row %d. Record check (%hs) failed. Values are %ld and %ld.' ,1033)

insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(2538,10,0,'File %d. Number of extents = %ld, used pages = %ld, reserved pages = %ld.',1033)

insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(2539,10,0,'Total number of extents = %ld, used pages = %ld, reserved pages = %ld in this database.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2540 ,10 ,1 ,'The system cannot self repair this error.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (2541 ,10 ,1 ,'DBCC UPDATEUSAGE: sysindexes row updated for table ''%.*ls'' (index ID %ld):' ,1033)
----------
-- Note - Leading spaces are for back compatability with prior messages
--        please do not remove for 2542 - 2545 - dbcc update usage documented
--		  message output
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (2542 ,10 ,1 ,'        DATA pages: Changed from (%ld) to (%ld) pages.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (2543 ,10 ,1 ,'        USED pages: Changed from (%ld) to (%ld) pages.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (2544 ,10 ,1 ,'        RSVD pages: Changed from (%ld) to (%ld) pages.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (2545 ,10 ,1 ,'        ROWS count: Changed from (%I64d) to (%I64d) rows.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (2546, 10, 1, 'Index ''%.*ls'' on table ''%.*ls'' is marked offline. Rebuild the index to bring it online.', 1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (2547, 10, 1, 'Performing second pass of index checks.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (2548 ,10 ,0 ,'DBCC: Compaction phase of index ''%.*ls'' is %d%% complete.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2549 ,10 ,0 ,'DBCC: Defrag phase of index ''%.*ls'' is %d%% complete.' ,1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2557 ,14 ,0 ,'User ''%.*ls'' does not have permission to run DBCC %ls for object ''%.*ls''.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (2559, 16, 1, 'The ''%ls'' and ''%ls'' options are not allowed on the same statement.', 1033)

Go

insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(2560,16,0,'Parameter %d is incorrect for this DBCC statement.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2562 ,16 ,0 ,'''%ls'' cannot access object ''%.*ls'' because it is not a table.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2566 ,14 ,0 ,'DBCC DBREINDEX cannot be used on system tables.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2567 ,14 ,0 ,'DBCC INDEXDEFRAG cannot be used on system table indexes' ,1033)


insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(2568,16,0,'Page %S_PGID is out of range for this database or is in a log file.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2570 ,16 ,1 ,'Warning: Page %S_PGID, slot %d in Object %d Index %d Column %.*ls value %.*ls is out of range for data type "%.*ls".  Update column to a legal value.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2571 ,14 ,0 ,'User ''%.*ls'' does not have permission to run DBCC %.*ls.' ,1033)

go



insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(2572 , 16 ,0 ,'DBCC cannot free DLL ''%.*ls''. The DLL is in use.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2573 ,16 ,0 ,'Database ''%.*ls'' is not marked suspect. You cannot drop it with DBCC.' ,1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(2574,10,0,'Object ID %d, index ID %d: Page %S_PGID is empty. This is not permitted at level %d of the B-tree.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2575 ,16 ,1 ,'IAM page %S_PGID is pointed to by the next pointer of IAM page %S_PGID object ID %d index ID %d but was not detected in the scan.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2576 ,16 ,1 ,'IAM page %S_PGID is pointed to by the previous pointer of IAM page %S_PGID object ID %d index ID %d but was not detected in the scan.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2577 ,16 ,1 ,'Chain sequence numbers are out of order in IAM chain for object ID %d, index ID %d. Page %S_PGID sequence number %d points to page %S_PGID sequence number %d.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2578 ,16 ,1 ,'Minimally logged extents were found in GAM interval starting at page %S_PGID but the minimally logged flag is not set in the database table.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2579 ,16 ,1 ,'Table error: Extent %S_PGID object ID %d, index ID %d is beyond the range of this database.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2580, 16, 1, 'Table ''%.*ls'' is either a system or temporary table. DBCC CLEANTABLE cannot be applied to a system or temporary table.', 1033)

insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(2583,16,0,'An incorrect number of parameters was given to the DBCC statement.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2588 ,16 ,0 ,'Page %S_PGID was expected to be the first page of a text, ntext, or image value.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (2590, 10, 1, 'User ''%.*ls'' is modifying bytes %d to %d of page %S_PGID in database ''%.*ls''.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2591 ,16 ,0 ,'Could not find row in sysindexes with index ID %d for table ''%.*ls''.' ,1033)
Go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2592 ,10 ,0 ,'%ls index successfully restored for object ''%.*ls'' in database ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2593 ,10 ,0 ,'There are %I64d rows in %ld pages for object ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2594 ,16 ,0 ,'Invalid index ID (%d) specified.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2595 ,16 ,0 ,'Database ''%.*ls'' must be set to single user mode before executing this statement.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2597 ,16 ,0 ,'The database is not open. Execute a ''USE %.*ls'' statement and rerun the DBCC statement.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2598 ,16 ,0 ,'Clustered indexes on sysobjects and sysindexes cannot be re-created.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2601 ,14 ,0 ,'Cannot insert duplicate key row in object ''%.*ls'' with unique index ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2603 ,21 ,0 ,'No space left on logical page %S_PGID of index ID %d for object ''%.*ls'' when inserting row on an index page. This situation should have been handled while traversing the index.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2617 ,20 ,0 ,'Buffer holding logical page %S_PGID not found in keep pool in SDES for object ''%.*ls''. Contact Technical Support.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2624 ,21 ,0 ,'Could not insert into table %S_DES because row length %d is less than the minimum length %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2627 ,14 ,0 ,'Violation of %ls constraint ''%.*ls''. Cannot insert duplicate key in object ''%.*ls''.' ,1033)

GO
backup Transaction master with no_log
GO

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2701 ,10 ,0 ,'Database name ''%.*ls'' ignored, referencing object in tempdb.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2702 ,16 ,0 ,'Database ''%.*ls'' does not exist.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2705 ,16 ,0 ,'Column names in each table must be unique. Column name ''%.*ls'' in table ''%.*ls'' is specified more than once.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2706 ,11 ,0 ,'Table ''%.*ls'' does not exist.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2710 ,16 ,0 ,'You are not the owner specified for the object ''%.*ls'' in this statement (CREATE, ALTER, TRUNCATE, UPDATE STATISTICS or BULK INSERT).' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2714 ,16 ,0 ,'There is already an object named ''%.*ls'' in the database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2715 ,16 ,0 ,'Column or parameter #%d: Cannot find data type %.*ls.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2716 ,16 ,0 ,'Column or parameter #%d: Cannot specify a column width on data type %.*ls.' ,1033)

--2717 was misplaced 
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2717 ,15 ,0 ,'The size (%d) given to the %S_MSG ''%.*ls'' exceeds the maximum allowed (%d).' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2718 ,16 ,0 ,'Column or parameter #%d: Cannot specify null values on a column of data type bit.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2721 ,11 ,0 ,'Could not find a default segment to create the table on. Ask your system administrator to specify a default segment in syssegments.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2724 ,10 ,0 ,'Parameter ''%.*ls'' has an invalid data type.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2727 ,11 ,0 ,'Cannot find index ''%.*ls''.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2730 ,11 ,0 ,'Cannot create procedure ''%.*ls'' with a group number of %d because a procedure with the same name and a group number of 1 does not currently exist in the database. Must execute CREATE PROCEDURE ''%.*ls'';1 first.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2731, 16, 1, 'Column ''%.*ls'' has invalid width: %d.' ,1033)


go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2732 ,16 ,0 ,'Error number %ld is invalid. The number must be from %ld through %ld' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2734 ,16 ,0 ,'The user name ''%.*ls'' does not exist in sysusers.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2736 ,16 ,0 ,'Owner name specified is a group name. Objects cannot be owned by groups.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2737 ,16 ,0 ,'Message passed to %hs must be of type char, varchar, nchar, or nvarchar.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2738 ,16 ,0 ,'A table can only have one timestamp column. Because table ''%.*ls'' already has one, the column ''%.*ls'' cannot be added.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2739 ,16 ,0 ,'The text, ntext, and image data types are invalid for local variables.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2740 ,16 ,0 ,'SET LANGUAGE failed because ''%.*ls'' is not an official language name or a language alias on this SQL Server.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2741 ,16 ,0 ,'SET DATEFORMAT date order ''%.*ls'' is invalid.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2742 ,16 ,0 ,'SET DATEFIRST %d is out of range.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2743 ,16 ,0 ,'%ls statement requires %S_MSG parameter.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2744 ,16 ,0 ,'Multiple identity columns specified for table ''%.*ls''. Only one identity column per table is allowed.' ,1033)

Go

---- New messages for user defined error support.


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2745 ,10 ,0 ,'Process ID %d has raised user error %d, severity %d. SQL Server is terminating this process.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2746 ,16 ,0 ,'Cannot specify user error format string with a length exceeding %d bytes.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2747 ,16 ,0 ,'Too many substitution parameters for RAISERROR. Cannot exceed %d substitution parameters.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2748 ,16 ,0 ,'Cannot specify %ls data type (RAISERROR parameter %d) as a substitution parameter for RAISERRROR.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2749 ,16 ,0 ,'Identity column ''%.*ls'' must be of data type int, bigint, smallint, tinyint, or decimal or numeric with a scale of 0, and constrained to be nonnullable.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2750 ,16 ,0 ,'Column or parameter #%d: Specified column precision %d is greater than the maximum precision of %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2751 ,16 ,0 ,'Column or parameter #%d: Specified column scale %d is greater than the specified precision of %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2752 ,16 ,0 ,'Identity column ''%.*ls'' contains invalid SEED.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2753 ,16 ,0 ,'Identity column ''%.*ls'' contains invalid INCREMENT.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2754 ,16 ,0 ,'Error severity levels greater than %d can only be specified by members of the sysadmin role, using the WITH LOG option.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2755 ,16 ,0 ,'SET DEADLOCK_PRIORITY option ''%.*ls'' is invalid.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2756 ,16 ,0 ,'Invalid value %d for state. Valid range is from %d to %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2757 ,16 ,0 ,'RAISERROR failed due to invalid parameter substitution(s) for error %d, severity %d, state %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2758 ,16 ,0 ,'%hs could not locate entry for error %d in sysmessages.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2759 ,0 ,0 ,'CREATE SCHEMA failed due to previous errors.' ,1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(2760,16,1,'Specified owner name ''%.*ls'' either does not exist or you do not have permission to use it.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2761 ,16 ,0 ,'The ROWGUIDCOL property can only be specified on the uniqueidentifier data type.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2762 ,16 ,0 ,'sp_setapprole was not invoked correctly. Refer to the documentation for more information.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2763 ,16 ,0 ,'Could not find application role ''%.*ls''.' ,1033)	
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2764 ,16 ,0 ,'Incorrect password supplied for application role ''%.*ls''.' ,1033)	
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
        values
        (2765,15,0,'Could not locate statistics for column ''%.*ls'' in the system catalogs.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2766 ,16 ,0 ,'The definition for user-defined data type ''%.*ls'' has changed.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
        values
        (2767,15,0,'Could not locate statistics ''%.*ls'' in the system catalogs.', 1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
        values
        (2768,15,0,'Statistics for %ls ''%.*ls''.', 1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
        values
        (2769,15,0,'Column ''%.*ls''. Cannot create statistics on a column of data type %ls.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(2770, 16, 1, 'The SELECT INTO statement cannot have same source and destination tables.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2771 ,16 ,1 ,'Cannot create statistics on table ''%.*ls''. This table is a virtual system table.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2772, 16, 0, 'Cannot access temporary tables from within a function.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2773, 16, 0, 'Sort order ID %d is invalid.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2774, 16, 0, 'Collation ID %d is invalid.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2775, 16, 0, 'Code page %d is not supported by the operating system.', 1033)

GO
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2777, 17, 0, 'Database ''%.*ls'' contains columns or parameters with the following code page(s) not supported by the operating system: %ls.', 1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2801 ,16 ,0 ,'The definition of object ''%.*ls'' has changed since it was compiled.' ,1033)
go


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2809 ,18 ,0 ,'The request for %S_MSG ''%.*ls'' failed because ''%.*ls'' is a %S_MSG object.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(2812 ,16 ,0 ,'Could not find stored procedure ''%.*ls''.' ,1033)

GO
raiserror('sysmessages.error>=3000 ....',0,1) with nowait
GO

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3009,16,0,'Could not insert a backup or restore history/detail record in the msdb database. This may indicate a problem with the msdb database. The backup/restore operation was still successful.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(3011,16,0,'All backup devices must be of the same general class (for example, DISK and TAPE).', 1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3013,16,0,'%hs is terminating abnormally.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3014,10,0,'%hs successfully processed %d pages in %d.%03d seconds (%d.%03d MB/sec).' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3015,10,0,'%hs is not yet implemented.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3016,16,0,'File ''%ls'' of database ''%ls'' has been removed or shrunk since this backup or restore operation was interrupted. The operation cannot be restarted.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3017,16,0,'Could not resume interrupted backup or restore operation. See the SQL Server error log for more information.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3018,16,0,'There is no interrupted backup or restore operation to restart. Reissue the statement without the RESTART clause.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3019,16,0,'The checkpoint file was for a different backup or restore operation. Reissue the statement without the RESTART clause.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3020,16,0,'The backup operation cannot be restarted as the log has been truncated. Reissue the statement without the RESTART clause.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3021,16,0,'Cannot perform a backup or restore operation within a transaction.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3023,16,0,'Backup and file manipulation operations (such as ALTER DATABASE ADD FILE) on a database must be serialized. Reissue the statement after the current backup or file manipulation operation is completed.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3024,16,0,'You can only perform a full backup of the master database. Use BACKUP DATABASE to back up the entire master database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3025,16,0,'Missing database name. Reissue the statement specifying a valid database name.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3026,16,0,'Could not find filegroup ID %d in sysfilegroups for database ''%ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3027,16,0,'Could not find filegroup ''%.*ls'' in sysfilegroups for database ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3028,16,0,'Operation checkpoint file is invalid. Could not restart operation. Reissue the statement without the RESTART option.' ,1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3031,16,0,'Option ''%ls'' conflicts with option(s) ''%ls''. Remove the conflicting option and reissue the statement.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3032,16,0,'One or more of the options (%ls) are not supported for this statement. Review the documentation for supported options.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3033,16,0,'BACKUP DATABASE cannot be used on a database opened in emergency mode.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3034,16,0,'No files were selected to be processed. You may have selected one or more filegroups that have no members.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3035,16,0,'Cannot perform a differential backup for database ''%ls'', because a current database backup does not exist. Perform a full database backup by reissuing BACKUP DATABASE, omitting the WITH DIFFERENTIAL option.' ,1033)


insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(3036,16,1, 'Database ''%ls'' is in warm-standby state (set by executing RESTORE WITH STANDBY) and cannot be backed up until the entire load sequence is completed.', 1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3037,16,0,'Minimally logged operations have occurred prior to this WITH RESTART command. Reissue the BACKUP statement without WITH RESTART.', 1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3038,16,0,'The filename ''%ls'' is invalid as a backup device name.  Reissue the BACKUP statement with a valid filename.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3039,16,0,'Cannot perform a differential backup for file ''%ls'' because a current file backup does not exist. Reissue BACKUP DATABASE omitting the WITH DIFFERENTIAL option.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (3040, 10, 0, 'An error occurred while informing replication of the backup. The backup will continue, but the replication environment should be inspected.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (3041, 16, 0, 'BACKUP failed to complete the command %.*ls', 1033)
Go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3101,16,0,'Exclusive access could not be obtained because the database is in use.', 1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3108,16,0,'RESTORE DATABASE must be used in single user mode when trying to restore the master database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3110,14,0,'User does not have permission to RESTORE database ''%.*ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3112,16,0,'Cannot restore any database other than master when the server is in single user mode.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3113,21,0,'The database owner (DBO) does not have an entry in sysusers in database ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3114,21,0,'Database ''%.*ls'' does not have an entry in sysdatabases.' ,1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3123,16,0,'Invalid database name ''%.*ls'' specified for backup or restore operation.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3124, 14, 0, 'Must be a System Administrator to perform LOAD with CONVERT65.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3127,16,0,'Temporary Message: The backup set does not contain pages for file ''%ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3128,16,0,'File ''%ls'' has an unsupported page size (%d).' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3129,16,0,'Temporary Message: File ''%ls'' has changed size from %d to %d bytes.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3132,16,0,'The media set for database ''%ls'' has %d family members but only %d are provided.  All members must be provided.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3133,16,0,'The volume on device ''%ls'' is not a member of the media family.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3135,16,0,'The backup set in file ''%ls'' was created by %hs and cannot be used for this restore operation.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3136,16,0,'Cannot apply the backup on device ''%ls'' to database ''%ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3138,16,0,'One or more files in the backup set are no longer part of database ''%ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3140,16,0,'Could not adjust the space allocation for file ''%ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3141,16,0,'The database to be restored was named ''%ls''. Reissue the statement using the WITH REPLACE option to overwrite the ''%ls'' database.' ,1033)

--3142 updated Syl 4/27

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3142,16,0,'File ''%ls'' cannot be restored over the existing ''%ls''. Reissue the RESTORE statement using WITH REPLACE to overwrite pre-existing files.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3143,16,0,'The data set on device ''%ls'' is not a SQL Server backup set.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3144,16,0,'File ''%.*ls'' was not backed up in file %d on device ''%ls''. The file cannot be restored from this backup set.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3145,16,0,'The STOPAT option is not supported for RESTORE DATABASE. You can use the STOPAT option with RESTORE LOG.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3146,16,0,'None of the newly-restored files had been modified after the backup was taken, so no further recovery actions are required. The database is now available for use.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3147 ,16 ,0 ,'Backup and restore operations are not allowed on database tempdb.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3148 ,16 ,0 ,'Media recovery for ALTER DATABASE is not yet implemented. The database cannot be rolled forward.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3150 ,10 ,0 ,'The master database has been successfully restored. Shutting down SQL Server.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3151 ,21 ,0 ,'The master database failed to restore. Use the rebuildm utility to rebuild the master database. Shutting down SQL Server.' ,1033)
insert into sysmessages 
	values
	(3152, 16, 0, 'Cannot overwrite file ''%ls'' because it is marked as read-only.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3153 ,16 ,0 ,'The database is already fully recovered.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3154 ,16 ,0 ,'The backup set holds a backup of a database other than the existing ''%ls'' database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3155, 16, 0, 'The RESTORE operation cannot proceed because one or more files have been added or dropped from the database since the backup set was created.', 1033)

--3156 updated 4/27
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(3156,16,1,'File ''%ls'' cannot be restored to ''%ls''. Use WITH MOVE to identify a valid location for the file.', 1033)

insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(3157,16,1,'The logical file (%d) is named ''%ls''. RESTORE will not overwrite it from ''%ls''.',
	1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(3158,16,1,'Could not create one or more files. Consider using the WITH MOVE option to identify valid locations.',
	1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3159, 16, 0, 'The tail of the log for database ''%ls'' has not been backed up. Back up the log and rerun the RESTORE statement specifying the FILE clause.', 1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(3160,16,1,'Could not update primary file information in sysdatabases.',
	1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 3161, 16, 1, 'The primary file is unavailable. It must be restored or otherwise made available.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(3162,16,1, 'The database has on-disk structure version %d. The server supports version %d and can only restore such a database that was inactive when it was backed up. This database was not inactive.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(3163,16,1, 'The transaction log was damaged. All data files must be restored before RESTORE LOG can be attempted.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(3164,16,0,'Cannot roll forward the database with on-disk structure version %d. The server supports version %d. Reissue the RESTORE statement WITH RECOVERY.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(3165,16,0,'Could not adjust the replication state of database ''%ls''. The database was successfully restored, however its replication state is indeterminate. See the Troubleshooting Replication section in SQL Server Books Online.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(3166,16,0,'RESTORE DATABASE could not drop database ''%ls''. Drop the database and then reissue the RESTORE DATABASE statement.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(3167,16,0,'RESTORE could not start database ''%ls''.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3168,16,0,'The backup of the system database on device %ls cannot be restored because it was created by a different version of the server (%u) than this server (%u).' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3169,16,0,'The backed-up database has on-disk structure version %d. The server supports version %d and cannot restore or upgrade this database.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3170,16,0,'The STANDBY filename is invalid.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3171,16,0,'Cannot restore file %ls because the file is offline.' ,1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3172,16,0,'Cannot restore filegroup %ls because the filegroup is offline.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3174,16,0,'The file ''%ls'' cannot be moved by this RESTORE operation.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3175,16,0,'The filegroup ''%ls'' cannot be restored because all of the files are not present in the backup set. File ''%ls'' is missing.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3176,16,0,'File ''%ls'' is claimed by ''%ls''(%d) and ''%ls''(%d). The WITH MOVE clause can be used to relocate one or more files.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3177,14,0,'Only members of the dbcreator and sysadmin roles can execute the %ls statement.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3178,16,0,'File %ls is not in the correct state to have this differential backup applied to it.' ,1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3179,16,0,'The system database cannot be moved by RESTORE.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3180,16,0,'This backup cannot be restored  using WITH STANDBY because a database upgrade is needed. Reissue the RESTORE without WITH STANDBY.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3201,16,0,'Cannot open backup device ''%ls''. Device error or device off-line. See the SQL Server error log for more details.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3202,16,0,'Write on ''%ls'' failed, status = %ld. See the SQL Server error log for more details.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3203,16,0,'Read on ''%ls'' failed, status = %ld. See the SQL Server error log for more details.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3204,16,0,'Operator aborted backup or restore. See the error messages returned to the console for more details.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3205,16,0,'Too many backup devices specified for backup or restore; only %d are allowed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3206,16,0,'No entry in sysdevices for backup device ''%.*ls''. Update sysdevices and rerun statement.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3207,16,0,'Backup or restore requires at least one backup device. Rerun your statement specifying a backup device.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3208,16,0,'Unexpected end of file while reading beginning of backup set. Confirm that the media contains a valid SQL Server backup set, and see the console error log for more details.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3209,16,0,'''%.*ls'' is not a backup device. Check sysdevices.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3211 ,10 ,0 ,'%d percent %hs.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3217,16,0,'Invalid value specified for %ls parameter.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3221,16,0,'The ReadFileEx system function executed on file ''%ls'' only read %d bytes, expected %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3222,16,0,'The WriteFileEx system function executed on file ''%ls'' only wrote %d bytes, expected %d.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3224,16,0,'Cannot create worker thread.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3227,16,0,'The volume on device ''%ls'' is a duplicate of stripe set member %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3229,16,0,'Request for device ''%ls'' timed out.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3230,16,0,'Operation on device ''%ls'' exceeded retry count.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3234,16,0,'Logical file ''%.*ls'' is not part of database ''%ls''. Use RESTORE FILELISTONLY to list the logical file names.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3235,16,0,'File ''%ls'' is not part of database ''%ls''. You can only list files that are members of this database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3237,16,0,'Option not supported for Named Pipe-based backup sets.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3239,16,0,'The backup set on device ''%ls'' uses a feature of the Microsoft Tape Format not supported by SQL Server.' ,1033)
GO
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3241,16,0,'The media family on device ''%ls'' is incorrectly formed. SQL Server cannot process this media family.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3242,16,0,'The file on device ''%ls'' is not a valid Microsoft Tape Format backup set.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3243,16,0,'The media family on device ''%ls'' was created using Microsoft Tape Format version %d.%d. SQL Server supports version %d.%d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3244,16,0,'Descriptor block size exceeds %d bytes. Use a shorter name and/or description string and retry the operation.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3245,16,0,'Could not convert a string to or from Unicode, %ls.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3246,16,0,'The media family on device ''%ls'' is marked as nonappendable. Reissue the statement using the INIT option to overwrite the media.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3247,16,0,'The volume on device ''%ls'' has the wrong media sequence number (%d). Remove it and insert volume %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3248,25,0,'>>> VOLUME SWITCH <<< (not for output!)' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3249,16,0,'The volume on device ''%ls'' is a continuation volume for the backup set. Remove it and insert the volume holding the start of the backup set.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3250,16,0,'The value ''%d'' is not within range for the %ls parameter.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3251,10,0,'The media family on device ''%ls'' is complete. The device is now being reused for one of the remaining families.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3253,16,0,'The block size parameter must supply a value that is a power of 2.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3254,16,0,'The volume on device ''%ls'' is empty.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3255,16,0,'The data set on device ''%ls'' is a SQL Server backup set not compatible with this version of SQL Server.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3256,16,0,'The backup set on device ''%ls'' was terminated while it was being created and is incomplete. RESTORE sequence is terminated abnormally.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3257,16,0,'There is insufficient free space on disk volume ''%ls'' to create the database. The database requires %I64u additional free bytes, while only %I64u bytes are available.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(3258,16,0,'The volume on device ''%ls'' belongs to a different media set.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(3259,16,0,'The volume on device ''%ls'' is not part of a multiple family media set. BACKUP WITH FORMAT can be used to form a new media set.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(3260,16,0,'An internal buffer has become full.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(3261,16,0,'SQL Server cannot use the virtual device configuration.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(3262,10,0,'The backup set is valid.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(3263,16,0,'Cannot use the volume on device ''%ls'' as a continuation volume. It is sequence number %d of family %d for the current media set. Insert a new volume, or sequence number %d of family %d for the current set.'
    ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(3264,16,0,'The operation did not proceed far enough to allow RESTART. Reissue the statement without the RESTART qualifier.'
    ,1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(3265,16,1, 'The login has insufficient authority. Membership of the sysadmin role is required to use VIRTUAL_DEVICE with BACKUP or RESTORE.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(3266,10,0,'The backup data in ''%ls'' is incorrectly formatted. Backups cannot be appended, but existing backup sets may still be usable.', 1033)




insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(3267,16,0,'Insufficient resources to create UMS scheduler.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (3268,16,0,'Cannot use the backup file ''%ls'' because it was originally formatted with sector size %d and is now on a device with sector size %d.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (3269,16,0,'Cannot restore the file ''%ls'' because it was originally written with sector size %d; ''%ls'' is now on a device with sector size %d.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (3270,16,0,'An internal consistency error occurred. Contact Technical Support for assistance.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(3271,16,0,'Nonrecoverable I/O error occurred on file ''%ls''.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(3272,16,0,'The ''%ls'' device has a hardware sector size of %d, but the block size parameter specifies an incompatible override value of %d. Reissue the statement using a compatible block size.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3273,16,0,'The BUFFERCOUNT parameter must supply a value that allows at least one buffer per backup device.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3274,16,0,'Incorrect checksum computed for the backup set on device %ls. The backup set cannot be restored.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3275,16,0,'I/O request 0x%08x failed I/O verification. See the error log for a description.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3276,16,0,'WITH SNAPSHOT can be used only if the backup set was created WITH SNAPSHOT.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3277,16,0,'WITH SNAPSHOT must be used with only one virtual device.', 1033)

GO

--3278 to 3281 added 4/27 - Syl
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3278,16,0,'Failed to encrypt string %ls', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3279,16,0,'Access is denied due to a password failure', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3280,16,0,'Backups on raw devices are not supported. ''%ls'' is a raw device.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3281,16,0,'Released and initiated rewind on ''%ls''.', 1033)



GO
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3301 ,21 ,0 ,'Invalid log record found in the transaction log (logop %d).' ,1033)

insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(3313,21,1,'Error while redoing logged operation in database ''%.*ls''. Error at log record ID %S_LSN.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(3314,21,1,'Error while undoing logged operation in database ''%.*ls''. Error at log record ID %S_LSN.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3315,10,0,'During rollback, process %d was expected to hold mode %d lock at level %d for row %S_RID in database ''%.*ls'' under transaction %S_XID.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3405 ,10 ,0 ,'Recovering database ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3406 ,10 ,0 ,'%d transactions rolled forward in database ''%.*ls'' (%d).' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3407 ,10 ,0 ,'%d transactions rolled back in database ''%.*ls'' (%d).' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3408 ,10 ,0 ,'Recovery complete.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3413 ,21 ,0 ,'Database ID %d. Could not mark database as suspect. Getnext NC scan on sysdatabases.dbid failed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3414 ,10 ,0 ,'Database ''%.*ls'' (database ID %d) could not recover. Contact Technical Support.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3415 ,16 ,0 ,'Database ''%.*ls'' is read-only or has read-only files and must be made writable before it can be upgraded.' ,1033)

Go


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3417 ,21 ,0 ,'Cannot recover the master database. Exiting.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3429, 10, 0 ,'Warning: The outcome of transaction %S_XID, named ''%.*ls'' in database ''%.*ls'' (database ID %d), could not be determined because the coordinating database (database ID %d) could not be opened. The transaction was assumed to be committed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3430, 10, 0 ,'Warning: Could not determine the outcome of transaction %S_XID, named ''%.*ls'' in database ''%.*ls'' (with ID %d) because the coordinating database (ID %d) did not contain the outcome. The transaction was assumed to be committed.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3431, 21, 0 ,'Could not recover database ''%.*ls'' (database ID %d) due to unresolved transaction outcomes.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3432 ,16 ,0 ,'Warning: syslanguages is missing.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(3433, 16, 0, 'Name is truncated to ''%.*ls''. The maximum name length is %d.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3434, 20, 1,'Cannot change sort order or locale. Server shutting down. Restart SQL Server to continue with sort order unchanged.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3435, 20, 2, 'Sort order or locale cannot be changed because user objects or user databases exist.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3436 ,16 ,0 ,'Cannot rebuild index for the ''%.*ls'' table in the ''%.*ls'' database.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3437 ,21 ,0 ,'Error recovering database ''%.*ls''. Could not connect to MSDTC to check the completion status of transaction %S_XID.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3438 ,10 ,0 ,'Database ''%.*ls'' (database ID %d) failed to recover because transaction first LSN is not equal to LSN in checkpoint. Contact Technical Support.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3439 ,10 ,0 ,'Database ''%.*ls'' (database ID %d). The DBCC RECOVERDB statement failed due to previous errors.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3440 ,21 ,0 ,'Database ''%.*ls'' (database ID %d). The DBCC RECOVERDB statement can only be run after a RESTORE statement that used the WITH NORECOVERY option.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3441 ,21 ,0 ,'Database ''%.*ls'' (database ID %d). The RESTORE statement could not access file ''%ls''. Error was ''%ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3442 ,21 ,0 ,'Database ''%.*ls'' (database ID %d). The size of the undo file is insufficient.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3443 ,21 ,0 ,'Database ''%.*ls'' (database ID %d) was marked for standby or read-only use, but has been modified. The RESTORE LOG statement cannot be performed.' ,1033)

--3445  updated 4/27
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3445 ,21 ,0 ,'File ''%ls'' is not a valid undo file for database ''%.*ls'', database ID %d.' ,1033)



insert into sysmessages 
	values
	(3446, 16, 0, 'Primary log file is not available for database ''%.*ls''.  The log cannot be backed up.', 1033)
insert into sysmessages 
	values
	(3447, 16, 0, 'Could not activate or scan all of the log files for database ''%.*ls''.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3448 ,21 ,0 ,'Could not undo log record %S_LSN, for transaction ID %S_XID, on page %S_PGID, database ''%.*ls'' (database ID %d). Page information: LSN = %S_LSN, type = %ld. Log information: OpCode = %ld, context %ld.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3449 ,21 ,0 ,'An error has occurred that requires SQL Server to shut down so that recovery can be performed on database ID %d.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3450, 10, 0, 'Recovery of database ''%.*ls'' (%d) is %d%% complete (approximately %d more seconds) (Phase %d of 3).', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(3451,16,1, 'Recovery has failed because reexecution of CREATE INDEX found inconsistencies between target filegroup ''%ls'' (%d) and source filegroup ''%ls'' (%d). Restore both filegroups before attempting further RESTORE LOG operations.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3452 ,10 ,0 ,'Recovery of database ''%.*ls'' (%d) detected possible identity value inconsistency in table ID %d. Run DBCC CHECKIDENT (''%.*ls'').' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3453,16,0,'This version cannot redo any index creation or non-logged operation done by SQL Server 7.0.  Further roll forward is not possible.', 1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3454, 10, 0, 'Recovery is checkpointing database ''%.*ls'' (%d)', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3455, 10, 0, 'Analysis of database ''%.*ls'' (%d) is %d%% complete (approximately %d more seconds)', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3456 ,21 ,0 ,'Could not redo log record %S_LSN, for transaction ID %S_XID, on page %S_PGID, database ''%.*ls'' (%d). Page: LSN = %S_LSN, type = %ld. Log: OpCode = %ld, context %ld, PrevPageLSN: %S_LSN.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3741,16,0,'Cannot drop the %S_MSG ''%.*ls'' because at least part of the table resides on an offline filegroup.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3501 ,21 ,0 ,'Could not find row in sysdatabases for database ID %d at checkpoint time.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3505 ,14 ,0 ,'Only the owner of database ''%.*ls'' can run the CHECKPOINT statement.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3508 ,25 ,0 ,'Could not get an exclusive lock on the database ''%.*ls''. Make sure that no other users are currently using this database, and rerun the CHECKPOINT statement.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3509 ,14 ,0 ,'Could not set database ''%.*ls'' %ls read-only user mode because you could not exclusively lock the database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3510 ,16 ,0 ,'Database ''%.*ls'' cannot be changed from read-only because the primary and/or log file(s) are not writable.' ,1033)

GO
backup Transaction master with no_log
GO

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3604 ,10 ,0 ,'Duplicate key was ignored.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3605 ,10 ,0 ,'Duplicate row was ignored.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3606 ,10 ,0 ,'Arithmetic overflow occurred.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3607 ,10 ,0 ,'Division by zero occurred.' ,1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(3608, 16, 0, 'Cannot allocate a GUID for the token.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3612 ,10 ,0 ,'%hsSQL Server Execution Times:%hs   CPU time = %lu ms,  elapsed time = %lu ms.' ,1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
	(3613 ,10 ,0 ,'SQL Server parse and compile time: %hs   CPU time = %lu ms, elapsed time = %lu ms.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3615 ,10 ,0 ,'Table ''%.*ls''. Scan count %d, logical reads %d, physical reads %d, read-ahead reads %d.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3618 ,10 ,0 ,'The transaction has been terminated.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3619 ,10 ,0 ,'Could not write a CHECKPOINT record in database ID %d because the log is out of space.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3620 ,10 ,128 ,'Automatic checkpointing is disabled in database ''%.*ls'' because the log is out of space. It will continue when the database owner successfully checkpoints the database. Free up some space or extend the database and then run the CHECKPOINT statement.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3621 ,10 ,0 ,'The statement has been terminated.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3622 ,10 ,0 ,'A domain error occurred.' ,1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(3625,20,1,'''%hs'' is not yet implemented.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (3627,16,0,'Could not create worker thread.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (3628, 24, 0, 'A floating point exception occurred in the user process. Current transaction is canceled.', 1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3629, 10, 0, 'This SQL Server has been optimized for %d concurrent queries. This limit has been exceeded by %d queries and performance may be adversely affected.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3630, 10, 0, 'Concurrency violations since %ls%s     1     2     3     4     5     6     7     8     9  10-100  >100%s%6u%6u%6u%6u%6u%6u%6u%6u%6u%8u%6u' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3631, 10, 0, 'Concurrency violations will be written to the SQL Server error log.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3632, 10, 0, 'Concurrency violations will not be written to the SQL Server error log.' ,1033)

go


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3701 , 11 ,0 ,'Cannot %S_MSG the %S_MSG ''%.*ls'', because it does not exist in the system catalog.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3702 ,16 ,0 ,'Cannot drop the %S_MSG ''%.*ls'' because it is currently in use.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3703 ,16 ,0 ,'Cannot detach the %S_MSG ''%.*ls'' because it is currently in use.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3704 ,16 ,0 ,'User does not have permission to perform this operation on %S_MSG ''%.*ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3705 ,16 ,0 ,'Cannot use DROP %ls with ''%.*ls'' because ''%.*ls'' is a %S_MSG. Use DROP %ls.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3708 ,16 ,0 ,'Cannot %S_MSG the %S_MSG ''%.*ls'' because it is a system %S_MSG.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3716 ,16 ,0 ,'The %S_MSG ''%.*ls'' cannot be dropped because it is bound to one or more %S_MSG.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3718 ,11 ,0 ,'Could not drop index ''%.*ls'' because the table or clustered index entry cannot be found in the sysindexes system table.' ,1033)

Go

---- These are new messages for DROP CONSTRAINT (and one for replication), Messages 3723 - 3735

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3723 ,16 ,0 ,'An explicit DROP INDEX is not allowed on index ''%.*ls''. It is being used for %ls constraint enforcement.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3724 ,16 ,0 ,'Cannot %S_MSG the %S_MSG ''%.*ls'' because it is being used for replication.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3725 ,16 ,0 ,'The constraint ''%.*ls'' is being referenced by table ''%.*ls'', foreign key constraint ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3726 ,16 ,0 ,'Could not drop object ''%.*ls'' because it is referenced by a FOREIGN KEY constraint.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3727 ,10 ,0 ,'Could not drop constraint. See previous errors.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3728 ,16 ,0 ,'''%.*ls'' is not a constraint.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3729, 16, 1, 'Cannot %ls ''%.*ls'' because it is being referenced by object ''%.*ls''.' ,1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3733 ,16 ,0 ,'Constraint ''%.*ls'' does not belong to table ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3736,16,0,'Cannot drop the %S_MSG ''%.*ls'' because it is being used for distribution.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3737,16,0,'Could not delete file ''%ls''. See the SQL Server error log for more information.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3738,16,0,'Deleting database file ''%ls''.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
        (3739,15,0,'Cannot %ls the index ''%.*ls'' because it is not a statistics collection.',1033) 

insert into sysmessages 
	values
	(3740, 16, 0, 'Cannot drop the %S_MSG ''%.*ls'' because at least part of the table resides on a read-only filegroup.', 1033)

GO

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3902 ,13 ,0 ,'The COMMIT TRANSACTION request has no corresponding BEGIN TRANSACTION.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3903 ,13 ,0 ,'The ROLLBACK TRANSACTION request has no corresponding BEGIN TRANSACTION.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3904 ,21 ,0 ,'Cannot unsplit logical page %S_PGID in object ''%.*ls'', in database ''%.*ls''. Both pages together contain more data than will fit on one page.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3906 ,16 ,0 ,'Could not run BEGIN TRANSACTION in database ''%.*ls'' because the database is read-only.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3908 ,16 ,0 ,'Could not run BEGIN TRANSACTION in database ''%.*ls'' because the database is in bypass recovery mode.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3909 ,16 ,0 ,'Session binding token is invalid.' ,1033)

---- The following are new messages for bound session support.  Messages 3909 - 3912


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3910 ,16 ,0 ,'Transaction context in use by another session.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3912 ,16 ,0 ,'Cannot bind using an XP token while the server is not in an XP call.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3914, 16, 0, 'The data type ''%s'' is invalid for transaction names or savepoint names. Allowed data types are char, varchar, nchar, or nvarchar.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(3915, 16, 0, 'Cannot use the ROLLBACK statement within an INSERT-EXEC statement.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(3916, 16, 0, 'Cannot use the COMMIT statement within an INSERT-EXEC statement unless BEGIN TRANSACTION is used first.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (3917, 16, 0, 'Session is bound to a transaction context that is in use. Other statements in the batch were ignored.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3918,16,0,'Statement must be executed in the context of a user transaction.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (3919 ,16 ,0 ,'Cannot enlist in the transaction because the transaction has already been committed or rolled back.' ,1033)
go

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(3920 ,10 ,0 ,'The WITH MARK option only applies to the first BEGIN TRAN WITH MARK statement. The option is ignored.' ,1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (3921, 16, 0 ,'Cannot get a transaction token if there is no transaction active. Reissue the statement after a transaction has been started' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (3922, 16, 1, 'Cannot enlist in the transaction because the transaction does not exist.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3923, 10, 0, 'Cannot use transaction marks on database ''%.*ls'' with bulk-logged operations that have not been backed up. The mark is ignored.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3924, 10, 0, 'The session was enlisted in an active user transaction while trying to bind to a new transaction. The session has defected from the previous user transaction.', 1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (3925, 16, 0, 'Invalid transaction mark name. The ''LSN:'' prefix is reserved.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (3926,10,0,'The transaction active in this session has been committed or aborted by another session.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (3927,10,0,'The session had an active transaction when it tried to enlist in a Distributed Transaction Coordinator transaction.', 1033)

go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(3928 ,16 ,0 ,'The marked transaction ''%.*ls'' failed. A Deadlock was encountered while attempting to place the mark in the log.' ,1033)

go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (3929 ,16 ,0 ,'No distributed or bound transaction is allowed in single user database.' ,1033)

--4000
GO
raiserror('sysmessages.error>=4000 ....',0,1) with nowait
GO

insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(4003 ,21 ,0 ,'ODS error. Server is terminating this connection.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
    values
    (4004, 16, 0, 'Unicode data in a Unicode-only collation or ntext data cannot be sent to clients using DB-Library (such as ISQL) or ODBC version 3.7 or earlier.', 1033)



insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(4015,16,1,'Language requested in login ''%.*ls'' is not an official name on this SQL Server. Using server-wide default %.*ls instead.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(4016,16,1,'Language requested in ''login %.*ls'' is not an official name on this SQL Server. Using user default %.*ls instead.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(4017,16,1,'Neither the language requested in ''login %.*ls'' nor user default language %.*ls is an official language name on this SQL Server. Using server-wide default %.*ls instead.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(4018,16,1,'User default language %.*ls is not an official language name on this SQL Server. Using server-wide default %.*ls instead.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(4019,16,1,'Language requested in login ''%.*ls'' is not an official language name on this SQL Server. Login fails.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(4020,16,1,'Default date order ''%.*ls'' for language %.*ls is invalid. Using mdy instead.',1033)


---- These are new messages for tape devices, Messages 4027 - 4035


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4027,16,0,'Mount tape for %hs of database ''%ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4028,16,0,'End of tape has been reached. Remove tape ''%ls'' and mount next tape for %hs of database ''%ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4030,10,0,'The medium on device ''%ls'' expires on %hs and cannot be overwritten.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4035,10,0,'Processed %d pages for database ''%ls'', file ''%ls'' on file %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4037,16,0,'User-specified volume ID ''%ls'' does not match the volume ID ''%ls'' of the device ''%ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4038,16,0,'Cannot find file ID %d on device ''%ls''.' ,1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(4060,11,1,'Cannot open database requested in login ''%.*ls''. Login fails.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(4061,11,1,'Cannot open either database requested in login (%.*ls) or user default database. Using master database instead.',1033)



insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(4062,11,1,'Cannot open user default database. Using master database instead.',1033)
go


insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(4063,11,1,'Cannot open database requested in login (%.*ls). Using user default ''%.*ls'' instead.',1033)
GO
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(4064,11,1,'Cannot open user default database. Login failed.',1033)
go

--4208 removed space 
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4208,16,0, 'The statement %hs is not allowed while the recovery model is SIMPLE. Use BACKUP DATABASE or change the recovery model using ALTER DATABASE.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4212,16,0,'Cannot back up the log of the master database. Use BACKUP DATABASE instead.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4214,10,0,'There is no current database backup. This log backup cannot be used to roll forward a preceding database backup.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4215,10,0,'The log was not truncated because records at the beginning of the log are pending replication. Ensure the Log Reader Agent is running or use sp_repldone to mark transactions as distributed.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4216,16,0,'Minimally logged operations cannot be backed up when the database is unavailable.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4217,10,0,'BACKUP LOG cannot modify the database because database is read-only. The backup will continue,although subsequent backups will duplicate the work of this backup.', 1033)

go


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4301,16,0,'Database in use. The system administrator must have exclusive use of the database to restore the log.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4304 ,16 ,0 ,'A USER ATTENTION signal raised during RESTORE LOG is being ignored until the current restore completes.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4305,16,0,'The log in this backup set begins at LSN %.*ls, which is too late to apply to the database. An earlier log backup that includes LSN %.*ls can be restored.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4306,16,0,'The preceding restore operation did not specify WITH NORECOVERY or WITH STANDBY. Restart the restore sequence, specifying WITH NORECOVERY or WITH STANDBY for all but the final step.' ,1033)
Go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4316,16,0,'Can only RESTORE LOG in the master database if SQL Server is in single user mode.' ,1033)


---- Backup/restore messages


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4318,16,0,'File ''%ls'' has been rolled forward to LSN %.*ls. This log terminates at LSN %.*ls, which is too early to apply the WITH RECOVERY option. Reissue the RESTORE LOG statement WITH NORECOVERY.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4320,16,0,'File ''%ls'' was only partially restored by a database or file restore. The entire file must be successfully restored before applying the log.' ,1033)


insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(4322,10,1, 'This log file contains records logged before the designated point-in-time. The database is being left in load state so you can apply another log file.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(4323,16,0,'The database is marked suspect. Transaction logs cannot be restored. Use RESTORE DATABASE to recover the database.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
        values
        (4324,10,0,'Backup history older than %ls has been deleted.',1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
        values
        (4325,16,0,'Could not delete entries for backup set ID ''%ls''.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4326,16,0,'The log in this backup set terminates at LSN %.*ls, which is too early to apply to the database. A more recent log backup that includes LSN %.*ls can be restored.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4327,16,0,'The log in this backup set contains minimally logged changes. Point-in-time recovery is inhibited. RESTORE will roll forward to end of logs without recovering the database.', 1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4328,16,0, 'File ''%ls'' is missing. Rollforward stops at log sequence number %.*ls. File is created at LSN %.*ls, dropped at LSN %.*ls. Restore transaction log beyond beyond point in time when file was dropped or restore data to be consistent with rest of database.' ,1033)


insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(4329, 10, 1, 'This log file contains records logged before the designated mark. The database is being left in load state so you can apply another log file.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4330,16,0,'The log in this backup set cannot be applied because it is on a recovery path inconsistent with the database.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4331,16,0,'The database cannot be recovered because the files have been restored to inconsistent points in time.', 1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4332, 16, 0, 'RESTORE LOG has been halted. To use the database in its current state, run RESTORE DATABASE %ls WITH RECOVERY.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (4333, 16, 0, 'The database cannot be recovered because the log was not restored.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (4334, 16, 0, 'The named mark does not identify a valid LSN.', 1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4403 ,16 ,0 ,'View or function ''%.*ls'' is not updatable because it contains aggregates.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4404 ,16 ,0 ,'View or function ''%.*ls'' is not updatable because the definition contains the DISTINCT clause.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4405, 16 ,0 ,'View or function ''%.*ls'' is not updatable because the modification affects multiple base tables.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4406 ,16 ,0 ,'Update or insert of view or function ''%.*ls'' failed because it contains a derived or constant field.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4408 ,19 ,0 ,'The query and the views or functions in it exceed the limit of %d tables.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(4413 ,16 ,0 ,'Could not use view or function ''%.*ls'' because of binding errors.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4414 ,16 ,0 ,'Could not allocate ancillary table for view or function resolution. The maximum number of tables in a query (%d) was exceeded.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4415 ,16 ,0 ,'View ''%.*ls'' is not updatable because either it was created WITH CHECK OPTION or it spans a view created WITH CHECK OPTION and the target table is referenced multiple times in the resulting query.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	 (4416 ,16 ,0 ,'UNION ALL view ''%.*ls'' is not updatable because the definition contains a disallowed construct.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4417 ,16 ,0 ,'Derived table ''%.*ls'' is not updatable because the definition contains a UNION operator.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4418 ,16 ,0 ,'Derived table ''%.*ls'' is not updatable because it contains aggregates.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4419 ,16 ,0 ,'Derived table ''%.*ls'' is not updatable because the definition contains the DISTINCT clause.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4420, 16 ,0 ,'Derived table ''%.*ls'' is not updatable because the modification affects multiple base tables.' ,1033)

Go
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4421 ,16 ,0 ,'Derived table ''%.*ls'' is not updatable because a column of the derived table is derived or constant.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4422, 16, 1, 'View ''%.*ls'' has an INSTEAD OF UPDATE trigger and cannot be a target of an UPDATE FROM statement.', 1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4423, 16, 1, 'View ''%.*ls'' has an INSTEAD OF DELETE trigger and cannot be a target of a DELETE FROM statement.', 1033)


insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
    	(4424,16,0,'Joined tables cannot be specified in a query containing outer join operators. View or function ''%.*ls'' contains joined tables.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4425 ,16 ,0 ,'Cannot specify outer join operators in a query containing joined tables. View or function ''%.*ls'' contains outer join operators.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(4427 ,16 ,0 ,'The view or function ''%.*ls'' is not updatable because the definition contains the TOP clause.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(4428 ,16 ,0 ,'The derived table ''%.*ls'' is not updatable because the definition contains the TOP clause.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(4429 ,16 ,0 ,'View or function ''%.*ls'' contains a self-reference. Views or functions cannot reference themselves directly or indirectly.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(4430,10,0,'Warning: Index hints supplied for view ''%.*ls'' will be ignored.',1033)
GO
backup Transaction master with no_log
GO

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (4431, 16, 0, 'Partitioned view ''%.*ls'' is not updatable because table ''%.*ls'' has a timestamp column.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (4432, 16, 0, 'Partitioned view ''%.*ls'' is not updatable because table ''%.*ls'' has a DEFAULT constraint.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (4433, 16, 0, 'Cannot INSERT into partitioned view ''%.*ls'' because table ''%.*ls'' has an IDENTITY constraint.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (4434, 16, 0, 'Partitioned view ''%.*ls'' is not updatable because table ''%.*ls'' has an INSTEAD OF trigger.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (4435, 16, 0, 'Partitioned view ''%.*ls'' is not updatable because a value was not specified for partitioning column ''%.*ls''.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (4436, 16, 0, 'UNION ALL view ''%.*ls'' is not updatable because a partitioning column was not found.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (4437, 16, 0, 'Partitioned view ''%.*ls'' is not updatable as the target of a bulk operation.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (4438, 16, 0, 'Partitioned view ''%.*ls'' is not updatable because it does not deliver all columns from its member tables.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (4439, 16, 0, 'Partitioned view ''%.*ls'' is not updatable because the source query contains references to partition table ''%.*ls''.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (4440, 16, 0, 'UNION ALL view ''%.*ls'' is not updatable because a primary key was not found on table ''%.*ls''.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (4441, 16, 0, 'Partitioned view ''%.*ls'' is not updatable because the table ''%.*ls'' has an index on a computed column.', 1033)

GO

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (4442, 16, 0, 'UNION ALL view ''%.*ls'' is not updatable because base table ''%.*ls'' is used multiple times.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values 
    (4443, 16, 0, 'UNION ALL view ''%.*ls'' is not updatable because column ''%.*ls'' of base table ''%.*ls'' is used multiple times.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (4444, 16, 0, 'UNION ALL view ''%.*ls'' is not updatable because the primary key of table ''%.*ls'' is not included in the union result.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (4445, 16, 0, 'UNION ALL view ''%.*ls'' is not updatable because the primary key of table ''%.*ls'' is not unioned with primary keys of preceding tables.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (4446, 16, 0, 'UNION ALL view ''%.*ls'' is not updatable because the definiton of column ''%.*ls'' of view ''%.*ls'' is used by another view column.', 1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4447 ,16 ,0 ,'View ''%.*ls'' is not updatable because the definition contains a set operator.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (4448, 16, 0, 'Cannot INSERT into partitioned view ''%.*ls'' because values were not supplied for all columns.', 1033)
go
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4449 ,16 ,0 ,'Using defaults is not allowed in views that contain a set operator.' ,1033)
go

--4450 & 4451 Raid 232164 fix --nigele new 5/31
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (4450, 16, 0, 'Cannot update partitioned view ''%.*ls'' because the definition of the view column ''%.*ls'' in table ''%.*ls'' has a IDENTITY constraint.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (4451, 16, 0, 'Views referencing tables on multiple servers are not updatable on this SKU of SQL Server.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (4452, 16, 0, 'Cannot UPDATE partitioning column ''%.*ls'' of view ''%.*ls'' because the table ''%.*ls'' has a CASCADE DELETE or CASCADE UPDATE constraint.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (4453, 16, 0, 'Cannot UPDATE partitioning column ''%.*ls'' of view ''%.*ls'' because the table ''%.*ls'' has a INSERT, UPDATE or DELETE trigger.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (4454, 16, 0, 'View ''%.*ls'' is not updatable because the %s statement contains a GROUP BY ALL clause.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (4455, 16, 0, 'Derived table ''%.*ls'' is not updatable because the %s statement contains a GROUP BY ALL clause.', 1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4501 ,16 ,0 ,'View or function ''%.*ls'' has more columns defined than column names given.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4502 ,16 ,0 ,'View or function ''%.*ls'' has more column names specified than columns defined.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4505 ,16 ,0 ,'CREATE VIEW failed because column ''%.*ls'' in view ''%.*ls'' exceeds the maximum of %d columns.' ,1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4506 ,10 ,0 ,'Column names in each view or function must be unique. Column name ''%.*ls'' in view or function ''%.*ls'' is specified more than once.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4508 ,16 ,0 ,'Views or functions are not allowed on temporary tables. Table names that begin with ''#'' denote temporary tables.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4509 ,16 ,0 ,'Could not perform CREATE VIEW because WITH %ls was specified and the view contains set operators.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4510 ,16 ,0 ,'Could not perform CREATE VIEW because WITH %ls was specified and the view is not updatable.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4511 ,16 ,0 ,'Create View or Function failed because no column name was specified for column %d.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4512, 16, 1, 'Cannot schema bind %S_MSG ''%.*ls'' because name ''%.*ls'' is invalid for schema binding. Names must be in two-part format and an object cannot reference itself.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4513, 16, 1, 'Cannot schema bind %S_MSG ''%.*ls''. ''%.*ls'' is not schema bound.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4516, 16, 1, 'Cannot schema bind function ''%.*ls'' because it contains an EXECUTE statement.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4514 ,16 ,0 ,'CREATE FUNCTION failed because a column name is not specified for column %d.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4515 ,16 ,0 ,'CREATE FUNCTION failed because column ''%.*ls'' in function ''%.*ls'' exceeds the maximum of %d columns.' ,1033)

GO
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4602 ,14 ,0 ,'Only members of the sysadmin role can grant or revoke the CREATE DATABASE permission.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4604 ,16 ,0 ,'There is no such user or group ''%.*ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4606 ,16 ,0 ,'Granted or revoked privilege %ls is not compatible with object.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4610 ,16 ,0 ,'You can only grant or revoke permissions on objects in the current database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4611 ,16 ,0 ,'To revoke grantable privileges, specify the CASCADE option with REVOKE.' ,1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(4613,16,1,'Grantor does not have GRANT permission.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(4615,16,1,'Invalid column name ''%.*ls''.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(4617,16,1,'Cannot grant, deny or revoke permissions to or from special roles.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(4618,16,1,'You do not have permission to use %.*ls in the AS clause.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(4619,16,1,'CREATE DATABASE permission can only be granted in the master database.',1033)
Go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4701 ,11 ,0 ,'Could not truncate table ''%.*ls'' because this table does not exist in database ''%.*ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4706 ,17 ,0 ,'Could not truncate table ''%.*ls'' because there is not enough room in the log to record the deallocation of all the index and data pages.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4707 ,16 ,0 ,'Could not truncate object ''%.*ls'' because it or one of its indexes resides on a READONLY filegroup.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4708 ,16 ,0 ,'Could not truncate object ''%.*ls'' because it is not a table.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4709 ,16 ,0 ,'You are not allowed to truncate the system table ''%.*ls''.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4711 ,16 ,0 ,'Cannot truncate table ''%.*ls'' because it is published for replication.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4712 ,16 ,0 ,'Cannot truncate table ''%.*ls'' because it is being referenced by a FOREIGN KEY constraint.' ,1033)

GO
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(4803,21,0,'Received invalid row length %d from bcp client. Maximum row size is %d.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4804 ,21 ,0 ,'Premature end-of-message while reading current row from host. Host program may have terminated.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4805 ,17 ,0 ,'The front-end tool you are using does not support the feature of bulk insert from host. Use the proper tools for this command.' ,1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(4807,21,0,'Received invalid row length %d from bcp client. Minimum row size is %d.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
	(4808 , 16 ,0 ,'Bulk copy operations cannot trigger BULK INSERT statements.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4810 ,16 ,0 ,'Expected the TEXT token in data stream for bulk copy of text or image data.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4811 ,16 ,0 ,'Expected the column offset in data stream for bulk copy of text or image data.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4812 ,16 ,0 ,'Expected the row offset in data stream for bulk copy of text or image data.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4813 ,16 ,0 ,'Expected the text length in data stream for bulk copy of text, ntext, or image data.' ,1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(4815,21,0,'Received invalid column length from bcp client.',1033)

insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(4817,16,0,'Could not bulk insert. Invalid sorted column ''%.*ls''. Assuming data stream is not sorted.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(4818,16,0,'Could not bulk insert. Sorted column ''%.*ls'' was specified more than once. Assuming data stream is not sorted.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4819 ,16 ,1 ,'Could not bulk insert. Bulk data stream was incorrectly specified as sorted.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4820,16,0,'Could not bulk insert. Unknown version of format file ''%s''.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4821,16,0,'Could not bulk insert. Error reading the number of columns from format file ''%s''.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4822,16,0,'Could not bulk insert. Invalid number of columns in format file ''%s''.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4823,16,0,'Could not bulk insert. Invalid column number in format file ''%s''.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4824,16,0,'Could not bulk insert. Invalid data type for column number %d in format file ''%s''.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4825,16,0,'Could not bulk insert. Invalid prefix for column number %d in format file ''%s''.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4826,16,0,'Could not bulk insert. Invalid column length for column number %d in format file ''%s''.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4827,16,0,'Could not bulk insert. Invalid column terminator for column number %d in format file ''%s''.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4828,16,0,'Could not bulk insert. Invalid destination table column number for source column %d in format file ''%s''.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4829,16,0,'Could not bulk insert. Error reading destination table column name for source column %d in format file ''%s''.',1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(4830 ,10 ,0 ,'Bulk Insert: DataFileType was incorrectly specified as char. DataFileType will be assumed to be widechar because the data file has a Unicode signature.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(4831 ,10 ,0 ,'Bulk Insert: DataFileType was incorrectly specified as widechar. DataFileType will be assumed to be char because the data file does not have a Unicode signature.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4832 ,16 ,1 ,'Bulk Insert: Unexpected end-of-file (EOF) encountered in data file.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4833 ,16 ,1 ,'Bulk Insert: Version mismatch between the provider dynamic link library and the server executable.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
   (4834 ,16 ,0 ,'You do not have permission to use the BULK INSERT statement.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (4835 ,16 ,0 ,'Bulk copying into a table with computed columns is not supported for downlevel clients.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (4837 ,16 ,0 ,'Error: Cannot bulk copy into a table ''%s'' enabled for immediate-updating subscriptions' ,1033)

--4838 to 4848 added Bulk Data Source messages --Jeffe

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4838,16,1,'The bulk data source does not support the SQLNUMERIC or SQLDECIMAL data types.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4839,16,1,'Cannot perform bulk insert. Invalid collation name for source column %d in format file ''%s''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4840,16,1,'The bulk data source provider string has an invalid %ls property value %ls.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4841,16,1,'The data source name is not a simple object name.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4842,16,1,'The required FormatFile property is missing from the provider string of the server.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4843,16,1,'The bulk data source provider string has a syntax error (''%lc'') near character position %d.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4844,16,1,'The bulk data source provider string has an unsupported property name (%ls).' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4845,16,1,'The bulk data source provider string has a syntax error near character position %d. Expected ''%lc'', but found ''%lc''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4846,16,1,'The bulk data provider failed to allocate memory.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4847,16,1,'Bulk copying into a table with bigint columns is not supported for versions earlier than SQL Server 2000.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4848,16,1,'Bulk copying into a table with sql_variant columns is not supported for versions earlier than SQL Server 2000.' ,1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(4849,16,0,'Could not import table ''%ls''. Error %d.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4850 ,10 ,0 ,'Data import: Table ''%ls'' is already locked by another user.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4851 ,10 ,0 ,'Data import: Table ''%ls'' already has data. Skipping to next table.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4852 ,10 ,0 ,'Data import: Table ''%ls'' does not exist or it is not a user table.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4853 ,10 ,0 ,'%hs' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4854 ,21 ,0 ,'%hs' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(4860, 16, 0, 'Could not bulk insert. File ''%ls'' does not exist.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(4861, 16, 0, 'Could not bulk insert because file ''%ls'' could not be opened. Operating system error code %ls.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(4862, 16, 0, 'Could not bulk insert because file ''%ls'' could not be read. Operating system error code %ls.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(4863, 16, 0, 'Bulk insert data conversion error (truncation) for row %d, column %d (%ls).', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(4864, 16, 0, 'Bulk insert data conversion error (type mismatch) for row %d, column %d (%ls).', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(4865, 16, 0, 'Could not bulk insert because the maximum number of errors (%d) was exceeded.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(4866, 16, 1, 'Bulk Insert fails. Column is too long in the data file for row %d, column %d. Make sure the field terminator and row terminator are specified correctly.', 1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(4867, 16, 0, 'Bulk insert data conversion error (overflow) for row %d, column %d (%ls).', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4868, 16, 1, 'Bulk Insert fails. Codepage ''%d'' is not installed. Install the codepage and run the command again.' ,1033)

go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4869, 16, 1, 'Bulk Insert failed. Unexpected NULL value in data file row %d, column %d. Destination column (%ls) is defined NOT NULL.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4880, 16, 1, 'Could not bulk insert. When using the FIRSTROW and LASTROW parameters, the value for FIRSTROW cannot be greater than the value for LASTROW.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4881 ,10 ,1 ,'Note: Bulk Insert through a view may result in base table default values being ignored for NULL columns in the data file.' ,1033)
go


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4882,16,0,'Could not bulk insert. Prefix length, field length, or terminator required for source column %d in format file ''%s''.',1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4901 ,16 ,0 ,'ALTER TABLE only allows columns to be added that can contain nulls or have a DEFAULT definition specified. Column ''%.*ls'' cannot be added to table ''%.*ls'' because it does not allow nulls and does not specify a DEFAULT definition.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4902 ,11 ,0 ,'Cannot alter table ''%.*ls'' because this table does not exist in database ''%.*ls''.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4909 ,16 ,0 ,'Cannot alter ''%.*ls'' because it is not a table.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4910 ,16 ,0 ,'Only the owner or members of the sysadmin role can alter table ''%.*ls''.' ,1033)

GO

---- These are new messages for alter table, Messages 4912 - 4915


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4916 ,16 ,0 ,'Could not enable or disable the constraint. See previous errors.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4917 ,16 ,0 ,'Constraint ''%.*ls'' does not exist.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(4920 ,16 ,0 ,'ALTER TABLE failed because trigger ''%.*ls'' on table ''%.*ls'' does not exist.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(4921 ,16 ,0 ,'ALTER TABLE failed because trigger ''%.*ls'' does not belong to table ''%.*ls''.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(4922, 16, 1, '%ls %.*ls failed because one or more objects access this column.', 1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(4923 ,16 ,0 ,'ALTER TABLE DROP COLUMN failed because ''%.*ls'' is the only data column in table ''%.*ls''. A table must have at least one data column.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4924 ,16 ,0 ,'%ls failed because column ''%.*ls'' does not exist in table ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4925 ,16 ,0 ,'ALTER TABLE ALTER COLUMN ADD ROWGUIDCOL failed because a column already exists in table ''%.*ls'' with ROWGUIDCOL property.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4926 ,16 ,0 ,'ALTER TABLE ALTER COLUMN DROP ROWGUIDCOL failed because a column does not exist in table ''%.*ls'' with ROWGUIDCOL property.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(4927 ,16 ,0 ,'Cannot alter column ''%.*ls'' to be data type %.*ls.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(4928 ,16 ,0 ,'Cannot alter column ''%.*ls'' because it is ''%ls''.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(4929 ,16 ,0 ,'Cannot alter the %S_MSG ''%.*ls'' because it is being published for replication.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4930 ,10 ,1 ,'Warning: Columns added to the replicated table %S_MSG ''%.*ls'' will be ignored by existing articles.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4931 ,16 ,1 ,'Cannot add columns to %S_MSG ''%.*ls'' because it is being published for merge replication.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(4932,16,1,'ALTER TABLE DROP COLUMN failed because ''%.*ls'' is currently replicated.' ,1033)

GO
raiserror('sysmessages.error>=5000 ....',0,1) with nowait
GO

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5001 ,16 ,0 ,'User must be in the master database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5002 ,16 ,0 ,'Database ''%.*ls'' does not exist. Check sysdatabases.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5004 ,16 ,0 ,'To use ALTER DATABASE, the database must be in a writable state in which a checkpoint can be executed.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5005, 10 ,0 ,'Extending database by %.2f MB on disk ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5006 ,16 ,0 ,'Could not get exclusive use of %S_MSG ''%.*ls'' to perform the requested operation.' ,1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(5008, 16, 1, 'This ALTER DATABASE statement is not supported.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5009 ,16 ,0 ,'ALTER DATABASE failed. Some disk names listed in the statement were not found. Check that the names exist and are spelled correctly before rerunning the statement.' ,1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(5010,16,0,'Log file name cannot be generated from a raw device. The log file name and path must be specified.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5011 ,14 ,0 ,'User does not have permission to alter database ''%.*ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5012 ,16 ,0 ,'The name of the primary filegroup cannot be changed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5013 ,16 ,0 ,'The master and model databases cannot have files added to them. ALTER DATABASE was aborted.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5014 ,16 ,0 ,'The %S_MSG ''%.*ls'' does not exist in database ''%.*ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5015 ,16 ,0 ,'ALTER DATABASE failed. The total size specified must be 1 MB or greater.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5016 ,16 ,0 ,'System databases master, model, and tempdb cannot have their names changed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5017 ,16 ,0 ,'ALTER DATABASE failed.  Database ''%.*ls'' was not created with ''FOR LOAD'' option.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5018 ,0 ,0 ,'File ''%.*ls'' modified in sysaltfiles. Delete old file after restarting SQL Server.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5019 ,10 ,0 ,'Cannot find entry in sysaltfiles for file ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5020 ,16 ,0 ,'The primary data or log file cannot be removed from a database.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5021 ,10 ,0 ,'The %S_MSG name ''%.*ls'' has been set.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(5022,16,0,'Log file ''%ls'' for this database is already active.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(5023,16,0,'Database must be put in bypass recovery mode to rebuild the log.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(5024,16,0,'No entry found for the primary log file in sysfiles1.  Could not rebuild the log.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(5025,16,0,'The file ''%ls'' already exists. It should be renamed or deleted so that a new log file can be created.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(5026,16,0,'Could not create a new log file with file ''%.*ls''. See previous errors.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(5027,16,0,'System databases master, model, and tempdb cannot have their logs rebuilt.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(5028,16,0,'The system could not activate enough of the database to rebuild the log.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (5029,10,0,'Warning: The log for database ''%.*ls'' has been rebuilt. Transactional consistency has been lost. DBCC CHECKDB should be run to validate physical consistency. Database options will have to be reset, and extra log files may need to be deleted.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(5030,16,0,'The database could not be exclusively locked to perform the operation.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(5031,16,1,'Cannot remove the file ''%.*ls'' because it is the only file in the DEFAULT filegroup.', 1033)
GO

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5032 ,10 ,0 ,'The file cannot be shrunk below page %ud until the log is backed up because it contains bulk logged pages.' ,1033)
go

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(5035,16,0,'Filegroup ''%.*ls'' already exists in this database.', 1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(5036,16,0,'MODIFY FILE failed. Specify logical name.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(5037,16,0,'MODIFY FILE failed. Do not specify physical name.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(5038,16,0,'MODIFY FILE failed for file "%.*ls". At least one property per file must be specified.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(5039,16,0,'MODIFY FILE failed. Specified size is less than current size.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(5040,16,0,'MODIFY FILE failed. Size is greater than MAXSIZE.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(5041,16,0,'MODIFY FILE failed. File ''%.*ls'' does not exist.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5042 ,16 ,0 ,'The %S_MSG ''%.*ls'' cannot be removed because it is not empty.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5043 ,16 ,0 ,'The %S_MSG ''%.*ls'' cannot be found in %ls.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (5044 ,10,0 ,'The %S_MSG ''%.*ls'' has been removed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5045 ,16 ,0 ,'The %S_MSG already has the ''%ls'' property set.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (5046 ,10,0 ,'The %S_MSG property ''%ls'' has been set.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5047 ,16 ,0 ,'Cannot change the READONLY property of the PRIMARY filegroup.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5048 ,16 ,0 ,'Cannot add, remove, or modify files in filegroup ''%.*ls''. The filegroup is read-only.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5049 ,16 ,0 ,'Cannot extend file ''%ls'' using this syntax as it was not created with DISK INIT. Use ALTER DATABASE MODIFY FILE.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5050 ,16 ,0 ,'Cannot change the properties of empty filegroup ''%.*ls''. The filegroup must contain at least one file.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5051 ,16 ,0 ,'Cannot have a filegroup with the name ''DEFAULT''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5053 ,16 ,0 ,'The maximum of %ld filegroups per database has been exceeded.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5054 ,16 ,0 ,'Could not cleanup worktable IAM chains to allow shrink or remove file operation.  Please try again when tempdb is idle.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(5055, 16, 0, 'Cannot add, remove, or modify file ''%.*ls''. The file is read-only.' ,1033)


go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5056,16,0,'Cannot add, remove, or modify a file in filegroup ''%.*ls'' because the filegroup is offline.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5057,16,0,'Cannot add, remove, or modify file ''%.*ls'' because it is offline.' ,1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(5058, 16, 1, 'Option ''%.*ls'' cannot be set in database ''%.*ls''.', 1033)


insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(5059, 16, 1, 'Database ''%.*ls'' is in transition. Try the ALTER DATABASE statement later.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(5060, 10, 1, 'Nonqualified transactions are being rolled back. Estimated rollback completion: %d%%.', 1033)


insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(5061, 16, 1, 'ALTER DATABASE failed because a lock could not be placed on database ''%.*ls''. Try again later.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(5062, 16, 1, 'Option ''%.*ls'' cannot be set at the same time as another option setting.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(5063, 16, 1, 'Database ''%.*ls'' is in warm standby. A warm-standby database is read-only.', 1033)



insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(5064, 16, 1, 'Changes to the state or options of database ''%.*ls'' cannot be made at this time. The database is in single-user mode, and a user is currently connected to it.', 1033)


insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(5065, 16, 1, 'Database ''%.*ls'' cannot be opened.', 1033)


insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(5066, 16, 1, 'Database options single user and dbo use only cannot be set at the same time.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(5068, 10, 1, 'Failed to restart the current database. The current database is switched to master.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(5069, 16, 1, 'ALTER DATABASE statement failed.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(5070 ,16 ,0 ,'Database state cannot be changed while other users are using the database ''%.*ls''' ,1033)


go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (5072, 16, 1, 'ALTER DATABASE failed. The default collation of database ''%.*ls'' cannot be set to %.*ls.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (5073, 16, 1, 'Cannot alter collation for database ''%ls'' because it is READONLY, OFFLINE, or marked SUSPECT.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (5074, 16, 1, 'The %S_MSG ''%.*ls'' is dependent on %S_MSG ''%.*ls''.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (5075, 16, 1, 'The %S_MSG ''%.*ls'' is dependent on %S_MSG.', 1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5076 ,10 ,0 ,'Warning: Changing default collation for database ''%.*ls'', which is used in replication. It is recommend that all replication database have the same default collation.' ,1033)

GO

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5101 ,15 ,0 ,'You must supply parameters for the DISK %hs statement. Usage: %hs.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5102 ,15 ,0 ,'No such statement DISK %.*ls.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5103 ,16 ,0 , 'MAXSIZE cannot be less than SIZE for file ''%ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5104 ,16 ,0 ,'File ''%.*ls'' already used.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5105 ,16 ,0 ,'Device activation error. The physical file name ''%.*ls'' may be incorrect.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5106 ,15 ,0 ,'Parameter ''%hs'' requires value of data type ''%hs''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5107 ,15 ,0 ,'Value is wrong data type for parameter ''%hs'' (requires data type ''%hs'').' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5109 ,16 ,0 ,'No such parameter ''%.*ls''.' ,1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(5108,10,0,'Log file ''%.*ls'' does not match the primary file.  It may be from a different database or the log may have been rebuilt previously.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5110 ,16 ,0 ,'File ''%.*ls'' is on a network device not supported for database files.' ,1033)
Go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5116 ,14 ,0 ,'You do not have permission to run DISK statements.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5117 ,16 ,0 ,'Could not run DISK statement. You must be in the master database to run this statement.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5122 ,10 ,0 ,'Each disk file size must be greater than or equal to 1 MB.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5123 ,16 ,0 ,'CREATE FILE encountered operating system error %ls while attempting to open or create the physical file ''%.*ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5126 ,16 ,0 ,'The logical device ''%.*ls'' does not exist in sysdevices.' ,1033)

Go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5146 ,16 ,0 ,'The %hs of %d is out of range. It must be between %d and %d.' ,1033)

---- New messages for expanding devices.
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(5148,16,1,'Could not set the file size to the desired amount. The operating system file size limit may have been reached.',
	1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5149 ,16 ,0 ,'MODIFY FILE encountered operating system error %ls while attempting to expand the physical file.' ,1033)

insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(5150,16,1,'The size of a single log file must not be greater than 2 TB.',
	1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5151,16,0,'The %hs statement is obsolete and no longer supported.' ,1033)
Go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5157 ,16 ,0 ,'I/O error encountered in the writelog system function during backout.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5158 ,10 ,0 ,'Warning: Media in device ''%.*ls'' may have been changed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5159 ,16 ,0 ,'Operating system error %.*ls on device ''%.*ls'' during %ls.' ,1033)

---- These are the new messages for DBCC DBCONTROL (5160-5167)

insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(5160,16,0,'Cannot take ''%.*ls'' offline because the database is in use.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5162 ,16 ,0 ,'Cannot find ''%.*ls'' in sysdatabases.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5163 ,16 ,0 ,'Cannot open ''%.*ls'' to take offline.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5164 ,16 ,0 ,'Usage: DBCC DBCONTROL(dbname,ONLINE|OFFLINE)' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5165 ,16 ,0 ,'Cannot explicitly open or close master database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5167 ,16 ,0 ,'Database ''%.*ls'' is already offline.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5168 ,16 ,0 ,'File ''%.*ls'' is on a network drive, which is not allowed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5169 ,16 ,0 ,'FILEGROWTH cannot be greater than MAXSIZE for file ''%.*ls''.' ,1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(5170,16,0,'Cannot create file ''%ls'' because it already exists.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(5171,16,0,'%.*ls is not a primary database file.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5172 ,16 ,0 ,'The header for file ''%ls'' is not a valid database file header. The %ls property is incorrect.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(5173, 16, 0, 'Cannot associate files with different databases.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5174, 10 ,0 ,'Each file size must be greater than or equal to 512 KB.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5175, 10 ,128 ,'The file ''%.*ls'' has been expanded to prevent recovery from failing. Contact the system administrator for further assistance.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5176, 10 ,128 ,'The file ''%.*ls'' has been expanded beyond its maximum size to prevent recovery from failing. Contact the system administrator for further assistance.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (5177,16,0,'Encountered an unexpected error while checking the sector size for file ''%.*ls''. Check the SQL Server error log for more information.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (5178,16,0,'Cannot use file ''%.*ls'' because it was originally formatted with sector size %d and is now on a device with sector size %d.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (5179,16,0,'Cannot use file ''%.*ls'', which is on a device with sector size %d. SQL Server supports a maximum sector size of 4096 bytes.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (5180 ,22 ,1 ,'Could not open FCB for invalid file ID %d in database ''%.*ls''.' ,1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(5181, 16, 0, 'Could not restart database ''%.*ls''. Reverting back to old status.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (5182, 16, 1, 'New log file ''%.*ls'' was created.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5183,16,0,'File ''%ls'' cannot be created. Use WITH MOVE to specify a usable physical file name.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (5184 ,16 ,0 ,'Cannot use file ''%.*ls'' for clustered server. Only formatted files on which the cluster resource of the server has a dependency can be used.' ,1033)

GO
backup Transaction master with no_log
GO

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(5600,16,0,'The Cross Database Chaining option cannot be set to the specified value on the specified database.', 1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5701 ,10 ,0 ,'Changed database context to ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5702 ,10 ,0 ,'SQL Server is terminating this process.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5703 ,10 ,0 ,'Changed language setting to %.*ls.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5803 ,10 ,0 ,'Unknown config number (%d) in sysconfigures.' ,1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(5804,16,0,'Character set, sort order, or collation cannot be changed because at least one database is not writable.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5805 ,16 ,0 ,'Too few locks specified. Minimum %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5807 ,16 ,0 ,'Recovery intervals above %d minutes not recommended. Use the RECONFIGURE WITH OVERRIDE statement to force this configuration.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5808 ,16 ,0 ,'Ad hoc updates to system catalogs not recommended. Use the RECONFIGURE WITH OVERRIDE statement to force this configuration.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5809 ,16 ,0 ,'Average time slices above %d milliseconds not recommended. Use the RECONFIGURE WITH OVERRIDE statement to force this configuration.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5810 ,16 ,0 ,'Valid values for the fill factor are 0 to 100.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5812 ,14 ,0 ,'You do not have permission to run the RECONFIGURE statement.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5823 ,16 ,0 ,'Cannot reconfigure SQL Server to use sort order ID %d, because the row for that sort order does not exist in syscharsets.' ,1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5828 ,16 ,0 ,'User connections are limited to %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5829 ,16 ,0 ,'The specified user options value is invalid.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5830 ,10 ,0 ,'The default collation for SQL Server has been reconfigured. Restart SQL Server to rebuild the table indexes on columns of character data types.' ,1033)




insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5831,16,0,'Minimum server memory value (%d) must be less than or equal to the maximum value (%d).',1033)

Go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(5904 ,17 ,0 ,'Background checkpoint process suspended until locks are available.' ,1033)
GO
raiserror('sysmessages.error>=6000 ....',0,1) with nowait
GO

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(6001 ,10 ,0 ,'SHUTDOWN is waiting for %d process(es) to complete.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(6002 ,10 ,0 ,'SHUTDOWN is in progress. Log off.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(6004 ,10 ,0 ,'User does not have permission to perform this action.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(6005 ,10 ,0 ,'SHUTDOWN is in progress.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(6006 ,10 ,0 ,'Server shut down by request.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(6007, 10, 0, 'The SHUTDOWN statement cannot be executed within a transaction or by a stored procedure.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(6101 ,16 ,0 ,'Process ID %d is not a valid process ID. Choose a number between 1 and %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(6102 ,14 ,0 ,'User does not have permission to use the KILL statement.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(6103 ,17 ,0 ,'Could not do cleanup for the killed process. Received message %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(6104 ,16 ,0 ,'Cannot use KILL to kill your own process.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(6106 ,16 ,0 ,'Process ID %d is not an active process ID.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(6107 ,14 ,0 ,'Only user processes can be killed.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6108, 16, 1, 'KILL SPID WITH COMMIT/ABORT is not supported by Microsoft SQL Server 2000. Use Microsoft Distributed Transaction Coordinator to resolve distributed transactions.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(6109, 10, 0, 'SPID %d: transaction rollback in progress. Estimated rollback completion: %d%%. Estimated time remaining: %d seconds.', 1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6110, 16, 1, 'The distributed transaction with UOW %s does not exist.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6111, 16, 1, 'Another user has decided a different outcome for the distributed transaction associated with UOW %s.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6112, 16, 1, 'Distributed transaction with UOW %s is in prepared state. Only Microsoft Distributed Transaction Coordinator can resolve this transaction. KILL command failed.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6113, 16, 1, 'The distributed transaction associated with UOW %s is in PREPARE state. Use KILL UOW WITH COMMIT/ABORT syntax to kill the transaction instead.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
        (6114, 16, 1, 'Distributed transaction with UOW %s is being used by another user. KILL command failed.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(6115, 16, 1, 'KILL command cannot be used inside user transactions.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(6116, 16, 1, 'KILL command failed.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(6117, 16, 1, 'There is a connection associated with the distributed transaction with UOW %s. First, kill the connection using KILL SPID syntax.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(6118, 16, 1, 'The distributed transaction associated with UOW %s is not in PREPARED state. Use KILL UOW to kill the transaction instead.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(6119, 10, 0, 'Distributed transaction with UOW %s is rolling back: estimated rollback completion: %d%%, estimated time left %d seconds.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(6120, 16, 1, 'Status report cannot be obtained. Rollback operation for Process ID %d is not in progress.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(6121, 16, 1, 'Status report cannot be obtained. Rollback operation for UOW %s is not in progress.', 1033)

GO
backup Transaction master with no_log
GO


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(6401 ,16 ,0 ,'Cannot roll back %.*ls. No transaction or savepoint of that name was found.' ,1033)

GO

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6600 ,16 ,0 ,'XML error: %.*ls' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
	(6601, 10, 0, 'XML parser returned the error code %d from line number %d, source ''%.*ls''.', 1033)

--leave original, query out on 6602
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
	(6602, 16, 0, 'The error description is ''%.*ls''.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6603 ,16 ,0 ,'XML parsing error: %.*ls' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6604 ,25 ,0 ,'XML stored procedures are not supported in fibers mode.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6605 ,16 ,0 ,'%.*ls: Failed to obtain an IPersistStream interface on the XML text.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6606 ,17 ,0 ,'%.*ls: Failed to save the XML text stream. The server resources may be too low.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6607 ,16 ,0 ,'%.*ls: The value supplied for parameter number %d is invalid.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6608 ,16 ,0 ,'Failed to instantiate class ''%ls''. Make sure Msxml2.dll exists in the SQL Server installation.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6609 ,16 ,0 ,'Column ''%ls'' contains an invalid data type. Valid data types are char, varchar, nchar, nvarchar, text, and ntext.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6610 ,17 ,0 ,'Failed to load Msxml2.dll.' ,1033)

-- 6611 is available

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6612 ,16 ,0 ,'Invalid data type for the column indicated by the parameter ''%ls''. Valid data types are int, bigint, smallint, and tinyint.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6613 ,16 ,0 ,'Specified value ''%ls'' already exists.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6614 ,16 ,0 ,'Value specified for column ''%ls'' is the same for column ''%ls''. An element cannot be its own parent.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6615 ,16 ,0 ,'Invalid data type is specified for column ''%ls''. Valid data types are int, bigint, smallint, and tinyint.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6616 ,16 ,0 ,'Parameter ''%ls'' is required when the parent of the element to be added is missing and must be inserted.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6617 ,16 ,0 ,'The specified edge table has an invalid format. Column ''%ls'' is missing or has an invalid data type.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6618 ,16 ,0 ,'Column ''%ls'' in the specified edge table has an invalid or null value.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6619 ,16 ,0 ,'XML node of type %d named ''%ls'' cannot be created .' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6620 ,16 ,0 ,'XML attribute or element cannot be created for column ''%ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6621 ,16 ,0 ,'XML encoding or decoding error occurred with object name ''%.*ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6622 ,16 ,0 , 'Invalid data type for column ''%ls''. Data type cannot be text, ntext, image, or binary.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6623 ,16 ,0 , 'Column ''%ls'' contains an invalid data type. Valid data types are char, varchar, nchar, and nvarchar.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6624 ,16 ,0 , 'XML document could not be created because server memory is low. Use sp_xml_removedocument to release XML documents.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(6625, 16, 0, 'Could not convert the value for OPENXML column ''%ls'' to sql_variant data type. The value is too long. Change the data type of this column to text, ntext or image.', 1033)

GO 

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6800 ,16 ,0 ,'FOR XML AUTO requires at least one table for generating XML tags. Use FOR XML RAW or add a FROM clause with a table name.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6801 ,16 ,0 ,'FOR XML EXPLICIT requires at least three columns, including the tag column, the parent column, and at least one data column.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6802 ,16 ,0 ,'FOR XML EXPLICIT query contains the invalid column name ''%.*ls''. Use the TAGNAME!TAGID!ATTRIBUTENAME[!..] format where TAGID is a positive integer.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6803 ,16 ,0 ,'FOR XML EXPLICIT requires the first column to hold positive integers that represent XML tag IDs.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6804 ,16 ,0 ,'FOR XML EXPLICIT requires the second column to hold NULL or nonnegative integers that represent XML parent tag IDs.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6805 ,16 ,0 ,'FOR XML EXPLICIT stack overflow occurred. Circular parent tag relationships are not allowed.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6806 ,16 ,0 ,'Undeclared tag ID %d is used in a FOR XML EXPLICIT query.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6807 ,16 ,0 ,'Undeclared parent tag ID %d is used in a FOR XML EXPLICIT query.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6808 ,16 ,0 ,'XML tag ID %d could not be added. The server memory resources may be low.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6809 ,16 ,0 ,'Unnamed column or table names cannot be used as XML identifiers. Name unnamed columns using AS in the SELECT statement.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6810 ,16 ,0 ,'Column name ''%.*ls'' is repeated. The same attribute cannot be generated more than once on the same XML tag.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6811 ,16 ,0 ,'FOR XML is incompatible with COMPUTE expressions.  Remove the COMPUTE expression.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6812 ,16 ,0 ,'XML tag ID %d that was originally declared as ''%.*ls'' is being redeclared as ''%.*ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6813 ,16 ,0 ,'FOR XML EXPLICIT cannot combine multiple occurrences of ID, IDREF, IDREFS, NMTOKEN, and/or NMTOKENS in column name ''%.*ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6814 ,16 ,0 ,'In the FOR XML EXPLICIT clause, ID, IDREF, IDREFS, NMTOKEN, and NMTOKENS require attribute names in ''%.*ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6815 ,16 ,0 ,'In the FOR XML EXPLICIT clause, ID, IDREF, IDREFS, NMTOKEN, and NMTOKENS attributes cannot be hidden in ''%.*ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6816 ,16 ,0 ,'In the FOR XML EXPLICIT clause, ID, IDREF, IDREFS, NMTOKEN, and NMTOKENS attributes cannot be generated as CDATA, XML, or XMLTEXT in ''%.*ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6817 ,16 ,0 ,'FOR XML EXPLICIT cannot combine multiple occurrences of ELEMENT, XML, XMLTEXT, and CDATA in column name ''%.*ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6818 ,16 ,0 ,'In the FOR XML EXPLICIT clause, CDATA attributes must be unnamed in ''%.*ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6819 ,16 ,0 ,'The FOR XML clause is not allowed in a %ls statement.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6820 ,16 ,0 ,'FOR XML EXPLICIT requires column %d to be named ''%ls'' instead of ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6821 ,16 ,0 ,'GROUP BY and aggregate functions are currently not supported with FOR XML AUTO.' ,1033)


-- 6822 & 6823 not used


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6824 ,16 ,0 ,'In the FOR XML EXPLICIT clause, mode ''%.*ls'' in a column name is invalid.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6825 ,16 ,0 ,'ELEMENTS mode requires FOR XML AUTO.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6826 ,16 ,0 ,'Every IDREFS or NMTOKENS column in a FOR XML EXPLICIT query must appear in a separate SELECT clause, and the instances must be ordered directly after the element to which they belong.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6827 ,16 ,0 ,'FOR XML EXPLICIT queries allow only one XMLTEXT column per tag. Column ''%.*ls'' declares another XMLTEXT column that is not permitted.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6828 ,16 ,0 ,'XMLTEXT column ''%.*ls'' must be of a string data type.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6829 ,16 ,0 ,'FOR XML EXPLICIT and RAW modes currently do not support addressing binary data as URLs in column ''%.*ls''. Remove the column, or use the BINARY BASE64 mode, or create the URL directly using the ''dbobject/TABLE[@PK1="V1"]/@COLUMN'' syntax.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6830 ,16 ,0 ,'FOR XML AUTO could not find the table owning the following column ''%.*ls'' to create a URL address for it. Remove the column, or use the BINARY BASE64 mode, or create the URL directly using the ''dbobject/TABLE[@PK1="V1"]/@COLUMN'' syntax.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6831 ,16 ,0 ,'FOR XML AUTO requires primary keys to create references for ''%.*ls''. Select primary keys, or use BINARY BASE64 to obtain binary data in encoded form if no primary keys exist.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6832 ,16 ,0 ,'FOR XML AUTO cannot generate a URL address for binary data if a primary key is also binary.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6833 ,16 ,0 ,'Parent tag ID %d is not among the open tags. FOR XML EXPLICIT requires parent tags to be opened first. Check the ordering of the result set.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6834 ,16 ,0 ,'XMLTEXT field ''%.*ls'' contains an invalid XML document. Check the root tag and its attributes.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6835 ,16 ,0 ,'FOR XML EXPLICIT field ''%.*ls'' can specify the directive HIDE only once.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6836 ,16 ,0 ,'FOR XML EXPLICIT requires attribute-centric IDREFS or NMTOKENS field ''%.*ls'' to precede element-centric IDREFS/NMTOKEN fields.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6837 ,16 ,0 ,'The XMLTEXT document attribute that starts with ''%.*ls'' is too long. Maximum length is %d.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6838 ,16 ,0 ,'Attribute-centric IDREFS or NMTOKENS field not supported on tags having element-centric field ''%.*ls'' of type TEXT/NTEXT or IMAGE.  Either specify ELEMENT on IDREFS/NMTOKENS field or remove the ELEMENT directive.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6839 ,16 ,0 ,'FOR XML EXPLICIT does not support XMLTEXT field on tag ''%.*ls'' that has IDREFS or NMTOKENS fields.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (6840 ,16 ,0 ,'XMLDATA does not support namespace elements or attributes such as ''%.*ls''. Run the SELECT FOR XML statement without XMLDATA or remove the namespace prefix declaration.' ,1033)

GO
raiserror('sysmessages.error>=7000 ....',0,1) with nowait
GO
--- XML messages 
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7000 ,16 ,0 ,'OPENXML document handle parameter must be of data type int.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7001 ,16 ,0 ,'OPENXML flags parameter must be of data type int.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7002 ,16 ,0 ,'OPENXML XPath must be of a string data type, such as nvarchar.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7003 ,16 ,0 ,'Only one OPENXML column can be of type %ls.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7004 ,16 ,0 ,'OPENXML does not support retrieving schema from remote tables, as in ''%.*ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7005 ,16 ,0 ,'OPENXML requires a metaproperty namespace to be declared if ''mp'' is used for another namespace in sp_xml_preparedocument.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7006 ,16 ,0 ,'OPENXML encountered a problem identifying the metaproperty namespace prefix. Consider removing the namespace parameter from the corresponding sp_xml_preparedocument statement.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7007 ,16 ,0 ,'OPENXML encountered unknown metaproperty ''%.*ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7008 ,16 ,0 ,'The OPENXML EDGETABLE is incompatible with the XMLTEXT OVERFLOW flag.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7009 ,16 ,0 ,'OPENXML allows only one metaproperty namespace prefix declaration in sp_xml_preparedocument.' ,1033)

GO

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values (7101, 16, 1, 'You cannot use a text pointer for a table with option ''text in row'' set to ON.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values (7102, 20, 1, 'SQL Server Internal Error. Text manager cannot continue with current statement.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values (7103, 16, 1, 'You cannot set option ''text in row'' for table %s.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7104,16 ,0 ,'Offset or size type is invalid. Must be int or smallint data type.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values (7105, 22, 1, 'Page %S_PGID, slot %d for text, ntext, or image node does not exist.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values (7106, 16, 1, 'You cannot update a blob with a read-only text pointer', 1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values (7107, 16, 1, 'You can have only 1,024 in-row text pointers in one transaction', 1033)
go


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7116 ,16 ,0 ,'Offset %d is not in the range of available text, ntext, or image data.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7122,16 ,0 ,'Invalid text, ntext, or image pointer type. Must be binary(16).' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7123 ,16 ,0 ,'Invalid text, ntext, or image pointer value %hs.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7124 ,16 ,0 ,'The offset and length specified in the READTEXT statement is greater than the actual data length of %ld.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7125 ,16 ,0 ,'The text, ntext, or image pointer value conflicts with the column name specified.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7126 ,16 ,0 ,'The text, ntext, or image pointer value references a data page with an invalid text, ntext, or image status.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7127 ,16 ,0 ,'The text, ntext, or image pointer value references a data page with an invalid timestamp.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7128 ,16 ,0 ,'The text, ntext, or image pointer value references a data page that is no longer allocated.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7130 ,16 ,0 ,'%ls WITH NO LOG is not valid at this time. Use sp_dboption to set the ''select into/bulkcopy'' option on for database ''%.*ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7133 ,16 ,0 ,'NULL textptr (text, ntext, or image pointer) passed to %ls function.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7135 ,16 ,0 ,'Deletion length %ld is not in the range of available text, ntext, or image data.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7137,16,0,'%s is not allowed because the column is being processed by a concurrent snapshot and is being replicated to a non-SQL Server Subscriber or Published in a publication allowing Data Transformation Services (DTS).',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(7138 ,16 ,0 ,'The WRITETEXT statement is not allowed because the column is being replicated with Data Transformation Services (DTS).' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7139 ,16 ,0 ,'Length of text, ntext, or image data (%ld) to be replicated exceeds configured maximum %ld.' ,1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7141 ,16 ,0 ,'Must create orphaned text inside a user transaction.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7142 ,16 ,0 ,'Must drop orphaned text before committing the transaction.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7143 ,16 ,0 ,'Invalid locator de-referenced.' ,1033)

GO
backup Transaction master with no_log
GO

insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(7201,17,4,'Could not execute procedure on remote server ''%.*ls'' because SQL Server is not configured for remote access. Ask your system administrator to reconfigure SQL Server to allow remote access.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(7202,11,2,'Could not find server ''%.*ls'' in sysservers. Execute sp_addlinkedserver to add the server to sysservers.',1033)

insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(7212,16,1,'Could not execute procedure ''%.*ls'' on remote server ''%.*ls''.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(7213,20,2,'Could not set up parameter for remote server ''%.*ls''.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(7214,16,1,'Remote procedure time out of %d seconds exceeded. Remote procedure ''%.*ls'' is canceled.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(7221,16,1,'Could not relay results of procedure ''%.*ls'' from remote server ''%.*ls''.',1033)
GO
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7300,16,1,'OLE DB error trace [%ls].',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7301,16,1,'Could not obtain a required interface from OLE DB provider ''%ls''.',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7302,16,1,'Could not create an instance of OLE DB provider ''%ls''.',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7303,16,1,'Could not initialize data source object of OLE DB provider ''%ls''. %ls',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7304,16,1,'Could not create a new session on OLE DB provider ''%ls''.',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7305,16,1,'Could not create a statement object using OLE DB provider ''%ls''.',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7306,16,1,'Could not open table ''%ls'' from OLE DB provider ''%ls''. %ls',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7307,16,1,'Could not obtain the data source of a session from OLE DB provider ''%ls''. This action must be supported by the provider.',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7310,16,1,'Could not obtain the schema options for OLE DB provider ''%ls''. The provider supports the interface, but returns a failure code when it is used.',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7311,16,1,'Could not obtain the schema rowset for OLE DB provider ''%ls''. The provider supports the interface, but returns a failure code when it is used.',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7312,16,1,'Invalid use of schema and/or catalog for OLE DB provider ''%ls''. A four-part name was supplied, but the provider does not expose the necessary interfaces to use a catalog and/or schema.',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7313,16,1,'Invalid schema or catalog specified for provider ''%ls''.',1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7314,16,1,'OLE DB provider ''%ls'' does not contain table ''%ls''.  The table either does not exist or the current user does not have permissions on that table.',1033)
go

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7315,16,1,'OLE DB provider ''%ls'' contains multiple tables that match the name ''%ls''.',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7316,16,1,'Could not use qualified table names (schema or catalog) with OLE DB provider ''%ls'' because it does not implement required functionality.',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7317,16,1,'OLE DB provider ''%ls'' returned an invalid schema definition.',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7318,16,1,'OLE DB provider ''%ls'' returned an invalid column definition.',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (7319,16,1,'OLE DB provider ''%ls'' returned a ''%ls'' index ''%ls'' with incorrect bookmark ordinal %d.',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7320,16,1,'Could not execute query against OLE DB provider ''%ls''. %ls',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7321,16,1,'An error occurred while preparing a query for execution against OLE DB provider ''%ls''. %ls',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7322,16,1,'A failure occurred while giving parameter information to OLE DB provider ''%ls''. %ls',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7323,16,1,'An error occurred while submitting the query text to OLE DB provider ''%ls''. %ls',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7330,16,1,'Could not fetch a row from OLE DB provider ''%ls''. %ls',1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7331,16,1,'Rows from OLE DB provider ''%ls'' cannot be released. %ls',1033)

go

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7332,16,1,'Could not rescan the result set from OLE DB provider ''%ls''. %ls',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7333,16,1,'Could not fetch a row using a bookmark from OLE DB provider ''%ls''. %ls',1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7340,16,1,'Could not create a column accessor for OLE DB provider ''%ls''. %ls',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7341,16,1,'Could not get the current row value of column ''%ls.%ls'' from the OLE DB provider ''%ls''. %ls',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7342,16,1,'Unexpected NULL value returned for column ''%ls.%ls'' from the OLE DB provider ''%ls''. This column cannot be NULL.',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7343,16,1,'OLE DB provider ''%ls'' could not %ls table ''%ls''. %ls',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7344,16,1,'OLE DB provider ''%ls'' could not %ls table ''%ls'' because of column ''%ls''. %ls',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7345,16,1,'OLE DB provider ''%ls'' could not delete from table ''%ls''. %ls',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7346,16,1,'Could not get the data of the row from the OLE DB provider ''%ls''. %ls',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7347,16,1,'OLE DB provider ''%ls'' returned an unexpected data length for the fixed-length column ''%ls.%ls''. The expected data length is %ls, while the returned data length is %ls.',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (7348,16,1,'OLE DB provider ''%ls'' could not set range for table ''%ls''.%ls',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (7349,16,1,'OLE DB provider ''%ls'' could not set range for table ''%ls'' because of column ''%ls''.%ls',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7350,16,1,'Could not get the column information from the OLE DB provider ''%ls''.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7351,16,1,'OLE DB provider ''%ls'' could not map ordinals for one or more columns of object ''%ls''.',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7352,16,1,'OLE DB provider ''%ls'' supplied inconsistent metadata. The object ''%ls'' was missing expected column ''%ls''.',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7353,16,1,'OLE DB provider ''%ls'' supplied inconsistent metadata. An extra column was supplied during execution that was not found at compile time.',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7354,16,1,'OLE DB provider ''%ls'' supplied invalid metadata for column ''%ls''. %ls',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7355,16,1,'OLE DB provider ''%ls'' supplied inconsistent metadata for a column. The name was changed at execution time.',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7356,16,1,'OLE DB provider ''%ls'' supplied inconsistent metadata for a column. Metadata information was changed at execution time.',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7357,16,1,'Could not process object ''%ls''. The OLE DB provider ''%ls'' indicates that the object has no columns.',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7358,16,1,'Could not execute query. The OLE DB provider ''%ls'' did not provide an appropriate interface to access the text, ntext, or image column ''%ls.%ls''.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7359,16,1,'The OLE DB provider ''%ls'' reported a schema version for table ''%ls'' that changed between compilation and execution.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7360,16,1,'Could not get the length of a storage object from the OLE DB provider ''%ls'' for table ''%ls'', column ''%ls''.',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7361,16,1,'Could not read a storage object from the OLE DB provider ''%ls'', for table ''%ls'', column ''%ls''.',1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7362,16,1,'The OLE DB provider ''%ls'' reported different meta data at run time for table ''%ls'' column ''%ls''.', 1033)


insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7365,16,1,'Could not obtain optional metadata columns of columns rowset from the OLE DB provider ''%ls''.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7366,16,1,'Could not obtain columns rowset from OLE DB provider ''%ls''. The provider supports the interface, but returns a failure code when used.',1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7367,16,1,'The OLE DB provider ''%ls'' supports column-level collation, but failed to provide metadata column ''%ls'' at run time.',1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7368,16,1,'The OLE DB provider ''%ls'' supports column-level collation, but failed to provide collation data for column ''%ls''.',1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7369,16,1,'The OLE DB provider ''%ls'' provided invalid collation. %ls.',1033)
go

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7370,16,1,'One or more properties could not be set on the query for OLE DB provider ''%ls''. %ls',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7371,16,1,'One or more properties could not be set on the table for OLE DB provider ''%ls''.',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7372,16,1,'Cannot get properties from OLE DB provider ''%ls''.',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7373,16,1,'Could not set the initialization properties for the OLE DB provider ''%ls''.',1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7374,16,1,'Could not set the session properties for the OLE DB provider ''%ls''.',1033)


insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (7375,16,1,'Could not open index ''%ls'' on table ''%ls'' from OLE DB provider ''%ls''. %ls',1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (7376, 16, 1, 'Could not enforce the remote join hint for this query.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(7377 ,16 ,0 ,'Cannot specify an index or locking hint for a remote data source.' ,1033)

insert into master..sysmessages (error,severity,dlevel,description,msglangid)
	values
	(7378, 16, 0,'The update/delete operation requires a unique key or a clustered index on the remote table.', 1033)
go

insert into master..sysmessages (error,severity,dlevel,description,msglangid)
    values
    (7379, 16, 0,'OLE DB provider ''%ls'' returned an unexpected ''%ls'' for the decimal/numeric column ''%ls.%ls''. The expected data length is ''%ls'', while the returned data length is ''%ls''.', 1033)
go
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7390,16,1,'The requested operation could not be performed because the OLE DB provider ''%ls'' does not support the required transaction interface.',1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7391,16,1,'The operation could not be performed because the OLE DB provider ''%ls'' was unable to begin a distributed transaction.',1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7392,16,1,'Could not start a transaction for OLE DB provider ''%ls''.',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7393,16,1,'OLE DB provider ''%ls'' reported an error aborting the current transaction.',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7394,16,1,'OLE DB provider ''%ls'' reported an error committing the current transaction.',1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7395,16,1,'Unable to start a nested transaction for OLE DB provider ''%ls''.  A nested transaction was required because the XACT_ABORT option was set to OFF.',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7399,16,1,'OLE DB provider ''%ls'' reported an error. %ls', 1033)
GO
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7401,16,1,'Cannot create OLE DB provider enumeration object installed with SQL Server. Verify installation.',1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7403,16,1,'Could not locate registry entry for OLE DB provider ''%ls''.',1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(7404,16,0,'The server could not load DCOM.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (7405,16,0,'Heterogeneous queries require the ANSI_NULLS and ANSI_WARNINGS options to be set for the connection. This ensures consistent query semantics. Enable these options and then reissue your query.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7410, 16, 1, 'Remote access not allowed for Windows NT user activated by SETUSER.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7411, 16, 1, 'Server ''%.*ls'' is not configured for %ls.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(7413, 16, 0, 'Could not perform a Windows NT authenticated login because delegation is not available.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(7414 ,16 ,0 ,'Invalid number of parameters. Rowset ''%ls'' expects %d parameter(s).' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(7415 ,16 ,0 ,'Ad hoc access to OLE DB provider ''%ls'' has been denied. You must access this provider through a linked server.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(7416 ,16 ,0 ,'Access to the remote server is denied because no login-mapping exists.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(7417, 16, 0,'GROUP BY ALL is not supported in queries that access remote tables if there is also a WHERE clause in the query.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7418,16,1,'Text, image, or ntext column was too large to send to the remote data source due to the storage interface used by the provider.',1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7419,16,1,'Lazy schema validation error. Linked server schema version has changed. Re-run the query.',1033)

GO
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(7601, 16, 0, 'Cannot use a CONTAINS or FREETEXT predicate on %S_MSG ''%.*ls'' because it is not full-text indexed.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(7602, 16, 0, 'The Full-Text Service (Microsoft Search) is not available. The system administrator must start this service.', 1033)



insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7603, 15, 0,
	'Syntax error in search condition, or empty or null search condition ''%ls''.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(7604, 17, 0, 'Full-text operation failed due to a time out.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(7605, 17, 0, 'Full-text catalog ''%ls'' has been lost. Use sp_fulltext_catalog to rebuild and to repopulate this full-text catalog.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(7606, 17, 0, 'Could not find full-text index for database ID %d, table ID %d. Use sp_fulltext_table to deactivate then activate this index.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(7607, 17, 0, 'Search on full-text catalog ''%ls'' for database ID %d, table ID %d with search condition ''%ls'' failed with unknown result (%x).', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(7608, 17, 0, 'An unknown full-text failure (%x) occurred in function %hs on full-text catalog ''%ls''.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(7609, 17, 0,'Full-Text Search is not installed, or a full-text component cannot be loaded.' ,1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7610, 16, 0,
	'Access is denied to ''%ls'', or the path is invalid. Full-text search was not installed properly.', 1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(7611, 10, 0, 'Warning: Request to start a population in full-text catalog ''%ls'' ignored because a population is currently active for this full-text catalog.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(7612, 16, 0, '%d is not a valid value for full-text system resource usage.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(7613, 16, 0, 'Cannot drop index ''%.*ls'' because it enforces the full-text key for table ''%.*ls''.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(7614, 16, 0, 'Cannot alter or drop column ''%.*ls'' because it is enabled for Full-Text Search.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(7615, 16, 0, 'A CONTAINS or FREETEXT predicate can only operate on one table. Qualify the use of * with a table name.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(7616, 16, 0, 'Full-Text Search is not enabled for the current database. Use sp_fulltext_database to enable full-text search for the database.', 1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(7617, 16, 0,'Query does not reference the full-text indexed table.', 1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(7618, 16, 0, '%d is not a valid value for a full-text connection time out.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
    (7619, 16, 0, 'Execution of a full-text operation failed. %ls', 1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(7620, 16, 0, 'Conversion to data type %ls failed for full-text search key value 0x%ls.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(7621, 16, 0, 'Invalid use of full-text predicate in the HAVING clause.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
    (7622, 17, 0, 'Full-text catalog ''%ls'' lacks sufficient disk space to complete this operation.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
    (7623, 17, 0, 'Full-text query failed because full-text catalog ''%ls'' is not yet ready for queries.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
    (7624, 17, 0, 'Full-text catalog ''%ls'' is in a unusable state. Drop and re-create this full-text catalog.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7625 ,16 ,0 ,'Full-text table has more than one LCID among its full-text indexed columns.' ,1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7626, 15, 0,'The top_n_by_rank argument (''%d'') must be greater than zero.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7627, 16, 0,'Full-text catalog in directory ''%ls'' for clustered server cannot be created. Only directories on a disk in the cluster group of the server can be used.', 1033)


insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7628, 17, 0,'Cannot copy Schema.txt to ''%.*ls'' because access is denied or the path is invalid. Full-text search was not installed properly.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7629, 17, 0,'Cannot open or query registry key ''%.*ls''.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7630, 15, 0,'Syntax error occurred near ''%.*ls'' in search condition ''%.*ls''.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7631, 15, 0,'Syntax error occurred near ''%.*ls''. Expected ''%.*ls'' in search condition ''%.*ls''.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7632, 15, 0,'The value of the Weight argument must be between 0.0 and 1.0.', 1033)

go

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7633, 15, 0,'The syntax <content search condition> OR NOT <content boolean term> is not allowed.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7634, 17, 0,'Stack overflow occurred in parsing search condition ''%.*ls''.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7635, 16, 0, 'The Microsoft Search service cannot be administered under the present user account', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
values
	(7636, 10, 0, 'Warning: Request to start a full-text index population on table ''%ls'' is ignored because a population is currently active for this table.', 1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
values
	(7637, 16, 0, 'Value %d is not valid for full-text data time-out.', 1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
values
	(7638, 10, 0, 'Warning: Request to stop change tracking has deleted all changes tracked on table ''%ls''.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7639, 16, 0,'Cannot use a full-text predicate on %S_MSG ''%.*ls'' because it is not located on the local server.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
values
	(7640, 10, 0, 'Warning: Request to stop tracking changes on table ''%ls'' will not stop population currently in progress on the table.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
values
	(7641, 16, 0, 'Full-Text catalog ''%ls'' does not exist.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
values
	(7642, 16, 0, 'A full-text catalog named ''%ls'' already exists in this database.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7643 ,16 ,0 ,'Your search generated too many results. Please perform a more specific search.' ,1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(7905, 16, 1,'The object specified is neither a table nor a constraint', 1033)
go


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7908 ,10 ,0 ,'The table ''%.*ls'' was created with the NO_LOG option.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7910 ,10 ,1 ,'Repair: Page %S_PGID has been allocated to object ID %d, index ID %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7911 ,10 ,1 ,'Repair: Page %S_PGID has been deallocated from object ID %d, index ID %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7912 ,10 ,1 ,'Repair: Extent %S_PGID has been allocated to object ID %d, index ID %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7913 ,10 ,1 ,'Repair: Extent %S_PGID has been deallocated from object ID %d, index ID %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7914 ,10 ,1 ,'Repair: %ls page at %S_PGID has been rebuilt.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7915 ,10 ,1 ,'Repair: IAM chain for object ID %d, index ID %d, has been truncated before page %S_PGID and will be rebuilt.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7916 ,10 ,1 ,'Repair: Deleted record for object ID %d, index ID %d, on page %S_PGID, slot %d. Indexes will be rebuilt.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7917 ,10 ,1 ,'Repair: Converted forwarded record for object ID %d, index ID %d, at page %S_PGID, slot %d to a data row.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7918 ,10 ,1 ,'Repair: Page %S_PGID next and %S_PGID previous pointers have been set to match each other in object ID %d, index ID %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7919 ,16 ,1 ,'Repair statement not processed. Database needs to be in single user mode.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7920 ,10 ,2 ,'Processed %ld entries in sysindexes for database ID %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7922 ,16 ,0 ,'***************************************************************' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7923 ,10 ,1 ,'Table %.*ls                Object ID %ld.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7924 ,16 ,0 ,'Index ID %ld. FirstIAM %S_PGID. Root %S_PGID. Dpages %ld.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7925 ,16 ,0 ,'Index ID %d. %ld pages used in %ld dedicated extents.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7927 ,16 ,0 ,'Total number of extents is %ld.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7932 ,16 ,0 ,'The indexes for ''%.*ls'' are already correct. They will not be rebuilt.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7933 ,16 ,0 ,'One or more indexes contain errors. They will be rebuilt.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7934 ,16 ,0 ,'The table ''%.*ls'' has no indexes.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7935 ,16 ,0 ,'REINDEX received an exception. Statement terminated.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7937 ,16 ,0 ,'The data in table ''%.*ls'' is possibly inconsistent. REINDEX terminated. Run DBCC CHECKTABLE and report errors to your system administrator.' ,1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(7939,16,0,'Cannot detach database ''%.*ls'' because it does not exist.',1033)



insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(7940,16,0,'System databases master, model, msdb, and tempdb cannot be detached.',1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7941 ,10 ,1 ,'Trace option(s) not enabled for this connection. Use ''DBCC TRACEON()''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7942 ,10 ,1 ,'DBCC %ls scanning ''%.*ls'' table...' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7943 ,10 ,1 ,'Table: ''%.*ls'' (%d); index ID: %d, database ID: %d' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7944 ,10 ,1 ,'%ls level scan performed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7945 ,10 ,1 ,'- Pages Scanned................................: %lu' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7946 ,10 ,1 ,'- Extents Scanned..............................: %lu' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7947 ,10 ,1 ,'- Extent Switches..............................: %lu' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7948 ,10 ,1 ,'- Avg. Pages per Extent........................: %3.1f' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7949 ,10 ,1 ,'- Scan Density [Best Count:Actual Count].......: %4.2f%ls [%lu:%lu]' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7950 ,10 ,1 ,'- Logical Scan Fragmentation ..................: %4.2f%ls' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7951 ,10 ,1 ,'- Physical Scan Fragmentation .................: %4.2f%ls' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7952 ,10 ,1 ,'- Extent Scan Fragmentation ...................: %4.2f%ls' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7953 ,10 ,1 ,'- Avg. Bytes Free per Page.....................: %3.1f' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7954 ,10 ,1 ,'- Avg. Page Density (full).....................: %4.2f%ls' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7955 ,10 ,1 ,'Invalid SPID %d specified.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7956 ,10 ,1 ,'Permission to execute DBCC %ls denied.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7957 ,10 ,1 ,'Cannot display the specified SPID''s buffer; in transition.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7958 ,10 ,1 ,'The specified SPID does not process input/output data streams.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7959 ,10 ,1 ,'The DBCC statement is not supported in this release.' ,1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7961 ,16 ,1 ,'Object ID %d, index ID %d, page ID %S_PGID, row ID %d. Column ''%.*ls'' is a var column with a NULL value and non-zero data length.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7962 ,16 ,0 ,'Upgrade requires SQL Server to be started in single user mode. Restart SQL Server with the -m flag.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7963 ,16 ,0 ,'Upgrade encountered a fatal error. See the SQL Server errorlog for more information.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7965 ,16 ,1 ,'Table error: Could not check object ID %d, index ID %d due to invalid allocation (IAM) page(s).' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7966 ,10 ,1 ,'Warning: NO_INDEX option of %ls being used. Checks on non-system indexes will be skipped.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7968 ,10 ,1 ,'Transaction information for database ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7969 ,10 ,0 ,'No active open transactions.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7970 ,10 ,0 ,'%hsOldest active transaction:' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7971 ,10 ,0 ,'    SPID (server process ID) : %d' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7972 ,10 ,0 ,'    UID (user ID) : %d' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7974 ,10 ,0 ,'    Name          : %.*ls' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7975 ,10 ,1 ,'    LSN           : (%d:%d:%d)' ,1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7977 ,10 ,1 ,'    Start time    : %.*ls' ,1033)




insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7979 ,10 ,0 ,'%hsReplicated Transaction Information:' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7980 ,10 ,1 ,'        Oldest distributed LSN     : (%d:%d:%d)' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7982 ,10 ,1 ,'        Oldest non-distributed LSN : (%d:%d:%d)' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7983 ,14 ,0 ,'User ''%.*ls'' does not have permission to run DBCC %ls for database ''%.*ls''.' ,1033)


Go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7984 ,16 ,0 ,'Invalid object name ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7985 ,16 ,0 ,'The object name ''%.*ls'' contains more than the maximum number of prefixes. The maximum is %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7986 ,16 ,0 ,'Warning: Pinning tables should be carefully considered. If a pinned table is larger, or grows larger, than the available data cache, the server may need to be restarted and the table unpinned.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7991 ,16 ,1 ,'System table mismatch: Table ''%.*ls'', object ID %d has index ID 1 in sysindexes but the status in sysobjects does not have the clustered bit set. The table will be checked as a heap.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7992 ,16 ,1 ,'Cannot shrink ''read only'' database ''%.*ls''.' ,1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(7993,10,0,'Cannot shrink file ''%d'' in database ''%.*ls'' to %d pages as it only contains %d pages.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7994 ,16 ,1 ,'Object ID %d, index ID %d: FirstIAM field in sysindexes is %S_PGID. FirstIAM for statistics only and dummy index entries should be (0:0).' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (7995 ,16 ,1 ,'Database ''%ls'' consistency errors in sysobjects, sysindexes, syscolumns, or systypes prevent further %ls processing.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7996 ,16 ,0 ,'Extended stored procedures can only be created in the master database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7997 ,16 ,0 ,'''%.*ls'' does not contain an identity column.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7998 ,16 ,0 ,'Checking identity information: current identity value ''%.*hs'', current column value ''%.*hs''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(7999 ,16 ,0 ,'Could not find any index named ''%.*ls'' for table ''%.*ls''.' ,1033)
GO
backup Transaction master with no_log
GO

raiserror('sysmessages.error>=8000 ....',0,1) with nowait

GO
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8101 ,16 ,0 ,'An explicit value for the identity column in table ''%.*ls'' can only be specified when a column list is used and IDENTITY_INSERT is ON.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8102 ,16 ,0 ,'Cannot update identity column ''%.*ls''.' ,1033)

Go
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8103 ,16 ,0 ,'Table ''%.*ls'' does not exist or cannot be opened for SET operation.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8104 ,16 ,0 ,'The current user is not the database or object owner of table ''%.*ls''. Cannot perform SET operation.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8105 ,16 ,0 ,'''%.*ls'' is not a user table. Cannot perform SET operation.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8106 ,16 ,0 ,'Table ''%.*ls'' does not have the identity property. Cannot perform SET operation.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8107 ,16 ,0 ,'IDENTITY_INSERT is already ON for table ''%.*ls.%.*ls.%.*ls''. Cannot perform SET operation for table ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8108 ,16 ,0 ,'Cannot add identity column, using the SELECT INTO statement, to table ''%.*ls'', which already has column ''%.*ls'' that inherits the identity property.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8109 ,16 ,0 ,'Attempting to add multiple identity columns to table ''%.*ls'' using the SELECT INTO statement.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8110 ,16 ,0 ,'Cannot add multiple PRIMARY KEY constraints to table ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8111 ,16 ,0 ,'Cannot define PRIMARY KEY constraint on nullable column in table ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8112 ,16 ,0 ,'Cannot add more than one clustered index for constraints on table ''%.*ls''.' ,1033)

---- New messages for exact numeric data types (8114-8117).


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8114 ,16 ,0 ,'Error converting data type %ls to %ls.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8115 ,16 ,0 ,'Arithmetic overflow error converting %ls to data type %ls.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8116 ,16 ,0 ,'Argument data type %ls is invalid for argument %d of %ls function.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8117 ,16 ,0 ,'Operand data type %ls is invalid for %ls operator.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8118 ,16 ,0 ,'Column ''%.*ls.%.*ls'' is invalid in the select list because it is not contained in an aggregate function and there is no GROUP BY clause.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8119 ,16 ,0 ,'Column ''%.*ls.%.*ls'' is invalid in the HAVING clause because it is not contained in an aggregate function and there is no GROUP BY clause.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8120 ,16 ,0 ,'Column ''%.*ls.%.*ls'' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8121 ,16 ,0 ,'Column ''%.*ls.%.*ls'' is invalid in the HAVING clause because it is not contained in either an aggregate function or the GROUP BY clause.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8122 ,16 ,0 ,'Only the first query in a UNION statement can have a SELECT with an assignment.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8123 ,16 ,0 ,'A correlated expression is invalid because it is not in a GROUP BY clause.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8124 ,16 ,0 ,'Multiple columns are specified in an aggregated expression containing an outer reference. If an expression being aggregated contains an outer reference, then that outer reference must be the only column referenced in the expression.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8125 ,16 ,0 ,'An aggregated expression containing an outer reference must be contained in either the select list, or a HAVING clause subquery in the query whose FROM clause contains the table with the column being aggregated.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8126 ,16 ,0 ,'Column name ''%.*ls.%.*ls'' is invalid in the ORDER BY clause because it is not contained in an aggregate function and there is no GROUP BY clause.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8127 ,16 ,0 ,'Column name ''%.*ls.%.*ls'' is invalid in the ORDER BY clause because it is not contained in either an aggregate function or the GROUP BY clause.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(8128 ,10 ,0 , 'Using ''%s'' version ''%s'' to execute extended stored procedure ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8129 ,16 ,0 ,'The new disk size must be greater than %d. Consider using DBCC SHRINKDB.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8130 ,16 ,0 ,'The device is not a database device. Only database devices can be expanded.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(8131, 10, 0, 'Extended stored procedure DLL ''%s'' does not export __GetXpVersion(). Refer to the topic "Backward Compatibility Details (Level 1) - Open Data Services" in the documentation for more information.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(8132, 10, 0, 'Extended stored procedure DLL ''%s'' reports its version is %d.%d. Server expects version %d.%d.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8133 ,16 ,0 ,'None of the result expressions in a CASE specification can be NULL.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8134 ,16 ,0 ,'Divide by zero error encountered.' ,1033)


---- These are new messages for ADD CONSTRAINT, Messages 8135 - 8153

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8135 ,16 ,0 ,'Table level constraint does not specify column list, table ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8136 ,16 ,0 ,'Duplicate columns specified in %ls constraint key list, table ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8138 ,16 ,0 ,'More than 16 columns specified in foreign key column list, table ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8139 ,16 ,0 ,'Number of referencing columns in foreign key differs from number of referenced columns, table ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8140 ,16 ,0 ,'More than one key specified in column level %ls constraint, table ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8141 ,16 ,0 ,'Column %ls constraint for column ''%.*ls'' references another column, table ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8142 ,16 ,0 ,'Subqueries are not supported in %ls constraints, table ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8143 ,16 ,0 ,'Parameter ''%.*ls'' was supplied multiple times.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8144 ,16 ,0 ,'Procedure or function %.*ls has too many arguments specified.' ,1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8145 ,16 ,0 ,'%.*ls is not a parameter for procedure %.*ls.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8146 ,16 ,0 ,'Procedure %.*ls has no parameters and arguments were supplied.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8147 ,16 ,0 ,'Could not create IDENTITY attribute on nullable column ''%.*ls'', table ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8148 ,16 ,0 ,'More than one column %ls constraint specified for column ''%.*ls'', table ''%.*ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (8149, 16, 0, 'OLE Automation objects are not supported in fiber mode.', 1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8150 ,16 ,0 ,'Multiple NULL constraints were specified for column ''%.*ls'', table ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8151 ,16 ,0 ,'Both a PRIMARY KEY and UNIQUE constraint have been defined for column ''%.*ls'', table ''%.*ls''. Only one is allowed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8152 ,16 ,0 ,'String or binary data would be truncated.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8153 ,0 ,0 ,'Warning: Null value is eliminated by an aggregate or other SET operation.',1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8154 ,15 ,0 ,'The table ''%.*ls'' is ambiguous.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8155 ,15 ,0 ,'No column was specified for column %d of ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8156 ,15 ,0 ,'The column ''%.*ls'' was specified multiple times for ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8157 ,15 ,0 ,'All the queries in a query expression containing a UNION operator must have the same number of expressions in their select lists.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8158 ,15 ,0 ,'''%.*ls'' has more columns than were specified in the column list.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8159 ,15 ,0 ,'''%.*ls'' has fewer columns than were specified in the column list.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8160 ,15 ,0 ,'A grouping function can only be specified when either CUBE or ROLLUP is specified in the GROUP BY clause.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8161 ,15 ,0 ,'A grouping function argument does not match any of the expressions in the GROUP BY clause.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8162 ,16 ,0 ,'Formal parameter ''%.*ls'' was defined as OUTPUT but the actual parameter not declared OUTPUT.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8163 ,16 ,0 ,'The text, ntext, or image data type cannot be selected as DISTINCT.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8164 ,16 ,0 ,'An INSERT EXEC statement cannot be nested.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (8165 ,16 ,0 ,'Invalid subcommand value %d. Legal range from %d to %d.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8166 ,16 ,0 ,'Constraint name ''%.*ls'' not permitted. Constraint names cannot begin with a number sign (#).' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(8168 ,16 ,0 ,'Cannot create two constraints named ''%.*ls''. Duplicate constraint names are not allowed.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(8169, 16, 0, 'Syntax error converting from a character string to uniqueidentifier.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(8170, 16, 0, 'Insufficient result space to convert uniqueidentifier value to char.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8171 ,16 ,0 ,'Hint ''%ls'' on object ''%.*ls'' is invalid.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8175 ,10 ,0 ,'Could not find table %.*ls. Will try to resolve this table name later.' , 1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8176, 16, 0,'Resync procedure expects value of key ''%.*ls'', which was not supplied.', 1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(8177, 16, 0, 'Cannot use a column in the %hs clause unless it is contained in either an aggregate function or the GROUP BY clause.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8178 ,16 ,0 ,'Prepared statement ''%.*ls'' expects parameter %.*ls, which was not supplied.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8179,16 ,0 ,'Could not find prepared statement with handle %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8180 ,16 ,0 ,'Statement(s) could not be prepared.',1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(8181 ,16 ,0 ,'Text for ''%.*ls'' is missing from syscomments. The object must be dropped and re-created before it can be used.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8183, 16, 1, 'Only UNIQUE or PRIMARY KEY constraints are allowed on computed columns.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8184 ,16 ,1 ,'Error expanding ''*'': all columns incomparable, ''*'' expanded to zero columns.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8185 ,16 ,1 , 'Error expanding ''*'':  An uncomparable column has been found in an underlying table or view.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8186 ,16 ,1 , 'Function ''%.*ls'' can be used only on user and system tables.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(8190,16,1,'Cannot compile replication filter procedure without defining table being filtered.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(8191,16,1,'Replication filter procedures can only contain SELECT, GOTO, IF, WHILE, RETURN, and DECLARE statements.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(8192,16,1,'Replication filter procedures cannot have parameters.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(8193,16,1,'Cannot execute a procedure marked FOR REPLICATION.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(8194,16,1,'Cannot execute a USE statement while an application role is active.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8196 ,16 ,0 ,'Duplicate column specified as ROWGUIDCOL.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8197, 16, 1, 'Windows NT user ''%.*ls'' does not have server access.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(8198, 16, 1, 'Could not obtain information about Windows NT group/user ''%ls''.', 1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(8199,16,0,'In EXECUTE <procname>, procname can only be a literal or variable of type char, varchar, nchar, or nvarchar.',1033)

---- messages for backup table

GO

---- Load Table messages
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8501 ,16 ,0 ,'MSDTC on server ''%.*ls'' is unavailable.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8502 ,20 ,0 ,'Unknown MSDTC token ''0x%x'' received.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8504 ,20 ,0 ,'Invalid transaction import buffer.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8506 ,20 ,0 ,'Invalid transaction state change requested from %hs to %hs.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8508 ,20 ,0 ,'QueryInterface failed for ''%hs'': %hs.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8509 ,20 ,0 ,'Import of MSDTC transaction failed: %hs.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8510 ,20 ,0 ,'Enlist of MSDTC transaction failed: %hs.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8511 ,20 ,0 ,'Unknown isolation level %d requested from MSDTC.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8512 ,20 ,0 ,'MSDTC Commit acknowledgement failed: %hs.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8513 ,20 ,0 ,'MSDTC Abort acknowledgement failed: %hs.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8514 ,20 ,0 ,'MSDTC PREPARE acknowledgement failed: %hs.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8515 ,20 ,0 ,'MSDTC Global state is invalid.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8517 ,20 ,0 ,'Failed to get MSDTC PREPARE information: %hs.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8518 ,20 ,0 ,'MSDTC BEGIN TRANSACTION failed: %hs.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8519 ,16 ,0 ,'Current MSDTC transaction must be committed by remote client.' ,1033)

Go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8520 ,20 ,0 ,'Commit of internal MSDTC transaction failed: %hs.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8521 ,20 ,0 ,'Invalid awakening state. Slept in %hs; awoke in %hs.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8522 ,20 ,0 ,'Distributed transaction aborted by MSDTC.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8523 ,15 ,0 ,'PREPARE TRAN statement not allowed on MSDTC transaction.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8524 ,16 ,0 ,'The current transaction could not be exported to the remote provider. It has been rolled back.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
       (8525,16,1,'Distributed transaction completed. Either enlist this session in a new transaction or the NULL transaction.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8526, 16, 0, 'Cannot go remote while the session is enlisted in a distributed transaction that has an active savepoint.', 1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (8601, 17, 0,'Internal Query Processor Error: The query processor could not obtain access to a required interface.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
	(8602 ,16 ,0 ,'Indexes used in hints must be explicitly included by the index tuning wizard.' ,1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
	(8616 ,10 ,0 ,'The index hints for table ''%.*ls'' were ignored because the table was considered a fact table in the star join.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (8617, 17, 0,'Invalid Query: CUBE and ROLLUP cannot compute distinct aggregates.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (8618, 17, 0,'Warning: The query processor could not produce a query plan from the optimizer because the total length of all the columns in the GROUP BY or ORDER BY clause exceeds 8000 bytes.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (8619, 17, 0,'Warning: The query processor could not produce a query plan from the optimizer because the total length of all the columns in the GROUP BY or ORDER BY clause exceeds 8000 bytes.  Resubmit your query without the ROBUST PLAN hint.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (8620, 17, 0,'Internal Query Processor Error: The query processor encountered an internal limit overflow.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (8621, 16, 0,'Internal Query Processor Error: The query processor ran out of stack space during query optimization.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (8622, 16, 0,'Query processor could not produce a query plan because of the hints defined in this query. Resubmit the query without specifying any hints and without using SET FORCEPLAN.',1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (8623, 16, 0,'Internal Query Processor Error: The query processor could not produce a query plan.  Contact your primary support provider for more information.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8624 ,16 ,0 ,'Internal SQL Server error.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (8625, 16, 0,'Warning: The join order has been enforced because a local join hint is used.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (8626, 16, 0,'Only text pointers are allowed in work tables, never text, ntext, or image columns. The query processor produced a query plan that required a text, ntext, or image column in a work table.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (8627, 16, 0,'The query processor could not produce a query plan because of the combination of hints and text, ntext, or image data passing through operators using work tables.', 1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(8628,17,0,'A time out occurred while waiting to optimize the query. Rerun the query.',
	1033)

insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(8629,16, 0,'The query processor could not produce a query plan from the optimizer because a query cannot update a text, ntext, or image column and a clustering key at the same time.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (8630, 17, 0,'Internal Query Processor Error: The query processor encountered an unexpected error during execution.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (8640, 17, 0,'Internal Query Processor Error: The query processor encountered an unexpected work table error during execution.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (8642, 17, 0,'The query processor could not start the necessary thread resources for parallel query execution.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (8644, 16, 0,'Internal Query Processor Error: The plan selected for execution does not support the invoked given execution routine.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (8645, 17, 0,'A time out occurred while waiting for memory resources to execute the query. Rerun the query.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    (8646 ,21 ,0 ,' The index entry for row ID %.*hs was not found in index ID %d, of table %d, in database ''%.*ls''.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    (8647 ,20 ,0 ,'Scan on sysindexes for database ID %d, object ID %ld, returned a duplicate index ID %d. Run DBCC CHECKTABLE on sysindexes.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(8648, 20, 0, 'Could not insert a row larger than the page size into a hash table. Resubmit the query with the ROBUST PLAN hint.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(8649, 17, 0,'The query has been canceled because the estimated cost of this query (%d) exceeds the configured threshold of %d. Contact the system administrator.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
	(8650 ,13 ,0 ,'Intra-query parallelism caused your server command (process ID #%d) to deadlock. Rerun the query without intra-query parallelism by using the query hint option (maxdop 1).' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    (8651, 17, 0, 'Could not perform the requested operation because the minimum query memory is not available. Decrease the configured value for the ''min memory per query'' server configuration option.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (8653, 17, 0,'Warning: The query processor is unable to produce a plan because the table ''%.*ls'' is marked OFFLINE.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8654 ,16 ,1 ,'A cursor plan could not be generated for the given statement because it contains textptr ( inrow lob ).' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (8660 ,16 ,0 ,'An index cannot be created on the view ''%.*ls'' because the view definition does not include all the columns in the GROUP BY clause.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (8661 ,16 ,0 ,'A clustered index cannot be created on the view ''%.*ls'' because the index key includes columns which are not in the GROUP BY clause.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (8662 ,16 ,0 , 'An index cannot be created on the view ''%.*ls'' because the view definition includes an unknown value (the sum of a nullable expression).' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (8663 ,16 ,0 ,'An index cannot be created on the view ''%.*ls'' because the view definition does not include count_big(*).' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (8664 ,16 ,0 ,'An index cannot be created on the view ''%.*ls'' because the view definition includes duplicate column names.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (8665,16 ,0 ,'An index cannot be created on the view ''%.*ls'' because no row can satisfy the view definition.' ,1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
	(8666,10 ,0 ,'Warning: The optimizer cannot use the index because the select list of the view contains a non-aggregate expression.' ,1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
	(8667,10 ,0 ,'Warning: The optimizer cannot use the index because the group-by list in the view forms a key and is redundant.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (8668,16 ,0 ,'An index cannot be created on the view ''%.*ls'' because the select list of the view contains a non-aggregate expression.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (8669,16 ,0 ,'The indexed view ''%.*ls'' is not updatable.' ,1033)

go

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (8680, 17, 0,'Internal Query Processor Error: The query processor encountered an unexpected error during the processing of a remote query phase.', 1033)
GO
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8901 ,13 ,2 ,'Deadlock detected during DBCC. Complete the transaction in progress and retry this statement.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8902 ,17 ,1 ,'Memory allocation error during DBCC processing.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8903 ,16 ,1 ,'Extent %S_PGID in database ID %d is allocated in both GAM %S_PGID and SGAM %S_PGID.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8904 ,16 ,1 ,'Extent %S_PGID in database ID %d is allocated by more than one allocation object.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8905 ,16 ,1 ,'Extent %S_PGID in database ID %d is marked allocated in the GAM, but no SGAM or IAM has allocated it.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8906 ,16 ,1 ,'Page %S_PGID in database ID %d is allocated in the SGAM %S_PGID and PFS %S_PGID, but was not allocated in any IAM. PFS flags ''%hs''.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8908 ,16 ,1 ,'Table error: Database ID %d, object ID %d, index ID %d. Chain linkage mismatch. %S_PGID->next = %S_PGID, but %S_PGID->prev = %S_PGID.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8909 ,16 ,1 ,'Table error: Object ID %d, index ID %d, page ID %S_PGID. The PageId in the page header = %S_PGID.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8910 ,16 ,1 ,'Page %S_PGID in database ID %d is allocated to both object ID %d, index ID %d, and object ID %d, index ID %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8911 ,10 ,1 ,'        The error has been repaired.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8912, 10, 1, '%.*ls fixed %d allocation errors and %d consistency errors in database ''%ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8913 ,16 ,1 ,'Extent %S_PGID is allocated to ''%ls'' and at least one other object.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (8914, 10, 1, 'Incorrect PFS free space information for page %S_PGID, object ID %d, index ID %d, in database ID %d. Expected value %hs, actual value %hs.', 1033)


insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(8915,10,1,'           File %d (number of mixed extents = %ld, mixed pages = %ld).',1033)


insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(8916,10,1,'    Object ID %ld, Index ID %ld, data extents %ld, pages %ld, mixed extent pages %ld.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(8917,10,1,'    Object ID %ld, Index ID %ld, index extents %ld, pages %ld, mixed extent pages %ld.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(8918,10,1,'       (number of mixed extents = %ld, mixed pages = %ld) in this database.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(8919,16,1,'Single page allocation %S_PGID in table %ls, object ID %d, index ID %d is not allocated in PFS page ID %S_PGID.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(8920,16,1,'Cannot perform a %ls operation inside a user transaction. Terminate the transaction and reissue the statement.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(8921,16,1,'CHECKTABLE terminated. A failure was detected while collecting facts. Possibly tempdb out of space or a system table is inconsistent. Check previous errors.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8922 ,10 ,1 ,'        Could not repair this error. ' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8923 ,10 ,1 ,'        The repair level on the DBCC statement caused this repair to be bypassed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8924 ,10 ,1 ,'        Repairing this error requires other errors to be corrected first.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8925, 16, 1, 'Table error: Cross object linkage: Page %S_PGID, slot %d, in object ID %d, index ID %d, refers to page %S_PGID, slot %d, in object ID %d, index ID %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8926, 16, 1, 'Table error: Cross object linkage: Parent page %S_PGID, slot %d, in object ID %d, index ID %d, and page %S_PGID, slot %d, in object ID %d, index ID %d, next refer to page %S_PGID but are not in the same object.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8927, 16, 1, 'Object ID %d, index ID %d: The ghosted record count (%d) in the header does not match the number of ghosted records (%d) found on page %S_PGID.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8928, 16, 1, 'Object ID %d, index ID %d: Page %S_PGID could not be processed. See other errors for details.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8929, 16, 1, 'Object ID %d: Errors found in text ID %I64d owned by data record identified by %.*ls.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8930 ,16 ,1 ,'Table error: Object ID %d, index ID %d cross-object chain linkage. Page %S_PGID points to %S_PGID in object ID %d, index ID %d.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8931 ,16 ,1 ,'Table error: Object ID %d, index ID %d B-tree level mismatch, page %S_PGID. Level %d does not match level %d from parent %S_PGID.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8932,16,0,'Table error: Object ID %d, index ID %d, column ''%.*ls''. The column ID %d is not valid for this table. The valid range is from 1 to %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8933 ,16 ,1 ,'Table error: Object ID %d, index ID %d. The low key value on page %S_PGID (level %d) is not %ls the key value in the parent %S_PGID slot %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8934 ,16 ,1 ,'Table error: Object ID %d, index ID %d. The high key value on page %S_PGID (level %d) is not less than the low key value in the parent %S_PGID, slot %d of the next page %S_PGID.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8935 ,16 ,1 ,'Table error: Object ID %d, index ID %d. The previous link %S_PGID on page %S_PGID does not match the previous page %S_PGID that the parent %S_PGID, slot %d expects for this page.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8936 ,16 ,1 ,'Table error: Object ID %d, index ID %d. B-tree chain linkage mismatch. %S_PGID->next = %S_PGID, but %S_PGID->Prev = %S_PGID.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8937 ,16 ,1 ,'Table error: Object ID %d, index ID %d. B-tree page %S_PGID has two parent nodes %S_PGID, slot %d and %S_PGID, slot %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8938 ,16 ,1 ,'Table error: Page %S_PGID, Object ID %d, index ID %d. Unexpected page type %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8939 ,16 ,1 ,'Table error: Object ID %d, index ID %d, page %S_PGID. Test (%hs) failed. Values are %ld and %ld.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8940 ,16 ,1 ,'Table error: Object ID %d, index ID %d, page %S_PGID. Test (%hs) failed. Address 0x%x is not aligned.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8941 ,16 ,1 ,'Table error: Object ID %d, index ID %d, page %S_PGID. Test (%hs) failed. Slot %d, offset 0x%x is invalid.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8942 ,16 ,1 ,'Table error: Object ID %d, index ID %d, page %S_PGID. Test (%hs) failed. Slot %d, offset 0x%x overlaps with the prior row.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8943 ,16 ,1 ,'Table error: Object ID %d, index ID %d, page %S_PGID. Test (%hs) failed. Slot %d, row extends into free space at 0x%x.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8944 ,16 ,1 ,'Table error: Object ID %d, index ID %d, page %S_PGID, row %d. Test (%hs) failed. Values are %ld and %ld.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8945 ,16 ,1 ,'Table error: Object ID %d, index ID %d will be rebuilt.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8946 ,16 ,1 ,'Table error: Allocation page %S_PGID has invalid %ls page header values. Type is %d. Check type, object ID and page ID on the page.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8947 ,16 ,1 ,'Table error: Multiple IAM pages for object ID %d, index ID %d contain allocations for the same interval. IAM pages %S_PGID and %S_PGID.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8948 ,16 ,1 ,'Database error: Page %S_PGID is marked with the wrong type in PFS page %S_PGID. PFS status 0x%x expected 0x%x.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8949 ,10 ,1 ,'%.*ls fixed %d allocation errors and %d consistency errors in table ''%ls'' (object ID %d).' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8950 ,16 ,1 ,'%.*ls fixed %d allocation errors and %d consistency errors not associated with any single object.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8951 ,16 ,1 ,'Table error: Table ''%ls'' (ID %d). Missing or invalid key in index ''%ls'' (ID %d) for the row:' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8952 ,16 ,1 ,'Table error: Database ''%ls'', index ''%ls.%ls'' (ID %d) (index ID %d). Extra or invalid key for the keys:' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8953, 10, 1, 'Repair: Deleted text column, text ID %I64d, for object ID %d on page %S_PGID, slot %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8954 ,10 ,1 ,'%.*ls found %d allocation errors and %d consistency errors not associated with any single object.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8955 ,16 ,1 ,'Data row (%d:%d:%d) identified by (%ls) has index values (%ls).' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8956 ,16 ,1 ,'Index row (%d:%d:%d) with values (%ls) points to the data row identified by (%ls).' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8957 ,10 ,1 ,'DBCC %ls (%ls%ls%ls) executed by %ls found %d errors and repaired %d errors.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8958,10,0,'%ls is the minimum repair level for the errors found by DBCC %ls (%ls %ls).' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8959 ,16 ,1 ,'Table error: IAM page %S_PGID for object ID %d, index ID %d is linked in the IAM chain for object ID %d, index ID %d by page %S_PGID.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8960, 23, 1, 'Table error: Page %S_PGID, slot %d, column %d is not a valid complex column.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8961, 23, 1, 'Table error: Object ID %d. The text, ntext, or image node at page %S_PGID, slot %d, text ID %I64d does not match its reference from page %S_PGID, slot %d.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8962, 23, 1, 'Table error: The text, ntext, or image node at page %S_PGID, slot %d, text ID %I64d has incorrect node type %d.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8963, 23, 1, 'Table error: The text, ntext, or image node at page %S_PGID, slot %d, text ID %I64d has type %d. It cannot be placed on a page of type %d.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8964, 23, 1, 'Table error: Object ID %d. The text, ntext, or image node at page %S_PGID, slot %d, text ID %I64d is not referenced.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8965, 23, 1, 'Table error: Object ID %d. The text, ntext, or image node at page %S_PGID, slot %d, text ID %I64d is referenced by page %S_PGID, slot %d, but was not seen in the scan.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8966 ,22 ,1 ,'Could not read and latch page %S_PGID with latch type %ls. %ls failed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8967 ,16 ,1 ,'Table error: Invalid value detected in %ls for Object ID %d, index ID %d. Row skipped.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8968 ,16 ,1 ,'Table error: %ls page %S_PGID (object ID %d, index ID %d) is out of the range of this database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8969 ,16 ,1 ,'Table error: IAM chain linkage error: Object ID %d, index ID %d. The next page for IAM page %S_PGID is %S_PGID, but the previous link for page %S_PGID is %S_PGID.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8970 ,16 ,1 ,'Row error: Object ID %d, index ID %d, page ID %S_PGID, row ID %d. Column ''%.*ls'' was created NOT NULL, but is NULL in the row.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8971, 16, 1, 'Forwarded row mismatch: Object ID %d, page %S_PGID, slot %d points to forwarded row page %S_PGID, slot %d; the forwarded row points back to page %S_PGID, slot %d.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8972, 16, 1, 'Forwarded row referenced by more than one row. Object ID %d, page %S_PGID, slot %d incorrectly points to forwarded row page %S_PGID, slot %d; the forwarded row correctly refers back to page %S_PGID, slot %d.' ,1033)




insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8973, 16, 1, 'CHECKTABLE processing of object ID %d, index ID %d encountered page %S_PGID, slot %d twice. Possible internal error or allocation fault.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8974, 16, 1, 'Text node referenced by more than one node. Object ID %d, text, ntext, or image node page %S_PGID, slot %d, text ID %I64d is pointed to by page %S_PGID, slot %d and by page %S_PGID, slot %d.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8975 ,16 ,1 ,'Table error: Object ID %d, index ID %d.  The child page pointer %S_PGID on PageId %S_PGID, slot %d is not a valid page for this database.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8976, 16, 1, 'Table error: Object ID %d, index ID %d. Page %S_PGID was not seen in the scan although its parent %S_PGID and previous %S_PGID refer to it. Check any previous errors.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8977, 16, 1, 'Table error: Object ID %d, index ID %d. Parent node for page %S_PGID was not encountered.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8978, 16, 1, 'Table error: Object ID %d, index ID %d. Page %S_PGID is missing a reference from previous page %S_PGID. Possible chain linkage problem.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8979, 16, 1, 'Table error: Object ID %d, index ID %d. Page %S_PGID is missing references from parent (unknown) and previous (page %S_PGID) nodes. Possible bad root entry in sysindexes.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8980, 16, 1, 'Table error: Object ID %d, index ID %d. Index node page %S_PGID, slot %d refers to child page %S_PGID and previous child %S_PGID, but they were not encountered.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8981, 16, 1, 'Table error: Object ID %d, index ID %d. The next pointer of %S_PGID refers to page %S_PGID. Neither %S_PGID nor its parent were encountered. Possible bad chain linkage.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8982, 16, 1, 'Table error: Cross object linkage. Page %S_PGID->next in object ID %d, index ID %d refers to page %S_PGID in object ID %d, index ID %d but is not in the same index.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8983, 10, 1, 'File %d. Extents %d, used pages %d, reserved pages %d, mixed extents %d, mixed pages %d.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8984, 10, 1, '    Object ID %d, index ID %d. Allocations for %S_PGID. IAM %S_PGID, extents %d, used pages %d, mixed pages %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8985, 16, 1, 'Could not locate file ''%.*ls'' in sysfiles.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8986, 16, 1, 'Too many errors found (%d) for object ID %d. To see all error messages rerun the statement using "WITH ALL_ERRORMSGS".' ,1033)
GO
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8987,16,0,'No help available for DBCC statement ''%.*ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8988, 10, 1, 'The schema for database ''%ls'' is changing. May find spurious allocation problems due to schema changes in progress.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8989, 10, 1, '%.*ls found %d allocation errors and %d consistency errors in database ''%ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8990, 10, 1, '%.*ls found %d allocation errors and %d consistency errors in table ''%ls'' (object ID %d).' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8991, 16, 1, '0x%p + 0x%p bytes is not a valid address range.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8992, 16, 1, 'Database ID %d, object ''%ls'' (ID %d). Loop in data chain detected at %S_PGID.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8993, 16, 1, 'Object ID %d, forwarding row page %S_PGID, slot %d points to page %S_PGID, slot %d. Did not encounter forwarded row. Possible allocation error.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8994, 16, 1, 'Object ID %d, forwarded row page %S_PGID, slot %d should be pointed to by forwarding row page %S_PGID, slot %d. Did not encounter forwarding row. Possible allocation error.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8995, 16, 1, 'System table ''%.*ls'' (object ID %d, index ID %d) is in filegroup %d. All system tables must be in filegroup %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8996, 16, 1, 'IAM page %S_PGID for object ID %d, index ID %d controls pages in filegroup %d, that should be in filegroup %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8997, 16, 1, 'Single page allocation %S_PGID for object ID %d, index ID %d is in filegroup %d; it should be in filegroup %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8998, 16, 1, 'Page errors on the GAM, SGAM, or PFS pages do not allow CHECKALLOC to verify database ID %d pages from %S_PGID to %S_PGID. See other errors for cause.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(8999, 10, 1, 'Database tempdb allocation errors prevent further %ls processing.' ,1033)
GO
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(9001,10,128,'The log for database ''%.*ls'' is not available.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(9002,19,128,'The log file for database ''%.*ls'' is full. Back up the transaction log for the database to free up some log space.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(9003,20,128,'The LSN %S_LSN passed to log scan in database ''%.*ls'' is invalid.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(9004,21,128,'An error occurred while processing the log for database ''%.*ls''.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(9005, 16, 1, 'Either start LSN or end LSN specified in OpenRowset(DBLog, ...) is invalid.', 1033)
go


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (9006 ,10 ,0 , 'Cannot shrink log file %d (%s) because total number of logical log files cannot be fewer than %d.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (9007 ,10 ,0 ,'Cannot shrink log file %d (%s) because requested size (%dKB) is larger than the start of the last logical log file.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (9008 ,10 ,0 ,'Cannot shrink log file %d (%s) because all logical log files are in use.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (9009 ,10 ,0 ,'Cannot shrink log file %d (%s) because of minimum log space required.' ,1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(9010, 14, 1, 'User does not have permission to query the virtual table, DBLog. Only members of the sysadmin fixed server role and the db_owner fixed database role have this permission ', 1033)
go


GO
backup Transaction master with no_log
GO
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10000,16,1,'Unknown provider error.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10001,16,1,'The provider reported an unexpected catastrophic failure.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10002,16,1,'The provider did not implement the functionality.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10003,16,1,'The provider ran out of memory.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10004,16,1,'One or more arguments were reported invalid by the provider.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10005,16,1,'The provider did not support an interface.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10006,16,1,'The provider indicated an invalid pointer was used.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10007,16,1,'The provider indicated an invalid handle was used.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10008,16,1,'The provider terminated the operation.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (10009,16,1,'The provider did not give any information about the error.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10010,16,1,'The data necessary to complete this operation was not yet available to the provider.', 1033)


insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10011,16,1,'Access denied.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10021,16,1,'Execution terminated by the provider because a resource limit was reached.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10022,16,1,'The provider called a method from IRowsetNotify in the consumer, and the method has not yet returned.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10023,16,1,'The provider does not support the necessary method.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10024,16,1,'The provider indicates that the user did not have the permission to perform the operation.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10025,16,1,'Provider caused a server fault in an external process.', 1033)


insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10026,16,1,'No command text was set.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10027,16,1,'Command was not prepared.', 1033)
go


insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10028,16,1,'Authentication failed.', 1033)


insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10031,16,1,'An error occurred because one or more properties could not be set.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10032,16,1,'Cannot return multiple result sets (not supported by the provider).', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (10033,16,1,'The specified index does not exist or the provider does not support an index scan on this data source.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10034,16,1,'The specified table does not exist.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10035,16,1,'No value was given for one or more of the required parameters.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10041,16,1,'Could not set any property values.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10042,16,1,'Cannot set any properties while there is an open rowset.', 1033)
GO
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10051,16,1,'An error occurred while setting the data.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10052,16,1,'The insertion was canceled by the provider during notification.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10053,16,1,'Could not convert the data value due to reasons other than sign mismatch or overflow.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10054,16,1,'The data value for one or more columns overflowed the type used by the provider.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10055,16,1,'The data violated the integrity constraints for one or more columns.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10056,16,1,'The number of rows that have pending changes has exceeded the limit specified by the DBPROP_MAXPENDINGROWS property.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10057,16,1,'Cannot create the row. Would exceed the total number of active rows supported by the rowset.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10058,16,1,'The consumer cannot insert a new row before releasing previously-retrieved row handles.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10061,16,1,'An error occurred while setting data for one or more columns.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10062,16,1,'The change was canceled by the provider during notification.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10063,16,1,'Could not convert the data value due to reasons other than sign mismatch or overflow.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10064,16,1,'The data value for one or more columns overflowed the type used by the provider.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10065,16,1,'The data violated the integrity constraints for one or more columns.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10066,16,1,'The number of rows that have pending changes has exceeded the limit specified by the DBPROP_MAXPENDINGROWS property.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10067,16,1,'The rowset was using optimistic concurrency and the value of a column has been changed after the containing row was last fetched or resynchronized.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10068,16,1,'The consumer could not delete the row. A deletion is pending or has already been transmitted to the data source.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10069,16,1,'The consumer could not delete the row. The insertion has been transmitted to the data source.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(10075,16,1,'An error occurred while deleting the row.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (10081,16,1,'The rowset uses integrated indexes and there is no current index.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (10085,16,1,'RestartPosition on the table was canceled during notification.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (10086,16,1,'The table was built over a live data stream and the position cannot be restarted.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (10087,16,1,'The provider did not release some of the existing rows.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (10088,16,1,'The order of the columns was not specified in the object that created the rowset. The provider had to reexecute the command to reposition the next fetch position to its initial position, and the order of the columns changed.', 1033)
GO
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(11000,16,1,'Unknown status code for this column.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(11001,16,1,'Non-NULL value successfully returned.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(11002,16,1,'Deferred accessor validation occurred. Invalid binding for this column.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(11003,16,1,'Could not convert the data value due to reasons other than sign mismatch or overflow.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(11004,16,1,'Successfully returned a NULL value.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(11005,16,1,'Successfully returned a truncated value.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(11006,16,1,'Could not convert the data type because of a sign mismatch.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(11007,16,1,'Conversion failed because the data value overflowed the data type used by the provider.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(11008,16,1,'The provider cannot allocate memory or open another storage object on this column.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(11009,16,1,'The provider cannot determine the value for this column.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(11010,16,1,'The user did not have permission to write to the column.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(11011,16,1,'The data value violated the integrity constraints for the column.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(11012,16,1,'The data value violated the schema for the column.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(11013,16,1,'The column had a bad status.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(11014,16,1,'The column used the default value.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (11015,16,1,'The column was skipped when setting data.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (11031,16,1,'The row was successfully deleted.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (11032,16,1,'The table was in immediate-update mode, and deleting a single row caused more than one row to be deleted in the data source.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (11033,16,1,'The row was released even though it had a pending change.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (11034,16,1,'Deletion of the row was canceled during notification.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (11036,16,1,'The rowset was using optimistic concurrency and the value of a column has been changed after the containing row was last fetched or resynchronized.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (11037,16,1,'The row has a pending delete or the deletion had been transmitted to the data source.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (11038,16,1,'The row is a pending insert row.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (11039,16,1,'DBPROP_CHANGEINSERTEDROWS was VARIANT_FALSE and the insertion for the row has been transmitted to the data source.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (11040,16,1,'Deleting the row violated the integrity constraints for the column or table.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (11041,16,1,'The row handle was invalid or was a row handle to which the current thread does not have access rights.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (11042,16,1,'Deleting the row would exceed the limit for pending changes specified by the rowset property DBPROP_MAXPENDINGROWS.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (11043,16,1,'The row has a storage object open.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (11044,16,1,'The provider ran out of memory and could not fetch the row.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (11045,16,1,'User did not have sufficient permission to delete the row.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (11046,16,1,'The table was in immediate-update mode and the row was not deleted due to reaching a limit on the server, such as query execution timing out.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (11047,16,1,'Updating did not meet the schema requirements.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (11048,16,1,'There was a recoverable, provider-specific error, such as an RPC failure.', 1033)

GO
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(11100,16,1,'The provider indicates that conflicts occurred with other properties or requirements.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(11101,16,1,'Could not obtain an interface required for text, ntext, or image access.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(11102,16,1,'The provider could not support a required row lookup interface.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(11103,16,1,'The provider could not support an interface required for the UPDATE/DELETE/INSERT statements.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(11104,16,1,'The provider could not support insertion on this table.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(11105,16,1,'The provider could not support updates on this table.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(11106,16,1,'The provider could not support deletion on this table.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(11107,16,1,'The provider could not support a row lookup position.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(11108,16,1,'The provider could not support a required property.', 1033)
insert into master..sysmessages(error, severity, dlevel, description, msglangid)
    values
    (11109,16,1,'The provider does not support an index scan on this data source.', 1033)

GO
raiserror('sysmessages.error>=13000 ....',0,1) with nowait
GO


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13001 ,10 ,0 ,'data page' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13002 ,10 ,0 ,'index page' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13003 ,10 ,0 ,'leaf page' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13004 ,10 ,0 ,'last' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13005 ,10 ,0 ,'root' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13006 ,10 ,0 ,'read from' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13007 ,10 ,0 ,'send to' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13008 ,10 ,0 ,'receive' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13009 ,10 ,0 ,'send' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13010 ,10 ,0 ,'read' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13011 ,10 ,0 ,'wait' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13012 ,10 ,0 ,'a USE database statement' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13013 ,10 ,0 ,'a procedure or trigger' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13014 ,10 ,0 ,'a DISTINCT clause' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13015 ,10 ,0 ,'a view' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13016 ,10 ,0 ,'an INTO clause' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13017 ,10 ,0 ,'an ORDER BY clause' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13018 ,10 ,0 ,'a COMPUTE clause' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13019 ,10 ,0 ,'a SELECT INTO statement' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13020 ,10 ,0 ,'option' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13021 ,10 ,0 ,'offset option' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13022 ,10 ,0 ,'statistics option' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13023 ,10 ,0 ,'parameter option' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13024 ,10 ,0 ,'function name' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(13025, 10, 0, 'varbinary (128) NOT NULL', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13026 ,10 ,0 ,'parameter' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13027 ,10 ,0 ,'convert specification' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13028 ,10 ,0 ,'index' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13029 ,10 ,0 ,'table' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13030 ,10 ,0 ,'database' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13031 ,10 ,0 ,'procedure' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13032 ,10 ,0 ,'trigger' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13033 ,10 ,0 ,'view' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13034 ,10 ,0 ,'default' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13035 ,10 ,0 ,'rule' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13036 ,10 ,0 ,'system table' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13037 ,10 ,0 ,'unknown type' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13038 ,10 ,0 ,'SET statement' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13039 ,10 ,0 ,'column' ,1033)
go
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13040 ,10 ,0 ,'type' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13041 ,10 ,0 ,'character string' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13042 ,10 ,0 ,'integer' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13043 ,10 ,0 ,'identifier' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13044 ,10 ,0 ,'number' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13045 ,10 ,0 ,'integer value' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13046 ,10 ,0 ,'floating point value' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13047 ,10 ,0 ,'object' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13048 ,10 ,0 ,'column heading' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13076 ,10 ,0 ,'an assignment' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13077 ,10 ,0 ,'a cursor declaration' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13078 ,10 ,0 ,'replication filter' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13079 ,10 ,0 ,'variable assignment' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
        values
        (13080 ,10 ,0 ,'statistics' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
        values
        (13081 ,10 ,0 ,'file' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
        values
        (13082 ,10 ,0 ,'filegroup' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
        values
        (13083 ,10 ,0 ,'server' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(13084, 0, 0, 'write', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(13085, 0, 0, 'function', 1033)
go

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(13086, 10, 0, 'database collation', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(13087, 10, 0, 'drop', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(13088, 10, 0, 'alter', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13089 ,10 ,0 ,'lock' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13090 ,10 ,0 ,'thread' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(13091 ,10 ,0 ,'communication buffer' ,1033)


GO
backup Transaction master with no_log
GO


raiserror(' ',0,1)
raiserror('Adding messages for replication stored procedures.',0,1) with nowait
GO



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14002 ,16 ,0 ,'Could not find the ''Sync'' subsystem with the task ID %ld.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14003 ,16 ,0 ,'You must supply a publication name.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14004 ,16 ,0 ,'%s must be in the current database.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14005 ,16 ,0 ,'Could not drop publication. A subscription exists to it.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14006 ,16 ,0 ,'Could not drop the publication.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14008 ,11 ,0 ,'There are no publications.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14009 ,11 ,0 ,'There are no articles for publication ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14010 ,16 ,0 ,'The remote server is not defined as a subscription server.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14012 ,16 ,0 ,'The @status parameter value must be either ''active'' or ''inactive''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14013 ,16 ,0 ,'This database is not enabled for publication.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14014,16,0,'The synchronization method (@sync_method) must be ''[bcp] native'', ''[bcp] character'', ''concurrent'' or ''concurrent_c''.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14015 ,16 ,0 ,'The replication frequency (@repl_freq) must be either ''continuous'' or ''snapshot''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14016 ,16 ,0 ,'The publication ''%s'' already exists.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14017 ,16 ,0 ,'Invalid @restricted parameter value. Valid options are ''true'' or ''false''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14018 ,16 ,0 ,'Could not create the publication.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14019 ,16 ,0 ,'The @operation parameter value must be either ''add'' or ''drop''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14020 ,16 ,0 ,'Could not obtain the column ID for the specified column. Schema replication failed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14021 ,16 ,0 ,'The column was not added correctly to the article.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14022 ,16 ,0 ,'The @property parameter value must be either  ''description'', ''sync_object'', ''type'', ''ins_cmd'', ''del_cmd'', ''upd_cmd'', ''filter'', ''dest_table'', ''dest_object'', ''creation_script'', ''pre_creation_cmd'', ''status'', ''schema_option'', or ''destination_owner''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14023 ,16 ,0 ,'The type must be ''[indexed view] logbased'', ''[indexed view] logbased manualfilter'', ''[indexed view] logbased manualview'', ''[indexed view] logbased manualboth'',  or ''( view | indexed view | proc | func ) schema only''.'  
 ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14025 ,10 ,0 ,'Article update successful.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14027 ,11 ,0 ,'%s does not exist in the current database.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    (14028,16,0,'Only user tables, materialized views, and stored procedures can be published as ''logbased'' articles.',1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14029 ,16 ,0 ,'The vertical partition switch must be either ''true'' or ''false''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14030 ,16 ,0 ,'The article ''%s'' exists in publication ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14031 ,16 ,0 ,'User tables and views are the only valid synchronization objects.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14032,16,0,'The value of parameter %s cannot be ''all''. It is reserved by replication stored procedures.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14033 ,16 ,0 ,'Could not change replication frequency because there are active subscriptions on the publication.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14034 ,16 ,0 ,'The publication name (@publication) cannot be the keyword ''all''.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(14035,16,0,'The replication option ''%s'' of database ''%s'' has already been set to true.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14036 ,16 ,0 ,'Could not enable database for publishing.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(14037,16,0,'The replication option ''%s'' of database ''%s'' has been set to false.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14038 ,16 ,0 ,'Could not disable database for publishing.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14039 ,16 ,0 ,'Could not construct column clause for article view. Reduce the number of columns or create the view manually.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14040 ,16 ,0 ,'The server ''%s'' is already a Subscriber.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14042 ,16 ,0 ,'Could not create Subscriber.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14043 ,16 ,0 ,'The parameter %s cannot be NULL.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14046 ,16 ,0 ,'Could not drop article. A subscription exists on it.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14047 ,16 ,0 ,'Could not drop %s.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14048 ,16 ,0 ,'The server ''%s'' is not a Subscriber.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14049 ,16 ,0 ,'Stored procedures for replication are the only objects that can be used as a filter.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14050 ,11 ,0 ,'No subscription is on this publication or article.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14051 ,16 ,0 ,'The parameter value must be ''sync_type'' or ''dest_db''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14052 ,16 ,0 ,'The @sync_type parameter value must be ''automatic'' or ''none''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14053 ,16 ,0 ,'The subscription could not be updated at this time.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14054 ,10 ,0 ,'The subscription was updated successfully.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14055, 10 ,0 ,'The subscription does not exist.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14056 ,16 ,0 ,'The subscription could not be dropped at this time.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14057 ,16 ,0 ,'The subscription could not be created.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14058 ,16 ,0 ,'The subscription already exists.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    (14059,16,0,'Materialized view articles cannot be created for publications with the properties allow_sync_tran, allow_queued_tran, or allow_dts.',1033)

go
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14061 ,16 ,0 ,'The @pre_creation_cmd parameter value must be ''none'', ''drop'', ''delete'', or ''truncate''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14062 ,10 ,0 ,'The Subscriber was dropped.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14063 ,11 ,0 ,'The remote server does not exist or has not been designated as a valid Subscriber.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    (14065,16,0,'The @status parameter value must be ''initiated'', ''active'', ''inactive'', or ''subscribed''.',1033)

go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14066 ,16 ,0 ,'The previous status must be ''active'', ''inactive'', or ''subscribed''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14067 ,16 ,0 ,'The status value is the same as the previous status value.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14068 ,16 ,0 ,'Could not update sysobjects. The subscription status could not be changed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14069 ,16 ,0 ,'Could not update sysarticles. The subscription status could not be changed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14070 ,16 ,0 ,'Could not update the distribution database subscription table. The subscription status could not be changed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14071 ,16 ,0 ,'Could not find the Distributor or the distribution database for the local server. The Distributor may not be installed, or the local server may not be configured as a Publisher at the Distributor.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14074 ,16 ,0 ,'The server ''%s'' is already listed as a Publisher.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14075 ,16 ,0 ,'The Publisher could not be created at this time.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14076 ,16 ,0 ,'Could not grant replication login permission to ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14077 ,10 ,0 ,'The publication was updated successfully.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14078 ,16 ,0 ,'The parameter must be ''description'', ''taskid'', ''sync_method'', ''status'', ''repl_freq'', ''restricted'', ''retention'', ''immediate_sync'', ''enabled_for_internet'', ''allow_push'', ''allow_pull'', ''allow_anonymous'', or ''retention''.' ,1033)


--removed 14079, obsolete 

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14080 ,11 ,0 ,'The remote server does not exist or has not been designated as a valid Publisher.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14085 ,16 ,0 ,'The Subscriber information could not be obtained from the Distributor.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14088 ,16 ,0 ,'The table ''%s'' must have a primary key to be published using the transaction-based method.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    (14089,16,0,'The clustered index on materialized view ''%s'' may not contain nullable columns if it is to be published using the transaction-based method.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    (14090,16,0,'Error evaluating article synchronization object after column drop. The filter clause for article ''%s'' must not reference the dropped column.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14091 ,16 ,0 ,'The @type parameter passed to sp_helpreplicationdb must be either ''pub'' or ''sub''.' ,1033)

Go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14092 ,16 ,0 ,'Could not change article because there is an existing subscription to the article.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14093 ,16 ,0 ,'Cannot grant or revoke access directly on publication ''%s'' because it uses the default publication access list. ' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
		(14094,16 ,0 ,'Could not subscribe to article ''%s'' because heterogeneous Subscriber ''%s'' does not support the @pre_creation_cmd parameter value ''truncate''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
		(14095,16 ,0 ,'Could not subscribe to publication ''%s'' because heterogeneous Subscriber ''%s'' only supports the @sync_method parameter value ''bcp character'' .' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14096 ,16 ,0 ,'The path and name of the table creation script must be specified if the @pre_creation_cmd parameter value is ''drop''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14097,16,0,'The ''status'' value must be ''no column names'', ''include column names'', ''string literals'', ''parameters'', ''DTS horizontal partitions'' or ''no DTS horizontal partitions''.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(14098,16,0 ,'Cannot drop Distribution Publisher ''%s''. The remote Publisher is using ''%s'' as Distributor.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14099 ,16 ,0 ,'The server ''%s'' is already defined as a Distributor.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    (14100,16,0,'Specify all articles when subscribing to a publication using concurrent snapshot processing.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14101 ,16 ,0 ,'The publication ''%s'' already has a Snapshot Agent defined.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    (14102,16,0,'Specify all articles when unsubscribing from a publication using concurrent snapshot processing.',1033)
	
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14105 ,10 ,0 ,'You have updated the distribution database property ''%s'' successfully.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14106 ,10 ,0 ,'Distribution retention periods must be greater than 0.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14107 ,10 ,0 ,'The @max_distretention value must be larger than the @min_distretention value.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14108 ,10 ,0 ,'Removed %ld history records from %s.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14109 ,10 ,0 ,'The @security_mode parameter value must be 0 (SQL Server Authentication) or 1 (Windows Authentication).' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
     values
     (14110 ,16 ,0 ,'For stored procedure articles, the @property parameter value must be ''description'', ''dest_table'', ''dest_object'', ''creation_script'', ''pre_creation_cmd'', ''schema_option'', or ''destination_owner''.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
        values
        (14111 ,16 ,0 ,'The @pre_creation_cmd parameter value must be ''none'' or ''drop''.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
        values
        (14112 ,16 ,0 ,'This procedure can be executed only against table-based articles.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14113,16,0,'Could not execute ''%s''. Check ''%s'' in the install directory.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
        values
        (14114,16,0,'''%s'' is not configured as a Distributor.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14115 ,16 ,0 ,'The property parameter value must be %s.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14117 ,16 ,0 ,'''%s'' is not configured as a distribution database.',1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values	(14118 ,16 ,0 ,'A stored procedure can be published only as a ''serializable proc exec'' article, a ''proc exec'' article, or a ''proc schema only'' article.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14119 ,16 ,0 ,'Could not add the distribution database ''%s''. This distribution database already exists.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14120 ,16 ,0 ,'Could not drop the distribution database ''%s''. This distributor database is associated with a Publisher.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14121 ,16 ,0 ,'Could not drop the Distributor ''%s''. This Distributor has associated distribution databases.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(14122,16,0,'The @article parameter value must be ''all'' for immediate_sync publications.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(14123,16,0,'The subscription @sync_type parameter value ''manual'' is no longer supported.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(14124,16,0,'A publication must have at least one article before a subscription to it can be created.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(14126,16,0,'You do not have the required permissions to complete the operation.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(14128,16,0,'Invalid @subscription_type parameter value. Valid options are ''push'' or ''pull''.',1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(14129,16,0,'The @status parameter value must be NULL for ''automatic'' sync_type when you add subscriptions to an immediate_sync publication.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(14135,16,0,'There is no subscription on Publisher ''%s'', publisher database ''%s'', publication ''%s''.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(14136,16,0,'The keyword ''all'' is reserved by replication stored procedures.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(14137,16,0,'The @value parameter value must be either ''true'' or ''false''.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(14138,16,0,'Invalid option name ''%s''.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(14139,16,0,'The replication system table ''%s'' already exists.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(14143,16,0,'Cannot drop Distributor Publisher ''%s''. There are Subscribers associated with it in the distribution database ''%s''.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(14144,16,0,'Cannot drop Subscriber ''%s''. There are subscriptions from it in the publication database ''%s''.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(14146,16,0,'The article parameter ''@schema_option'' cannot be NULL.',1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(14147,16,0,'Restricted publications are no longer supported.',1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(14148,16,0,'Invalid ''%s'' value. Valid values are ''true'' or ''false''.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14149 ,10 ,0 ,'Removed %ld replication history records in %s seconds (%ld row/secs).' ,1033)

GO

raiserror(' ',0,1)
raiserror('Adding messages for SQLServerAgent Replication subsystems / Jobs.',0,1) with nowait
go

---- Adding messages for SQLServerAgent Replication subsystems / Jobs.

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14150 ,10 ,0 ,'Replication-%s: agent %s succeeded. %s' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(14151, 18, 0 ,'Replication-%s: agent %s failed. %s' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14152 ,10 ,0 ,'Replication-%s: agent %s scheduled for retry. %s' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14153 ,10 ,0 ,'Replication-%s: agent %s warning. %s' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14154 ,16 ,0 ,'The Distributor parameter must be ''@heartbeat_interval''.',1033)		 
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(14155,16,0,'Invalid article ID specified for procedure script generation.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(14156,16,0,'The custom stored procedure was not specified in the article definition.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(14157,10,0,'The subscription created by Subscriber ''%s'' to publication ''%s'' has expired and has been dropped.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(14158,10,0, 'Replication-%s: agent %s: %s.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(14159,16,0, 'Could not change property ''%s'' for article ''%s'' because there is an existing subscription to the article.', 1033)

-- Adding messages for maintaining maintenance plan SPs
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(14199,10,0, 'The specified job "%s" is not created for maintenance plans.', 1033)
GO
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14200 ,16 ,0 ,'The specified ''%s'' is invalid.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14201 ,10 ,0 ,'0 (all steps) .. ' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14202 ,10 ,0 ,'before or after @active_start_time' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14203 ,10 ,0 ,'sp_helplogins [excluding Windows NT groups]' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14204 ,10 ,0 ,'0 (non-idle), 1 (executing), 2 (waiting for thread), 3 (between retries), 4 (idle),  5 (suspended), 7 (performing completion actions)' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14205 ,10 ,0 ,'(unknown)' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14206 ,10 ,0 ,'0..n seconds' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14207 ,10 ,0 ,'-1 [no maximum], 0..n' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14208 ,10 ,0 ,'1..7 [1 = E-mail, 2 = Pager, 4 = NetSend]' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14209 ,10 ,0 ,'0..127 [1 = Sunday .. 64 = Saturday]' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14210 ,10 ,0 ,'notification' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14211 ,10 ,0 ,'server' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14212 ,10 ,0 ,'(all jobs)' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14213 ,16 ,0 ,'Core Job Details:' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14214 ,16 ,0 ,'Job Steps:' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14215 ,16 ,0 ,'Job Schedules:' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14216 ,16 ,0 ,'Job Target Servers:' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14217 ,16 ,0 ,'SQL Server Warning: ''%s'' has performed a forced defection of TSX server ''%s''. Run sp_delete_targetserver at the MSX in order to complete the defection.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14218 ,10 ,0 ,'hour' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14219 ,10 ,0 ,'minute' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14220 ,10 ,0 ,'second' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14221 ,16 ,0 ,'This job has one or more notifications to operators other than ''%s''. The job cannot be targeted at remote servers as currently defined.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14222 ,16 ,0 ,'Cannot rename the ''%s'' operator.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14223 ,16 ,0 ,'Cannot modify or delete operator ''%s'' while this server is a %s.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14224, 0, 0, 'Warning: The server name given is not the current MSX server (''%s'').' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14225 ,16 ,0 ,'Warning: Could not determine local machine name. This prevents MSX operations from being posted.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14226, 0, 0, '%ld history entries purged.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14227, 0, 0, 'Server defected from MSX ''%s''. %ld job(s) deleted.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14228, 0, 0, 'Server MSX enlistment changed from ''%s'' to ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14229, 0, 0, 'Server enlisted into MSX ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14230, 0, 0, 'SP_POST_MSX_OPERATION: %ld %s download instruction(s) posted.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14231, 0, 0, 'SP_POST_MSX_OPERATION Warning: The specified %s (''%s'') is not involved in a multiserver job.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14232 ,16 ,0 ,'Specify either a job_name, job_id, or an originating_server.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14233 ,16 ,0 ,'Specify a valid job_id (or 0x00 for all jobs).' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14234 ,16 ,0 ,'The specified ''%s'' is invalid (valid values are returned by %s).' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14235 ,16 ,0 ,'The specified ''%s'' is invalid (valid values are greater than 0 but excluding %ld).' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14236, 0, 0, 'Warning: Non-existent step referenced by %s.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14237 ,16 ,0 ,'When an action of ''REASSIGN'' is specified, the New Login parameter must also be supplied.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14238, 0, 0, '%ld jobs deleted.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14239, 0, 0, '%ld jobs reassigned to %s.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14240, 0, 0, 'Job applied to %ld new servers.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14241, 0, 0, 'Job removed from %ld servers.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14242 ,16 ,0 ,'Only a system administrator can reassign ownership of a job.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14243, 0, 0, 'Job ''%s'' started successfully.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14244 ,16 ,0 ,'Only a system administrator can reassign tasks.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14245 ,16 ,0 ,'Specify either the @name, @id, or @loginname of the task(s) to be deleted.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14246 ,16 ,0 ,'Specify either the @currentname or @id of the task to be updated.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14247 ,16 ,0 ,'Only a system administrator can view tasks owned by others.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14248 ,16 ,0 ,'This login is the owner of %ld job(s). You must delete or reassign these jobs before the login can be dropped.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14249 ,16 ,0 ,'Specify either @taskname or @oldloginname when reassigning a task.' ,1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14250 ,16 ,0 ,'The specified %s is too long. It must contain no more than %ld characters.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14251 ,16 ,0 ,'Cannot specify ''%s'' as the operator to be notified.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14252 ,16 ,0 ,'Cannot perform this action on a job you do not own.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14253, 0, 0, '%ld (of %ld) job(s) stopped successfully.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14254, 0, 0, 'Job ''%s'' stopped successfully.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14255 ,16 ,0 ,'The owner (''%s'') of this job is either an invalid login, or is not a valid user of database ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14256 ,16 ,0 ,'Cannot start job ''%s'' (ID %s) because it does not have any job server(s) defined.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14257 ,16 ,0 ,'Cannot stop job ''%s'' (ID %s) because it does not have any job server(s) defined.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14258 ,16 ,0 ,'Cannot perform this operation while SQLServerAgent is starting. Try again later.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14259 ,16 ,0 ,'A schedule (ID %ld, ''%s'') for this job with this definition already exists.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14260 ,16 ,0 ,'You do not have sufficient permission to run this command.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14261 ,16 ,0 ,'The specified %s (''%s'') already exists.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14262 ,16 ,0 ,'The specified %s (''%s'') does not exist.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14263 ,16 ,0 ,'Target server ''%s'' is already a member of group ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14264 ,16 ,0 ,'Target server ''%s'' is not a member of group ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14265 ,25 ,0 ,'The MSSQLServer service terminated unexpectedly.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14266 ,16 ,0 ,'The specified ''%s'' is invalid (valid values are: %s).' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14267 ,16 ,0 ,'Cannot add a job to the ''%s'' job category.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14268 ,16 ,0 ,'There are no jobs at this server that originated from server ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14269 ,16 ,0 ,'Job ''%s'' is already targeted at server ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14270 ,16 ,0 ,'Job ''%s'' is not currently targeted at server ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14271 ,16 ,0 ,'A target server cannot be named ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14272 ,16 ,0 ,'Object-type and object-name must be supplied as a pair.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14273 ,16 ,0 ,'You must provide either @job_id or @job_name (and, optionally, @schedule_name), or @schedule_id.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14274 ,16 ,0 ,'Cannot add, update, or delete a job (or its steps or schedules) that originated from an MSX server.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14275 ,16 ,0 ,'The originating server must be either ''(local)'' or ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14276 ,16 ,0 ,'''%s'' is a permanent %s category and cannot be deleted.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14277 ,16 ,0 ,'The command script does not destroy all the objects that it creates. Revise the command script.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14278 ,16 ,0 ,'The schedule for this job is invalid (reason: %s).' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14279 ,16 ,0 ,'Supply either @job_name or @originating_server.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14280 ,16 ,0 ,'Supply either a job name (and job aspect), or one or more job filter parameters.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14281, 0, 0, 'Warning: The @new_owner_login_name parameter is not necessary when specifying a ''DELETE'' action.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14282 ,16 ,0 ,'Supply either a date (created or last modified) and a data comparator, or no date parameters at all.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14283 ,16 ,0 ,'Supply @target_server_groups or @target_servers, or both.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14284 ,16 ,0 ,'Cannot specify a job ID for a new job. An ID will be assigned by the procedure.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14285 ,16 ,0 ,'Cannot add a local job to a multiserver job category.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14286 ,16 ,0 ,'Cannot add a multiserver job to a local job category.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14287 ,16 ,0 ,'The ''%s'' supplied has an invalid %s.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14288 ,16 ,0 ,'%s cannot be before %s.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14289 ,16 ,0 ,'%s cannot contain ''%s'' characters.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14290 ,16 ,0 ,'This job is currently targeted at the local server so cannot also be targeted at a remote server.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14291 ,16 ,0 ,'This job is currently targeted at a remote server so cannot also be targeted at the local server.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14292 ,16 ,0 ,'There are two or more tasks named ''%s''. Specify %s instead of %s to uniquely identify the task.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14293 ,16 ,0 ,'There are two or more jobs named ''%s''. Specify %s instead of %s to uniquely identify the job.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14294 ,16 ,0 ,'Supply either %s or %s to identify the job.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14295 ,16 ,0 ,'Frequency Type 0x2 (OnDemand) is no longer supported.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14296 ,16 ,0 ,'This server is already enlisted into MSX ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14297 ,16 ,0 ,'Cannot enlist into the local machine.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14298 ,16 ,0 ,'This server is not currently enlisted into an MSX.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14299 ,16 ,0 ,'Server ''%s'' is an MSX. Cannot enlist one MSX into another MSX.' ,1033)
GO

---- Error messages for tasks.
---- Removing errors 142xx per Richard Hughes

GO

raiserror(' ',0,1)
raiserror('Adding messages for SQLOLE.',0,1) with nowait
go

---- Error messages for SQLOLE


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14300 ,16 ,0 ,'Circular dependencies exist. Dependency evaluation cannot continue.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14301 ,16 ,0 ,'Logins other than the current user can only be seen by members of the sysadmin role.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14302 ,16 ,0 ,'You must upgrade your client to version 6.5 of SQL-DMO and SQL Server Enterprise Manager to connect to this server. The upgraded versions will administer both SQL Server version 6.5 and 6.0 (if sqlole65.sql is run).' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (14303 ,16 ,0 ,'Stored procedure ''%s'' failed to access registry key.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (14304 ,16 ,0 ,'Stored procedure ''%s'' can run only on Windows 2000 servers.' ,1033)
go


---- Error messages for xpadsi throught sp_ActiveDirectory_SCP and sp_ActiveDirectory_Obj
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14350 ,16 ,0 ,'Cannot initialize COM library because CoInitialize failed.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14351 ,16 ,0 ,'Cannot complete this operation because an unexpected error occurred.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14352 ,16 ,0 ,'Cannot find Active Directory information in the registry for this SQL Server instance. Run sp_ActiveDirectory_SCP again.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (14353 ,16 ,0 ,'Cannot determine the service account for this SQL Server instance.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (14354 ,16 ,0 ,'Cannot start the MSSQLServerADHelper service. Verify that the service account for this SQL Server instance has the necessary permissions to start the MSSQLServerADHelper service.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (14355 ,16 ,0 ,'The MSSQLServerADHelper service is busy. Retry this operation later.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (14356 ,16 ,0 ,'The Windows Active Directory client is not installed properly on the computer where this SQL Server instance is running. LoadLibrary failed to load ACTIVEDS.DLL.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (14357 ,16 ,0 ,'Cannot list ''%s'' in Active Directory because the name is too long. Active Directory common names cannot exceed 64 characters.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (14358 ,16 ,0 ,'Cannot determine the SQL Server Agent proxy account for this SQL Server instance or the account is not a domain user account. Use xp_sqlagent_proxy_account to configure SQL Server Agent to use a domain user account as the proxy account.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (14359 ,16 ,0 ,'Active Directory is either not enabled on the network or not supported by the operating system.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (14360,16,0,'%s is already configured as TSX machine', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (14361,16,0,'MSX server does not support mixed security mode', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (14362,16,0,'The MSX server must be running the Standard or Enterprise edition of SQL Server', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (14363,16,0,'The MSX server is not prepared for enlistments [there must be an operator named ''MSXOperator'' defined at the MSX]', 1033)
go

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (14364,16,0,'The TSX server is not currently enlisted', 1033)
go

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values (14410, 16, 0, 'You must supply either a plan_name or a plan_id.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values (14411, 16, 0, 'Cannot delete this plan. The plan contains enlisted databases.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values (14412, 16, 0, 'The destination database is already part of a log shipping plan.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values (14413, 16, 0, 'This database is already log shipping.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values (14414, 16, 0, 'A log shipping monitor is already defined.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values (14415, 16, 0, 'The user name cannot be null when using SQL Server authentication.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values (14416, 16, 0, 'This stored procedure must be run in msdb.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values (14417, 16, 0, 'Cannot delete the monitor server while databases are participating in log shipping.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values (14418, 16, 0, 'The specified @backup_file_name was not created from database ''%s''.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values (14419, 16, 0, 'The specified @backup_file_name is not a database backup.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values (14420, 16, 128, 'The log shipping source %s.%s has not backed up for %s minutes.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values (14421, 16, 128, 'The log shipping destination %s.%s is out of sync by %s minutes.', 1033)

go

--inserted 14422-14451 

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
  (14422, 16, 0, 'Supply either @plan_id or @plan_name.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
  (14423, 16, 0,'Other databases are enlisted on this plan and must be removed before the plan can be deleted.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
  (14424, 16, 0,'The database ''%s'' is already involved in log shipping.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
  (14425, 16, 0,'The database ''%s'' does not seem to be involved in log shipping.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
  (14426, 16, 0,'A log shipping monitor is already defined. Call sp_define_log_shipping_monitor with @delete_existing = 1.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
  (14427, 16, 0,'A user name is necessary for SQL Server security.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
  (14428, 16, 0,'Could not remove the monitor as there are still databases involved in log shipping.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
  (14429, 16, 0,'There are still secondary servers attached to this primary.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14430, 16, 0, 'Invalid destination path %s.', 1033 )
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
  (14440, 16, 0,'Could not set single user mode.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
  (14441, 16, 0,'Role change succeeded.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
  (14442, 16, 0,'Role change failed.' , 1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
  (14450, 16, 0,'The specified @backup_file_name was not taken from database ''%s''.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
  (14451, 16, 0,'The specified @backup_file_name is not a database backup.', 1033)

GO
backup Transaction master with no_log
GO

raiserror(' ',0,1)
raiserror('Adding messages for Alerts, Operators and Jobs.',0,1) with nowait
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14500 ,16 ,0 ,'Supply either a non-zero message ID, non-zero severity, or non-null performance condition.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14501 ,16 ,0 ,'An alert (''%s'') has already been defined on this condition.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14502 ,16 ,0 ,'The @target_name parameter must be supplied when specifying an @enum_type of ''TARGET''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14503 ,16 ,0 ,'The @target_name parameter should not be supplied when specifying an @enum_type of ''ALL'' or ''ACTUAL''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14504 ,16 ,0 ,'''%s'' is the fail-safe operator. You must make another operator the fail-safe operator before ''%s'' can be dropped.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14505 ,16 ,0 ,'Specify a null %s when supplying a performance condition.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14506 ,16 ,0 ,'Cannot set alerts on message ID %ld.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14507 ,16 ,0 ,'A performance condition must be formatted as: ''object_name|counter_name|instance_name|comparator(> or < or =)|numeric value''.' ,1033)
go
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14539 ,16 ,0 , 'Only a Standard or Enterprise edition of SQL Server can be enlisted into an MSX.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14540 ,16 ,0 , 'Only a SQL Server running on Microsoft Windows NT can be enlisted into an MSX.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14541 ,16 ,0 , 'The version of the MSX (%s) is not recent enough to support this TSX.  Version %s or later is required at the MSX.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14542 ,16 ,0 , 'It is invalid for any TSQL step of a multiserver job to have a non-null %s value.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14543 ,16 ,0 ,'Login ''%s'' owns one or more multiserver jobs. Ownership of these jobs can only be assigned to members of the %s role.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14544 ,16 ,0 ,'This job is owned by ''%s''. Only a job owned by a member of the %s role can be a multiserver job.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14545 ,16 ,0 ,'The %s parameter is not valid for a job step of type ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14546 ,16 ,0 ,'The %s parameter is not supported on Windows 95/98 platforms.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14547 ,10 ,0 ,'Warning: This change will not be downloaded by the target server(s) until an %s for the job is posted using %s.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14548 ,10 ,0 ,'Target server ''%s'' does not have any jobs assigned to it.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14549 ,10 ,0 ,'(Description not requested.)' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14550 ,10 ,0 ,'Command-Line Subsystem' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14551 ,10 ,0 ,'Replication Snapshot Subsystem' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14552 ,10 ,0 ,'Replication Transaction-Log Reader Subsystem' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14553 ,10 ,0 ,'Replication Distribution Subsystem' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14554 ,10 ,0 ,'Replication Merge Subsystem' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14555 ,10 ,0 ,'Active Scripting Subsystem' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14556 ,10 ,0 ,'Transact-SQL Subsystem' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14557 ,10 ,0 ,'[Internal]' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14558 ,10 ,0 ,'(encrypted command)' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14559 ,10 ,0 ,'(append output file)' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14560 ,10 ,0 ,'(include results in history)' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14561 ,10 ,0 ,'(normal)' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14562 ,10 ,0 ,'(quit with success)' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14563 ,10 ,0 ,'(quit with failure)' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14564 ,10 ,0 ,'(goto next step)' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14565 ,10 ,0 ,'(goto step)' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14566 ,10 ,0 ,'(idle)' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14567 ,10 ,0 ,'(below normal)' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14568 ,10 ,0 ,'(above normal)' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14569 ,10 ,0 ,'(time critical)' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14570 ,10 ,0 ,'(Job outcome)' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14571 ,10 ,0 ,'No description available.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14572 ,10 ,0 ,'@freq_interval must be at least 1 for a daily job.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14573 ,10 ,0 ,'@freq_interval must be a valid day of the week bitmask [Sunday = 1 .. Saturday = 64] for a weekly job.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14574 ,10 ,0 ,'@freq_interval must be between 1 and 31 for a monthly job.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14575 ,10 ,0 ,'@freq_relative_interval must be one of 1st (0x1), 2nd (0x2), 3rd [0x4], 4th (0x8) or Last (0x10).' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14576 ,10 ,0 ,'@freq_interval must be between 1 and 10 (1 = Sunday .. 7 = Saturday, 8 = Day, 9 = Weekday, 10 = Weekend-day) for a monthly-relative job.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14577 ,10 ,0 ,'@freq_recurrence_factor must be at least 1.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14578 ,10 ,0 ,'Starts whenever the CPU usage has remained below %ld percent for %ld seconds.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14579 ,10 ,0 ,'Automatically starts when SQLServerAgent starts.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14580 ,10 ,0 ,'job' ,1033)
go
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14581 ,10 ,0 ,'Replication Transaction Queue Reader Subsystem' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14585 ,16 ,0 ,'Only the owner of DTS Package ''%s'' or a member of the sysadmin role may reassign its ownership.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14586 ,16 ,0 ,'Only the owner of DTS Package ''%s'' or a member of the sysadmin role may create new versions of it.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14587 ,16 ,0 ,'Only the owner of DTS Package ''%s'' or a member of the sysadmin role may drop it or any of its versions.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14588 ,10 ,0 ,'ID.VersionID = ' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14589 ,10 ,0 ,'[not specified]' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14590 ,16 ,0 ,'DTS Package ''%s'' already exists with a different ID in this category.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14591 ,16 ,0 ,'DTS Category ''%s'' already exists in the specified parent category.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14592 ,16 ,0 ,'DTS Category ''%s'' was found in multiple parent categories. You must uniquely specify the category to be dropped.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14593 ,16 ,0 ,'DTS Category ''%s'' contains packages and/or other categories. You must drop these first, or specify a recursive drop.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14594 ,10 ,0 ,'DTS Package' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14595 ,16 ,0 ,'DTS Package ''%s'' exists in different categories. You must uniquely specify the package.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14596 ,16 ,0 ,'DTS Package ''%s'' exists in another category.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14597 ,16 ,0 ,'DTS Package ID ''%s'' already exists with a different name.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14598 ,16 ,0 ,'Cannot drop the Local, Repository, or LocalDefault DTS categories.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(14599 ,10 ,0 ,'Name' ,1033)
GO

raiserror(' ',0,1)
raiserror('Adding generic error messages for system stored procedures.',0,1)

raiserror('sysmessages.error>=15000 ....',0,1) with nowait
GO

---- Reserved 15000-15999 for system sprocs.


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15001 ,16 ,0 ,'Object ''%ls'' does not exist or is not a valid object for this operation.', 1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15002 ,16 ,0 ,'The procedure ''%s'' cannot be executed within a transaction.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
-- DEVNOTE: Server devs should not use 15003, use 15247 instead. This msg although obsolete
-- is still left in because other groups such as *fighter & repl are using it.
	(15003 ,16 ,0 ,'Only members of the %s role can execute this stored procedure.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15004 ,16 ,0 ,'Name cannot be NULL.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15005,0 ,0 ,'Statistics for all tables have been updated.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15006 ,16 ,0 ,'''%s'' is not a valid name because it contains invalid characters.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15007 ,16 ,0 ,'The login ''%s'' does not exist.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15008 ,16 ,0 ,'User ''%s'' does not exist in the current database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15009 ,16 ,0 ,'The object ''%s'' does not exist in database ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15010 ,16 ,0 ,'The database ''%s'' does not exist. Use sp_helpdb to show available databases.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15011 ,16 ,0 ,'Database option ''%s'' does not exist.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15012 ,16 ,0 ,'The device ''%s'' does not exist. Use sp_helpdevice to show available devices.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15013,0 ,0 ,'Table ''%s'': No columns without statistics found.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15014 ,16 ,0 ,'The role ''%s'' does not exist in the current database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15015 ,16 ,0 ,'The server ''%s'' does not exist. Use sp_helpserver to show available servers.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15016 ,16 ,0 ,'The default ''%s'' does not exist.' ,1033)

Go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15017 ,16 ,0 ,'The rule ''%s'' does not exist.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15018,0 ,0 ,'Table ''%s'': Creating statistics for the following columns:' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15019 ,16 ,0 ,'The extended stored procedure ''%s'' does not exist.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15020,0 ,0 ,'Statistics have been created for the %d listed columns of the above tables.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15021 ,16 ,0 ,'There are no remote users mapped to any local user from remote server ''%s''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15022 ,16 ,0 ,'The specified user name is already aliased.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15023 ,16 ,0 ,'User or role ''%s'' already exists in the current database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15024 ,16 ,0 ,'The group ''%s'' already exists in the current database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15025 ,16 ,0 ,'The login ''%s'' already exists.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15026 ,16 ,0 ,'Logical device ''%s'' already exists.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15027 ,16 ,0 ,'There are no remote users mapped to local user ''%s'' from remote server ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15028 ,16 ,0 ,'The server ''%s'' already exists.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15029 ,16 ,0 ,'The data type ''%s'' already exists in the current database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15030 ,16 ,0 ,'The read-only bit cannot be turned off because the database is in standby mode.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15031 ,0 ,0 ,'''Virtual_device'' device added.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15032 ,16 ,0 ,'The database ''%s'' already exists.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15033 ,16 ,0 ,'''%s'' is not a valid official language name.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15034 ,16 ,0 ,'The application role password must not be NULL.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15035 ,16 ,0 ,'''%s'' is not a database device.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15036 ,16 ,0 ,'The data type ''%s'' does not exist.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15037 ,16 ,0 ,'The physical data type ''%s'' does not allow nulls.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15038 ,16 ,0 ,'User-defined data types based on timestamp are not allowed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15039 ,16 ,0 ,'The language %s already exists in syslanguages.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15040 ,16 ,0 ,'User-defined error messages must have an ID greater than 50000.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15041 ,16 ,0 ,'User-defined error messages must have a severity level between 1 and 25.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15043 ,16 ,0 ,'You must specify ''REPLACE'' to overwrite an existing message.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15044 ,16 ,0 ,'''%s'' is an unknown device type. Use ''disk'', ''tape'', or ''pipe''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15045 ,16 ,0 ,'The logical name cannot be NULL.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15046 ,16 ,0 ,'The physical name cannot be NULL.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15047 ,16 ,0 ,'The only permitted options for a tape device are ''skip'' and ''noskip''.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(15048, 0, 0, 'Valid values of database compatibility level are %d, %d, %d, or %d.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15049 ,11 ,0 ,'Cannot unbind from ''%s''. Use ALTER TABLE DROP CONSTRAINT.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15050 ,11 ,0 ,'Cannot bind default ''%s''. The default must be created using the CREATE DEFAULT statement.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (15051 ,11 ,0 ,'Cannot rename the table because it is published for replication.' ,1033)
GO
insert into master..sysmessages(error ,severity ,dlevel ,description ,msglangid)
	values
	(15052 ,0 ,0 ,'Prior to updating sysdatabases entry for database ''%s'', mode = %d and status = %d (status suspect_bit = %d).' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15053 ,16 ,0 ,'Objects exist which are not owned by the database owner.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(15054, 0, 0, 'The current compatibility level is %d.', 1033)
insert into master..sysmessages(error ,severity ,dlevel ,description ,msglangid)
	values
	(15055 ,11, 0, 'Error. Updating sysdatabases returned @@error <> 0.' ,1033)
insert into master..sysmessages(error ,severity ,dlevel ,description ,msglangid)
	values
	(15056 ,0 ,0 ,'No row in sysdatabases was updated because mode and status are already correctly reset. No error and no changes made.'  ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15057 ,16 ,0 ,'List of %s name contains spaces, which are not allowed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15058 ,16 ,0 ,'List of %s has too few names.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15059 ,16 ,0 ,'List of %s has too many names.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15060 ,16 ,0 ,'List of %s names contains name(s) which have ''%s'' non-alphabetic characters.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15061 ,16 ,0 ,'Add device request denied. A physical device named ''%s'' already exists.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15062 ,16 ,0 ,'The guest user cannot be mapped to a login name.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15063 ,16 ,0 ,'The login already has an account under a different user name.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15064 ,11 ,0 ,'PRIMARY KEY and UNIQUE KEY constraints do not have space allocated.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15065 ,16 ,0 ,'All user IDs have been assigned.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15066 ,16 ,0 ,'A default-name mapping of a remote login from remote server ''%s'' already exists.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15067 ,16 ,0 ,'''%s'' is not a local user. Remote login denied.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15068 ,16 ,0 ,'A remote user ''%s'' already exists for remote server ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15069 ,16 ,0 ,'One or more users are using the database. The requested operation cannot be completed.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(15070, 0, 0, 'Object ''%s'' was successfully marked for recompilation.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15071 ,16 ,0 ,'Usage: sp_addmessage <msgnum>,<severity>,<msgtext> [,<language> [,FALSE | TRUE [,REPLACE]]]' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15072 ,16 ,0 ,'Usage: sp_addremotelogin remoteserver [, loginame [,remotename]]' ,1033)
insert into master..sysmessages(error ,severity ,dlevel ,description ,msglangid)
	values
	(15073 ,0 ,0 ,'For row in sysdatabases for database ''%s'', the status bit %d was forced off and mode was forced to 0.' ,1033)
insert into master..sysmessages(error ,severity ,dlevel ,description ,msglangid)
	values
	(15074 ,0 ,0 ,'Warning: You must recover this database prior to access.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15075 ,16 ,0 ,'The data type ''%s'' is reserved for future use.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15076 ,16 ,0 ,'Default, table, and user data types must be in the current database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15077 ,16 ,0 ,'Rule, table, and user data type must be in the current database.' ,1033)

Go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15078 ,16 ,0 ,'The table or view must be in the current database.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15079 ,10 ,0 ,'Queries processed: %d.' ,1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(15081, 16, 0,'Membership of the public role cannot be changed.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15082 ,11 ,0 ,'NULL is not an acceptable parameter value for this procedure. Use a percent sign instead.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15083 ,16 ,0 ,'Physical data type ''%s'' does not accept a collation' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15084 ,16 ,0 ,'The column or user data type must be in the current database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15085 ,16 ,0 ,'Usage: sp_addtype name, ''data type'' [,''NULL'' | ''NOT NULL'']' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15086 ,16 ,0 ,'Invalid precision specified. Precision must be between 1 and 38.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15087 ,16 ,0 ,'Invalid scale specified. Scale must be less than precision and positive.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15088 ,16 ,0 ,'The physical data type is fixed length. You cannot specify the length.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15089 ,11 ,0 ,'Cannot change the ''%s'' option of a database while another user is in the database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15090 ,16 ,0 ,'There is already a local server.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15091 ,16 ,0 ,'You must specify a length with this physical data type.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15092 ,16 ,0 ,'Invalid length specified. Length must be between 1 and 8000 bytes.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15093 ,16 ,0 ,'''%s'' is not a valid date order.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15094 ,16 ,0 ,'''%s'' is not a valid first day.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15095 ,16 ,0 ,'Insert into syslanguages failed. Language not added.' ,1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(15097, 16, 0,'The size associated with an extended property cannot be more than 7,500 bytes.', 1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15100 ,16 ,0 ,'Usage: sp_bindefault defaultname, objectname [, ''futureonly'']' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15101 ,16 ,0 ,'Cannot bind a default to a column of data type timestamp.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15102 ,16 ,0 ,'Cannot bind a default to an identity column.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15103 ,16 ,0 ,'Cannot bind a default to a column created with or altered to have a default value.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15104 ,16 ,0 ,'You do not own a table named ''%s'' that has a column named ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15105 ,16 ,0 ,'You do not own a data type with that name.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15106 ,16 ,0 ,'Usage: sp_bindrule rulename, objectname [, ''futureonly'']' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15107 ,16 ,0 ,'Cannot bind a rule to a column of data type text, ntext, image, or timestamp.' ,1033)
Go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15109 ,16 ,0 ,'Cannot change the owner of the master database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15110 ,16 ,0 ,'The proposed new database owner is already a user in the database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15111 ,16 ,0 ,'The proposed new database owner is already aliased in the database.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15112 ,11 ,0 ,'The third parameter for table option ''text in row'' is invalid. It should be ''on'', ''off'', ''0'', or a number from 24 through 7000.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15123 ,16 ,0 ,'The configuration option ''%s'' does not exist, or it may be an advanced option.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15124 ,16 ,0 ,'The configuration option ''%s'' is not unique.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15125 ,16 ,0 ,'Trigger ''%s'' is not a trigger for ''%s''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15126 ,16 ,0 ,'Trigger ''%s'' was not found.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15127 ,16 ,0 ,'Cannot set the default language to a language ID not defined in syslanguages.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15129 ,16 ,0 ,'''%d'' is not a valid value for configuration option ''%s''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15130 ,16 ,0 ,'Table ''%s'' already has a ''%s'' trigger for ''%s''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15131 ,16 ,0 ,'Usage: sp_dbremove <dbname> [,dropdev]' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15132 ,16 ,0 ,'Cannot change default database belonging to someone else.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15133 ,16 ,0 ,'INSTEAD OF trigger ''%s'' cannot be associated with an order.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15134 ,16 ,0 ,'No alias exists for the specified user.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15135, 16,0,'Object is invalid. Extended properties are not permitted on ''%s'', or the object does not exist.', 1033)

Go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15139 ,16 ,0 ,'The device is a RAM disk and cannot be used as a default device.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15140 ,16 ,0 ,'Usage: sp_diskdefault logicalname {defaulton | defaultoff}' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15142 ,16 ,0 ,'Cannot drop the role ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15143 ,16 ,0 ,'''%s'' is not a valid option for the @updateusage parameter. Enter either ''true'' or ''false''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15144 ,16 ,0 ,'The role has members. It must be empty before it can be dropped.' ,1033)

Go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15174 ,16 ,0 ,'Login ''%s'' owns one or more database(s). Change the owner of the following database(s) before dropping login:' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15175 ,16 ,0 ,'Login ''%s'' is aliased or mapped to a user in one or more database(s). Drop the user or alias before dropping the login.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15176 ,16 ,0 ,'The only valid @parameter value is ''WITH_LOG''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15177 ,16 ,0 ,'Usage: sp_dropmessage <msg number> [,<language> | ''ALL'']' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15178 ,16 ,0 ,'Cannot drop a message with an ID less than 50000.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15179 ,16 ,0 ,'Message number %u does not exist.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15180 ,16 ,0 ,'Cannot drop. The data type is being used.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15181 ,16 ,0 ,'Cannot drop the database owner.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15182 ,16 ,0 ,'Cannot drop the guest user from master or tempdb.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15183 ,16 ,0 ,'The user owns objects in the database and cannot be dropped.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15184 ,16 ,0 ,'The user owns data types in the database and cannot be dropped.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15185 ,16 ,0 ,'There is no remote user ''%s'' mapped to local user ''%s'' from the remote server ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15190 ,16 ,0 ,'There are still remote logins for the server ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15191 ,16 ,0 ,'Usage: sp_dropserver server [, droplogins]' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15193 ,16 ,0 ,'This procedure can only be used on system tables.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15194 ,16 ,0 ,'Cannot re-create index on this table.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15197 ,16 ,0 ,'There is no text for object ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15198 ,16 ,0 ,'The name supplied (%s) is not a user, role, or aliased login.' ,1033)

Go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15200 ,16 ,0 ,'There are no remote servers defined.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15201 ,16 ,0 ,'There are no remote logins for the remote server ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15202 ,16 ,0 ,'There are no remote logins defined.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15203 ,16 ,0 ,'There are no remote logins for ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15204 ,16 ,0 ,'There are no remote logins for ''%s'' on remote server ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15205 ,16 ,0 ,'There are no servers defined.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15206 ,16 ,0 ,'Invalid Remote Server Option: ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15210 ,16 ,0 ,'Only members of the sysadmin role can use the loginame option. The password was not changed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15211 ,16 ,0 ,'Old (current) password incorrect for user. The password was not changed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15216 ,16 ,0 ,'''%s'' is not a valid option for the @delfile parameter.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15217, 16, 0, 'Property cannot be updated or deleted. Property ''%s'' does not exist for ''%s''.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15218 ,16 ,0 ,'Object ''%s'' is not a table.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15220 ,16 ,0 ,'Usage: sp_remoteoption [remoteserver, loginame, remotename, optname, {true | false}]' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15221 ,16 ,0 ,'Remote login option does not exist or cannot be set by user. Run sp_remoteoption with no parameters to see options.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15222 ,16 ,0 ,'Remote login option ''%s'' is not unique.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15223 ,11 ,0 ,'Error: The input parameter ''%s'' is not allowed to be null.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15224 ,11 ,0 ,'Error: The value for the @newname parameter contains invalid characters or violates a basic restriction (%s).' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15225 ,11 ,0 ,'No item by the name of ''%s'' could be found in the current database ''%s'', given that @itemtype was input as ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15227 ,16 ,0 ,'The database ''%s'' cannot be renamed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15228 ,16 ,0 ,'A member of the sysadmin role must set database ''%s'' to single user mode with sp_dboption before it can be renamed.' ,1033)


-- 15229-15232 Available
Go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15233, 16,0,'Property cannot be added. Property ''%s'' already exists for ''%s''.', 1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15234 ,16 ,0 ,'Object is stored in sysprocedures and has no space allocated directly.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15235 ,16 ,0 ,'Views do not have space allocated.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15236 ,16 ,0 ,'Column ''%s'' has no default.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15237 ,16 ,0 ,'User data type ''%s'' has no default.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15238 ,16 ,0 ,'Column ''%s'' has no rule.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15239 ,16 ,0 ,'User data type ''%s'' has no rule.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15241 ,16 ,0 ,'Usage: sp_dboption [dbname [,optname [,''true'' | ''false'']]]' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15242 ,16 ,0 ,'Database option ''%s'' is not unique.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15243 ,16 ,0 ,'The option ''%s'' cannot be changed for the master database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15244 ,16 ,0 ,'Only members of the sysadmin role or the database owner may set database options.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15245 ,16 ,0 ,'DBCC DBCONTROL error. Database was not placed offline.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15247, 16,0,'User does not have permission to perform this action.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15248 ,11 ,0 ,'Either the parameter @objname is ambiguous or the claimed @objtype (%s) is wrong.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15249 ,11 ,0 ,'Error: Explicit @itemtype ''%s'' is unrecognized (%d).' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15250 ,16 ,0 ,'The database name component of the object qualifier must be the name of the current database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15251 ,16 ,0 ,'Invalid ''%s'' specified. It must be %s.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15252 ,16 ,0 ,'The primary or foreign key table name must be given.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(15253,11,0,'Syntax error parsing SQL identifier ''%s''.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15254 ,16 ,0 ,'Users other than the database owner or guest exist in the database. Drop them before removing the database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15255 ,11 ,0 ,'''%s'' is not a valid value for @autofix. The only valid value is ''auto''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15256 ,16 ,0 ,'Usage: sp_certify_removable <dbname> [,''auto'']' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15257 ,16 ,0 ,'The database that you are attempting to certify cannot be in use at the same time.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15258 ,16 ,0 ,'The database must be owned by a member of the sysadmin role before it can be removed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15261 ,16 ,0 ,'Usage: sp_create_removable <dbname>,<syslogical>,<sysphysical>,<syssize>,<loglogical>,<logphysical>,<logsize>,<datalogical1>,<dataphysical1>,<datasize1> [,<datalogical2>,<dataphysical2>,<datasize2>...<datalogical16>,<dataphysical16>,<datasize16>]' ,1033)

Go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15262 ,0 ,0 ,'Invalid file size entered. All files must be at least 1 MB.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15264 ,16 ,0 ,'Could not create the ''%s'' portion of the database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15266 ,16 ,0 ,'Cannot make ''%s'' database removable.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15269 ,16 ,0 ,'Logical data device ''%s'' not created.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15270 ,16 ,0 ,'You cannot specify a length for user data types based on sysname.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15271 ,16 ,0 ,'Invalid @with_log parameter value. Valid values are ''true'' or ''false''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15275 ,16 ,0 ,'FOREIGN KEY constraints do not have space allocated.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15277 ,16 ,0 ,'The only valid @parameter_value values are ''true'' or ''false''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15278 ,16 ,0 ,'Login ''%s'' is already mapped to user ''%s'' in database ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15279 ,16 ,0 ,'You must add the us_english version of this message before you can add the ''%s'' version.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15280 ,16 ,0 ,'All localized versions of this message must be dropped before the us_english version can be dropped.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15283 ,16 ,0 ,'The name ''%s'' contains too many characters.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15284 ,16 ,0 ,'The user has granted or revoked privileges to the following in the database and cannot be dropped.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15285 ,16 ,0 ,'The special word ''%s'' cannot be used for a logical device name.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15286 ,16 ,0 ,'Terminating this procedure. The @action ''%s'' is unrecognized. Try ''REPORT'', ''UPDATE_ONE'', or ''AUTO_FIX''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15287 ,16 ,0 ,'Terminating this procedure. ''%s'' is a forbidden value for the login name parameter in this procedure.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15289 ,16 ,0 ,'Terminating this procedure. Cannot have an open transaction when this is run.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15290 ,16 ,0 ,'Terminating this procedure. The Action ''%s'' is incompatible with the other parameter values (''%s'', ''%s'').' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15291 ,16 ,0 ,'Terminating this procedure. The %s name ''%s'' is absent or invalid.' ,1033)

Go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15292 ,0 ,0 ,'The row for user ''%s'' will be fixed by updating its login link to a login already in existence.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15293 ,0 ,0 ,'Barring a conflict, the row for user ''%s'' will be fixed by updating its link to a new login. Consider changing the new password from null.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15294 ,0 ,0 ,'The number of orphaned users fixed by adding new logins and then updating users was %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15295 ,0 ,0 ,'The number of orphaned users fixed by updating users was %d.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15298 ,0 ,0 ,'New login created.' ,1033)

GO
backup Transaction master with no_log
GO
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15300 ,11 ,0 ,'No recognized letter is contained in the parameter value for General Permission Type (%s). Valid letters are in this set: %s .' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15301, 16, 0, 'Collation ''%s'' is supported for Unicode data types only and cannot be set at either the database or server level.', 1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15302 ,11 ,0 ,'Database_Name should not be used to qualify owner.object for the parameter into this procedure.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15303 ,11 ,0 ,'The "user options" config value (%d) was rejected because it would set incompatible options.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15304 ,16 ,0 ,'The severity level of the ''%s'' version of this message must be the same as the severity level (%ld) of the us_english version.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15305 ,16 ,0 ,'The @TriggerType parameter value must be ''insert'', ''update'', or ''delete''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15306 ,16 ,0 ,'Cannot change the compatibility level of replicated or distributed databases.',1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	( 15307 ,16 ,0 , 'Could not change the merge publish option because the server is not set up for replication.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15308 ,16 ,0 ,'You must set database ''%s'' to single user mode with sp_dboption before fixing indexes on system tables.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15311 ,16 ,0 ,'The file named ''%s'' does not exist.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15312 ,16 ,0 ,'The file named ''%s'' is a primary file and cannot be removed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15318 ,0 ,0 ,'All fragments for database ''%s'' on device ''%s'' are now dedicated for log usage only.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15319 ,17 ,0 ,'Error: DBCC DBREPAIR REMAP failed for database ''%s'' (device ''%s'').' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15321 ,16 ,0 ,'There was some problem removing ''%s'' from sysaltfiles.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15322 ,0 ,0 ,'File ''%s'' was removed from tempdb, and will take effect upon server restart.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15323 ,16 ,0 ,'The selected index does not exist on table ''%s''.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15324 ,16 ,0 ,'The option %s cannot be changed for the ''%s'' database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15325 ,16 ,0 ,'The current database does not contain a %s named ''%ls''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15326 ,0 ,0 ,'No extended stored procedures exist.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15327 ,0 ,0 ,'The database is now offline.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15328,0 ,0 ,'The database is offline already.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15330 ,11 ,0 ,'There are no matching rows on which to report.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15331 ,11 ,0 ,'The user ''%s'' cannot take the action auto_fix due to duplicate SID.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15333 ,11 ,0 ,'Error: The qualified @oldname references a database (%s) other than the current database.' ,1033)

Go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15335 ,11 ,0 ,'Error: The @newname value ''%s'' is already in use as a %s name and would cause a duplicate that is not permitted.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15336 ,16 ,0 ,'Object ''%s'' cannot be renamed because the object participates in enforced dependencies.' ,1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15337 ,0 ,0 ,'Caution: sysdepends shows that other objects (views, procedures and so on) are referencing this object by its old name. These objects will become invalid, and should be dropped and re-created promptly.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15338 ,0 ,0 ,'The %s was renamed to ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15339 ,0 ,0 ,'Creating ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15340 ,0 ,0 ,'Alias user added.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15341 ,0 ,0 ,'Granted database access to ''%s''.' ,1033)


---- For sp_fallback_ (approx 15344-15385)  1996/02/28 13:31


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15354 ,0 ,0 ,'Usage: sp_detach_db <dbname>, [TRUE|FALSE]' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15355 ,10 ,0 ,'''sys'' will be a reserved user or role name in next version of SQL Server.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15358 ,0 ,0 ,'User-defined filegroups should be made read-only.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15363 ,16 ,0 ,'The role ''%s'' already exists in the current database.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15379 ,11 ,0 ,'The server option value ''%s'' supplied is unrecognized.' ,1033)


---- For sp_tableoption approx 15386-15392

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
   (15394, 16, 0,  'Collation ''%s'' is not supported by the operating system', 1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15387 ,11 ,0 ,'If the qualified object name specifies a database, that database must be the current database.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15388 ,11 ,0 ,'There is no user table matching the input name ''%s'' in the current database.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 	-- for sp_autostats
	values
	(15390, 11 ,0 ,'Input name ''%s'' does not have a matching user table or indexed view in the current database.' ,1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15395 ,11 ,0 ,'The qualified old name could not be found for item type ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15398 ,11 ,0 ,'Only objects in the master database owned by dbo can have the startup setting changed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15399 ,11 ,0 ,'Could not change startup option because this option is restricted to objects that have no parameters.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15401 ,11 ,0 ,'Windows NT user or group ''%s'' not found. Check the name again.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15402 ,11 ,0 ,'''%s'' is not a fixed server role.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15405 ,11 ,0 ,'Cannot use the reserved user or role name ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15407 ,11 ,0 ,'''%s'' is not a valid Windows NT name. Give the complete name: <domain\username>.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15409 ,11 ,0 ,'''%s'' is not a role.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15410 ,11 ,0 ,'User or role ''%s'' does not exist in this database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15412 ,11 ,0 ,'''%s'' is not a known fixed role.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15413 ,11 ,0 ,'Cannot make a role a member of itself.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15414, 16 ,0 ,'Cannot set compatibility level because database has a view or computed column that is indexed. These indexes require a SQL Server compatible database.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15415 ,11 ,0 ,'User is a member of more than one group. sp_changegroup is set up for backward compatibility and expects membership in one group at most.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15416 ,16 ,0 ,'Usage: sp_dbcmptlevel [dbname [, compatibilitylevel]]', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15417 ,16 ,0 ,'Cannot change the compatibility level of the ''%s'' database.' ,1033)	
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15418 ,16 ,0 ,'Only members of the sysadmin role or the database owner may set the database compatibility level.' ,1033)	
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15419 ,16 ,0 ,'Supplied parameter @sid should be binary(16).',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15420 ,16 ,0 ,'The group ''%s'' does not exist in this database.' ,1033)	
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15421 ,16 ,0 ,'The user owns role(s) in the database and cannot be dropped.' ,1033)	
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15422 ,16 ,0 ,'Application roles can only be activated at the ad hoc level.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15423 ,0 ,0 ,'The password for application role ''%s'' has been changed.' ,1033)	
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15424 ,0 ,0 ,'New role added.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15425 ,0 ,0 ,'New application role added.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(15426,16,0,'You must specify a provider name with this set of properties.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(15427,16,0,'You must specify a provider name for unknown product ''%ls''.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(15428,16,0,'You cannot specify a provider or any properties for product ''%ls''.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(15429,16,0,'''%ls'' is an invalid product name.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(15430,19,0,'Limit exceeded for number of servers.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15431 ,16 ,0 ,'You must specify the @rolename parameter.' ,1033)	
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15432 ,16 ,0 ,'Stored procedure ''%s'' can only be executed at the ad hoc level.' ,1033)	
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15433 ,16 ,0 ,'Supplied parameter @sid is in use.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15434 ,16 ,0 ,'Could not drop login ''%s'' as the user is currently logged in.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15435,0 ,0 ,'Database successfully published.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15436,0 ,0 ,'Database successfully enabled for subscriptions.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15437,0 ,0 ,'Database successfully published using merge replication.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15438,0 ,0 ,'Database is already online.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15439,0 ,0 ,'Database is now online.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15440,0 ,0 ,'Database is no longer published.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15441,0 ,0 ,'Database is no longer enabled for subscriptions.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15442,0 ,0 ,'Database is no longer enabled for merge publications.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15443,0 ,0 ,'Checkpointing database that was changed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15444,0 ,0 ,'''Disk'' device added.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15445,0 ,0 ,'''Diskette'' device added.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15446,0 ,0 ,'''Tape'' device added.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15447,0 ,0 ,'''Pipe'' device added.' ,1033)
-- 15448 available
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15449,0 ,0 ,'Type added.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15450 ,0 ,0 ,'New language inserted.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15452,0 ,0 ,'No alternate languages are available.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15453,0 ,0 ,'us_english is always available, even though it is not in syslanguages.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15454,0 ,0 ,'Language deleted.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15456,0 ,0 ,'Valid configuration options are:' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15457,0 ,0 ,'Configuration option ''%ls'' changed from %ld to %ld. Run the RECONFIGURE statement to install.' ,1033)

go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15458,0 ,0 ,'Database removed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15459,0 ,0 ,'In the current database, the specified object references the following:' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15460,0 ,0 ,'In the current database, the specified object is referenced by the following:' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15461,0 ,0 ,'Object does not reference any object, and no objects reference it.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15462,0 ,0 ,'File ''%s'' closed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15463,0 ,0 ,'Device dropped.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15467,0 ,0 ,'Type has been dropped.' ,1033)
-- 15468 available
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15469,0 ,0 ,'No constraints have been defined for this object.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15470,0 ,0 ,'No foreign keys reference this table.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15471,0 ,0 ,'The object comments have been encrypted.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15472,0 ,0 ,'The object does not have any indexes.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15473,0 ,0 ,'Settable remote login options.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15475,0 ,0 ,'The database is renamed and in single user mode.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15476,0 ,0 ,'A member of the sysadmin role must reset the database to multiuser mode with sp_dboption.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15477,0 ,0 ,'Caution: Changing any part of an object name could break scripts and stored procedures.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15478,0 ,0 ,'Password changed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15479,0 ,0 ,'Login dropped.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15480,0 ,0 ,'Could not grant login access to ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15481,0 ,0 ,'Granted login access to ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15482,0 ,0 ,'Could not deny login access to ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15483,0 ,0 ,'Denied login access to ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15484,0 ,0 ,'Could not revoke login access from ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15485,0 ,0 ,'Revoked login access from ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15486,0 ,0 ,'Default database changed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15487,0 ,0 ,'%s''s default language is changed to %s.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15488,0 ,0 ,'''%s'' added to role ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15489,0 ,0 ,'''%s'' dropped from role ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15490,0 ,0 ,'The dependent aliases were also dropped.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15491,0 ,0 ,'User has been dropped from current database.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15492,0 ,0 ,'Alias user dropped.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15493,0 ,0 ,'Role dropped.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15494,0 ,0 ,'The application role ''%s'' is now active.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15495,0 ,0 ,'Application role dropped.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15496,0 ,0 ,'Group changed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15497,0 ,0 ,'Could not add login using sp_addlogin (user = %s). Terminating this procedure.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15498,17,127,'Inside txn_1a_, update failed. Will roll back (1a1).' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15499,0 ,0 ,'The dependent aliases were mapped to the new database owner.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15500,0 ,0 ,'The dependent aliases were dropped.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15501,0 ,0 ,'Database owner changed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15502,0 ,0 ,'Setting database owner to SA.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15503,0 ,0 ,'Giving ownership of all objects to the database owner.' ,1033)	
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15504,0 ,0 ,'Deleting users except guest and the database owner from sysusers.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15505 ,16 ,0 ,'Cannot change owner of object ''%ls'' or one of its child objects because the new owner ''%ls'' already has an object with the same name.' ,1033)
go


-- 15506-15510 available
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15511,0 ,0 ,'Default bound to column.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15512,0 ,0 ,'Default bound to data type.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15513,0 ,0 ,'The new default has been bound to columns(s) of the specified user data type.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15514,0 ,0 ,'Rule bound to table column.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15515,0 ,0 ,'Rule bound to data type.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15516,0 ,0 ,'The new rule has been bound to column(s) of the specified user data type.' ,1033)
-- 15517,15518 available
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15519,0 ,0 ,'Default unbound from table column.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15520,0 ,0 ,'Default unbound from data type.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15521,0 ,0 ,'Columns of the specified user data type had their defaults unbound.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15522,0 ,0 ,'Rule unbound from table column.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15523,0 ,0 ,'Rule unbound from data type.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15524,0 ,0 ,'Columns of the specified user data type had their rules unbound.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15525,0 ,0 ,'sp_checknames is used to search for non 7-bit ASCII characters.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15526,0 ,0 ,'in several important columns of system tables. The following' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15527,0 ,0 ,'columns are searched:' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15528,0 ,0 ,'    In master:' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15536,0 ,0 ,'    In all databases:' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15543,0 ,0 ,'Looking for non 7-bit ASCII characters in the system tables of database ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15544,0 ,0 ,'Table.column ''%s''' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15545,0 ,0 ,'The following database names contain non 7-bit ASCII characters.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15546,0 ,0 ,'If you wish to change these names, use ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15547,0 ,0 ,'The following logins have default database names that contain' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15548,0 ,0 ,'non 7-bit ASCII characters. If you wish to change these names use' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15549,0 ,0 ,'sp_defaultdb.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15550,0 ,0 ,'The following servers have ''initialization file'' names that contain' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15551,0 ,0 ,'non 7-bit ASCII characters. If you wish to change these names,' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15552,0 ,0 ,'use UPDATE.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15553,0 ,0 ,'Database ''%s'' has no object, user, and so on' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15554,0 ,0 ,'names that contain non 7-bit ASCII characters.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15555,0 ,0 ,'The database name provided ''%s'' must be the current database when executing this stored procedure.' ,1033)
GO
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15564,0 ,0 ,'The following device names contain non 7-bit ASCII characters.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15565,0 ,0 ,'The following login names contain non 7-bit ASCII characters.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15566,0 ,0 ,'The following remote login names contain non 7-bit ASCII characters.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15567,0 ,0 ,'The following server names contain non 7-bit ASCII characters.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15568,0 ,0 ,'The following column and parameter names contain non 7-bit ASCII characters.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15569,0 ,0 ,'The following index names contain non 7-bit ASCII characters.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15570,0 ,0 ,'The following object names contain non 7-bit ASCII characters.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15571,0 ,0 ,'The following segment names contain non 7-bit ASCII characters.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15572,0 ,0 ,'The following data type names contain non 7-bit ASCII characters.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 15573,0 ,0 ,'The following user or role names contain non 7-bit ASCII characters.' ,1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(15574, 10, 0,'This object does not have any statistics.', 1033)
go

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(15575, 10, 0,'This object does not have any statistics or indexes.', 1033)
go


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(15576,16,0,'You cannot set network name on server ''%ls'' because it is not a linked SQL Server.',1033)
	go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(15577,10,0,'Warning: A linked server that refers to the originating server is not a supported scenario.  If you wish to use a four-part name to reference a local table, please use the actual server name rather than an alias.',1033)
	go

GO
--- RESERVE 15600-15699 for sp_fulltext_*
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(15600, 15, 0, 'An invalid parameter or option was specified for procedure ''%s''.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(15601, 16, 0,'Full-Text Search is not enabled for the current database. Use sp_fulltext_database to enable Full-Text Search.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(15604, 16, 0, 'Cannot drop full-text catalog ''%ls'' because it contains a full-text index.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(15605, 16, 0, 'A full-text index for table ''%ls'' has already been created.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(15606, 16, 0, 'You must first create a full-text index on table ''%ls''.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(15607, 16, 0, '''%ls'' is not a valid index to enforce a full-text search key. You must specify a unique, non-nullable, single-column index.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(15608, 16, 0, 'Full-text search has already been activated for table ''%ls''.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(15609, 16, 0, 'Cannot activate full-text search for table ''%ls'' because no columns have been enabled for full-text search.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(15610, 16, 0, 'You must deactivate full-text search on table ''%ls'' before adding columns to or removing columns from the full-text index.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(15611, 16, 0, 'Column ''%ls'' of table ''%ls'' cannot be used for full-text search because it is not a character-based column.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(15612 ,16 ,0 ,'DBCC DBCONTROL error. Database was not made read-only.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15613 ,0 ,0 ,'The database is now read-only.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15614 ,0 ,0 ,'The database already is read-only.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(15615 ,16 ,0 ,'DBCC DBCONTROL error. Database was not made single user.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15616 ,0 ,0 ,'The database is now single user.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15617 ,0 ,0 ,'The database already is single user.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15618 ,0 ,0 ,'The database is now read/write.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15619 ,0 ,0 ,'The database already is read/write.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15620 ,0 ,0 ,'The database is now multiuser.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15621 ,0 ,0 ,'The database already is multiuser.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15622 ,10 ,0 ,'No permission to access database ''%s''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (15623 ,10 ,0 ,'Enabling %ls option for database ''%ls''.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (15624 ,10 ,0 ,'Disabling %ls option for database ''%ls''.' ,1033)


go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (15625 ,10 ,0 ,'Option ''%ls'' not recognized for ''%ls'' parameter.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (15626 ,10 ,0 ,'You attempted to acquire a transactional application lock without an active transaction.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
    (15627 ,10 ,0 ,'sp_dboption command failed.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(15630, 16, 0, 'Full-text search must be activated on table ''%ls'' before this operation can be performed.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(15631, 16, 0, 'Full-text change tracking is currently enabled for table ''%ls''.', 1033)
go

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(15632, 16, 0, 'Full-text change tracking must be started on table ''%ls'' before full-text auto propagation can begin.', 1033)
go
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(15633, 16, 0, 'Full-text auto propagation is currently enabled for table ''%ls''.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(15634, 16, 0, 'Full-text change tracking must be started on table ''%ls'' before the changes can be flushed.', 1033)
go

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(15635, 16, 0,'Cannot execute ''%ls'' because the database is in read-only access mode.' ,1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(15636, 16, 0,'Full-text catalog ''%ls'' cannot be populated because the database is in single-user access mode.' ,1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(15637, 16, 0,'Full-text index for table ''%ls'' cannot be populated because the database is in single-user access mode.' ,1033)


insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(15638, 10, 0,'Warning: Full-text index for table ''%ls'' cannot be populated because the database is in single-user access mode. Change tracking is stopped for this table. Use sp_fulltext_table to start change tracking.' ,1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(15639, 10, 0,'Warning: Table ''%s'' does not have the option ''text in row'' enabled and has full-text indexed columns that are of type image, text, or ntext. Full-text change tracking cannot track WRITETEXT or UPDATETEXT operations performed on these columns.' ,1033)

go



insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(15640, 16, 0,'sp_fulltext_table ''start_full'' must be executed on table ''%ls''. Columns affecting the index have been added or dropped since the last index full population.', 1033)


insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(15642, 16, 0,'The ongoing population is necessary to ensure an up-to-date index. If needed, stop change tracking, and then deactivate the full-text index population.', 1033)
go

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(15643, 10, 0,'Warning: This operation did not succeed on one or more tables. A table may be inactive, or a full-text index population may already be active.', 1033)
go

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(15644, 16, 0,'Full-text index population failed to start on this table. Execute sp_fulltext_table ''%ls'', ''%ls'' to update the index.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15645 ,16 ,0 ,'Column ''%ls'' does not exist.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(15646 ,16 ,0 ,'Column ''%ls'' is not a computed column.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
    (15647 ,10 ,0 ,'No views with schema binding reference this table.' ,1033)

GO
backup Transaction master with no_log
GO

raiserror(' ',0,1)
raiserror('Adding Web Server messages.',0,1)

raiserror('sysmessages.error>=16000 ....',0,1) with nowait

GO

---- The message range 16800 to 16899 is reserved for Web Server messages

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16801 ,11 ,0 ,'sp_dropwebtask requires at least one defined parameter @outputfile or @procname.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16802 ,11 ,0 ,'sp_dropwebtask cannot find the specified task.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16803 ,11 ,0 ,'sp_runwebtask requires at least one defined parameter @outputfile or @procname.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16804 ,11 ,0 ,'SQL Web Assistant: Could not establish a local connection to SQL Server.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16805 ,11 ,0 ,'SQL Web Assistant: Could not execute the SQL statement.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16806 ,11 ,0 ,'SQL Web Assistant: Could not bind the parameter to the SQL statement.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16807 ,11 ,0 ,'SQL Web Assistant: Could not obtain a bind token.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16808 ,11 ,0 ,'SQL Web Assistant: Could not find the existing trigger. This could be due to encryption.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16809 ,11 ,0 ,'SQL Web Assistant failed on the call to SQLGetData.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16810 ,11 ,0 ,'SQL Web Assistant failed on the call to SQLFetch.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16811 ,11 ,0 ,'SQL Web Assistant failed to bind a results column.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16812 ,11 ,0 ,'SQL Web Assistant: The @query parameter must be specified.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16813 ,11 ,0 ,'SQL Web Assistant: Parameters can be passed either by name or position.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16814 ,11 ,0 ,'SQL Web Assistant: Invalid parameter.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16815 ,11 ,0 ,'SQL Web Assistant: @procname is not valid.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16816 ,11 ,0 ,'SQL Web Assistant: @outputfile is not valid.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16817 ,11 ,0 ,'SQL Web Assistant: Could not read the given file.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16820 ,11 ,0 ,'SQL Web Assistant failed because the state of the Web task in msdb..MSwebtasks is invalid.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16821 ,11 ,0 ,'SQL Web Assistant: Could not open the output file.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16822 ,11 ,0 ,'SQL Web Assistant: Could not open the template file.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16823 ,11 ,0 ,'SQL Web Assistant: Could not allocate enough memory to satisfy this request.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16824 ,11 ,0 ,'SQL Web Assistant: The template file specified in the Web task has a bad size.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16825 ,11 ,0 ,'SQL Web Assistant: Could not read the template file.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16826 ,11 ,0 ,'SQL Web Assistant: Could not find the specified marker for data insertion in the template file.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16827 ,11 ,0 ,'SQL Web Assistant: Could not write to the output file.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16828 ,11 ,0 ,'SQL Web Assistant: @tabborder must be tinyint.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16829 ,11 ,0 ,'SQL Web Assistant: @singlerow must be 0 or 1. Cannot specify this parameter with @nrowsperpage.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16830 ,11 ,0 ,'SQL Web Assistant: The @blobfmt parameter specification is invalid.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16831 ,11 ,0 ,'SQL Web Assistant: The output file name is mandatory for every column specified in the @blobfmt parameter.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16832 ,11 ,0 ,'SQL Web Assistant: Procedure called with too many parameters.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16833 ,11 ,0 ,'SQL Web Assistant: @nrowsperpage must be a positive number and it cannot be used with @singlerow.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16834 ,11 ,0 ,'SQL Web Assistant: Read/write operation on text, ntext, or image column failed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16838 ,11 ,0 ,'SQL Web Assistant: Could not find the table in the HTML file.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16839 ,11 ,0 ,'SQL Web Assistant: Could not find the matching end table tag in the HTML file.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16841 ,11 ,0 ,'SQL Web Assistant: The @datachg parameter cannot be specified with the given @whentype value.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16842 ,11 ,0 ,'SQL Web Assistant: Could not find and drop the necessary trigger for updating the Web page.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16843 ,11 ,0 ,'SQL Web Assistant: Could not add the necessary trigger for the @datachg parameter. There could be an existing trigger on the table with missing or encrypted text.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16844 ,11 ,0 ,'SQL Web Assistant: Incorrect syntax for the @datachg parameter.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16845 ,11 ,0 ,'SQL Web Assistant: @datachg must be specified for the given @whentype option.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16846 ,11 ,0 ,'SQL Web Assistant: @unittype and/or @numunits must be specified for the given @whentype option.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16847 ,11 ,0 ,'SQL Web Assistant: @fixedfont must be 0 or 1.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16848 ,11 ,0 ,'SQL Web Assistant: @bold must be 0 or 1.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16849 ,11 ,0 ,'SQL Web Assistant: @italic must be 0 or 1.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16850 ,11 ,0 ,'SQL Web Assistant: @colheaders must be 0 or 1.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16851 ,11 ,0 ,'SQL Web Assistant: @lastupdated must be 0 or 1.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16852 ,11 ,0 ,'SQL Web Assistant: @HTMLheader must be in the range 1 to 6.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16853 ,11 ,0 ,'SQL Web Assistant: @username is not valid.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16854 ,11 ,0 ,'SQL Web Assistant: @dbname is not valid.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16855 ,11 ,0 ,'SQL Web Assistant: @whentype must be in the range 1 to 9.' ,1033)
GO

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16856 ,11 ,0 ,'SQL Web Assistant: @unittype must be in the range 1 to 4.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16857 ,11 ,0 ,'SQL Web Assistant: @targetdate is invalid. It must be a valid date after 1900-01-01.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16858 ,11 ,0 ,'SQL Web Assistant: The @targettime parameter must be between 0 and 240000.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16859 ,11 ,0 ,'SQL Web Assistant: @dayflags must be 1, 2, 4, 8, 16, 32, or 64.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16860 ,11 ,0 ,'SQL Web Assistant: @numunits must be greater than 0.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16861 ,11 ,0 ,'SQL Web Assistant: @targetdate must be specified for the given @whentype option.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16862 ,11 ,0 ,'SQL Web Assistant: @dayflags must be specified for the given @whentype option.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16863 ,11 ,0 ,'SQL Web Assistant: URL specification is invalid.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16864 ,11 ,0 ,'SQL Web Assistant: @blobfmt is invalid. The file must include the full path to the output_file location.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16865 ,11 ,0 ,'SQL Web Assistant: URL hyperlink text column must not be of the image data type.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16866 ,11 ,0 ,'SQL Web Assistant: Could not obtain the number of columns in @query.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16867 ,11 ,0 ,'SQL Web Assistant: URL hyperlink text column is missing in @query.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16868 ,11 ,0 ,'SQL Web Assistant failed on the call to SQLColAttribute.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16869 ,11 ,0 ,'SQL Web Assistant: Columns of data type image cannot have a template.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16870 ,11 ,0 ,'SQL Web Assistant: Internal error. Could not read @ parameters.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16871 ,11 ,0 ,'SQL Web Assistant: Invalid @charset. Execute sp_enumcodepages for a list of character sets.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16873 ,11 ,0 ,'SQL Web Assistant: Invalid @codepage. Execute sp_enumcodepages for a list of code pages.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16874 ,11 ,0 ,'SQL Web Assistant: Internal error. Cannot translate to the specified code page.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16875 ,11 ,0 ,'SQL Web Assistant: Translation to the desired code page is unavailable on this system.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16876 ,11 ,0 ,'SQL Web Assistant: Internal error. Could not obtain COM interface ID.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16877 ,11 ,0 ,'SQL Web Assistant: Internal error. Could not obtain COM language ID.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16878 ,11 ,0 ,'SQL Web Assistant: Internal error. Could not initialize COM library.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16879 ,11 ,0 ,'SQL Web Assistant: Internal error. Could not translate from Unicode to the specified code page.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16880 ,11 ,0 ,'SQL Web Assistant: Internal error. Could not create translation object. Make sure that the file MLang.dll is in your system directory.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(16881 ,16 ,0 ,'SQL Web Assistant: This version is not supported on Win32s of Windows 3.1.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(16882, 16, 0, 'SQL Web Assistant: Web task not found. Verify the name of the task for possible errors.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (16883, 16, 0, 'SQL Web Assistant: Could not list Web task parameters. xp_readwebtask requires @procname.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (16884, 16, 0, 'SQL Web Assistant: Procedure name is required to convert Web tasks.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (16885, 16, 0, 'SQL Web Assistant: Could not upgrade the Web task to 7.0. The Web task will remain in 6.5 format and will need to be re-created.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (16886, 16, 0, 'SQL Web Assistant: Could not update Web tasks system table. The Web task remains in 6.5 format.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (16887, 16, 0, 'SQL Web Assistant: @procname parameter is missing. The parameter is required to upgrade a Web task to 7.0.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (16888, 16, 0, 'SQL Web Assistant: Source code page is not supported on the system.  Ensure @charset and @codepage language files are installed on your system.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (16889, 16, 0, 'SQL Web Assistant: Could not send Web task row to the client.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (16890, 16, 0, 'SQL Web Assistant: ODS error occurred. Could not send Web task parameters.', 1033)

GO

raiserror(' ',0,1)
raiserror('Adding cursor messages.',0,1) with nowait

GO

---- The message range 16900 to 16999 is reserved for cursor related messages


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16901 ,16 ,1 ,'%hs: This feature has not been implemented yet.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16902 ,16 ,1 ,'%hs: The value of parameter %hs is invalid.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16903 ,16 ,1 ,'%hs procedure called with incorrect number of parameters.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16904 ,16 ,1 ,'sp_cursor: optype: You can only specify ABSOLUTE in conjunction with DELETE or UPDATE.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16905 ,16 ,1 ,'The cursor is already open.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16907 ,16 ,1 ,'%hs is not allowed in cursor statements.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16909 ,16 ,1 ,'%hs: The cursor identifier value provided (%x) is not valid.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16911 ,16 ,1 ,'%hs: The fetch type %hs cannot be used with forward only cursors.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16914 ,16 ,1 ,'%hs procedure called with too many parameters.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16915 ,16 ,1 ,'A cursor with the name ''%.*ls'' already exists.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16916 ,16 ,1 ,'A cursor with the name ''%.*ls'' does not exist.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16917 ,16 ,1 ,'Cursor is not open.' ,1033)
GO
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16922 ,16 ,0 ,'Cursor Fetch: Implicit conversion from data type %s to %s is not allowed.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16924 ,16 ,1 ,'Cursorfetch: The number of variables declared in the INTO list must match that of selected columns.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16925 ,16 ,1 ,'The fetch type %hs cannot be used with dynamic cursors.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16926 ,16 ,1 ,'sp_cursoroption: The column ID (%d) does not correspond to a text, ntext, or image column.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16927, 16, 0,'Cannot fetch into text, ntext, and image variables.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16929 ,16 ,1 ,'The cursor is READ ONLY.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16930 ,16 ,1 ,'The requested row is not in the fetch buffer.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16931 ,16 ,1 ,'There are no rows in the current fetch buffer.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16932 ,16 ,1 ,'The cursor has a FOR UPDATE list and the requested column to be updated is not in this list.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16933 ,16 ,1 ,'The cursor does not include the table being modified or the table is not updatable through the cursor.' ,1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16934 ,16 ,1 ,'Optimistic concurrency check failed. The row was modified outside of this cursor.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16935 ,16 ,1 ,'No parameter values were specified for the sp_cursor-%hs statement.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16936 ,16 ,1 ,'sp_cursor: One or more values parameters were invalid.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16937 ,16 ,1 ,'A server cursor is not allowed on a remote stored procedure or stored procedure with more than one SELECT statement. Use a default result set or client cursor.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 16938 ,16 ,0 ,'sp_cursoropen/sp_cursorprepare: The statement parameter can only be a single select or a single stored procedure.' ,1033)
GO
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16940 ,16 ,1 ,'Cannot specify UPDLOCK or TABLOCKX with READ ONLY or INSENSITIVE cursors.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16941 ,16 ,1 ,'Cursor updates are not allowed on tables opened with the NOLOCK option.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16942 ,16 ,1 ,'Could not generate asynchronous keyset. The cursor has been deallocated.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16943 ,16 ,1 ,'Could not complete cursor operation because the table schema changed after the cursor was declared.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16944 ,16 ,1 ,'Cannot specify UPDLOCK or TABLOCKX on a read-only table in a cursor.' ,1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(16945,16,1,'The cursor was not declared.', 1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(16946,16,1,'Could not open the cursor because one or more of its tables have gone out of scope.',
	1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values(16947, 10, 1,'No rows were updated or deleted.',
	1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16948 ,16 ,0 ,'The variable ''%.*ls'' is not a cursor variable, but it is used in a place where a cursor variable is expected.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16949 ,16 ,0 ,'The variable ''%.*ls'' is a cursor variable, but it is used in a place where a cursor variable is not valid.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16950 ,10 ,0 ,'The variable ''%.*ls'' does not currently have a cursor allocated to it.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16951 ,16 ,0 ,'The variable ''%.*ls'' cannot be used as a parameter because a CURSOR OUTPUT parameter must not have a cursor allocated to it before execution of the procedure.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16952 ,16 ,0 ,'A cursor variable cannot be used as a parameter to a remote procedure call.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16953 ,10 ,0 ,'Remote tables are not updatable. Updatable keyset-driven cursors on remote tables require a transaction with the REPEATABLE_READ or SERIALIZABLE isolation level spanning the cursor.' ,1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	( 16954 ,16 ,0 ,'Executing SQL directly; no cursor.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(16955, 16, 0, 'Could not create an acceptable cursor.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(16956, 10, 0, 'Cursor created was not of the requested type.', 1033)


	insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16957, 16, 0,'FOR UPDATE cannot be specified on a READ ONLY cursor.', 1033) 


	insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16958, 16, 0,'Could not complete cursor operation because the set options have changed since the cursor was declared.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16959, 16, 0,'Unique table computation failed.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(16960, 16, 0,'You have reached the maximum number of cursors allowed.', 1033)

insert into master..sysmessages(error, severity, dlevel, description, msglangid)
	values
	(16961, 10, 0,'One or more FOR UPDATE columns have been adjusted to the first instance of their table in the query.', 1033)
go
	insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16962, 16, 0,'The target object type is not updatable through a cursor.', 1033)
	insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16963, 16, 0,'You cannot specify scroll locking on a cursor that contains a remote table.', 1033)
go

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(16996, 16, 0, '%hs cannot take output parameters.', 1033)
go



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16998 ,20 ,1 ,'Internal Cursor Error: A cursor work table operation failed.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(16999 ,20 ,1 ,'Internal Cursor Error: The cursor is in an invalid state.' ,1033)
GO
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
        values
        (17000 ,10 ,0 ,'Usage: sp_autostats <table_name> [, {ON|OFF} [, <index_name>] ]' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(17050, 10, 0, 'The ''%ls'' option is ignored in this edition of SQL Server.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (17550 ,10 ,0 ,'DBCC TRACEON %d, server process ID (SPID) %d.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (17551 ,10 ,0 ,'DBCC TRACEOFF %d, server process ID (SPID) %d.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(17557, 16, 128, 'DBCC DBRECOVER failed for database ID %d.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(17558, 10, 128, '*** Bypassing recovery for database ID %d.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(17560, 10, 128, 'DBCC DBREPAIR: ''%ls'' index restored for ''%ls.%ls''.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(17561, 10, 128, '%ls index restored for %ls.%ls.', 1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(17569, 16, 128, 'DBCC cannot find the library initialization function %ls.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(17570, 16, 128, 'DBCC cannot find the function %ls in the library %ls.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(17571, 20, 128, 'DBCC function %ls in the library %ls generated an access violation. SQL Server is terminating process %d.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(17572, 16, 128, 'DBCC cannot free DLL %ls. SQL Server depends on this DLL to function properly.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(17750, 16, 128, 'Cannot load the DLL %ls, or one of the DLLs it references. Reason: %ls.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(17751, 16, 128, 'Cannot find the function %ls in the library %ls. Reason: %ls.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(17752, 16, 128, 'Extended procedure memory allocation failed for ''%ls''.', 1033) 
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(17753, 16, 128, '%.*ls can only be executed in the master database.', 1033)

GO
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) values
	(18002, 20, 0, 'Stored function ''%.*ls'' in the library ''%.*ls'' generated an access violation. SQL Server is terminating process %d.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(18100, 10, 0, 'Process ID %d killed by hostname %.*ls, host process ID %d.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(18450, 14, 128, 'Login failed for user ''%ls''. Reason: Not defined as a valid user of a trusted SQL Server connection.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(18451, 14, 128, 'Login failed for user ''%ls''. Only administrators may connect at this time.', 1033)

GO

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(18452, 14, 128, 'Login failed for user ''%ls''. Reason: Not associated with a trusted SQL Server connection.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(18453, 14, 128, 'Login succeeded for user ''%ls''. Connection: Trusted.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(18454, 14, 128, 'Login succeeded for user ''%ls''. Connection: Non-Trusted.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(18455, 14, 128, 'Login succeeded for user ''%ls''.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(18456, 14, 128, 'Login failed for user ''%ls''.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(18457, 14, 128, 'Login failed for user ''%ls''. Reason: User name contains a mapping character or is longer than 30 characters.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(18458, 14, 128, 'Login failed. The maximum simultaneous user count of %d licenses for this server has been exceeded. Additional licenses should be obtained and registered through the Licensing application in the Windows NT Control Panel.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(18459, 14, 128, 'Login failed. The maximum workstation licensing limit for SQL Server access has been exceeded.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(18460, 14, 128, 'Login failed. The maximum simultaneous user count of %d licenses for this ''%ls'' server has been exceeded. Additional licenses should be obtained and installed or you should upgrade to a full version.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(18461, 14, 128, 'Login failed for user ''%ls''. Reason: Server is in single user mode. Only one administrator can connect at this time.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(18482, 16, 128, 'Could not connect to server ''%ls'' because ''%ls'' is not defined as a remote server.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(18483, 16, 128, 'Could not connect to server ''%ls'' because ''%ls'' is not defined as a remote login at the server.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(18485, 16, 128, 'Could not connect to server ''%ls'' because it is not configured for remote access.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(18666, 17, 128, 'Could not free up descriptor in rel_desclosed() system function.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(18750, 16, 128, '%ls: The parameter ''%ls'' is invalid.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(18751, 16, 128, '%ls procedure called with incorrect number of parameters.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(18752, 16, 128, 'Another log reader is replicating the database.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(18754, 16, 128, 'Could not open table %d.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(18755, 16, 128, 'Could not allocate memory for replication.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(18756, 16, 128, 'Could not get replication information for table %d.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(18757, 16, 128, 'The database is not published.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(18759, 16, 128, 'Replication failure. File ''%ls'', line %d.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid) 
	values
	(18760, 16, 128, 'Invalid %ls statement for article %d.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(18761, 16, 128, 'Commit record at (%ls) has already been distributed. Check DBTABLE.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(18762, 16, 128, 'Invalid begin LSN (%ls) for commit record (%ls). Check DBTABLE.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(18763, 16, 128, 'Commit record (%ls) reports oldest active LSN as (0:0:0).',1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(18764, 16, 0, 'Execution of filter stored procedure %d failed. See the SQL Server errorlog for more information.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(18765 ,16 ,0 ,'Begin LSN specified for replication log scan is invalid.',1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(18766 ,16 ,0 ,'The replbeginlsn field in the DBTABLE is invalid.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(18767 ,16 ,0 ,'The specified begin LSN (%ls) for replication log scan occurs before replbeginlsn (%ls).' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (18768,16,0,'The specified LSN (%ls) for repldone log scan occurs before the current start of replication in the log (%ls).', 1033)
go

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (18769,16,0,'The specified LSN (%ls) for repldone log scan is not a replicated commit record.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (18770,16,0,'The specified LSN (%ls) for repldone log scan is not present in the transaction log.', 1033)

--del 18771 & 18772?
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(18771,16,0,'Invalid storage type %d specified writing variant of type %d.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(18772,16,0,'Invalid server data type (%d) specified in repl type lookup.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    (18773,16,0,'Could not locate text information records for column %d during command construction.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    (18774,16,0,'The stored procedure sp_replsetoriginator must be executed within a transaction.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    (18775,16,0,'The Log Reader Agent encountered an unexpected log record of type %u encountered while processing DML operation.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    (18776,16,0,'An error occurred while waiting on the article cache access event.',1033)

--kaushikc
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (18777 ,16 ,0 ,'%s: Error initializing MSMQ components' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    	values
	(18778 ,16 ,0 ,'%s: Error opening Microsoft Message Queue %s' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    	values
	(18779 ,16 ,0 ,'%s: Number of delete and insert log records mismatch in bounded update, insert:%d, delete:%d, beginLSN:(%ls), endLSN(%ls)' ,1033)
GO
raiserror(' ',0,1)
raiserror('Adding messages for row level replication stored procedures.',0,1)

raiserror('sysmessages.error>=20000 ....',0,1) with nowait
GO

---- Error messages for replication stored procedures.
---- The message range 20001 to 20999 is reserved for row level replication related messages

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20001 ,0 ,0 ,'There is no nickname for article ''%s'' in publication ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20002 ,0 ,0 ,'The filter ''%s'' already exists for article ''%s'' in publication ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20003 ,0 ,0 ,'Could not generate nickname for ''%s''.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20007,16,0,'The system tables for merge replication could not be dropped successfully.',1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20008,16,0,'The system tables for merge replication could not be created successfully.',1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20009 ,16 ,0 ,'The article ''%s'' could not be added to the publication ''%s''.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20010 ,16 ,0 ,'The Snapshot Agent corresponding to the publication ''%s'' could not be dropped.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20011 ,16 ,0 ,'Cannot set incompatible publication properties. The ''allow_anonymous'' property of a publication depends on the ''immediate_sync'' property.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20012 ,16 ,0 ,'The subscription type ''%s'' is not allowed on publication ''%s''.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20013 ,16 ,0 ,'The publication property ''%s'' cannot be changed when there are subscriptions on it.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20014 ,16 ,0 ,'Invalid @schema_option value.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (20015 ,16 ,0 ,'Could not remove directory ''%ls''. Check the security context of xp_cmdshell and close other processes that may be accessing the directory.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20016,16,0,'Invalid @subscription_type value. Valid values are ''pull'' or ''anonymous''.',1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20017,16,0,'The subscription on the Subscriber does not exist.',1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20018,16,0,'The @optional_command_line is too long. Use an agent definition file. ',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20019, 16, 0, 'Replication database option ''%s'' cannot be set unless the database is a publishing database or a distribution database.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20020 ,16 ,0 ,'The article resolver supplied is either invalid or nonexistent.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20021 ,16 ,0 ,'The subscription could not be found.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20023, 16 ,0 ,'Invalid @subscriber_type value. Valid options are ''local'', ''global'', ''anonymous'', or ''repub''.',1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20025 ,16 ,0 ,'The publication name must be unique. The specified publication name ''%s'' has already been used.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20026 ,16 ,0 ,'The publication ''%s'' does not exist.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20027 ,16 ,0 ,'The article ''%s'' does not exist.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20028 ,16 ,0 ,'The Distributor has not been installed correctly. Could not enable database for publishing.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20029 ,16 ,0 ,'The Distributor has not been installed correctly. Could not disable database for publishing.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20030 ,16 ,0 ,'The article ''%s'' already exists on another publication with a different column tracking option.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20031 ,16 ,0 ,'Could not delete the row because it does not exist.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20032,16 ,0 ,'''%s'' is not defined as a Subscriber for ''%s''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20033,16 ,0 ,'Invalid publication type.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20034,16 ,0 ,'Publication ''%s'' does not support ''%s'' subscriptions.' ,1033)

GO
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20036 ,16 ,0 ,'The Distributor has not been installed correctly. ' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20037 ,16 ,0 ,'The article ''%s'' already exists in another publication with a different article resolver.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20038, 16 ,0 ,'The article filter could not be added to the article ''%s'' in the publication ''%s''.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20039, 16 ,0 ,'The article filter could not be dropped from the article ''%s'' in the publication ''%s''.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20040 ,16 ,0 ,'Could not drop the article(s) from the publication ''%s''.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20041 ,16 ,0 ,'Transaction rolled back. Could not execute trigger. Retry your transaction.' ,1033)



insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values (20043 ,16 ,0 ,'Could not change the article ''%s'' because the publication has already been activated.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20044 ,16 ,0 ,'The priority property is invalid for local subscribers.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20045 ,16 ,0 ,'You must supply an article name.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20046 ,16 ,0 ,'The article does not exist.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20047 ,16 ,0 ,'You are not authorized to perform this operation.' ,1033)	
GO

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20049 , 16 ,0 ,'The priority value should not be larger than 100.0.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    (20050, 16 ,0 ,'The retention period must be greater than or equal to %d.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    (20051, 16 ,0 ,'The Subscriber is not registered.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    (20054, 16 ,0 ,'Current database is not enabled for publishing.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    (20055, 16 ,0 ,' Table ''%s'' cannot be published for merge replication because it has a timestamp column.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    (20056, 16 ,0 ,'Table ''%s'' cannot be republished.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20057,16 ,0 ,'The profile name ''%s'' already exists for the specified agent type.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20058,16 ,0 ,'The @agent_type must be 1 (Snapshot), 2 (Logreader), 3 (Distribution), or 4 (Merge)' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20059,16 ,0 ,'The @profile_type must be 0 (System) or 1 (Custom)' ,1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    (20060, 16 ,0 ,'Compatibility level cannot be smaller than 60.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    (20061, 16 ,0 ,'The compatibility level of this database must be set to 70 or higher to be enabled for merge publishing.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    (20062, 16 ,0 ,'Updating columns with the rowguidcol property is not allowed.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20064,16 ,0 ,'Cannot drop profile. Either it is not defined or it is defined as the default profile.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20065,16 ,0 ,'Cannot drop profile because it is in use.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20066,16 ,0 ,'Profile not defined.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20067,16 ,0 ,'The parameter name ''%s'' already exists for the specified profile.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    (20068, 16 ,0 ,'The article cannot be created on table ''%s'' because it has more than %d columns.' ,1033) 

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20069, 16, 0, 'Cannot validate a merge article that uses looping join filters. ', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20070, 16, 0, 'Cannot update subscription row. ', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20072, 16, 0, 'Cannot update Subscriber information row. ', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20073, 16, 0, 'Articles can be added or changed only at the Publisher. ', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20074 ,16 ,0 ,'Only a table object can be published as a "table" article for merge replication.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20075 ,16 ,0 ,'The ''status'' parameter value must be either ''active'' or ''unsynced''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20076 ,16 ,0 ,'The @sync_mode parameter value must be ''native'' or ''character''.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20077 ,16 ,0 ,'Problem encountered generating replica nickname.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20078 ,16 ,0 ,'The @property parameter value must be ''sync_type'', ''priority'', or ''description''.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20079,16,0,'Invalid @subscription_type parameter value. Valid options are ''push'', ''pull'', or ''both''. ',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20081,16,0,'Publication property ''%s'' cannot be NULL.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20084,16,0, 'Publication ''%s'' cannot be subscribed to by Subscriber database ''%s''.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (20086, 16, 0, 'Publication ''%s'' does not support the nosync type because it contains a table that does not have a rowguidcol column.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (20087, 16, 0, 'You cannot push an anonymous subscription.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (20088, 16, 0, 'Only assign priorities that are greater than or equal to 0 and less than 100.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (20089, 16, 0, 'Could not get license information correctly.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (20090, 16, 0, 'Could not get version information correctly.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (20091, 16, 0, 'sp_mergesubscription_cleanup is used to clean up push subscriptions. Use sp_dropmergepullsubscription to clean up pull or anonymous subscriptions.', 1033)



insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20100, 16, 0, 'Cannot drop Subscriber ''%s''. There are existing subscriptions.',1033)
GO
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20500,16,0,'The updatable Subscriber stored procedure ''%s'' does not exist in sysobjects.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20501,16,0,'Could not insert into sysarticleupdates using sp_articlecolumn.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20502,16,0,'Invalid ''%s'' value. Valid values are ''read only'', ''sync tran'', ''queued tran'', or ''failover''.',1033) 

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(20503,16,0,'Invalid ''%s'' value in ''%s''. The publication is not enabled for ''%s'' updatable subscriptions.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20505,16,0,'Could not drop synchronous update stored procedure ''%s'' in ''%s''.',1033) 

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20506,16,0,'Source table ''%s'' not found in ''%s''.',1033) 
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20507,16,0,'Table ''%s'' not found in ''%s''.',1033) 
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20508,16,0,'Updatable Subscriptions: The text/ntext/image values inserted at Subscriber will be NULL.',1033) 
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20509,16,0,'Updatable Subscriptions: The text/ntext/image values cannot be updated at Subscriber.',1033) 
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20510,16,0,'Updatable Subscriptions: Cannot update identity columns.',1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20511,16,0,'Updatable Subscriptions: Cannot update timestamp columns.',1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20512,16,0,'Updatable Subscriptions: Rolling back transaction.',1033)
go

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20515,16,0,'Updatable Subscriptions: Rows do not match between Publisher and Subscriber. Run the Distribution Agent to refresh rows at the Subscriber.', 1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20516,16,0,'Updatable Subscriptions: Replicated data is not updatable.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20517,16,0,'Updatable Subscriptions: Update of replica''s primary key is not allowed unless published table has a timestamp column.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20518,16,0,'Updatable Subscriptions: INSERT and DELETE operations are not supported unless published table has a timestamp column.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20519,16,0,'Updatable Subscriptions: INSERT operations on tables with identity or timestamp columns are not allowed unless a primary key is defined at the Subscriber.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20520,16,0,'Updatable Subscriptions: UPDATE operations on tables with identity or timestamp columns are not allowed unless a primary key is defined at the Subscriber.', 1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20521,16,0,'sp_MSmark_proc_norepl: must be a member of the db_owner or sysadmin roles.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20522,16,0,'sp_MSmark_proc_norepl: invalid object name ''%s''.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20523,16,0,'Could not validate the article ''%s''. It is not activated. ', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20524,10,0,'Table ''%s'' may be out of synchronization. Rowcounts (actual: %s, expected: %s). Rowcount method %d used (0 = Full, 1 = Fast).', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20525,10,0,'Table ''%s'' might be out of synchronization. Rowcounts (actual: %s, expected %s). Checksum values (actual: %s, expected: %s).', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20526,10,0,'Table ''%s'' passed rowcount (%s) validation. Rowcount method %d used (0 = Full, 1 = Fast).', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20527,10,0,'Table ''%s'' passed rowcount (%s) and checksum validation. Checksum is not compared for any text or image columns.', 1033)
	

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20528,10,0,'Log Reader Agent startup message.', 1033)	

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20529,10,0,'Starting agent.', 1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20530,10,0,'Run agent.', 1033)		-- description of job step
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20531,10,0,'Detect nonlogged agent shutdown.', 1033)	-- description of job step
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20532,10,0,'Replication agent schedule.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20533,10,0,'Replication agents checkup', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20534,10,0,'Detects replication agents that are not logging history actively.', 1033) -- description
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20535,10,0,'Removes replication agent history from the distribution database.', 1033) -- description
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20536,10,0,'Replication: agent failure', 1033)	-- Alert name
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20537,10,0,'Replication: agent retry', 1033) -- Alert name
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20538,10,0,'Replication: expired subscription dropped', 1033)	-- Alert name
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20540,10,0,'Replication: agent success', 1033)  -- Alert name
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20541,10,0,'Removes replicated transactions from the distribution database.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20542,10,0,'Detects and removes expired subscriptions from published databases.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20543,10,0,'@rowcount_only parameter must be the value 0,1, or 2. 0=7.0 compatible checksum. 1=only check rowcounts. 2=new checksum functionality introduced in version 8.0.', 1033)
GO

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20545,10,0,'Default agent profile', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20546,10,0,'Verbose history agent profile.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20547,10,0,'Agent profile for detailed history logging.',1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20548,10,0,'Slow link agent profile.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20549,10,0,'Agent profile for low bandwidth connections.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20550,10,0,'Windows Synchronization Manager profile', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20551,10,0,'Profile used by the Windows Synchronization Manager.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20552,10,0,'Could not clean up the distribution transaction tables.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20553,10,0,'Could not clean up the distribution history tables.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20554,10,0,'The agent is suspect. No response within last %ld minutes.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20555,10,0,'6.x publication.', 1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20556,10,0,'Heartbeats detected for all running replication agents.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20557,10,0,'Agent shutdown. For more information, see the SQL Server Agent job history for job ''%s''.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20558,10,0,'Table ''%s'' passed full rowcount validation after failing the fast check. DBCC UPDATEUSAGE will be initiated automatically.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20559,10,0,'Conditional Fast Rowcount method requested without specifying an expected count. Fast method will be used.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20560,10,0,'An expected checksum value was passed, but checksums will not be compared because rowcount-only checking was requested.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20561,10,0,'Generated expected rowcount value of %s for %s.', 1033)

GO
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20562,10,0,'User delete.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20563,10,0,'No longer belongs in this partial.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20564,10,0,'System delete.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20565,10,0,'Replication: Subscriber has failed data validation', 1033)	-- Alert name
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20566,10,0,'Replication: Subscriber has passed data validation', 1033)	-- Alert name

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20567,10,0,'Agent history clean up: %s', 1033)	-- Job name
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20568,10,0,'Distribution clean up: %s', 1033)



insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20569,10,0,'Expired subscription clean up', 1033)	-- Job name
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20570,10,0,'Reinitialize subscriptions having data validation failures', 1033)	-- Title of a alert response job
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20571,10,0,'Reinitializes all subscriptions that have data validation failures.', 1033)	-- Description of a alert response job
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20572,10,0, 'Subscriber ''%s'' subscription to article ''%s'' in publication ''%s'' has been reinitialized after a validation failure.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20573,10,0, 'Replication: Subscription reinitialized after validation failure', 1033)	-- Alert name
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20574,10,0, 'Subscriber ''%s'' subscription to article ''%s'' in publication ''%s'' failed data validation.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20575,10,0, 'Subscriber ''%s'' subscription to article ''%s'' in publication ''%s'' passed data validation.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20576,10,0, 'Subscriber ''%s'' subscription to article ''%s'' in publication ''%s'' has been reinitialized after a synchronization failure.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20577,10,0, 'No entries were found in msdb..sysreplicationalerts.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20578,10,0, 'Replication: agent custom shutdown', 1033) -- Alert name
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20579,10,0,'Generated expected rowcount value of %s and expected checksum value of %s for %s.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20580,10,0,'Heartbeats not detected for some replication agents. The status of these agents have been changed to ''Failed''.', 1033)  -- 'Failed' is a replication runstatus value in monitoring UI

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20581,10,0,'Cannot drop server ''%s'' because it is used as a Distributor in replication.', 1033)  
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20582,10,0,'Cannot drop server ''%s'' because it is used as a Publisher in replication.', 1033) 
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20583,10,0,'Cannot drop server ''%s'' because it is used as a Subscriber in replication.', 1033)  
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20584,10,0,'Cannot drop server ''%s'' because it is used as a Subscriber to remote Publisher ''%s'' in replication.', 1033)  

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20585,16,0,'Validation Failure. Object ''%s'' does not exist.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(20586,16,0,'(default destination)', 1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(20587,16,0,'Invalid ''%s'' value for stored procedure ''%s''.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(20588,16,0,'The subscription is not initialized. Run the Distribution Agent first.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (20589 ,10 ,0 ,'Agent profile for replicated queued transaction reader.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(20590,16,0,'The article property ''status'' cannot include bit 64, ''DTS horizontal partitions'' because the publication does not allow data transformations.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(20591,16,0,'Only ''DTS horizontal partitions'' and ''no DTS horizontal partitions'' are valid ''status'' values because the publication allows data transformations.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20592,16,0,'''dts horizontal partitions'' and ''no dts horizontal partitions'' are not valid ''status'' values because the publication does not allow data transformations.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20593,16,0,'Cannot modify publication ''%s''.  The sync_method cannot be changed to ''native'', ''concurrent'' or ''concurrent_c'' because the publication has subscriptions from ODBC or OLE DB Subscribers.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20594,16,0,'A push subscription to the publication exists. Use sp_subscription_cleanup to drop defunct push subscriptions.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20595,16,0,'Skipping error signaled.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(20596,16,0,'Only ''%s'' or members of db_owner can drop the anonymous agent.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(20597,10,0,'Dropped %d anonymous subscription(s).', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
		(20598,16,0,'The row was not found at the Subscriber when applying the replicated command.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
		(20599,16,0,'Continue on data consistency errors.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(20600,10,0,'Agent profile for skipping data consistency errors. It can be used only by SQL Server Subscribers.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(20601,10,0,'Invalid value specified for agent parameter ''SkipErrors''.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(20602,10,0,'The value specified for agent parameter ''SkipErrors'' is too long.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(20603,10,0,'The agent profile cannot be used by heterogeneous Subscribers.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(20604,10,0,'You do not have permissions to run agents for push subscriptions. Make sure that you specify the agent parameter ''SubscriptionType''.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(20605,10,0,'Invalidated the existing snapshot of the publication. Run the Snapshot Agent again to generate a new snapshot.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(20606,10,0,'Reinitialized subscription(s).',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(20607,10,0,'Cannot make the change because a snapshot is already generated. Set @force_invalidate_snapshot to 1 to force the change and invalidate the existing snapshot.',1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(20608,10,0,'Cannot make the change because there are active subscriptions. Set @force_reinit_subscription to 1 to force the change and reinitialize the active subscriptions.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(20609,16,0,'Cannot attach subscription file ''%s''. Make sure that it is a valid subscription copy file.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(20610,16,0,'Cannot run ''%s'' when the Log Reader Agent is replicating the database.', 1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(20611,16,0,'Only table or indexed view to table articles are allowed in publications that allow DTS.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(20612,16,0,'Checksum validation is not supported because the publication allows DTS. Use row count only validation.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(20613,16,0,'Validation is not supported for articles that are set up for DTS horizontal partitions.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(20614,16,0,'Validation is not supported for heterogeneous Subscribers.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(20616,10,0,'High Volume Server-to-Server Profile', 1033)
go

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(20617,10,0,'Merge agent profile optimized for the high volume server-to-server synchronization scenario.', 1033)
go

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(20618,16 ,0 ,'You must have CREATE DATABASE permission to attach a subscription database.' ,1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
		(20619,16 ,0 ,'Server user ''%s'' is not a valid user in database ''%s''. Add the user account or ''guest'' user account into the database first.' ,1033)

insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
		(20620,11,2,'The security mode specified requires the server ''%s'' in sysservers. Use sp_addlinkedserver to add the server.',1033)

insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
		(20621,11,2,'Cannot copy a subscription database to an existing database.',1033)

insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
		(20622,11,2,'Replication database option ''sync with backup'' cannot be set on the publishing database because the database is in Simple Recovery mode.',1033)

insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
		(20623,11,2,'You cannot validate article ''%s'' unless you have ''SELECT ALL'' permission on table ''%s''.',1033)

-- jsampath added the following for sp3
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
		(20624,16 ,0 ,'Server user ''%s'' is not a valid user in database ''%s''. Add the user account into the database first.' ,1033)
		
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
		(20625,16 ,0 ,'Could not create the merge replication PAL database role for publication ''%s''.' ,1033)

--------------
go
--- Start 21000 set of messages

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21000 ,16 ,0 ,'Cannot subscribe to an inactive publication.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21001 ,16 ,0 ,'Cannot add a Distribution Agent at the Subscriber for a push subscription.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21002 ,16 ,0 ,'The Distribution Agent for this subscription already exists (%s).', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21003 ,16 ,0 ,'Changing publication names is no longer supported.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21004 ,16 ,0 ,'Cannot publish the database object ''%s'' because it is encrypted.' ,1033)
go

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21005,10,0 ,'For backward compatibility, sp_addpublisher can be used to add a Publisher for this Distributor. However, sp_adddistpublisher is more flexible.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21006,16,0 ,'Cannot use sp_addpublisher to add a Publisher. Use sp_adddistpublisher.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21007,16,0 ,'Cannot add the remote Distributor. Make sure that the local server is configured as a Publisher at the Distributor.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21008,16,0,'Cannot uninstall the Distributor because there are Subscribers defined.', 1033)
insert into master..sysmessages(error,severity,dlevel,description,msglangid)
	values
	(21009,16,0,'The specified filter procedure is already associated with a table.',1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21010,16,0,'Removed %ld replicated transactions consisting of %ld statements in %ld seconds (%ld rows/sec).', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21011,16,0,'Deactivated subscriptions.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21012,16,0,'Cannot change the ''allow_push'' property of the publication to "false". There are push subscriptions on the publication.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21013,16,0,'Cannot change the ''allow_pull'' property of the publication to "false". There are pull subscriptions on the publication.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21014,16,0,'The @optname parameter value must be ''transactional'' or ''merge''.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21015,16,0,'The replication option ''%s'' has been set to TRUE already.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21016,16,0,'The replication option ''%s'' has been set to FALSE already.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21017, 16, 0, 'Cannot perform SQL Server 7.0 compatible checksum operation on a merge article that has a vertical or horizontal partition. Rowcount validation and SQL Server 2000 compatible binary checksum operation can be performed on this article.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21018,16,0,'There are too many consecutive snapshot transactions in the distribution database.  Run the Log Reader Agent again or clean up the distribution database.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21021,16,0,'Drop the Distributor before you uninstall replication. ', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21022,16,0,'Cannot set incompatible publication properties. The ''immediate_sync'' property of a publication is dependent on the ''independent agent'' property of a publication.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21023,16,0,'''%s'' is no longer supported. ', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21024,16,0,'The stored procedure ''%s'' is already published as an incompatible type.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21025,16,0,'The string being encrypted cannot have null characters.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21026,16,0,'Cannot have an anonymous subscription on a publication that does not have an independent agent.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21027,16,0,'''%s'' replication stored procedures are not installed. Use sp_replicationoption to install them.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21028,16,0, 'Replication components are not installed on this server. Run SQL Server Setup again and select the option to install replication.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21029,16,0,'Cannot drop a push subscription entry at the Subscriber unless @drop_push is ''true''.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21030,16,0,'Names of SQL Server replication agents cannot be changed.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21031,16,0,'''post_script'' is not supported for stored procedure articles.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21032,16,0, 'Could not subscribe because non-SQL Server Subscriber ''%s'' does not support ''sync tran'' update mode.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21033,16,0, 'Cannot drop server ''%s'' as Distribution Publisher because there are databases enabled for replication on that server.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21034,16,0, 'Rows inserted or updated at the Subscriber cannot be outside the article partition.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21035,16,0, 'You have updated the Publisher property ''%s'' successfully.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21036,16,0, 'Another %s agent for the subscription(s) is running.', 1033)



insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21037,16,0, 'Invalid working directory ''%s''.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21038,16,0, 'Windows Authentication is not supported by the server.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21039,16,0, 'The destination owner name is not supported for publications that can have heterogeneous Subscribers. Use native mode bcp for this functionality.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21040,16,0,'Publication ''%s'' does not exist.', 1033) 
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21041, 16, 0, 'A remote distribution Publisher is not allowed on this server version.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21042,16,0, 'The distribution Publisher property, ''distributor_password'', has no usage and is not supported for a Distributor running on Windows NT 4.0.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21043,16,0, 'The Distributor is not installed.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21044,16,0, 'Cannot ignore the remote Distributor (@ignore_remote_distributor cannot be 1) when enabling the database for publishing or merge publishing.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21045,16,0, 'Cannot uninstall the Distributor because there are databases enabled for publishing or merge publishing.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21046,16,0 ,'Cannot change distribution Publisher property ''distribution_db'' because the remote Publisher is using the current distribution database.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21047,16,0,'Cannot drop the local distribution Publisher because there are Subscribers defined.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21048,16,0,'Cannot add login ''%s'' to the publication access list because it does not have access to the distribution server ''%s''.' ,1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21049,16,0, 'The login ''%s'' does not have access permission on publication ''%s'' because it is not in the publication access list.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21050,16,0,'Only members of the sysadmin or db_owner roles can perform this operation.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21051, 16, 0, 'Could not subscribe because non-SQL Server Subscriber ''%s'' does not support custom stored procedures.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21052, 16, 0,'Queued Updating Subscriptions: write to message queue failed.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21053 ,16 ,0 , 'The parameter must be one of the following: ''description'', ''status'', ''retention'', ''sync_mode'', ''allow_push'', ''allow_pull'', ''allow_anonymous'', ''enabled_for_internet'', ''centralized_conflicts'', ''conflict_retention'', or ''snapshot_ready''.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21054,16,0,'Updatable Subscribers: RPC to Publisher failed.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21055 ,15 ,0 ,'Invalid parameter %s specified for %s.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(21056,16,0, 'The subscription to publication ''%s'' has expired and does not exist.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21057,16,0,'Anonymous Subscribers cannot have updatable subscriptions.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21058,16,0,'An updatable subscription to publication ''%s'' on Subscriber ''%s'' already exists.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21059,16,0,'Cannot reinitialize subscriptions of non-immediate_sync publications.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21060 ,16 ,1 ,'Could not subscribe because non-SQL Server Subscriber ''%s'' does not support parameterized statements.' ,1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21061 ,16 ,1 ,'Invalid article status %d specified when adding article ''%s''.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21062 ,16 ,1, 'The row size of table ''%s'' exceeds the replication limit of 6,000 bytes.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21063,16,0,'Table ''%s'' cannot participate in updatable subscriptions because it is published for merge replication.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21064 ,16 ,0 ,'The subscription is uninitialized or unavailable for immediate updating as it is marked for reinitialization. If using queued failover option, run Queue Reader Agent for subscription initialization. Try again after the (re)initialization completes.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21070, 16, 0, 'This subscription does not support automatic reinitialization (subscribed with the ''no sync'' option). To reinitialize this subscription, you must drop and re-create the subscription.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21071, 10, 0, 'Cannot reinitialize article ''%s'' in subscription ''%s:%s'' to publication ''%s'' (subscribed with the ''no sync'' option).' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21072, 16, 0, 'The subscription has not been synchronized within the maximum retention period or it has been dropped at the Publisher. You must reinitialize the subscription to receive data.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21073, 16, 0, 'The publication specified does not exist.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21074,16,0, 'The subscription(s) have been marked inactive and must be reinitialized. NoSync subscriptions will need to be dropped and recreated.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21075, 10, 0, 'The initial snapshot for publication ''%s'' is not yet available.' ,1033) -- Used for formatmessage

--ywu 

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21076, 10, 0, 'The initial snapshot for article ''%s'' is not yet available.' ,1033) -- Used for formatmessage

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21077, 10, 0, 'Deactivated initial snapshot for anonymous publication(s). New subscriptions must wait for the next scheduled snapshot.' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21078, 16, 0, 'Table ''%s'' does not exist in the Subscriber database.' ,1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21079,16,0, 'The RPC security information for the Publisher is missing or invalid. Use sp_link_publication to specify it.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
		(21080,16,0, 'The ''msrepl_tran_version'' column must be in the vertical partition of the article that is enabled for updatable subscriptions; it cannot be dropped.' ,1033)



insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21081,16,0,'Server setting ''Allow triggers to be fired which fire other triggers (nested triggers)'' must exist on updatable Subscribers.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
	(21082,16,0,'Database property ''IsRecursiveTriggersEnabled'' has to be false for subscription databases at Subscribers that allow updatable subscriptions.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21083,16,0,'Database compatibility level at immediate updating Subscribers cannot be less than 70.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21084,16,0,'Publication ''%s'' does not allow anonymous subscriptions.', 1033)    

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21085,16,0, 'The retention period must be less than the retention period for the distribution database.', 1033)    

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21086,16,0, 'The retention period for the distribution database must be greater than the retention period of any existing non-merge publications. ', 1033)    

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21087,16,0,'Anonymous Subscribers or Subscribers at this server are not allowed to create merge publications. ', 1033)    

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21088, 10, 0, 'The initial snapshot for the publication is not yet available.' ,1033) -- Used for formatmessage



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21107, 16, 0, '''%ls'' is not a table or view.' ,1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21108, 16, 0, 'This edition of SQL Server does not support transactional publications. ', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21109,16,0,'The parameters @xact_seqno_start and @xact_seqno_end must be identical if @command_id is specified.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21110,16,0,'@xact_seqno_start and @publisher_database_id must be specified if @command_id is specified.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21111,16,0,'''%s'' is not a valid parameter for the Snapshot Agent.', 1033)  

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21112,16,0,'''%s'' is not a valid parameter for the Log Reader Agent.', 1033)  

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21113,16,0,'''%s'' is not a valid parameter for the Distribution Agent.', 1033)  

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21114,16,0,'''%s'' is not a valid parameter for the Merge Agent.', 1033)  

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21115,16,0,'''%s'' is not a valid value for the ''%s'' parameter. The value must be a positive integer.', 1033)  

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21116,16,0,'''%s'' is not a valid value for the ''%s'' parameter. The value must be 1, 2, or 3.', 1033)  

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21117,16,0,'''%s'' is not a valid value for the ''%s'' parameter. The value must be 0, 1, or 2.', 1033)  

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21118,16,0,'''%s'' is not a valid value for the ''%s'' parameter. The value must be greater than or equal to 0 and less than or equal to 10,000.', 1033)  

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21119,16,0,'''%s'' is not a valid value for the ''%s'' parameter. The value must be a non-negative integer.', 1033)  

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21120,16,0,'Only members of the sysadmin fixed server role and db_owner fixed database role can drop subscription ''%s'' to publication ''%s''.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21121,16,0,'Only members of the sysadmin fixed server role and ''%s'' can drop the pull subscription to the publication ''%s''.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21122,16,0,'Cannot drop the distribution database ''%s'' because it is currently in use.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21123,16,0,'The agent profile ''%s'' could not be found at the Distributor.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21124,16,0,'Cannot find the table name or the table owner corresponding to the alternative table ID(nickname) ''%d'' in sysmergearticles.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21125,16,0,'A table used in merge replication must have at least one non-computed column.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21126,16,0,'Pull subscriptions cannot be created in the same database as the publication.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21127,16,0,'Only global merge subscriptions can be added to database ''%s''.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21128,16,0,'Terminating immediate updating or queued updating INSERT trigger because it is not the first trigger to fire. Use sp_settriggerorder procedure to set the firing order for trigger ''%s'' to first.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
   (21129,16,0,'Terminating  immediate updating or queued updating UPDATE trigger because it is not the first trigger to fire.  Use sp_settriggerorder procedure to set the  firing order for trigger ''%s'' to first.',  1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21130,16,0,'Terminating immediate updating or queued updating DELETE trigger  because it is not the first trigger to fire. Use sp_settriggerorder procedure to set the  firing order for trigger ''%s'' to first.',  1033)

GO

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21131,16,0,'There are existing subscriptions to heterogeneous publication ''%s''. To add new articles, first drop the existing subscriptions to the publication.', 1033)
GO

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21132,16,0,'Cannot create transactional subscription to merge publication ''%s''. The publication type should be either transactional(0) or snapshot(1) for this operation.', 1033)
GO


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21133,16,0,'Publication ''%s'' is not enabled to use an independent agent.', 1033)
GO

raiserror(' ',0,1)
raiserror('Adding Replication messages.',0,1) with nowait
raiserror(' ',0,1)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21134,16,0, 'The specified job ID must identify a Distribution Agent or a Merge Agent job.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21135,16,0,'Detected inconsistencies in the replication agent table. The specified job ID does not correspond to an entry in ''%ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21136,16,0,'Detected inconsistencies in the replication agent table. The specified job ID corresponds to multiple entries in ''%ls''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21137,16,0,'This procedure supports only remote execution of push subscription agents.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21138,16,0,'The ''offload_server'' property cannot be the same as the Distributor name.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21139,16,0,'Could not determine the Subscriber name for distributed agent execution.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21140,16,0,'Agent execution cannot be distributed to a Subscriber that resides on the same server as the Distributor.' ,1033)

--remove 21141 from here?
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21141,16,0,'The @change_active flag may not be specified for articles with manual filters or views.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21143,16,0,'The custom stored procedure schema option is invalid for a snapshot publication article.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21142,16,0,'The SQL Server ''%s'' could not obtain Windows group membership information for login ''%s''. Verify that the Windows account has access to the domain of the login.' ,1033)

--del 21144 & 21145?
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21144,16,0,'Cannot subscribe to publication of sync_type ''dump database'' because the Subscriber has subscriptions to other publications.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21145,16,0,'Cannot subscribe to publication %s because the Subscriber has a subscription to a publication of sync_type ''dump database''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21146,16,0,'@use_ftp cannot be ''true'' while @alt_snapshot_folder is neither NULL nor empty.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21147,16,0, 'The ''%s'' database is not published for merge replication.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21148,16,0,'Both @subscriber and @subscriberdb must be specified with non-null values simultaneously, or both must be left unspecified.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21149,16,0, 'The ''%s'' database is not published for transactional or snapshot replication.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21150,16,0,'Unable to determine the snapshot folder for the specified subscription because the specified Subscriber is not known to the Distributor.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21151,16,0,'Pre- and post-snapshot commands are not supported for a publication that may support non-SQL Server Subscribers by using the character-mode bcp as the synchronization method.' ,1033)

--del 21152, 53, & 54?
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21152,16,0,'Cannot create a subscription of sync_type ''none'' to a publication using the ''concurrent'' or ''concurrent_c'' synchronization method.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21153,16,0,'Cannot create article ''%s''. All articles that are part of a concurrent synchronization publication must use stored procedures to apply changes to the Subscriber.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21154,16,0,'Cannot change article ''%s''.  All articles that are part of a concurrent synchronization publication must use stored procedures to apply changes to the Subscriber.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    (21156,16,0,'The @status  parameter value must be ''initiated'' or ''active''.',1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21157,16,0, 'The snapshot compression option can be enabled only for a publication having an alternate snapshot generation folder defined.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21158,16,0,'For a publication to be enabled for the Internet, the ''ftp_address'' property must not be null.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21159,16,0,'If a publication is enabled for the Internet, the ''alt_snapshot_folder'' property must be non-empty.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21160,16,0, 'The @ftp_port parameter cannot be NULL.' ,1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21161,16,0,'Could not change the Publisher because the subscription has been dropped. Use sp_subscription_cleanup to clean up the triggers.',1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21162,16,0,'It is invalid to exclude the rowguid column for the table from the partition.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21163,16,0,'It is not possible to add column ''%s'' to article ''%s'' because the snapshot for publication ''%s'' has been run.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21164,16,0,'Column ''%s'' cannot be included in a vertical partition because it is neither nullable nor defined with a default value.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21165,16,0,'Column ''%s'' cannot be excluded from a vertical partition because it is neither nullable nor defined with a default value.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21166,16,0,'Column ''%s'' does not exist.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21167,16,0, 'The specified job ID does not represent a %s agent job for any push subscription in this database.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21168,16,0,'Only members of the sysadmin fixed server role, members of the db_owner fixed database role, and owners of subscriptions served by the specified replication agent job can modify the agent offload settings.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21169,16,0,'Could not identify the Publisher ''%s'' at the Distributor ''%s''. Make sure that ''%s'' is registered in the sysservers table at the Distributor.' ,1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21170,16,0,'Only a SQL Server 2000 or OLE DB Subscriber can use DTS.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21171,16,0,'Could not find package ''%s'' in msdb at server ''%s''.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21172,16,0,'The publication has to be in ''character'' or ''concurrent_c'' bcp mode to allow DTS.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21173,16,0,'The publication has to be ''independent_agent type'' to allow DTS.',1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21174,16,0,'You must use default values for @ins_cmd,  @upd_cmd,  and @del_cmd, and @status can be only 16 or 80 because the publication allows DTS.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21175,16,0,'You cannot change ''ins_cmd'',''upd_cmd'', or ''del_cmd'' article properties because the publication allows DTS or queued updating option.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21176,16,0,'Only members of the sysadmin fixed server role, db_owner fixed database role, or the creator of the subscription can change the subscription properties.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21177,16,0,'Could not create column list because it is too long. Create the list manually.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21178,16,0,'DTS properties cannot be set because the publication does not allow for data transformation.',1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21179,16,0,'Invalid @dts_package_location parameter value. Valid options are ''Distributor'' or ''Subscriber''.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21180,16 ,0 ,'A publication that allows DTS cannot be enabled for updatable subscriptions.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21184 ,16 ,0 ,'%s parameter is incorrect: it should be ''%s'', ''%s'' or ''%s''.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
(21181,16,0,'@dts_package_name can be set for push subscriptions only.',1033)
    	

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21182,16,0,'The @agent_type parameter must be one of ''distribution'', ''merge'', or NULL.' ,1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21183,16,0,'Invalid property name ''%s''.',1033)

go

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21185 ,16 ,0 ,'The subscription is not initialized or not created for failover mode operations.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21186 ,16 ,0 ,'Subscription for Publisher ''%s'' does not have a valid queue_id.' ,1033)
 
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21187 ,16 ,0 ,'The current mode is the same as the requested mode.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21188 ,10 ,0 ,'Changed update mode from [%s] to [%s].' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21189 ,16 ,0 ,'The queue for this subscription with queue_id = ''%s'' is not empty. Run the Queue Reader Agent to make sure the queue is empty before setting mode from [queued] to [immediate].' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21190 ,10 ,0 ,'Overriding queue check for setting mode from [%s] to [%s].' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21191 ,16 ,0 ,'Values for @ins_cmd, @upd_cmd, and @del_cmd can be only [%s], [%s] and [%s] respectively because the publication allows queued transactions.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21192 ,16 ,0 ,'MSrepl_tran_version column is a predefined column used for replication and can be only of data type uniqueidentifier' ,1033)

go


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21193,16,0,'@identity_range, @pub_identity_range, or @threshold cannot be NULL when @auto_identity_support is set to TRUE.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21194,16,0,'Cannot support identity_range_control because this table does not have an identity column.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21195,16,0,'A valid identity range is not available. Check the data type of the identity column.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21196,16,0,'Identity automation failed.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21197,16,0,'Failed to allocate new identity range.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21198,16,0,'Schema replication failed.', 1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21199,16,0,'This change cannot take effect until you run the snapshot again.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21200,16,0,'Publication ''%s'' does not exist.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
    values
    (21201,16,0,'Dropping a column that is being used by a merge filter clause is not allowed.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21202,16,0,'It is not possible to drop column ''%s'' to article ''%s'' because the snapshot for publication ''%s'' has already been run.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21203,10,0,'Duplicate rows found in %s. Unique index not created.' ,1033)
GO


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21204,16 ,0 ,'The publication ''%s'' does not allow subscription copy or its subscription has not been synchronized.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(21205 ,16 ,0 ,'The subscription cannot be attached because the publication does not allow subscription copies to synchronize changes.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    (21206,16,0,'Cannot resolve load hint for object %d because the object is not a user table.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    (21207,16,0,'Cannot find source object ID information for article %d.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(21208 ,16 ,0 ,'This step failed because column ''%s'' exists in the vertical partition.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(21209 ,16 ,0 ,'This step failed because column ''%s'' does not exist in the vertical partition.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21210,16,0,'The publication must be immediate_sync type to allow subscription copy.',1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21211,16,0,'The database is attached from a subscription copy file without using sp_attach_subscription. Drop the database and reattach it using sp_attach_subscription.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21212,16,0,'Cannot copy subscription. Only single file subscription databases are supported for this operation.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21213,16,0,'Non-SQL Server Subscribers cannot subscribe to publications that allow DTS without using a DTS package.',1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21214,16,0,'Cannot create file ''%s'' because it already exists.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(21215, 16, 0, 'An alternate synchronization partner can be configured only at the Publisher. ', 1033)
go

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21216, 16, 0,'Publisher ''%s'', publisher database ''%s'', and publication ''%s'' are not valid synchronization partners.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21217, 10, 0,'Publication of ''%s'' data from Publisher ''%s''.', 1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21218,16,0,'The creation_script property cannot be NULL if a schema option of 0x0000000000000000 is specified for the article.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21219,16,0,'The specified source object must be a stored procedure object if it is published as a ''proc schema only'' type article.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21220,16,0, 'Unable to add the article ''%s'' because a snapshot has been generated for the publication ''%s''.' ,1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21221,16,0,'The specified source object must be a view object if it is going to be as a ''view schema only'' type article.' ,1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21222,16,0,'The @schema_option parameter for a procedure or function schema article can include only the options 0x0000000000000001 or 0x0000000000002000.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21223,16,0,'The @pre_creation_command parameter for a schema only article must be either ''none'' or ''drop''.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21224,16,0,'''%s'' is not a valid property for a schema only article.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21225,16,0,'The ''offload_server'' property cannot be NULL or empty if the pull subscription agent is to be enabled for remote activation.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21226,16,0,'The database ''%s'' does not have a pull subscription to the specified publication.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
        (21227,16,0,'The ''offload_server'' property cannot be the same as the Subscriber server name.' ,1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21228,16,0,'The specified source object must be a user-defined function object if it is going to be published as a ''func schema only'' type article.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21229,16,0,'The only schema options available for a view schema article are: 0x0000000000000001, 0x0000000000000010, 0x0000000000000040, 0x0000000000000100, and 0x0000000000002000.' ,1033)

go

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(21230, 16, 0, 'Do not call this stored procedure for schema change because the current database is not enabled for replication.', 1033)

go



insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21231,16,0,'Automatic identity range support is useful only for publications that allow queued updating.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21232,16,0,'Identity range values must be positive numbers that are greater than 1.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21233,16,0,'Threshold value must be from 1 through 100.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21234,16,0,'Cannot use the INSERT command because the table has an identity column. The insert custom stored procedure must be used to set ''identity_insert'' settings at the Subscriber.',1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21235,16,0,'Article property ''%s'' can be set only when the article uses automatic identity range management.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21236,16,0,'The subscription(s) to Publisher ''%s'' does not allow subscription copy or it has not been synchronized.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21237,16,0,'There is a push subscription to Publisher ''%s''. Only pull and anonymous subscriptions can be copied.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21238,16,0,'There is a push subscription to publication ''%s''. Only pull and anonymous subscriptions can be copied.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21239,16,0, 'Cannot copy subscriptions because there is no synchronized subscription found in the database.', 1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21240,16,0,'The table ''%s'' is already published as another article with a different automatic identity support option.' ,1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21241,16,0,'The threshold value should be from 0 through 99.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21242,16,0,'Conflict table for article ''%s'' could not be created successfully.' ,1033)

-- charun 21243
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
		(21243, 16, 0,'Publisher ''%s'', publication database ''%s'', and publication ''%s'' could not be added to the list of synchronization partners.', 1033)
go


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21244, 16, 0,'Character mode publication does not support vertical filtering when the base table does not support column-level tracking.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21245, 16, 0,'Table ''%s'' is not part of publication ''%s''.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21246, 16, 0,'This step failed because table ''%s'' is not part of any publication.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21247,16,0,'Cannot create file at ''%s''. Ensure the file path is valid.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21248,16,0,'Cannot attach subscription file ''%s''. Ensure the file path is valid and the file is updatable.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21249,16,0,'OLE DB or ODBC Subscribers cannot subscribe to article ''%s'' in publication ''%s'' because the article has a timestamp column and the publication is ''allow_queued_tran'' (allows queued updating subscriptions).', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21250,16,0,'Primary key column ''%s'' cannot be excluded from a vertical partition.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
		(21251, 16, 0,'Publisher ''%s'', publisher database ''%s'', publication ''%s'' could not be removed from the list of synchronization partners.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
		(21252, 16, 0,'It is invalid to remove the default Publisher ''%s'', publication database ''%s'', and publication ''%s'' from the list of synchronization partners', 1033)

go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
		(21253, 16, 0,'Parameter ''@add_to_active_directory'' cannot be set to TRUE because Active Directory client package is not installed properly on the machine where SQL Server is running.', 1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
		(21254, 16, 0,'The Active Directory operation on publication ''%s'' could not be completed bacause Active Directory client package is not installed properly on the machine where SQL Server is running.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
		(21255, 16, 0,'Column ''%s'' already exists in table ''%s''.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
		(21256, 16, 0,'A column used in filter clause ''%s'' either does not exist in the table ''%s'' or cannot be excluded from the current partition. ', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
		(21257, 16, 0,'Invalid property ''%s'' for article ''%s''.', 1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
		(21258, 16, 0,'You must first drop all existing merge publications to add an anonymous or local subscription to database ''%s''.', 1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
		(21259, 16, 0,'Invalid property value ''%s''.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21260, 16, 0,'Schema replication failed because database ''%s'' on server ''%s'' is not the original Publisher of table ''%s''.', 1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21261,16,0,'The offload server must be specified if the agent for this subscription is to be offloaded for remote execution.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21262,16,0,'Failed to drop column ''%s'' from the partition because a computed column is accessing it.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21263,16,0,'Parameter ''%s'' cannot be NULL or an empty string.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21264,16,0,'Column ''%s'' cannot be dropped from table ''%s'' because it is a primary key column.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
        (21265,16,0,'Column ''%s'' cannot be dropped from table ''%s'' because there is a unique index accessing this column.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21266,16,0,'Cannot publish table ''%s'' for both a merge publication and a publication with the queued updating option .', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21267 ,10 ,0 ,'Invalid value for queue type was specified. Valid values = (%s).' ,1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21268 ,10 ,0 ,'Cannot change queue type while there are subscriptions to the publication.' ,1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21269,16,0,'Cannot add a computed column or a timestamp column to a vertical partition for a character mode publication.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21270 ,10 ,0 ,'Queued snapshot publication property ''%s'' cannot have the value ''%s''.' ,1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21272,16,0,'Cannot clean up the meta data for publication ''%s'' because other publications are using one or more articles in this publication.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21273,16,0,'You must upgrade the Subscriber to SQL Server 2000 to create updatable subscriptions to SQL Server 2000 Publishers.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21274,16,0,'Invalid publication name ''%s''.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21275,16,0,'The schema-bound view ''%ls''  can be published only as ''indexed view schema only''  or a log-based indexed view (transactional only) article. ' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21276 ,16 ,0 ,'The type must be ''table'' or ''( view | indexed view | proc | func ) schema only''.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21277,16,0,'The source object ''%ls'' must be a schema-bound view to be published as ''indexed view schema only'' or a log-based indexed view article.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21278,16,0,'The source object ''%ls'' must be a schema-bound view with at least a clustered index to be published as a log-based indexed view article.' ,1033)



insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21279,16,0,'The ''schema_option'' property for a merge article cannot be changed after a snapshot is generated for the publication. To change the ''schema_option'' property of this article the corresponding merge publication must be dropped and re-created.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21280,16,0,'Publication ''%s'' cannot be subscribed to by Subscriber database ''%s'' because it contains one or more articles that have been subscribed to by the same Subscriber database at transaction level.', 1033) 

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21281,16,0,'Publication ''%s'' cannot be subscribed to by Subscriber database ''%s'' because it contains one or more articles that have been subscribed to by the same Subscriber database at merge level.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21282,16,0,'@identity_range, @pub_identity_range, and @threshold must be NULL when @auto_identity_support is set to FALSE.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21283,16,0,'Column ''%s'' of table ''%s'' cannot be excluded from a vertical partition because there is a computed column that depends on it.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21284,16,0,'Failed to drop column ''%s'' from table ''%s''.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21285,16,0,'Failed to add column ''%s'' to table ''%s''.', 1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21286,16,0,'Conflict table ''%s'' does not exist.', 1033)

--del 21287?  
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21287 ,16 ,0 ,'The specified @destination_folder is not a valid path of an existing folder.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21288 ,16 ,0 ,'Could not create the snapshot directory structure in the specified @destination_folder.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21289 ,16 ,0 ,'Either the snapshot files have not been generated or they have been cleaned up.' ,1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21290,16,0,'Identity range value is too large for the data type of the identity column.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21291,16,0,'The specified automatic identity support parameters conflict with the settings in another article.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21292,16,0,'Object ''%s'' cannot be published twice in the same publication.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21293 ,10 ,0 ,'Warning: adding updatable subscription for article ''%s'' may cause data inconsistency as the source table is already subscribed to ''%s''' ,1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21294,16,0,'Either @publisher (and @publisher_db) or @subscriber (and @subscriber_db) must be specified, but both cannot be specified.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21295,16,0,'Publication ''%s'' does not contain any article that uses automatic identity range management.', 1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21296,16,0,'Parameter @resync_type must be either 0, 1, 2.', 1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21297,16,0,'Invalid resync type. No validation has been performed for this subscription.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21298,16,0,'Failed to resynchronize this subscription.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21299,16,0,'Invalid Subscriber partition validation expression ''%s''.', 1033)

 go

-- charun
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
		(21300, 10, 0,'The resolver information was specified without specifying the resolver to be used for article ''%s''. The default resolver will be used.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
		(21301, 16, 0,'The resolver information should be specified while using the ''%s'' resolver.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
		(21302, 16, 0,'The resolver information should specify a column with data type, datetime, or smalldatetime while using the ''%s'' resolver.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
		(21303, 16, 0,'The article ''%s'' should enable column tracking to use the ''%s'' resolver. The default resolver will be used to resolve conflicts on this article.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
		(21304, 16, 0,'The merge triggers could not be created on the table ''%s''.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
		(21305, 16, 0,'The schema change information could not be updated at the subscription database.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
		(21306, 16, 0,'The copy of the subscription could not be made because the subscription to publication ''%s'' has expired.', 1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
		(21307, 16, 0,'The subscription could not be attached because the subscription to publication ''%s'' has expired.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(21308,10,0,'Rowcount validation profile.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(21309,10,0,'Profile used by the Merge Agent to perform rowcount validation.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(21310,10,0,'Rowcount and checksum validation profile.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(21311,10,0,'Profile used by the Merge Agent to perform rowcount and checksum validation.', 1033)

go

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(21312,10,0,'Cannot change this publication property because there are active subscriptions to this publication.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(21313,10,0,'Subscriber partition validation expression must be NULL for static publications.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(21314,10,0,'There must be one and only one of ''%s'' and ''%s'' that is not NULL.', 1033)
go

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(21315,10,0,'Failed to adjust Publisher identity range for table ''%s''.', 1033)
go

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(21316,10,0,'Failed to adjust Publisher identity range for publication ''%s''.', 1033)
go

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(21317,10,0,'A push subscription to the publication ''%s'' already exists. Use sp_mergesubscription_cleanup to drop defunct push subscriptions.', 1033)
go

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(21318,10,0,'Table ''%s'' must have at least one column that is included in the vertical partition.', 1033)
go

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21319 ,16 ,0 ,'Could not find the Snapshot Agent command line for the specified publication.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21320,16,0,'This version of the Publisher cannot use a SQL Server 7.0 Distributor.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21321 ,16 ,0 ,'The parameter @dynamic_snapshot_location cannot be an empty string.' ,1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21323 ,16 ,0 ,'A dynamic snapshot job can be scheduled only for a publication with dynamic filtering enabled.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21324 ,16 ,0 ,'A Snapshot Agent must be added for the specified publication before a dynamic snapshot job can be scheduled.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21325 ,16 ,0 ,'Could not find the Snapshot Agent ID for the specified publication.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21326 ,16 ,0 ,'Could not find the dynamic snapshot job with a ''%ls'' of ''%ls'' for the specified publication.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21327 ,16 ,0 ,'''%ls'' is not a valid dynamic snapshot job name.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21328 ,16 ,0 ,'The specified dynamic snapshot job name ''%ls'' is already in use. Try the operation again with a different job name.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21329 ,16 ,0 ,'Only one of the parameters, @dynamic_snapshot_jobid or @dynamic_snapshot_jobname, can be specified with a nondefault value.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21330 ,16 ,0 ,'Failed to create a sub-directory under the replication working directory.(%ls)' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21331 ,16 ,0 ,'Failed to copy user script file to the Distributor.(%ls)' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21332 ,16 ,0 ,'Failed to retrieve information about the publication : %ls. Check the name again.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21333,16,0,'Protocol error. Message indicates a generation has disappeared.', 1033)
insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21334 ,16 ,0 ,'Cannot initialize Message Queuing-based subscription because the platform is not Message Queuing %s compliant' ,1033)
go

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21335,16,0,'Warning: column ''%s'' already exists in the vertical partition already.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21336,16,0,'Warning: column ''%s'' does not exist in the vertical partition.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21337, 16 ,0 ,'Invalid @subscriber_type value. Valid options are ''local'' and ''global''.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21338, 16 ,0 ,'Cannot drop article ''%s'' from publication ''%s'' because its snapshot has been run and this publication could have active subscriptions.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21339, 10 ,0 ,'Warning: the publication uses a feature that is only supported only by Ssubscribers running ''%s'' or higher.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21340 ,16 ,0 ,'On Demand user script cannot be applied to the snapshot publication.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21341 ,16 ,0 ,'@dynamic_snapshot_location cannot be a non-empty string while @alt_snapshot_folder is neither empty nor null.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21342 ,16 ,0 ,'@dynamic_snapshot_location cannot be a non-empty string while @use_ftp is ''true''.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21343, 16 ,0 ,'Could not find stored procedure ''%s''.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21344, 16 ,0 ,'Invalid value specified for %ls parameter.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21345, 16 ,0 ,'Excluding the last column in the partition is not allowed.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21346, 16 ,0 ,'Failed to change the owner of ''%s'' to ''%s''.',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21347, 16 ,0 ,'Column ''%s'' cannot be excluded from the vertical partitioning because there is a unique index accessing this column.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21348, 16 ,0 ,'Invalid property name ''%s''.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21349, 10 ,0 ,'Warning: only Subscribers running SQL Server 7.0 Service Pack 2 or later can synchronize with publication ''%s'' because decentralized conflict logging is designated.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21350, 10 ,0 ,'Warning: only Subscribers running SQL Server 2000 can synchronize with publication ''%s'' because a compressed snapshot is used.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21351, 10 ,0 ,'Warning: only Subscribers running SQL Server 2000 can synchronize with publication ''%s'' because vertical filters are being used.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21352, 10 ,0 ,'Warning: only Subscribers running SQL Server 2000 can synchronize with publication ''%s'' because schema replication is performed.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21353, 10 ,0 ,'Warning: only Subscribers running SQL Server 7.0 Service Pack 2 or later can synchronize with publication ''%s'' because publication wide reinitialization is performed.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21354, 10 ,0 ,'Warning: only Subscribers running SQL Server 2000 can synchronize with publication ''%s'' because publication wide reinitialization is performed.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21355, 10 ,0 ,'Warning: only Subscribers running SQL Server 7.0 Service Pack 2 or later can synchronize with publication ''%s'' because merge metadata cleanup task is performed.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21356, 10 ,0 ,'Warning: only Subscribers running SQL Server 7.0 Service Pack 2 or later can synchronize with publication ''%s'' because publication wide validation task is performed.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21357, 10 ,0 ,'Warning: only Subscribers running SQL Server 2000 can synchronize with publication ''%s'' because data types new in SQL Server 2000 exist in one of its articles.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21358, 10 ,0 ,'Warning: only Subscribers running SQL Server 2000 can synchronize with publication ''%s'' because at least one timestamp column exists in one of its articles..' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21359, 10 ,0 ,'Warning: only Subscribers running SQL Server 2000 can synchronize with publication ''%s'' because automatic identity ranges are being used.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21360, 10 ,0 ,'Warning: only Subscribers running SQL Server 2000 can synchronize with publication ''%s'' because a new article has been added to the publication after its snapshot has been generated.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21361 ,16 ,0 ,'The specified @agent_jobid is not a valid job id for a ''%s'' agent job.' ,1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21362 ,16 ,0 ,'Merge filter ''%s'' does not exist.' ,1033)
go
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21363 ,16 ,0 ,'Failed to add publication ''%s'' to Active Directory. %s',1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21364 ,16 ,0 ,'Could not add article ''%s'' because a snapshot is already generated. Set @force_invalidate_snapshot to 1 to force this and invalidate the existing snapshot.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21365 ,16 ,0 ,'Could not add article ''%s'' because there are active subscriptions. Set @force_reinit_subscription to 1 to force this and reintialize the active subscriptions.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21366 ,16 ,0 ,'Could not add filter ''%s'' because a snapshot is already generated. Set @force_invalidate_snapshot to 1 to force this and invalidate the existing snapshot.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21367 ,16 ,0 ,'Could not add filter ''%s'' because there are active subscriptions. Set @force_reinit_subscription to 1 to force this and reintialize the active subscriptions.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21368, 16 ,0 ,'The specified offload server name contains the invalid character ''%s''.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21369 ,16 ,0 ,'Could not remove publication ''%s'' from Active Directory.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21370 ,16 ,0 ,'The resync date specified ''%s'' is not a valid date.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21371 ,10 ,0 ,'Could not propagate the change on publication ''%s'' to Active Directory.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21372 ,16 ,0 ,'Cannot drop filter ''%s'' from publication ''%s'' because its snapshot has been run and this publication could have active subscriptions.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21373, 11, 0, 'Could not open database %s. Replication settings and system objects could not be upgraded. If the database is used for replication, run sp_vupgrade_replication in the [master] database when the database is available.', 1033 )

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21374, 10, 0, 'Upgrading distribution settings and system objects in database %s.', 1033 )

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21375, 10, 0, 'Upgrading publication settings and system objects in database %s.', 1033 )

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21376, 11, 0, 'Could not open database %s. Replication settings and system objects could not be upgraded. If the database is used for replication, run sp_vupgrade_replication in the [master] database when the database is available.', 1033 )

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21377, 10, 0, 'Upgrading subscription settings and system objects in database %s.', 1033 )

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
	values
	(21378, 16, 0, 'Could not open distribution database %s because it is offline or being recovered. Replication settings and system objects could not be upgraded. Be sure this database is available and run sp_vupgrade_replication again.', 1033 )

go


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21379 ,16 ,0 ,'Cannot drop article ''%s'' from publication ''%s'' because a snapshot is already generated. Set @force_invalidate_snapshot to 1 to force this and invalidate the existing snapshot.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21380 ,16 ,0 ,'Cannot add identity column without forcing reinitialization. Set @force_reinit_subscription to 1 to force reinitialization.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21381 ,16 ,0 ,'Cannot add (drop) column to table ''%s'' because the table belongs to publication(s) with an active updatable subscription. Set @force_reinit_subscription to 1 to force reinitialization.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21382 ,16 ,0 ,'Cannot drop filter ''%s'' because a snapshot is already generated. Set @force_invalidate_snapshot to 1 to force this and invalidate the existing snapshot.' ,1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21383 ,16 ,0 ,'Cannot enable a merge publication on this server because the working directory of its Distributors is not using a UNC path.' ,1033)


insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21384, 16 ,0 ,'The specified subscription does not exist or has not been synchronized yet.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21385, 16 ,0 ,'Snapshot failed to process publication ''%s''. Possibly due to active schema change activity.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21386, 16 ,0 ,'Schema change failed on publication ''%s''. Possibly due to active snapshot or other schema change activity.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21387, 16 ,0 ,'The expanded dynamic snapshot view definition of one of the articles exceeds the system limit of 3499 characters. Consider using the default mechanism instead of the dynamic snapshot for initializing the specified subscription.' ,1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
    	(21388, 10, 0, 'The concurrent snapshot for publication ''%s'' has not been activated by the Log Reader Agent.' ,1033) -- Used for formatmessage

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21389, 10, 0,'Warning: only Subscribers running SQL Server 2000 can synchronize with publication ''%s'' because column-level collation is scripted out with the article schema creation script.' ,1033)
go


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21390, 10, 0,'Warning: only Subscribers running SQL Server 2000 can synchronize with publication ''%s'' because extended properties are scripted out with the article schema creation script.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21391, 10, 0,'Warning: only Subscribers running SQL Server 2000 can synchronize with publication ''%s'' because it contains schema-only articles.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21392 ,16 ,0 ,'Row filter(%s) is invalid for column partition(%s) for article ''%s'' in publication ''%s''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    	values
    	(21393 ,16 ,0 ,'Dropping row filter(%s) for article ''%s'' in ''%s''. Reissue sp_articlefilter and sp_articleview to create a row filter.' ,1033)


insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21394 ,16 ,0 ,'Invalid schema option specified for Queued updating publication. Need to set the schema option to include DRI constraints.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21395, 10, 0, 'This column cannot be included in a transactional publication because the column ID is greater than 255.' ,1033) 

go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21400 ,16 ,0 ,'Article property must be changed at the original Publisher of article ''%s''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21401 ,16 ,0 ,'Article name cannot be ''all''.' ,1033)

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21402 ,16 ,0 ,'Incorrect value for parameter ''%s''.' ,1033)
go

insert into master..sysmessages (error, severity ,dlevel ,description ,msglangid)
    values
    (21403, 10, 0,'The ''max_concurrent_dynamic_snapshots'' publication property must be greater than or equal to zero.' ,1033)
go
insert into master..sysmessages (error, severity ,dlevel ,description ,msglangid)
    values
    (21404, 10, 0,'''%s'' is not a valid value for the ''%s'' parameter. The value must be a positive integer greater than 300 or 0.' ,1033)
go

insert into master..sysmessages (error, severity ,dlevel ,description ,msglangid)
    values
    (21405, 10, 0,'''%s'' is not a valid value for the ''%s'' parameter. The value must be an integer greater than or equal to %d.' ,1033)
go

insert into master..sysmessages (error, severity ,dlevel ,description ,msglangid)
    values
    (21406, 10, 0,'''%s'' is not a valid value for the ''%s'' parameter. The value must be 0 or 1.' ,1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21413 ,16 ,0 ,'Failed to acquire the application lock indicating the front of the queue.' ,1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21414 ,10 ,0 ,'Unexpected failure acquiring application lock.' ,1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21415 ,10 ,0 ,'Unexpected failure releasing application lock.' ,1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21416 ,10 ,0 ,'Property ''%s'' of article ''%s'' cannot be changed.' ,1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21417 ,10 ,0 ,'Having a queue timeout value of over 12 hours is not allowed.' ,1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21418 ,10 ,0 ,'Failed to add column ''%s'' to table ''%s'' because of metadata overflow.' ,1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21419 ,10 ,0 ,'Filter ''%s'' of article ''%s'' cannot be changed.' ,1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21420 ,10 ,0 ,'Subscription property ''%s'' cannot be changed.' ,1033)
go

insert into master..sysmessages (error ,severity ,dlevel ,description ,msglangid)
    values
    (21421 ,10 ,0 ,'Article ''%s'' cannot be dropped because there are other articles using it as a join article.' ,1033)
go

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(21500,10,0,'Invalid subscription type is specified. A subscription to publication ''%s'' already exists in the database with a different subscription type.', 1033)
go

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(21501,10,0,'The supplied resolver information does not specify a valid column name to be used for conflict resolution by ''%s''.', 1033)
go
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
		(21502,10,0,'The publication ''%s'' does not allow the subscription to synchronize to an alternate synchronization partner.', 1033)

GO

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21503,10,0,'Cleanup of merge meta data cannot be performed while merge processes are running. Retry this operation after the merge processes have completed.', 1033)

GO

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21504,10,0,'Cleanup of merge meta data at republisher ''%s''.''%s'' could not be performed because merge processes are propagating changes to the republisher. All subscriptions to this republisher must be reinitialized.', 1033)
GO

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21505,10,0,'Changes to publication ''%s'' cannot be merged because it has been marked inactive.', 1033)
GO

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21506,10,0,'sp_mergecompletecleanup cannot be executed before sp_mergepreparecleanup is executed. Use sp_mergepreparecleanup to initiate the first phase of merge meta data cleanup.', 1033)
GO

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21507,10,0,'All prerequisites for cleaning up merge meta data have been completed. Execute sp_mergecompletecleanup to initiate the final phase of merge meta data cleanup.', 1033)
GO

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21508,10,0,'Cleanup of merge meta data cannot be performed while merge processes are running. Cleanup will proceed after the merge processes have completed.', 1033)

GO

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21509,10,0,'Cleanup of merge meta data cannot be performed because some republishers have not quiesced their changes. Cleanup will proceed after all republishers have quiesced their changes.', 1033)

GO

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21510,10,0,'Data changes are not allowed while cleanup of merge meta data is in progress.', 1033)

GO

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21511,10,0,'Neither MSmerge_contents nor MSmerge_tombstone contain meta data for this row.', 1033)

GO

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21512,18,0,'%ls: The %ls parameter is shorter than the minimum required size.', 1033)
GO

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21513,18,0,'Foreign key column ''%s'' cannot be excluded from a vertical partition.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21515,18,0,'Replication custom procedures will not be scripted because the specified publication ''%s'' is a snapshot publication.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21516,10,0,'Transactional replication custom procedures for publication ''%s'' from database ''%s'':', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21517,10,0,'Replication custom procedures will not be scripted for article ''%s'' because the auto-generate custom procedures schema option is not enabled.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21518,0,0,'Replication custom procedures for article ''%s'':', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21519,10,0,'Custom procedures will not be scripted for article update commands based on direct INSERT, UPDATE, or DELETE statements.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21520,10,0,'Custom procedure will not be scripted because ''%s'' is not a recognized article update command syntax.', 1033)

insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21410,10,0,'Snapshot Agent startup message.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21411,10,0,'Distribution Agent startup message.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21412,10,0,'Merge Agent startup message.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21422,10,0,'Queue Reader Agent startup message.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21695,10,0,'The job name ''%s'' was not generated for this replication agent, delete the job manually when it is no longer in use.', 1033)
insert into master..sysmessages (error, severity, dlevel, description, msglangid)
	values
	(21423,10,0,'You do not have sufficient privileges to view the publication information. Your administrator may need to fix the PAL role on the publisher for publication ''%s''.', 1033)


BACKUP TRANSACTION master WITH TRUNCATE_ONLY
go

if object_id('sp_configure','P') IS NOT NULL
	begin
		exec sp_configure 'allow updates',0
		reconfigure with override
	end
go

declare @vdt varchar(99)
select  @vdt = convert(varchar,getdate(),113)
raiserror('
Finishing Install\Messages.SQL at  %s',0,1,@vdt)
go
Checkpoint
go
-- -


