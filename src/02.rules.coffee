###
# Rule definition.
#
# Cocomore.
#
# TODO: License, header template, copyright, authors.
###

staticData = {}

class Rule
  constructor: ->
    @rules = []
    @applied = {}

  parse: (rule, content) => throw new Error('AbstractClass Rule: method parse not implemented.')
  apply: (node) => throw new Error('AbstractClass Rule: method apply not implemented.')
  def: -> throw new Error('AbstractClass Rule: method def not implemented.')

  addSelector: (object) ->
    @rules.push(object)

  inherited: (node) ->
    parents = $(node).parents()
    parents.splice(0, 0, $(node))
    for parent in parents
      xpath = new XPath parent
      if @applied[xpath.path]
        return @applied[xpath.path]

  store: (node, object) =>
    xpath = new XPath node
    @applied[xpath.path] = object
