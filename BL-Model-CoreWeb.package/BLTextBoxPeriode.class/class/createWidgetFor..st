as yet unclassified
createWidgetFor: anInvocation
	| widget |
	widget := super createWidgetFor: anInvocation.
	widget parameters at: #selectionMode put: 'range'.
	^ widget