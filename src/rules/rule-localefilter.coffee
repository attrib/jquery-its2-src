###
# Locale Filter.
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

class LocaleFilterRule extends Rule
  constructor: ->
    super
    @RULE_NAME = 'its:localefilterrule'
    @NAME = 'localeFilter'
    @attributes = {
      localeFilterList: 'its-locale-filter-list',
      localeFilterType: 'its-locale-filter-type',
    }

  parse: (rule, content) ->
    if rule.tagName.toLowerCase() is @RULE_NAME
      object = {}
      object.selector = $(rule).attr 'selector'
      object.type = @NAME
      #one of following
      if $(rule).attr 'localeFilterList'
        object.localeFilterList = $(rule).attr 'localeFilterList'
      else
        return
      #optional
      if $(rule).attr 'localeFilterType'
        object.localeFilterType = $(rule).attr 'localeFilterType'

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
          if rule.localeFilterList
            ret.localeFilterList = rule.localeFilterList
          if rule.localeFilterType
            ret.localeFilterType = rule.localeFilterType
          @store tag, ret
    # 3. Rules in the document instance (inheritance)
    if tag instanceof Attr
      value = @inherited tag.ownerElement
    else
      value = @inherited tag
    if value instanceof Object then ret = value
    # 4. Local attributes
    for objectName, attributeName of @attributes
      if $(tag).attr(attributeName) != undefined
        ret[objectName] = $(tag).attr attributeName
        @store tag, ret
    # Conformance
    if ret.localeFilterType?
      ret.localeFilterType = ret.localeFilterType.toLowerCase();
    # ...and return
    ret

  def: ->
    {
      localeFilterList: '*',
      localeFilterType: 'include',
    }
