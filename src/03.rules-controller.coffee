###
# Rules Controller.
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

class RulesController
  constructor: (supportedRules) ->
    @supportedRules = supportedRules

  setContent: (content) =>
    @content = content

  addLink: (link) ->
    if link.href
      @getFile link.href

  addXML: (xml) ->
    # TODO: Schema Validation?
    if xml.tagName and xml.tagName.toLowerCase() is "its:rules" and ($(xml).attr('version') is "2.0" or $(xml).attr('its:version') is "2.0")
      @parseXML xml
    else
      if xml.hasChildNodes
        for child in xml.childNodes
          @addXML child

  parseXML: (xml) ->
    if xml.hasChildNodes
      for child in xml.childNodes
        for rule in @supportedRules
          rule.parse child, @content, xml if child.nodeType is 1

  getFile: (file) ->
    request = $.ajax file, {async: false}
    request.success (data) =>
      @addXML data.childNodes[0]
    request.error (jqXHR, textStatus, errorThrown) ->
      $('body').append "AJAX Error: #{file} (#{errorThrown})."

  apply: (node, ruleName) ->
    ret = {}
    for rule in @supportedRules
      ret[rule.constructor.name] = rule.apply node
    if ruleName
      ret[ruleName]
    else
      ret
