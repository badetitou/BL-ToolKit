Trait {
	#name : #TCSNExporter,
	#instVars : [
		'currentWriteStream',
		'indentLevel',
		'indentNumber'
	],
	#category : #'Casino-Exporter'
}

{ #category : #'instance creation' }
TCSNExporter classSide >> on: aStream [
	^ self new
		currentWriteStream: aStream;
		yourself
]

{ #category : #streaming }
TCSNExporter >> << elements [
  self indent.
  currentWriteStream << elements
]

{ #category : #streaming }
TCSNExporter >> <<< elements [
  currentWriteStream << elements
]

{ #category : #streaming }
TCSNExporter >> crlf [
  ^ self <<< String crlf 
]

{ #category : #accessing }
TCSNExporter >> currentWriteStream [
	^ currentWriteStream
]

{ #category : #accessing }
TCSNExporter >> currentWriteStream: anObject [
	currentWriteStream := anObject
]

{ #category : #streaming }
TCSNExporter >> indent [
  1 to: self indentLevel * self indentNumber do: [:i |  currentWriteStream << self indentCharacter ]
]

{ #category : #streaming }
TCSNExporter >> indentCharacter [
	^ String space
]

{ #category : #streaming }
TCSNExporter >> indentLevel [
	^ indentLevel ifNil: [ indentLevel := 0 ]
]

{ #category : #streaming }
TCSNExporter >> indentLevel: aLevel [
	indentLevel := aLevel
]

{ #category : #streaming }
TCSNExporter >> indentMinus [
	^ indentLevel := indentLevel - 1
]

{ #category : #streaming }
TCSNExporter >> indentNumber [
	^ 4
]

{ #category : #streaming }
TCSNExporter >> indentPlus [
	^ indentLevel := indentLevel + 1
]