###
# XPath class.
#
# Cocomore.
#
# TODO: License, header template, copyright, authors.
###

class XPath
  constructor: (element) ->
    @path = ''
    @element = null

    if (element == undefined || element.length <= 0) then return null

    if element.jquery?
      @element = element
    else
      @element = $(element)

    @build()

  build: =>
    @path = @path.concat @parents()
    @path = @path.concat @index(@element.get(0))

  parents: =>
    parentPath = ""
    $.each @element.parents().get().reverse(), (i, parent) =>
      parentPath = parentPath.concat @index(parent)
    parentPath

  index: (element) ->
    nodeName = element.nodeName.toLowerCase()
    prevSiblings = $(element).prevAll(nodeName)
    position = prevSiblings.length + 1
    if $(element).parents().length == 0
      "/#{nodeName}"
    else
      "/#{nodeName}[#{position}]"

  filter: (selector) ->
    # TODO: Try to use the correct namespace in @query
    selector.replace /h:/g, ''

  query: (selector, resultType) ->
    domElement = @element.get(0)
    if domElement instanceof Attr
      domElement = domElement.ownerElement
    document.evaluate selector, domElement, null, resultType, null

  process: (selector) ->
    selector = @filter selector
    xpe = new XPathEvaluator()
    domElement = @element.get(0)
    # domElement has to be a domElement and no attribute
    attribute = false
    if (domElement instanceof Attr)
      attribute  = domElement
      domElement = domElement.ownerElement
    if (domElement.ownerDocument == null)
      docElement = domElement.documentElement
    else
      docElement = domElement.ownerDocument.documentElement
    nsResolver = xpe.createNSResolver docElement
    result = xpe.evaluate selector, domElement, nsResolver, XPathResult.ANY_TYPE, null
    while res = result.iterateNext()
      if (!attribute and res == domElement) or (res and attribute and attribute == res)
        return true
    return false

  resolve: (selector, pointer) ->
    selector = @filter selector
    pointer = @filter pointer
    result = @query selector, XPathResult.ORDERED_NODE_ITERATOR_TYPE
    unrolled = []
    while matchedElement = result.iterateNext()
      xpath = new XPath matchedElement
      ret = xpath.query pointer, XPathResult.ORDERED_NODE_ITERATOR_TYPE
      obj = {selector: xpath.path, result: ret.iterateNext()}
      unrolled.push(obj)
    unrolled

