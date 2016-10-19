# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 25.04.16
# Time: 1:08
# To change this template use File | Settings | File Templates.

@CLASS
Parsekit/Semver/Constraint/EmptyConstraint

@OPTIONS
locals

@BASE
Parsekit/Semver/Constraint/ConstraintInterface

@auto[]
###


#------------------------------------------------------------------------------
#:constructor
#------------------------------------------------------------------------------
@create[]
    $self._prettyString[]
###


#------------------------------------------------------------------------------
#Empty constraint matches everything
#
#:param provider type Parsekit/Semver/Constraint/ConstraintInterface
#
#:result boolean
#------------------------------------------------------------------------------
@matches[provider]
    $result(true)
###


#------------------------------------------------------------------------------
#:param prettyString type string
#------------------------------------------------------------------------------
@SET_prettyString[prettyString]
    $self._prettyString[$prettyString]
###


#------------------------------------------------------------------------------
#:result string
#------------------------------------------------------------------------------
@GET_prettyString[]
    $result[$self._prettyString]
    ^if(!def $result){
        $result[^self.GET[]]
    }
###


#------------------------------------------------------------------------------
#:result string
#------------------------------------------------------------------------------
@GET[][result]
    $result[^[^]]
###