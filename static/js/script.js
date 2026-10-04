document.addEventListener('DOMContentLoaded', () => {
    const dropZone = document.getElementById('drop-zone');
    const fileInput = document.getElementById('file-input');
    const browseBtn = document.getElementById('browse-btn');
    const imagePreview = document.getElementById('image-preview');
    const dropZoneContent = document.querySelector('.drop-zone-content');
    const recognizeBtn = document.getElementById('recognize-btn');
    const resultBox = document.getElementById('result-box');
    const resultText = document.getElementById('result-text');
    const btnText = recognizeBtn.querySelector('span');
    const spinner = recognizeBtn.querySelector('.spinner');

    let currentFile = null;

    // Handle Drag & Drop
    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
        dropZone.addEventListener(eventName, preventDefaults, false);
    });

    function preventDefaults(e) {
        e.preventDefault();
        e.stopPropagation();
    }

    ['dragenter', 'dragover'].forEach(eventName => {
        dropZone.addEventListener(eventName, () => {
            dropZone.classList.add('dragover');
        }, false);
    });

    ['dragleave', 'drop'].forEach(eventName => {
        dropZone.addEventListener(eventName, () => {
            dropZone.classList.remove('dragover');
        }, false);
    });

    dropZone.addEventListener('drop', (e) => {
        const dt = e.dataTransfer;
        const files = dt.files;
        handleFiles(files);
    });

    // Handle Click to Browse
    browseBtn.addEventListener('click', () => {
        fileInput.click();
    });
    
    // Also allow clicking the whole drop zone (except when clicking the button directly)
    dropZone.addEventListener('click', (e) => {
        if(e.target !== browseBtn && e.target !== fileInput) {
             fileInput.click();
        }
    });

    fileInput.addEventListener('change', function() {
        handleFiles(this.files);
    });

    function handleFiles(files) {
        if (files.length === 0) return;
        
        const file = files[0];
        if (!file.type.startsWith('image/')) {
            alert('Please upload an image file.');
            return;
        }

        currentFile = file;
        showPreview(file);
        
        // Reset result
        resultBox.classList.add('hidden');
        resultText.textContent = '';
        
        // Enable recognize button
        recognizeBtn.classList.remove('hidden');
        recognizeBtn.disabled = false;
    }

    function showPreview(file) {
        const reader = new FileReader();
        reader.readAsDataURL(file);
        reader.onloadend = function() {
            imagePreview.src = reader.result;
            imagePreview.classList.remove('hidden');
            dropZoneContent.classList.add('hidden');
        }
    }

    // Handle API Request
    recognizeBtn.addEventListener('click', async () => {
        if (!currentFile) return;

        const formData = new FormData();
        formData.append('image', currentFile);

        // UI Loading state
        recognizeBtn.disabled = true;
        btnText.textContent = 'Processing...';
        spinner.classList.remove('hidden');
        resultBox.classList.add('hidden');

        try {
            const response = await fetch('/api/recognize', {
                method: 'POST',
                body: formData
            });

            const data = await response.json();

            if (!response.ok) {
                throw new Error(data.error || 'Failed to process image');
            }

            // Show result
            resultText.textContent = data.text;
            resultText.style.color = '#10b981'; // Green for success
            resultBox.classList.remove('hidden');
            
        } catch (error) {
            console.error('Error:', error);
            resultText.textContent = `Error: ${error.message}`;
            resultText.style.color = '#ef4444'; // Red for error
            resultBox.classList.remove('hidden');
        } finally {
            // Restore UI state
            recognizeBtn.disabled = false;
            btnText.textContent = 'Run OCR';
            spinner.classList.add('hidden');
        }
    });
});
