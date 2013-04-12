###
# Translate Rule.
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

class TranslateRule extends Rule
  constructor: ->
    super
    @RULE_NAME = 'its:translaterule'
    @NAME = 'translate'

  parse: (rule, content) =>
    if rule.tagName.toLowerCase() is @RULE_NAME
      object = {}
      object.selector = $(rule).attr('selector')
      object.type = @NAME
      object.translate = normalize $(rule).attr(@NAME)
      @addSelector object

  apply: (tag) =>
    # Precedence order
    # 1. Default
    ret = if tag instanceof Attr then @defAttr() else @def()
    # 2. Rules in the schema
    xpath = new XPath tag
    for rule in @rules
      if rule.type = @NAME
        if xpath.process rule.selector
          ret = { translate: rule.translate }
          @store tag, ret
    # 3. Rules in the document instance (inheritance)
    value = @inherited tag
    if value instanceof Object then ret = value
    # 4. Local attributes
    if (!(tag instanceof Attr) and tag.hasAttribute(@NAME) and $(tag).attr(@NAME) != undefined)
      ret = { translate: normalize $(tag).attr(@NAME) }
    # ...and return
    ret

  def: ->
    { translate: true }

  defAttr: ->
    { translate: false }

  normalize = (translateString) ->
    if typeof translateString == "boolean"
      return translateString
    # Trim the string and lowecase.
    translateString = translateString.replace(/^\s+|\s+$/g, '').toLowerCase();
    if translateString == "yes"
      return true
    else
      return false
