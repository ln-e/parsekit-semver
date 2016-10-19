# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 25.04.16
# Time: 1:05
# To change this template use File | Settings | File Templates.

@CLASS
Comparator

@OPTIONS
locals

@auto[]
###


#------------------------------------------------------------------------------
#:constructor
#------------------------------------------------------------------------------
@create[]
###


#------------------------------------------------------------------------------
#:param version1 type string
#:param version2 type string
#
#:result boolean
#------------------------------------------------------------------------------
@greaterThan[version1;version2][result]
    $result(^self.compare[$version1;>;$version2])
###


#------------------------------------------------------------------------------
#:param version1 type string
#:param version2 type string
#
#:result boolean
#------------------------------------------------------------------------------
@greaterThanOrEqualTo[version1;version2][result]
    $result(^self.compare[$version1;>=;$version2])
###


#------------------------------------------------------------------------------
#:param version1 type string
#:param version2 type string
#
#:result boolean
#------------------------------------------------------------------------------
@lessThan[version1;version2][result]
    $result(^self.compare[$version1;<;$version2])
###


#------------------------------------------------------------------------------
#:param version1 type string
#:param version2 type string
#
#:result boolean
#------------------------------------------------------------------------------
@lessThanOrEqualTo[version1;version2][result]
    $result(^self.compare[$version1;<=;$version2])
###


#------------------------------------------------------------------------------
#:param version1 type string
#:param version2 type string
#
#:result boolean
#------------------------------------------------------------------------------
@equalTo[version1;version2][result]
    $result(^self.compare[$version1;==;$version2])
###


#------------------------------------------------------------------------------
#:param version1 type string
#:param version2 type string
#
#:result boolean
#------------------------------------------------------------------------------
@notEqualTo[version1;version2][result]
    $result(^self.compare[$version1;!=;$version2])
###


#------------------------------------------------------------------------------
#:param version1 type string
#:param operator type string
#:param version2 type string
#
#:result boolean
#------------------------------------------------------------------------------
@compare[version1;operator;version2][result]
    $constraint[^Constraint::create[$operator;$version2]]
    $result(^constraint.matches[^Constraint::create[==;$version1]])
###
