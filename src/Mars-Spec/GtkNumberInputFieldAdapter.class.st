Class {
	#name : #GtkNumberInputFieldAdapter,
	#superclass : #GtkTextInputFieldAdapter,
	#category : #'Mars-Spec-Adapter'
}

{ #category : #building }
GtkNumberInputFieldAdapter >> addModelTo: gtkSpinButton [

	super addModelTo: gtkSpinButton.
	
	gtkSpinButton 
		beNumber;
		rangeMinimum: (self model minimum ifNil: [ Float fmin ]) 
			maximum: (self model maximum ifNil: [ Float fmax ]).
	
	self model isFloat ifTrue: [ 
		gtkSpinButton digits: self model digits ].
	self model climbRate ifNotNil: [ :rate |
		gtkSpinButton climbRate: rate ]
]

{ #category : #building }
GtkNumberInputFieldAdapter >> newWidget [ 

	^ self widgetClass 
		newAdjustment: GtkAdjustment newDefault
		climbRate: 1.0 
		digits: 0
]

{ #category : #private }
GtkNumberInputFieldAdapter >> refreshText [
	
	self widgetDo: [ :w |
		w value: self model number ]
]

{ #category : #accessing }
GtkNumberInputFieldAdapter >> setText: aString to: gtkWidget [

	gtkWidget value: (aString 
		ifNotEmpty: [ aString asNumber asFloat ]
		ifEmpty: [ 0.0 ])
]

{ #category : #building }
GtkNumberInputFieldAdapter >> widgetClass [ 

	^ GtkSpinButton
]
