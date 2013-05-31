###
# Text Analysis.
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

class TextAnalysisRule extends Rule

  constructor: ->
    super
    @RULE_NAME = 'its:textanalysisrule'
    @NAME = 'textAnalysis'
    @attributes = {
      taClassRef: 'its-ta-class-ref',
      taConfidence: 'its-ta-confidence',
      taIdent: 'its-ta-ident',
      taIdentRef: 'its-ta-ident-ref'
      taSource: 'its-ta-source',
    }

  parse: (rule, content) ->
    if rule.tagName.toLowerCase() is @RULE_NAME
      rules = []
      object = {}
      object.selector = $(rule).attr 'selector'
      object.type = @NAME
      # at least one of the following
      foundOne = false
      if $(rule).attr 'taClassRefPointer'
        foundOne = true
        xpath = XPath.getInstance content
        newRules = xpath.resolve object.selector, $(rule).attr 'taClassRefPointer'
        for newRule in newRules
          newObject = $.extend(true, {}, object);
          if newRule.result instanceof Attr then newObject.taClassRef = newRule.result.value else newObject.taClassRef = $(newRule.result).text()
          newObject.selector = newRule.selector
          rules.push newObject

      # exaclty one of the following
      if $(rule).attr 'taIdentRefPointer'
        foundOne = true
        xpath = XPath.getInstance content
        newRules = xpath.resolve object.selector, $(rule).attr 'taIdentRefPointer'
        for newRule in newRules
          newObject = $.extend(true, {}, object);
          newObject.selector = newRule.selector
          if newRule.result instanceof Attr then newObject.taIdentRef = newRule.result.value else newObject.taIdentRef = $(newRule.result).text()
          rules.push newObject

      else if $(rule).attr('taSourcePointer') and $(rule).attr('taIdentPointer')
        foundOne = true
        xpath = XPath.getInstance content
        newRules = xpath.resolve object.selector, $(rule).attr 'taSourcePointer'
        for newRule in newRules
          newObject = $.extend(true, {}, object);
          newObject.selector = newRule.selector
          if newRule.result instanceof Attr then newObject.taSource = newRule.result.value else newObject.taSource = $(newRule.result).text()
          rules.push newObject
        newRules = xpath.resolve object.selector, $(rule).attr 'taIdentPointer'
        for newRule in newRules
          newObject = $.extend(true, {}, object);
          newObject.selector = newRule.selector
          if newRule.result instanceof Attr then newObject.taIdent = newRule.result.value else newObject.taIdent = $(newRule.result).text()
          rules.push newObject
          for ruleOb in rules
            ruleOb = newObject.taIdent

      if !foundOne
        return

      for ruleObject in rules
        @addSelector ruleObject

  apply: (tag) =>
    # Precedence order
    # 1. Default
    ret = @def()
    # 2. Rules in the schema
    @applyRules ret, tag, ['taClassRef', 'taIdent', 'taIdentRef', 'taSource']
    # 3. no inheritance
    # 4. Local attributes
    @applyAttributes ret, tag
    # ...and return
    ret

  def: ->
    {
    }

  jQSelector:
    name: 'textAnalysis'
    callback: (a, i, m) ->
      query = if m[3] then m[3] else 'any'
      value = window.rulesController.apply a, 'TextAnalysisRule'
      if (k for own k of value).length isnt 0
        if query is 'any'
          return true
        else
          return @splitQuery query, value, {
            taConfidence: (match) =>
              return @compareNumber(match[2], value.taConfidence)

            taIdentRef: "" #default behaivor
            taClassRef: "" #default behaivor
            taSource: ""   #default behaivor
            taIdent: ""    #default behaivor
          }

      return false
