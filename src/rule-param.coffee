###
# Param Rule.
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

class ParamRule extends Rule

  constructor: ->
    super
    @RULE_NAME = 'its:param'
    @NAME = 'param'

  parse: (rule, content, xml) ->
    if rule.tagName.toLowerCase() is @RULE_NAME
      paramName =  $(rule).attr 'name'
      exp = new RegExp "\\$#{paramName}", 'g'
      paramValue = "'#{rule.childNodes[0].nodeValue}'";
      @replaceParam(exp, paramValue, xml)

  replaceParam: (regExp, paramValue, xml) ->
    for child in xml.childNodes
      if child.tagName and child.tagName.toLowerCase() != @RULE_NAME
        for attribute in child.attributes
          attribute.nodeValue = attribute.nodeValue.replace regExp, paramValue
        if child.hasChildNodes
          @replaceParam regExp, paramValue, child
        if child.nodeValue
          child.nodeValue = child.nodeValue.replace regExp, paramValue

  apply: (node) ->
    {}

  def: ->
    {}
