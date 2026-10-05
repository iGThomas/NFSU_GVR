// GvrPrivReg - a private, per-game registry for the GlobalVR titles.
//
// Each game's shim calls privreg_attach() from DllMain. From then on every advapi32
// registry call that touches the game's own HKLM\SOFTWARE roots is answered from one
// file in the install folder (<install>\<storeName>), so the game needs no machine-wide
// registry, no administrator rights, and can never collide with another GVR title.
// See GvrPrivReg.cpp for the details.
#pragma once
#include <windows.h>

struct PrivRegDefault {
    const char* section;   // key path below HKLM\SOFTWARE, e.g. "GlobalVR\\NASCAR"
    const char* name;      // value name ("" = the key's default value); NULL = key only
    const char* value;     // text; "dword:xxxxxxxx" for REG_DWORD. "%ROOT%" = the install
                           // folder - such values are computed every time, never stored.
};

struct PrivRegConfig {
    const char*           storeName;     // e.g. "nascar_registry.ini"
    const char* const*    roots;         // keys below HKLM\SOFTWARE that become private,
    int                   nRoots;        //   e.g. "GlobalVR", "gvr"
    const PrivRegDefault* defaults;
    int                   nDefaults;
    bool                  allKeysExist;  // true: any key under a root opens (NASCAR);
                                         // false: only keys in the store / defaults (NFSU)
    bool                  noSeed;        // true: never copy the real registry into a new store
                                         //   (its shared keys hold the other title's values)
};

// installRoot: the game's install folder. log: optional printf-style trace.
void privreg_attach(const char* installRoot, const PrivRegConfig* cfg,
                    void (*log)(const char* fmt, ...));
