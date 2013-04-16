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
      taConfidence: 'its-ta-confidence',
      taClassRef: 'its-ta-class-ref',
      taSource: 'its-ta-source',
      taIdent: 'its-ta-ident',
      taIdentRef: 'its-ta-ident-ref'
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
        xpath = new XPath content
        newRules = xpath.resolve object.selector, $(rule).attr 'taClassRefPointer'
        for newRule in newRules
          if newRule.result instanceof Attr then object.taClassRef = newRule.result.value else object.taClassRef = $(newRule.result).text()
          rules.push object

      # exaclty one of the following
      if $(rule).attr('taSourcePointer') and $(rule).attr('taIdentPointer')
        foundOne = true
        xpath = new XPath content
        newRules = xpath.resolve object.selector, $(rule).attr 'taSourcePointer'
        for newRule in newRules
          if newRule.result instanceof Attr then object.taSource = newRule.result.value else object.taSource = $(newRule.result).text()
        newRules = xpath.resolve object.selector, $(rule).attr 'taIdentPointer'
        for newRule in newRules
          if newRule.result instanceof Attr then object.taIdent = newRule.result.value else object.taIdent = $(newRule.result).text()
          rules.push object

      else if $(rule).attr 'taIdentRefPointer'
        foundOne = true
        xpath = new XPath content
        newRules = xpath.resolve object.selector, $(rule).attr 'taIdentRefPointer'
        for newRule in newRules
          if newRule.result instanceof Attr then object.taIdentRef = newRule.result.value else object.taIdentRef = $(newRule.result).text()
          rules.push object

      if !foundOne
        return

      for ruleObject in rules
        @addSelector ruleObject

  apply: (tag) =>
    # Precedence order
    # 1. Default
    ret = @def()
    # 2. Rules in the schema
    xpath = new XPath tag
    for rule in @rules
      if rule.type = @NAME
        if xpath.process rule.selector
          if rule.taClassRef
            ret.taClassRef = rule.taClassRef
          if rule.taSource
            ret.taSource = rule.taSource
          if rule.taIdent
            ret.taIdent = rule.taIdent
          if rule.taIdentRef
            ret.taIdentRef = rule.taIdentRef
    # 3. no inheritance
    # 4. Local attributes
    for objectName, attributeName of @attributes
      if $(tag).attr attributeName
        ret[objectName] = $(tag).attr attributeName
    # ...and return
    ret

  def: ->
    {
    }
