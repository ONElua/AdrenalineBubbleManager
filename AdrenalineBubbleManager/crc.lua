--CRC for prks
-- default values modules ABM for adrenaline v6.3 commit b234c78:
_adrbubblebooter_suprx = "0x430C997F"
_adrenaline_kernel     = "0x12730F40"
_adrenaline_user       = "0x7B85DDDF"
_adrenaline_vsh        = "0xA21310E8"

local crc_path = "ux0:data/ABM/crc.ini"

if not files.exists(crc_path) then
	ini.write(crc_path,"adr_booter","adrbubblebooter_suprx",_adrbubblebooter_suprx)
	ini.write(crc_path,"adr_kernel","adrenaline_kernel",_adrenaline_kernel)
	ini.write(crc_path,"adr_user","adrenaline_user",_adrenaline_user)
	ini.write(crc_path,"adr_vsh","adrenaline_vsh",_adrenaline_vsh)
end

__CRCADRBOOTER = tonumber(ini.read(crc_path,"adr_booter","adrbubblebooter_suprx",_adrbubblebooter_suprx))
__CRCKERNEL    = tonumber(ini.read(crc_path,"adr_kernel","adrenaline_kernel",_adrenaline_kernel))
__CRCUSER      = tonumber(ini.read(crc_path,"adr_user","adrenaline_user",_adrenaline_user))
__CRCVSH       = tonumber(ini.read(crc_path,"adr_vsh","adrenaline_vsh",_adrenaline_vsh))


