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

# PhantomJS doesn't support bind yet
Function.prototype.bind = Function.prototype.bind || (thisp) ->
  fn = this;
  return () ->
    return fn.apply(thisp, arguments)


globalRules = [new ParamRule(), new TranslateRule(), new LocalizationNoteRule(), new StorageSizeRule(),
  new AllowedCharactersRule(), new AnnotatorsRef(), new TextAnalysisRule(), new TerminologyRule(), new DirectionalityRule(),
  new DomainRule(), new LocaleFilterRule(), new LocalizationQualityIssueRule(), new LocalizationQualityRatingRule(),
  new MTConfidenceRule(), new ProvenanceRule(), new ExternalResourceRule(), new TargetPointerRule(), new IdValueRule(),
  new LanguageInformationRule(), new ElementsWithinTextRule()]

selectors = {}
for rule in globalRules
  if rule.jQSelector? and typeof rule.jQSelector.callback is 'function'
    selectors[rule.jQSelector.name] = rule.jQSelector.callback.bind(rule)
$.extend $.expr[':'], selectors

$.extend
  parseITS: (callback) ->
    window.XPath = XPath
    window.rulesController = new RulesController(globalRules)
    window.rulesController.setContent $('html')
    window.rulesController.getStandoffMarkup()
    external_rules = $('link[rel="its-rules"]')
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

  clearITSCache: () ->
    XPath.instances = []
    XPath.instances_el = []
    for rule in globalRules
      rule.applied = {}

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

  getITSSplitText: () ->
    texts = []
    prepareText = (text) ->
      text.replace /^\s*|\s*$/g, ''

    splitText = (element, nested = false) ->
      value = window.rulesController.apply element, 'ElementsWithinTextRule'
      if value.withinText == 'no'
        if element.childNodes.length > 0
          text = ""
          for child in element.childNodes
            if child.nodeType is 1
              if splitText child, true
                text += " " + prepareText $('<div></div>').append($(child).clone()).html()
            else
              text += " " + prepareText child.nodeValue

          if text != ""
            texts.push prepareText text
        else
          texts.push prepareText $(element).html()
      else if value.withinText == 'nested'
        texts.push prepareText $(element).html()
      else if value.withinText == 'yes'
        if not nested
          splitText element.parentNode
        else
          return true

      return false

    for element in this
      splitText element

    texts
