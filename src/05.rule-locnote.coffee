###
# Localization Note Rule.
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

class LocalizationNoteRule extends Rule
  constructor: ->
    super
    @RULE_NAME = 'its:locnoterule'
    @NAME = 'localizationNote'
    @attributes = {
      locNote: 'its-loc-note',
      locNoteRef: 'its-loc-note-ref',
      locNoteType: 'its-loc-note-type'
    }

  createLocalizationNote: (selector, locNoteType, locNote, ref = false) ->
    # TODO: Default values
    object = {}
    object.type = @NAME
    object.selector = selector
    if (ref)
      object.locNoteRef = locNote.trim()
    else
      object.locNote = locNote.trim()
    # It should be (description || alert)
    object.locNoteType = locNoteType
    object

  parse: (rule, content) ->
    if rule.tagName.toLowerCase() is @RULE_NAME
      # Only one of the following:
      #  'its:locnote' element.
      #  'locNotePointer' | 'locNoteRef' | 'locNoteRefPointer' attribute.
      if $(rule).attr('locNotePointer')
        xpath = new XPath content
        newRules = xpath.resolve $(rule).attr('selector'), $(rule).attr('locNotePointer')
        for newRule in newRules
          if newRule.result instanceof Attr then locNote = newRule.result.value else locNote = $(newRule.result).text()
          @addSelector @createLocalizationNote newRule.selector, $(rule).attr('locNoteType'), $(newRule.result).text()
      else if $(rule).attr('locNoteRef')
        @addSelector @createLocalizationNote $(rule).attr('selector'), $(rule).attr('locNoteType'), $(rule).attr('locNoteRef'), true
      else if $(rule).attr('locNoteRefPointer')
        xpath = new XPath content
        newRules = xpath.resolve $(rule).attr('selector'), $(rule).attr('locNoteRefPointer')
        for newRule in newRules
          if newRule.result instanceof Attr then locNote = newRule.result.value else locNote = $(newRule.result).text()
          @addSelector @createLocalizationNote newRule.selector, $(rule).attr('locNoteType'), locNote, true
      else
        if ($(rule).children().length > 0) and ($(rule).children()[0].tagName.toLowerCase() == 'its:locnote')
          @addSelector @createLocalizationNote $(rule).attr('selector'), $(rule).attr('locNoteType'), $(rule).children().text()

  apply: (tag) ->
    # Precedence order
    # 1. Default
    ret = @def()
    # 2. Rules in the schema
    xpath = new XPath tag
    for rule in @rules
      if rule.type == @NAME
        if xpath.process rule.selector
          if rule.locNoteRef
            ret.locNoteRef = rule.locNoteRef
          if rule.locNote
            ret.locNote = rule.locNote
          if rule.locNoteType
            ret.locNoteType = rule.locNoteType
    # 3. Rules in the document instance (inheritance)
    # TODO: Not implemented
    # 4. Local attributes
    for objectName, attributeName of @attributes
      if $(tag).attr attributeName
        ret[objectName] = $(tag).attr attributeName
    # ...and return
    ret

  def: ->
    {}

