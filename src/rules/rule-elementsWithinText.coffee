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

  createRule: (selector, withinText) ->
    object = {}
    object.selector = selector
    object.type = @NAME
    object.withinText = @normalizeString withinText
    object

  parse: (rule, content) ->
    if rule.tagName.toLowerCase() is @RULE_NAME
      if $(rule).attr('withinText') and $(rule).attr('selector')
        @addSelector @createRule $(rule).attr('selector'), $(rule).attr('withinText')


  apply: (tag) =>
    # Precedence order
    # 1. Default
    if tag instanceof Attr
      return {}
    ret = @def(tag)
    # 2. Rules in the schema
    @applyRules ret, tag, ['withinText']
    # 3. no inheritance
    # 4. Local attributes
    @applyAttributes ret, tag
    # Conformance
    if ret.withinText?
      ret.withinText = @normalizeString ret.withinText
      if not ret.withinText in ['yes', 'nested', 'no']
        ret.withinText = @def(tag)
    # ...and return
    ret

  def: (tag) ->
    if $(tag).parents('body').length > 0
      if tag.nodeName.toLowerCase() in ['a', 'abbr', 'area', 'audio', 'b', 'bdi', 'bdo',
        'br', 'button', 'canvas', 'cite', 'code', 'command', 'datalist', 'del', 'dfn',
        'em', 'embed', 'i', 'img', 'input', 'ins', 'kbd', 'keygen', 'label', 'map', 'mark',
        'math', 'meter', 'object', 'output', 'progress', 'q', 'ruby', 's', 'samp', 'select',
        'small', 'span', 'strong', 'sub', 'sup', 'svg', 'time', 'u', 'var', 'video', 'wbr']
        return {
          withinText: 'yes'
        }
      else if tag.nodeName.toLowerCase() in ['iframe', 'noscript', 'script', 'textarea']
        return {
          withinText: 'nested'
        }
    return {
      withinText: 'no'
    }
