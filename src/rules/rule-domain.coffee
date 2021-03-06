###
# Domain Rule.
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

class DomainRule extends Rule
  constructor: ->
    super
    @RULE_NAME = 'its:domainrule'
    @NAME = 'domains'

  createRule: (selector, domains) ->
    object = {}
    object.selector = selector
    object.type = @NAME
    object.domains = domains
    object

  parse: (rule, content) =>
    if rule.tagName.toLowerCase() is @RULE_NAME
      selector = $(rule).attr('selector')
      rules = []

      if $(rule).attr 'domainPointer'
        xpath = XPath.getInstance content
        newRules = xpath.resolve selector, $(rule).attr 'domainPointer'
        for newRule in newRules
          domains = ""
          for result in newRule.results
            domains += ", "
            domains += if newRule.result instanceof Attr then result.value else $(result).text()
          domains = domains.split ','
          domainArr = []
          for domain in domains
            # trim spaces and ", '
            domain = domain.replace(/^[\s'"]+|[\s'"]+$/g, '');
            if (domain != '')
              domainArr.push domain

          rules.push @createRule newRule.selector, domainArr

      else
        return

      if $(rule).attr 'domainMapping'
        mappings = $(rule).attr 'domainMapping'
        mappings = mappings.split ','
        mappingObj = {}

        for mapping in mappings
          # trim spaces
          mapping = mapping.replace(/^\s+|\s+$/g, '');
          regEx = /['"]?([\w ]+)['"]? ['"]?([\w ]+)['"]?/gi
          if (mapping != '' and matches = regEx.exec mapping)
            mappingObj[matches[1]] = matches[2]

        for ruleObject in rules
          for search, replace of mappingObj
            key = $.inArray search, ruleObject.domains
            if key != -1
              ruleObject.domains[key] = replace

      for ruleObject in rules
        ruleObject.domains = ruleObject.domains.unique()
        @addSelector ruleObject

  apply: (tag) =>
    # Precedence order
    # 1. Default
    ret = @def()
    # 2. Rules in the schema
    @applyRules ret, tag, ['domains', 'domainMapping']
    # 3. Rules in the document instance (inheritance)
    @applyInherit ret, tag, true
    # 4. No Local Attributes
    # ...and return
    ret

  def: ->
    { }

  jQSelector:
    name: 'domain'
    callback: (a, i, m) ->
      query = if m[3] then m[3] else 'any'
      value = window.rulesController.apply a, 'DomainRule'
      if (k for own k of value).length isnt 0
        if query is 'any'
          return true
        else if not value.domains? or value.domains.indexOf(query) == -1
          return false
        else
          return true

      return false


Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output
