###
# Allowed Characters Rule.
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

class AllowedCharactersRule extends Rule

  constructor: ->
    super
    @RULE_NAME = 'its:allowedcharactersrule'
    @NAME = 'allowedCharacters'
    @attributes = {
      allowedCharacters: 'its-allowed-characters',
    }

  createRule: (selector, allowedCharacters) ->
    object = {}
    object.selector = selector
    object.allowedCharacters = allowedCharacters
    object.type = @NAME
    object

  parse: (rule, content) ->
    if rule.tagName.toLowerCase() is @RULE_NAME
      selector = $(rule).attr 'selector'
      #one of following
      if $(rule).attr 'allowedCharacters'
        @addSelector @createRule selector, $(rule).attr('allowedCharacters')
      else if $(rule).attr 'allowedCharactersPointer'
        xpath = XPath.getInstance content
        newRules = xpath.resolve selector, $(rule).attr('allowedCharactersPointer')
        for newRule in newRules
          if newRule.result instanceof Attr then allowedCharacters = newRule.result.value else allowedCharacters = $(newRule.result).text()
          @addSelector @createRule newRule.selector, allowedCharacters
      else
        return

  apply: (tag) =>
    # Precedence order
    # 1. Default
    ret = @def()
    # 2. Rules in the schema
    @applyRules ret, tag, ['allowedCharacters']
    # 3. Rules in the document instance
    @applyInherit ret, tag
    # 4. Local attributes
    @applyAttributes ret, tag
    # ...and return
    if ret.allowedCharacters == ''
      return {}
    else
      return ret

  def: ->
    {
      allowedCharacters: '',
    }

  jQSelector:
    name: 'allowedCharacters'
    callback: (a, i, m) ->
      query = if m[3] then m[3] else 'any'
      value = window.rulesController.apply a, 'AllowedCharactersRule'
      if value.allowedCharacters
        if query == 'any'
          return true
        else if value.allowedCharacters == query
          return true
      return false

