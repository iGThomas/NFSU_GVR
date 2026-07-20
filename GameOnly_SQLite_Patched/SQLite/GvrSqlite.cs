// GvrSqlite.cs — a minimal ADO.NET-shaped provider backed by SQLite, built to
// stand in for System.Data.SqlClient inside the GlobalVR cabinet engine
// (PLUSDE.dll) after a dnlib typeref-swap. Written in C# 1.x style (NO generics)
// so the compiled assembly can be retargeted to .NET 1.1 (the game's CLR).
//
// The dnlib patch remaps:
//   System.Data.SqlClient.SqlConnection          -> GvrSqlite.GvrConnection
//   System.Data.SqlClient.SqlCommand             -> GvrSqlite.GvrCommand
//   System.Data.SqlClient.SqlDataAdapter         -> GvrSqlite.GvrDataAdapter
//   System.Data.SqlClient.SqlParameter           -> GvrSqlite.GvrParameter
//   System.Data.SqlClient.SqlParameterCollection -> GvrSqlite.GvrParameterCollection
//   System.Data.SqlClient.SqlException           -> GvrSqlite.GvrException
//   System.Data.SqlClient.SqlError               -> GvrSqlite.GvrError
//   System.Data.SqlClient.SqlErrorCollection     -> GvrSqlite.GvrErrorCollection
//   System.Data.SqlClient.SqlInfoMessageEventHandler -> GvrSqlite.GvrInfoMessageEventHandler
//   System.Data.SqlClient.SqlInfoMessageEventArgs    -> GvrSqlite.GvrInfoMessageEventArgs
// and the DbDataAdapter/DataAdapter members Fill/Update/TableMappings/
// ContinueUpdateOnError -> GvrDataAdapter's own members.
//
// Member signatures below match the exact MemberRefs PLUSDE.dll uses.

using System;
using System.Collections;
using System.Data;
using System.Data.Common;
using System.Globalization;
using System.Runtime.InteropServices;
using System.Text;

namespace GvrSqlite
{
    // ---- native sqlite3 (x86, cdecl) --------------------------------------
    internal sealed class Native
    {
        private const string DLL = "sqlite3.dll";
        private const CallingConvention CC = CallingConvention.Cdecl;

        internal const int OK = 0, ROW = 100, DONE = 101;
        internal const int SI_INTEGER = 1, SI_FLOAT = 2, SI_TEXT = 3, SI_BLOB = 4, SI_NULL = 5;
        internal static readonly IntPtr TRANSIENT = new IntPtr(-1);

        [DllImport(DLL, CallingConvention = CC)] internal static extern int sqlite3_open(byte[] filename, out IntPtr db);
        [DllImport(DLL, CallingConvention = CC)] internal static extern int sqlite3_close(IntPtr db);
        [DllImport(DLL, CallingConvention = CC)] internal static extern int sqlite3_prepare_v2(IntPtr db, byte[] sql, int nByte, out IntPtr stmt, out IntPtr tail);
        [DllImport(DLL, CallingConvention = CC)] internal static extern int sqlite3_step(IntPtr stmt);
        [DllImport(DLL, CallingConvention = CC)] internal static extern int sqlite3_finalize(IntPtr stmt);
        [DllImport(DLL, CallingConvention = CC)] internal static extern int sqlite3_column_count(IntPtr stmt);
        [DllImport(DLL, CallingConvention = CC)] internal static extern IntPtr sqlite3_column_name(IntPtr stmt, int i);
        [DllImport(DLL, CallingConvention = CC)] internal static extern int sqlite3_column_type(IntPtr stmt, int i);
        [DllImport(DLL, CallingConvention = CC)] internal static extern IntPtr sqlite3_column_text(IntPtr stmt, int i);
        [DllImport(DLL, CallingConvention = CC)] internal static extern long sqlite3_column_int64(IntPtr stmt, int i);
        [DllImport(DLL, CallingConvention = CC)] internal static extern double sqlite3_column_double(IntPtr stmt, int i);
        [DllImport(DLL, CallingConvention = CC)] internal static extern int sqlite3_bind_text(IntPtr stmt, int idx, byte[] val, int n, IntPtr free);
        [DllImport(DLL, CallingConvention = CC)] internal static extern int sqlite3_bind_int64(IntPtr stmt, int idx, long val);
        [DllImport(DLL, CallingConvention = CC)] internal static extern int sqlite3_bind_double(IntPtr stmt, int idx, double val);
        [DllImport(DLL, CallingConvention = CC)] internal static extern int sqlite3_bind_null(IntPtr stmt, int idx);
        [DllImport(DLL, CallingConvention = CC)] internal static extern int sqlite3_changes(IntPtr db);
        [DllImport(DLL, CallingConvention = CC)] internal static extern IntPtr sqlite3_errmsg(IntPtr db);

        internal static byte[] Utf8z(string s)
        {
            if (s == null) s = "";
            byte[] b = Encoding.UTF8.GetBytes(s);
            byte[] r = new byte[b.Length + 1];
            Array.Copy(b, r, b.Length);
            return r;
        }
        internal static string FromUtf8(IntPtr p)
        {
            if (p == IntPtr.Zero) return null;
            int len = 0;
            while (Marshal.ReadByte(p, len) != 0) len++;
            if (len == 0) return "";
            byte[] b = new byte[len];
            Marshal.Copy(p, b, 0, len);
            return Encoding.UTF8.GetString(b);
        }
    }

    // ---- diagnostic log (remove for release) ------------------------------
    internal sealed class Log
    {
        private static readonly object _lock = new object();
        // Off by default. Set env var GVRSQLITE_LOG (to anything) to enable tracing.
        private static readonly bool _on = (Environment.GetEnvironmentVariable("GVRSQLITE_LOG") != null);
        internal static void W(string s)
        {
            if (!_on) return;
            try
            {
                lock (_lock)
                {
                    System.IO.StreamWriter sw = new System.IO.StreamWriter("C:\\gvrsqlite.log", true);
                    sw.WriteLine(DateTime.Now.ToString("HH:mm:ss.fff") + "  " + s);
                    sw.Close();
                }
            }
            catch { }
        }
    }

    // ---- connection --------------------------------------------------------
    public sealed class GvrConnection
    {
        internal IntPtr Db = IntPtr.Zero;
        private string _cs;
        private ConnectionState _state = ConnectionState.Closed;
        internal Hashtable ColMeta;   // "table.column" -> sql-server type string (optional)

        public GvrConnection() { }

        public string ConnectionString { get { return _cs; } set { _cs = value; } }
        public ConnectionState State { get { return _state; } }

        // consumed but never fired
        public event GvrInfoMessageEventHandler InfoMessage;
        internal void RaiseInfo() { if (InfoMessage != null) { } }

        // Parse a SQL Server style connection string and derive the sqlite db path.
        // "Data Source=..." is ignored; we look for our own hints or default to
        // <dir of this dll>\game.db. Supports "Initial Catalog=<path-or-name>".
        private string ResolveDbPath()
        {
            // Shared DB for both the cabinet (UndergroundGVR.exe) and shell
            // (UniverShell2.exe) processes: a fixed absolute path wins so they
            // never diverge into per-folder databases.
            string env = Environment.GetEnvironmentVariable("GVRSQLITE_DB");
            if (env != null && env.Length > 0) return env;
            string path = null;
            if (_cs != null)
            {
                string[] parts = _cs.Split(';');
                for (int i = 0; i < parts.Length; i++)
                {
                    string kv = parts[i];
                    int eq = kv.IndexOf('=');
                    if (eq <= 0) continue;
                    string k = kv.Substring(0, eq).Trim().ToLower(CultureInfo.InvariantCulture);
                    string v = kv.Substring(eq + 1).Trim();
                    if (k == "sqlite" || k == "attachdbfilename" || k == "data source file") { path = v; break; }
                    if (k == "initial catalog" && (v.IndexOf('\\') >= 0 || v.ToLower(CultureInfo.InvariantCulture).EndsWith(".db"))) path = v;
                }
            }
            if (path == null || path.Length == 0)
            {
                // relocation-aware: derive the shared db from the game's own registry
                // PlusSchemaPath (<GvrPlus>\1\schema\...), so it works at any install
                // location without an env var. Cabinet + shell resolve the same file.
                string reg = DbFromRegistry();
                if (reg != null) return reg;
                if (System.IO.File.Exists("C:\\GvrPlus\\game.db")) return "C:\\GvrPlus\\game.db";
                string dir = System.IO.Path.GetDirectoryName(typeof(GvrConnection).Assembly.Location);
                path = System.IO.Path.Combine(dir, "game.db");
            }
            return path;
        }

        private static string DbFromRegistry()
        {
            try
            {
                Microsoft.Win32.RegistryKey k = Microsoft.Win32.Registry.LocalMachine.OpenSubKey("SOFTWARE\\Gvr\\Plus\\1.1\\Cabinet");
                if (k == null) return null;
                object sp = k.GetValue("PlusSchemaPath");
                k.Close();
                if (sp == null) return null;
                string dir = System.IO.Path.GetDirectoryName(sp.ToString()); // <GvrPlus>\1\schema
                if (dir == null) return null;
                dir = System.IO.Path.GetDirectoryName(dir);                  // <GvrPlus>\1
                if (dir == null) return null;
                dir = System.IO.Path.GetDirectoryName(dir);                  // <GvrPlus>
                if (dir == null) return null;
                string cand = System.IO.Path.Combine(dir, "game.db");
                if (System.IO.File.Exists(cand)) return cand;
            }
            catch { }
            return null;
        }

        public void Open()
        {
            if (_state == ConnectionState.Open) return;
            string path = ResolveDbPath();
            Log.W("Open cs=[" + _cs + "] -> db=[" + path + "]");
            int rc = Native.sqlite3_open(Native.Utf8z(path), out Db);
            Log.W("sqlite3_open rc=" + rc);
            if (rc != Native.OK) throw new GvrException("sqlite3_open failed (" + rc + ") for " + path);
            _state = ConnectionState.Open;
            LoadColMeta();
            Log.W("Open OK, colmeta=" + (ColMeta == null ? -1 : ColMeta.Count));
        }

        public void Close()
        {
            if (Db != IntPtr.Zero) { Native.sqlite3_close(Db); Db = IntPtr.Zero; }
            _state = ConnectionState.Closed;
        }

        private void LoadColMeta()
        {
            ColMeta = new Hashtable();
            IntPtr st;
            IntPtr tail;
            byte[] sql = Native.Utf8z("SELECT tbl,col,sstype FROM _gvrmeta");
            if (Native.sqlite3_prepare_v2(Db, sql, -1, out st, out tail) != Native.OK) return; // table optional
            while (Native.sqlite3_step(st) == Native.ROW)
            {
                string t = Native.FromUtf8(Native.sqlite3_column_text(st, 0));
                string c = Native.FromUtf8(Native.sqlite3_column_text(st, 1));
                string s = Native.FromUtf8(Native.sqlite3_column_text(st, 2));
                if (t != null && c != null) ColMeta[(t + "." + c).ToLower(CultureInfo.InvariantCulture)] = s;
            }
            Native.sqlite3_finalize(st);
        }

        internal string SsType(string table, string col)
        {
            if (ColMeta == null || table == null || col == null) return null;
            return (string)ColMeta[(table + "." + col).ToLower(CultureInfo.InvariantCulture)];
        }
    }

    // ---- parameter & collection -------------------------------------------
    public sealed class GvrParameter
    {
        public string ParameterName;
        public SqlDbType SqlType;
        public int Size;
        public string SourceColumn;
        private object _value;
        public object Value { get { return _value; } set { _value = value; } }
        public GvrParameter(string name, SqlDbType t, int size, string src)
        { ParameterName = name; SqlType = t; Size = size; SourceColumn = src; }
    }

    public sealed class GvrParameterCollection
    {
        internal ArrayList Items = new ArrayList();
        public GvrParameter this[int i] { get { return (GvrParameter)Items[i]; } }
        public int Count { get { return Items.Count; } }
        public GvrParameter Add(string name, SqlDbType t, int size, string src)
        {
            GvrParameter p = new GvrParameter(name, t, size, src);
            Items.Add(p);
            return p;
        }
    }

    // ---- command -----------------------------------------------------------
    public sealed class GvrCommand
    {
        private string _commandText;
        public string CommandText { get { return _commandText; } set { _commandText = value; } }
        private CommandType _commandType = CommandType.Text;
        public CommandType CommandType { get { return _commandType; } set { _commandType = value; } }
        private GvrConnection _connection;
        public GvrConnection Connection { get { return _connection; } set { _connection = value; } }
        private GvrParameterCollection _params = new GvrParameterCollection();
        public GvrParameterCollection Parameters { get { return _params; } }

        public GvrCommand() { }
        public GvrCommand(string text, GvrConnection conn) { CommandText = text; Connection = conn; }

        // Translate the game's command into (sqlText, orderedParamValues).
        internal string Translate(out object[] values, out bool isQuery)
        {
            isQuery = false;
            if (CommandType == CommandType.StoredProcedure)
                return Sql.FromProc(CommandText, _params, out values, out isQuery);
            // Text: raw SQL, values come from parameters in declared order.
            ArrayList vs = new ArrayList();
            for (int i = 0; i < _params.Count; i++) vs.Add(_params[i].Value);
            values = (object[])vs.ToArray(typeof(object));
            string s = Sql.FixDialect(CommandText);
            string up = s.TrimStart().ToUpper(CultureInfo.InvariantCulture);
            isQuery = up.StartsWith("SELECT");
            return s;
        }

        public int ExecuteNonQuery()
        {
            try
            {
                object[] vals; bool q;
                string sql = Translate(out vals, out q);
                return Exec(sql, vals);
            }
            catch (Exception ex) { Log.W("ExecuteNonQuery EX type=" + CommandType + " text=[" + CommandText + "] " + ex.GetType().FullName + ": " + ex.Message + "\n" + ex.StackTrace); throw; }
        }

        internal int Exec(string sql, object[] vals)
        {
            Log.W("Exec: " + sql);
            IntPtr st, tail;
            int rc = Native.sqlite3_prepare_v2(Connection.Db, Native.Utf8z(sql), -1, out st, out tail);
            if (rc != Native.OK) { string e = Native.FromUtf8(Native.sqlite3_errmsg(Connection.Db)); Log.W("  prepare FAIL rc=" + rc + " err=" + e); throw new GvrException("prepare failed (" + rc + "): " + e + " || " + sql); }
            Bind(st, vals);
            rc = Native.sqlite3_step(st);
            Native.sqlite3_finalize(st);
            if (rc != Native.DONE && rc != Native.ROW)
            { string e = Native.FromUtf8(Native.sqlite3_errmsg(Connection.Db)); Log.W("  step FAIL rc=" + rc + " err=" + e); throw new GvrException("step failed (" + rc + "): " + e + " || " + sql); }
            int ch = Native.sqlite3_changes(Connection.Db);
            Log.W("  Exec OK changes=" + ch);
            return ch;
        }

        internal static void Bind(IntPtr st, object[] vals)
        {
            if (vals == null) return;
            for (int i = 0; i < vals.Length; i++)
            {
                int idx = i + 1;
                object v = vals[i];
                if (v == null || v == DBNull.Value) { Native.sqlite3_bind_null(st, idx); continue; }
                Type t = v.GetType();
                if (t == typeof(string)) Native.sqlite3_bind_text(st, idx, Native.Utf8z((string)v), -1, Native.TRANSIENT);
                else if (t == typeof(long)) Native.sqlite3_bind_int64(st, idx, (long)v);
                else if (t == typeof(int)) Native.sqlite3_bind_int64(st, idx, (int)v);
                else if (t == typeof(short)) Native.sqlite3_bind_int64(st, idx, (short)v);
                else if (t == typeof(byte)) Native.sqlite3_bind_int64(st, idx, (byte)v);
                else if (t == typeof(bool)) Native.sqlite3_bind_int64(st, idx, ((bool)v) ? 1 : 0);
                else if (t == typeof(double)) Native.sqlite3_bind_double(st, idx, (double)v);
                else if (t == typeof(float)) Native.sqlite3_bind_double(st, idx, (float)v);
                else if (t == typeof(decimal)) Native.sqlite3_bind_double(st, idx, (double)(decimal)v);
                else if (t == typeof(DateTime)) Native.sqlite3_bind_text(st, idx, Native.Utf8z(((DateTime)v).ToString("yyyy-MM-dd HH:mm:ss", CultureInfo.InvariantCulture)), -1, Native.TRANSIENT);
                else Native.sqlite3_bind_text(st, idx, Native.Utf8z(Convert.ToString(v, CultureInfo.InvariantCulture)), -1, Native.TRANSIENT);
            }
        }
    }

    // ---- data adapter ------------------------------------------------------
    public sealed class GvrDataAdapter
    {
        private GvrCommand _sel, _ins, _upd, _del;
        public GvrCommand SelectCommand { get { return _sel; } set { _sel = value; } }
        public GvrCommand InsertCommand { get { return _ins; } set { _ins = value; } }
        public GvrCommand UpdateCommand { get { return _upd; } set { _upd = value; } }
        public GvrCommand DeleteCommand { get { return _del; } set { _del = value; } }
        private bool _continueOnError;
        public bool ContinueUpdateOnError { get { return _continueOnError; } set { _continueOnError = value; } }
        private DataTableMappingCollection _maps = new DataTableMappingCollection();
        public DataTableMappingCollection TableMappings { get { return _maps; } }

        public GvrDataAdapter() { }

        public int Fill(DataSet ds)
        {
            try
            {
                DataTable dt = new DataTable();
                int n = FillTable(dt, SelectCommand);
                ds.Tables.Add(dt);
                return n;
            }
            catch (Exception ex) { Log.W("Fill EX " + ex.GetType().FullName + ": " + ex.Message + "\n" + ex.StackTrace); throw; }
        }

        internal int FillTable(DataTable dt, GvrCommand cmd)
        {
            object[] vals; bool q;
            string sql = cmd.Translate(out vals, out q);
            Log.W("Fill: " + sql);
            IntPtr st, tail;
            int rc = Native.sqlite3_prepare_v2(cmd.Connection.Db, Native.Utf8z(sql), -1, out st, out tail);
            if (rc != Native.OK) { string e = Native.FromUtf8(Native.sqlite3_errmsg(cmd.Connection.Db)); Log.W("  Fill prepare FAIL rc=" + rc + " err=" + e); throw new GvrException("prepare(select) failed (" + rc + "): " + e + " || " + sql); }
            GvrCommand.Bind(st, vals);
            int cols = Native.sqlite3_column_count(st);
            string table = Sql.TableOf(sql);
            string[] names = new string[cols];
            for (int i = 0; i < cols; i++)
            {
                names[i] = Native.FromUtf8(Native.sqlite3_column_name(st, i));
                if (!dt.Columns.Contains(names[i]))
                    dt.Columns.Add(names[i], NetType(cmd.Connection.SsType(table, names[i])));
            }
            int rows = 0;
            while (Native.sqlite3_step(st) == Native.ROW)
            {
                DataRow row = dt.NewRow();
                for (int i = 0; i < cols; i++)
                    row[i] = ReadValue(st, i, dt.Columns[i].DataType);
                dt.Rows.Add(row);
                rows++;
            }
            Native.sqlite3_finalize(st);
            return rows;
        }

        // ADO.NET Update: persist changed rows through Insert/Delete commands.
        public int Update(DataSet ds)
        {
            int n = 0;
            for (int i = 0; i < ds.Tables.Count; i++) n += Update(ds.Tables[i]);
            return n;
        }
        public int Update(DataTable dt)
        {
            int n = 0;
            DataRow[] rows = dt.Select(null, null, DataViewRowState.Added | DataViewRowState.ModifiedCurrent | DataViewRowState.Deleted);
            for (int r = 0; r < rows.Length; r++)
            {
                DataRow row = rows[r];
                GvrCommand cmd = null;
                bool deleted = (row.RowState == DataRowState.Deleted);
                cmd = deleted ? DeleteCommand : InsertCommand; // InsertCommand carries SP_InsertOrUpdate_
                if (cmd == null) continue;
                object[] vals = new object[cmd.Parameters.Count];
                for (int p = 0; p < cmd.Parameters.Count; p++)
                {
                    GvrParameter par = cmd.Parameters[p];
                    string sc = par.SourceColumn;
                    object v = null;
                    if (sc != null && sc.Length > 0 && dt.Columns.Contains(sc))
                        v = deleted ? row[sc, DataRowVersion.Original] : row[sc];
                    else v = par.Value;
                    vals[p] = v;
                }
                object[] tvals; bool q;
                string sql = cmd.CommandType == CommandType.StoredProcedure
                    ? Sql.FromProcValues(cmd.CommandText, cmd.Parameters, vals, out tvals)
                    : cmd.Translate(out tvals, out q);
                if (cmd.CommandType != CommandType.StoredProcedure) tvals = vals;
                try { n += cmd.Exec(sql, tvals); row.AcceptChanges(); }
                catch { if (!ContinueUpdateOnError) throw; }
            }
            return n;
        }

        private static Type NetType(string ss)
        {
            if (ss == null) return typeof(object);
            string t = ss.ToLower(CultureInfo.InvariantCulture);
            if (t.StartsWith("bigint")) return typeof(long);
            if (t.StartsWith("int") || t.StartsWith("smallint") || t.StartsWith("tinyint")) return typeof(int);
            if (t.StartsWith("bit")) return typeof(bool);
            if (t.StartsWith("datetime") || t.StartsWith("smalldatetime")) return typeof(DateTime);
            if (t.StartsWith("float") || t.StartsWith("real") || t.StartsWith("decimal") || t.StartsWith("numeric") || t.StartsWith("money")) return typeof(double);
            return typeof(string);
        }

        private static object ReadValue(IntPtr st, int i, Type want)
        {
            int ct = Native.sqlite3_column_type(st, i);
            if (ct == Native.SI_NULL) return DBNull.Value;
            if (want == typeof(long)) return Native.sqlite3_column_int64(st, i);
            if (want == typeof(int)) return (int)Native.sqlite3_column_int64(st, i);
            if (want == typeof(bool)) return Native.sqlite3_column_int64(st, i) != 0;
            if (want == typeof(double)) return Native.sqlite3_column_double(st, i);
            if (want == typeof(DateTime))
            {
                string s = Native.FromUtf8(Native.sqlite3_column_text(st, i));
                DateTime dtv;
                if (s != null && s.Length > 0 && TryParseDate(s, out dtv)) return dtv;
                return DBNull.Value;
            }
            // default: text
            if (ct == Native.SI_INTEGER) return Native.sqlite3_column_int64(st, i).ToString(CultureInfo.InvariantCulture);
            if (ct == Native.SI_FLOAT) return Native.sqlite3_column_double(st, i).ToString(CultureInfo.InvariantCulture);
            return Native.FromUtf8(Native.sqlite3_column_text(st, i));
        }

        private static bool TryParseDate(string s, out DateTime dt)
        {
            dt = DateTime.MinValue;
            try { dt = DateTime.Parse(s, CultureInfo.InvariantCulture); return true; }
            catch { return false; }
        }
    }

    // ---- SQL translation ---------------------------------------------------
    internal sealed class Sql
    {
        // Stored proc "SP_<Op>_<Table>" + parameter collection -> SQLite text.
        internal static string FromProc(string proc, GvrParameterCollection ps, out object[] values, out bool isQuery)
        {
            ArrayList vs = new ArrayList();
            for (int i = 0; i < ps.Count; i++) vs.Add(ps[i].Value);
            values = (object[])vs.ToArray(typeof(object));
            return Build(proc, ps, values, out isQuery);
        }
        internal static string FromProcValues(string proc, GvrParameterCollection ps, object[] values, out object[] outValues)
        {
            bool q; outValues = values; return Build(proc, ps, values, out q);
        }

        private static string Build(string proc, GvrParameterCollection ps, object[] values, out bool isQuery)
        {
            isQuery = false;
            string name = proc.Trim();
            if (name.Length > 0 && name[0] == '[') name = name.Replace("[", "").Replace("]", "");
            // split into op + table on the SP_<Op>_ prefix
            string op, table;
            SplitProc(name, out op, out table);
            string[] cols = ColNames(ps);
            switch (op)
            {
                case "InsertOrUpdate":
                case "Insert":
                    return "INSERT OR REPLACE INTO [" + table + "] (" + Join(cols, null) + ") VALUES (" + Marks(cols.Length) + ")";
                case "Update":
                {
                    // first col is PK
                    StringBuilder sb = new StringBuilder("UPDATE [" + table + "] SET ");
                    for (int i = 1; i < cols.Length; i++) { if (i > 1) sb.Append(", "); sb.Append("[").Append(cols[i]).Append("]=?"); }
                    sb.Append(" WHERE [").Append(cols[0]).Append("]=?");
                    // reorder values: set-cols then pk
                    // (caller passes values in declared order pk,rest..; we reorder)
                    Reorder(values);
                    return sb.ToString();
                }
                case "Delete":
                    return "DELETE FROM [" + table + "] WHERE [" + cols[0] + "]=?";
                case "Get":
                    isQuery = true;
                    return "SELECT * FROM [" + table + "] WHERE [" + cols[0] + "]=?";
                case "GetSet":
                    isQuery = true;
                    return "SELECT * FROM [" + table + "]";
                default:
                    // Depth variants and anything else: best-effort upsert
                    return "INSERT OR REPLACE INTO [" + table + "] (" + Join(cols, null) + ") VALUES (" + Marks(cols.Length) + ")";
            }
        }

        private static void Reorder(object[] v)
        {
            if (v == null || v.Length < 2) return;
            object pk = v[0];
            for (int i = 0; i < v.Length - 1; i++) v[i] = v[i + 1];
            v[v.Length - 1] = pk;
        }

        private static void SplitProc(string name, out string op, out string table)
        {
            op = ""; table = name;
            if (name.StartsWith("SP_") || name.StartsWith("sp_")) name = name.Substring(3);
            int us = name.IndexOf('_');
            if (us > 0) { op = name.Substring(0, us); table = name.Substring(us + 1); }
            else { op = name; table = ""; }
        }

        private static string[] ColNames(GvrParameterCollection ps)
        {
            string[] c = new string[ps.Count];
            for (int i = 0; i < ps.Count; i++)
            {
                string src = ps[i].SourceColumn;
                if (src == null || src.Length == 0)
                {
                    src = ps[i].ParameterName;
                    if (src != null && src.Length > 0 && src[0] == '@') src = src.Substring(1);
                }
                c[i] = src;
            }
            return c;
        }

        private static string Join(string[] cols, string suffix)
        {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < cols.Length; i++) { if (i > 0) sb.Append(", "); sb.Append("[").Append(cols[i]).Append("]"); }
            return sb.ToString();
        }
        private static string Marks(int n)
        {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < n; i++) { if (i > 0) sb.Append(", "); sb.Append("?"); }
            return sb.ToString();
        }

        internal static string TableOf(string sql)
        {
            // extract the table name after FROM for column-type lookup
            string u = sql.ToUpper(CultureInfo.InvariantCulture);
            int f = u.IndexOf(" FROM ");
            if (f < 0) return null;
            string rest = sql.Substring(f + 6).TrimStart();
            StringBuilder sb = new StringBuilder();
            foreach (char c in rest)
            {
                if (c == '[' || c == ']') continue;
                if (char.IsLetterOrDigit(c) || c == '_') sb.Append(c); else break;
            }
            return sb.Length > 0 ? sb.ToString() : null;
        }

        // Minimal T-SQL -> SQLite fixups for the game's direct text commands.
        internal static string FixDialect(string sql)
        {
            if (sql == null) return sql;
            string s = sql;
            s = s.Replace("dbo.", "");
            // GETDATE() -> datetime('now')
            s = ReplaceCI(s, "GETDATE()", "datetime('now')");
            // SELECT TOP n -> ... LIMIT n
            s = TopToLimit(s);
            return s;
        }

        // T-SQL "SELECT TOP n ..." has no SQLite equivalent - SQLite spells it as a trailing
        // "LIMIT n". Without this the statement does not even parse (sqlite reports
        // near "1": syntax error), Fill throws, and the caller silently gets no rows.
        // The shell leans on this for every car-configuration lookup
        // (SELECT TOP 1 * FROM CarConfiguration_NFS1 WHERE ConfigType=.. AND CarType=..),
        // so with it failing each car in the frontend is drawn with no paint and no vinyl -
        // i.e. every car is white. Also used by the leaderboard/best-time queries
        // (GameResult_NFS1) and TempPlayerInfo_NFS1.
        internal static string TopToLimit(string s)
        {
            if (s == null) return s;
            int i = SkipWs(s, 0);
            while (i < s.Length && s[i] == '(') i = SkipWs(s, i + 1);
            if (!IsWordAt(s, i, "SELECT")) return s;
            int p = SkipWs(s, i + 6);
            if (IsWordAt(s, p, "DISTINCT")) p = SkipWs(s, p + 8);
            else if (IsWordAt(s, p, "ALL")) p = SkipWs(s, p + 3);
            if (!IsWordAt(s, p, "TOP")) return s;

            int numStart = SkipWs(s, p + 3);
            bool paren = false;
            if (numStart < s.Length && s[numStart] == '(') { paren = true; numStart = SkipWs(s, numStart + 1); }
            int numEnd = numStart;
            while (numEnd < s.Length && char.IsDigit(s[numEnd])) numEnd++;
            if (numEnd == numStart) return s;            // TOP @var / non-literal - leave alone
            string n = s.Substring(numStart, numEnd - numStart);

            int end = numEnd;
            if (paren) { end = SkipWs(s, end); if (end < s.Length && s[end] == ')') end++; }
            // TOP n PERCENT / WITH TIES have no clean LIMIT equivalent - better to leave the
            // statement untouched (and fail loudly) than to silently return the wrong rows.
            if (IsWordAt(s, SkipWs(s, end), "PERCENT")) return s;

            string body = (s.Substring(0, p) + s.Substring(end).TrimStart()).TrimEnd();
            bool semi = body.EndsWith(";");
            if (semi) body = body.Substring(0, body.Length - 1).TrimEnd();
            // don't double-limit if the statement already carries one
            if (body.ToUpper(CultureInfo.InvariantCulture).IndexOf(" LIMIT ") >= 0) return s;
            return body + " LIMIT " + n + (semi ? ";" : "");
        }
        private static int SkipWs(string s, int i) { while (i < s.Length && char.IsWhiteSpace(s[i])) i++; return i; }
        private static bool IsWordAt(string s, int i, string word)
        {
            if (i < 0 || i + word.Length > s.Length) return false;
            if (string.Compare(s, i, word, 0, word.Length, true, CultureInfo.InvariantCulture) != 0) return false;
            int after = i + word.Length;
            if (after < s.Length && (char.IsLetterOrDigit(s[after]) || s[after] == '_')) return false;
            return true;
        }
        private static string ReplaceCI(string s, string find, string repl)
        {
            int idx = s.ToUpper(CultureInfo.InvariantCulture).IndexOf(find.ToUpper(CultureInfo.InvariantCulture));
            while (idx >= 0) { s = s.Substring(0, idx) + repl + s.Substring(idx + find.Length); idx = s.ToUpper(CultureInfo.InvariantCulture).IndexOf(find.ToUpper(CultureInfo.InvariantCulture), idx + repl.Length); }
            return s;
        }
    }

    // ---- exception surface -------------------------------------------------
    public sealed class GvrError { internal int _n; public int Number { get { return _n; } } }
    public sealed class GvrErrorCollection
    {
        internal ArrayList Items = new ArrayList();
        public GvrError this[int i] { get { return (GvrError)Items[i]; } }
        public int Count { get { return Items.Count; } }
    }
    public sealed class GvrException : Exception
    {
        private GvrErrorCollection _errs = new GvrErrorCollection();
        public GvrException(string msg) : base(msg) { }
        public GvrErrorCollection Errors { get { return _errs; } }
    }

    // ---- info message delegate/args ---------------------------------------
    public sealed class GvrInfoMessageEventArgs : EventArgs { }
    public delegate void GvrInfoMessageEventHandler(object sender, GvrInfoMessageEventArgs e);
}
