# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 25.04.16
# Time: 1:08
# To change this template use File | Settings | File Templates.

@CLASS
Parsekit/Semver/Constraint/Constraint

@OPTIONS
locals

@BASE
Parsekit/Semver/Constraint/ConstraintInterface

@auto[]
    $self.OP_EQ(0)
    $self.OP_LT(1)
    $self.OP_LE(2)
    $self.OP_GT(3)
    $self.OP_GE(4)
    $self.OP_NE(5)

    $self.opString[
        $.[=]($self.OP_EQ)
        $.[==]($self.OP_EQ)
        $.[<]($self.OP_LT)
        $.[<=]($self.OP_LE)
        $.[>]($self.OP_GT)
        $.[>=]($self.OP_GE)
        $.[<>]($self.OP_NE)
        $.[!=]($self.OP_NE)
    ]

    $self.opInt[
        $.[$self.OP_EQ][==]
        $.[$self.OP_LT][<]
        $.[$self.OP_LE][<=]
        $.[$self.OP_GT][>]
        $.[$self.OP_GE][>=]
        $.[$self.OP_NE][!=]
    ]

#   str < dev < alpha = a < beta = b < RC = rc < # < pl = p
    $self.tails[
        $.dev(1)
        $.a(1)
        $.alpha(1)
        $.b(2)
        $.beta(3)
        $.RC(3)
        $.rc(3)
        $.[#](4)
        $.pl(5)
        $.p(5)
    ]

###


#------------------------------------------------------------------------------
#:constructor
#
#:param operator type string
#:param version type string
#------------------------------------------------------------------------------
@create[operator;version]
    ^if(!^self.opString.contains[$operator]){
        ^throw[invalid.argument;Constraint.p;Invalid operator $operator]
    }

    $self.operator[$self.opString.[^operator.trim[]]]
    $self.version[$version]
###


#------------------------------------------------------------------------------
#:param provider type Parsekit/Semver/Constraint/ConstraintInterface
#
#:result boolean
#------------------------------------------------------------------------------
@matches[provider][result]
    $className[Parsekit/Semver/Constraint/Constraint]
    ^if($provider is $className){
        $result[^self.matchSpecific[$provider]]
    }{
        $result[^provider.matches[$self]]
    }
###


#------------------------------------------------------------------------------
#:result string
#------------------------------------------------------------------------------
@GET[][result]
    $result[$self.opInt.[$self.operator] $self.version]
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
#:param provider type Constraint
#:param compareBranches type boolean
#
#:result boolean
#------------------------------------------------------------------------------
@matchSpecific[provider;compareBranches]
    $noEqualOp[^self.opInt.[$self.operator].replace[=;]]
    $providerNoEqualOp[^self.opInt.[$rovider.operator].replace[=;]]

    $isEqualOp($self.OP_EQ == $self.operator)
    $isNonEqualOp($self.OP_NE == $self.operator)
    $isProviderEqualOp($self.OP_EQ == $provider.operator)
    $isProviderNonEqualOp($self.OP_NE == $provider.operator)

    ^if($isNonEqualOp || $isProviderNonEqualOp){
        ^rem['!=' operator is match when other operator is not '==' operator or version is not match]

        $result(
            !$isEqualOp && !$isProviderEqualOp
            || ^self.versionCompare[$provider.version;$self.version;!=;$compareBranches]
        )
    }($self.operator != $self.OP_EQ && $noEqualOp eq $providerNoEqualOp){
        ^rem[the condition is <= 2.0 & < 1.0 always have a solution]

        $result(true)
    }(^self.versionCompare[$provider.version;$self.version;$self.opInt.[$self.operator];$compareBranches]){
        $result(true)

        ^if(
            $provider.version eq $self.version
            && $self.opInt.[$provider.operator] eq $providerNoEqualOp
            && $self.opInt.[$self.operator] ne $noEqualOp
        ){
            ^rem[require >= 1.0 and provide < 1.0]
            ^rem[1.0 >= 1.0 but 1.0 is outside of the provided interval]

            $result[false]
        }
    }{
        $result(false)
    }
###


#------------------------------------------------------------------------------
#:param a type string
#:param b type string
#:param operator type string
#:param compareBrances type boolean
#
#:result boolean
#------------------------------------------------------------------------------
@versionCompare[a;b;operator;compareBrances][result]
    ^if(!^self.opString.contains[$operator]){
        ^throw[invalid.argument;Constraint.p;Invalid operator $operator not found in list ]
    }

    $aIsBranch('dev-' eq ^a.mid(0;4))
    $bIsBranch('dev-' eq ^b.mid(0;4))

    ^if($aIsBranch && $bIsBranch){
        $result($operator eq '==' && $a == $b)
    }(!$compareBranches && ($aIsBranch || $bIsBranch)){
        ^rem[when branches are not comparable, we make sure dev branches never match anything]
        $result(false)
    }{
        $result(^self.phplikeVersionCompare[$a;$b;$operator])
    }
###


#------------------------------------------------------------------------------
#:param a type string
#:param b type string
#:param operator type string
#
#:result boolean
#------------------------------------------------------------------------------
@phplikeVersionCompare[a;b;operator][result]
    $result[]
    $tableA[^self.pointize[$a]]
    $tableB[^self.pointize[$b]]
    $indexA[^tableA.count[]]
    $indexB[^tableB.count[]]
    $index(^if($indexA > $indexB){$indexA}{$indexB})

    $tmp[$self.OP_EQ]
    ^for[i](0;$index){
#       check all operators and $tableA.piece and $tableB.piece]
#       str < dev < alpha = a < beta = b < RC = rc < # < pl = p
        ^if($tableA.piece is string && !($tableB.piece is string)){
            ^rem[number always bigger that string]
            $tmp[$self.OP_LT]
            ^break[]
        }(!($tableA.piece is string) && $tableB.piece is string){
            ^rem[number always bigger that string]
            $tmp[$self.OP_GT]
            ^break[]
        }($tableA.piece is string && $tableB.piece is string){
            ^rem[compare two string by indecies]
            $indA[^self.stringTailToIndex[$tableA.piece]]
            $indB[^self.stringTailToIndex[$tableB.piece]]
            ^if($indA < $indB){
                $tmp[$self.OP_LT]
                ^break[]
            }
            ^if($indA > $indB){
                $tmp[$self.OP_GT]
                ^break[]
            }
        }

        ^if($tableA.piece < $tableB.piece){
            $tmp[$self.OP_LT]
            ^break[]
        }

        ^if($tableA.piece > $tableB.piece){
            $tmp[$self.OP_GT]
            ^break[]
        }

        ^rem[Values equals in current iteration, move next table row]
        ^tableA.offset(1)
        ^tableB.offset(1)
    }

    ^switch($self.opString.$operator){
        ^case($self.OP_EQ){$result($tmp == $self.OP_EQ)}
        ^case($self.OP_NE){$result($tmp == $self.OP_NE || $tmp == $self.OP_LT || $tmp == $self.OP_GT)}
        ^case($self.OP_GE){$result($tmp == $self.OP_EQ || $tmp == $self.OP_GT)}
        ^case($self.OP_LE){$result($tmp == $self.OP_EQ || $tmp == $self.OP_LT)}
        ^case($self.OP_GT){$result($tmp == $self.OP_GT)}
        ^case($self.OP_LT){$result($tmp == $self.OP_LT)}
    }
###


#------------------------------------------------------------------------------
#:param version type string
#
#:result table
#------------------------------------------------------------------------------
@pointize[version][result]
    $version[^version.match[([\+\-\_])][g]{.}]
    $version[^version.match[[^^\.\d]+][g]{.$match[1].}]
    $version[^version.trim[both;.]]

    $result[^version.split[.]]
###


#------------------------------------------------------------------------------
#:param tail type string
#
#:result number
#------------------------------------------------------------------------------
@stringTailToIndex[tail][result]
    $result(0)

    $tail[^tail.lower[]]
    ^if(^self.tails.contain[$tail]){
        $result($self.tails.$tail)
    }
###
