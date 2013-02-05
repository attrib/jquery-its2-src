###
# jQuery plugin for ITS testing framework.
#
# Authors: Karl Fritsche <karl.fritsche@cocomore.com>
#          Alejandro Leiva <alejandro.leiva@cocomore.com>
#
# This file is part of ITS Parser. ITS Parser is free software: you can
# redistribute it and/or modify it under the terms of the GNU General Public
# License as published by the Free Software Foundation, version 2.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 51
# Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
# Copyright (C) 2013 Cocomore AG
###

$ = jQuery

$.extend
  parseITS: (callback) ->
    window.XPath = XPath
    globalRules = [new TranslateRule(), new LocalizationNoteRule(), new StorageSizeRule(), new AllowedCharactersRule(), new ParamRule()]
    external_rules = $('link[rel="its-rules"]')
    window.rulesController = new RulesController(globalRules)
    window.rulesController.setContent $('html')
    if external_rules
      window.rulesController.addLink rule for rule in external_rules
    internal_rules = $('script[type="application/its+xml"]')
    if internal_rules
      for rule in internal_rules
        rule = $.parseXML rule.childNodes[0].data
        if rule
          window.rulesController.addXML rule.childNodes[0]
    if callback
      callback(window.rulesController)

$.extend $.expr[':'],
  translate: (a, i, m) ->
    query = 'translate=' + if m[3] then m[3] else 'yes'
    value = window.rulesController.apply a, 'TranslateRule'
    return value == query
  locnote: (a, i, m) ->
    return false
