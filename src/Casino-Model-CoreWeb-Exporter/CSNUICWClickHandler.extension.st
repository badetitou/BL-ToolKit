Extension { #name : #CSNUICWClickHandler }

{ #category : #'*Casino-Model-CoreWeb-Exporter' }
CSNUICWClickHandler >> extractMethodNamed: methodsName from: methodsText [
	"I return the content of onClick generated method"

	| beginPos endPos |
	beginPos := (((methodsName , '\([^()]*\) \{') asRegex matchingRangesIn: methodsText) collect: [ :a | a first ]) at: 1.
	endPos := methodsText findCloseBracketFor: (methodsText indexOf: ${ startingAt: beginPos).
	^ methodsText copyFrom: beginPos to: endPos
]