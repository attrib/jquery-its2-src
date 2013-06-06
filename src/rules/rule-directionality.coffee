###
# Directionality Rule.
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

class DirectionalityRule extends Rule
  constructor: ->
    super
    @RULE_NAME = 'its:dirrule'
    @NAME = 'dir'

  createRule: (selector, dir) ->
    object = {}
    object.selector = selector
    object.type = @NAME
    object.dir = dir
    object

  parse: (rule, content) =>
    if rule.tagName.toLowerCase() is @RULE_NAME
      @addSelector @createRule $(rule).attr('selector'), $(rule).attr(@NAME)

  apply: (tag) =>
    # Precedence order
    # 1. Default
    ret = @def()
    # 2. Rules in the schema
    @applyRules ret, tag, ['dir']
    # 3. Rules in the document instance (inheritance)
    @applyInherit ret, tag, true
    # 4. Local attributes
    if (!(tag instanceof Attr) and tag.hasAttribute(@NAME) and $(tag).attr(@NAME) != undefined)
      ret = { dir: $(tag).attr(@NAME) }
      @store tag, ret
    # ...and return
    ret

  def: ->
    { dir: 'ltr' }

  jQSelector:
    name: 'dir'
    callback: (a, i, m) ->
      query = if m[3] then m[3] else 'ltr'
      value = window.rulesController.apply a, 'DirectionalityRule'
      if query.charAt(0) is '!'
        query = query.substr(1)
        return value.dir != query
      return value.dir == query
