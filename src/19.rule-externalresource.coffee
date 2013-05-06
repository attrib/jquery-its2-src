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

  parse: (rule, content) ->
    if rule.tagName.toLowerCase() is @RULE_NAME
      rules = []
      object = {}
      object.selector = $(rule).attr 'selector'
      object.type = @NAME
      # at least one of the following
      if $(rule).attr 'externalResourceRefPointer'
        xpath = new XPath content
        newRules = xpath.resolve object.selector, $(rule).attr 'externalResourceRefPointer'
        for newRule in newRules
          newObject = $.extend(true, {}, object);
          if newRule.result instanceof Attr then newObject.externalResourceRef = newRule.result.value else newObject.externalResourceRef = $(newRule.result).text()
          newObject.selector = newRule.selector
          rules.push newObject

      else
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
          if rule.externalResourceRef
            ret.externalResourceRef = rule.externalResourceRef
    # 3. no inheritance
    # 4. no local attributes
    # ...and return
    ret

  def: ->
    {
    }

