#!/bin/bash
# This script builds a swf containing all classes located under the org.swiftsuspenders.support.injectees 
# and .types packages in the test directory of the Swiftsuspenders project.
# Run it whenever these types change in meaningful ways in order to be able to properly run the tests that exercise 
# Swiftsuspenders' dealing with child ApplicationDomains.
#
# The script expects the mxmlc compiler to be available in the shell's PATH.

cd `dirname $0`
#remove existing files
[ -e "app-domain-support.swf" ] && rm app-domain-support.swf

#create list of classes to include. We want to include everything in the 'support.injectees' package
addInjecteesFromDir()
{
	for entry in $1/*;
	do
		if [ -d $entry ];
		then
			addInjecteesFromDir $entry
		else
			injectees+=${entry//\//.}","
		fi
	done
}
injectees=""
addInjecteesFromDir ../../../test/org/swiftsuspenders/support/injectees
addInjecteesFromDir ../../../test/org/swiftsuspenders/support/types
injectees=${injectees//".........test."/}
injectees=${injectees//".as,"/,}

#compile swf
mxmlc -debug -source-path=../../../src,../../../test -output=app-domain-support.swf -static-link-runtime-shared-libraries=true -includes=$injectees ../../../test/org/swiftsuspenders/support/AppDomainSupportSWFSprite.as
