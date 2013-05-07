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

$ = jQuery

formatVal = (value) ->
  if typeof value is "boolean"
    value = if value then 'yes' else 'no'
  if typeof value is "string"
    value = value.replace /\n/g, ' '
  value

formatOutput = (value) ->
  if value instanceof Object
    outputValue = []
    for key, val of value
      if key == 'annotatorsRef'
        annotators = []
        for attribute, annotator of val
          attribute = attribute.charAt(0).toLowerCase() + attribute.slice(1)
          attribute = attribute.replace(/([A-Z])/g, "-$1").toLowerCase()
          annotators.push attribute + "|" + annotator
        val = annotators.sort().join(" ")
        outputValue.push "\t#{key}=\"#{formatVal val}\""
      else if key == 'domains'
        outputValue.push "\t#{key}=\"#{val.join(", ")}\""
      else if key == 'locQualityIssues' or key == 'provenanceRecords'
        issues = ''
        for count, issueObj of val
          count++
          issue = []
          for k, v of issueObj
            issue.push "\t#{k}[#{count}]=\"#{formatVal v}\""
          issues += issue.sort().join ''
      else
        outputValue.push "\t#{key}=\"#{formatVal val}\""
    outputValue.sort (a,b) ->
      return +1 if a > b
      return -1 if a < b
      return 0
    if issues?
      outputValue.push issues
    return outputValue.join ''
  else
    outputValue = value
  if outputValue == 'default' then '' else outputValue

##
# Function to remove default values, except when we are in the specific test folder
##
deleteValuesDependingOnTests = (value) ->
  if document.URL.search(/translate\/html\//) == -1
    delete value.translate
  if document.URL.search(/terminology\/html\//) == -1
    delete value.term
  if document.URL.search(/directionality\/html\//) == -1
    delete value.dir
  if document.URL.search(/localefilter\/html\//) == -1
    delete value.localeFilterList
    delete value.localeFilterType
  if document.URL.search(/idvalue\/html\//) == -1
    delete value.idValue
  if document.URL.search(/elementswithintext\/html\//) == -1
    delete value.withinText
  delete value.target
  value

$ ->
  window.testFile()

# needed for call from phantomJS as window function
window.testFile = () ->
  $.parseITS () ->
    string = ''
    for tag in $('*')
      if $(tag).attr('data-test') == 'mlw-lt'
        continue
      xpath = new XPath(tag)
      value = deleteValuesDependingOnTests $.getITSData tag
      string += "#{xpath.path}#{formatOutput value}\n"
      if tag.attributes.length != 0
        tmp = []
        for attribute in tag.attributes
          attributeName = attribute.nodeName || attribute.name
          value = deleteValuesDependingOnTests $.getITSData attribute
          tmp.push
            str:  "#{xpath.path}/@#{attributeName}#{formatOutput value}\n",
            name: attributeName
        tmp = tmp.sort (a, b) ->
          return +1 if a.name > b.name
          return -1 if a.name < b.name
          return 0
        for obj in tmp
          string += obj.str
    $('<textarea id="its-result">' + string + '</textarea>').css('width', '100%').css('height', '500px').appendTo('body');
