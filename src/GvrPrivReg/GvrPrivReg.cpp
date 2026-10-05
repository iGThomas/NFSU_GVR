// ============================================================================
//  GvrPrivReg.cpp  -  a private, per-game registry (shared by the NASCAR and
//                     NFSU shims; see GvrPrivReg.h)
//
//  Every advapi32 registry call that touches one of the game's roots below
//  HKLM\SOFTWARE (either view) is answered from <install>\<storeName>, an ini
//  file: one [section] per key (its path below HKLM\SOFTWARE), values quoted,
//  REG_DWORD as "dword:xxxxxxxx". Nothing machine-wide is read or written for
//  those keys any more, so no administrator rights, nothing to go missing, and
//  two GVR titles can never repoint each other's values.
//
//    * Defaults (from the game's shim) fill in anything absent. Values that
//      contain %ROOT% are computed from the install folder every time and never
//      stored, so a moved or copied install just works. %NOW% = current time.
//    * Writes go to the file, which every process of the game reads on every
//      query (the front end and the race talk through these keys).
//    * First run: the real registry's values under the roots are copied in
//      (never over a value already in the file).
//    * Keys exist when the store or the defaults have them (or a key below
//      them); with allKeysExist any key under a root opens.
//
//  The hook: the advapi32 Reg* exports start with the hot-patch prologue
//  (`mov edi,edi` with 5 bytes of padding before the function), so each one
//  gets a short jump back into a 5-byte `jmp hook` in that padding; the
//  original continues at function+2. Private key handles are odd numbers (real
//  handles never are). GVR_NO_PRIVATE_REGISTRY=1 turns it all off.
// ============================================================================

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "GvrPrivReg.h"

static const PrivRegConfig* g_cfg = NULL;
static char g_root[MAX_PATH];
static char g_store[MAX_PATH];
static void (*g_log)(const char*, ...) = NULL;
static CRITICAL_SECTION g_lock;                   // the scratch buffers below are shared
struct Lock { Lock() { EnterCriticalSection(&g_lock); } ~Lock() { LeaveCriticalSection(&g_lock); } };

#define LOG(...) do { if (g_log) g_log(__VA_ARGS__); } while (0)

static const char kMissing[] = "\x01missing";
static const char kDeleted[] = "<deleted>";
static const char kExists[]  = "__exists__";       // marks a key that has no values yet

// ------------------------------------------------------------------ small helpers
static bool istarts(const char* s, const char* pre)
{
    size_t n = strlen(pre);
    return _strnicmp(s, pre, n) == 0;
}

// "a\b" starts with "a" as a whole key component?
static bool under(const char* path, const char* parent)
{
    size_t n = strlen(parent);
    return _strnicmp(path, parent, n) == 0 && (path[n] == 0 || path[n] == '\\');
}

static void expand(const char* in, char* out, size_t n)
{
    out[0] = 0;
    size_t o = 0;
    for (const char* p = in; *p && o + 1 < n; ) {
        if (istarts(p, "%ROOT%")) {
            size_t L = strlen(g_root);
            if (o + L >= n) break;
            memcpy(out + o, g_root, L); o += L; p += 6;
        } else if (istarts(p, "%NOW%")) {
            SYSTEMTIME st; GetLocalTime(&st);
            char t[32];
            _snprintf(t, sizeof t, "%04d-%02d-%02d %02d:%02d:%02d", st.wYear, st.wMonth, st.wDay,
                      st.wHour, st.wMinute, st.wSecond);
            t[sizeof t - 1] = 0;
            size_t L = strlen(t);
            if (o + L >= n) break;
            memcpy(out + o, t, L); o += L; p += 5;
        } else out[o++] = *p++;
    }
    out[o] = 0;
}

static const PrivRegDefault* find_default(const char* section, const char* name)
{
    for (int i = 0; i < g_cfg->nDefaults; i++) {
        const PrivRegDefault& d = g_cfg->defaults[i];
        if (d.name && _stricmp(d.section, section) == 0 && _stricmp(d.name, name) == 0) return &d;
    }
    return NULL;
}

static void store_name(const char* name, char* out, size_t n)
{
    lstrcpynA(out, (name && *name) ? name : "@", (int)n);   // "@" = the key's default value
}

// ------------------------------------------------------------------ values
static bool value_get(const char* section, const char* rawName, char* out, size_t n)
{
    char name[256];
    store_name(rawName, name, sizeof name);
    const PrivRegDefault* d = find_default(section, name);
    if (d && strstr(d->value, "%ROOT%")) { expand(d->value, out, n); return true; }   // computed
    GetPrivateProfileStringA(section, name, kMissing, out, (DWORD)n, g_store);
    if (strcmp(out, kDeleted) == 0) return false;
    if (strcmp(out, kMissing) != 0) return _stricmp(name, kExists) != 0;
    if (d) { expand(d->value, out, n); return true; }
    return false;
}

static void value_put(const char* section, const char* rawName, const char* text)
{
    char name[256], q[2100];
    store_name(rawName, name, sizeof name);
    _snprintf(q, sizeof q, "\"%s\"", text);   // quoted: leading/trailing spaces survive
    q[sizeof q - 1] = 0;
    WritePrivateProfileStringA(section, name, q, g_store);
}

// ------------------------------------------------------------------ keys
// All section names of the store (double-NUL list) into buf.
static void store_sections(char* buf, DWORD n)
{
    buf[0] = buf[1] = 0;
    GetPrivateProfileSectionNamesA(buf, n, g_store);
}

static bool key_exists(const char* section)
{
    if (g_cfg->allKeysExist) return true;
    static char names[32768];
    store_sections(names, sizeof names);
    for (const char* s = names; *s; s += strlen(s) + 1)
        if (under(s, section)) return true;
    for (int i = 0; i < g_cfg->nDefaults; i++)
        if (under(g_cfg->defaults[i].section, section)) return true;
    return false;
}

static void key_create(const char* section)
{
    if (key_exists(section)) return;
    WritePrivateProfileStringA(section, kExists, "\"1\"", g_store);
}

// Immediate subkey names of `section` (from the store and the defaults), sorted.
static void add_child(const char* full, const char* section, size_t L, char names[][128], int* count, int max)
{
    if (strlen(full) <= L + 1 || _strnicmp(full, section, L) != 0 || full[L] != '\\') return;
    char child[128];
    lstrcpynA(child, full + L + 1, sizeof child);
    char* bs = strchr(child, '\\');
    if (bs) *bs = 0;
    for (int k = 0; k < *count; k++) if (_stricmp(names[k], child) == 0) return;
    if (*count < max) lstrcpynA(names[(*count)++], child, 128);
}

static int subkeys(const char* section, char names[][128], int max)
{
    int count = 0;
    size_t L = strlen(section);
    static char sec[32768];
    store_sections(sec, sizeof sec);
    for (const char* s = sec; *s; s += strlen(s) + 1) add_child(s, section, L, names, &count, max);
    for (int i = 0; i < g_cfg->nDefaults; i++) add_child(g_cfg->defaults[i].section, section, L, names, &count, max);
    for (int a = 0; a < count; a++)                     // the registry enumerates sorted
        for (int b = a + 1; b < count; b++)
            if (_stricmp(names[b], names[a]) < 0) {
                char tmp[128];
                lstrcpynA(tmp, names[a], 128); lstrcpynA(names[a], names[b], 128); lstrcpynA(names[b], tmp, 128);
            }
    return count;
}

// Value names of `section`: the store's, then defaults not in the store. "" = default value.
static int valuenames(const char* section, char names[][128], int max)
{
    int count = 0;
    static char lines[32768];
    lines[0] = lines[1] = 0;
    GetPrivateProfileSectionA(section, lines, sizeof lines, g_store);
    for (const char* l = lines; *l; l += strlen(l) + 1) {
        const char* eq = strchr(l, '=');
        if (!eq) continue;
        char nm[128];
        size_t k = (size_t)(eq - l) < sizeof nm - 1 ? (size_t)(eq - l) : sizeof nm - 1;
        memcpy(nm, l, k); nm[k] = 0;
        if (_stricmp(nm, kExists) == 0 || strstr(eq + 1, kDeleted)) continue;
        if (count < max) lstrcpynA(names[count++], strcmp(nm, "@") == 0 ? "" : nm, 128);
    }
    for (int i = 0; i < g_cfg->nDefaults; i++) {
        const PrivRegDefault& d = g_cfg->defaults[i];
        if (!d.name || _stricmp(d.section, section) != 0) continue;
        char probe[64];
        GetPrivateProfileStringA(section, *d.name ? d.name : "@", kMissing, probe, sizeof probe, g_store);
        if (strcmp(probe, kMissing) != 0) continue;        // listed above (or deleted)
        if (count < max) lstrcpynA(names[count++], d.name, 128);
    }
    return count;
}

// ------------------------------------------------------------------ private handles
struct VKey { DWORD magic; char section[200]; };
static const DWORD kVKeyMagic = 0x47565252;   // 'GVRR'

static HKEY vkey_new(const char* section)
{
    VKey* v = (VKey*)HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, sizeof(VKey));
    if (!v) return NULL;
    v->magic = kVKeyMagic;
    lstrcpynA(v->section, section, sizeof v->section);
    return (HKEY)((ULONG_PTR)v | 1);
}

static VKey* vkey_of(HKEY h)
{
    ULONG_PTR p = (ULONG_PTR)h;
    if (!(p & 1) || (p & 0x80000000u)) return NULL;       // real handle or predefined root
    VKey* v = (VKey*)(p & ~(ULONG_PTR)1);
    __try { if (v->magic == kVKeyMagic) return v; } __except (EXCEPTION_EXECUTE_HANDLER) {}
    return NULL;
}

// ------------------------------------------------------------------ originals
typedef LONG (WINAPI *PFN_OpenExA)(HKEY, LPCSTR, DWORD, REGSAM, PHKEY);
typedef LONG (WINAPI *PFN_OpenExW)(HKEY, LPCWSTR, DWORD, REGSAM, PHKEY);
typedef LONG (WINAPI *PFN_OpenA)(HKEY, LPCSTR, PHKEY);
typedef LONG (WINAPI *PFN_OpenW)(HKEY, LPCWSTR, PHKEY);
typedef LONG (WINAPI *PFN_CreateExA)(HKEY, LPCSTR, DWORD, LPSTR, DWORD, REGSAM, LPSECURITY_ATTRIBUTES, PHKEY, LPDWORD);
typedef LONG (WINAPI *PFN_CreateExW)(HKEY, LPCWSTR, DWORD, LPWSTR, DWORD, REGSAM, LPSECURITY_ATTRIBUTES, PHKEY, LPDWORD);
typedef LONG (WINAPI *PFN_CreateA)(HKEY, LPCSTR, PHKEY);
typedef LONG (WINAPI *PFN_CreateW)(HKEY, LPCWSTR, PHKEY);
typedef LONG (WINAPI *PFN_QueryExA)(HKEY, LPCSTR, LPDWORD, LPDWORD, LPBYTE, LPDWORD);
typedef LONG (WINAPI *PFN_QueryExW)(HKEY, LPCWSTR, LPDWORD, LPDWORD, LPBYTE, LPDWORD);
typedef LONG (WINAPI *PFN_SetExA)(HKEY, LPCSTR, DWORD, DWORD, const BYTE*, DWORD);
typedef LONG (WINAPI *PFN_SetExW)(HKEY, LPCWSTR, DWORD, DWORD, const BYTE*, DWORD);
typedef LONG (WINAPI *PFN_DelA)(HKEY, LPCSTR);
typedef LONG (WINAPI *PFN_DelW)(HKEY, LPCWSTR);
typedef LONG (WINAPI *PFN_Close)(HKEY);
typedef LONG (WINAPI *PFN_InfoA)(HKEY, LPSTR, LPDWORD, LPDWORD, LPDWORD, LPDWORD, LPDWORD, LPDWORD, LPDWORD, LPDWORD, LPDWORD, PFILETIME);
typedef LONG (WINAPI *PFN_InfoW)(HKEY, LPWSTR, LPDWORD, LPDWORD, LPDWORD, LPDWORD, LPDWORD, LPDWORD, LPDWORD, LPDWORD, LPDWORD, PFILETIME);
typedef LONG (WINAPI *PFN_EnumValA)(HKEY, DWORD, LPSTR, LPDWORD, LPDWORD, LPDWORD, LPBYTE, LPDWORD);
typedef LONG (WINAPI *PFN_EnumValW)(HKEY, DWORD, LPWSTR, LPDWORD, LPDWORD, LPDWORD, LPBYTE, LPDWORD);
typedef LONG (WINAPI *PFN_EnumKeyExA)(HKEY, DWORD, LPSTR, LPDWORD, LPDWORD, LPSTR, LPDWORD, PFILETIME);
typedef LONG (WINAPI *PFN_EnumKeyExW)(HKEY, DWORD, LPWSTR, LPDWORD, LPDWORD, LPWSTR, LPDWORD, PFILETIME);
typedef LONG (WINAPI *PFN_EnumKeyA)(HKEY, DWORD, LPSTR, DWORD);
typedef LONG (WINAPI *PFN_EnumKeyW)(HKEY, DWORD, LPWSTR, DWORD);

static PFN_OpenExA  oOpenExA;  static PFN_OpenExW  oOpenExW;
static PFN_OpenA    oOpenA;    static PFN_OpenW    oOpenW;
static PFN_CreateExA oCreateExA; static PFN_CreateExW oCreateExW;
static PFN_CreateA  oCreateA;  static PFN_CreateW  oCreateW;
static PFN_QueryExA oQueryExA; static PFN_QueryExW oQueryExW;
static PFN_SetExA   oSetExA;   static PFN_SetExW   oSetExW;
static PFN_DelA     oDelA;     static PFN_DelW     oDelW;
static PFN_Close    oClose;
static PFN_InfoA    oInfoA;    static PFN_InfoW    oInfoW;
static PFN_EnumValA oEnumValA; static PFN_EnumValW oEnumValW;
static PFN_EnumKeyExA oEnumKeyExA; static PFN_EnumKeyExW oEnumKeyExW;
static PFN_EnumKeyA oEnumKeyA; static PFN_EnumKeyW oEnumKeyW;

// ------------------------------------------------------------------ path resolution
typedef LONG (NTAPI *PFN_NtQueryKey)(HANDLE, int, PVOID, ULONG, PULONG);

static void normalise(char* p)                 // drop "\wow6432node", "/" -> "\", no trailing "\"
{
    for (char* c = p; *c; c++) if (*c == '/') *c = '\\';
    char* w;
    while ((w = (char*)strstr(p, "\\WOW6432Node")) != NULL || (w = (char*)strstr(p, "\\wow6432node")) != NULL ||
           (w = (char*)strstr(p, "\\Wow6432Node")) != NULL)
        memmove(w, w + 12, strlen(w + 12) + 1);
    size_t L = strlen(p);
    while (L && p[L - 1] == '\\') p[--L] = 0;
}

// Path of a key as "HKLM\SOFTWARE\..." (original spelling); false if not under HKLM.
static bool key_path(HKEY h, char* out, size_t n)
{
    out[0] = 0;
    if (VKey* v = vkey_of(h)) { _snprintf(out, n, "HKLM\\SOFTWARE\\%s", v->section); out[n - 1] = 0; return true; }
    if (h == HKEY_LOCAL_MACHINE) { lstrcpynA(out, "HKLM", (int)n); return true; }
    if ((ULONG_PTR)h & 0x80000000u) return false;          // other predefined roots
    static PFN_NtQueryKey q = (PFN_NtQueryKey)GetProcAddress(GetModuleHandleA("ntdll.dll"), "NtQueryKey");
    if (!q) return false;
    BYTE buf[1024]; ULONG got = 0;
    if (q((HANDLE)h, 3 /*KeyNameInformation*/, buf, sizeof buf, &got) < 0) return false;
    ULONG len = *(ULONG*)buf / 2;
    char a[600];
    int m = WideCharToMultiByte(CP_ACP, 0, (const WCHAR*)(buf + 4), (int)len, a, sizeof a - 1, NULL, NULL);
    a[m] = 0;
    normalise(a);
    const char* pre = "\\REGISTRY\\MACHINE";
    if (_strnicmp(a, pre, strlen(pre)) != 0) return false;
    _snprintf(out, n, "HKLM%s", a + strlen(pre));
    out[n - 1] = 0;
    return true;
}

// If parent\sub lies under one of the game's roots: true + the section (path below SOFTWARE).
static bool private_section(HKEY parent, const char* sub, char* section, size_t n)
{
    char path[700], full[900];
    if (!key_path(parent, path, sizeof path)) return false;
    if (sub && *sub) _snprintf(full, sizeof full, "%s\\%s", path, sub);
    else             lstrcpynA(full, path, sizeof full);
    full[sizeof full - 1] = 0;
    normalise(full);
    const char* pre = "HKLM\\SOFTWARE\\";
    if (_strnicmp(full, pre, strlen(pre)) != 0) return false;
    const char* rel = full + strlen(pre);
    for (int i = 0; i < g_cfg->nRoots; i++)
        if (under(rel, g_cfg->roots[i])) {
            // use the defaults' spelling when the key is a known one (readable store)
            for (int d = 0; d < g_cfg->nDefaults; d++)
                if (_stricmp(g_cfg->defaults[d].section, rel) == 0) { lstrcpynA(section, g_cfg->defaults[d].section, (int)n); return true; }
            lstrcpynA(section, rel, (int)n);
            return true;
        }
    return false;
}

static void w2a(LPCWSTR w, char* a, size_t n)
{
    a[0] = 0;
    if (w) { WideCharToMultiByte(CP_ACP, 0, w, -1, a, (int)n, NULL, NULL); a[n - 1] = 0; }
}

// ------------------------------------------------------------------ hooks: keys
// handled=false: not ours, call the original. create=true: make the key if missing.
static LONG open_private(HKEY parent, const char* sub, PHKEY out, bool create, bool* handled, LPDWORD disp)
{
    Lock lock;
    char sec[200];
    *handled = false;
    if (!out || !private_section(parent, sub, sec, sizeof sec)) return 0;
    *handled = true;
    bool existed = key_exists(sec);
    if (!existed && !create) return ERROR_FILE_NOT_FOUND;
    if (!existed) key_create(sec);
    if (disp) *disp = existed ? REG_OPENED_EXISTING_KEY : REG_CREATED_NEW_KEY;
    *out = vkey_new(sec);
    return *out ? ERROR_SUCCESS : ERROR_NOT_ENOUGH_MEMORY;
}

static LONG WINAPI hOpenExA(HKEY h, LPCSTR s, DWORD o, REGSAM sam, PHKEY r)
{ bool d; LONG e = open_private(h, s, r, false, &d, NULL); return d ? e : oOpenExA(h, s, o, sam, r); }
static LONG WINAPI hOpenExW(HKEY h, LPCWSTR s, DWORD o, REGSAM sam, PHKEY r)
{ char a[600]; w2a(s, a, sizeof a); bool d; LONG e = open_private(h, a, r, false, &d, NULL); return d ? e : oOpenExW(h, s, o, sam, r); }
static LONG WINAPI hOpenA(HKEY h, LPCSTR s, PHKEY r)
{ bool d; LONG e = open_private(h, s, r, false, &d, NULL); return d ? e : oOpenA(h, s, r); }
static LONG WINAPI hOpenW(HKEY h, LPCWSTR s, PHKEY r)
{ char a[600]; w2a(s, a, sizeof a); bool d; LONG e = open_private(h, a, r, false, &d, NULL); return d ? e : oOpenW(h, s, r); }
static LONG WINAPI hCreateExA(HKEY h, LPCSTR s, DWORD res, LPSTR c, DWORD o, REGSAM sam, LPSECURITY_ATTRIBUTES sa, PHKEY r, LPDWORD disp)
{ bool d; LONG e = open_private(h, s, r, true, &d, disp); return d ? e : oCreateExA(h, s, res, c, o, sam, sa, r, disp); }
static LONG WINAPI hCreateExW(HKEY h, LPCWSTR s, DWORD res, LPWSTR c, DWORD o, REGSAM sam, LPSECURITY_ATTRIBUTES sa, PHKEY r, LPDWORD disp)
{ char a[600]; w2a(s, a, sizeof a); bool d; LONG e = open_private(h, a, r, true, &d, disp); return d ? e : oCreateExW(h, s, res, c, o, sam, sa, r, disp); }
static LONG WINAPI hCreateA(HKEY h, LPCSTR s, PHKEY r)
{ bool d; LONG e = open_private(h, s, r, true, &d, NULL); return d ? e : oCreateA(h, s, r); }
static LONG WINAPI hCreateW(HKEY h, LPCWSTR s, PHKEY r)
{ char a[600]; w2a(s, a, sizeof a); bool d; LONG e = open_private(h, a, r, true, &d, NULL); return d ? e : oCreateW(h, s, r); }

static LONG WINAPI hClose(HKEY h)
{
    VKey* v = vkey_of(h);
    if (!v) return oClose(h);
    v->magic = 0;
    HeapFree(GetProcessHeap(), 0, v);
    return ERROR_SUCCESS;
}

// ------------------------------------------------------------------ hooks: values
// Value text -> (type, bytes); wide = UTF-16 string data for the W functions.
static LONG answer(const char* text, bool wide, LPDWORD type, LPBYTE data, LPDWORD cb)
{
    DWORD t = REG_SZ, need;
    BYTE tmp[4200];
    if (strncmp(text, "dword:", 6) == 0) {
        t = REG_DWORD;
        DWORD v = strtoul(text + 6, NULL, 16);
        memcpy(tmp, &v, 4); need = 4;
    } else if (wide) {
        int m = MultiByteToWideChar(CP_ACP, 0, text, -1, (LPWSTR)tmp, (int)(sizeof tmp / 2));
        need = (DWORD)m * 2;
    } else {
        need = (DWORD)strlen(text) + 1;
        if (need > sizeof tmp) need = sizeof tmp;
        memcpy(tmp, text, need);
    }
    if (type) *type = t;
    if (!cb) return data ? ERROR_INVALID_PARAMETER : ERROR_SUCCESS;
    if (!data) { *cb = need; return ERROR_SUCCESS; }
    if (*cb < need) { *cb = need; return ERROR_MORE_DATA; }
    memcpy(data, tmp, need);
    *cb = need;
    return ERROR_SUCCESS;
}

static LONG WINAPI hQueryExA(HKEY h, LPCSTR n, LPDWORD r, LPDWORD t, LPBYTE d, LPDWORD cb)
{
    VKey* v = vkey_of(h);
    if (!v) return oQueryExA(h, n, r, t, d, cb);
    char text[2100];
    if (!value_get(v->section, n, text, sizeof text)) return ERROR_FILE_NOT_FOUND;
    return answer(text, false, t, d, cb);
}
static LONG WINAPI hQueryExW(HKEY h, LPCWSTR n, LPDWORD r, LPDWORD t, LPBYTE d, LPDWORD cb)
{
    VKey* v = vkey_of(h);
    if (!v) return oQueryExW(h, n, r, t, d, cb);
    char name[300], text[2100];
    w2a(n, name, sizeof name);
    if (!value_get(v->section, name, text, sizeof text)) return ERROR_FILE_NOT_FOUND;
    return answer(text, true, t, d, cb);
}

static void put_value(VKey* v, const char* name, DWORD type, const BYTE* d, DWORD cb, bool wide)
{
    char text[2100] = { 0 };
    if (type == REG_DWORD && d && cb >= 4) _snprintf(text, sizeof text, "dword:%08lx", *(const DWORD*)d);
    else if (d && cb) {
        if (wide) WideCharToMultiByte(CP_ACP, 0, (LPCWSTR)d, (int)(cb / 2), text, sizeof text - 1, NULL, NULL);
        else      memcpy(text, d, cb < sizeof text - 1 ? cb : sizeof text - 1);
    }
    text[sizeof text - 1] = 0;
    value_put(v->section, name, text);
}
static LONG WINAPI hSetExA(HKEY h, LPCSTR n, DWORD r, DWORD t, const BYTE* d, DWORD cb)
{
    VKey* v = vkey_of(h);
    if (!v) return oSetExA(h, n, r, t, d, cb);
    put_value(v, n, t, d, cb, false);
    return ERROR_SUCCESS;
}
static LONG WINAPI hSetExW(HKEY h, LPCWSTR n, DWORD r, DWORD t, const BYTE* d, DWORD cb)
{
    VKey* v = vkey_of(h);
    if (!v) return oSetExW(h, n, r, t, d, cb);
    char name[300]; w2a(n, name, sizeof name);
    put_value(v, name, t, d, cb, true);
    return ERROR_SUCCESS;
}
static LONG delete_value(VKey* v, const char* raw)
{
    char text[64];
    if (!value_get(v->section, raw, text, sizeof text)) return ERROR_FILE_NOT_FOUND;
    char nm[256]; store_name(raw, nm, sizeof nm);
    if (find_default(v->section, nm)) WritePrivateProfileStringA(v->section, nm, kDeleted, g_store);
    else                              WritePrivateProfileStringA(v->section, nm, NULL, g_store);
    return ERROR_SUCCESS;
}
static LONG WINAPI hDelA(HKEY h, LPCSTR n)
{ VKey* v = vkey_of(h); return v ? delete_value(v, n) : oDelA(h, n); }
static LONG WINAPI hDelW(HKEY h, LPCWSTR n)
{ VKey* v = vkey_of(h); if (!v) return oDelW(h, n); char a[300]; w2a(n, a, sizeof a); return delete_value(v, a); }

// ------------------------------------------------------------------ hooks: enumeration
static char g_tmpNames[512][128];

static LONG info(VKey* v, LPDWORD cc, LPDWORD sk, LPDWORD msk, LPDWORD mc, LPDWORD nv, LPDWORD mvn, LPDWORD mvd,
                 LPDWORD sd, PFILETIME ft, bool wide)
{
    Lock lock;
    int nk = subkeys(v->section, g_tmpNames, 512);
    DWORD maxk = 0;
    for (int i = 0; i < nk; i++) if (strlen(g_tmpNames[i]) > maxk) maxk = (DWORD)strlen(g_tmpNames[i]);
    int nvv = valuenames(v->section, g_tmpNames, 512);
    DWORD maxn = 0, maxd = 0;
    for (int i = 0; i < nvv; i++) {
        if (strlen(g_tmpNames[i]) > maxn) maxn = (DWORD)strlen(g_tmpNames[i]);
        char text[2100];
        if (value_get(v->section, g_tmpNames[i], text, sizeof text)) {
            DWORD d = (DWORD)(strlen(text) + 1) * (wide ? 2 : 1);
            if (d > maxd) maxd = d;
        }
    }
    if (cc) *cc = 0;
    if (sk) *sk = (DWORD)nk;
    if (msk) *msk = maxk;
    if (mc) *mc = 0;
    if (nv) *nv = (DWORD)nvv;
    if (mvn) *mvn = maxn;
    if (mvd) *mvd = maxd < 4 ? 4 : maxd;
    if (sd) *sd = 0;
    if (ft) GetSystemTimeAsFileTime(ft);
    return ERROR_SUCCESS;
}
static LONG WINAPI hInfoA(HKEY h, LPSTR c, LPDWORD cc, LPDWORD r, LPDWORD sk, LPDWORD msk, LPDWORD mc, LPDWORD nv, LPDWORD mvn, LPDWORD mvd, LPDWORD sd, PFILETIME ft)
{
    VKey* v = vkey_of(h);
    if (!v) return oInfoA(h, c, cc, r, sk, msk, mc, nv, mvn, mvd, sd, ft);
    if (c && cc && *cc) *c = 0;
    return info(v, cc, sk, msk, mc, nv, mvn, mvd, sd, ft, false);
}
static LONG WINAPI hInfoW(HKEY h, LPWSTR c, LPDWORD cc, LPDWORD r, LPDWORD sk, LPDWORD msk, LPDWORD mc, LPDWORD nv, LPDWORD mvn, LPDWORD mvd, LPDWORD sd, PFILETIME ft)
{
    VKey* v = vkey_of(h);
    if (!v) return oInfoW(h, c, cc, r, sk, msk, mc, nv, mvn, mvd, sd, ft);
    if (c && cc && *cc) *c = 0;
    return info(v, cc, sk, msk, mc, nv, mvn, mvd, sd, ft, true);
}

// copy a name out: cch in characters, excluding the NUL on success
static LONG name_out(const char* s, void* out, LPDWORD cch, bool wide)
{
    DWORD len = (DWORD)strlen(s);
    if (!out || !cch) return ERROR_INVALID_PARAMETER;
    if (*cch <= len) { *cch = len + 1; return ERROR_MORE_DATA; }
    if (wide) MultiByteToWideChar(CP_ACP, 0, s, -1, (LPWSTR)out, (int)*cch);
    else      lstrcpynA((char*)out, s, (int)*cch);
    *cch = len;
    return ERROR_SUCCESS;
}

static LONG enum_key(VKey* v, DWORD i, void* name, LPDWORD cch, bool wide)
{
    Lock lock;
    int n = subkeys(v->section, g_tmpNames, 512);
    if ((int)i >= n) return ERROR_NO_MORE_ITEMS;
    return name_out(g_tmpNames[i], name, cch, wide);
}
static LONG WINAPI hEnumKeyExA(HKEY h, DWORD i, LPSTR n, LPDWORD nc, LPDWORD r, LPSTR c, LPDWORD cc, PFILETIME ft)
{
    VKey* v = vkey_of(h);
    if (!v) return oEnumKeyExA(h, i, n, nc, r, c, cc, ft);
    if (cc) *cc = 0;
    if (ft) GetSystemTimeAsFileTime(ft);
    return enum_key(v, i, n, nc, false);
}
static LONG WINAPI hEnumKeyExW(HKEY h, DWORD i, LPWSTR n, LPDWORD nc, LPDWORD r, LPWSTR c, LPDWORD cc, PFILETIME ft)
{
    VKey* v = vkey_of(h);
    if (!v) return oEnumKeyExW(h, i, n, nc, r, c, cc, ft);
    if (cc) *cc = 0;
    if (ft) GetSystemTimeAsFileTime(ft);
    return enum_key(v, i, n, nc, true);
}
static LONG WINAPI hEnumKeyA(HKEY h, DWORD i, LPSTR n, DWORD cch)
{ VKey* v = vkey_of(h); if (!v) return oEnumKeyA(h, i, n, cch); DWORD c = cch; return enum_key(v, i, n, &c, false); }
static LONG WINAPI hEnumKeyW(HKEY h, DWORD i, LPWSTR n, DWORD cch)
{ VKey* v = vkey_of(h); if (!v) return oEnumKeyW(h, i, n, cch); DWORD c = cch; return enum_key(v, i, n, &c, true); }

static LONG enum_value(VKey* v, DWORD i, void* name, LPDWORD cch, LPDWORD type, LPBYTE data, LPDWORD cb, bool wide)
{
    Lock lock;
    int n = valuenames(v->section, g_tmpNames, 512);
    if ((int)i >= n) return ERROR_NO_MORE_ITEMS;
    char nm[128]; lstrcpynA(nm, g_tmpNames[i], sizeof nm);
    LONG r = name_out(nm, name, cch, wide);
    if (r != ERROR_SUCCESS) return r;
    char text[2100];
    if (!value_get(v->section, nm, text, sizeof text)) text[0] = 0;
    if (!data && !cb) { if (type) *type = strncmp(text, "dword:", 6) == 0 ? REG_DWORD : REG_SZ; return ERROR_SUCCESS; }
    return answer(text, wide, type, data, cb);
}
static LONG WINAPI hEnumValA(HKEY h, DWORD i, LPSTR n, LPDWORD nc, LPDWORD r, LPDWORD t, LPBYTE d, LPDWORD cb)
{ VKey* v = vkey_of(h); return v ? enum_value(v, i, n, nc, t, d, cb, false) : oEnumValA(h, i, n, nc, r, t, d, cb); }
static LONG WINAPI hEnumValW(HKEY h, DWORD i, LPWSTR n, LPDWORD nc, LPDWORD r, LPDWORD t, LPBYTE d, LPDWORD cb)
{ VKey* v = vkey_of(h); return v ? enum_value(v, i, n, nc, t, d, cb, true) : oEnumValW(h, i, n, nc, r, t, d, cb); }

// ------------------------------------------------------------------ hot-patching
static bool hotpatch(HMODULE mod, const char* name, void* hook, void** orig)
{
    BYTE* f = (BYTE*)GetProcAddress(mod, name);
    if (!f) { LOG("registry: %s not exported", name); return false; }
    static const BYTE padCC[5] = { 0xCC, 0xCC, 0xCC, 0xCC, 0xCC };
    static const BYTE pad90[5] = { 0x90, 0x90, 0x90, 0x90, 0x90 };
    if (f[0] != 0x8B || f[1] != 0xFF || (memcmp(f - 5, padCC, 5) != 0 && memcmp(f - 5, pad90, 5) != 0)) {
        LOG("registry: %s has no hot-patch prologue - not hooked", name);
        return false;
    }
    DWORD old;
    if (!VirtualProtect(f - 5, 7, PAGE_EXECUTE_READWRITE, &old)) return false;
    *orig = f + 2;                                         // continue after `mov edi,edi`
    f[-5] = 0xE9;
    *(DWORD*)(f - 4) = (DWORD)((BYTE*)hook - f);           // jmp hook (5 bytes at f-5)
    *(WORD*)f = 0xF9EB;                                    // jmp short -7, written last
    VirtualProtect(f - 5, 7, old, &old);
    FlushInstructionCache(GetCurrentProcess(), f - 5, 7);
    return true;
}

// ------------------------------------------------------------------ first-run seeding
static int seed_key(const char* rel)
{
    char path[400];
    _snprintf(path, sizeof path, "SOFTWARE\\%s", rel);
    path[sizeof path - 1] = 0;
    HKEY h;
    if (oOpenExA(HKEY_LOCAL_MACHINE, path, 0, KEY_READ, &h) != ERROR_SUCCESS) return 0;
    int copied = 0, values = 0;
    for (DWORD i = 0;; i++) {
        char name[256]; BYTE data[2048];
        DWORD nl = sizeof name, dl = sizeof data - 2, type = 0;
        LONG r = oEnumValA(h, i, name, &nl, NULL, &type, data, &dl);
        if (r == ERROR_NO_MORE_ITEMS) break;
        if (r != ERROR_SUCCESS) continue;
        values++;
        char text[2100] = { 0 };
        if (type == REG_DWORD && dl >= 4) _snprintf(text, sizeof text, "dword:%08lx", *(DWORD*)data);
        else if (type == REG_SZ || type == REG_EXPAND_SZ) { data[dl] = 0; lstrcpynA(text, (char*)data, sizeof text); }
        else continue;
        char nm[256]; store_name(name, nm, sizeof nm);
        char have[16];
        GetPrivateProfileStringA(rel, nm, kMissing, have, sizeof have, g_store);
        if (strcmp(have, kMissing) != 0) continue;     // never over what the store already has
        value_put(rel, name, text);
        copied++;
    }
    if (!values) WritePrivateProfileStringA(rel, kExists, "\"1\"", g_store);  // keep empty keys
    for (DWORD i = 0;; i++) {
        char sub[256]; DWORD sl = sizeof sub;
        LONG r = oEnumKeyExA(h, i, sub, &sl, NULL, NULL, NULL, NULL);
        if (r == ERROR_NO_MORE_ITEMS) break;
        if (r != ERROR_SUCCESS) continue;
        char child[400];
        _snprintf(child, sizeof child, "%s\\%s", rel, sub);
        child[sizeof child - 1] = 0;
        copied += seed_key(child);
    }
    oClose(h);
    return copied;
}

// ------------------------------------------------------------------ public
void privreg_attach(const char* installRoot, const PrivRegConfig* cfg, void (*log)(const char*, ...))
{
    g_log = log;
    if (GetEnvironmentVariableA("GVR_NO_PRIVATE_REGISTRY", NULL, 0) > 0 ||
        GetEnvironmentVariableA("GVRIOSHIM_NO_PRIVATE_REGISTRY", NULL, 0) > 0) return;
    if (!installRoot || !*installRoot || !cfg) return;
    g_cfg = cfg;
    InitializeCriticalSection(&g_lock);
    lstrcpynA(g_root, installRoot, sizeof g_root);
    size_t L = strlen(g_root);
    while (L && g_root[L - 1] == '\\') g_root[--L] = 0;
    _snprintf(g_store, sizeof g_store, "%s\\%s", g_root, cfg->storeName);
    g_store[sizeof g_store - 1] = 0;

    HMODULE adv = GetModuleHandleA("advapi32.dll");
    if (!adv) { LOG("registry: advapi32 not loaded - private registry OFF"); return; }
    struct { const char* n; void* h; void** o; bool core; } H[] = {
        { "RegOpenKeyExA", (void*)hOpenExA, (void**)&oOpenExA, true }, { "RegOpenKeyExW", (void*)hOpenExW, (void**)&oOpenExW, true },
        { "RegOpenKeyA", (void*)hOpenA, (void**)&oOpenA, true },       { "RegOpenKeyW", (void*)hOpenW, (void**)&oOpenW, true },
        { "RegCreateKeyExA", (void*)hCreateExA, (void**)&oCreateExA, true }, { "RegCreateKeyExW", (void*)hCreateExW, (void**)&oCreateExW, true },
        { "RegCreateKeyA", (void*)hCreateA, (void**)&oCreateA, true }, { "RegCreateKeyW", (void*)hCreateW, (void**)&oCreateW, true },
        { "RegQueryValueExA", (void*)hQueryExA, (void**)&oQueryExA, true }, { "RegQueryValueExW", (void*)hQueryExW, (void**)&oQueryExW, true },
        { "RegSetValueExA", (void*)hSetExA, (void**)&oSetExA, true },  { "RegSetValueExW", (void*)hSetExW, (void**)&oSetExW, true },
        { "RegDeleteValueA", (void*)hDelA, (void**)&oDelA, true },     { "RegDeleteValueW", (void*)hDelW, (void**)&oDelW, true },
        { "RegCloseKey", (void*)hClose, (void**)&oClose, true },
        { "RegQueryInfoKeyA", (void*)hInfoA, (void**)&oInfoA, true },  { "RegQueryInfoKeyW", (void*)hInfoW, (void**)&oInfoW, true },
        { "RegEnumValueA", (void*)hEnumValA, (void**)&oEnumValA, true }, { "RegEnumValueW", (void*)hEnumValW, (void**)&oEnumValW, true },
        { "RegEnumKeyExA", (void*)hEnumKeyExA, (void**)&oEnumKeyExA, true }, { "RegEnumKeyExW", (void*)hEnumKeyExW, (void**)&oEnumKeyExW, true },
        { "RegEnumKeyA", (void*)hEnumKeyA, (void**)&oEnumKeyA, false }, { "RegEnumKeyW", (void*)hEnumKeyW, (void**)&oEnumKeyW, false },
    };
    const int nH = (int)(sizeof(H) / sizeof(H[0]));
    // all-or-nothing for the core set: a half-hooked registry would be worse than none
    for (int i = 0; i < nH; i++) {
        if (!H[i].core) continue;
        BYTE* f = (BYTE*)GetProcAddress(adv, H[i].n);
        if (!f || f[0] != 0x8B || f[1] != 0xFF) { LOG("registry: %s not hookable - private registry OFF", H[i].n); return; }
    }
    // seed with the real functions, before hooking
    oOpenExA = (PFN_OpenExA)GetProcAddress(adv, "RegOpenKeyExA");
    oEnumValA = (PFN_EnumValA)GetProcAddress(adv, "RegEnumValueA");
    oEnumKeyExA = (PFN_EnumKeyExA)GetProcAddress(adv, "RegEnumKeyExA");
    oClose = (PFN_Close)GetProcAddress(adv, "RegCloseKey");
    char seeded[8];
    GetPrivateProfileStringA("Store", "Seeded", "", seeded, sizeof seeded, g_store);
    if (!seeded[0] && cfg->noSeed) {
        WritePrivateProfileStringA("Store", "Seeded", "\"defaults only\"", g_store);
        LOG("registry: new private registry %s, built-in defaults only", g_store);
    } else if (!seeded[0]) {
        int copied = 0;
        for (int i = 0; i < cfg->nRoots; i++) copied += seed_key(cfg->roots[i]);
        WritePrivateProfileStringA("Store", "Seeded", "\"real registry\"", g_store);
        LOG("registry: new private registry %s, %d value(s) copied from the real registry", g_store, copied);
    }

    int n = 0;
    for (int i = 0; i < nH; i++) if (hotpatch(adv, H[i].n, H[i].h, H[i].o)) n++;
    LOG("registry: private registry active (%d hooks) - %s", n, g_store);
}
