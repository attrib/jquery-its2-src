###
# MT Confidence.
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

class MTConfidenceRule extends Rule
  constructor: ->
    super
    @RULE_NAME = 'its:mtconfidencerule'
    @NAME = 'mtConfidence'
    @attributes = {
      mtConfidence: 'its-mt-confidence',
    }

  parse: (rule, content) ->
    if rule.tagName.toLowerCase() is @RULE_NAME
      object = {}
      object.selector = $(rule).attr 'selector'
      object.type = @NAME
      #one of following
      if $(rule).attr 'mtConfidence'
        object.mtConfidence = $(rule).attr 'mtConfidence'
      else
        return

      @addSelector object

  apply: (tag) =>
    # Precedence order
    # 1. Default
    ret = @def()
    # 2. Rules in the schema
    xpath = new XPath tag
    for rule in @rules
      if rule.type = @NAME
        if xpath.process rule.selector
          if rule.mtConfidence
            ret.mtConfidence = rule.mtConfidence
          @store tag, ret
    # 3. Rules in the document instance (inheritance)
    value = @inherited tag
    if value instanceof Object then ret = value
    # 4. Local attributes
    for objectName, attributeName of @attributes
      if $(tag).attr(attributeName) != undefined
        ret[objectName] = $(tag).attr attributeName
        @store tag, ret
    # Conformance
    if ret.mtConfidence?
      ret.mtConfidence = parseFloat ret.mtConfidence;
    # ...and return
    ret

  def: ->
    {
    }
