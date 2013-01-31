###
# Rule Storage Size.
#
# Cocomore.
#
# TODO: License, header template, copyright, authors.
###

class ParamRule extends Rule

  constructor: ->
    super
    @RULE_NAME = 'its:param'
    @NAME = 'param'

  parse: (rule, content, xml) ->
    if rule.tagName.toLowerCase() is @RULE_NAME
      paramName =  $(rule).attr 'name'
      exp = new RegExp "\\$#{paramName}", 'g'
      paramValue = "'#{rule.childNodes[0].nodeValue}'";
      @replaceParam(exp, paramValue, xml)

  replaceParam: (regExp, paramValue, xml) ->
    for child in xml.childNodes
      if child.tagName and child.tagName.toLowerCase() != @RULE_NAME
        for attribute in child.attributes
          attribute.nodeValue = attribute.nodeValue.replace regExp, paramValue
        if child.hasChildNodes
          @replaceParam regExp, paramValue, child
        if child.nodeValue
          child.nodeValue = child.nodeValue.replace regExp, paramValue

  apply: (node) ->
    {}

  def: ->
    {}