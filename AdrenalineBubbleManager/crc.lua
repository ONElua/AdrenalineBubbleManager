--CRC for prks
-- default values modules AdrenalineBooter v.09 for adrenaline v6.8
__CRCADRBOOTER  = 0x2E70A660
__CRCKERNEL     = 0x2FBCD297
__CRCUSER       = 0x776B9075
__CRCVSH        = 0x11DE65BA
__CRCBOOTCONV   = 0xD9487522

ADRENALINE = "ux0:app/PSPEMUCFW"
MODULES = {
  { fullpath = ADRENALINE.."/sce_module/adrbubblebooter.suprx",   path = "sce_module/adrbubblebooter.suprx",   crc = __CRCADRBOOTER },
  { fullpath = ADRENALINE.."/sce_module/adrenaline_kernel.skprx", path = "sce_module/adrenaline_kernel.skprx", crc = __CRCKERNEL  },
  { fullpath = ADRENALINE.."/sce_module/adrenaline_user.suprx",   path = "sce_module/adrenaline_user.suprx",   crc = __CRCUSER  },
  { fullpath = ADRENALINE.."/sce_module/adrenaline_vsh.suprx",    path = "sce_module/adrenaline_vsh.suprx",    crc = __CRCVSH  },
  { fullpath = ADRENALINE.."/sce_module/bootconv.suprx",          path = "sce_module/bootconv.suprx",          crc = __CRCBOOTCONV }
}
