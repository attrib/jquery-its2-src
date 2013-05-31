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

  createRule: (selector, locNoteType, locNote, ref = false) ->
    object = {}
    object.type = @NAME
    object.selector = selector
    if (ref)
      object.locNoteRef = locNote.trim()
    else
      object.locNote = locNote.trim()
    # It should be (description || alert)
    object.locNoteType = @normalizeString locNoteType
    object

  parse: (rule, content) ->
    if rule.tagName.toLowerCase() is @RULE_NAME
      # Only one of the following:
      #  'its:locnote' element.
      #  'locNotePointer' | 'locNoteRef' | 'locNoteRefPointer' attribute.
      if $(rule).attr('locNotePointer')
        xpath = XPath.getInstance content
        newRules = xpath.resolve $(rule).attr('selector'), $(rule).attr('locNotePointer')
        for newRule in newRules
          if newRule.result instanceof Attr then locNote = newRule.result.value else locNote = $(newRule.result).text()
          @addSelector @createRule newRule.selector, $(rule).attr('locNoteType'), $(newRule.result).text()
      else if $(rule).attr('locNoteRef')
        @addSelector @createRule $(rule).attr('selector'), $(rule).attr('locNoteType'), $(rule).attr('locNoteRef'), true
      else if $(rule).attr('locNoteRefPointer')
        xpath = XPath.getInstance content
        newRules = xpath.resolve $(rule).attr('selector'), $(rule).attr('locNoteRefPointer')
        for newRule in newRules
          if newRule.result instanceof Attr then locNote = newRule.result.value else locNote = $(newRule.result).text()
          @addSelector @createRule newRule.selector, $(rule).attr('locNoteType'), locNote, true
      else
        if ($(rule).children().length > 0) and ($(rule).children()[0].tagName.toLowerCase() == 'its:locnote')
          @addSelector @createRule $(rule).attr('selector'), $(rule).attr('locNoteType'), $(rule).children().text()

  apply: (tag) ->
    # Precedence order
    # 1. Default
    ret = @def()
    # 2. Rules in the schema
    @applyRules ret, tag, ['locNoteRef', 'locNote', 'locNoteType']
    # 3. Rules in the document instance (inheritance)
    @applyInherit ret, tag
    # 4. Local attributes
    @applyAttributes ret, tag
    # ...and return
    if ret.locNoteType?
      ret.locNoteType = @normalizeString ret.locNoteType
    ret

  def: ->
    {}

  jQSelector:
    name: 'locNote'
    callback: (a, i, m) ->
      type = if m[3] then m[3] else 'any'
      value = window.rulesController.apply a, 'LocalizationNoteRule'
      if value.locNote
        if type == 'any'
          return true
        else if value.locNoteType == type
          return true
      return false
