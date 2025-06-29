package main

import (
	"encoding/json"
	"sync"
	"time"
)

// Room is an interface for a room that can handle updates.
type Room interface {
	GetName() string
	GetMembersID() []string
	GetLastUpdateTime() time.Time
	AddMember(string, *Hub)
	RemoveMember(string)
	HandleUpdate(*Update, *Hub)
	SetMaxUpdates(int)
}

// BaseRoom is a struct that contains the basic information for a room.
type BaseRoom struct {
	Name           string
	MembersID      []string
	updates        []*Update
	MaxUpdates     int
	lastUpdateTime time.Time
	mu             sync.RWMutex
}

// NewBaseRoom creates a new base room.
func NewBaseRoom(name string, maxUpdates int) BaseRoom {
	return BaseRoom{
		Name:           name,
		MembersID:      []string{},
		MaxUpdates:     maxUpdates,
		lastUpdateTime: time.Now(),
	}
}

// GetName returns the name of the room.
func (r *BaseRoom) GetName() string {
	return r.Name
}

// GetMembersID returns the IDs of the members of the room.
func (r *BaseRoom) GetMembersID() []string {
	return r.MembersID
}

// GetLastUpdateTime returns the last update time of the room.
func (r *BaseRoom) GetLastUpdateTime() time.Time {
	return r.lastUpdateTime
}

// AddMember adds a member to the room and sends them the update history.
func (r *BaseRoom) AddMember(memberID string, h *Hub) {
	r.mu.Lock()
	r.MembersID = append(r.MembersID, memberID)
	updates := make([]*Update, len(r.updates))
	copy(updates, r.updates)
	r.mu.Unlock()

	go r.sendInitialUpdates(memberID, updates, h)
}

// sendInitialUpdates sends the initial updates to a new member.
func (r *BaseRoom) sendInitialUpdates(memberID string, updates []*Update, h *Hub) {
	for _, update := range updates {
		// Create a copy of the update to avoid modifying the original
		updateCopy := *update
		updateCopy.TargetUserID = memberID
		updateCopy.Ret = true // Ensure the update is sent

		jsonData, err := json.Marshal(updateCopy)
		if err != nil {
			// Handle error, maybe log it
			continue
		}

		for client := range h.clients {
			if client.ID == memberID {
				select {
				case client.send <- jsonData:
				default:
					close(client.send)
					delete(h.clients, client)
				}
				break // Found the client, no need to check others
			}
		}
	}
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

// SetMaxUpdates sets the maximum number of updates to store in the room.
func (r *BaseRoom) SetMaxUpdates(maxUpdates int) {
	r.MaxUpdates = maxUpdates
}

// HandleUpdate stores and handles updates for the room.
func (r *BaseRoom) HandleUpdate(update *Update, h *Hub, handleSpecificUpdate func(*Update, *Hub)) {
	r.mu.Lock()
	r.updates = append(r.updates, update)
	if len(r.updates) > r.MaxUpdates {
		r.updates = r.updates[len(r.updates)-r.MaxUpdates:]
	}
	r.lastUpdateTime = time.Now()
	r.mu.Unlock()

	handleSpecificUpdate(update, h)
}
