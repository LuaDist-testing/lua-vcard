#!/usr/bin/lua5.2

local vcard = require("vcard")

local file = io.open(arg[1])
local card = file:read("*all")
file:close()

require("pl.pretty").dump(vcard.parse(card))
