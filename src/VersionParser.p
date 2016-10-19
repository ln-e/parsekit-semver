# Created by IntelliJ IDEA.
# User: ibodnar
# Date: 21.03.16
# Time: 9:06
# To change this template use File | Settings | File Templates.

@CLASS
Parsekit/Semver/VersionParser

@OPTIONS
locals

#------------------------------------------------------------------------------
#Static constructor
#------------------------------------------------------------------------------
@auto[]

# Regex to match pre-release data (sort of).
#
# Due to backwards compatibility:
#  - Instead of enforcing hyphen, an underscore, dot or nothing at all are also accepted.
#  - Only stabilities as recognized are allowed to precede a numerical identifier.
#  - Numerical-only pre-release identifiers are not supported.
#
#                        |--------------|
# [major].[minor].[patch] -[pre-release] +[build-metadata]
$self.modifierRegex[[._-]?(?:(stable|beta|b|RC|alpha|a|patch|pl|p)((?:[.-]?\d+)*+)?)?([.-]?dev)?]

$self.stabilities[
    $.stable[0]
    $.RC[1]
    $.beta[2]
    $.alpha[3]
    $.dev[4]
]

$self.implodedStabilities[^self.stabilities.foreach[stability;priority]{$stability}[|]]

$self.normalizedVersions[^hash::create[]]
$self.parsedConstraint[^hash::create[]]
$self.parsedConstraints[^hash::create[]]

###


#------------------------------------------------------------------------------
#:constructor
#------------------------------------------------------------------------------
@create[]
###


#------------------------------------------------------------------------------
#Returns a stability
#
#:param version type string String representation on version
#
#:result string
#------------------------------------------------------------------------------
@parseStability[version][result]
    $version[^version.match[#.*^$][i]{}] ^rem[Stripped out #hash of version]

    ^version.match[$self.modifierRegex^(?:\+.*)?^$][i]{
        ^if($match.3 eq dev){
            $result[dev]
        }($match.1 eq beta || $match.1 eq b){
            $result[beta]
        }($match.1 eq alpha || $match.1 eq a){
            $result[alpha]
        }($match.1 eq rc){
            $result[rc]
        }{
            $result[stable]
        }
    }{ ^throw[couldn't parse version]}
###


#------------------------------------------------------------------------------
#:param stability type string
#
#:result string
#------------------------------------------------------------------------------
@normalizeStability[stability][result]
    $result[^stability.lower[]]

    ^if($result eq rc){$result[RC]}
###


#------------------------------------------------------------------------------
#:param branchName type string
#
#:result string
#------------------------------------------------------------------------------
@normalizeBranch[branchName][result]

    $name[^branchName.trim[]]

    $master[
        $.master[]
        $.trunk[]
        $.default[]
    ]

    ^if(^master.contains[$name]){
        $result[^Parsekit/Semver/VersionParser:normalize[$name]]
    }{
        ^name.match[^^v?(\d++)(\.(?:\d++|[xX*]))?(\.(?:\d++|[xX*]))?(\.(?:\d++|[xX*]))?^$][i]{
            $version[]
            $repl[^table::create[nameless]{*	x}]
            ^for[i](1;4){
                ^if(def $match.$i){
                    $version[$version^match.$i.replace[$repl]]
                }{
                    $version[${version}.x]
                }
            }
            $version[^version.lower[]]

            $result[^version.replace[^table::create[nameless]{x	9999999}]-dev]
        }{
            $result[dev-$name]
        }
    }
###


#------------------------------------------------------------------------------
#:param branchName type string
#
#:result string
#------------------------------------------------------------------------------
@parseNumericAliasPrefix[branchName][result]
    ^branchName.match[^^((\d++\.)*\d++)(?:\.x)?-dev^$][i]{
        $result[${match.1}.]
    }{
        $result(false)
    }
###


#------------------------------------------------------------------------------
#:param version type string
#
#:result string
#------------------------------------------------------------------------------
@normalize[version][result]
^if(^self.normalizedVersions.contains[$version]){
    $result[$self.normalizedVersions.$version]
}{
    $version[^version.trim[]]

    ^if(!def $version || $version eq ''){
        ^throw[version.empty;;Version string is empty]
    }

    $fullVersion[$version]

# strip off aliasing
    $matches[^version.match[^^([^^,\s]+) +as +([^^,\s]+)^$][i]]
    ^if(def $matches){
        $version[$match.1]
    }

# strip off build metadata
    $matches[^version.match[^^([^^,\s+]+)\+[^^\s]+^$][i]]
    ^if(def $matches){
        $version[$matches.1]
    }

# match master-like branches
    ^if(^version.match[^^(?:dev-)?(?:master|trunk|default)^$][in] > 0){
        $result[9999999-dev]
    }

# add somehow lower to if's version mid
    ^if(!def $result && 'dev-' eq ^version.mid(0;4)){
        $result[dev-^version.mid(4)]
    }(!def $result){
        $matches[^version.match[^^v?(\d{1,5})(\.\d+)?(\.\d+)?(\.\d+)?$self.modifierRegex^$][i]]
        ^if(def $matches){
            $version[]
            ^for[i](1;4){
                $version[${version}^if(def $matches.$i)[$matches.$i][.0]]
            }
            $index(5)
        }{
            $matches[^version.match[^^v?(\d{4}(?:[.:-]?\d{2}){1,6}(?:[.:-]?\d{1,3})?)$self.modifierRegex^$]]
            ^if($matches){
                $tmp[$matches.1]
                $version[^tmp.match[\D][g]{.}]
                $index(2)
            }
        }

        ^if(def $index && $index > 0){
            ^if(def $matches.$index && $matches.$index ne ''){
                ^if(stable eq $matches.$index){
                    $result[$version]
                }{
                    $indNext($index+1)
                    $matchNext[$matches.$indNext]
                    $version[${version}-^self.expandStability[$matches.$index]^if(def $matchNext){^matchNext.trim[left;.-]}]
                }
            }
            $ind2($index+2)
            ^if(def $matches.$ind2){
                $version[${version}-dev]
            }

            ^if(!def $result){
                $result[$version]
            }
        }{

            $matches[^version.match[(.*?)[.-]?dev^$][i]]

            ^if(def $matches){
                $result[^Parsekit/Semver/Constraint/VersionParser:normalizeBranch[$matches.1]]
            }{
                $extraMessage[]
                ^if(^fullVersion.match[ +as +^untaint[regex]{$version}^$][n] > 0){
                    $extraMessage[ in '$fullVersion', the alias must be an exact version]
                }(^fullVersion.match[^^^untaint[regex]{$version} +as +][n] > 0){
                    $extraMessage[ in '$fullVersion', the alias source must be an exact version, if it is a branch name you should prefix it with dev-]
                }
                $errorText[ Invalid version string '$fullVersion' $extraMessage ]
                ^throw[UnexpectedValueException;;$errorText]
            }

        }

    }


    ^if(!def $result){
        ^throw[UnexpectedValueException;;Invalid version string $fullVersion]
    }{
        $self.normalizedVersions.$fullVersion[$result]
    }
}
###


#------------------------------------------------------------------------------
#:param constraints type string
#
#:result Parsekit/Semver/Constraint/ConstraintInterface
#------------------------------------------------------------------------------
@parseConstraints[constraints]
^if(^self.parsedConstraints.contains[$constraints]){
    $result[$self.parsedConstraints.$constraints]
}{
    $prettyConstraint[$constraints]
    $constraints[^constraints.trim[]]

    $matches[^constraints.match[^^([^^,\s]*?)@($self.implodedStabilities)^$][i]]
    ^if($matches){
        $constraints[^if(!def $matches.1){*}{$matches.1}]
    }

    $matches[^constraints.match[^^(dev-[^^,\s@]+?|[^^,\s@]+?\.x-dev)#.+^$][i]]
    ^if($matches){
        $constraints[$matches.1]
    }

    $orConstraints[^self.rsplit[$constraints;(\s*\|\|?\s*)]]
    $orConstraints[^orConstraints.flip[]]
    ^orConstraints.offset(3)
    $orConstraints[$orConstraints.fields]

    $orGroups[^hash::create[]]
    ^orConstraints.foreach[key;constraint]{
        $andConstraints[^self.rsplit[$constraint;(?<!^^|as|[=>< ,]) *(?<!-)[, ](?!-) *(?!,|as|^$)]]
        $andConstraints[^andConstraints.flip[]]
        ^andConstraints.offset(3)
        $andConstraints[$andConstraints.fields]

        ^if(^andConstraints._count[] > 1){
            $constraintObjects[^hash::create[]]
            ^andConstraints.foreach[j;andConstraint]{
                $parsedConstraints[^self.parseConstraint[$andConstraint]]
                ^parsedConstraints.foreach[k;parsedConstraint]{
                    $index[^constraintObjects._count[]]
                    $constraintObjects.$index[$parsedConstraint]
                }
            }
        }{
            $constraintObjects[^self.parseConstraint[^andConstraints._at(0)]]
        }

        $constraint[^if(^constraintObjects._count[] == 1){$constraintObjects.0}{^Parsekit/Semver/Constraint/MultiConstraint::create[$constraintObjects]}]
        $index[^orGroups._count[]]
        $orGroups.$index[$constraint]
    }

# precalucalation for if else params
    ^if(2 == ^orGroups._count[]){
        $a[^orGroups.0.GET[]]
        $b[^orGroups.1.GET[]]
        $posA[^a.pos['<'](4)]
        $posB[^b.pos['<'](4)]
    }

    $multiConstraintClassName[Parsekit/Semver/Constraint/MultiConstraint]
    ^if(1 == ^orGroups._count[]){
        $constraint[$orGroups.0]
    }(2 == ^orGroups._count[]
# parse the two OR groups and if they are contiguous we collapse
# them into one constraint
      && $orGroups.0 is $multiConstraintClassName
      && $orGroups.1 is $multiConstraintClassName
      && ^a.mid(0;3) eq '[>=' && ($posA != -1)
      && ^b.mid(0;3) eq '[>=' && ($posB != -1)
      && ^a.mid($posA + 2;-1) == ^b.mid(4;$posB - 5)
    ){
        $constraint[^Parsekit/Semver/Constraint/MultiConstraint::create[
            $.0[^Parsekit/Semver/Constraint/Constraint::create[>=;^a.mid(4;$posA - 5)]]
            $.1[^Parsekit/Semver/Constraint/Constraint::create[<;^b.mid($posB + 2;-1)]]
        ]]
    }{
        $constraint[^Parsekit/Semver/Constraint/MultiConstraint::create[$orGroups](false)]
    }

    $constraint.prettyString[$prettyConstraint]

    $result[$constraint]
    $self.parsedConstraints.[$prettyConstraint][$result]
}
###


#------------------------------------------------------------------------------
#:param constraint type string
#
#:result hash
#------------------------------------------------------------------------------
@parseConstraint[constraint][result]
^if(^self.parsedConstraint.contains[$constraint]){
    $result[$self.parsedConstraint.$constraint]
}{
    $origin[$constraint]
    $matches[^constraint.match[^^([^^,\s]+?)@($self.implodedStabilities)^$][i]]
    ^if($matches){
        $constraint[$matches.1]

        ^if($matches.2 ne 'stable'){
            $stabilityModifier[$matches.2]
        }
    }

    ^if(^constraint.match[^^v?[xX*](\.[xX*])*^$][i]){
        $result[
            $.0[^Parsekit/Semver/Constraint/EmptyConstraint::create[]]
        ]
    }

    $versionRegex[v?(\d++)(?:\.(\d++))?(?:\.(\d++))?(?:\.(\d++))?${self.modifierRegex}^(?:\+[^^\s]+)?]



# Tilde Range
#
# Like wildcard constraints, unsuffixed tilde constraints say that they must be greater than the previous
# version, to ensure that unstable instances of the current version are allowed. However, if a stability
# suffix is added to the constraint, then a >= match on the current version is used instead.
    $matches[^constraint.match[^^~>?$versionRegex^$][i]]
    ^if(!def $result && $matches){

        ^if(^constraint.mid(0;2) eq '~>'){
            ^throw[UnexpectedValue;;Invalid operator "~>", you probably meant to use the "~" operator]
        }

        ^if(def $matches.4 && '' ne $matches.4){
            $position[4]
        }(def $matches.3 && '' ne $matches.3){
            $position[3]
        }(def $matches.2 && '' ne $matches.2){
            $position[2]
        }{
            $position[1]
        }

        $stabilitySuffix[]
        ^if($matches.5){
            $stabilitySuffix[-^self.expandStability[$matches.5]^if($matches.6){$matches.6}]
        }
        ^if($matches.7){
            $stabilitySuffix[${stabilitySuffix}-dev]
        }
        ^if(!$stabilitySuffix){
            $stabilitySuffix[-dev]
        }

        $lowVersion[^self.manipulateVersionString[$matches.fields;$position;0]$stabilitySuffix]
        $lowerBound[^Parsekit/Semver/Constraint/Constraint::create[>=;$lowVersion]]

        $highPosition[^if(1 > $position - 1){1}($position-1)]
        $highVersion[^self.manipulateVersionString[$matches.fields;$highPosition;1]-dev]
        $upperBound[^Parsekit/Semver/Constraint/Constraint::create[<;$highVersion]]

        $result[
          $.0[$lowerBound]
          $.1[$upperBound]
        ]
    }



# Caret Range
#
# Allows changes that do not modify the left-most non-zero digit in the [major, minor, patch] tuple.
# In other words, this allows patch and minor updates for versions 1.0.0 and above, patch updates for
# versions 0.X >=0.1.0, and no updates for versions 0.0.X
    $matches[^constraint.match[^^\^^$versionRegex^(^$)][i]]
    ^if(!def $result && $matches){

        ^if('0' ne $matches.1 || '' eq $matches.2){
            $position[1]
        }('0' ne $matches.2 || '' eq $matches.3){
            $position[2]
        }{
            $position[3]
        }

# Calculate the stability suffix
        $stabilitySuffix[]
        ^if($matches.5 && !def $matches.7){
            $stabilitySuffix['-dev']
        }

        $tmp[${constraint}$stabilitySuffix]
        $lowVersion[^self.normalize[^tmp.mid(1)]]
        $lowerBound[^Parsekit/Semver/Constraint/Constraint::create[>=;$lowVersion]]
# For upper bound, we increment the position of one more significance,
# but highPosition = 0 would be illegal
        $highVersion[^self.manipulateVersionString[$matches.fields;$position;1]-dev]
        $upperBound[^Parsekit/Semver/Constraint/Constraint::create[<;$highVersion]]

        $result[
            $.0[$lowerBound]
            $.1[$upperBound]
        ]
    }



#X Range
#
#Any of X, x, or * may be used to "stand in" for one of the numeric values in the [major, minor, patch] tuple.
#A partial version range is treated as an X-Range, so the special character is in fact optional.
    $matches[^constraint.match[^^v?(\d++)(?:\.(\d++))?(?:\.(\d++))?(?:\.[xX*])++^$][i]]
    ^if(!def $result && $matches){

        ^if($matches.3 && '' ne $matches.3){
            $position[3]
        }($matches.2 && '' ne $matches.2){
            $position[2]
        }{
            $position[1]
        }

        $lowVersion[^self.manipulateVersionString[$matches.fields;$position]-dev]
        $highVersion[^self.manipulateVersionString[$matches.fields;$position;1]-dev]
        ^if($lowVersion eq '0.0.0.0-dev'){
            $result[
                $.0[^Parsekit/Semver/Constraint/Constraint::create[<;$highVersion]]
            ]
        }{
            $result[
                $.0[^Parsekit/Semver/Constraint/Constraint::create[>=;$lowVersion]]
                $.1[^Parsekit/Semver/Constraint/Constraint::create[<;$highVersion]]
            ]
        }
    }



#Hyphen Range
#
#Specifies an inclusive set. If a partial version is provided as the first version in the inclusive range,
#then the missing pieces are replaced with zeroes. If a partial version is provided as the second version in
#the inclusive range, then all versions that start with the supplied parts of the tuple are accepted, but
#nothing that would be greater than the provided tuple parts.
    $matches[^constraint.match[^^($versionRegex) +- +($versionRegex)(^$)][i]]
    ^if(!def $result && $matches){
#       Calculate the stability suffix
        $lowStabilitySuffix[]
        ^if(!$matches.6 && !$matches.8){
            $lowStabilitySuffix[-dev]
        }
        $lowVersion[^self.normalize[$matches.1]]
        $lowerBound[^Parsekit/Semver/Constraint/Constraint::create[>=;${lowVersion}$lowStabilitySuffix]]

        ^if((!^self.emptyX[$matches.11] && !^self.emptyX[$matches.12]) || !$matches.14 || !$matches.16){
            $highVersion[^self.normalize[$matches.9]]
            $upperBound[^Parsekit/Semver/Constraint/Constraint::create[<=;$highVersion]]
        }{
            $highMatch[
                $.0[]
                $.1[$matches.10]
                $.2[$matches.11]
                $.3[$matches.12]
                $.4[$matches.13]
            ]
            $pos[^if(^self.emptyX[$matches.11]){1}{2}]
            $highVersion[^self.manipulateVersionString[$highMatch;$pos;1]-dev]
            $upperBound[^Parsekit/Semver/Constraint/Constraint::create[<;$highVersion]]
        }

        $result[
            $.0[$lowerBound]
            $.1[$upperBound]
        ]
    }



#Basic Comparators
    $matches[^constraint.match[^^(<>|!=|>=?|<=?|==?)?\s*(.*)][]]
    ^if(!def $result && $matches){

        $version[^self.normalize[$matches.2]]

        ^if(def $stabilityModifier && ^self.parseStability[$version] eq stable){
            $version[${version}-$stabilityModifier]
        }('<' eq $matches.1 || '>=' eq $matches.1){
            $lowerTmp[^matches.2.lower[]]

            ^if(^lowerTmp.match[-$modifierRegex^$][n] > 0){
                ^if(^matches.2.mid(0;4) ne 'dev-'){
                    $version[${version}-dev]
                }
            }
        }

        $result[
            $.0[^Parsekit/Semver/Constraint/Constraint::create[^if(def $matches.1){$matches.1}{=};$version]]
        ]
    }

    $message[Could not parse version constraint $constraint]

    ^if(!def $result){
        ^throw[UnexpectedValueException;;$message]
    }{
        $self.parsedConstraint.$origin[$result]
    }
}
###


#------------------------------------------------------------------------------
#:param x type string
#
#:result bool
#------------------------------------------------------------------------------
@emptyX[x][result]
    ^if($x == 0 || $x eq '0'){
        $result(false)
    }{
        $result(def $x)
    }
###


#------------------------------------------------------------------------------
#:param matches type hash
#:param position
#:param increment
#:param pad
#
#:result string
#------------------------------------------------------------------------------
@manipulateVersionString[matches;position;increment;pad][result;i;ind]
    ^if(!def $pad){
        $pad[0]
    }

    ^for[ind](1;4){
        $i(5 - $ind)

        ^if($i > $position){
            $matches.$i[$pad]
        }($i == $position && $increment){
            $matches.[$i]($matches.$i + $increment)

            ^if($matches.$i < 0){
                $matches.$i[$pad]
                $position($position - 1)

                ^if($i == 1){
                    ^throw[CarryOverflowException;;carry overflow]
                }
            }
        }
    }

    $result[${matches.1}.${matches.2}.${matches.3}.${matches.4}]
###


#------------------------------------------------------------------------------
#:param stability type string
#
#:result string
#------------------------------------------------------------------------------
@expandStability[stability][result]
    $stability[^stability.lower[]]
    ^switch[$stability]{
        ^case[a]{$result[alpha]}
        ^case[b]{$result[beta]}
        ^case[p;pl]{$result[patch]}
        ^case[rc]{$result[RC]}
        ^case[DEFAULT]{$result[$stability]}
    }
###


#------------------------------------------------------------------------------
#Regexp split by Misha.v3
#http://www.parser.ru/examples/rsplit/
#------------------------------------------------------------------------------
@rsplit[sText;sRegex;sDelimiter][result]
^if(def $sText && def $sRegex){
	$result[^sText.match[(.+?)(?:$sRegex|^$)][g]]
}{
	$result[^table::create{1}]
}
^if(def $sDelimiter){
	^if($result && (^sDelimiter.pos[r]>=0 || ^sDelimiter.pos[R]>=0)){
		$result[^table::create[$result;$.reverse(true)]]
	}
	^if(^sDelimiter.pos[v]>=0 || ^sDelimiter.pos[V]>=0){
		$result[^result.flip[]]
	}
}
###
