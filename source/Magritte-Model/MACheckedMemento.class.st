"
Besides caching values like my superclass, I also remember the original values of the model at the time the cache is built. With this information I am able to detect edit conflicts and can prevent accidental loss of data by merging the changes.
"
Class {
	#name : #MACheckedMemento,
	#superclass : #MACachedMemento,
	#instVars : [
		'original'
	],
	#category : #'Magritte-Model-Memento'
}

{ #category : #testing }
MACheckedMemento >> hasConflict [
	"Answer ==true==, if there is an edit conflict."

	^ self hasChanges and: [ self hasModelChangedElsewhere ]
]

{ #category : #testing }
MACheckedMemento >> hasModelChangedElsewhere [
	^ self isDifferent: self original to: self pullRaw
]

{ #category : #accessing }
MACheckedMemento >> original [
	^ original
]

{ #category : #actions }
MACheckedMemento >> reset [
	super reset.
	self setOriginal: (self pullRawTransforming: [ :e | e copy ]).
	
	"Implementation note: We copy the field values because checked mementos compare this to the current object to see if it has changed elsewhere. Unless we make a copy each time, this comparison would not be possible for complex objects, because any changes to them from outside will be reflected equally in this `original` dictionary. E.g. if `original at: #person == self model person` and outside someone does `self model person age: 25`, the check above would pass even though it should fail."
]

{ #category : #initialization }
MACheckedMemento >> setOriginal: aDictionary [
	original := aDictionary
]

{ #category : #'private-testing' }
MACheckedMemento >> shouldPush: anObject using: aDescription [

	| originalValue cachedValue |
	originalValue := self original at: aDescription.
	cachedValue := self cache at: aDescription.
	^ (originalValue = cachedValue) not and: [ super shouldPush: anObject using: aDescription ]
]

{ #category : #actions }
MACheckedMemento >> validate [
	self hasConflict
		ifFalse: [ ^ super validate ].
	self reset.
	MAConflictError
		description: self magritteDescription
		signal: self magritteDescription conflictErrorMessage
]
