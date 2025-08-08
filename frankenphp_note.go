package frankenphp_note

import (
	"C"
	"fmt"
	"sync"
)

// Thread-local storage for notes
var (
	notesMutex sync.RWMutex
	notesMap   = make(map[string]string)
)

//export frankenphp_note
func frankenphp_note(key *C.char, value *C.char) *C.char {
	keyStr := C.GoString(key)
	
	// If value is provided, set the note
	if value != nil {
		valueStr := C.GoString(value)
		notesMutex.Lock()
		notesMap[keyStr] = valueStr
		notesMutex.Unlock()
		return C.CString(valueStr)
	}
	
	// If no value provided, get the note
	notesMutex.RLock()
	defer notesMutex.RUnlock()
	if valueStr, exists := notesMap[keyStr]; exists {
		return C.CString(valueStr)
	}
	
	return C.CString("")
}

//export frankenphp_note_clear
func frankenphp_note_clear() C.int {
	notesMutex.Lock()
	defer notesMutex.Unlock()
	
	// Clear all notes for the current request
	notesMap = make(map[string]string)
	
	return 0
}

//export frankenphp_note_get_all
func frankenphp_note_get_all() *C.char {
	notesMutex.RLock()
	defer notesMutex.RUnlock()
	
	// Return all notes as JSON string
	result := "{"
	first := true
	for key, value := range notesMap {
		if !first {
			result += ","
		}
		result += fmt.Sprintf(`"%s":"%s"`, key, value)
		first = false
	}
	result += "}"
	
	return C.CString(result)
}


