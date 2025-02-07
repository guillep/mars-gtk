Class {
	#name : #GtkButtonAdapter,
	#superclass : #GtkBaseButtonAdapter,
	#category : #'Mars-Spec-Adapter'
}

{ #category : #building }
GtkButtonAdapter >> addModelTo: gtkButton [

	super addModelTo: gtkButton.

	self presenter contextMenu ifNotNil: [ :menu |
		self addMenu: menu to: gtkButton ].

	gtkButton connectClicked: [ 
		self presenter performAction ]
]

{ #category : #events }
GtkButtonAdapter >> clicked [

	self widget clicked
]

{ #category : #factory }
GtkButtonAdapter >> newWidget [ 
	
	^ GtkButton newLabel: self model label asString
]
