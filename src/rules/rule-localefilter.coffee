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

  jQSelector:
    name: 'localeFilter'
    callback: (a, i, m) ->
      query = if m[3] then m[3] else 'any'
      value = window.rulesController.apply a, 'LocaleFilterRule'
      if value.localeFilterList?
        if query == 'any'
          # don't return default
          if value.localeFilterList == "*" and value.localeFilterType == 'include'
            return false
          else
            return true

        regExp = /(localeFilterList|localeFilterType|lang):[\s]?(["']?)([\w\- ,\*]+)\2(,|$)/gi
        while match = regExp.exec(query)
          switch(match[1])
            when "localeFilterList"
              if value.localeFilterList != match[3]
                return false

            when "localeFilterType"
              if value.localeFilterType != match[3]
                return false

            when "lang"
              match[3] = match[3].toLowerCase()
              lang = match[3];
              # removing one case
              if value.localeFilterList == '*' and value.localeFilterType == 'include'
                return false
              if value.localeFilterList == '' and value.localeFilterType == 'exclude'
                value.localeFilterList = '*'
                value.localeFilterType = 'include'
              value.localeFilterList = value.localeFilterList.toLowerCase()
              if (lang == '*')
                if value.localeFilterType != 'include' or value.localeFilterList != '*'
                  return false
              else
                lang = lang.split '-'
                if lang.length != 2
                  return false
                # include or exclude all languages
                if value.localeFilterList == '*'
                  if value.localeFilterType != 'include'
                    return false
                  # search language is in the language list
                else if value.localeFilterList.indexOf(match[3]) != -1
                  if value.localeFilterType != 'include'
                    return false
                  # language is included or excluded
                else if value.localeFilterList.indexOf("#{lang[0]}-*") != -1
                  if value.localeFilterType != 'include'
                    return false
                  # country is included or excluded
                else if value.localeFilterList.indexOf("*-#{lang[1]}") != -1
                  if value.localeFilterType != 'include'
                    return false
                else if lang[0] == '*' and value.localeFilterList.indexOf("-#{lang[1]}") != -1
                  if value.localeFilterType != 'include'
                    return false
                else if lang[1] == '*' and value.localeFilterList.indexOf("#{lang[0]}-") != -1
                  if value.localeFilterType != 'include'
                    return false
                else if value.localeFilterType != 'include'
                  # do nothing here
                else
                  return false

            else
              return false

        return true

      return false
