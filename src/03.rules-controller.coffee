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

  addXML: (xml, file=null) ->
    # TODO: Schema Validation?
    if xml.tagName and xml.tagName.toLowerCase() is "its:rules" and ($(xml).attr('version') is "2.0" or $(xml).attr('its:version') is "2.0")
      @parseXML xml
    else
      # its no rules tag, maybe its a standoff markup, ask the rules, if the can handle it
      found = false
      for rule in @supportedRules
        found = found or rule.standoffMarkupXML xml, @content, file if xml.nodeType is 1

      # nobody can handle it, go deeper and test again, because its not defined where rules or standoff markup has to be
      if !found
        if xml.hasChildNodes
          for child in xml.childNodes
            @addXML child, file

  parseXML: (xml) ->
    if xml.hasChildNodes
      for child in xml.childNodes
        for rule in @supportedRules
          rule.parse child, @content, xml if child.nodeType is 1

  getFile: (file) ->
    request = $.ajax file, {async: false}
    request.success (data) =>
      # XML Content
      if data.childNodes?
        @addXML data.childNodes[0], file
      # HTML Content
      else
        for element in $(data)
          if element.nodeType? and element.nodeType is 1 and element.tagName? and element.tagName.toLowerCase() == 'script'
            if $(element).attr('type') == "application/its+xml"
              xml = $.parseXML element.childNodes[0].data
              if xml
                @addXML xml, file
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

  getStandoffMarkup: () ->
    for rule in @supportedRules
      rule.standoffMarkup @content

