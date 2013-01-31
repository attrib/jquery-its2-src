###
# Rule Storage Size.
#
# Cocomore.
#
# TODO: License, header template, copyright, authors.
###

class StorageSizeRule extends Rule

  constructor: ->
    super
    @RULE_NAME = 'its:storagesizerule'
    @NAME = 'storageSize'
    @attributes = {
      storageSize: 'its-storage-size',
      storageEncoding: 'its-storage-encoding',
      lineBreakType: 'its-line-break-type'
    }

  parse: (rule, content) ->
    if rule.tagName.toLowerCase() is @RULE_NAME
      rules = []
      object = {}
      object.selector = $(rule).attr 'selector'
      object.type = @NAME
      #one of following
      if $(rule).attr 'storageSize'
        object.storageSize = $(rule).attr 'storageSize'
        rules.push object
      else if $(rule).attr 'storageSizePointer'
        xpath = new XPath content
        newRules = xpath.resolve object.selector, $(rule).attr 'storageSizePointer'
        for newRule in newRules
          if newRule.result instanceof Attr then object.storageSize = newRule.result.value else object.storageSize = $(newRule.result).text()
          rules.push object
      else
        return
      #one or none of following
      if $(rule).attr 'storageEncoding'
        for ruleObject in rules
          ruleObject.storageEncoding = $(rule).attr 'storageEncoding'
      else if $(rule).attr 'storageEncodingPointer'
        xpath = new XPath content
        newRules = xpath.resolve object.selector, $(rule).attr 'storageEncodingPointer'
        rulesTmp = []
        for newRule in newRules
          if newRule.result instanceof Attr then storageEncoding = newRule.result.value else storageEncoding = $(newRule.result).text()
          for ruleObject in rules
            ruleObject.storageEncoding = storageEncoding
            rulesTmp.push ruleObject
        rules = rulesTmp;
      else
        for ruleObject in rules
          ruleObject.storageEncoding = 'UTF-8'

      #optional
      for ruleObject in rules
        if $(rule).attr 'lineBreakType'
          ruleObject.lineBreakType = $(rule).attr 'lineBreakType'
        else
          ruleObject.lineBreakType = 'lf'

      for ruleObject in rules
        @addSelector ruleObject

  apply: (tag) =>
    # Precedence order
    # 1. Default
    ret = @def()
    # 2. Rules in the schema
    xpath = new XPath tag
    for rule in @rules
      if rule.type = @NAME
        if xpath.process rule.selector
          if rule.storageSize
            ret.storageSize = rule.storageSize
          if rule.storageEncoding
            ret.storageEncoding = rule.storageEncoding
          if rule.lineBreakType
            ret.lineBreakType = rule.lineBreakType
    # 3. Rules in the document instance
    # TODO: Not implemented
    # no inheritance
    # 4. Local attributes
    for objectName, attributeName of @attributes
      if $(tag).attr attributeName
        ret[objectName] = $(tag).attr attributeName
    # ...and return
    ret.lineBreakType = ret.lineBreakType.toLowerCase();
    if ret.storageSize == null then {} else ret

  def: ->
    {
      lineBreakType: 'lf',
      storageEncoding: 'UTF-8',
      storageSize: null
    }