Extension { #name : #BLCenterAlignement }

{ #category : #'*BL-Model-CoreWeb-Importer' }
BLCenterAlignement >> angularHorizontalAlignement [
	^ 'p-justify-around'
]

{ #category : #'*BL-Model-CoreWeb-Importer' }
BLCenterAlignement >> angularValue [
	^ 'text-align: center;'
]

{ #category : #'*BL-Model-CoreWeb-Importer' }
BLCenterAlignement class >> generateWithHorizontal: horizontal [
	^ horizontal = 'HasHorizontalAlignment.ALIGN_LEFT'
		ifTrue: [ BLWestAlignement new ]
		ifFalse: [ horizontal = 'HasHorizontalAlignment.ALIGN_RIGHT'
				ifTrue: [ BLEastAlignement new ]
				ifFalse: [ horizontal isNil ifTrue: [ nil ] ifFalse: [ BLCenterAlignement new ] ] ]
]