
langs = {
	{ file = "JAPANESE",		name = STRINGS_LANG_JAPANESE,		},--1
	{ file = "ENGLISH_US",		name = STRINGS_LANG_ENGLISH_US,		},--2
	{ file = "FRENCH",			name = STRINGS_LANG_FRENCH,			},
	{ file = "SPANISH",			name = STRINGS_LANG_SPANISH,		},
	{ file = "GERMAN",			name = STRINGS_LANG_GERMAN,			},
	{ file = "ITALIAN",			name = STRINGS_LANG_ITALIAN,		},
	{ file = "DUTCH",			name = STRINGS_LANG_DUTCH,			},
	{ file = "PORTUGUESE",		name = STRINGS_LANG_PORTUGUESE,		},
	{ file = "RUSSIAN",			name = STRINGS_LANG_RUSSIAN,		},
	{ file = "KOREAN",			name = STRINGS_LANG_KOREAN,			},
	{ file = "CHINESE_T",		name = STRINGS_LANG_CHINESE_T,		},
	{ file = "CHINESE_S",		name = STRINGS_LANG_CHINESE_S,		},
	{ file = "FINNISH",			name = STRINGS_LANG_FINNISH,		},
	{ file = "SWEDISH",			name = STRINGS_LANG_SWEDISH,		},
	{ file = "DANISH",			name = STRINGS_LANG_DANISH,			},
	{ file = "NORWEGIAN",		name = STRINGS_LANG_NORWEGIAN,		},
	{ file = "POLISH",			name = STRINGS_LANG_POLISH,			},
	{ file = "PORTUGUESE_BR",	name = STRINGS_LANG_PORTUGUESE_BR,	},
	{ file = "ENGLISH_GB",		name = STRINGS_LANG_ENGLISH_GB,		},
	{ file = "TURKISH",			name = STRINGS_LANG_TURKISH,		},--20
}

local current_lang = nil
local tb = {}
if #langs > 1 then table.sort(langs ,function (a,b) return string.lower(a.file)<string.lower(b.file) end) end

for i=1,#langs do
	if files.exists("resources/lang/"..langs[i].file..".txt") then
		table.insert(tb, langs[i])
	end
end

__PATH_LANG = "ux0:/data/ABM/lang/"
files.mkdir(__PATH_LANG)
function download_langs()
--local onNetGetFileOld = onNetGetFile; onNetGetFile = nil
	for i=1,#langs do
		bubble_id,NResources,TResources = langs[i].file..".txt",i,#langs
		local res = http.download(string.format("https://raw.githubusercontent.com/%s/%s/master/%s/resources/lang/%s.txt", APP_REPO,APP_PROJECT,APP_PROJECT,
				string.lower(langs[i].file)), "ux0:data/abm/lang/"..string.lower(langs[i].file..".txt"))
		if res.headers and res.headers.status_code == 200 and files.exists(__PATH_LANG..langs[i].file..".txt") then
			files.move(__PATH_LANG..langs[i].file..".txt","resources/lang/")
		else
			files.delete(__PATH_LANG..langs[i].file..".txt")
		end
		bubble_id = ""
		NResources, TResources = 0,0
	end
	os.delay(750)
--onNetGetFile = onNetGetFileOld
end
