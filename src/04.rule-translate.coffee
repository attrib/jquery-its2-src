###
# Rule Translate.
#
# Cocomore.
#
# TODO: License, header template, copyright, authors.
###

##= require

class TranslateRule extends Rule
  constructor: ->
    super
    @RULE_NAME = 'its:translaterule'
    @NAME = 'translate'

  parse: (rule, content) =>
    if rule.tagName.toLowerCase() is @RULE_NAME
      object = {}
      object.selector = $(rule).attr('selector')
      object.type = @NAME
      object.translate = normalize $(rule).attr(@NAME)
      @addSelector object

  apply: (tag) =>
    # Precedence order
    # 1. Default
    ret = if tag instanceof Attr then @defAttr() else @def()
    # 2. Rules in the schema
    xpath = new XPath tag
    for rule in @rules
      if rule.type = @NAME
        if xpath.process rule.selector
          ret = { translate: rule.translate }
          @store tag, ret
    # 3. Rules in the document instance (inheritance)
    value = @inherited tag
    if value instanceof Object then ret = value
    # 4. Local attributes
    if ($(tag).attr(@NAME))
      ret = { translate: normalize $(tag).attr(@NAME) }
    # ...and return
    ret

  def: ->
    { translate: true }

  defAttr: ->
    { translate: false }

  normalize = (translateString) ->
    # Trim the string and lowecase.
    translateString = translateString.replace(/^\s+|\s+$/g, '').toLowerCase();
    if translateString == "yes"
      return true
    else
      return false
