###
# Localization Quality Rating.
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

class LocalizationQualityRatingRule extends Rule
  constructor: ->
    super
    @NAME = 'locQualityRating'
    @attributes = {
      locQualityRatingScore: 'its-loc-quality-rating-score',
      locQualityRatingScoreThreshold: 'its-loc-quality-rating-score-threshold',
      locQualityRatingVote: 'its-loc-quality-rating-vote',
      locQualityRatingVoteThreshold: 'its-loc-quality-rating-vote-threshold',
      locQualityRatingProfileRef: 'its-loc-quality-rating-profile-ref',
    }

  parse: (rule, content) ->
    # No Rules!

  apply: (tag) =>
    # Precedence order
    # 1. Default
    ret = @def()
    # 2. No Rules
    # 3. Rules in the document instance (inheritance)
    value = @inherited tag
    if value instanceof Object then ret = value
    # 4. Local attributes
    for objectName, attributeName of @attributes
      if $(tag).attr(attributeName) != undefined
        ret[objectName] = $(tag).attr attributeName
        @store tag, ret
    # Both are not allowed
    if ret.locQualityRatingScore? and ret.locQualityRatingVote?
      delete ret.locQualityRatingVote
      delete ret.locQualityRatingVoteThreshold
    # Conformance
    if ret.locQualityRatingScore?
      ret.locQualityRatingScore = parseFloat(ret.locQualityRatingScore)
    if ret.locQualityRatingScoreThreshold?
      ret.locQualityRatingScoreThreshold = parseFloat(ret.locQualityRatingScoreThreshold)

    if ret.locQualityRatingVote?
      ret.locQualityRatingVote = parseInt(ret.locQualityRatingVote)
    if ret.locQualityRatingVoteThreshold?
      ret.locQualityRatingVoteThreshold = parseInt(ret.locQualityRatingVoteThreshold)
    # ...and return
    ret

  def: ->
    {
    }
