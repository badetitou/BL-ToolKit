accessing
viewDependancyHeritCoreAndReferencesAndDepth: theDepth
	| view nodes references lb |
	nodes := self modelWidget asSet.
	1 to: theDepth do: [ :val | nodes addAll: (nodes collect: #superclass thenSelect: #isNotNil) ].
	nodes := nodes select: [ :el | (self isClassFromGWT: el) or: (self isClassFromWidget: el) ].
	references := (nodes
		collect: [ :a | 
			a
				-> (((a queryIncoming: FAMIXInvocation) atScope: FAMIXClass) collect: [ :b | Association new key: b value: a ] thenSelect: [ :b | self modelWidget includes: b value ]) ])
		asDictionary.
	view := RTMondrian new.
	view shape rectangle
		color: [ :cl | 
			(self isClassFromGWT: cl)
				ifTrue: [ Color blue ]
				ifFalse: [ Color green ] ];
		height: [ :cl | cl methods size ];
		width: [ :cl | (references at: cl) size ].
	view nodes: {nodes} flatten asSet.
	(view shape line arrowedLine headOffset: 1.0) shape head
		baseSize: 5.0;
		size: 8.
	view edgesFrom: #superclass.
	view treeLayout
		verticalGap: 10;
		horizontalGap: 10.
	lb := RTLegendBuilder new.
	lb
		view: view view;
		right.
	lb addText: 'Legende'.
	lb addColor: Color blue text: 'Class from GWT'.
	lb addColor: Color green text: 'Other Class (from BlCore)'.
	lb addRectanglePolymetricWidth: 'number of references' height: 'number of methods' box: 'aWidget'.
	lb addLineColor: Color gray text: 'superclass'.
	lb build.
	^ view