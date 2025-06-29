package main

// Module is a type for the module of an update.
type Module string

// ErrorMessage is a type for the error message of an update.
type ErrorMessage string

const (
	// JoinRoomModule is the module for joining a room.
	JoinRoomModule Module = "join-room"
	// JoinRoomSuccessModule is the module for a successful room join.
	JoinRoomSuccessModule Module = "join-room-success"
	// QuitEditorModule is the module for quitting the editor.
	QuitEditorModule Module = "quit-editor"
	// EditorModule is the module for the editor.
	EditorModule Module = "editor"
	// ChatModule is the module for the chat.
	ChatModule Module = "chat"
	// PositionModule is the module for the position.
	PositionModule Module = "position"

	// RoomNotFoundErrorMessage is the error message for a room not found.
	RoomNotFoundErrorMessage ErrorMessage = "room-not-found"
	// UnknownRoomTypeErrorMessage is the error message for an unknown room type.
	UnknownRoomTypeErrorMessage ErrorMessage = "unknown-room-type"
)

// ChatUpdate for chat messages.
type ChatUpdate struct {
	Message string `json:"message,omitempty"`
}
