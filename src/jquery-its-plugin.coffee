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
    globalRules = [new TranslateRule(), new LocalizationNoteRule(), new StorageSizeRule(), new AllowedCharactersRule(),
      new ParamRule(), new AnnotatorsRef(), new TextAnalysisRule(), new TerminologyRule(), new DirectionalityRule(),
      new DomainRule(), new LocaleFilterRule(), new LocalizationQualityIssueRule(), new LocalizationQualityRatingRule(),
      new MTConfidenceRule()]
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
    window.rulesController.getStandoffMarkup()
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

  dir: (a, i, m) ->
    query = if m[3] then m[3] else 'ltr'
    value = window.rulesController.apply a, 'DirectionalityRule'
    return value.dir == query

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
              match2[2] = parseFloat match2[2]
              if not value.storageSize?
                return false
              value.storageSize = parseFloat value.storageSize
              if not isNaN(match2[2]) and not isNaN(value.storageSize)
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
            match2[2] = parseFloat match2[2]
            if not value.taConfidence?
              return false
            value.taConfidence = parseFloat value.taConfidence
            if not isNaN(match2[2]) and not isNaN(value.taConfidence)
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

  terminology: (a, i, m) ->
    query = if m[3] then m[3] else 'any'
    value = window.rulesController.apply a, 'TerminologyRule'
    if (k for own k of value).length isnt 0
      if query is 'any'
        return value.term

      query = query.split ','
      for test in query
        match = test.match /(term|termInfoRef|termConfidence):\s*(.*?)\s*$/
        switch(match[1])
          when "termConfidence"
            match2 = match[2].match /([<>!=]*)\s*([\d\.]*)/
            match2[2] = parseFloat match2[2]
            if not value.termConfidence?
              return false
            value.termConfidence = parseFloat value.termConfidence
            if not isNaN(match2[2]) and not isNaN(value.termConfidence)
              switch match2[1]
                when "", "=", "=="
                  if value.termConfidence != match2[2]
                    return false
                when "!="
                  if value.termConfidence == match2[2]
                    return false
                when ">"
                  if value.termConfidence <= match2[2]
                    return false
                when "<"
                  if value.termConfidence >= match2[2]
                    return false
                else
                  return false
            else
              return false

          when "termInfoRef"
            if value.termInfoRef != match[2]
              return false

          when "term"
            if (value.term and "no" == match[2]) or (!value.term and "yes" == match[2])
              return false

          else
            return false

      return true

    return false

  localeFilter: (a, i, m) ->
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
              else if value.localeFilterType != 'include'
                # do nothing here
              else
                return false

          else
            return false

      return true

    return false

  locQualityIssue: (a, i, m) ->
    query = if m[3] then m[3] else 'any'
    value = window.rulesController.apply a, 'LocalizationQualityIssueRule'
    if (k for own k of value).length isnt 0
      if query == 'any'
          return true

      matchQuery = (value, type, query) ->
        switch(type)
          when "locQualityIssueComment"
            if value.locQualityIssueComment != query
              return false

          when "locQualityIssueEnabled"
            return value.locQualityIssueEnabled == ( query == 'yes' )

          when "locQualityIssueProfileRef"
            if value.locQualityIssueProfileRef != query
              return false

          when "locQualityIssueType"
            if value.locQualityIssueType != query
              return false

          when "locQualityIssuesRef"
            if value.locQualityIssuesRef != query
              return false

          when "locQualityIssueSeverity"
            match2 = query.match /([<>!=]*)\s*([\d\.]*)/
            match2[2] = parseFloat match2[2]
            if not value.locQualityIssueSeverity?
              return false
            value.locQualityIssueSeverity = parseFloat value.locQualityIssueSeverity
            if not isNaN(match2[2]) and not isNaN(value.locQualityIssueSeverity)
              switch match2[1]
                when "", "=", "=="
                  if value.locQualityIssueSeverity != match2[2]
                    return false
                when "!="
                  if value.locQualityIssueSeverity == match2[2]
                    return false
                when ">"
                  if value.locQualityIssueSeverity <= match2[2]
                    return false
                when "<"
                  if value.locQualityIssueSeverity >= match2[2]
                    return false
                else
                  return false
            else
              return false

          else
            return false

      regExp = /(locQualityIssueComment|locQualityIssueEnabled|locQualityIssueProfileRef|locQualityIssueSeverity|locQualityIssueType|locQualityIssuesRef):[\s]?(["']?)(.+)\2(,|$)/gi
      while match = regExp.exec(query)
        ret = matchQuery value, match[1], match[3]
        if ret?
          if !ret and value.locQualityIssues?
            foundOne = false
            for issue in value.locQualityIssues
              ret = matchQuery issue, match[1], match[3]
              if not ret?
                foundOne = true
            return foundOne
          else
            return ret

      return true

    return false

  locQualityRating: (a, i, m) ->
    query = if m[3] then m[3] else 'any'
    value = window.rulesController.apply a, 'LocalizationQualityRatingRule'
    if (k for own k of value).length isnt 0
      if query is 'any'
        return true

      query = query.split ','
      for test in query
        match = test.match /(locQualityRatingScore|locQualityRatingScoreThreshold|locQualityRatingVote|locQualityRatingVoteThreshold|locQualityRatingProfileRef):\s*(.*?)\s*$/
        switch(match[1])
          when "locQualityRatingProfileRef"
            if value.locQualityRatingProfileRef != match[2]
              return false

          else
            match2 = match[2].match /([<>!=]*)\s*([-\d\.]*)/
            match2[2] = parseFloat match2[2]
            if not isNaN(match2[2]) and value[match[1]]? and not isNaN(value[match[1]])
              switch match2[1]
                when "", "=", "=="
                  if value[match[1]] != match2[2]
                    return false
                when "!="
                  if value[match[1]] == match2[2]
                    return false
                when ">"
                  if value[match[1]] <= match2[2]
                    return false
                when "<"
                  if value[match[1]] >= match2[2]
                    return false
                else
                  return false
            else
              return false

      return true

    return false

  mtConfidence: (a, i, m) ->
    query = if m[3] then m[3] else 'any'
    value = window.rulesController.apply a, 'MTConfidenceRule'
    if (k for own k of value).length isnt 0
      if query is 'any'
        return true

      query = query.split ','
      for test in query
        match = test.match /(mtConfidence):\s*(.*?)\s*$/
        switch(match[1])
          when "mtConfidence"
            match2 = match[2].match /([<>!=]*)\s*([-\d\.]*)/
            match2[2] = parseFloat match2[2]
            if not isNaN(match2[2]) and value[match[1]]? and not isNaN(value[match[1]])
              switch match2[1]
                when "", "=", "=="
                  if value[match[1]] != match2[2]
                    return false
                when "!="
                  if value[match[1]] == match2[2]
                    return false
                when ">"
                  if value[match[1]] <= match2[2]
                    return false
                when "<"
                  if value[match[1]] >= match2[2]
                    return false
                else
                  return false
            else
              return false

      return true

    return false
