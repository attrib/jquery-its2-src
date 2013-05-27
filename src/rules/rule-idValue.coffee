###
# Id Value.
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

class IdValueRule extends Rule

  constructor: ->
    super
    @RULE_NAME = 'its:idvaluerule'
    @NAME = 'idValue'

  createRule: (selector, idValue) ->
    object = {}
    object.selector = selector
    object.type = @NAME
    object.idValue = idValue
    object

  parse: (rule, content) ->
    if rule.tagName.toLowerCase() is @RULE_NAME
      selector = $(rule).attr 'selector'
      # at least one of the following
      if $(rule).attr 'idValue'
        xpath = new XPath content
        newRules = xpath.resolve selector, $(rule).attr 'idValue'
        for newRule in newRules
          if newRule.result instanceof Attr then idValue = newRule.result.value else idValue = $(newRule.result).text()
          @addSelector @createRule(newRule.selector, idValue)

  apply: (tag) =>
    # Precedence order
    # 1. Default
    ret = @def()
    # 2. Rules in the schema
    @applyRules ret, tag, ['idValue']
    # 3. no inheritance
    # 4. Local attributes
    if $(tag).attr('xml:id') != undefined
      ret.idValue = $(tag).attr 'xml:id'
    if $(tag).attr('id') != undefined
      ret.idValue = $(tag).attr 'id'
    # ...and return
    ret

  def: ->
    {
    }

  jQSelector:
    name: 'idValue'
    callback: (a, i, m) ->
      query = if m[3] then m[3] else 'any'
      value = window.rulesController.apply a, 'IdValueRule'
      if (k for own k of value).length isnt 0
        if query is 'any'
          return true
        else if not value.idValue? or value.idValue != query
          return false
        else
          return true

      return false
