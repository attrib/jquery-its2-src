###
# ITS Tools Annotation.
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

class AnnotatorsRef extends Rule

  constructor: ->
    super
    @NAME = 'annotatorsRef'
    @attributes = {
    annotatorsRef: 'its-annotators-ref',
    }

  parse: (rule, content) ->
    # Only local attribute
    return

  apply: (tag) =>
    # Precedence order
    # 1. Default
    ret = @def()
    # 2. no rules
    # 3. Inheritance
    # 3. Rules in the document instance (inheritance)
    if tag instanceof Attr
      value = @inherited tag.ownerElement
    else
      value = @inherited tag
    if value instanceof Object then ret = value
    # 4. Local attributes
    for objectName, attributeName of @attributes
      if $(tag).attr attributeName
        values = $(tag).attr attributeName
        ret[objectName] = values
        values = values.split ' '
        obj = {}
        for value in values
          value = value.split '|'
          nameParts = value[0].split '-'
          name = ""
          for namePart in nameParts
            name += namePart.charAt(0).toUpperCase() + namePart.slice(1)
          obj[name] = value[1]
        ret[objectName + 'Splitted'] = obj
        @store tag, ret
    # ...and return
    ret

  def: ->
    {
    }
