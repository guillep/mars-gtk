Class {
	#name : #GtkCodeAdapter,
	#superclass : #GtkTextAdapter,
	#instVars : [
		'completionProvider'
	],
	#category : #'Mars-Spec-Adapter'
}

{ #category : #building }
GtkCodeAdapter >> addModelTo: gtkTextView [ 

	self addSourceFeaturesTo: gtkTextView.
	
	self model contextKeyBindings ifNotNil: [ :aCategory | 
		aCategory allEntries keymaps do: [ :each |
			self 
				bindKeyCombination: each shortcut 
				toAction: each action ] ].
	
	super addModelTo: gtkTextView
]

{ #category : #building }
GtkCodeAdapter >> addMonospaceStyleFor: gtkTextView [
	
	gtkTextView styleContext addClass: 'code'
]

{ #category : #building }
GtkCodeAdapter >> addSourceFeaturesTo: gtkSourceView [
	
	self flag: #TODO. "Find a better way to validate this"
	(gtkSourceView isKindOf: GtkSourceView) ifFalse: [ ^ self ].
	  
	self flag: #TODO. "All this needs to come from settings"
	gtkSourceView 
		showLineNumbers: true;
		autoIndent: true;
		indentOnTab: true;
		tabWidth: 4.

	gtkSourceView textBuffer 
		infiniteUndoLevels;
		highlightMatchingBrackets: true.
		
	gtkSourceView completion
		showHeaders: false;
		showIcons: true;
		addProvider: (completionProvider := GtkPharoSourceCompletionProvider new
			completionClass: self behavior;
			yourself)
]

{ #category : #building }
GtkCodeAdapter >> addTextTo: gtkTextView [
	
	"gtkTextView monospace: true."
	self addMonospaceStyleFor: gtkTextView.
	"add style table"
	self model hasSyntaxHighlight ifTrue: [ 
		self flag: #TODO. "What do we do when color style changes?"
		gtkTextView textBuffer: (self bufferClass newTable: GtkTextTagTable newForCode).
		"I need to recalculate style each time I get a change"
		gtkTextView textBuffer connectChanged: [ 
			self applyFullStyleTo: gtkTextView textBuffer ] ]	.
		
	super addTextTo: gtkTextView
]

{ #category : #visiting }
GtkCodeAdapter >> applyFullStyleTo: textBuffer [

	textBuffer userActionDuring: [ 
		self applyStyleTo: textBuffer ]
]

{ #category : #visiting }
GtkCodeAdapter >> applyStyleTo: textBuffer [

	self model hasSyntaxHighlight ifFalse: [ ^ self ].

	textBuffer removeAllTags.
	self behavior 
		ifNotNil: [ :aBehavior | 
			self setMethodText: textBuffer text class: aBehavior toBuffer: textBuffer ]
		ifNil: [ 
			self setExpressionText: textBuffer text toBuffer: textBuffer ]
]

{ #category : #'api-shout' }
GtkCodeAdapter >> behavior [

	^ self model behavior
]

{ #category : #building }
GtkCodeAdapter >> bufferClass [

	^ GtkSourceViewLibrary uniqueInstance isAvailable 
		ifTrue: [ GtkSourceBuffer ]
		ifFalse: [ super bufferClass ]
]

{ #category : #'private-shout' }
GtkCodeAdapter >> classOrMetaClass: aClass [
	"I will take the behavior from model, I just need to fire a refresh"

	self applyStyleTo: self innerWidget textBuffer.
	self updateCompletionProvider	
]

{ #category : #'private-shout' }
GtkCodeAdapter >> setExpressionText: aString toBuffer: textBuffer [ 

	(GtkTextStyleVisitor new 
		styleExpression: aString)
		do: [ :each | each acceptTextBuffer: textBuffer ].

]

{ #category : #'private-shout' }
GtkCodeAdapter >> setMethodText: aString class: aClass toBuffer: textBuffer [ 

	(GtkTextStyleVisitor new 
		contextClass: aClass;
		styleMethod: aString)
		do: [ :each | each acceptTextBuffer: textBuffer ].

]

{ #category : #private }
GtkCodeAdapter >> textWithStyle [

	^ self innerWidget textBuffer asText
]

{ #category : #'private-shout' }
GtkCodeAdapter >> updateCompletionProvider [	
	
	completionProvider ifNotNil: [ :p | 
		p completionClass: self behavior ]
]

{ #category : #building }
GtkCodeAdapter >> widgetClass [

	^ GtkSourceViewLibrary uniqueInstance isAvailable 
		ifTrue: [ GtkSourceView ]
		ifFalse: [ super widgetClass ]
]
