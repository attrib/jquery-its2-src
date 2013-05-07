###
# Elements Within Text.
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

class ElementsWithinTextRule extends Rule

  constructor: ->
    super
    @RULE_NAME = 'its:withintextrule'
    @NAME = 'elementsWithinRules'
    @attributes = {
      withinText: 'its-within-text',
    }

  parse: (rule, content) ->
    if rule.tagName.toLowerCase() is @RULE_NAME
      object = {}
      object.selector = $(rule).attr 'selector'
      object.type = @NAME

      if $(rule).attr 'withinText'
        object.withinText = $(rule).attr 'withinText'

      else
        return

      @addSelector object

  apply: (tag) =>
    # Precedence order
    # 1. Default
    if tag instanceof Attr
      return {}
    ret = @def(tag)
    # 2. Rules in the schema
    xpath = new XPath tag
    for rule in @rules
      if rule.type = @NAME
        if xpath.process rule.selector
          if rule.withinText
            ret.withinText = rule.withinText
    # 3. no inheritance
    # 4. Local attributes
    for objectName, attributeName of @attributes
      if $(tag).attr attributeName
        ret[objectName] = $(tag).attr attributeName
    # Conformance
    if ret.withinText?
      ret.withinText = ret.withinText.toLowerCase()
      if not ret.withinText in ['yes', 'nested', 'no']
        ret.withinText = @def(tag)
    # ...and return
    ret

  def: (tag) ->
#    if tag instanceof Attr or not tag.nodeName.toLowerCase() in ['a', 'abbr', 'area', 'audio', 'b', 'bdi', 'bdo', 'br', 'button', 'canvas', 'cite', 'code', 'command', 'datalist', 'del', 'dfn', 'em', 'embed', 'i', 'iframe', 'img', 'input', 'ins', 'kbd', 'keygen', 'label', 'map', 'mark', 'math', 'meter', 'noscript', 'object', 'output', 'progress', 'q', 'ruby', 's', 'samp', 'script', 'select', 'small', 'span', 'strong', 'sub', 'sup', 'svg', 'textarea', 'time', 'u', 'var', 'video', 'wbr']
#      {
#        withinText: 'no'
#      }
#    else
#      {
#        withinText: 'yes'
#      }
    {
      withinText: 'no'
    }
