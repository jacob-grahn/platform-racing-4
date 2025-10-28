package main

// Module is a string that represents the type of message being sent.
type Module string

const (
	// EditorModule is the module for the level editor.
	EditorModule Module = "editor"
)

// AuthenticatedClient is a wrapper for a client and a message.
type AuthenticatedClient struct {
	Client  *Client
	Message []byte
}

// LevelEditorContent contains the actual editor data.
type LevelEditorContent struct {
	Data string `json:"data"`
}

// LevelEditorIncomingUpdate for client actions within the editor.
type LevelEditorIncomingUpdate struct {
	Module Module              `json:"module"`
	Editor *LevelEditorContent `json:"editor,omitempty"` // For EditorModule
	ID     string              `json:"id"`
}

// LevelEditorOutgoingUpdate for broadcasting state changes to clients.
type LevelEditorOutgoingUpdate struct {
	Module       Module              `json:"module"`
	FromUser     string              `json:"from_user"`
	Editor       *LevelEditorContent `json_:"editor,omitempty"`
	MemberIDList []string            `json:"member_id_list,omitempty"`
	Timestamp    int64               `json:"timestamp"`
}
