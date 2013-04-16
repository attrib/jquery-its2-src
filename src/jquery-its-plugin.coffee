###
# jQuery plugin for ITS testing framework.
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

$.extend
  parseITS: (callback) ->
    window.XPath = XPath
    globalRules = [new TranslateRule(), new LocalizationNoteRule(), new StorageSizeRule(), new AllowedCharactersRule(), new ParamRule(), new AnnotatorsRef(), new TextAnalysisRule()]
    external_rules = $('link[rel="its-rules"]')
    window.rulesController = new RulesController(globalRules)
    window.rulesController.setContent $('html')
    if external_rules
      window.rulesController.addLink rule for rule in external_rules
    internal_rules = $('script[type="application/its+xml"]')
    if internal_rules
      for rule in internal_rules
        rule = $.parseXML rule.childNodes[0].data
        if rule
          window.rulesController.addXML rule.childNodes[0]
    if callback
      callback(window.rulesController)

  getITSData: (element) ->
    $(element).getITSData();

$.fn.extend
  getITSData: () ->
    values = []
    for element in this
      ruleValues = window.rulesController.apply element
      if ruleValues
        delete ruleValues.ParamRule
        value = {}
        for ruleName, rule of ruleValues
          value = $.extend value, rule
        values.push value
    if values.length == 1
      values.pop()
    else
      values

  getITSAnnotatorsRef: (searchRuleName) ->
    annotator = []
    for element in this
      ruleValues = window.rulesController.apply element, 'AnnotatorsRef'
      if ruleValues.annotatorsRefSplitted
        for ruleName, ruleAnnotator of ruleValues.annotatorsRefSplitted
          if searchRuleName.toLowerCase() == ruleName.toLowerCase()
            annotator.push ruleAnnotator
    annotator


$.extend $.expr[':'],
  translate: (a, i, m) ->
    query = if m[3] then m[3] else 'yes'
    value = window.rulesController.apply a, 'TranslateRule'
    return value.translate == ( query == 'yes' )

  locNote: (a, i, m) ->
    type = if m[3] then m[3] else 'any'
    value = window.rulesController.apply a, 'LocalizationNoteRule'
    if value.locNote
      if type == 'any'
        return true
      else if value.locNoteType == type
        return true
    return false

  storageSize: (a, i, m) ->
    query = if m[3] then m[3] else 'any'
    value = window.rulesController.apply a, 'StorageSizeRule'
    if value.storageSize
      if query == 'any'
        return true
      else
        query = query.split ','
        for test in query
          match = test.match /(size|encoding|linebreak):\s*(.*?)\s*$/
          switch match[1]
            when "size"
              match2 = match[2].match /([<>!=]*)\s*(\d*)/
              if match2[2]
                switch match2[1]
                  when "", "=", "=="
                    if value.storageSize != match2[2]
                      return false
                  when "!="
                    if value.storageSize == match2[2]
                      return false
                  when ">"
                    if value.storageSize <= match2[2]
                      return false
                  when "<"
                    if value.storageSize >= match2[2]
                      return false
                  else
                    return false
              else
                return false
            when "encoding"
              if value.storageEncoding != match[2]
                return false;
            when "linebreak"
              if value.lineBreakType != match[2]
                return false;
            else
              return false

        return true

    return false

  allowedCharacters: (a, i, m) ->
    query = if m[3] then m[3] else 'any'
    value = window.rulesController.apply a, 'AllowedCharactersRule'
    if value.allowedCharacters
      if query == 'any'
        return true
      else if value.allowedCharacters == query
        return true
    return false

  textAnalysis: (a, i, m) ->
    query = if m[3] then m[3] else 'any'
    value = window.rulesController.apply a, 'TextAnalysisRule'
    if (k for own k of value).length isnt 0
      if query is 'any'
        return true

      query = query.split ','
      for test in query
        match = test.match /(taConfidence|taClassRef|taSource|taIdent|taIdentRef):\s*(.*?)\s*$/
        switch(match[1])
          when "taConfidence"
            match2 = match[2].match /([<>!=]*)\s*([\d\.]*)/
            if match2[2]
              switch match2[1]
                when "", "=", "=="
                  if value.taConfidence != match2[2]
                    return false
                when "!="
                  if value.taConfidence == match2[2]
                    return false
                when ">"
                  if value.taConfidence <= match2[2]
                    return false
                when "<"
                  if value.taConfidence >= match2[2]
                    return false
                else
                  return false

          when "taClassRef"
            if value.taClassRef != match[2]
              return false

          when "taSource"
            if value.taSource != match[2]
              return false

          when "taIdent"
            if value.taIdent != match[2]
              return false

          when "taIdentRef"
            if value.taIdentRef != match[2]
              return false

          else
            return false

      return true

    return false
