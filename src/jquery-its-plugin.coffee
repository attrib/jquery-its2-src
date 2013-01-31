###
# jQuery plugin for ITS testing framework.
#
# Cocomore.
#
# TODO: License, header template, copyright, authors.
###

$ = jQuery

$.extend
  parseITS: (callback) ->
    window.XPath = XPath
    globalRules = [new TranslateRule(), new LocalizationNoteRule(), new StorageSizeRule(), new AllowedCharactersRule(), new ParamRule()]
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

$.extend $.expr[':'],
  translate: (a, i, m) ->
    query = 'translate=' + if m[3] then m[3] else 'yes'
    value = window.rulesController.apply a, 'TranslateRule'
    return value == query
  locnote: (a, i, m) ->
    return false