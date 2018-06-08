local vdata= {}

-- The rules for vcard, from the RFCs
-- I may add some checks sometime in the future
-- but right now i don't need it
-- if you want to check against the RFCs
-- don't hesitate to contribute :)

local datatypes = {
	"TEXT",
	"URI",
	"DATE",
	"TIME",
	"DATE-TIME",
	"DATE-AND-OR-TIME", --Guys...
	"TIMESTAMP",
	"BOOLEAN",
	"INTEGER",
	"FLOAT",
	"UTC-OFFSET",
	"LANGUAGE-TAG",

	-- Not an official name, it's to indicate a list of text elements separated by a semicolon
	"LIST",

	-- Legacy types from RFC2426
	"BINARY",
	"VCARD",
	"PHONE-NUMBER"
}

local parameters = {
	"LANGUAGE",
	"VALUE",
	"PREF",
	"ALTID",
	"PID",
	"TYPE",
	"MEDIATYPE",
	"CALSCALE",
	"SORT-AS",
	"GEO",
	"TZ",

	-- Match X-* parameters
	"ANY",

	-- Added in RFC6715
	"INDEX",
	"LEVEL",

	-- Legacy parameters from RFC2426
	"ENCODING",
	"CHARSET",
	"CONTEXT"

	-- Doesn't include "GROUP", from RFC7095 because it's JSON-Specific
}

-- name, versions, parameters, datatype, possible values
local elements = {
	-- Legacy elements from 2.1 and 3.0, these are obsolete
	{ "AGENT", {2.1, 3.0}, {{"VALUE", {"URI"}}}, {"URI", "TEXT"}, nil},
	{ "CLASS", {3.0}, nil, {"TEXT"}, {"PUBLIC", "PRIVATE", "CONFIDENTIAL"}},
	{ "MAILER", {2.1, 3.0}, nil, {"TEXT"}, nil},
	{ "NAME", {3.0}, nil, {"TEXT"}, nil},
	{ "PROFILE", {2.1, 3.0}, nil, {"TEXT"}, nil},

	-- Elements as of RFC6350
	{ "BEGIN", {2.1, 3.0, 4.0}, nil, {"TEXT"}, {"VCARD"}},
	{ "END", {2.1, 3.0, 4.0}, nil, {"TEXT"}, {"VCARD"}},
	{ "SOURCE", {2.1, 3.0, 4.0}, {{"VALUE", {"URI"}}, "PID", "PREF", "ALTID", "MEDIATYPE", "ANY"}, {"URI"}, nil},
	{ "KIND", {4.0}, {{"VALUE", {"TEXT"}}, "X-*"}, {"TEXT"}, {"individual", "group", "org", "location", "ANY"}},
	{ "XML", {4.0}, {{"VALUE", {"TEXT"}}, "ALTID"}, {"TEXT"}, nil},
	{ "FN", {2.1, 3.0, 4.0}, {{"VALUE", {"TEXT"}}, {"TYPE", {"work", "home"}}, "LANGUAGE", "ALTID", "PID", "PREF", "ANY"}, {"TEXT"}, nil},
	{ "N", {2.1, 3.0, 4.0}, {{"VALUE", {"TEXT"}}, "SORT-AS", "LANGUAGE", "ALTID", "ANY"}, {"LIST", {"surname", "given", "additional", "honorific_prefix", "honorifix_suffix"}}, nil},
	{ "NICKNAME", {3.0, 4.0}, {{"VALUE", {"TEXT"}}, {"TYPE", {"work", "home"}}, "LANGUAGE", "ALTID", "PID", "PREF", "ANY"}, {"TEXT"}, nil},
	{ "PHOTO", {2.1, 3.0, 4.0}, {{"VALUE", {"URI"}}, "ALTID", {"TYPE", {"work", "home"}}, "MEDIATYPE", "PREF", "PID", "ANY"}, {"URI"}, nil},
	{ "BDAY", {2.1, 3.0, 4.0}, {{"VALUE", {"TEXT", "DATE-AND-OR-TIME"}}, "LANGUAGE", "ALTID", "CALSCALE", "ANY"}, {"DATE-AND-OR-TIME", "TEXT"}, nil},
	{ "ANNIVERSARY", {4.0}, {{"VALUE", {"TEXT", "DATE-AND-OR-TIME"}}, "ALTID", "CALSCALE", "ANY"}, {"DATE-AND-OR-TIME", "TEXT"}, nil},
	{ "GENDER", {4.0}, {{"VALUE", {"TEXT"}}, "ANY"}, {"LIST", {"sex", "gender"}}, {{"", "M", "F", "O", "N", "U"}, nil}},
	{ "ADR", {2.1, 3.0, 4.0}, {{"VALUE", {"TEXT"}}, "LABEL", "LANGUAGE", "GEO", "TZ", "ALTID", "PID", "PREF", {"TYPE", {"work", "home"}}, "ANY"}, {"LIST", {"postbox", "extended", "street", "locality", "region", "postcode", "country"}}, nil},
	{ "TEL", {2.1, 3.0, 4.0}, {{"VALUE", {"TEXT", "URI"}}, {"TYPE", {"work", "home", "text", "voice", "fax", "cell", "video", "pager", "textphone", "ANY"}}, "MEDIATYPE", "PID", "PREF", "ANY"}, {"TEXT", "URI"}, nil},
	{ "EMAIL", {2.1, 3.0, 4.0}, {{"VALUE", {"TEXT"}}, "PID", "PREF", {"TYPE", {"work", "home"}}, "ALTID", "ANY"}, {"TEXT"}, nil},
	{ "IMPP", {3.0, 4.0}, {{"VALUE", {"URI"}}, "PID", "PREF", {"TYPE", {"work", "home"}}, "MEDIATYPE", "ALTID", "ANY"}, {"URI"}, nil},
	{ "LANG", {4.0}, {{"VALUE", {"LANGUAGE-TAG"}}, "PID", "PREF", "ALTID", {"TYPE", {"work", "home"}}, "ANY"}, {"LANGUAGE-TAG"}, nil},
	{ "TZ", {2.1, 3.0, 4.0}, {{"VALUE", {"TEXT", "URI", "UTC-OFFSET"}}, "ALTID", "PID", "PREF", {"TYPE", {"work", "home"}}, "MEDIATYPE", "ANY"}, {"TEXT", "URI", "UTC-OFFSET"}},
	{ "GEO", {2.1, 3.0, 4.0}, {{"VALUE", {"URI"}}, "PID", "PREF", {"TYPE", {"work", "home"}}, "MEDIATYPE", "ALTID", "ANY"}, {"URI"}, nil},
	{ "TITLE", {2.1, 3.0, 4.0}, {{"VALUE", {"TEXT"}}, "LANGUAGE", "PID", "PREF", "ALTID", {"TYPE", {"work", "home"}}, "ANY"}, {"TEXT"}, nil},
	{ "ROLE", {2.1, 3.0, 4.0}, {{"VALUE", {"TEXT"}}, "LANGUAGE", "PID", "PREF", {"TYPE", {"work", "home"}}, "ALTID", "ANY"}, {"TEXT"}, nil},
	{ "LOGO", {2.1, 3.0, 4.0}, {{"VALUE", {"URI"}}, "LANGUAGE", "PID", "PREF", {"TYPE", {"work", "home"}}, "MEDIATYPE", "ALTID", "ANY"}, {"URI"}, nil},
	{ "ORG", {2.1, 3.0, 4.0}, {{"VALUE", {"TEXT"}}, "SORT-AS", "LANGUAGE", "PID", "PREF", "ALTID", {"TYPE", {"work", "home"}}, "ANY"}, {"LIST", {nil}}, nil},
	{ "MEMBER", {4.0}, {{"VALUE", {"URI"}}, "PID", "PREF", "ALTID", "MEDIATYPE", "ANY"}, {"URI"}, nil},
	{ "RELATED", {4.0}, {{"VALUE", {"URI", "TEXT"}}, "PREF", "ALTID", {"TYPE", {"work", "home", "context", "acquaintance", "friend", "met", "co-worker", "colleague", "co-resident", "neighbor", "child", "parent", "sibling", "spouse", "kin", "muse", "crush", "date", "sweetheart", "me", "agent", "emergency"}}, "MEDIATYPE", "LANGUAGE"}, {"TEXT", "URI"}, nil},
	{ "CATEGORIES", {2.1, 3.0, 4.0}, {{"VALUE", {"TEXT"}}, "PID", "PREF", "TYPE", "ALTID", "ANY"}, {"TEXT"}, nil},
	{ "NOTE", {2,1, 3.0, 4.0}, {{"VALUE", {"TEXT"}}, "LANGUAGE", "PID", "PREF", {"TYPE", {"work", "home"}}, "ALTID", "ANY"}, {"TEXT"}, nil},
	{ "PRODID", {3.0, 4.0}, {{"VALUE", {"TEXT"}}, "ANY"}, {"TEXT"}, nil},
	{ "REV", {2.1, 3.0, 4.0}, {{"VALUE", {"TIMESTAMP"}}, "ANY"}, {"TIMESTAMP"}, nil},
	{ "SOUND", {2.1, 3.0, 4.0}, {{"VALUE", {"URI"}}, "LANGUAGE", "PID", "PREF", {"TYPE", {"work", "home"}}, "MEDIATYPE", "ALTID", "ANY"}, {"URI"}, nil},
	{ "UID", {2.1, 3.0, 4.0}, {{"VALUE", {"TEXT", "URI"}}, "ANY"}, {"TEXT", "URI"}, nil},
	{ "CLIENTPIDMAP", {4.0}, {"ANY"}, {"LIST", {"pid", "uri"}}, nil},
	{ "URL", {2.1, 3.0, 4.0}, {{"VALUE", {"TEXT"}}, "PID", "PREF", {"TYPE", {"work", "home"}}, "MEDIATYPE", "ALTID", "ANY"}, {"TEXT"}, nil},
	{ "VERSION", {2.1, 3.0, 4.0}, {{"VALUE", {"TEXT"}}, "ANY"}, {"TEXT"}, {"2.1", "3.0", "4.0"}},
	{ "KEY", {2.1, 3.0, 4.0}, {{"VALUE", {"TEXT", "URI"}}, "ALTID", "PID", "PREF", {"TYPE", {"work", "home"}}, "MEDIATYPE", "ANY"}, {"TEXT", "URI"}, nil},
	{ "FBURL", {4.0}, {{"VALUE", {"URI"}}, "PID", "PREF", {"TYPE", {"work", "home"}}, "MEDIATYPE", "ALTID", "ANY"}, {"URI"}, nil},
	{ "CALADRURI", {4.0}, {{"VALUE", {"URI"}}, "PID", "PREF", {"TYPE", {"work", "home"}}, "MEDIATYPE", "ALTID", "ANY"}, {"URI"}, nil},
	{ "CALURI", {4.0}, {{"VALUE", {"URI"}}, "PID", "PREF", {"TYPE", {"work", "home"}}, "MEDIATYPE", "ALTID", "ANY"}, {"URI"}, nil},

	-- Added by RFC 6474
	{ "BIRTHPLACE", {4.0}, {{"VALUE", {"TEXT", "URI"}}, "ALTID", "LANGUAGE", "ANY"}, {"TEXT", "URI"}, nil},
	{ "DEATHPLACE", {4.0}, {{"VALUE", {"TEXT", "URI"}}, "ALTID", "LANGUAGE", "ANY"}, {"TEXT", "URI"}, nil},
	{ "DEATHPLACE", {4.0}, {{"VALUE", {"DATE-AND-OR-TIME", "TEXT"}}, "ALTID", "CALSCALE", "LANGUAGE", "ANY"}, {"DATE-AND-OR-TIME", "TEXT"}, nil},

	-- Added by RFC 6715 // NOTE: TYPE parameters aren't defined here
	{ "EXPERTISE", {4.0}, {{"LEVEL", {"beginner", "average", "expert"}}, "INDEX", "LANGUAGE", "PREF", "ALTID", "TYPE", "ANY"}, {"TEXT"}, nil},
	{ "HOBBY", {4.0}, {{"LEVEL", {"high", "medium", "low"}}, "INDEX", "LANGUAGE", "PREF", "ALTID", "TYPE", "ANY"}, {"TEXT"}, nil},
	{ "INTEREST", {4.0}, {{"LEVEL", {"high", "medium", "low"}}, "INDEX", "LANGUAGE", "PREF", "ALTID", "TYPE", "ANY"}, {"TEXT"}, nil},
	{ "ORG-DIRECTORY", {4.0}, {"PREF", "INDEX", "LANGUAGE", "PID", "PREF", "ALTID", "TYPE", "ANY"}, {"URI"}, nil},

	-- Other x-* (non-official) types, which are common given to wikipedia, so... why not.
	{ "X-ABUID", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-ANNIVERSARY", {2.1, 3.0, 4.0}, nil, {"DATE-AND-OR-TIME"}, nil},
	{ "X-ASSISTANT", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-MANAGER", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-SPOUSE", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-GENDER", {2.1, 3.0, 4.0}, nil, {"TEXT"}, {"Male", "Female"}},
	{ "X-WAB-GENDER", {2.1, 3.0, 4.0}, nil, {"INTEGER"}, {1, 2}},
	{ "X-AIM", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-ICQ", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-GTALK", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-GOOGLE-TALK", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-JABBER", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-MSN", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-YAHOO", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-TWITTER", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-SKYPE", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-SKYPE-USERNAME", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-GADUGADU", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-GROUPWISE", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-MS-CHILD", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-MS-IMADDRESS", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-MS-CARDPICTURE", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-MS-OL-DESIGN", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-PHONETIC-FIRST-NAME", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-PHONETIC-LAST-NAME", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-MOZILLA-HTML", {2.1, 3.0, 4.0}, nil, {"BOOLEAN"}, nil},
	{ "X-MOZILLA-PROPERTY", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-EVOLUTION-ANNIVERSARY", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-EVOLUTION-ASSISTANT", {2.1, 3.0, 4.0}, nil, {"DATE-AND-OR-TIME"}, nil},
	{ "X-EVOLUTION-BLOG-URL", {2.1, 3.0, 4.0}, nil, {"TEXT", "URI"}, nil},
	{ "X-EVOLUTION-FILE-AS", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-EVOLUTION-LIST", {2.1, 3.0, 4.0}, nil, {"BOOLEAN"}, nil},
	{ "X-EVOLUTION-LIST-SHOW-ADDRESSES", {2.1, 3.0, 4.0}, nil, {"BOOLEAN"}, nil},
	{ "X-EVOLUTION-MANAGER", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-EVOLUTION-SPOUSE", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-EVOLUTION-VIDEO-URL", {2.1, 3.0, 4.0}, nil, {"TEXT", "URI"}, nil},
	{ "X-EVOLUTION-CALLBACK", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-EVOLUTION-RADIO", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-EVOLUTION-TELEX", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-EVOLUTION-TTYTDD", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-KADDRESSBOOK-BlogFeed", {2.1, 3.0, 4.0}, nil, {"TEXT", "URI"}, nil},
	{ "X-KADDRESSBOOK-X-Anniversary", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-KADDRESSBOOK-X-AssistantName", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-KADDRESSBOOK-X-IMAddress", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-KADDRESSBOOK-X-ManagersName", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-KADDRESSBOOK-X-Office", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-KADDRESSBOOK-X-Profession", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-KADDRESSBOOK-X-SpouseName", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-KADDRESSBOOK-OPENPGPFP", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
	{ "X-WEBMONEY-ID", {2.1, 3.0, 4.0}, nil, {"TEXT"}, nil},
}

return vdata
