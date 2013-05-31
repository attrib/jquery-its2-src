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

  applyRules: (ret, tag, attributes) ->
    xpath = XPath.getInstance tag
    store = false
    for rule in @rules
      if rule.type = @NAME
        if xpath.process rule.selector
          for attribute in attributes
            if rule[attribute]?
              ret[attribute] = rule[attribute]
              store = true
    if store
      @store tag, ret

  applyAttributes: (ret, tag) ->
    if @attributes?
      store = false
      for objectName, attributeName of @attributes
        attributeValue = $(tag).attr(attributeName)
        if attributeValue?
          ret[objectName] = attributeValue
          store = true
      if store
        @store tag, ret

  applyInherit: (ret, tag, withAttributes = false) ->
    if tag instanceof Attr
      if withAttributes
        value = @inherited tag.ownerElement
    else
      value = @inherited tag
    if value instanceof Object
      for key, val of value
        ret[key] = val

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
      xpath = XPath.getInstance parent
      if @applied[xpath.path]
        return $.extend(true, {}, @applied[xpath.path])

  store: (node, object) =>
    # don't waste memory here and save empty objects
    if (k for own k of object).length isnt 0
      xpath = XPath.getInstance node
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

  normalizeString: (string) ->
    if string?
      string = string.toLowerCase()
    else
      string = ''
    string

  splitQuery: (query, value, callbacks) ->
    allowed = []
    for key, callback of callbacks
      allowed.push(key)
    allowedReg = allowed.join('|')
    query = query.split ','
    ret = if query.length > 0 then true else false
    for test in query
      match = test.match ///(#{allowedReg}):\s*(.*?)\s*$///
      if match == null
        console.log "Unknown query "+ query
        return false
      if callbacks[match[1]]? and typeof callbacks[match[1]] is "function"
        ret = ret and callbacks[match[1]](match)
        if !ret
          return false
      else if value[match[1]]?
        if value[match[1]] != match[2]
          return false
      else
        return false
    return ret

  compareNumber: (query, value) ->
    match = query.match /([<>!=]*)\s*([-\d\.]*)/
    match[2] = parseFloat match[2]
    if not value?
      return false
    value = parseFloat value
    if not isNaN(match[2]) and not isNaN(value)
      switch match[1]
        when "", "=", "=="
          if value != match[2]
            return false
        when "!="
          if value == match[2]
            return false
        when ">"
          if value <= match[2]
            return false
        when "<"
          if value >= match[2]
            return false
        else
          return false
      return true
    else
      return false
