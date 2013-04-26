###
# Rule class.
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

staticData = {}

class Rule
  constructor: ->
    @rules = []
    @applied = {}
    @standoff = []

  parse: (rule, content) => throw new Error('AbstractClass Rule: method parse not implemented.')
  apply: (node) => throw new Error('AbstractClass Rule: method apply not implemented.')
  def: -> throw new Error('AbstractClass Rule: method def not implemented.')
  standoffMarkupXML: (rule, content, file) =>
    return false

  standoffMarkup: (content) =>
    return false

  addStandoff: (object) ->
    @standoff.push object

  addSelector: (object) ->
    @rules.push(object)

  inherited: (node) ->
    parents = $(node).parents()
    parents.splice(0, 0, $(node))
    for parent in parents
      xpath = new XPath parent
      if @applied[xpath.path]
        return @applied[xpath.path]

  store: (node, object) =>
    xpath = new XPath node
    @applied[xpath.path] = object

  normalizeYesNo: (translateString) ->
    if typeof translateString == "boolean"
      return translateString
    # Trim the string and lowecase.
    translateString = translateString.replace(/^\s+|\s+$/g, '').toLowerCase();
    if translateString == "yes"
      return true
    else
      return false
