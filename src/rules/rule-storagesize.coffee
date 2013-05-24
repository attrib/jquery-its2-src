###
# Storage Size Rule.
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

class StorageSizeRule extends Rule

  constructor: ->
    super
    @RULE_NAME = 'its:storagesizerule'
    @NAME = 'storageSize'
    @attributes = {
      storageSize: 'its-storage-size',
      storageEncoding: 'its-storage-encoding',
      lineBreakType: 'its-line-break-type'
    }

  createRule: (selector, storageSize, storageEncoding = null) ->
    object = {}
    object.selector = selector
    object.type = @NAME
    object.storageSize = storageSize
    if storageEncoding?
      object.storageEncoding = storageEncoding
    object

  parse: (rule, content) ->
    if rule.tagName.toLowerCase() is @RULE_NAME
      rules = []
      selector = $(rule).attr 'selector'
      #one of following
      if $(rule).attr 'storageSize'
        rules.push @createRule selector, $(rule).attr 'storageSize'
      else if $(rule).attr 'storageSizePointer'
        xpath = new XPath content
        newRules = xpath.resolve selector, $(rule).attr 'storageSizePointer'
        for newRule in newRules
          if newRule.result instanceof Attr then storageSize = newRule.result.value else storageSize = $(newRule.result).text()
          rules.push @createRule newRule.selector, storageSize
      else
        return
      #one or none of following
      if $(rule).attr 'storageEncoding'
        for ruleObject in rules
          ruleObject.storageEncoding = $(rule).attr 'storageEncoding'
      else if $(rule).attr 'storageEncodingPointer'
        xpath = new XPath content
        newRules = xpath.resolve selector, $(rule).attr 'storageEncodingPointer'
        for newRule in newRules
          if newRule.result instanceof Attr then storageEncoding = newRule.result.value else storageEncoding = $(newRule.result).text()
          rules.push @createRule newRule.selector, storageSize, storageEncoding
          for ruleObject in rules
            ruleObject.storageEncoding = storageEncoding
      else
        for ruleObject in rules
          ruleObject.storageEncoding = 'UTF-8'

      #optional
      for ruleObject in rules
        if $(rule).attr 'lineBreakType'
          ruleObject.lineBreakType = @normalizeString $(rule).attr 'lineBreakType'
        else
          ruleObject.lineBreakType = 'lf'

      for ruleObject in rules
        @addSelector ruleObject

  apply: (tag) =>
    # Precedence order
    # 1. Default
    ret = @def()
    # 2. Rules in the schema
    @applyRules ret, tag, ['storageSize', 'storageEncoding', 'lineBreakType']
    # 3. Rules in the document instance
    # no inheritance
    # 4. Local attributes
    @applyAttributes ret, tag
    # ...and return
    if ret.lineBreakType?
      ret.lineBreakType = @normalizeString ret.lineBreakType
    if ret.storageSize == null then {} else ret

  def: ->
    {
      lineBreakType: 'lf',
      storageEncoding: 'UTF-8',
      storageSize: null
    }
