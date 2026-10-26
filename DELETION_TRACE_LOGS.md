# Document Deletion Trace Logs - Investigation Summary

**Date:** 2026-10-22  
**Issue:** Documents appear deleted but reappear after refresh. Subject cards show stale file counts.

## Problem Analysis

### Observed Behavior
1. ✅ Deleting documents appears to work initially
2. ✅ Opening the subject shows "This subject has no files"
3. ❌ Library view shows stale file counts (e.g., "9 files", "24 files")
4. ❌ Reopening the subject brings deleted files back

### Root Cause Hypothesis
Different parts of the app are reading from different sources:
- **Subject cards** count files from a cached/stale document list
- **Subject view** reads from the same list but filters differently
- **Firestore deletion** may complete, but streams not updating
- **Local UI state** (`_deletingDocIds`) only hides docs temporarily

---

## Data Flow Architecture

### 1. Document Deletion Flow
```
UI (library_screen.dart)
  └─> KnowledgeEngine.deleteDocument()
      ├─> Step 1: Delete from Firebase Storage
      │   └─> FirebaseUploadService.deleteStoredDocument()
      ├─> Step 2: Delete from Firestore
      │   └─> FirestoreService.deleteDocument()
      │       ├─> Delete document from subjects/{subjectId}/documents/{docId}
      │       ├─> Decrement user's documentsUploaded count
      │       ├─> Delete related chat sessions
      │       ├─> Delete knowledge index entries
      │       └─> Delete generation cache entries
      └─> Step 3: Invalidate cache
          └─> KnowledgeEngine.invalidateSubjectContext()
```

### 2. Document Stream Flow
```
FirestoreService.streamUserDocuments(userId)
  └─> Creates live Firestore listeners for each subject
      └─> Listens to subjects/{subjectId}/documents subcollection
          └─> Emits List<FirestoreDocumentModel>
              └─> Provider: userDocumentsStreamProvider(userId)
                  └─> UI: ref.watch(userDocumentsStreamProvider(userId))
```

### 3. Subject Card File Count
```
_SubjectExplorer widget
  └─> Gets documents from userDocumentsStreamProvider
      └─> Counts files per subject by filtering:
          documents.where((doc) => 
            doc.subjectId == id || 
            folders.contains(doc.subjectId) ||
            folders.contains(doc.folderId))
```

### 4. Subject View Document List
```
_openSubject()
  └─> Reads from ref.read(userDocumentsStreamProvider(userId))
      └─> Filters: _documentsForSubject(id, documents, items)
          └─> Same logic as subject card counting
```

---

## Comprehensive Logging Added

### 🖱️ UI Layer (library_screen.dart)
**Location:** Delete handler (`_onDocDelete`)
- User confirmation/cancellation
- Document & subject IDs being deleted
- Success/failure of delete operation
- State cleanup after deletion

**Location:** Build method
- Total docs from Firestore stream
- Active subject/folder state
- Documents being filtered out (in `_deletingDocIds`)
- Final filtered count for display

**Location:** `_openSubject()` method
- Subject being opened
- Total documents from stream
- Documents filtered for this subject
- Individual document IDs being displayed

**Location:** Subject card rendering
- Subject name & ID
- File count being displayed
- Total docs available in stream

**Location:** `_documentsForSubject()` helper
- Filtering logic results
- Document count per subject

### 🔥 KnowledgeEngine Layer (knowledge_engine.dart)
- User authentication verification
- Document metadata fetch
- **Step 1:** Firebase Storage deletion start/complete
- **Step 2:** Firestore deletion start/complete  
- **Step 3:** Cache invalidation
- Complete deletion success confirmation

### 📦 Firebase Storage Layer (firebase_upload_service.dart)
- Storage path being deleted
- Success/failure with stack traces
- Empty path handling

### 🗑️ Firestore Service Layer (firestore_service.dart)

**Location:** `deleteDocument()` method
- Document path construction
- Subject ownership verification
- Document ownership verification
- Related data fetch (chat sessions, knowledge, cache)
- Batch commit operation
- Chat session deletion
- Knowledge item deletion  
- Cache entry deletion
- Complete Firestore deletion confirmation

**Location:** `streamUserDocuments()` method
- Stream creation for user
- Stream listener attachment
- Subjects snapshot updates (count)
- Document listener creation per subject
- **Documents snapshot per subject (count from Firestore)**
- Owner filtering results
- Total documents being emitted
- **Per-subject document counts in stream**
- Error handling for streams

---

## How to Use These Logs

### Step 1: Run the app in debug mode
```bash
flutter run -d chrome --debug
```

### Step 2: Perform deletion test
1. Open the Library view
2. Note the file count on a subject card (e.g., "9 files")
3. Open that subject
4. Delete a document
5. Watch the console logs

### Step 3: Analyze the log sequence

Look for this emoji trail in the console:

```
🖱️ [UI] Delete confirmed for document: <docId>
🔥 [KnowledgeEngine] Starting document deletion...
📦 [Firebase Storage] Deleting file at: <path>
📦 [Firebase Storage] ✅ File deleted successfully
🗑️ [DELETE] Starting deletion for document: <docId>
🗑️ [DELETE] Document path: subjects/<subjectId>/documents/<docId>
🗑️ [DELETE] Found X chat sessions
🗑️ [DELETE] Found Y knowledge items
🗑️ [DELETE] Found Z cache entries
🗑️ [DELETE] Committing batch delete...
🗑️ [DELETE] ✅ Main document deleted from Firestore
🗑️ [DELETE] ✅ Chat sessions deleted
🗑️ [DELETE] ✅ Knowledge items deleted
🗑️ [DELETE] ✅ Cache entries deleted
🗑️ [DELETE] ✅✅✅ DOCUMENT DELETION COMPLETE
🔥 [KnowledgeEngine] ✅✅✅ DELETE COMPLETE
🖱️ [UI] ✅✅✅ UI DELETE HANDLER COMPLETE
```

### Step 4: Check stream updates

After deletion completes, watch for:

```
📡 [STREAM] Documents snapshot for subject <subjectId>: X docs in Firestore
📡 [STREAM] After owner filter: X docs
📡 [STREAM] Emitting Y total documents
📡 [STREAM]   Subject <subjectId>: X docs
```

**Key question:** Does the count decrease immediately after deletion?

### Step 5: Verify UI updates

```
📋 [UI] Build: Total docs from Firestore stream: X
📋 [UI] Build: Filtered docs for display: Y
🎴 [UI] Subject card "<name>": showing Z files
```

**Key question:** Does the subject card count update after the stream emits?

---

## What to Look For

### ✅ Expected Behavior (Working Correctly)
1. Deletion completes all steps without errors
2. Stream emits updated document count immediately
3. Subject card shows decreased file count
4. Opening subject shows correct (reduced) file list
5. Refresh doesn't bring files back

### ❌ Problem Indicators

#### Problem 1: Firestore deletion fails
**Symptoms:**
- Error in `🗑️ [DELETE]` logs
- Batch commit fails

**Look for:**
- Permission errors
- Network errors
- Document not found errors

#### Problem 2: Stream doesn't emit after deletion
**Symptoms:**
- No `📡 [STREAM]` log after deletion completes
- Stream shows old count

**Possible causes:**
- Stream listener not attached to Firestore
- Stream using cached data
- Firestore rules blocking read after delete

#### Problem 3: Stream emits but UI doesn't update
**Symptoms:**
- `📡 [STREAM]` shows correct (reduced) count
- `🎴 [UI] Subject card` shows old count

**Possible causes:**
- Widget not rebuilding after stream update
- Subject card using stale reference
- Riverpod provider not notifying listeners

#### Problem 4: Documents reappear after refresh
**Symptoms:**
- Deletion succeeds
- UI updates correctly
- Refresh brings files back

**Possible causes:**
- Local cache recreating documents
- Firestore document not actually deleted (only hidden)
- Different Firestore path being read on refresh

---

## Critical Debugging Points

### Check 1: Is the document actually deleted from Firestore?
- Look for: `🗑️ [DELETE] ✅ Main document deleted from Firestore`
- Verify in Firebase Console: `subjects/{subjectId}/documents/{docId}` should be gone

### Check 2: Does the stream receive the deletion event?
- Look for: `📡 [STREAM] Documents snapshot for subject X: Y docs`
- Compare count before and after deletion

### Check 3: Is the UI reading from the stream?
- Look for: `📋 [UI] Build: Total docs from Firestore stream: X`
- Compare with stream emission count

### Check 4: Are deleted docs filtered correctly?
- Look for: `📋 [UI] Filtering out deleting doc: <docId>`
- Check if `_deletingDocIds` is being populated and cleared correctly

### Check 5: Is the subject card counting from the updated stream?
- Look for: `🎴 [UI] Subject card "<name>": showing X files (from Y total docs in stream)`
- Compare X and Y before/after deletion

---

## Next Steps Based on Logs

### If deletion completes but stream doesn't update:
→ Check Firestore listener implementation
→ Verify Firestore rules allow reading after deletion
→ Check for stream caching issues

### If stream updates but UI doesn't refresh:
→ Check Riverpod provider setup
→ Verify widget is watching the provider (not just reading)
→ Check if `_deletingDocIds` is being cleared correctly

### If documents reappear after refresh:
→ Verify Firestore document is actually deleted (not just status changed)
→ Check for multiple document sources being merged
→ Look for local database syncing stale data back to Firestore

---

## Files Modified

1. **lib/services/firestore_service.dart**
   - Enhanced `deleteDocument()` with step-by-step logging
   - Enhanced `streamUserDocuments()` with emission tracking

2. **lib/core/ai/services/knowledge_engine.dart**
   - Enhanced `deleteDocument()` with 3-step logging
   - Enhanced `_deleteStorageObjectIfPresent()` with status logs

3. **lib/core/services/firebase_upload_service.dart**
   - Enhanced `deleteStoredDocument()` with detailed logging

4. **lib/features/semester/presentation/screens/library_screen.dart**
   - Enhanced delete handler with operation tracking
   - Enhanced build method with stream/filter tracking
   - Enhanced `_openSubject()` with document listing
   - Enhanced subject card with file count tracking
   - Enhanced `_documentsForSubject()` with filter results

---

## Testing Checklist

- [ ] Delete a document and verify all deletion steps complete
- [ ] Check if Firestore stream emits updated count
- [ ] Check if subject card file count decreases
- [ ] Open subject and verify document is gone
- [ ] Close and reopen subject - document should stay gone
- [ ] Refresh browser/app - document should stay gone
- [ ] Check Firebase Console - document should not exist in Firestore
- [ ] Check Firebase Storage - file should be deleted

---

## Log Output Format

All logs use emoji prefixes for easy filtering:

- 🖱️ **[UI]** - User interface layer events
- 🔥 **[KnowledgeEngine]** - Business logic layer
- 📦 **[Firebase Storage]** - Storage operations
- 🗑️ **[DELETE]** - Firestore deletion operations
- 📡 **[STREAM]** - Firestore stream updates
- 📋 **[UI]** - Build/render cycle tracking
- 🎴 **[UI]** - Subject card rendering
- 🔍 **[UI]** - Subject opening/navigation
- 📊 **[UI]** - Document filtering logic

Use browser DevTools console filter to focus on specific layers.

---

## Report Format

After testing, please provide:

1. **Full console output** from delete button click to completion
2. **Subject card file count** before and after deletion
3. **Stream emission logs** showing document counts
4. **Any error messages** or stack traces
5. **Behavior after refresh** - do files reappear?

This will allow precise identification of where stale data is being reintroduced.
