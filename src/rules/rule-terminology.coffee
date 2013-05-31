###
# Terminology.
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

class TerminologyRule extends Rule

  constructor: ->
    super
    @RULE_NAME = 'its:termrule'
    @NAME = 'terminology'
    @attributes = {
      termConfidence: 'its-term-confidence',
      termInfoRef: 'its-term-info-ref',
      term: 'its-term'
    }

  parse: (rule, content) ->
    if rule.tagName.toLowerCase() is @RULE_NAME
      rules = []
      object = {}
      object.selector = $(rule).attr 'selector'
      object.type = @NAME
      if $(rule).attr 'term'
        object.term = $(rule).attr 'term'
      else
        return

      # none or exaclty one of the following
      if $(rule).attr('termInfoPointer')
        xpath = XPath.getInstance content
        newRules = xpath.resolve object.selector, $(rule).attr 'termInfoPointer'
        for newRule in newRules
          newObject = $.extend(true, {}, object);
          newObject.selector = newRule.selector
          if newRule.result instanceof Attr then newObject.termInfo = newRule.result.value else newObject.termInfo = $(newRule.result).text()
          rules.push newObject

      else if $(rule).attr 'termInfoRef'
        object.termInfoRef = $(rule).attr 'termInfoRef'
        rules.push $.extend(true, {}, object)

      else if $(rule).attr 'termInfoRefPointer'
        xpath = XPath.getInstance content
        newRules = xpath.resolve object.selector, $(rule).attr 'termInfoRefPointer'
        for newRule in newRules
          newObject = $.extend(true, {}, object);
          newObject.selector = newRule.selector
          if newRule.result instanceof Attr then newObject.termInfoRef = newRule.result.value else newObject.termInfoRef = $(newRule.result).text()
          rules.push newObject

      else
        rules.push $.extend(true, {}, object)

      for ruleObject in rules
        if rules.term?
          rules.term = @normalizeYesNo rules.term
        @addSelector ruleObject

  apply: (tag) =>
    # Precedence order
    # 1. Default
    ret = @def()
    # 2. Rules in the schema
    @applyRules ret, tag, ['term', 'termInfoRef', 'termInfo']
    # 3. no inheritance
    # 4. Local attributes
    @applyAttributes ret, tag
    # ...and return
    if ret.term?
      ret.term = @normalizeYesNo ret.term
    ret

  def: ->
    {
      term: false
    }

  jQSelector:
    name: 'terminology'
    callback: (a, i, m) ->
      query = if m[3] then m[3] else 'any'
      value = window.rulesController.apply a, 'TerminologyRule'
      if (k for own k of value).length isnt 0
        if query is 'any'
          return value.term
        else
          return @splitQuery query, value, {
            termConfidence: (match) =>
              return @compareNumber match[2], value.termConfidence
            term: (match) ->
              if (value.term and "no" == match[2]) or (!value.term and "yes" == match[2])
                return false
              else
                return true
            termInfoRef: "" #default behaivor
          }

      return false

