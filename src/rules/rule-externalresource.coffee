###
# External Resource.
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

class ExternalResourceRule extends Rule

  constructor: ->
    super
    @RULE_NAME = 'its:externalresourcerefrule'
    @NAME = 'externalResource'

  createRule: (selector, externalResourceRef) ->
    object = {}
    object.selector = selector
    object.type = @NAME
    object.externalResourceRef = externalResourceRef
    object

  parse: (rule, content) ->
    if rule.tagName.toLowerCase() is @RULE_NAME
      selector = $(rule).attr 'selector'
      # at least one of the following
      if $(rule).attr 'externalResourceRefPointer'
        xpath = new XPath content
        newRules = xpath.resolve selector, $(rule).attr 'externalResourceRefPointer'
        for newRule in newRules
          if newRule.result instanceof Attr then externalResourceRef = newRule.result.value else externalResourceRef = $(newRule.result).text()
          @addSelector @createRule(newRule.selector, externalResourceRef)

  apply: (tag) =>
    # Precedence order
    # 1. Default
    ret = @def()
    # 2. Rules in the schema
    @applyRules ret, tag, ['externalResourceRef']
    # 3. no inheritance
    # 4. no local attributes
    # ...and return
    ret

  def: ->
    {
    }

  jQSelector:
    name: 'externalResource'
    callback: (a, i, m) ->
      query = if m[3] then m[3] else 'any'
      value = window.rulesController.apply a, 'ExternalResourceRule'
      if (k for own k of value).length isnt 0
        if query is 'any'
          return true
        else if not value.externalResourceRef? or value.externalResourceRef != query
          return false
        else
          return true

      return false
