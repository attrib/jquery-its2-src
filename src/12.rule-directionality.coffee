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

  parse: (rule, content) =>
    if rule.tagName.toLowerCase() is @RULE_NAME
      object = {}
      object.selector = $(rule).attr('selector')
      object.type = @NAME
      object.dir = $(rule).attr(@NAME)
      @addSelector object

  apply: (tag) =>
    # Precedence order
    # 1. Default
    ret = @def()
    # 2. Rules in the schema
    xpath = new XPath tag
    for rule in @rules
      if rule.type = @NAME
        if xpath.process rule.selector
          ret = { dir: rule.dir }
          @store tag, ret
    # 3. Rules in the document instance (inheritance)
    if tag instanceof Attr
      value = @inherited tag.ownerElement
    else
      value = @inherited tag
    if value instanceof Object then ret = value
    # 4. Local attributes
    if (!(tag instanceof Attr) and tag.hasAttribute(@NAME) and $(tag).attr(@NAME) != undefined)
      ret = { dir: $(tag).attr(@NAME) }
      @store tag, ret
    # ...and return
    ret

  def: ->
    { dir: 'ltr' }
