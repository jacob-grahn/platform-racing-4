package main

import "time"

// LevelEditorRoom is a room for editing levels.
type LevelEditorRoom struct {
	BaseRoom
}

// NewLevelEditorRoom creates a new level editor room.
func NewLevelEditorRoom(name string) *LevelEditorRoom {
	return &LevelEditorRoom{
		BaseRoom: NewBaseRoom(name, 99999),
	}
}

// HandleUpdate handles updates for the level editor room.
func (r *LevelEditorRoom) HandleUpdate(update *Update, h *Hub) {
	r.BaseRoom.HandleUpdate(update, h, r.handleSpecificUpdate)
}

func (r *LevelEditorRoom) handleSpecificUpdate(update *Update, h *Hub) {
	switch Module(update.Module) {
	case JoinEditorModule:
		r.AddMember(update.ID, h)
		update.Module = string(JoinSuccessModule)
		update.MemberIDList = r.GetMembersID()
	case QuitEditorModule:
		r.RemoveMember(update.ID)
		if len(r.GetMembersID()) == 0 {
			h.removeRoom(r.GetName())
		}
		update.Module = string(QuitSuccessModule)
		update.MemberIDList = r.GetMembersID()
	case RequestEditorModule:
		// broadcast to all members
	case ResponseEditorModule:
		// No special handling needed
	case RequestRoomModule:
		update.Module = string(ResponseRoomModule)
		update.MemberIDList = r.GetMembersID()
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
