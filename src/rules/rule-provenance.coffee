###
# Provenance..
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

class ProvenanceRule extends Rule
  constructor: ->
    super
    @RULE_NAME = 'its:provrule'
    @STANDOFF_NAME = 'its:provenancerecords'
    @NAME = 'Provenance'
    @attributes = {
      person: 'its-person',
      personRef: 'its-person-ref',
      org: 'its-org',
      orgRef: 'its-org-ref',
      tool: 'its-tool',
      toolRef: 'its-tool-ref',
      revPerson: 'its-rev-person',
      revPersonRef: 'its-rev-person-ref',
      revOrg: 'its-rev-org',
      revOrgRef: 'its-rev-org-ref',
      revTool: 'its-rev-tool',
      revToolRef: 'its-rev-tool-ref',
      provRef: 'its-prov-ref',
      provenanceRecordsRef: 'its-provenance-records-ref'
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

      records = []
      for child in rule.childNodes
        if child.nodeType is 1 and child.tagName.toLowerCase() is "its:provenancerecord"
          record = {}
          for objectName, attributeName of @attributes
            if $(child).attr(objectName) != undefined
              record[objectName] = $(child).attr objectName
          records.push record

      object.records = records
      @addStandoff object
      return true

    return false

  standoffMarkup: (content) =>
    $('[its-provenance-records-ref]', content).each (key, element) =>
      value = $(element).attr 'its-provenance-records-ref'
      @getExternalStandoffMarkup value

    return false

  getExternalStandoffMarkup: (provenanceRecordsRef) =>
    # non local reference
    if provenanceRecordsRef.charAt(0) isnt '#'
      alreadyAdded = false
      for standoff in @standoff
        if standoff.type = @NAME
          if standoff.id is provenanceRecordsRef
            alreadyAdded = true
            break

      if not alreadyAdded
        window.rulesController.getFile provenanceRecordsRef


  parse: (rule, content) ->
    if rule.tagName.toLowerCase() is @RULE_NAME

      rules = []
      object = {}
      object.selector = $(rule).attr 'selector'
      object.type = @NAME
      if $(rule).attr('provenanceRecordsRefPointer') != undefined
        xpath = new XPath content
        object.provenanceRecordsRefPointer = $(rule).attr('provenanceRecordsRefPointer')
        newRules = xpath.resolve object.selector, object.provenanceRecordsRefPointer
        for newRule in newRules
          newObject = $.extend(true, {}, object)
          if newRule.result instanceof Attr then newObject.provenanceRecordsRef = newRule.result.value else newObject.provenanceRecordsRef = $(newRule.result).text()
          newObject.selector = newRule.selector
          rules.push newObject
          @getExternalStandoffMarkup newObject.provenanceRecordsRef
      else
        return

      for rule in rules
        @addSelector rule

  apply: (tag) =>
    # Precedence order
    # 1. Default
    ret = @def()
    # 2. Rules in the schema
    @applyRules ret, tag, ['provenanceRecordsRef']
    # 3. Rules in the document instance (inheritance)
    @applyInherit ret, tag, true
    # 4. Local attributes
    @applyAttributes ret, tag
    # Standoff Markup
    if ret.provenanceRecordsRef?
      for standoff in @standoff
        if standoff.type = @NAME
          if standoff.id is ret.provenanceRecordsRef
            if standoff.records?
              ret.provenanceRecords = standoff.records
            @store tag, ret

    # ...and return
    ret

  def: ->
    {
    }
