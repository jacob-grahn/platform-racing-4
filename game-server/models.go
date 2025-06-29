package main

// Module is a string that represents the type of message being sent.
type Module string

const (
	// JoinRoomModule is the module for joining a room.
	JoinRoomModule Module = "join-room"
	// JoinRoomSuccessModule is the module for a successful room join.
	JoinRoomSuccessModule Module = "join-room-success"
	// EditorModule is the module for the level editor.
	EditorModule Module = "editor"
	// ChatModule is the module for chat messages.
	ChatModule Module = "chat"
)

// AuthenticatedClient is a wrapper for a client and a message.
type AuthenticatedClient struct {
	Client  *Client
	Message []byte
}

// ChatUpdate is a struct for chat messages.
type ChatUpdate struct {
	Message string `json:"message"`
}

// LevelEditorContent contains the actual editor data.
type LevelEditorContent struct {
	Data string `json:"data"`
}

// LevelEditorIncomingUpdate for client actions within the editor.
type LevelEditorIncomingUpdate struct {
	Module Module              `json:"module"`
	Chat   *ChatUpdate         `json:"chat,omitempty"`
	Editor *LevelEditorContent `json:"editor,omitempty"` // For EditorModule
	ID     string              `json:"id"`
}

// LevelEditorOutgoingUpdate for broadcasting state changes to clients.
type LevelEditorOutgoingUpdate struct {
	Module       Module              `json:"module"`
	FromUser     string              `json:"from_user"`
	Chat         *ChatUpdate         `json:"chat,omitempty"`
	Editor       *LevelEditorContent `json_:"editor,omitempty"`
	MemberIDList []string            `json:"member_id_list,omitempty"`
	Timestamp    int64               `json:"timestamp"`
}

// IncomingJoinUpdate is sent by the client to join (or create) a room.
type IncomingJoinUpdate struct {
	Module   Module `json:"module"`
	Room     string `json:"room"`
	RoomType string `json:"room_type"`
	ID       string `json:"id"` // Client ID
}

// OutgoingJoinUpdate is sent back to the client to confirm the result.
type OutgoingJoinUpdate struct {
	Module       Module   `json:"module"`
	Success      bool     `json:"success"`
	Room         string   `json:"room"`
	ErrorMessage string   `json:"error_message,omitempty"`
	MemberIDList []string `json:"member_id_list,omitempty"`
}
