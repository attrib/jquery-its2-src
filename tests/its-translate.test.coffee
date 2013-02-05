###
# Test Class.
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

TEST_RULE_NAME = 'TranslateRule'
#TEST_RULE_NAME = 'LocalizationNoteRule'
#TEST_RULE_NAME = 'StorageSizeRule'
#TEST_RULE_NAME = 'AllowedCharactersRule'

$ = jQuery

$ ->
  formatOutput = (value) ->
    if value instanceof Object
      outputValue = ""
      for key, val of value
        if key == 'translate'
          val = if val then 'yes' else 'no'
        val = val.replace /\n/g, ' '
        outputValue += "\t#{key}=\"#{val}\""
    else
      outputValue = value
    if outputValue == 'default' then '' else outputValue

  $.parseITS (rules) ->
    string = ''
    for tag in $('*')
      if $(tag).attr('data-test') == 'mlw-lt'
        continue
      xpath = new XPath(tag)
      value = rules.apply(tag)
      string += "#{xpath.path}#{formatOutput value[TEST_RULE_NAME]}\n"
      if tag.attributes.length != 0
        tmp = []
        for attribute in tag.attributes
          attributeName = attribute.nodeName || attribute.name
          value = rules.apply attribute
          tmp.push
            str:  "#{xpath.path}/@#{attributeName}#{formatOutput value[TEST_RULE_NAME]}\n",
            name: attributeName
        tmp = tmp.sort (a, b) ->
          return +1 if a.name > b.name
          return -1 if a.name < b.name
          return 0
        for obj in tmp
          string += obj.str
    $('<textarea>' + string + '</textarea>').css('width', '100%').css('height', '500px').appendTo('body');
