###
# Target Pointer.
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

class TargetPointerRule extends Rule

  constructor: ->
    super
    @RULE_NAME = 'its:targetpointerrule'
    @NAME = 'targetPointer'

  createRule: (selector, targetPointer, target) ->
    object = {}
    object.selector = selector
    object.type = @NAME
    object.targetPointer = targetPointer
    if target?
      object.target = target
    object

  parse: (rule, content) ->
    if rule.tagName.toLowerCase() is @RULE_NAME
      selector = $(rule).attr 'selector'
      # at least one of the following
      if $(rule).attr 'targetPointer'
        targetPointer = $(rule).attr 'targetPointer'
        xpath = new XPath content
        newRules = xpath.resolve selector, targetPointer
        if newRules.length > 0
          for newRule in newRules
            if newRule.result instanceof Attr then target = newRule.result.value else target = $(newRule.result).text()
            @addSelector @createRule newRule.selector, targetPointer, target
        else
          @addSelector @createRule selector, targetPointer

  apply: (tag) =>
    # Precedence order
    # 1. Default
    ret = @def()
    # 2. Rules in the schema
    @applyRules ret, tag, ['target', 'targetPointer']
    # 3. no inheritance
    # 4. no local attributes
    # ...and return
    ret

  def: ->
    {
    }

  jQSelector:
    name: 'targetPointer'
    callback: (a, i, m) ->
      query = if m[3] then m[3] else 'any'
      value = window.rulesController.apply a, 'TargetPointerRule'
      if (k for own k of value).length isnt 0
        if query is 'any'
          return true
        else if not value.target? or value.target != query
          return false
        else
          return true

      return false
