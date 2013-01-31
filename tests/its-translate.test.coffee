###
# 
#
# Cocomore.
#
# TODO: License, header template, copyright, authors.
###

TEST_RULE_NAME = 'TranslateRule'
#TEST_RULE_NAME = 'LocalizationNoteRule'
#TEST_RULE_NAME = 'StorageSizeRule'
#TEST_RULE_NAME = 'AllowedCharactersRule'

$ = jQuery

$ ->
  formatOutput = (value) ->
    if value instanceof Object
      outputValue = ""
      for key, val of value
        if key == 'translate'
          val = if val then 'yes' else 'no'
        val = val.replace /\n/g, ' '
        outputValue += "\t#{key}=\"#{val}\""
    else
      outputValue = value
    if outputValue == 'default' then '' else outputValue

  $.parseITS (rules) ->
    string = ''
    for tag in $('*')
      if $(tag).attr('data-test') == 'mlw-lt'
        continue
      xpath = new XPath(tag)
      value = rules.apply(tag)
      string += "#{xpath.path}#{formatOutput value[TEST_RULE_NAME]}\n"
      if tag.attributes.length != 0
        tmp = []
        for attribute in tag.attributes
          attributeName = attribute.nodeName || attribute.name
          value = rules.apply attribute
          tmp.push
            str:  "#{xpath.path}/@#{attributeName}#{formatOutput value[TEST_RULE_NAME]}\n",
            name: attributeName
        tmp = tmp.sort (a, b) ->
          return +1 if a.name > b.name
          return -1 if a.name < b.name
          return 0
        for obj in tmp
          string += obj.str
    $('<textarea>' + string + '</textarea>').css('width', '100%').css('height', '500px').appendTo('body');
