package main

import "time"

// Room is an interface for a room that can handle updates.
type Room interface {
	GetName() string
	GetHostID() string
	GetMembersID() []string
	AddMember(string)
	RemoveMember(string)
	HandleUpdate(*Update, *Hub)
}

// BaseRoom is a struct that contains the basic information for a room.
type BaseRoom struct {
	Name      string
	HostID    string
	MembersID []string
}

// GetName returns the name of the room.
func (r *BaseRoom) GetName() string {
	return r.Name
}

// GetHostID returns the ID of the host of the room.
func (r *BaseRoom) GetHostID() string {
	return r.HostID
}

// GetMembersID returns the IDs of the members of the room.
func (r *BaseRoom) GetMembersID() []string {
	return r.MembersID
}

// AddMember adds a member to the room.
func (r *BaseRoom) AddMember(memberID string) {
	r.MembersID = append(r.MembersID, memberID)
}

// RemoveMember removes a member from the room.
func (r *BaseRoom) RemoveMember(memberID string) {
	for i, id := range r.MembersID {
		if id == memberID {
			r.MembersID = append(r.MembersID[:i], r.MembersID[i+1:]...)
			return
		}
	}
}

// LevelEditorRoom is a room for editing levels.
type LevelEditorRoom struct {
	BaseRoom
}

// NewLevelEditorRoom creates a new level editor room.
func NewLevelEditorRoom(name, hostID string) *LevelEditorRoom {
	return &LevelEditorRoom{
		BaseRoom: BaseRoom{
			Name:      name,
			HostID:    hostID,
			MembersID: []string{hostID},
		},
	}
}

// HandleUpdate handles updates for the level editor room.
func (r *LevelEditorRoom) HandleUpdate(update *Update, h *Hub) {
	switch Module(update.Module) {
	case JoinEditorModule:
		r.AddMember(update.ID)
		update.Module = string(JoinSuccessModule)
		update.MemberIDList = r.GetMembersID()
		update.HostID = r.GetHostID()
	case QuitEditorModule:
		r.RemoveMember(update.ID)
		if r.GetHostID() == update.ID {
			if len(r.GetMembersID()) > 0 {
				r.HostID = r.GetMembersID()[0]
			} else {
				h.removeRoom(r.GetName())
			}
		}
		update.Module = string(QuitSuccessModule)
		update.MemberIDList = r.GetMembersID()
		update.HostID = r.GetHostID()
	case RequestEditorModule:
		update.TargetUserID = r.GetHostID()
	case ResponseEditorModule:
		// No special handling needed
	case RequestRoomModule:
		update.Module = string(ResponseRoomModule)
		update.MemberIDList = r.GetMembersID()
		update.HostID = r.GetHostID()
	case EditorModule:
		if update.Editor == nil {
			update.Editor = &LevelEditorUpdate{}
		}
		update.Editor.Timestamp = time.Now().UnixMilli()
	case ChatModule:
		// simply pass the chat message along
	default:
		h.setError(update, UnknownModuleErrorMessage, update.ID)
	}
}

// GameRoom is a room for playing the game.
type GameRoom struct {
	BaseRoom
}

// NewGameRoom creates a new game room.
func NewGameRoom(name, hostID string) *GameRoom {
	return &GameRoom{
		BaseRoom: BaseRoom{
			Name:      name,
			HostID:    hostID,
			MembersID: []string{hostID},
		},
	}
}

// HandleUpdate handles updates for the game room.
func (r *GameRoom) HandleUpdate(update *Update, h *Hub) {
	switch Module(update.Module) {
	case PositionModule:
		// Handle position updates
	case ChatModule:
		// simply pass the chat message along
	default:
		h.setError(update, UnknownModuleErrorMessage, update.ID)
	}
}
