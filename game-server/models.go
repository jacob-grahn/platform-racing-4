package main

// Module is a type for the module of an update.
type Module string

// ErrorMessage is a type for the error message of an update.
type ErrorMessage string

const (
	// JoinEditorModule is the module for joining the editor.
	JoinEditorModule Module = "join-editor"
	// HostEditorModule is the module for hosting the editor.
	HostEditorModule Module = "host-editor"
	// QuitEditorModule is the module for quitting the editor.
	QuitEditorModule Module = "quit-editor"
	// RequestEditorModule is the module for requesting the editor.
	RequestEditorModule Module = "request-editor"
	// ResponseEditorModule is the module for responding to the editor.
	ResponseEditorModule Module = "response-editor"
	// RequestRoomModule is the module for requesting the room.
	RequestRoomModule Module = "request-room"
	// EditorModule is the module for the editor.
	EditorModule Module = "editor"
	// ChatModule is the module for the chat.
	ChatModule Module = "chat"
	// PositionModule is the module for the position.
	PositionModule Module = "position"

	// JoinSuccessModule is the module for a successful join.
	JoinSuccessModule Module = "join-success"
	// HostSuccessModule is the module for a successful host.
	HostSuccessModule Module = "host-success"
	// QuitSuccessModule is the module for a successful quit.
	QuitSuccessModule Module = "quit-success"
	// ResponseRoomModule is the module for a successful room response.
	ResponseRoomModule Module = "response-room"

	// RoomNotFoundErrorMessage is the error message for a room not found.
	RoomNotFoundErrorMessage ErrorMessage = "room-not-found"
	// RoomExistsErrorMessage is the error message for a room that already exists.
	RoomExistsErrorMessage ErrorMessage = "room-exists"
	// EmptyErrorMessage is the error message for an empty error.
	EmptyErrorMessage ErrorMessage = ""
	// UnknownModuleErrorMessage is the error message for an unknown module.
	UnknownModuleErrorMessage ErrorMessage = "unknown-module"
	// UnknownRoomTypeErrorMessage is the error message for an unknown room type.
	UnknownRoomTypeErrorMessage ErrorMessage = "unknown-room-type"
)

// Update is a struct that represents an update from a client.
type Update struct {
	Module       string             `json:"module"`
	ID           string             `json:"id"`
	Room         string             `json:"room"`
	RoomType     string             `json:"room_type"`
	Ret          bool               `json:"ret"`
	TargetUserID string             `json:"target_user_id"`
	ErrorMessage string             `json:"error_message"`
	MemberIDList []string           `json:"member_id_list"`
	HostID       string             `json:"host_id"`
	Editor       *LevelEditorUpdate `json:"editor,omitempty"`
}

// LevelEditorUpdate is a struct that represents an update to the level editor.
type LevelEditorUpdate struct {
	Timestamp int64  `json:"timestamp"`
	Data      string `json:"data"`
}
