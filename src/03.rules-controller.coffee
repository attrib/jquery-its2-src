###
# Rules controller.
#
# Cocomore.
#
# TODO: License, header template, copyright, authors.
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
    if xml.tagName and xml.tagName.toLowerCase() is "its:rules" and $(xml).attr('version') is "2.0"
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
