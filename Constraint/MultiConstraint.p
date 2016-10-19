# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 25.04.16
# Time: 1:08
# To change this template use File | Settings | File Templates.

@CLASS
MultiConstraint

@OPTIONS
locals

@BASE
ConstraintInterface

@auto[]
###


#------------------------------------------------------------------------------
#:constructor
#
#:param constraints type hash
#:param conjunctive type boolean
#------------------------------------------------------------------------------
@create[constraints;conjunctive]
    $self.constraints[^hash::create[$constraints]]
    $self.conjunctive(^if(def $conjunctive){$conjunctive}(true))
    $self.prettyString[]
###


#------------------------------------------------------------------------------
#:param provider type ConstraintInterface
#
#:result boolean
#------------------------------------------------------------------------------
@matches[provider][result]
    ^if(!$self.conjunctive){
        $result(false)

        ^self.constraints.foreach[key;constraint]{
            ^if(^constraint.matches[$provider]){
                $result(true)
            }
        }
    }{
        $result(true)

        ^self.constraints.foreach[key;constraint]{
            ^if(!^constraint.matches[$provider]){
                $result(false)
            }
        }
    }
###


#------------------------------------------------------------------------------
#:result string
#------------------------------------------------------------------------------
@GET[][result]
    $separator[^if($self.conjunctive){ }{||}]

    $result[^[^self.constraints.foreach[key;constraint]{^constraint.GET[]}[$separator]^]]
###


#------------------------------------------------------------------------------
#:result hash
#------------------------------------------------------------------------------
@GET_constraints[][result]
    $result[$self._constraints]
###

#------------------------------------------------------------------------------
#:param constraints type hash
#
#:result hash
#------------------------------------------------------------------------------
@SET_constraints[constraints][result]
    $self._constraints[$constraints]
###


#------------------------------------------------------------------------------
#:param prettyString type string
#------------------------------------------------------------------------------
@SET_prettyString[prettyString][result]
    $self._prettyString[$prettyString]
###


#------------------------------------------------------------------------------
#:result string
#------------------------------------------------------------------------------
@GET_prettyString[][result]
    $result[$self._prettyString]
###

#------------------------------------------------------------------------------
#:result boolean
#------------------------------------------------------------------------------
@isConjunctive[][result]
    $result($self.conjunctive)
###


#------------------------------------------------------------------------------
#:result boolean
#------------------------------------------------------------------------------
@isDisjunctive[][result]
    $result(!$self.conjunctive)
###
