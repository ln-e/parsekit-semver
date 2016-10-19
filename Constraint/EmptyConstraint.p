# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 25.04.16
# Time: 1:08
# To change this template use File | Settings | File Templates.

@CLASS
EmptyConstraint

@OPTIONS
locals

@BASE
ConstraintInterface

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
#:param provider type ConstraintInterface
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