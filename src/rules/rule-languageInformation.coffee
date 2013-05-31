###
# Language Information.
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

class LanguageInformationRule extends Rule

  constructor: ->
    super
    @RULE_NAME = 'its:langrule'
    @NAME = 'languageInformation'

  createRule: (selector, lang) ->
    object = {}
    object.selector = selector
    object.type = @NAME
    object.lang = lang
    object

  parse: (rule, content) ->
    if rule.tagName.toLowerCase() is @RULE_NAME
      selector = $(rule).attr 'selector'
      # at least one of the following
      if $(rule).attr 'langPointer'
        xpath = XPath.getInstance content
        newRules = xpath.resolve selector, $(rule).attr 'langPointer'
        for newRule in newRules
          if newRule.result instanceof Attr then lang = newRule.result.value else lang = $(newRule.result).text()
          @addSelector @createRule(newRule.selector, lang)

  apply: (tag) =>
    # Precedence order
    # 1. Default
    ret = @def()
    # 2. Rules in the schema
    @applyRules ret, tag, ['lang']
    # 3. Rules in the document instance (inheritance)
    @applyInherit ret, tag, true
    # 4. Local attributes
    store = false
    if (!(tag instanceof Attr) and tag.hasAttribute('xml:lang') and $(tag).attr('xml:lang') != undefined)
      ret.lang = $(tag).attr 'xml:lang'
      store = true
    if (!(tag instanceof Attr) and tag.hasAttribute('lang') and $(tag).attr('lang') != undefined)
      ret.lang = $(tag).attr 'lang'
      store = true
    if store
      @store tag, ret
    # ...and return
    ret

  def: ->
    {
    }

  jQSelector:
    name: 'lang'
    callback: (a, i, m) ->
      query = if m[3] then m[3] else 'any'
      value = window.rulesController.apply a, 'LanguageInformationRule'
      if (k for own k of value).length isnt 0
        invert = false
        if query.charAt(0) is '!'
          invert = true
          query = query.substr(1)
        if query is 'any'
          return true
        else if not invert and (not value.lang? or value.lang != query)
          return false
        else if invert and (not value.lang? or value.lang == query)
          return false
        else
          return true

      return false
