###
# Localization Quality Issue.
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

class LocalizationQualityIssueRule extends Rule
  constructor: ->
    super
    @RULE_NAME = 'its:locqualityissuerule'
    @STANDOFF_NAME = 'its:locqualityissues'
    @NAME = 'locQualityIssue'
    @attributes = {
      locQualityIssueComment: 'its-loc-quality-issue-comment',
      locQualityIssueEnabled: 'its-loc-quality-issue-enabled',
      locQualityIssueProfileRef: 'its-loc-quality-issue-profile-ref',
      locQualityIssueSeverity: 'its-loc-quality-issue-severity',
      locQualityIssueType: 'its-loc-quality-issue-type',
    }

  standoffMarkupXML: (rule, content, file) =>
    if rule.tagName.toLowerCase() is @STANDOFF_NAME

      object = {}
      id = $(rule).attr 'xml:id'
      if file?
        if file.indexOf '#' != -1
          file = file.substr 0, file.indexOf('#')
          object.id = "#{file}##{id}"
        else
          object.id = "#{file}##{id}"
      else
        object.id = "##{id}"
      object.type = @NAME

      issues = []
      for child in rule.childNodes
        if child.nodeType is 1 and child.tagName.toLowerCase() is "its:locqualityissue"
          issue = @parseRuleOrStandoff child, {}
          issues.push issue

      object.issues = issues

      @addStandoff object
      return true

    return false

  standoffMarkup: (content) =>
    $('[its-loc-quality-issues-ref]', content).each (key, element) =>
      value = $(element).attr 'its-loc-quality-issues-ref'
      # non local reference
      if value.charAt(0) isnt '#'
        alreadyAdded = false
        for standoff in @standoff
          if standoff.type = @NAME
            if standoff.id is value
              alreadyAdded = true
              break

        if not alreadyAdded
          window.rulesController.getFile value

    return false

  parse: (rule, content) ->
    if rule.tagName.toLowerCase() is @RULE_NAME
      object = {}
      object.selector = $(rule).attr 'selector'
      object.type = @NAME
      @parseRuleOrStandoff rule, object

      @addSelector object

  parseRuleOrStandoff: (rule, object) ->
    #one of following
    found = false
    if $(rule).attr 'locQualityIssueType'
      object.locQualityIssueType = $(rule).attr 'locQualityIssueType'
      found = true
    if $(rule).attr 'locQualityIssueComment'
      object.locQualityIssueComment = $(rule).attr 'locQualityIssueComment'
      found = true
    if !found
      return
    #optional
    if $(rule).attr 'locQualityIssueSeverity'
      object.locQualityIssueSeverity = $(rule).attr 'locQualityIssueSeverity'
    if $(rule).attr 'locQualityIssueProfileRef'
      object.locQualityIssueProfileRef = $(rule).attr 'locQualityIssueProfileRef'
    if $(rule).attr 'locQualityIssueEnabled'
      object.locQualityIssueEnabled = $(rule).attr 'locQualityIssueEnabled'

    if not object.locQualityIssueEnabled? and ( object.locQualityIssueComment? or object.locQualityIssueProfileRef? or object.locQualityIssueSeverity? or object.locQualityIssueType)
      object.locQualityIssueEnabled = true

    if object.locQualityIssueEnabled?
      object.locQualityIssueEnabled = @normalizeYesNo object.locQualityIssueEnabled
    if object.locQualityIssueType?
      object.locQualityIssueType = @normalizeString object.locQualityIssueType

    return object

  apply: (tag) =>
    # Precedence order
    # 1. Default
    ret = @def()
    # 2. Rules in the schema
    @applyRules ret, tag, ['locQualityIssueComment', 'locQualityIssueEnabled', 'locQualityIssueProfileRef', 'locQualityIssueSeverity', 'locQualityIssueType']
    # 3. Rules in the document instance (inheritance)
    @applyInherit ret, tag
    # 4. Local attributes
    @applyAttributes ret, tag
    # Standoff Markup
    if $(tag).attr('its-loc-quality-issues-ref') != undefined
      ret.locQualityIssuesRef = $(tag).attr('its-loc-quality-issues-ref')
      for standoff in @standoff
        if standoff.type = @NAME
          if standoff.id is ret.locQualityIssuesRef
            ret.locQualityIssues = standoff.issues
            @store tag, ret

    # 5. Default enabled
    if not ret.locQualityIssueEnabled? and ( ret.locQualityIssueComment? or ret.locQualityIssueProfileRef? or ret.locQualityIssueSeverity? or ret.locQualityIssueType)
      ret.locQualityIssueEnabled = true
    # Conformance
    if ret.locQualityIssueEnabled?
      ret.locQualityIssueEnabled = @normalizeYesNo ret.locQualityIssueEnabled
    if ret.locQualityIssueType?
      ret.locQualityIssueType = @normalizeString ret.locQualityIssueType
    # ...and return
    ret

  def: ->
    {
    }

  jQSelector:
    name: 'locQualityIssue'
    callback: (a, i, m) ->
      query = if m[3] then m[3] else 'any'
      value = window.rulesController.apply a, 'LocalizationQualityIssueRule'
      if (k for own k of value).length isnt 0
        if query == 'any'
          return true

        matchQuery = (value, type, query) =>
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
              ret = @compareNumber(query, value.locQualityIssueSeverity)
              if !ret
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
