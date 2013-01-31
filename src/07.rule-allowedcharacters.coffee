###
# Rule Storage Size.
#
# Cocomore.
#
# TODO: License, header template, copyright, authors.
###

class AllowedCharactersRule extends Rule

  constructor: ->
    super
    @RULE_NAME = 'its:allowedcharactersrule'
    @NAME = 'allowedCharacters'
    @attributes = {
      allowedCharacters: 'its-allowed-characters',
    }

  parse: (rule, content) ->
    if rule.tagName.toLowerCase() is @RULE_NAME
      object = {}
      object.selector = $(rule).attr 'selector'
      object.type = @NAME
      #one of following
      if $(rule).attr 'allowedCharacters'
        object.allowedCharacters = $(rule).attr 'allowedCharacters'
        @addSelector object
      else if $(rule).attr 'allowedCharactersPointer'
        allowedCharactersPointer = $(rule).attr 'allowedCharactersPointer'
        xpath = new XPath content
        newRules = xpath.resolve object.selector, $(rule).attr('allowedCharactersPointer')
        for newRule in newRules
          if newRule.result instanceof Attr then object.allowedCharacters = newRule.result.value else object.allowedCharacters = $(newRule.result).text()
          @addSelector object
      else
        return

  apply: (tag) =>
    # Precedence order
    # 1. Default
    ret = @def()
    # 2. Rules in the schema
    xpath = new XPath tag
    for rule in @rules
      if rule.type = @NAME
        if xpath.process rule.selector
          if rule.allowedCharacters
            ret.allowedCharacters = rule.allowedCharacters
    # 3. Rules in the document instance
    # TODO: Not implemented
    # inheritance
    # 4. Local attributes
    for objectName, attributeName of @attributes
      if $(tag).attr attributeName
        ret[objectName] = $(tag).attr attributeName
    # ...and return
    if ret.allowedCharacters == '' then {} else ret

  def: ->
    {
      allowedCharacters: '',
    }