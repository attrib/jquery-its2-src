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

  parse: (rule, content) ->
    if rule.tagName.toLowerCase() is @RULE_NAME
      object = {}
      object.selector = $(rule).attr 'selector'
      object.type = @NAME
      #one of following
      if $(rule).attr 'allowedCharacters'
        object.allowedCharacters = $(rule).attr 'allowedCharacters'
        @addSelector object
      else if $(rule).attr 'allowedCharactersPointer'
        allowedCharactersPointer = $(rule).attr 'allowedCharactersPointer'
        xpath = new XPath content
        newRules = xpath.resolve object.selector, $(rule).attr('allowedCharactersPointer')
        for newRule in newRules
          newObject = $.extend(true, {}, object);
          if newRule.result instanceof Attr then newObject.allowedCharacters = newRule.result.value else newObject.allowedCharacters = $(newRule.result).text()
          newObject.selector = newRule.selector
          @addSelector newObject
      else
        return

  apply: (tag) =>
    # Precedence order
    # 1. Default
    ret = @def()
    # 2. Rules in the schema
    xpath = new XPath tag
    for rule in @rules
      if rule.type = @NAME
        if xpath.process rule.selector
          if rule.allowedCharacters
            ret.allowedCharacters = rule.allowedCharacters
    # 3. Rules in the document instance
    # TODO: Not implemented
    # inheritance
    # 4. Local attributes
    for objectName, attributeName of @attributes
      if $(tag).attr attributeName
        ret[objectName] = $(tag).attr attributeName
    # ...and return
    if ret.allowedCharacters == '' then {} else ret

  def: ->
    {
      allowedCharacters: '',
    }
