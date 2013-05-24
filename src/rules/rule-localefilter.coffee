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
        object.localeFilterType = @normalizeString $(rule).attr 'localeFilterType'

      @addSelector object

  apply: (tag) =>
    # Precedence order
    # 1. Default
    ret = @def()
    # 2. Rules in the schema
    @applyRules ret, tag, ['localeFilterList', 'localeFilterType']
    # 3. Rules in the document instance (inheritance)
    @applyInherit ret, tag, true
    # 4. Local attributes
    @applyAttributes ret, tag
    # Conformance
    if ret.localeFilterType?
      ret.localeFilterType = @normalizeString ret.localeFilterType;
    # ...and return
    ret

  def: ->
    {
      localeFilterList: '*',
      localeFilterType: 'include',
    }
