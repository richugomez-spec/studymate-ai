# Upload Pipeline Audit - Complete Trace

**Date:** 2026-10-22  
**Issue:** Upload/index lifecycle verification and comprehensive logging

---

## Upload Pipeline Architecture

### Complete Flow: `KnowledgeEngine.uploadAndIndex()`

```
📤 STEP 1: Create Firestore Document
  └─> firestore.createDocumentRecord()
      └─> Creates: subjects/{subjectId}/documents/{documentId}
      └─> Status: queued
      └─> AWAITED: ✅

📤 STEP 2: Set Uploading State
  └─> firestore.updateDocumentPipelineState()
      └─> Updates status: 'uploading'
      └─> AWAITED: ✅

📤 STEP 3: Upload to Firebase Storage
  └─> upload.uploadToStorage()
      └─> Uploads file to: uploads/{ownerId}/{subjectId}/{documentId}_{filename}
      └─> Returns download URL
      └─> Progress callbacks: onUploadProgress
      └─> AWAITED: ✅

📤 STEP 4: Save Download URL
  └─> firestore.updateDocumentPipelineState()
      └─> Updates downloadUrl
      └─> Updates status: 'extracting'
      └─> AWAITED: ✅

📤 STEP 5: Extract and Index Document
  └─> _indexUploadedSource()
      │
      ├─> 📑 STEP 5.1: Set Extracting State
      │   └─> firestore.updateDocumentPipelineState()
      │       └─> Status: 'extracting'
      │       └─> AWAITED: ✅
      │
      ├─> 📑 STEP 5.2: Download from Storage (if bytes not available)
      │   └─> upload.downloadDocument()
      │       └─> Downloads file bytes from storage
      │       └─> AWAITED: ✅
      │
      ├─> 📑 STEP 5.3: Extract Text
      │   └─> processing.extractText()
      │       └─> Extracts text from PDF/DOCX/etc.
      │       └─> AWAITED: ✅
      │
      ├─> 📑 STEP 5.4: Save Extracted Text
      │   └─> firestore.saveExtractedText()
      │       └─> Saves text to Firestore document
      │       └─> AWAITED: ✅
      │
      ├─> 📑 STEP 5.5: Set Indexing State
      │   └─> firestore.updateDocumentPipelineState()
      │       └─> Status: 'indexing'
      │       └─> AWAITED: ✅
      │
      └─> 📑 STEP 5.6: Generate and Save Index
          └─> index()
              │
              ├─> 🔍 STEP 5.6.1: AI Model Generation
              │   └─> _generateUncached()
              │       └─> Calls AI model to extract structured knowledge
              │       └─> AWAITED: ✅
              │
              └─> 🔍 STEP 5.6.2: Save Index to Firestore
                  └─> firestore.saveKnowledgeIndex()
                      └─> Saves knowledge index
                      └─> Updates document status: 'indexed'
                      └─> AWAITED: ✅

📤 RETURN: UploadResult
  └─> downloadUrl
  └─> storagePath
  └─> firestoreDocId
```

---

## Verification Checklist

### ✅ Every Async Operation is Awaited

1. **firestore.createDocumentRecord()** - ✅ AWAITED (Line 341-357)
2. **firestore.updateDocumentPipelineState()** (uploading) - ✅ AWAITED (Line 359-367)
3. **upload.uploadToStorage()** - ✅ AWAITED (Line 368-376)
4. **firestore.updateDocumentPipelineState()** (extracting) - ✅ AWAITED (Line 381-390)
5. **_indexUploadedSource()** - ✅ AWAITED (Line 392-406)
   - **firestore.updateDocumentPipelineState()** (extracting) - ✅ AWAITED
   - **upload.downloadDocument()** - ✅ AWAITED (conditional)
   - **processing.extractText()** - ✅ AWAITED
   - **firestore.saveExtractedText()** - ✅ AWAITED
   - **firestore.updateDocumentPipelineState()** (indexing) - ✅ AWAITED
   - **index()** - ✅ AWAITED
     - **_generateUncached()** (AI generation) - ✅ AWAITED
     - **firestore.saveKnowledgeIndex()** - ✅ AWAITED

### ✅ No Unawaited Futures

Searched for:
- `unawaited()` calls - None in upload pipeline
- Fire-and-forget futures - None found
- Background timers - None found
- Detached streams - None found

### ✅ Single Upload Pipeline

- **ONE entry point**: `uploadAndIndex()`
- **ONE sequential flow**: All steps executed in order
- **NO parallel uploads**: Each step waits for previous to complete
- **NO background tasks**: Everything happens in the main async flow

---

## Comprehensive Logging Added

### 📤 Upload Pipeline (`uploadAndIndex`)

**Start:**
- File name, size, subject
- Owner ID verification
- Document ID generation
- Storage path

**Each Step:**
- Clear step number and description
- Operation being performed
- Success confirmation with ✅
- Any returned data (URLs, IDs)

**Completion:**
- Final document ID
- Confirmation all async operations completed
- Return value logged

**Errors:**
- Failed step identification
- Full error message
- Stack trace
- Failure state persistence attempt

### 📑 Indexing (`_indexUploadedSource`)

**Start:**
- Source ID and filename
- Cached text availability
- File bytes availability

**Each Sub-step:**
- Step number (5.1, 5.2, etc.)
- Operation description
- Downloaded bytes count
- Extracted text length
- Status updates
- Success confirmation

**Completion:**
- Total indexing complete message

### 🔍 AI Index Generation (`index`)

**Start:**
- Source details
- Content length
- Subject information

**AI Generation:**
- Model request start
- Generated index keys
- Callback invocation

**Firestore Save:**
- Index save operation
- Context invalidation

**Completion:**
- AI index generation complete message

---

## Log Output Format

All logs use emoji prefixes:

- **📤 [UPLOAD]** - Main upload pipeline steps
- **📑 [INDEX]** - Text extraction and indexing
- **🔍 [INDEX]** - AI model generation and knowledge save
- **✅** - Operation completed successfully
- **❌** - Operation failed

### Expected Log Sequence

```
📤 [UPLOAD] ========== UPLOAD PIPELINE START ==========
📤 [UPLOAD] File: example.pdf (1234567 bytes)
📤 [UPLOAD] Subject: Computer Science (abc123)
📤 [UPLOAD] Owner ID: user_xyz
📤 [UPLOAD] Generated document ID: doc_789
📤 [UPLOAD] Storage path: uploads/user_xyz/abc123/doc_789_example.pdf
📤 [UPLOAD] ===== STEP 1: CREATE FIRESTORE DOCUMENT =====
UPLOAD CREATE FIRESTORE DOCUMENT START
UPLOAD CREATE FIRESTORE DOCUMENT COMPLETE
📤 [UPLOAD] ✅ Firestore document created
📤 [UPLOAD] ===== STEP 2: SET UPLOADING STATE =====
UPLOAD SET UPLOADING STATE START
UPLOAD SET UPLOADING STATE COMPLETE
📤 [UPLOAD] ✅ Status set to uploading
📤 [UPLOAD] ===== STEP 3: UPLOAD TO FIREBASE STORAGE =====
UPLOAD STORAGE UPLOAD AND DOWNLOAD URL START
UPLOAD STORAGE TASK CREATE START: uploads/...
UPLOAD STORAGE TASK WAIT START: uploads/...
UPLOAD STORAGE TASK COMPLETE: uploads/...
UPLOAD DOWNLOAD URL FETCH START: uploads/...
UPLOAD DOWNLOAD URL FETCH COMPLETE: uploads/...
UPLOAD STORAGE UPLOAD AND DOWNLOAD URL COMPLETE
📤 [UPLOAD] ✅ Storage upload complete, URL: https://...
📤 [UPLOAD] ===== STEP 4: SAVE DOWNLOAD URL =====
UPLOAD SAVE STORAGE DOWNLOAD URL START
UPLOAD SAVE STORAGE DOWNLOAD URL COMPLETE
📤 [UPLOAD] ✅ Download URL saved, status set to extracting
📤 [UPLOAD] ===== STEP 5: EXTRACT AND INDEX =====
UPLOAD EXTRACT AND INDEX DOCUMENT START
📑 [INDEX] ========== INDEXING START ==========
📑 [INDEX] Source ID: doc_789
📑 [INDEX] File: example.pdf
📑 [INDEX] ----- STEP 5.1: SET EXTRACTING STATE -----
UPLOAD SET EXTRACTING STATE START
UPLOAD SET EXTRACTING STATE COMPLETE
📑 [INDEX] ✅ Status set to extracting
📑 [INDEX] ----- STEP 5.3: EXTRACT TEXT -----
UPLOAD EXTRACT TEXT START
UPLOAD EXTRACT TEXT COMPLETE
📑 [INDEX] ✅ Extracted 12345 characters
📑 [INDEX] ----- STEP 5.4: SAVE EXTRACTED TEXT -----
UPLOAD SAVE EXTRACTED TEXT START
UPLOAD SAVE EXTRACTED TEXT COMPLETE
📑 [INDEX] ✅ Extracted text saved to Firestore
📑 [INDEX] ----- STEP 5.5: SET INDEXING STATE -----
UPLOAD SET INDEXING STATE START
UPLOAD SET INDEXING STATE COMPLETE
📑 [INDEX] ✅ Status set to indexing
📑 [INDEX] ----- STEP 5.6: GENERATE AND SAVE INDEX -----
UPLOAD GENERATE AND SAVE INDEX START
🔍 [INDEX] ========== AI INDEX GENERATION START ==========
🔍 [INDEX] Source ID: doc_789
🔍 [INDEX] ----- STEP 5.6.1: AI MODEL GENERATION -----
UPLOAD AI INDEX GENERATION START
UPLOAD INDEX MODEL REQUEST START: index_knowledge
UPLOAD INDEX MODEL REQUEST COMPLETE: index_knowledge
UPLOAD AI INDEX GENERATION COMPLETE
🔍 [INDEX] ✅ AI index generated: concepts, definitions, facts...
📑 [INDEX] ✅ AI index generation complete
🔍 [INDEX] ----- STEP 5.6.2: SAVE INDEX TO FIRESTORE -----
UPLOAD FIRESTORE INDEX UPDATE START
UPLOAD FIRESTORE INDEX UPDATE COMPLETE
🔍 [INDEX] ✅ Index saved to Firestore
🔍 [INDEX] ========== AI INDEX GENERATION COMPLETE ==========
UPLOAD GENERATE AND SAVE INDEX COMPLETE
📑 [INDEX] ========== INDEXING COMPLETE ==========
UPLOAD EXTRACT AND INDEX DOCUMENT COMPLETE
📤 [UPLOAD] ✅ Extraction and indexing complete
📤 [UPLOAD] ========== UPLOAD PIPELINE COMPLETE ==========
📤 [UPLOAD] Document ID: doc_789
📤 [UPLOAD] All async operations completed, returning result
```

---

## What to Look For

### ✅ Expected Behavior (Working Correctly)

1. Every step completes in sequence
2. No hanging awaits (each operation logs START and COMPLETE)
3. Status transitions: queued → uploading → extracting → indexing → indexed
4. Upload dialog closes only after "UPLOAD PIPELINE COMPLETE"
5. Document appears with status "indexed" after completion

### ❌ Problem Indicators

#### Problem 1: Upload hangs at a specific step
**Symptoms:**
- Log shows "START" but never "COMPLETE"
- Upload dialog never closes

**Look for:**
- Last logged step before hang
- No error message (silent hang)

**Possible causes:**
- Network timeout
- Firestore write hanging
- AI model request hanging
- File processing hanging

#### Problem 2: Upload completes but document status is wrong
**Symptoms:**
- "UPLOAD PIPELINE COMPLETE" logged
- Upload dialog closes
- Document shows status "uploading" or "extracting" instead of "indexed"

**Look for:**
- Which step completed last
- Whether "FIRESTORE INDEX UPDATE COMPLETE" logged
- Whether status was actually set to "indexed"

**Possible causes:**
- Firestore update not awaited properly
- Status update failing silently
- Stream not emitting updated status

#### Problem 3: Upload fails with error
**Symptoms:**
- "❌❌❌ UPLOAD FAILED at [step]" logged
- Error message and stack trace

**Look for:**
- Which step failed (firestore_create, storage_upload, extract_error, index_error)
- Exact error message
- Whether failure state was persisted

---

## Testing Instructions

### Test 1: Successful Upload
1. Select a PDF file
2. Upload to a subject
3. Watch console logs
4. Verify complete sequence appears
5. Verify document shows "indexed" status
6. Verify upload dialog closes

### Test 2: Large File Upload
1. Upload a 20MB+ file
2. Watch for each step completing
3. Verify no timeouts
4. Verify progress bar updates

### Test 3: Network Interruption (if possible)
1. Start upload
2. Disconnect network during storage upload
3. Verify error is caught and logged
4. Verify failure state is persisted

---

## Critical Verification Points

### Point 1: uploadAndIndex() returns only after ALL operations complete
- ✅ VERIFIED: All async operations use `await`
- ✅ VERIFIED: No unawaited futures
- ✅ VERIFIED: Return statement is after all steps

### Point 2: Every Firestore status update is awaited
- ✅ VERIFIED: createDocumentRecord - awaited
- ✅ VERIFIED: updateDocumentPipelineState (uploading) - awaited
- ✅ VERIFIED: updateDocumentPipelineState (extracting) - awaited
- ✅ VERIFIED: saveExtractedText - awaited
- ✅ VERIFIED: updateDocumentPipelineState (indexing) - awaited
- ✅ VERIFIED: saveKnowledgeIndex (indexed) - awaited

### Point 3: Upload progress dialog listens to the correct Future
**To verify:**
- Check where upload dialog is shown
- Verify it awaits `uploadAndIndex()` Future
- Verify it closes only when Future completes
- Share the upload dialog code location

---

## Files Modified

1. **lib/core/ai/services/knowledge_engine.dart**
   - Enhanced `uploadAndIndex()` with step-by-step logging
   - Enhanced `_indexUploadedSource()` with extraction/indexing logging
   - Enhanced `index()` with AI generation and save logging

---

## Next Steps

1. **Run the app** and upload a file
2. **Capture complete console output** from upload start to completion
3. **Report findings:**
   - Does every step complete?
   - Where does it hang (if it hangs)?
   - What error appears (if it fails)?
   - Does upload dialog close at the right time?
   - What is the final document status?

The comprehensive logging will reveal exactly which async operation is not completing or which step is hanging.

---

## Summary

✅ **VERIFIED:** Every async operation in the upload pipeline is properly awaited  
✅ **VERIFIED:** No unawaited futures, detached streams, or background timers  
✅ **VERIFIED:** Single sequential upload pipeline  
✅ **ADDED:** Comprehensive logging at every step  
✅ **ADDED:** Step numbering for easy tracing  
✅ **ADDED:** Success/failure indicators  

The upload pipeline is architecturally sound. If uploads are not completing, the logs will show exactly which step is hanging.
