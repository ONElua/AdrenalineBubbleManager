# AdrBubbleBooter v1.3 direct IFTU patch

`adrbubblebooter-v1.3-direct-iftu.patch` applies the direct Sharp Bilinear
Simple path to the archived AdrBubbleBooter VPK Edition v1.3 source while
retaining its per-bubble configuration, loader, menu, and embedded PSP boot
files.

It also carries forward the latest Adrenaline Bubble Manager fork's binary
menu-label fix: the booter driver entries are ordered `NP9660`, `INFERNO`,
`MARCH33`, matching the values stored in `boot.bin`. This is the exact
three-pointer change found in the fork's patched `adrenaline_user.suprx` at
commit `874d600`; the closed-source `adrbubblebooter.suprx` is not replaced.

The preserved source archive is available from:

https://github.com/theheroGAC/AdrBubbleBooter.VPKEdition

Extract `src.rar`, enter its `adrenaline` directory, and apply the patch with
Git's whitespace tolerance because the archive mixes DOS and Unix line endings:

```sh
git apply --ignore-space-change /path/to/adrbubblebooter-v1.3-direct-iftu.patch
```

The release modules were built with VitaSDK autobuild `master-linux-v1232`
(2020-09-26, GCC 10.1.0), the period immediately preceding the archived
booter source. The user module uses frangarcj's `vita2dlib-fbo` at commit
`c221adb` and `vitashaders` at commit `15393d5`, including the
`sharp_bilinear_simple` programs. `-fcommon` retains the archive's original
tentative-definition behavior under GCC 10; no source ownership was invented.

The period toolchain is intentional. Relative to the fork's original modules,
the rebuilt kernel has an identical Vita import set and retains the original
`ksceKernelCpuDcacheWritebackRange` NID `0x9CB9F0CE`. The rebuilt user module
has an identical import set except for the single new
`kuSetPspemuDirectSharpScale` syscall (`0x36B0C051`).

The fast path is deliberately limited to PSP mode on a handheld Vita with:

- Graphics Filtering: `Sharp Bilinear Simple ( No Scanlines )`
- Smooth Graphics: `No`
- F.lux Filter Color: `None`
- Effective PSP scale: exactly `2.000 x 2.000`

Other combinations keep using the existing Vita2D shader path. If the kernel
IFTU hook cannot be installed, the user module also falls back to that path.

The kernel and user modules are an ABI-matched pair. If taiHEN loads
`adrenaline_kernel.skprx` from `ur0:tai` (or another path outside
`ux0:app/PSPEMUCFW/sce_module`), copy the matching rebuilt kernel to that exact
configured path and fully reboot before loading the rebuilt user module.
