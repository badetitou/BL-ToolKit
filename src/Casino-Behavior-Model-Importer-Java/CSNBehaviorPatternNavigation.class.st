Class {
	#name : #CSNBehaviorPatternNavigation,
	#superclass : #CSNBehaviorPattern,
	#category : #'Casino-Behavior-Model-Importer-Java-Pattern'
}

{ #category : #running }
CSNBehaviorPatternNavigation >> newNavigation [
	^ self model silentlyAdd: CSNBNavigation new
]

{ #category : #running }
CSNBehaviorPatternNavigation >> run [
	self model allFASTJavaIdentifier
		select: [ :identifier | 
			identifier name = 'Workspace'
				and: [ identifier parentNode isNotNil
						and: [ identifier parentNode name = 'getPhaseManager'
								and: [ identifier parentNode parentNode isNotNil and: [ identifier parentNode parentNode name = 'displayPhase' and: [ identifier parentNode parentNode class = FASTJavaMethodInvocation ] ] ] ] ] ]
		thenDo: [ :identifier | 
			| navigation |
			navigation := self newNavigation.
			identifier parentNode parentNode parentNode expression: navigation. 
			(self tryComputePagefor: navigation from: identifier) ifFalse: [ | arguments | 
				arguments := identifier parentNode parentNode arguments asOrderedCollection.
				arguments do: #removeAllPotentialParentNode.
				navigation arguments addAll: arguments ].
			identifier parentNode parentNode removeAllPotentialParentNode.
			self model silentlyRemoveAll: {identifier parentNode parentNode . identifier parentNode . identifier} ]
]

{ #category : #running }
CSNBehaviorPatternNavigation >> tryComputePagefor: navigation from: identifier [
	self uiModel ifNil: [ ^ false ].
	^ (self uiModel allCSNPage
		select: [ :page | (identifier parentNode parentNode arguments first allToScope: FASTJavaMethodInvocation) anySatisfy: [ :possibleInvocation | possibleInvocation name = page codePhase ] ])
		ifNotEmpty: [ :page | 
			navigation page: page anyOne.
			true ]
		ifEmpty: [ false ]
]
