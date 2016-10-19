# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 25.04.16
# Time: 1:20
# To change this template use File | Settings | File Templates.

@CLASS
Parsekit/Semver/Constraint/ConstraintInterface

@OPTIONS
locals

@auto[]
###


#------------------------------------------------------------------------------
#:constructor
#------------------------------------------------------------------------------
@create[]
    ^throw[Abstract method not implemented]
###


#------------------------------------------------------------------------------
#:param provider type Parsekit/Semver/Constraint/ConstraintInterface
#
#:result boolean
#------------------------------------------------------------------------------
@matches[provider]
    ^throw[Abstract method not implemented]
###


#------------------------------------------------------------------------------
#:result string
#------------------------------------------------------------------------------
@GET_prettyString[]
    ^throw[Abstract method not implemented]
###


#------------------------------------------------------------------------------
#:result string
#------------------------------------------------------------------------------
@GET[]
    ^throw[Abstract method not implemented]
###
